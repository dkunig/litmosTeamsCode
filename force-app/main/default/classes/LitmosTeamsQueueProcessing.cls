public class LitmosTeamsQueueProcessing implements Queueable{
    private Map<Id, List<Object>> mapMembers;
    
    public LitmosTeamsQueueProcessing(Map<Id, List<Object>> members) {
        this.mapMembers = members;
    }
    public void execute(QueueableContext context) {
        List<Litmos_Team__c> teams = [SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Id IN : mapMembers.keySet()];
        Map<String,Litmos_Team_Member__c> members = new Map<String,Litmos_Team_Member__c>();
        for(Id memId : mapMembers.keySet()) {
            for(Object o : mapMembers.get(memId)) {
                Map<String, Object> newMap = (Map<String,Object>) o;
                members.put(String.valueOf(newMap.get('Id')),new Litmos_Team_Member__c(
                	Litmos_Team__c = memId,
                    Litmos_User_Id__c = String.valueOf(newMap.get('Id'))
                ));
            }
        }
        List<User> users = [SELECT Id, Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN : members.keySet() AND isActive = true AND Litmos__Litmos_Activated__c = true];
        List<Litmos_Team_Member__c> updates = new List<Litmos_Team_Member__c>();
        for(User u : users) {
            for(Litmos_Team_Member__c mem : members.values()) {
                if(mem.Litmos_User_Id__c == u.Litmos__LitmosUserId__c) {
                    mem.Learner__c = u.Id;
                    updates.add(mem);
                }
            }
        }
        Set<Id> teamSuccesses = new Set<Id>();
        Set<Id> teamErrors = new Set<Id>();
        Map<String,List<Database.Error>> errors = new Map<String,List<Database.Error>>();
        List<Database.SaveResult> saveResults = Database.insert(updates, false);
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