trigger InterviewTrigger on Interview__c(before insert, before delete, after insert, after update, after delete)
{
	List<Interview__c> interviews = Trigger.isDelete? Trigger.old : Trigger.new;
    if(Trigger.isBefore)
    {
    	if(Trigger.isInsert)
    	{
    		InterviewTriggerHandler.userValidation(interviews);
    	}
    	if(Trigger.isDelete)
    	{
    		InterviewTriggerHandler.deleteRelatedFeedbacks(interviews);
    	}
    }

    if(Trigger.isAfter)
    {
    	if(Trigger.isUpdate || Trigger.isInsert || Trigger.isDelete)
    	{
    		InterviewTriggerHandler.rollupInterviewsOnJobApplication(interviews);
    	}
    }
}