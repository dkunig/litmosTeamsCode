@isTest
public with sharing class litmosTeamsScheduleTEST {
    @TestSetup
    static void setupData(){
        Litmos__Configuration__c config = new Litmos__Configuration__c(
            Litmos__Api_Key__c = 'FAKEKEY',
            Litmos__Api_End_Point__c = 'https://api.litmos.com/v1.svc',
            Litmos__Sync_Active__c = true,
            Litmos__Sync_Frequency__c = 'Every 1 hour'
        );
        insert config;
    }
    @isTest    
    public static void litmosTeamsScheduleTEST() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('litmosTeamsJSON');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        
        //set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('litmosTeamsScheduleTEST',CRON_EXP,new litmosTeamsSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =:jobId];

        //verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00',String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}