@isTest
public class litmosTeamsConnectTEST {
	@isTest(SeeAllData=true)
    static void testGetAllTeams() {
        //get endpoint and configs
        Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
        //use static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosTeamsJSON');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mock.setHeader('apikey', config.Litmos__Api_Key__c);
        
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        //call the method taht performs the callout
        //get endpoint
        
        HttpResponse res = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams?source=sourceapp&format=json',config.Litmos__Api_Key__c);
        System.assertEquals(200, res.getStatusCode());
        System.debug('response: ' + res.getBody());
        System.assertEquals('[{"Id": "ZppqOWTqgVM1","Name": "Accounts","TeamCodeForBulkImport": "1689704-Accounts","ParentTeamId": ""},' +
      						'{"Id": "Aweaaw20pEU1","Name": "Accounts","TeamCodeForBulkImport": "1724932-Accounts","ParentTeamId": ""},' +
                            '{"Id": "GXDX8tFDORk1","Name": "Customers","TeamCodeForBulkImport": "1084247-Customers","ParentTeamId": ""},' +
                            '{"Id": "2O3Bi2Ib4Sg1","Name": "Hoa\'s Team","TeamCodeForBulkImport": "1119145-HoasTeam","ParentTeamId": ""},' +
                            '{"Id": "yYv0ln5yeAw1","Name": "Dawn\'s Sub Team Test","TeamCodeForBulkImport": "1725150-DawnsSubTeamTest","ParentTeamId": "2O3Bi2Ib4Sg1"},' +
                            '{"Id": "lwxtC0S_JV81","Name": "Dawn\'s Sub-Sub Team","TeamCodeForBulkImport": "1725165-DawnsSub-SubTeam","ParentTeamId": "yYv0ln5yeAw1"}]', res.getBody());
        Test.startTest();
        LitmosTeamsConnect.getAllTeams();
        Test.stopTest();        
    }
    @isTest(SeeAllData=true)
    static void testDescriptionUpdates() {
        //get endpoint and configs
        Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
        //use static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosTeamDataFull');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mock.setHeader('apikey', config.Litmos__Api_Key__c);
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        //call the method taht performs the callout
        //get endpoint
        
        HttpResponse res = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/ZppqOWTqgVM1?source=sourceapp&format=json',config.Litmos__Api_Key__c);
        System.assertEquals(200, res.getStatusCode());
        System.debug('response: ' + res.getBody());
        System.assertEquals('{"Id": "ZppqOWTqgVM1","Name": "Accounts","Description": "Created a sample Team for Account","ParentTeamId": "","TeamCodeForBulkImport": "1689704-Accounts"}', res.getBody());
        Test.startTest();
        LitmosTeamsConnect.updateNullDescriptions();
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void testMemberInserts() {
		Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Members');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mock.setHeader('apikey', config.Litmos__Api_Key__c);
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        //call the method taht performs the callout
        //get endpoint
        
        HttpResponse res = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/yYv0ln5yeAw1/users?source=sourceapp&format=json',config.Litmos__Api_Key__c);
        System.assertEquals(200, res.getStatusCode());
        System.debug('response: ' + res.getBody());
        System.assertEquals('[{"Id": "PaD1GUsp8bHbPMpQLsL7PQ2","UserName": "arya.starkelearn@gmail.com","FirstName": "Arya","LastName": "Stark","Active": true,"Email": "arya.starkelearn@gmail.com","AccessLevel": null,"Brand": null},{"Id": "lGJTqiW7D3duNp8XlKLrtg2","UserName": "dawn.kunig@fluidigm.com.test","FirstName": "Dawn","LastName": "Kunig","Active": true,"Email": "dawn.kunig=fluidigm.com@example.com","AccessLevel": null,"Brand": null},{"Id": "YMflF6OT8dfR6yaCUqzrYQ2","UserName": "dmitry.bandura@fluidigm.com.test","FirstName": "Dmitry","LastName": "Bandura","Active": true,"Email": "dmitry.bandura=fluidigm.com@example.com","AccessLevel": null,"Brand": null}]', res.getBody());
        Test.startTest();
        LitmosTeamsConnect.insertTeamMembers();
        Test.stopTest();

    }
    @isTest(SeeAllData=true)
    static void testTeamAdmins() {
        Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Members');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mock.setHeader('apikey', config.Litmos__Api_Key__c);
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        //call the method taht performs the callout
        //get endpoint
        
        HttpResponse res = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/yYv0ln5yeAw1/admins?source=sourceapp&format=json',config.Litmos__Api_Key__c);
        System.assertEquals(200, res.getStatusCode());
        System.debug('response: ' + res.getBody());
        System.assertEquals('[{"Id": "PaD1GUsp8bHbPMpQLsL7PQ2","UserName": "arya.starkelearn@gmail.com","FirstName": "Arya","LastName": "Stark","Active": true,"Email": "arya.starkelearn@gmail.com","AccessLevel": null,"Brand": null},{"Id": "lGJTqiW7D3duNp8XlKLrtg2","UserName": "dawn.kunig@fluidigm.com.test","FirstName": "Dawn","LastName": "Kunig","Active": true,"Email": "dawn.kunig=fluidigm.com@example.com","AccessLevel": null,"Brand": null},{"Id": "YMflF6OT8dfR6yaCUqzrYQ2","UserName": "dmitry.bandura@fluidigm.com.test","FirstName": "Dmitry","LastName": "Bandura","Active": true,"Email": "dmitry.bandura=fluidigm.com@example.com","AccessLevel": null,"Brand": null}]', res.getBody());
        Test.startTest();
        LitmosTeamsConnect.getTeamAdmins();
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void testTeamLeaders() {
        Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c, Litmos__Api_End_Point__c FROM Litmos__Configuration__c WHERE isDeleted = false AND Litmos__Sync_Active__c = true LIMIT 1];
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Members');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mock.setHeader('apikey', config.Litmos__Api_Key__c);
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        
        //call the method taht performs the callout
        //get endpoint
        
        HttpResponse res = litmosTeamsConnectCallout.getLitmosExternalService(config.Litmos__API_End_Point__c + 'teams/yYv0ln5yeAw1/leaders?source=sourceapp&format=json',config.Litmos__Api_Key__c);
        System.assertEquals(200, res.getStatusCode());
        System.debug('response: ' + res.getBody());
        System.assertEquals('[{"Id": "PaD1GUsp8bHbPMpQLsL7PQ2","UserName": "arya.starkelearn@gmail.com","FirstName": "Arya","LastName": "Stark","Active": true,"Email": "arya.starkelearn@gmail.com","AccessLevel": null,"Brand": null},{"Id": "lGJTqiW7D3duNp8XlKLrtg2","UserName": "dawn.kunig@fluidigm.com.test","FirstName": "Dawn","LastName": "Kunig","Active": true,"Email": "dawn.kunig=fluidigm.com@example.com","AccessLevel": null,"Brand": null},{"Id": "YMflF6OT8dfR6yaCUqzrYQ2","UserName": "dmitry.bandura@fluidigm.com.test","FirstName": "Dmitry","LastName": "Bandura","Active": true,"Email": "dmitry.bandura=fluidigm.com@example.com","AccessLevel": null,"Brand": null}]', res.getBody());
        Test.startTest();
        LitmosTeamsConnect.getTeamLeaders();
        Test.stopTest();
    }
}