@isTest
public class testMock implements HttpCalloutMock{
    public HTTPResponse respond(HttpRequest req) {
        System.assertEquals('GET',req.getMethod());
        System.assertEquals('https://api.litmos.com/v1.svc/', req.getEndpoint());
        System.assertEquals('ABCDEFG',req.getHeader('apikey'));
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-type','application/json');
        return res;
    }
}
