trigger LeadTrigger on Lead(after insert)
{
    if(Trigger.isAfter)
    {
    	if(Trigger.isInsert)
    	{
    		LeadTriggerHandler.sendLeadInfoToMohsinOrg(Trigger.new, Trigger.oldMap, Trigger.isInsert);
    	}
    }
}