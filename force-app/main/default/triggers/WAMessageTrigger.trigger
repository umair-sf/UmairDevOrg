trigger WAMessageTrigger on WAMessage__c (after insert)
{
    WAMessageTriggerHandler.subscribePlatformEvent(Trigger.new);
    // List<String> recordIds = new List<String>();
    // for(WAMessage__c msg : Trigger.new)
    // {
    //     Set<String> intents = new Set<String>();
        
    //     for(Intent__c i : [SELECT Intent_ID__c FROM Intent__c])
    //     {
    //         intents.add(i.Intent_ID__c);
    //     }

    //     if(!msg.Outgoing__c && intents.contains(msg.MessageContent__c))
    //     {
    //         recordIds.add(msg.Id);
    //     }
    // }
    // if(recordIds.size() > 0)  WAMessageTriggerHandler.sendMessageReply(recordIds);
}