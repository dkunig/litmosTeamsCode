@isTest
public class litmosTeamMemberUpdatesTEST {
	@testSetup
    public static void testSetup() {
         Litmos__Configuration__c config = new Litmos__Configuration__c(
        	Litmos__Api_Key__c = '1234567',
            Litmos__Api_End_Point__c = 'https://api.litmos.com/v1.svc/',
            Litmos__Sync_Active__c = true
        );
        insert config;
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
        System.debug('test member: ' + testMember);
    }
    @isTest
    public static void testTeamMemberUpdates() {
    	System.debug('testing member method now');
        StaticResource sr = [SELECT Id,Body FROM StaticResource WHERE Name = 'Litmos_Team_Member_Updates' LIMIT 1];
        
        String content = sr.Body.toString();
        List<Object> results = (List<Object>)JSON.deserializeUntyped(content);
        
        Test.startTest();
        litmosTeamMemberUpdates.processCalloutResponse(results);
        Test.stopTest();
        List<User> users = [SELECT Id FROM User WHERE FirstName = 'Test Member Updates'];
        System.debug('users: ' + users);
        List<Litmos_Team__c> t = [SELECT Id FROM Litmos_Team__c WHERE Name = 'Test Team'];
        System.debug('team: ' + t);
        List<Litmos_Team_Member__c> member = [SELECT Id,Member_Type__c,Learner__c,Learner__r.Name FROM Litmos_Team_Member__c WHERE Learner__c IN :users AND Litmos_Team__c IN :t];
        System.assertEquals(2, member.size());
        
    }
}