public with sharing class ContactController
{
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){
        return [SELECT Id, Name, Phone, Email, Logo__c, Rank__c, LeadSource, AccountId, Account.Name FROM Contact];
    }
}