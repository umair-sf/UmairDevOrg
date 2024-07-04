@isTest
private class LeadTriggerHandlerTest 
{
    static testMethod void testMethod1()
    {
        Test.startTest();
        	TestUtil.createLead('Test', 'Test', 'Web', 'HealthCare', 10000, true);
        	Test.setMock(HttpCalloutMock.class, new IntegrationMock() );
        Test.stopTest();
    }
}