@isTest
public class litmosTeamLeadAdminTEST {
	@testSetup
    static void testData() {
		Litmos__Configuration__c config = new Litmos__Configuration__c(
        	Litmos__Api_Key__c = '1234567',
            Litmos__Api_End_Point__c = 'https://api.litmos.com/v1.svc/',
            Litmos__Sync_Active__c = true,
            Litmos__Sync_Frequency__c = 'Every 1 Hour'
        );
        insert config;
        //user
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> users = new List<User>();
        User adminUser = new User(
            FirstName = 'Test Admin',
            LastName = 'Test Last',
            Litmos__OriginalId__c = 13488946,
            Litmos__LitmosUserId__c = 'ABCDE',
            Litmos__Litmos_Activated__c = true,
            ProfileId = standardUser.Id,
            isActive = true,
            email='team1@adminuser.com',
            Username='team1@adminuser.com',
            alias='team1',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User leadUser = new User(
            FirstName = 'Test Leader',
            LastName = 'Test Last',
            Litmos__OriginalId__c = 13488946,
            Litmos__LitmosUserId__c = 'FGHIJ',
            Litmos__Litmos_Activated__c = true,
            ProfileId = standardUser.Id,
            isActive = true,
            email='team1@leaduser.com',
            Username='team1@leaduser.com',
            alias='team1',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        users.add(adminUser);
        users.add(leadUser);
        insert users;
        //insert team and team members
        Litmos_Team__c team = new Litmos_Team__c(
        	Name = 'Test Team',
            Litmos_Id__c = 'TEAMTEST'
        );
        insert team;
        Litmos_Team_Member__c leader = new Litmos_Team_Member__c(
        	Litmos_Team__c = team.Id,
            Learner__c = leadUser.Id,
            Litmos_User_Id__c = leadUser.Litmos__LitmosUserId__c,
            Member_Type__c = 'Learner'
        );
        Litmos_Team_Member__c admin = new Litmos_Team_Member__c(
        	Litmos_Team__c = team.Id,
            Learner__c = adminUser.Id,
            Litmos_USer_Id__C = adminUser.Litmos__LitmosUserId__c,
            Member_Type__c = 'Learner'
        );
        insert leader;
        insert admin;
    }
    @isTest
    static void testAdmins() {
        //Litmos_Team__c team = [SELECT Id FROM Litmos_Team__c LIMIT 1];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosAdminMock2Users');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        litmosTeamLeadAdmin.getTeamAdmins([SELECT Id FROM Litmos_Team__c LIMIT 1].Id);
        Test.stopTest();
        //confirm only one admin exists
        System.assertEquals(1, [SELECT count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Admin']);
        //confirm error sync log
        System.assertEquals(1, [SELECT count() FROM Litmos_Sync_Logs__c WHERE Status_of_Sync__c = 'Error' AND Type__c = 'Team Member']);
    }
    @isTest
    static void testLeaders() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosLeaderMock2Users');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        litmosTeamLeadAdmin.getTeamLeaders([SELECT Id FROM Litmos_Team__c LIMIT 1].Id);
        Test.stopTest();
        //confirm only one leader exists
        System.assertEquals(1, [SELECT count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Leader']);
        //confirm error sync log
        System.assertEquals(1, [SELECT count() FROM Litmos_Sync_Logs__c WHERE Status_of_Sync__c = 'Error' AND Type__c = 'Team Member']);
    }
    @isTest
    static void testNOAdmins() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosAdminMockNOUsers');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        litmosTeamLeadAdmin.getTeamAdmins([SELECT Id FROM Litmos_Team__c LIMIT 1].Id);
        Test.stopTest();
        //confirm single sync log exists
        System.assertEquals(1, [SELECT count() FROM Litmos_Sync_Logs__c WHERE Status_of_Sync__c = 'Error' AND Type__c = 'Team Member']);
    }
    @isTest
    static void testNOLeaders() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosLeaderMockNOUsers');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        litmosTeamLeadAdmin.getTeamLeaders([SELECT Id FROM Litmos_Team__c LIMIT 1].Id);
        Test.stopTest();
        //confirm single sync log exists
        System.assertEquals(1, [SELECT count() FROM Litmos_Sync_Logs__c WHERE Status_of_Sync__c = 'Error' AND Type__c = 'Team Member']);
    }
}