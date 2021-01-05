public class litmosConnection {
	public static HttpResponse getLitmosExternalService(String endpoint, String apikey) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('content-type', 'application/json');
        req.setHeader('apikey', apikey);
        Http h = new Http();
        HttpResponse response = h.send(req);
        return response;
    }
}