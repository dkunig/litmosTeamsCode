public class litmosTeamsUpdates {
    static final Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
    @future(callout=true)
    public static void logTeamUpdates() {
        //called from schedulable apex to update teams daily
        System.debug('Inside logTeamUpdates: ' + config);
        
        String startDate = System.now().addDays(-3).format('yyyy-MM-dd');
        String endpoint = config.Litmos__API_End_Point__c + 'org/teams?source=sourceapp&since=' + startDate + '&to=' + System.now().format('yyyy-MM-dd') + '&format=json';
        HttpResponse response = litmosTeamsConnectCallout.getLitmosExternalService(endpoint, config.Litmos__Api_Key__c);
        List<Litmos_Team__c> teams = new List<Litmos_Team__c>();
        Map<String,String> childrenIds = new Map<String, String>();
        if(response.getStatusCode() == 200 & response.getBody() != '[]') {
            List<Object> results = (List<Object>)(JSON.deserializeUntyped(response.getBody()));
            for(Object o : results) {
                Map<String,Object> myMap = (Map<String,Object>)o;
                teams.add(new Litmos_Team__c(
                	Name = String.valueOf(myMap.get('Name')),
                    Litmos_Id__c = String.valueOf(myMap.get('Id')),
                    Team_Code_for_Bulk_Import__c = String.valueOf(myMap.get('TeamCodeForBulkImport'))
                ));
                if(myMap.get('ParentTeamId') != '') {
                    childrenIds.put(String.valueOf(myMap.get('Id')), String.valueOf(myMap.get('ParentTeamId')));
                }
            }
        }
        System.debug('childrenIds: ' + childrenIds);
        //upsert and gather successes and errors
        //*********************FOR TESTING PURPOSES -- ADD Error-Inducing Team ******************** *//
        if(Test.isRunningTest()) {
            teams.add(new Litmos_Team__c());
        }
        System.debug('teams: ' + teams);
        if(teams.size() != 0) {
            Schema.SObjectField litmosId = Litmos_Team__c.Fields.Litmos_Id__c;
            List<Database.upsertResult> upsertResults = Database.upsert(teams, litmosId,false);
            List<Litmos_Team__c> successes = new List<Litmos_Team__c>();
            List<Litmos_Team__c> failures = new List<Litmos_Team__c>();
            Set<Id> successIds = new Set<Id>();
            Set<Id> failedIds = new Set<Id>();
            Map<String,List<Database.Error>> errors = new Map<String,List<Database.Error>>();
            for(Database.upsertResult r : upsertResults) {
                if(r.isSuccess()) {
                    successIds.add(r.getId());
                } else {
                    failedIds.add(r.getId());
                    errors.put(r.getId(),r.getErrors());
                }
            }
            //update parentIds
            List<Litmos_Team__c> parents = [SELECT Id, Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.values()];
            System.debug('parents: ' + parents);
            System.debug('children keyset: ' + childrenIds.keySet());
            List<Litmos_Team__c> children = [SELECT Id, Litmos_Id__c FROM Litmos_Team__c WHERE Litmos_Id__c IN : childrenIds.keySet()];
            SYstem.debug('children: ' + children);
            List<Litmos_Team__c> updates = new List<Litmos_Team__c>();
            for(Litmos_Team__c c : children) {
                for(Litmos_Team__c parent : parents) {
                    if(childrenIds.get(c.Litmos_Id__c) == parent.Litmos_Id__c) {
                        updates.add(new Litmos_Team__c(
                            Id = c.Id,
                            Litmos_Parent_Team__c = parent.Id
                        ));
                    }
                }
            }

            //upsert children
            upsertResults = Database.upsert(updates, false);
            for(Database.upsertResult r : upsertResults) {
                if(r.isSuccess()) {
                    successIds.add(r.getId());
                } else {
                    failedIds.add(r.getId());
                    errors.put(r.getId(),r.getErrors());
                }
            }
            if(successIds.size() > 0) {
                litmosSyncLogs.logTeamsSuccess([SELECT Id FROM Litmos_Team__c WHERE Id IN :successIds]);
            }
            if(errors.size() > 0) {
                litmosSyncLogs.logTeamsErrors([SELECT Id FROM Litmos_Team__c WHERE Id IN :failedIds], errors);
            }
        } else {
            System.debug('no updates at this time');
        }
        //litmosTeamMemberUpdates.litmosTeamMemberUpdates();

    }
}