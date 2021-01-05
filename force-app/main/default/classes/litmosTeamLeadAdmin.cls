//Designed to be reused for loading team leads and admins when the teamId is known (not designed for looping)
public class litmosTeamLeadAdmin {
	static final Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
    @future(callout=true)
    public static void getTeamAdmins(String teamId) {
        String litmosId = [SELECT Litmos_Id__c FROM Litmos_Team__c WHERE Id =: teamId LIMIT 1].Litmos_Id__c;
        HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + litmosId + '/admins?source=source-app&format=json', config.Litmos__API_Key__c);
        Set<String> litmosUserIds = new Set<String>();
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> obj = (Map<String,Object>) o;
                litmosUserIds.add(String.valueOf(obj.get('Id')));
            }
        }
        Map<String,String> errors = new Map<String,String>();
        Set<String> idsChecked = new Set<String>();
        List<Litmos_Team_Member__c> members = [SELECT Id,Member_Type__c,Litmos_User_Id__c FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c IN :litmosUserIds AND Litmos_Team__c = :teamId];
        if(members.size() > 0) {
            for(Litmos_Team_Member__c m : members){
                m.Member_Type__c = 'Admin';
                idsChecked.add(m.Litmos_User_Id__c);
            }
        } else {
            System.debug('no team members to assign leader status');
            List<String> ids = new List<String>();
            ids.addAll(litmosUserIds);
            errors.put(teamId,'No existing team members have the correct litmosUserIds to assign admin status: ' + String.join(ids,', '));
        }
        //make list of ids not found in the event that at least one member exists; will add error if a member doesn't exist as a team member in SFDC
        if(!idsChecked.containsAll(litmosUserIds)) {
            for(String s : litmosUserIds) {
                if(!idsChecked.contains(s)) {
                    errors.put(teamId, 'No existing team member exists with litmos user Id: ' + s);
                }
            }
        }
        List<Database.SaveResult> saveResults = Database.update(members);
        Set<Id> successes = new Set<Id>();
        
        for(Database.SaveResult sr : saveResults) {
            if(sr.isSuccess()) {
                successes.add(sr.getId());
            } else {
                errors.put(teamId, 'Error updating admin');
            }
        }
        if(successes.size() > 0) {
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN : successes]);
        }
        if(errors.size() > 0) {
            litmosSyncLogs.logTeamMemberErrors(errors);
        }
        if(!test.isRunningTest()) {
            getTeamLeaders(teamId);
        }
    }
    
    public static void getTeamLeaders(String teamId) {
        String litmosId = [SELECT Litmos_Id__c FROM Litmos_Team__c WHERE Id =: teamId LIMIT 1].Litmos_Id__c;
        HttpResponse response = litmosConnection.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/' + litmosId + '/leaders?source=source-app&format=json', config.Litmos__API_Key__c);
        Set<String> litmosUserIds = new Set<String>();
        if(response.getStatusCode() == 200) {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object o : results) {
                Map<String,Object> obj = (Map<String,Object>) o;
                litmosUserIds.add(String.valueOf(obj.get('Id')));
            }
        }
        Map<String,String> errors = new Map<String,String>();
        List<Litmos_Team_Member__c> members = [SELECT Id,Member_Type__c,Litmos_User_Id__c FROM Litmos_Team_Member__c WHERE Litmos_User_Id__c IN :litmosUserIds AND Litmos_Team__c = :teamId];
        Set<String> idsChecked = new Set<String>();
        if(members.size() > 0) {
            for(Litmos_Team_Member__c m : members){
                m.Member_Type__c = 'Leader';
                idsChecked.add(m.Litmos_User_Id__c);
            }
        } else {
            System.debug('no team members to assign leader status');
            List<String> ids = new List<String>();
            ids.addAll(litmosUserIds);
            errors.put(teamId,'No existing team members have the correct litmosUserIds to assign leader status: ' + String.join(ids,', '));
        }
        //make list of ids not found in the event that at least one member exists; will add error if a member doesn't exist as a team member in SFDC
        if(!idsChecked.containsAll(litmosUserIds)) {
            for(String s : litmosUserIds) {
                if(!idsChecked.contains(s)) {
                    errors.put(teamId, 'No existing team member exists with litmos user Id: ' + s);
                }
            }
        }
        List<Database.SaveResult> saveResults = Database.update(members);
        Set<Id> successes = new Set<Id>();
        
        for(Database.SaveResult sr : saveResults) {
            if(sr.isSuccess()) {
                successes.add(sr.getId());
            } else {
                errors.put(teamId, 'Error updating leader');
            }
        }
        if(successes.size() > 0) {
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN : successes]);
        }
        if(errors.size() > 0) {
            litmosSyncLogs.logTeamMemberErrors(errors);
        }
        
    }
}