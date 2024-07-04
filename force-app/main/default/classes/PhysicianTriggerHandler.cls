public with sharing class PhysicianTriggerHandler
{
    public static void duplicateChecker(List<Physician__c> physicians)
    {
    	Set<String> newEmails = new Set<String>();
    	Set<String> existingEmails = new Set<String>();

    	for(Physician__c phy : physicians)
    	{
    		if(String.isNotBlank(phy.Email__c))
    		{
    			newEmails.add(phy.Email__c);
    		}
    	}
    	if(newEmails.size()==0) return;

    	for(Physician__c phy :[SELECT Email__c FROM Physician__c WHERE Email__c IN :newEmails AND Id NOT IN :physicians])
		{
    		existingEmails.add(phy.Email__c);
    	}
    	if(existingEmails.size()==0) return;

    	for(Physician__c phy : physicians)
    	{
    		if(existingEmails.contains(phy.Email__c))
    		{
    			phy.addError('Email Already Exists: '+phy.Email__c);
    		}
    	}
    }
}