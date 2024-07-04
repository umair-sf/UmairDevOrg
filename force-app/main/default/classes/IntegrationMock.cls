@isTest
public class IntegrationMock implements HttpCalloutMock 
{
    public IntegrationMock()
    {
    }

    public HttpResponse respond(HttpRequest req)
    {
        String endPoint = req.getEndpoint() ;
        HttpResponse res = new HttpResponse();

        if(endPoint.endsWith('auth/products/add'))
        {
            res.setBody('{"id":101, "title":"BMW Pencil", "description":"Test", "price":10, "category":"SmatPhone"}');
            res.setStatusCode(200);
        }
        else if(endPoint.endsWith('auth/products/'))
        {
            res.setBody('{"id":101, "title":"BMW Pencil", "description":"Test", "price":10, "category":"SmatPhone"}');
            res.setStatusCode(200);
        }
        else if(endPoint.endsWith('auth/login'))
        {
            res.setBody('{"id":1,"username":"xxx","email":"test@test.com","firstName":"Kala","lastName":"ABC","gender":"male","image":"1","token":"xyz"}'); 
            res.setStatusCode(200);
        }
        else if(endPoint.startsWith('https://dummyjson.com/products/')) 
        {
            res.setBody('{"id":1,"title":"iPhone 9","description":"An apple mobile which is nothing like apple","price":549,"discountPercentage":12.96,"rating":4.69,"stock":94,"brand":"Apple","category":"smartphones"'); 
            res.setStatusCode(200);
        }
        else if(endPoint.endsWith('callout:MohsinOrg/services/apexrest/leads')) 
        {
            res.setBody('{"leadId":"25"}'); 
            res.setStatusCode(200);
        }
        else if(endPoint.endsWith('/events')) 
        {
            res.setBody('{"id":"125","htmlLink":"xyz"}'); 
            res.setStatusCode(200);
        }
        return res;
    }
}