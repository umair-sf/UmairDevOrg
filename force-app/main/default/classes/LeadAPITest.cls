@isTest
private class LeadAPITest {
    static testMethod void testMethod1()
    {
    	Lead ld = TestUtil.createLead('Tester', 'TernEdge', 'Web', 'Test', 50000, true);
    	ld.Bilal_Org_Id__c = ld.Id;
    	update ld;

		RestRequest req = new RestRequest();
		RestContext.request = req;

		RestContext.response = new RestResponse();
		req.httpMethod = 'POST';
		req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'leads';
		req.requestBody = Blob.valueOf('{"leadId":"","leadName":"Test","leadCompany":"TernEdge","leadSource":"Web","email":"test@test.com"}');
		LeadAPI.handleLeadInsert();

		req.requestBody = Blob.valueOf('{"leadId":"","leadName":"Test","leadCompany":"","leadSource":"Web","email":"test@test.com"}');
		LeadAPI.handleLeadInsert();


		req.httpMethod = 'PUT';
		req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'leads';
		req.requestBody = Blob.valueOf('{"leadId":"'+ld.Id+'","leadName":"Test","leadCompany":"TernEdge","leadSource":"Web","email":"test@test.com"}');
		LeadAPI.handleLeadUpdate();

		req.requestBody = Blob.valueOf('{"leadId":"'+ld.Id+'","leadName":"Test","leadCompany":"","leadSource":"Web","email":"test@test.com"}');
		LeadAPI.handleLeadUpdate();
    }
}