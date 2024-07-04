public with sharing class WAMessageTriggerHandler
{
    public static void subscribePlatformEvent(List<WAMessage__c> messageRec)
    {
        System.debug('UN: messageRec '+ messageRec);
        String messageRecordId = messageRec.get(0).Id;
        MessaeRecordInserted__e mri = new MessaeRecordInserted__e();
        mri.Message_Record_Id__c = messageRecordId;
        EventBus.publish(mri);
        System.debug('UN: MessaeRecordInserted__e '+ mri);
    }

    @future(callout=true)
    public static void sendMessageReply(List<String> recordIds)
    {
        System.debug('UN: recordIds '+recordIds);
        List<WAMessage__c> messages = [SELECT Id, Name, CustomerPhone__c, Customer_Name__c, MessageContent__c, MessageID__c, ParentMessageID__c
                                        FROM WAMessage__c
                                        WHERE Id IN :recordIds];
        System.debug('UN: messages '+messages);
        WAMessage__c message = messages.get(0);
        System.debug('UN: PhoneNumber '+message.CustomerPhone__c);
        System.debug('UN: PhoneNumber '+message.MessageContent__c);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();

        String rows = '';
        Intent__c selectedIntent = [SELECT Name, Id, Intent_ID__c, Parent_Intent__c FROM Intent__c WHERE Intent_ID__c =:message.MessageContent__c LIMIT 1];

        for(Intent__c i : [SELECT Name, Id, Intent_ID__c, Parent_Intent__c FROM Intent__c WHERE Parent_Intent__c =:selectedIntent.Id])
        {
            rows += '{"id":"'+i.Intent_ID__c+'","title":"'+i.Name+'"},';
        }

        String reqBody = '{"messaging_product":"whatsapp","recipient_type":"individual","to":"'+message.CustomerPhone__c+'","type":"interactive","interactive":{"type":"list","header":{"type":"text","text":"TernEdge"},"body":{"text":"How we can help you? Please specify the service you are interested in."},"footer":{"text":"Sent By TernEdge"},"action":{"sections":[{"title":"Section 1","rows":['+rows.removeEnd(',')+']}],"button":"Select Service"}}}';
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
            WAMessageTriggerHandler responseFromWA = (WAMessageTriggerHandler) JSON.deserialize(res.getBody() , WAMessageTriggerHandler.class);
            salesforceMessage.MessageID__c = responseFromWA.messages.get(0).id;
            salesforceMessage.MessageType__c = 'Text';
            salesforceMessage.CustomerPhone__c = message.CustomerPhone__c;
            salesforceMessage.Outgoing__c = true;
            salesforceMessage.MessageContent__c = 'Reply Sent';
            salesforceMessage.MessageSentTime__c = System.now();
            salesforceMessage.Agent_Name__c = UserInfo.getFirstName() +' '+UserInfo.getLastName();
            upsert salesforceMessage MessageID__c;
        }
    }

    public messages[] messages;
    public class messages
    {
        public String id;
    } 
}