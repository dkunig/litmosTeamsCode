public without sharing class litmosTeamMemberUpdates {
    
    private static final Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
    @future(callout=true)
    public static void litmosTeamMemberUpdates() {
        System.debug('inside team member updates');
        String startDate = System.now().addDays(-4).format('yyyy-MM-dd');
        String endDate = System.now().addDays(1).format('yyyy-MM-dd');
        String endpoint = config.Litmos__API_End_Point__c + 'org/teams/users?source=sourceapp&since=' + startDate + '&to=' + endDate + '&format=json';
        HttpResponse response = litmosTeamsConnectCallout.getLitmosExternalService(endpoint, config.Litmos__Api_Key__c);
        System.debug('response status: ' + response.getStatus());
        if(response.getStatusCode() == 200 & response.getBody() != '[]') {
            System.debug('response: ' + response.getBody());
            if(!Test.isRunningTest()) processCalloutResponse((List<Object>)JSON.deserializeUntyped(response.getBody()));     
        }
    }
        	
    public static void processCalloutResponse(List<Object> results) {
        //System.debug('inside processCalloutResponse');
        Map<Decimal,Object> myMap = new Map<Decimal,Object>();
        Set<String> teamIds = new Set<String>();
        for(Object o : results) {
            Map<String,Object> itsAMap = (Map<String,Object>)o;
            myMap.put((Decimal)itsAMap.get('OriginalUserId'), o);
            teamIds.add(String.valueOf(itsAMap.get('TeamId')));
        }
        
        System.debug('teamIds: ' + teamIds);
        System.debug('map: ' + myMap.isEmpty());
        System.debug('map details: ' + myMap);
        if(!myMap.isEmpty()) {
            List<Litmos_Team_Member__c> members = new List<Litmos_Team_Member__c>();
            List<User> users = [SELECT Id,Litmos__OriginalId__c,Litmos__User_Id__c FROM User WHERE Litmos__OriginalId__c IN :myMap.keySet()];
            System.debug('users: ' + users);
            Map<String,User> userMap = new Map<String,User>();
            for(User u : users) {
                userMap.put(String.valueOf(u.Litmos__OriginalId__c), u);
            }
            System.debug('userMap: ' + userMap);
            List<Litmos_Team__c> teams = [SELECT Id,Name,Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN :teamIds];
            System.debug('teams: ' + teams);
            Set<Id> userIds = new Set<Id>();
            for(Object o : myMap.values()) {
                Map<String,Object> obj = (Map<String,Object>)o;
                SYstem.debug('object: ' + obj);
                for(Litmos_Team__c t : teams) {
                    User u = userMap.get(String.valueOf(obj.get('OriginalUserId')));
                    System.debug('user: ' + u);
                    if(u == null) {
                        //log errors -- need litmos original id
                        litmosSyncLogs.logTeamMemberErrors('No user with matching litmos original id: ' + obj.get('OriginalUserId'), t.Id);
                    } else {
                        if(t.Litmos_Id__c == obj.get('TeamId')) {
                            members.add(new Litmos_Team_Member__c(
                                Litmos_Team__c = t.Id,
                                Learner__c = u.Id,
                                Litmos_User_Id__c = u.Litmos__User_Id__c,
                                Member_Type__c = obj.get('IsTeamLeader') == true ? 'Leader' : obj.get('IsTeamAdmin') == true ? 'Admin' : 'Learner'
                            ));
                            userIds.add(u.Id);
                    	}
                    }
                }
            }
            // existing team members: add Id if a match
            List<Litmos_Team_Member__c> checks = [SELECT Id,Litmos_Team__c,Learner__c FROM Litmos_Team_Member__c WHERE Litmos_Team__r.Litmos_Id__c='MyTestClassTeam' AND Learner__c IN :userIds];
            System.debug('checks: ' + checks);
            for(Litmos_Team_Member__c member : members) {
                System.debug('inside member check');
                for(Litmos_Team_Member__c e : checks) {                   
                    if(e.Litmos_Team__c == member.Litmos_Team__c & e.Learner__c == member.Learner__c) {
                        member.Id = e.Id;
                    }
                }
            }
            //upsert result
            Map<String,List<Database.Error>> errors = new Map<String,List<Database.Error>>();
            Set<Id> successIds = new Set<Id>();
            Set<Id> failedIds = new Set<Id>();
            List<Database.UpsertResult> upsertResults = Database.upsert(members);
            for(Database.UpsertResult r : upsertResults) {
                if(r.isSuccess()) {
                    successIds.add(r.getId());
                } else {
                    failedIds.add(r.getId());
                    errors.put(r.getId(),r.getErrors());
                }
            }
            if(successIds.size() > 0) {
                litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN :successIds]);
            }
            if(failedIds.size() > 0) {
                litmosSyncLogs.logTeamMemberErrors([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN :failedIds], errors);
            }
        
        }
    }
}