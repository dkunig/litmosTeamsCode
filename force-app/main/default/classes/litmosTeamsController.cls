public  class litmosTeamsController {
    @AuraEnabled(cacheable=true)
    public static List<Litmos_Team_Member__c> getAdmins(String recordID) {
        return [SELECT Id,Learner__r.Name,Litmos_User_Id__c,Learner__r.SmallPhotoUrl,Learner__r.Title,Learner__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c = :recordID AND Member_Type__c ='Admin' ORDER BY Learner__r.Name];
    }
    @AuraEnabled(cacheable=true)
    public static List<Litmos_Team_Member__c> getLeaders(String recordID) {
        return [SELECT Id,Learner__r.Name,Litmos_User_Id__c,Learner__r.SmallPhotoUrl,Learner__r.Title,Learner__c FROM Litmos_Team_Member__c WHERE Litmos_Team__c = :recordID AND Member_Type__c ='Leader' ORDER BY Learner__r.Name];
    }
}