public with sharing class LeadTriggerHandler
{
    public static void sendLeadInfoToMohsinOrg(List<Lead> leads, Map<Id, Lead> oldMap, Boolean isInsert)
    {
        List<Id> leadIds = new List<Id>();
        for(Lead ld : leads)
        {
            Lead old = isInsert? NULL : oldMap.get(ld.Id);
            if(isInsert || (!isInsert && (old.company != ld.Company || old.LastName != ld.LastName || old.Email != ld.Email || old.LeadSource != ld.LeadSource)))
            {
                leadIds.add(ld.Id);
            }
        }

        if(leadIds.size()>0) 
        {
        	System.enqueueJob(new IntegrationQueueable('Lead_Sender', leadIds));
        }
    }

    public static void sendLeadInfoToMohsinOrgFuture(List<Id> leadIds)
    {
        System.debug('UAC: queuebale class execute method ');

        List<Lead> leadstoUpdate = new List<Lead>();
        for(Lead ld : [SELECT Id, Moshin_Org_Id__c  , LastName, Company, LeadSource, Email FROM Lead WHERE Id IN :leadIds])
        {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setEndpoint('callout:MohsinOrg/services/apexrest/leads');
            req.setMethod('POST');
            String jsonBody = '{"leadId":"'+ld.Id+'","leadName":"'+ld.LastName+'","leadCompany":"'+ld.Company+'","leadSource":"'+ld.LeadSource+'","email":"'+ (String.isNotBlank(ld.Email) ? ld.Email : '') + '"}'  ;
            System.debug('UN: jsonBody: '+ jsonBody );
            req.setBody(jsonBody);
            req.setHeader('Content-Type', 'application/json');
            res = h.send(req);
            System.debug('UN: ResBody: '+res.getbody());
            

            mohsinLeadId mlId = new mohsinLeadId();
            mlId = (mohsinLeadId) JSON.deserialize(res.getbody(), mohsinLeadId.class);
            System.debug('UN: mlId'+mlId);
            leadstoUpdate.add(new lead(Id=ld.Id, Moshin_Org_Id__c=mlId.leadId));
        }
        if(leadstoUpdate.size()>0) update leadstoUpdate;
    }

    public class mohsinLeadId
    {
        public string leadId;
    }
}