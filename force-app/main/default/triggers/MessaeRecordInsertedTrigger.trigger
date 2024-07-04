trigger MessaeRecordInsertedTrigger on MessaeRecordInserted__e (after insert)
{
    List<Id> recIds = new List<Id>();
    for(MessaeRecordInserted__e mri : Trigger.new)
    {
        recIds.add(mri.Message_Record_Id__c);
    }
    WAMessageTriggerHandler.sendMessageReply(recIds);
}