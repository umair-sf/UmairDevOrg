trigger TerminationTrigger on Termination_Request__c (before insert, before update, after insert, after update)
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            TerminationTriggerHandler.calculateDates(Trigger.new);
        }
    }

    if(Trigger.isAfter)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            TerminationTriggerHandler.insertTerminationLineItems(Trigger.new);
        }
    }
}