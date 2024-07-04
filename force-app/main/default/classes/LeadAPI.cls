@RestResource(urlMapping='/leads')
global with sharing class LeadAPI 
{
    // baseURL/services/apexrest/leads

    @HttpPost
    global static void handleLeadInsert() 
    {
        String reqBody = RestContext.request.requestBody.toString();

        LeadRequest lreq = (LeadRequest)JSON.deserialize(reqBody, LeadRequest.class);

        LeadResponse ldRes = new LeadResponse();

        if(String.isBlank(lreq.leadCompany) || String.isBlank(lreq.leadName))
        {
            ldRes.errormessage = 'Please enter Lead Company and Lead Name';
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(ldRes));
            return ;
        }

        Lead ld = new Lead();
        ld.LastName = lreq.leadName ;
        ld.Company = lreq.leadCompany ;
        ld.LeadSource = lreq.leadSource ;
        ld.Email = lreq.email ;
        ld.Bilal_org_Id__c = lreq.leadId ;

        insert ld ;

        ldRes.leadId = ld.Id ;
        ldRes.errorMessage = 'Lead Created Successfully';
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(ldRes));
    }

    @HttpPut
    global static void handleLeadUpdate() 
    {
        String reqBody = RestContext.request.requestBody.toString();

        LeadRequest ldUpdateReq = (LeadRequest)JSON.deserialize(reqBody, LeadRequest.class);

        LeadResponse ldRes = new LeadResponse();

        if(String.isBlank(ldUpdateReq.leadId) || String.isBlank(ldUpdateReq.leadName) || String.isBlank(ldUpdateReq.leadCompany))
        {
            ldRes.errormessage = 'LeadId, leadName and leadCompany is Required';
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(ldRes));
            return ;
        }
        
        List<Lead> leads = [SELECT Id, LastName, Company, LeadSource, Email FROM Lead WHERE Bilal_Org_Id__c =:ldUpdateReq.leadId];
        for(Lead ld : leads)
        {
            Lead updatedld = new Lead();
            updatedld.Id = ld.Id ;
            updatedld.LastName = ldUpdateReq.leadName ;
            updatedld.Company = ldUpdateReq.leadCompany ;
            updatedld.LeadSource = ldUpdateReq.leadSource ;
            updatedld.Email = ldUpdateReq.email ;
        }
        

        update leads ;
        
        ldRes.errormessage = 'Lead updated successfully';
        String resBody = JSON.serializePretty(ldRes) ;
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(ldRes));
    }

    public class LeadRequest
    {
        public String leadId;
        public String leadName;
        public String leadCompany;
        public String leadSource;
        public String email;      
        
    }

    public class LeadResponse
    {
        public String leadId;
        public String errorMessage;
    }
}