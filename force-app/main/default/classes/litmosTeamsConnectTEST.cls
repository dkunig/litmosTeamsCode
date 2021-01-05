@isTest
public class litmosTeamsConnectTEST {
	@testSetup
    static void testData() {
        Litmos__Configuration__c config = new Litmos__Configuration__c(
        	Litmos__Api_Key__c = '1234567',
            Litmos__Api_End_Point__c = 'https://api.litmos.com/v1.svc/',
            Litmos__Sync_Active__c = true
        );
        insert config;
        //insert team with no description
        List<Litmos_Team__c> teams = Test.loadData(Litmos_Team__c.sObjectType, 'litmosTeamSampleData');
        
        //insert users for testing new members
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> users = new List<User>();
        User u1 = new User(
            FirstName = 'Test Member Updates',
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
        User u2 = new User(
        	FirstName = 'Test Member Updates',
            LastName = 'On Team',
            Litmos__OriginalId__c = 123456789,
            Litmos__LitmosUserId__c = 'FGHIJ',
            Litmos__Litmos_Activated__c = true,
            ProfileId = standardUser.Id,
            isActive=true,
            email='onteam@onteam.com',
            Username='onteam@onteam.com',
            alias='ontea',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
        User u3 = new User(
            FirstName = 'Test Admin and Leader',
            LastName = 'Test Last',
            Litmos__OriginalId__c = 13488946,
            Litmos__LitmosUserId__c = 'KLMNO',
            Litmos__Litmos_Activated__c = true,
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
        users.add(u1);
        users.add(u2);
        users.add(u3);
        insert users;
        Litmos_Team__c team = new Litmos_Team__c(
        	Name = 'Test Team',
            Litmos_Id__c = 'TEAMTEST'
        );
        insert team;
        Litmos_Team_Member__c member = new Litmos_Team_Member__c(
        	Litmos_Team__c = team.Id,
            Learner__c = u3.Id,
            Litmos_User_Id__c = u3.Litmos__LitmosUserId__c
        );
        insert member;
    }
    @isTest
    public static void testGetAllTeams() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosTeamsJSON');
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        LitmosTeamsConnect.getAllTeams();
        Test.stopTest();        
        //NOTE: 6 teams are in the static resource, but an additional team is created during testing in the actual test class for testing failures in insertion
        System.assertEquals(6,[SELECT count() FROM Litmos_Team__c WHERE Litmos_Id__c != 'TEAMTEST']);
    }
    @isTest
    public static void testGetDescriptions() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosTeamDataFull');
        
        Test.setMock(HttpCalloutMock.class, mock);
        //make sure no description exists prior to launching test:
        Litmos_Team__c noDesc = [SELECT Id,Description__c FROM Litmos_Team__c LIMIT 1];
        System.assertEquals(null, noDesc.Description__c);
        Test.startTest();
        LitmosTeamsConnect.updateNullDescriptions();
        Test.stopTest();
        //make sure description exists after launching test
        Litmos_Team__c description = [SELECT Id,Description__c FROM Litmos_Team__c LIMIT 1];
        System.assertEquals('Created a sample Team for Account',description.Description__c);
        //assert that both records are the same to confirm that the description was added to the correct record
        System.assert(noDesc.Id == description.Id);
    }
    @isTest
    public static void testTeamMembers() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_With_Team_Members');
        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        LitmosTeamsConnect.insertTeamMembers();
        Test.stopTest();
        System.assertEquals(3, [SELECT Count() FROM Litmos_Team_Member__c]);
    }
    @isTest
    public static void testTeamAdmins() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Admins_Mock');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        LitmosTeamsConnect.getTeamAdmins();
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Admin']);
    }
    @isTest
    public static void testTeamLeaders() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Admins_Mock');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        LitmosTeamsConnect.getTeamLeaders();
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Litmos_Team_Member__c WHERE Member_Type__c = 'Leader']);
    }
}