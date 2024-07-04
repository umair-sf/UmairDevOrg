trigger ContentVersionTrigger on ContentVersion (after insert)
{
    if(Trigger.isAfter)
    {
    	if(Trigger.isInsert)
    	{
    		//ContentVersionTriggerHandler.createContentDistribution(Trigger.new);
    	}
    }
}