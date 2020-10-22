@isTest
public class litmosTeamsControllerTEST {
    @isTest
    static void testGetAdmins() {
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User admin = new User(
            FirstName = 'Admin',
            LastName = 'AdminUser',
            ProfileId = standardUser.Id,
            isActive = true,
            email='admin@adminuser.com',
            Username='admin@adminuser.com',
            alias='admin',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        Litmos_Team__c team = new Litmos_Team__c(
            Name='Test Team',
            Litmos_Id__c='ABCDE'
        );
        insert team;
        insert admin;
        Litmos_Team_Member__c member = new Litmos_Team_Member__c(
            Learner__c = admin.Id,
            Litmos_Team__c = team.Id,
            Member_Type__c = 'Admin',
            Litmos_User_Id__c = 'ADMINUSER1'
        );
        insert member;

        Test.startTest();
        List<Litmos_Team_Member__c> admins = litmosTeamsController.getAdmins(team.Id);
        Test.stopTest();
        System.assertEquals(1, admins.size());
    }
    @isTest
    static void testGetLeaders() {
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User leader = new User(
            FirstName = 'Leader',
            LastName = 'LeadUser',
            ProfileId = standardUser.Id,
            isActive = true,
            email='lead@adminuser.com',
            Username='lead@adminuser.com',
            alias='leadr',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        Litmos_Team__c team = new Litmos_Team__c(
            Name='Test Team',
            Litmos_Id__c='ABCDE'
        );
        insert team;
        insert leader;
        Litmos_Team_Member__c member = new Litmos_Team_Member__c(
            Learner__c = leader.Id,
            Litmos_Team__c = team.Id,
            Member_Type__c = 'Admin',
            Litmos_User_Id__c = 'ADMINUSER1'
        );
        insert member;

        Test.startTest();
        List<Litmos_Team_Member__c> leaders = litmosTeamsController.getLeaders(team.Id);
        Test.stopTest();
        System.assertEquals(1, leaders.size());
    }
}
