public with sharing class ContentDocumentLinkTriggerHandler
{
    public static void updateDocumentFields(List<ContentDocumentLink> contentDocLinks)
    {
        Map<String,String> contentDocIdtoRecId = new Map<String,String>();
        List<Document__c> documents = new List<Document__c>();
        List<ContentDistribution> conDistributions = new List<ContentDistribution>();
        String keyPrefix = Schema.getGlobalDescribe().get('Document__c').getDescribe().getKeyPrefix();
        
        for(ContentDocumentLink docLink:  contentDocLinks)
        {
            contentDocIdtoRecId.put(docLink.ContentDocumentId,docLink.LinkedEntityId);
        }

        for(ContentVersion conVer : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocIdtoRecId.keySet()
                                     AND Id NOT IN (select ContentVersionId from ContentDistribution)])
        {
            ContentDistribution conDis = new ContentDistribution();
            conDis.Name = conVer.Title;
            conDis.ContentVersionId = conVer.Id;
            conDis.PreferencesExpires = false;
            conDis.PreferencesAllowPDFDownload = false;
            conDis.PreferencesAllowOriginalDownload = false;
            conDis.PreferencesPasswordRequired = false;
            conDis.PreferencesAllowViewInBrowser = true;
            conDistributions.add(conDis);
        }
        if(conDistributions.size()>0) insert conDistributions;

        for(ContentDistribution conDis : [SELECT Id, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE ContentDocumentId IN :contentDocIdtoRecId.keySet()])
        {
            String docId = contentDocIdtoRecId.get(conDis.ContentDocumentId);
            If(contentDocIdtoRecId.get(conDis.ContentDocumentId).startsWith(keyPrefix))
            {
                documents.add(new Document__c(Id=docId, Is_File_Attached__c = true, File_Public_Link__c = conDis.DistributionPublicUrl));
            }
        }
        if(documents.size()>0) update documents;
    }
}