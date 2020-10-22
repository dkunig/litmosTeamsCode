public class LitmosTeamsConnect {
	static final Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
    //one-time upload of all teams
    public static void getAllTeams() {
        HttpResponse response = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams?source=sourceapp&format=json', config.Litmos__API_Key__c);
        List<Litmos_Team__c> teams = new List<Litmos_Team__c>();
        List<String> parentIds = new List<String>();
        Map<String,String> childrenIds = new Map<String,String>();
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('all results: ' + results);
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
        upsert teams Litmos_Id__c;
        //List<Litmos_Team__c> parents = [SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.values()];
        //List<Litmos_Team__c> children = [SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.keySet()];
        Map<Id, Litmos_Team__c> parents = new Map<Id, Litmos_Team__c>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.values()]);
        Map<Id,Litmos_Team__c> children = new Map<Id, Litmos_Team__c>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.keySet()]);
        List<Litmos_Team__c> updates = new List<Litmos_Team__c>();
        Integer parentSize = parents.size();
        
        /*for(Litmos_Team__c c : children) {
            for(Litmos_Team__c parent : parents) {
                if(parent.Litmos_Id__c == childrenIds.get(c.Litmos_Id__c)) {
                    Litmos_Team__c team = new Litmos_Team__c();
                    team.Id = c.Id;
                    team.Litmos_Parent_Team__c = parent.Id;
                    updates.add(team);
                }
            }
        }*/
        upsert updates;
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
            //req.setEndpoint(config.Litmos__API_End_Point__c + 'teams/' + t.Litmos_Id__c + '?source=sourceapp&format=json');
            HttpResponse response = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + t.Litmos_Id__c + '?source=sourceapp&format=json', config.Litmos__Api_Key__c);
            if(response.getStatusCode() == 200) {
                Map<String,Object> myMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                if(myMap.get('Description') != '') {
                    t.Description__c = String.valueOf(myMap.get('Description'));
                    updates.add(t);
                }
            }
        }
        upsert updates;
    }
    public static void insertTeamMembers() {
        List<Litmos_Team__c> teams = [SELECT Id,Litmos_Id__c FROM Litmos_Team__c];
        List<Litmos_Team_Member__c> members = new List<Litmos_Team_Member__c>();
        Set<String> litmosIds = new Set<String>();
        for(Litmos_Team__c t : teams) {
            HttpResponse response = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + t.Litmos_Id__c + '/users?source=sourceapp&format=json', config.Litmos__Api_Key__c);
            if(response.getStatusCode() == 200) {
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                //List<Map<String,Object>> myMaps = new List<Map<String,Object>>(JSON.deserializeUntyped(response.getBody()));
                //System.debug(myMaps);
                Integer size = results.size();
                for(Integer i = 0; i < size; i++) {
                    Map<String,Object> myMap = (Map<String,Object>)results[i];
                    /*Litmos_Team_Member__c mem = new Litmos_Team_Member__c();
                    mem.Litmos_Team__c = t.Id; //litmos team member with litmos team populated
                    mem.Litmos_User_Id__c = String.valueOf(myMap.get('Id'));
                    members.add(mem);*/
                    members.add(new Litmos_Team_Member__c(Litmos_Team__c = t.Id, Litmos_User_Id__c = String.valueOf(myMap.get('Id'))));
                    litmosIds.add(String.valueOf(myMap.get('Id'))); //set of litmosIds for users
                }
            }
        }
        //List<User> users = [SELECT Id,Name,Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN :litmosIds];
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN : litmosIds]);
        List<User> users = userMap.values();
        System.debug(users);
        
        for(User u : users) {
            for(Litmos_Team_Member__c mem : members) {
                if(mem.Litmos_User_Id__c == u.Litmos__LitmosUserId__c) {
                    mem.Learner__c = u.Id;
                }
            }
        }
        List<Litmos_Team_Member__c> inserts = new List<Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c mem : members) {
            if(mem.Learner__c != null) {
                inserts.add(mem);
            }
        }
        System.debug('members after: ' + inserts);
        insert inserts;
    }
    public static void getTeamLeaders() {
        Map<Id,Litmos_Team__c> teams = new Map<Id,Litmos_Team__C>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c]);
        
        List<String> litmosIds = new List<String>();
		List<Litmos_Team_Member__c> members = new List<Litmos_Team_Member__c>();
        for(Id t : teams.keySet()) {
            HttpResponse response = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + teams.get(t).Litmos_Id__c + '/leaders?source=sourceapp&format=json', config.Litmos__API_Key__c);
            if(response.getStatusCode() == 200) {
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                
                for(Object o : results) {
                    Map<String,Object> obj = (Map<String,Object>)o;
                    members.add(new Litmos_Team_Member__c(
                    	Litmos_Team__c = t,
                        Litmos_User_Id__c = String.valueOf(obj.get('Id'))
                    ));
                    litmosIds.add(String.valueOf(obj.get('Id')));
                }
            }
        }
        List<Litmos_Team_Member__c> updateMembers = [SELECT Id,Litmos_User_Id__c,Learner__r.Name,Litmos_Team__r.Name,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c IN : litmosIds];
        for(Litmos_Team_Member__c mem : members) {
            for(Litmos_Team_Member__c u : updateMembers) {
                if(u.Litmos_User_Id__c == mem.Litmos_User_Id__c && u.Litmos_Team__c == mem.Litmos_Team__c) {
                    u.Member_Type__c = 'Leader';
                }
            }
        }
        update updateMembers;
    }
    public static void getTeamAdmins() {
        Map<Id,Litmos_Team__c> teams = new Map<Id,Litmos_Team__C>([SELECT Id,Litmos_Id__c FROM Litmos_Team__c]);
        
        HttpRequest req = new HttpRequest();
        req.setHeader('apikey', config.Litmos__API_Key__c);
        req.setHeader('content-type','application/json');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        List<String> litmosIds = new List<String>();
        List<Litmos_Team_Member__c> members = new List<Litmos_Team_Member__c>();
        //need to add team Ids to SFDC or have another soql query to pull them. Need team member query to pull AND for litmos_user_id and Team_id
        for(Id t : teams.keySet()) {
            req.setEndpoint(config.Litmos__API_End_Point__c + 'teams/' + teams.get(t).Litmos_Id__c  + '/admins?source=sourceapp&format=json');
            response = http.send(req);
            if(response.getStatusCode() == 200) {
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                for(Object o : results) {
                    Map<String,Object> obj = (Map<String,Object>)o;
                    members.add(new Litmos_Team_Member__c(
                    	Litmos_User_Id__c = String.valueOf(obj.get('Id')),
                        Litmos_Team__c = t
                    ));
                    litmosIds.add(String.valueOf(obj.get('Id')));
                }
            }
        }
        List<Litmos_Team_Member__c> updateMembers = [SELECT Id,Litmos_User_Id__c,Litmos_Team__c,Member_Type__c FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c IN :litmosIds];
        for(Litmos_Team_Member__c mem : members) {
            for(Litmos_Team_Member__c u : updateMembers) {
                if(u.Litmos_User_Id__c == mem.Litmos_User_Id__c && u.Litmos_Team__c == mem.Litmos_Team__c){
					u.Member_Type__c = 'Admin';
                }
            }
        }
        update updateMembers;
    }
}