trigger WebLeadsTrigger on  BTL_Web_Lead__c (after insert)
{
	if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            WebLeadsTriggerHandler.afterInsert(Trigger.new);
        }
    }
}