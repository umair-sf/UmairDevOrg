trigger PhysicianTrigger on Physician__c(before insert)
{
    PhysicianTriggerHandler.duplicateChecker(Trigger.new);
}