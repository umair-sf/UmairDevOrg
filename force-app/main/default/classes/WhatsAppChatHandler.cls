public with sharing class WhatsAppChatHandler
{
    @AuraEnabled
    public static List<WAMessage__c> getAllMessages(String phone)
    {
        return [SELECT Id, Name, CreatedDate, CustomerPhone__c, Customer_Name__c, MessageContent__c,
                        MessageSentTime__c, MessageID__c, MessageType__c, ParentMessageID__c, Reaction__c,
                        Imagesha256__c, ImageType__c, ImageID__c, Outgoing__c, Agent_Name__c
                FROM WAMessage__c WHERE CustomerPhone__c =:phone ORDER BY  CreatedDate ASC];
    }

    @AuraEnabled
    public static List<WAMessage__c> getCustomerMessages(String whatsappNum, String recordId)
    {
        return [SELECT Id, Name, CreatedDate, CustomerPhone__c, Customer_Name__c, MessageContent__c,
                        MessageSentTime__c, MessageID__c, MessageType__c, ParentMessageID__c, Reaction__c,
                        Imagesha256__c, ImageType__c, ImageID__c, Outgoing__c, Agent_Name__c
                FROM WAMessage__c WHERE Id =:recordId AND CustomerPhone__c =:whatsappNum ];
    }

    @AuraEnabled
    public static WAMessage__c sendWhatsappmessage(String whatsappNum, String textMessage)
    {
        String parentIntent = '';
        WAMessage__c message = whatsappCallout(whatsappNum,textMessage);
        return [SELECT Id, Name, CreatedDate, CustomerPhone__c, Customer_Name__c, MessageContent__c,
                        MessageSentTime__c, MessageID__c, MessageType__c, ParentMessageID__c, Reaction__c,
                        Imagesha256__c, ImageType__c, ImageID__c, Outgoing__c, Agent_Name__c
                FROM WAMessage__c WHERE Id =:message.Id];
    }

    public static WAMessage__c whatsappCallout(String whatsappNum, String textMessage)
    {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();

        String rows = '';
        for(Intent__c i : [SELECT Name, Id, Intent_ID__c, Parent_Intent__c FROM Intent__c])
        {
            if(String.isBlank(i.Parent_Intent__c))
            {
                rows += '{"id":"'+i.Intent_ID__c+'","title":"'+i.Name+'"},';
            }
        }

        String reqBody = '{"messaging_product":"whatsapp","recipient_type":"individual","to":"'+whatsappNum+'","type":"interactive","interactive":{"type":"list","header":{"type":"text","text":"TernEdge"},"body":{"text":"How we can help you? Please specify the service you are interested in."},"footer":{"text":"Sent By TernEdge"},"action":{"sections":[{"title":"Section 1","rows":['+rows.removeEnd(',')+']}],"button":"Select Service"}}}';
        System.debug('UN: reqBody '+reqBody);
        req.setMethod('POST');
        req.setEndpoint('https://graph.facebook.com/v17.0/337603519444982/messages');
        req.setBody(reqBody);
        req.setHeader('Content-Type', 'application/json');
        String apiToken = 'EAAOlXlo1ehkBO9KNcyFlG4aKxMoiI2ywG3Vz8VIzoqyAyIKs6A7ZC0L63pksBO2W0ZCRcjrdG99efacNU75pmvZCXgsuZCUZBzFGhEh6ZCdS9vLBqLPD01cpcAASzKSR60UtJcdToMHEeK83OTAqb0OwKUvc4tW70ItEOBCFq04YIV1tkgZBWZCzAZCmyMZAmsvPaDDKnKDNZByUhxbnD7vxljBShuxUpoiAZCzc97PnTZBoR';
        req.setHeader('Authorization', 'Bearer '+apiToken);
        res = h.send(req);

        if(res.getStatusCode()==200)
        {
            WAMessage__c salesforceMessage = new WAMessage__c();
            WhatsappIntegration responseFromWA = (WhatsappIntegration) JSON.deserialize(res.getBody() , WhatsappIntegration.class);
            salesforceMessage.MessageID__c = responseFromWA.messages.get(0).id;
            salesforceMessage.MessageType__c = 'Text';
            salesforceMessage.CustomerPhone__c = whatsappNum;
            salesforceMessage.Outgoing__c = true;
            salesforceMessage.MessageContent__c = textMessage;
            salesforceMessage.MessageSentTime__c = System.now();
            salesforceMessage.Agent_Name__c = UserInfo.getFirstName() +' '+UserInfo.getLastName();
            upsert salesforceMessage MessageID__c;
            return salesforceMessage;
        }
        return null;
    }

    public messages[] messages;
    public class messages
    {
        public String id;
    }
}