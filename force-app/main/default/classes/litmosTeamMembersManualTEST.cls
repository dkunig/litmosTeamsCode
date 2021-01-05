@isTest
public class litmosTeamMembersManualTEST {
	@testSetup
    static void testData() {
        Litmos__Configuration__c config = new Litmos__Configuration__c(
        	Litmos__Api_Key__c = '1234567',
            Litmos__Api_End_Point__c = 'https://api.litmos.com/v1.svc/',
            Litmos__Sync_Active__c = true,
            Litmos__Sync_Frequency__c = 'Every 1 Hour'
        );
        insert config;
        //insert users
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> users = new List<User>();
        User u1 = new User(
            FirstName = 'Test Member Updates',
            LastName = 'Test Last',
            Litmos__OriginalId__c = 13488946,
            Litmos__User_Id__c = 'ABCDE',
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
            Litmos__User_Id__c = 'FGHIJ',
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
        Litmos_Team__c t = new Litmos_Team__c(
        	Name = 'Test Team',
            Litmos_Id__c = 'MyTestClassTeam'
        );
        insert t;
        Litmos_Team_Member__c testMember = new Litmos_Team_Member__c(
        	Learner__c = u2.Id,
            Member_Type__c = 'Learner',
            Litmos_Team__c = t.Id
        );
        insert testMember;
    }
    static void testUpdateTeamMembers() {
		
    }
}