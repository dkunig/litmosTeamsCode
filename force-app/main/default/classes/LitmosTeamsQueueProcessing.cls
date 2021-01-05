public class LitmosTeamsQueueProcessing implements Queueable{
    private Map<Id, List<Object>> mapMembers;
    
    public LitmosTeamsQueueProcessing(Map<Id, List<Object>> members) {
        this.mapMembers = members;
    }
    public void execute(QueueableContext context) {
        System.debug('size of member map: ' + this.mapMembers.size());
        List<Litmos_Team_Member__c> members = new List<Litmos_Team_Member__c>();
        Set<String> memberIds = new Set<String>();
      	for(Id memId : this.mapMembers.keySet()) {
            for(Object o : this.mapMembers.get(memId)) {
                Map<String, Object> newMap = (Map<String,Object>) o;
                members.add(new Litmos_Team_Member__c(
                    Litmos_Team__c = memId,
                    Litmos_User_Id__c = String.valueOf(newMap.get('Id'))
                ));
                memberIds.add(String.valueOf(newMap.get('Id')));
            }
        }
        
        Map<String,String> userMap = new Map<String,String>();
        for(User u : [SELECT Id,Litmos__LitmosUSerId__c FROM User WHERE Litmos__LitmosUserId__c IN : memberIds AND Litmos__Litmos_Activated__c = true]) {
            userMap.put(u.Litmos__LitmosUserId__c,u.Id);
        }
        System.debug(userMap);
        List<Litmos_Team_Member__c> updates = new List<Litmos_Team_Member__c>();
        for(Litmos_Team_Member__c mem: members) {
            mem.Learner__c = userMap.get(mem.Litmos_User_Id__c);
            updates.add(mem);
        }
        System.debug('updates size: ' + updates.size());
        Set<Id> teamSuccesses = new Set<Id>();
        Set<Id> teamErrors = new Set<Id>();
        List<String> errors = new List<String>();
        List<Database.SaveResult> saveResults = Database.insert(updates, false);
        System.debug('saveResults: ' + saveResults);
        for(Database.SaveResult res : saveResults) {
            if(res.isSuccess()) {
                teamSuccesses.add(res.getId());
            } else {
				errors.add('Generic error inserting new team members: ' + res.getErrors() + ' **** ' + res.getId());
            }
        }
        if(teamSuccesses.size() > 0) {
            SYstem.debug(teamSuccesses.size() + ' team members inserted');
            litmosSyncLogs.logTeamMemberSuccess([SELECT Id FROM Litmos_Team_Member__c WHERE Id IN : teamSuccesses]);
        }
        if(teamErrors.size() > 0) {
            System.debug(teamErrors.size() + ' errors inserting team members');
            litmosSyncLogs.logTeamMemberErrors(errors);
        }
    }
}