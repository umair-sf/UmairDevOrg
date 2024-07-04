@isTest
private class JobApplicationFormExtTest
{
    static testMethod void testMethod1()
    {
    	Job_Application__c ja = new Job_Application__c(Name='Test', Application_Date__c = Date.today(), Experience__c=4);
    	insert ja;
        JobApplicationFormExt cont =new JobApplicationFormExt(new ApexPages.StandardController(ja));
        ja.Application_Date__c = Date.today()-1;
        ja.Experience__c = -1;
        cont.Validator();
        cont.save();
    }
}