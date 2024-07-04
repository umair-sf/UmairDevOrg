@RestResource(urlMapping='/ternchat/webhook/v1/*')
global without sharing class WhatsAppWebhook
{
	private static Final String SIGNATURE_VALID_MESSAGE     = 'Signature Verified';
    private static Final String SIGNATURE_NOT_VALID_MESSAGE = 'Signature could not be verified';

    @HttpGet
    global static void doGet()
    {
    	RestResponse response = RestContext.response;
    	RestRequest request = RestContext.request;
    	if(request.params.get('hub.verify_token') == 'YABANKATITA')
    	{
    		response.responseBody = Blob.valueOf(request.params.get('hub.challenge'));
    	}
    	System.debug('Get Method called');
    }

    @HttpPost
    global static void doPost()
    {
        System.debug(' UN: doPost Called! ');
    	RestResponse response = RestContext.response;
        response.addHeader('Content-type','application/json');
        String responseString = RestContext.request.requestBody.toString();
        Map<String, String> headers = RestContext.request.headers;
        String responseValid = validateWhatsAppSignature(RestContext.request, responseString);

        if(responseValid == SIGNATURE_VALID_MESSAGE)
        {
            System.debug(' UN:Headers Response From WhatsApp \n  '+ JSON.serialize(headers) );
            System.debug(' UN: Response From WhatsApp \n  '+ responseString);

            String finalResponseString = responseString.replace('type', 'typex');
            WhatsAppMessage parentMessage = (WhatsAppMessage)JSON.deserialize( finalResponseString, WhatsAppMessage.class);
            System.debug(' UN: Response From WhatsApp '+ finalResponseString);
            List<WhatsAppMessage.entry> messageEntries = parentMessage.entry;
            if(messageEntries != null && messageEntries.size() > 0)
            {
                WhatsAppMessage.entry entryMessage = messageEntries.get(0);
                List<WhatsAppMessage.changes> changeMessages = entryMessage.changes;
                if(changeMessages != null && changeMessages.size() > 0)
                {
                    WhatsAppMessage.changes changeMessage = changeMessages.get(0);
                    List<WhatsAppMessage.contacts> contactList = changeMessage.value.contacts;
                    List<WhatsAppMessage.messages> messageList = changeMessage.value.messages;
                    WhatsAppMessage.metadata metadata = changeMessage.value.metadata;
                    /* Create record into Salesforce */
                    WAMessage__c salesforceMessage = new WAMessage__c();
                    salesforceMessage.BusinessPhoneNumber__c = metadata != null ? metadata.display_phone_number : null;
                    
                    if(contactList != null && contactList.size() > 0)
                    {
                        WhatsAppMessage.contacts contact = contactList.get(0);
                        salesforceMessage.CustomerPhone__c = contact.wa_id;
                        salesforceMessage.Customer_Name__c = contact.profile.name;
                    }
                    
                    if(messageList != null && messageList.size() > 0)
                    {
                        /* Simple Message */
                        WhatsAppMessage.messages message = messageList.get(0);
                        salesforceMessage.MessageID__c = message.id;
                        salesforceMessage.MessageType__c = message.typex;
                        salesforceMessage.MessageSentTime__c = System.now();
                        salesforceMessage.MessageContent__c = message.typex == 'interactive'? message.interactive.list_reply.id : message.text != null? message.text.body : null;
                        
                        /* If message is reaction */
                        salesforceMessage.Reaction__c = message.reaction != null ? message.reaction.emoji : null;
                        salesforceMessage.ParentMessageID__c = message.reaction != null ? message.reaction.message_id : null;
                        
                        /* If message is Image */
                        salesforceMessage.ImageID__c = message.image != null ? message.image.id : null;
                        salesforceMessage.ImageType__c = message.image != null ? message.image.mime_type : null;
                        salesforceMessage.ImageSHA256__c = message.image != null ? message.image.sha256 : null;
                        
                        /* If message is Video */
                        // salesforceMessage.VideoId__c = message.video != null ? message.video.id : null;
                        // salesforceMessage.VideoType__c = message.video != null ? message.video.mime_type : null;
                        // salesforceMessage.VideoSHA256__c = message.video != null ? message.video.sha256 : null;
                        
                        /* If the message is reply to another message */
                        salesforceMessage.ParentMessageID__c = message.context != null ? message.context.id : null;
                        upsert salesforceMessage MessageID__c;

                        WA_Message_Event__e waEvent = new WA_Message_Event__e();
                        waEvent.Message_ID__c = salesforceMessage.Id;
                        waEvent.Customer_Phone__c = salesforceMessage.CustomerPhone__c;
                        EventBus.publish(waEvent);
                }
               }     
            }
        }
        else
        {
            response.responseBody = Blob.valueOf('{success:false, event:"Unknown","message:"'+responseValid+'"}');
            response.statusCode = 401;
            return;
        }
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{success:true, event:"success"}');
    }
    
    private static String validateWhatsAppSignature(RestRequest request, String responseString)
    {
        Map<String, String> headers = request.headers;
        String whatsAppSignature = headers.get('X-Hub-Signature-256');
        String whatsAppPayload = RestContext.request.requestBody.toString();
        String whatsAppSecret = System.Label.WHATSAPPSECRET;
        Blob signedPayload = Crypto.generateMac('hmacSHA256', Blob.valueOf(whatsAppPayload), Blob.valueOf( whatsAppSecret ));
        String encodedPayload = 'sha256='+EncodingUtil.convertToHex(signedPayload);        
        String response = (encodedPayload == whatsAppSignature)? SIGNATURE_VALID_MESSAGE : SIGNATURE_NOT_VALID_MESSAGE;
        return response;
    }
}