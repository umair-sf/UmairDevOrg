trigger AccountTrigger on Account(after update)
{
    AccountTriggerHandler.contactClonerToParent(Trigger.new, Trigger.oldMap);
}