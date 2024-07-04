@isTest
private class ContentDocumentLinkTriggerHandlerTest
{
    static testMethod void testMethod1()
    {
        Document__c doc = new Document__c(Name='Test');
        insert doc;

        //Create Document
        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Test Doc';
        conVer.PathOnClient = 'TestDoc.jpeg';
        conVer.VersionData = Blob.valueOf('Test');
        conVer.IsMajorVersion = true;
        Insert conVer;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.LinkedEntityId = doc.Id;
        conDocLink.ContentDocumentId = conDocId;
        conDocLink.shareType = 'V';
        Insert conDocLink;
    }
}