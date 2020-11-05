public class LitmosTeamsConnect {
	static final Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
    //one-time upload of all teams
    public static void getAllTeams() {
        HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams?source=sourceapp&format=json', config.Litmos__API_Key__c);
        List<Litmos_Team__c> teams = new List<Litmos_Team__c>();
        List<String> parentIds = new List<String>();
        Map<String,String> childrenIds = new Map<String,String>();
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> obj = (Map<String,Object>)o;
                Litmos_Team__c team = new Litmos_Team__c();
                team.Name = String.valueOf(obj.get('Name'));
                team.Litmos_Id__c = String.valueOf(obj.get('Id'));
                team.Team_Code_for_Bulk_Import__c = String.valueOf(obj.get('TeamCodeForBulkImport'));
                teams.add(team);
                if(obj.get('ParentTeamId') != '') {
                    childrenIds.put(String.valueOf(obj.get('Id')),String.valueOf(obj.get('ParentTeamId')));
                }
            }
        }
        Set<Id> teamSuccesses = new Set<Id>();
        Set<Id> teamErrors = new Set<Id>();
        Map<String,List<Database.Error>> errors = new Map<String,List<Database.Error>>();
        Schema.SObjectField litmosId = Litmos_Team__c.Fields.Litmos_Id__c;
        List<Database.UpsertResult> upRes = Database.upsert(teams,litmosId, false);
        for(Database.UpsertResult res : upRes) {
            if(res.isSuccess()) {
                teamSuccesses.add(res.getId());
            } else {
                teamErrors.add(res.getId());
                errors.put(res.getId(),res.getErrors());
            }
        }
        Map<Id, Litmos_Team__c> parents = new Map<Id, Litmos_Team__c>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.values()]);
        Map<Id,Litmos_Team__c> children = new Map<Id, Litmos_Team__c>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.keySet()]);
        List<Litmos_Team__c> updates = new List<Litmos_Team__c>();

        for(Id child : children.keySet()) {
            for(Id par : parents.keySet()) {
                if(parents.get(par).Litmos_Id__c == childrenIds.get(children.get(child).Litmos_Id__c)) {
                    updates.add(new Litmos_Team__c(
                    	Id = child,
                        Litmos_Parent_Team__c = par
                    ));
                }
            }
        }
        List<Database.SaveResult> saveRes = Database.update(updates, false);
		
        for(Database.SaveResult sr : saveRes) {
            if(sr.isSuccess()) {
                teamSuccesses.add(sr.getId());
            } else {
                teamErrors.add(sr.getId());
                errors.put(sr.getId(), sr.getErrors());
            }
        }
        
        if(teamSuccesses.size() > 0) {
            litmosSyncLogs.logTeamsSuccess([SELECT Id FROM Litmos_Team__c WHERE Id IN : teamSuccesses]);
        }
        if(teamErrors.size() > 0) {
            litmosSyncLogs.logTeamsErrors([SELECT Id FROM Litmos_Team__c WHERE ID IN : teamErrors], errors);
        }
    }
    public static void updateNullDescriptions() {
        List<Litmos_Team__c> teams = [SELECT Id,Name,Description__c,Litmos_Id__c FROM Litmos_Team__c];
        List<Litmos_Team__c> emptyDesc = new List<Litmos_Team__c>();
        for(Litmos_Team__c t : teams) {
            if(t.Description__c == null) {
                emptyDesc.add(t);
            }
        }
        List<Litmos_Team__c> updates = new List<Litmos_Team__c>();
        for(Litmos_Team__c t : emptyDesc) {
            HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + t.Litmos_Id__c + '?source=sourceapp&format=json', config.Litmos__Api_Key__c);
            if(response.getStatusCode() == 200) {
                Map<String,Object> myMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                if(myMap.get('Description') != '') {
                    t.Description__c = String.valueOf(myMap.get('Description'));
                    updates.add(t);
                }
            }
        }
        Set<Id> teamSuccesses = new Set<Id>();
        Set<Id> teamErrors = new Set<Id>();
        Map<String,List<Database.Error>> errors = new Map<String,List<Database.Error>>();
        List<Database.SaveResult> saveResults = Database.update(updates, false);
        for(Database.SaveResult res : saveResults) {
            if(res.isSuccess()) {
                teamSuccesses.add(res.getId());
            } else {
                teamErrors.add(res.getId());
                errors.put(res.getId(),res.getErrors());
            }
        }
        if(teamSuccesses.size() > 0) {
            litmosSyncLogs.logTeamsSuccess([SELECT Id FROM Litmos_Team__c WHERE Id IN : teamSuccesses]);
        }
        if(teamErrors.size() > 0) {
            litmosSyncLogs.logTeamsErrors([SELECT Id FROM Litmos_Team__c WHERE ID IN : teamErrors], errors);
        }
    }
    public static void insertTeamMembers() {
		List<Litmos_Team__c> teams = [SELECT Id,Litmos_Id__c FROM Litmos_Team__c];
        Map<Id,List<Object>> myMemberMap = new Map<Id,List<Object>>();
        for(Litmos_Team__c t : teams) {
            HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__Api_End_Point__c + 'teams/' + t.Litmos_Id__c + '/users?source=sourceapp&format=json', config.Litmos__API_Key__c);
            if(response.getStatusCode() == 200) {
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                myMemberMap.put(t.Id,results);
            }
        }
        LitmosTeamsQueueProcessing process = new LitmosTeamsQueueProcessing(myMemberMap);
        Id jobId = System.enqueueJob(process);
    }
    public static void getTeamLeaders() {
        Map<Id,Litmos_Team__c> teams = new Map<Id,Litmos_Team__C>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c]);
		Map<String,Litmos_Team_Member__c> members = new Map<String,Litmos_Team_Member__c>();
        for(Id t : teams.keySet()) {
            HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + teams.get(t).Litmos_Id__c + '/leaders?source=sourceapp&format=json', config.Litmos__API_Key__c);
            if(response.getStatusCode() == 200) {
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                
                for(Object o : results) {
                    Map<String,Object> obj = (Map<String,Object>)o;
                    members.put(String.valueOf(obj.get('Id')), new Litmos_Team_Member__c(
                    	Litmos_Team__c = t,
                        Litmos_User_Id__c = String.valueOf(obj.get('Id'))
                    ));
                }
            }
        }
        List<Litmos_Team_Member__c> updateMembers = [SELECT Id,Litmos_User_Id__c,Learner__r.Name,Litmos_Team__r.Name,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c IN : members.keySet()];
        for(Litmos_Team_Member__c mem : members.values()) {
            for(Litmos_Team_Member__c u : updateMembers) {
                if(u.Litmos_User_Id__c == mem.Litmos_User_Id__c && u.Litmos_Team__c == mem.Litmos_Team__c) {
                    u.Member_Type__c = 'Leader';
                }
            }
        }
        
        //update updateMembers;
        Set<Id> teamSuccesses = new Set<Id>();
        Set<Id> teamErrors = new Set<Id>();
        Map<String,List<Database.Error>> errors = new Map<String,List<Database.Error>>();
        List<Database.SaveResult> saveResults = Database.update(updateMembers, false);
        for(Database.SaveResult res : saveResults) {
            if(res.isSuccess()) {
                teamSuccesses.add(res.getId());
            } else {
                teamErrors.add(res.getId());
                errors.put(res.getId(),res.getErrors());
            }
        }
        if(teamSuccesses.size() > 0) {
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN : teamSuccesses]);
        }
        if(teamErrors.size() > 0) {
            litmosSyncLogs.logTeamMemberErrors([SELECT Id FROM Litmos_Team_Member__c WHERE ID IN : teamErrors], errors);
        }
    }
    public static void getTeamAdmins() {
        Map<Id,Litmos_Team__c> teams = new Map<Id,Litmos_Team__C>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c]);
        Map<String,Litmos_Team_Member__c> members = new Map<String,Litmos_Team_Member__c>();
        //need to add team Ids to SFDC or have another soql query to pull them. Need team member query to pull AND for litmos_user_id and Team_id
        for(Id t : teams.keySet()) {
            HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + teams.get(t).Litmos_Id__c  + '/admins?source=sourceapp&format=json',config.Litmos__API_Key__c);
            if(response.getStatusCode() == 200) {
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                for(Object o : results) {
                    Map<String,Object> obj = (Map<String,Object>)o;
                    members.put(String.valueOf(obj.get('Id')),new Litmos_Team_Member__c(
                    	Litmos_User_Id__c = String.valueOf(obj.get('Id')),
                        Litmos_Team__c = t
                    ));
                }
            }
        }
        List<Litmos_Team_Member__c> updateMembers = [SELECT Id,Litmos_User_Id__c,Litmos_Team__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c IN : members.keySet()];
        for(Litmos_Team_Member__c mem : members.values()) {
            for(Litmos_Team_Member__c u : updateMembers) {
                if(u.Litmos_User_Id__c == mem.Litmos_User_Id__c && u.Litmos_Team__c == mem.Litmos_Team__c){
					u.Member_Type__c = 'Admin';
                }
            }
        }
        //update updateMembers;
        Set<Id> teamSuccesses = new Set<Id>();
        Set<Id> teamErrors = new Set<Id>();
        Map<String,List<Database.Error>> errors = new Map<String,List<Database.Error>>();
        List<Database.SaveResult> saveResults = Database.update(updateMembers, false);
        for(Database.SaveResult res : saveResults) {
            if(res.isSuccess()) {
                teamSuccesses.add(res.getId());
            } else {
                teamErrors.add(res.getId());
                errors.put(res.getId(),res.getErrors());
            }
        }
        if(teamSuccesses.size() > 0) {
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN : teamSuccesses]);
        }
        if(teamErrors.size() > 0) {
            litmosSyncLogs.logTeamMemberErrors([SELECT Id FROM Litmos_Team_Member__c WHERE ID IN : teamErrors], errors);
        }
    }
}