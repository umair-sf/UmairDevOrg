import { LightningElement, api, wire } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import CONTACT_API from '@salesforce/schema/Contact';
import CONTACT_NAME from '@salesforce/schema/Contact.Name';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';
import CONTACT_PHONE from '@salesforce/schema/Contact.Phone';
import CONTACT_ACCID from '@salesforce/schema/Contact.AccountId';
import getAccountContacts from '@salesforce/apex/AccountToContactExt.getAccountContacts';
const accountFields = ['Account.Name','Account.Phone','Account.OwnerId','Account.Owner.Name','Account.Email__c'];
export default class AccountContact extends LightningElement
{
    @api recordId = undefined;
    contactAPI = CONTACT_API;
    conName = CONTACT_NAME;
    conPhone = CONTACT_PHONE;
    conEmail = CONTACT_EMAIL;
    conAccId = CONTACT_ACCID;
    isCreated = false;
    // connectedCallback()
    // {
    //     getAccountContacts({acId:this.recordId})
    //     .then(result=>
    //     {
    //         this.contacts=result;
    //         console.log(this.contacts);
    //     })
    //     .catch(error=>
    //     {

    //     });
    // }
    account = undefined;
    @wire(getRecord, {recordId:'$recordId', fields:accountFields})
    wiredContacts({error,data})
    {
        if(data)
        {
            let accountData = Object.assign({},data);
            this.account = accountData;
            this.account.accountUrl = "https://umairtern-dev-ed.develop.lightning.force.com/lightning/r/User/"+this.account.fields.OwnerId.value+"/view";
            console.log(this.account);
        }
        if(error)
        {

        }
    }

    handleReset(event)
    {
        const allFields = this.template.querySelectorAll('lightning-input-field');
        if(allFields)
        {
            allFields.forEach(field => {field.reset()});
            allFields.forEach(item=>{item.disabled=false});
            this.isCreated = false;
        }
    }
    handleError(event)
    {
        this.showToast('Failed to Create Contact','Error','error');
    }
    handleSuccess(event)
    {
        this.isCreated = true;
        this.showToast('Contact Created Successfully '+event.detail.id,'Success','success');
        this.template.querySelectorAll('lightning-input-field').forEach(item=>{item.disabled=true});
        console.log(JSON.stringify(event.detail));
    }
    handleSubmit(event)
    {
        event.preventDefault();
        const allFields = event.detail.fields; 
        allFields.AccountId = this.recordId;
        console.log('UN: allFields'+JSON.stringify(allFields));
        console.log('UN: recordId'+this.recordId);
        this.template.querySelector('lightning-record-edit-form').submit(allFields);
    }

    showToast(theMessage, theTitle, theVariant)
    {
        const toast = new ShowToastEvent({title: theTitle, message: theMessage,variant: theVariant});
        this.dispatchEvent(toast);
    }
}