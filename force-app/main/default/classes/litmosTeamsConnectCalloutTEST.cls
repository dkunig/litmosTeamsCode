@isTest
public with sharing class litmosTeamsConnectCalloutTEST{
    @isTest
    public static void litmosTeamsConnectCalloutTEST() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.litmos.com/v1.svc/');
        req.setMethod('GET');
        req.setHeader('apikey','ABCDEFG');

        Test.setMock(HttpCalloutMock.class, new testMock());
        HttpResponse res = litmosTeamsConnectCallout.getLitmosExternalService('https://api.litmos.com/v1.svc/', 'ABCDEFG');
        System.assert(res.getHeader('Content-type') == 'application/json');
        System.assertEquals(200, res.getStatusCode());

    }
}
