public with sharing class WhatsappIntegration
{
		@AuraEnabled
		public static Boolean sendWhatsappmessage(String conId)
		{
			Contact con = [SELECT Id, Name, Phone FROM Contact WHERE Id =:conId LIMIT 1];

			String whatsappNum = con.Phone;
			HttpRequest req = new HttpRequest();
	        HttpResponse res = new HttpResponse();
	        Http h = new Http();

	        String reqBody = '{'+
							'  "messaging_product": "whatsapp",'+
							'  "recipient_type": "individual",'+
							'  "to": "'+whatsappNum+'",'+
							'  "type": "interactive",'+
							'  "interactive": {'+
							'    "type": "button",'+
							'    "header": {'+
							'        "type" : "image",'+
							'        "image" : {"link" : "https://gratisography.com/wp-content/uploads/2024/01/gratisography-cyber-kitty-800x525.jpg"}'+
							'    },'+
							'    "body": {'+
							'      "text": "Designism services."'+
							'    },'+
							'    "footer": {'+
							'      "text": "Sent from designism.co"'+
							'    },'+
							'    "action": {'+
							'      "buttons":'+
							'      ['+
							'        {'+
							'          "type": "reply",'+
							'          "reply": { "id": "graphic-design", "title": "Graphic Design" }'+
							'        },'+
							'        {'+
							'          "type": "reply",'+
							'          "reply": { "id": "web-development", "title": "Web Development" }'+
							'        },'+
							'        {'+
							'          "type": "reply",'+
							'          "reply": { "id": "branding", "title": "Branding" }'+
							'        }'+
							'      ]'+
							'    }'+
							'  }'+
							'}';
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
	        	salesforceMessage.MessageType__c = 'Interactive Button';
	        	salesforceMessage.CustomerPhone__c = whatsappNum;
	        	salesforceMessage.Outgoing__c = true;
	        	salesforceMessage.Agent_Name__c = UserInfo.getFirstName() +' '+UserInfo.getLastName();
	        	upsert salesforceMessage MessageID__c;
	            return true;
	        }
	        return false; 
		}

		public messages[] messages;
		public class messages
		{
			public String id;
		}   
}