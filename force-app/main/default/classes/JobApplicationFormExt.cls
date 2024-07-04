public without sharing class JobApplicationFormExt
{
	public Job_Application__c jobApp {get; set;}
    public jobApplicationFormExt(ApexPages.StandardController sc)
    {
        jobApp = (Job_Application__c)sc.getRecord();
    }
    public void validator()
    {
    	if(jobApp.Experience__c < 0)
    	{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Experience must be a posiitive number!'));
    	}
    	if(jobApp.Application_Date__c < System.today())
    	{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Application Date cannot be in Past.'));
    	}
    }

    public void save()
    {
        //insert new Job_Application__c(Name=jobApp.Name, Experience__c=jobApp.Experience__c, Resume__c=jobApp.Resume__c, Application_Date__c=jobApp.Application_Date__c);
        insert jobApp;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record has been inserted successfully'));
    }
}