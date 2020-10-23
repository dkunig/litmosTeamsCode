@isTest
public with sharing class litmosTeamsScheduleTEST {
    @isTest(SeeAllData=true)
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