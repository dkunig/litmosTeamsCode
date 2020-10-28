@isTest
public class litmosTeamMemberScheduleTEST {
    @testSetup
    public static void setupData() {
        Litmos__Configuration__c config = new Litmos__Configuration__c(
        	Litmos__Api_Key__c = '1234567',
            Litmos__Api_End_Point__c = 'https://api.litmos.com/v1.svc/',
            Litmos__Sync_Active__c = true
        );
        insert config;        
    }
    @isTest
    public static void litmosTeamMemberScheduleTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Litmos_Team_Member_Updates');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Litmos__Configuration__c config = [SELECT Litmos__Api_Key__c FROM Litmos__Configuration__c LIMIT 1];
        //mock.setHeader('apikey', config.Litmos__API_Key__c);
        
        
        Test.startTest();
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('litmosTeamMemberScheduleTEST',CRON_EXP,new litmosTeamMembersSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =:jobId];
		System.debug('cron trigger: ' + ct);
        //verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00',String.valueOf(ct.NextFireTime));
        System.debug('after cron check');
        Test.stopTest();  
    }
}