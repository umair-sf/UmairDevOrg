public with sharing class FeedbackTriggerHandler
{
    public static void feedbackRollupToJobApp(List<Feedback__c> feedbacks)
    {
        Set<Id> interviewIds = new Set<Id>();
        Set<Id> jobAppIds = new Set<Id>();
        List<Job_Application__c> jobAppToUpdate = new List<Job_Application__c>();

        for(Feedback__c feedback : feedbacks)
        {
        	interviewIds.add(feedback.Interview__c);
        }
        System.debug(interviewIds);
        if(interviewIds.size()==0) return;

        for(Interview__c interview : [SELECT Id, Job_Applications__c FROM Interview__c WHERE Id IN :interviewIds])
        {
        	jobAppIds.add(interview.Job_Applications__c);
        }

        for(AggregateResult ar : [SELECT COUNT(Id)totalFeedbacks, Interview__r.Job_Applications__c FROM Feedback__c WHERE  Interview__r.Job_Applications__c IN :jobAppIds GROUP BY Interview__r.Job_Applications__c])
        {
        	System.debug(ar);
        	jobAppToUpdate.add(new Job_Application__c( Id=(Id)ar.get('Job_Applications__c'), Total_Feedbacks__c=(Integer)ar.get('totalFeedbacks') ));
        }
        if(jobAppToUpdate.size()>0) update jobAppToUpdate;
    }
}