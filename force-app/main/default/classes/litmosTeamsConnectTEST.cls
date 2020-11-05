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
            email='admin@adminuser.com',
            Username='admin@adminuser.com',
            alias='admin',
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
        users.add(u1);
        users.add(u2);
        insert users;
    }
    @isTest
    public static void testGetAllTeams() {
        System.debug('test get all teams');
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosTeamsJSON');
        mock.setStatusCode(200);
        mock.setHeader('content-type','application/json');
        
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        LitmosTeamsConnect.getAllTeams();
        Test.stopTest();
        List<Litmos_Team__c> teamsInserted = [SELECT Id FROM Litmos_Team__c];
        System.assertEquals(6,teamsInserted.size());
    }
    @isTest
    public static void testGetDescriptions() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosTeamDataFull');
        /*mock.setStatusCode(200);
        mock.setHeader(key, val)*/
        
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
        Integer numMems = [SELECT Count() FROM Litmos_Team_Member__c];
        System.assertEquals(2, numMems);
    }
}