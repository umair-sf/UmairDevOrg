@isTest
private class InterviewTriggerHandlerTest
{
    static testMethod void testMethod1()
    {
		Job_Application__c ja = new Job_Application__c(Name='Salesforce Admin', Application_Date__c = Date.today());
    	insert ja;
    	Interview__c inter = new Interview__c(Name = 'Test Interview', Interview_Date__c = Date.today(),
    											Interviewer__c = Userinfo.getUserId(),Job_Applications__c = ja.Id,
    											Interview_Status__c = 'Scheduled');
    	insert inter;
    	Interview__c inter2 = new Interview__c(Name = 'Test Interview', Interview_Date__c = Date.today(),
    											Interviewer__c = Userinfo.getUserId(),Job_Applications__c = ja.Id,
    											Interview_Status__c = 'Pending');
    	try{
    		insert inter2;
    	}
    	catch(Exception ex)
    	{

    	}
    	try{
    		delete inter;
    	}
    	catch(Exception ex)
    	{

    	}

    	inter.Interview_Rating__c = 5;
    	inter.Interview_Status__c = 'Completed';
    	update inter;

    	inter.Interview_Status__c = 'Pending';
    	update inter;

		Feedback__c feed = new Feedback__c(Name = 'Test Feedback', Feedback_Date__c = Date.today(), Feedback_Giver__c = Userinfo.getUserId(),
											Interview__c = inter.Id);
        insert feed;
        delete inter;
    	
    }
}