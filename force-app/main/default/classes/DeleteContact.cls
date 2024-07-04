public with sharing class DeleteContact
{
    @AuraEnabled
    public static void deleteContact(String contactId)
    {
        Contact con = [SELECT Id FROM Contact WHERE Id =:contactId];
        delete con;
    }
}