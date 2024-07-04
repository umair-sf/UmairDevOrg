public with sharing class InterviewTriggerHandler
{
    public static void userValidation(List<Interview__c> interviews)
    {
    	Set<Id> scheduledUsers = new Set<Id>();

        for(Interview__c interview : [SELECT Id, Interviewer__c,Interview_Status__c FROM Interview__c WHERE Interview_Status__c='Scheduled'])
        {
        	if(interview.Interview_Status__c == 'Scheduled')
        	{
        		scheduledUsers.add(interview.Interviewer__c);
        	}
        }
        if(scheduledUsers.size()==0) return;

        for(Interview__c interview : interviews)
        {
        	if(scheduledUsers.contains(interview.Interviewer__c))
        	{
        		interview.addError('The selected user is already Scheduled in another interview');
        	}
        }
    }

    public static void deleteRelatedFeedbacks(List<Interview__c> interviews)
    {
        Set<Id> interviewIds = new Set<Id>();
        for(Interview__c interview : interviews)
        {
            if(Interview.Interview_Status__c=='Scheduled')
            {
                interview.addError('Scheduled interviews cant be delete');
            }
            else
            {
                interviewIds.add(interview.Id);
            }
        }
        if(interviewIds.size()==0) return;

        List<Feedback__c> feedbacksToDelete = [SELECT Id FROM Feedback__c WHERE Interview__c IN :interviewIds];
        if(feedbacksToDelete.size()>0) Delete feedbacksToDelete;
    }

    public static void rollupInterviewsOnJobApplication(List<Interview__c> interviews)
    {
    	Map<Id, Integer> jobAppIdToScheduledInterviews = new Map<Id, Integer>();
    	Map<Id, Integer> jobAppIdToCompletedInterviews = new Map<Id, Integer>();
    	Map<Id, Integer> jobAppIdToPendingInterviews = new Map<Id, Integer>();
    	Set<Id> jobAppIds = new Set<Id>();
    	List<Job_Application__c> jobAppToUpdate = new List<Job_Application__c>();

    	for(Interview__c interview : interviews)
    	{
            if(String.isNotBlank(interview.Job_Applications__c))
            {
                jobAppIds.add(interview.Job_Applications__c);
            }
    	}
    	if(jobAppIds.size()==0) return;

    	for(AggregateResult ar : [SELECT COUNT(Id)allScheduledInterviews, Job_Applications__c FROM Interview__c
    							  WHERE Interview_Status__c='Scheduled' AND Job_Applications__c IN :jobAppIds
    							  GROUP BY Job_Applications__c])
    	{
    		jobAppIdToScheduledInterviews.put( (Id)ar.get('Job_Applications__c'), (Integer)ar.get('allScheduledInterviews') );
    	}

    	for(AggregateResult ar : [SELECT COUNT(Id)allCompletedInterviews, Job_Applications__c FROM Interview__c
                                  WHERE Interview_Status__c='Completed' AND Job_Applications__c IN :jobAppIds
    							  GROUP BY Job_Applications__c])
    	{
    		jobAppIdToCompletedInterviews.put( (Id)ar.get('Job_Applications__c'), (Integer)ar.get('allCompletedInterviews') );
    	}

    	for(AggregateResult ar : [SELECT COUNT(Id)allPendingInterviews, Job_Applications__c FROM Interview__c
    							  WHERE Interview_Status__c='Pending' AND Job_Applications__c IN :jobAppIds
    							  GROUP BY Job_Applications__c])
    	{
    		jobAppIdToPendingInterviews.put( (Id)ar.get('Job_Applications__c'), (Integer)ar.get('allPendingInterviews') );
    	}

    	for(Id jobAppId : jobAppIds)
    	{
    		jobAppToUpdate.add( new Job_Application__c(Id=jobAppId, Pending_Interviews__c=(jobAppIdToPendingInterviews.containsKey(jobAppId)? jobAppIdToPendingInterviews.get(jobAppId):0),
    													Scheduled_Interviews__c=(jobAppIdToScheduledInterviews.containsKey(jobAppId)? jobAppIdToScheduledInterviews.get(jobAppId):0),
    													Completed_Interviews__c=(jobAppIdToCompletedInterviews.containsKey(jobAppId)? jobAppIdToCompletedInterviews.get(jobAppId):0) ));
    	}
    	if(jobAppToUpdate.size()>0) update jobAppToUpdate;
    }
}