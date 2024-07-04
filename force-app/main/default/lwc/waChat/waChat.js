import { LightningElement, api } from 'lwc';
import getAllMessages from '@salesforce/apex/WhatsAppChatHandler.getAllMessages'
import sendWhatsappmessage from '@salesforce/apex/WhatsAppChatHandler.sendWhatsappmessage'
import getCustomerMessages from '@salesforce/apex/WhatsAppChatHandler.getCustomerMessages'
import {subscribe,unsubscribe, onError} from 'lightning/empApi'
export default class WaChat extends LightningElement
{
    messages = undefined;
    message = undefined;
    isLoading = false;
    subscription = undefined;
    @api recordId;
    whatsappNum = '923237467967';

    connectedCallback()
    {
        this.platformEventSubscriber();
        this.getAllMessages();
    }

    getAllMessages()
    {
        getAllMessages({phone : this.whatsappNum})
        .then(result=>
        {
            this.messages = result;
            this.isLoading = true;
        })
        .catch(error =>
        {
            console.log('UN: Error Loading Messages '+JSON.stringify(error));
            this.isLoading = false;
        })
        .finally( () =>
        {
            this.isLoading = false;
            let chatArea = this.template.querySelector('.chatArea');
            if(chatArea)
            {
                chatArea.scrollTop = chatArea.scrollHeight;
            }
        });
    }

    disconnectedCallback()
    {
        unsubscribe(this.subscription, (response) => {console.log('UN: unsubsccribe event '+JSON.stringify(response))})
    }

    platformEventSubscriber(event)
    {
        onError(error=>{'UN: Error Subscribing PlaformEvent'+ JSON.stringify(error)});
        subscribe('/event/WA_Message_Event__e',-1,
                (response) =>
                {
                    console.log('UN: Customer New Message response'+JSON.stringify(response));
                    let data = response.data.payload;
                    let recordId = data.Message_ID__c;
                    let whatsappNum = data.Customer_Phone__c;
                    console.log('UN: recordId '+recordId+' whatsappNum: '+whatsappNum);
                    this.getAllMessages();
                })
        .then(response =>
        {
            console.log('UN: subscribed to PE '+JSON.stringify(response))
            this.subscription = response;
        });
    }

    // handleSubscribeResponse(response)
    // {
    //     console.log('UN: Customer New Message response'+JSON.stringify(response));
    //     let data = response.data.payload;
    //     let recordId = data.Message_ID__c;
    //     let whatsappNum = data.Customer_Phone__c;
    //     console.log('UN: recordId '+recordId+' whatsappNum: '+whatsappNum);
    //     getCustomerMessages({whatsappNum:whatsappNum , recordId: recordId})
    //     .then(result =>
    //     {
    //         console.log('UN: Customer New Message '+JSON.stringify(result))
    //         this.messages.push(result);
    //         console.log('UN: Messages after getting reply '+JSON.stringify(this.messages));
    //     })
    //     .catch(error =>
    //     {
    //         console.log('UN: Error Loading Customer Message '+JSON.stringify(error))
    //     })
    //     .finally( () =>
    //     {
    //         let chatArea = this.template.querySelector('.chatArea');
    //         if(chatArea)
    //         {
    //             chatArea.scrollTop = chatArea.scrollHeight;   
    //         }
    //     });
    // }

    handleMessageSubmit(event)
    {
        let buttonName = event.target.dataset.id;
        console.log('UN: buttonName '+buttonName);
        
        if ((event.key === 'Enter' || buttonName === 'sendMessageButton') && !this.isBlank(this.message))
        {
            this.isLoading = true;
            console.log('UN: Message to send '+this.message);
            sendWhatsappmessage({whatsappNum: this.whatsappNum, textMessage:this.message})
            .then(result =>
            {
                this.template.querySelector('[data-id="messageInput"]').value = '';
                this.isLoading = false;
                console.log('UN: Message Sent '+this.message);
                this.message = undefined;
                this.messages = [...this.messages, result];
            })
            .catch(error =>
            {
                this.isLoading = false;
                console.log('UN: Error Loading Messages '+JSON.stringify(error))
            })
            .finally( () =>
            {
                this.isLoading = false;
                let chatArea = this.template.querySelector('.chatArea');
                if(chatArea)
                {
                    chatArea.scrollTop = chatArea.scrollHeight;   
                }
            });
        }
    }
    
    handleInputChange(event)
    {
        this.message = event.detail.value;
    }

    isBlank(val)
    {
        let isBlank = val !== undefined && val !== '' && val !== null ;
        return !isBlank ;
    }
}