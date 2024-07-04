trigger FeedbackTrigger on Feedback__c(after insert)
{
    if(Trigger.isAfter)
    {
    	if(Trigger.isInsert)
    	{
    		FeedbackTriggerHandler.feedbackRollupToJobApp(Trigger.new);
    	}
    }
}