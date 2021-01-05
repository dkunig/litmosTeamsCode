//class is called by a Flow when button is clicked on Team record page to update that specific team. Will load all members, then associate admins and leaders with the team as needed
public class litmosTeamMembersManual {
	//static final Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
    @AuraEnabled
    public static void updateTeamMembers(String team) {
        //litmosQueueableTeamMembers process = new litmosQueueableTeamMembers(team);
        Id jobId = System.enqueueJob(new litmosQueueableTeamMembers(team));
        System.debug('job started: ' + jobId);
        /*String litmosId = [SELECT Litmos_Id__c FROM Litmos_Team__c WHERE Id =: team LIMIT 1].Litmos_Id__c;
        //create set of existing users on team
        List<Litmos_Team_Member__c> members = [SELECT Id,Litmos_User_Id__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c =: team];
        Set<String> onTeam = new Set<String>();
        for(Litmos_Team_Member__c mem : members) {
            onTeam.add(mem.Litmos_User_Id__c);
        }
        HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__Api_End_Point__c + 'teams/' + litmosId + '/users?source=sourceapp&format=json&limit=1000', config.Litmos__API_Key__c);
        Map<String,Litmos_Team_Member__c> mapMembers = new Map<String,Litmos_Team_Member__c>();
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> obj = (Map<String,Object>)o;
                if(!onTeam.contains(String.valueOf(obj.get('Id')))) {
                    mapMembers.put(String.valueOf(obj.get('Id')),new Litmos_Team_Member__c(
                    	Litmos_Team__c = team,
                        Litmos_User_Id__c = String.valueOf(obj.get('Id'))
                    ));
                }
            }
        }
        List<User> newMembers = [SELECT Id,Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN :mapMembers.keySet()];
        for(User u : newMembers) {
            for(Litmos_Team_Member__c mem : mapMembers.values()) {
                if(mem.Litmos_User_Id__c == u.Litmos__LitmosUserId__c) {
                    mem.Learner__c = u.Id;
                }
            }
        }
        
        Set<Id> teamMemSuccesses = new Set<Id>();
        Set<Id> teamMemErrors = new Set<Id>();
        Map<String,String> errors = new Map<String,String>();
        List<Database.SaveResult> saveResults = Database.insert(mapMembers.values());
        for(Database.SaveResult sr : saveResults) {
            if(sr.isSuccess()) {
                teamMemSuccesses.add(sr.getId());
            } else {
                teamMemErrors.add(sr.getId());
                errors.put(sr.getId(),String.valueOf(sr.getErrors()));
            }
        }
        if(teamMemSuccesses.size() > 0) {
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN :teamMemSuccesses]);
        }
        if(teamMemErrors.size() > 0) {
			litmosSyncLogs.logTeamMemberErrors([SELECT Id FROM Litmos_Team__c WHERE Id =:team], errors);
        }
        //if testing, don't proceed to next piece of admin and leader updating
        if(!test.isRunningTest()) {
            litmosTeamLeadAdmin.getTeamAdmins(team);
        }*/
    }
}