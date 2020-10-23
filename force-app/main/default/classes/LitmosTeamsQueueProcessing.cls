public class LitmosTeamsQueueProcessing implements Queueable{
    private Map<Id, List<Object>> mapMembers;
    
    public LitmosTeamsQueueProcessing(Map<Id, List<Object>> members) {
        this.mapMembers = members;
    }
    public void execute(QueueableContext context) {
        //list of teams included
        List<Litmos_Team__c> teams = [SELECT Id,Litmos_Id__c FROM Litmos_Team__c WHERE Id IN : mapMembers.keySet()];
        List<Litmos_Team_Member__c> members = new List<Litmos_Team_Member__c>();
        Set<String> litmosIds = new Set<String>();
        for(Id memId : mapMembers.keySet()) {
            for(Object o : mapMembers.get(memId)) {
                Map<String, Object> newMap = (Map<String,Object>) o;
                members.add(new Litmos_Team_Member__c(
                	Litmos_Team__c = memId,
                    Litmos_User_Id__c = String.valueOf(newMap.get('Id'))
                ));
                litmosIds.add(String.valueOf(newMap.get('Id')));
            }
        }
        //users
        List<User> users = [SELECT Id, Litmos__LitmosUserId__c FROM User WHERE Litmos__LitmosUserId__c IN : litmosIds AND isActive = true AND Litmos__Litmos_Activated__c = true];
        List<Litmos_Team_Member__c> updates = new List<Litmos_Team_Member__c>();
        for(User u : users) {
            for(Litmos_Team_Member__c mem : members) {
                if(mem.Litmos_User_Id__c == u.Litmos__LitmosUserId__c) {
                    mem.Learner__c = u.Id;
                    updates.add(mem);
                }
            }
        }
        insert updates;
    }
}