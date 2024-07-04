import { LightningElement,api } from 'lwc';
import sendWhatsappmessage from "@salesforce/apex/WhatsappIntegration.sendWhatsappmessage"
export default class WhatsappIntegration extends LightningElement
{
    @api recordId;

    handleSendMessage(event)
    {
        sendWhatsappmessage({conId: this.recordId})
        .then(result => { console.log('UN: Message sent '+result) })
        .catch(error => { console.log('UN: Message sent error '+JSON.stringify(error)) })
    }
}