import { LightningElement, api, wire } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { updateRecord, createRecord, deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
const caseFields = ['Case.Status','Case.AccountId','Case.ContactId','Case.SuppliedEmail','Case.SuppliedPhone','Case.Origin'];
const contactFields = ['Contact.Name','Contact.Title','Contact.Phone','Contact.Email','Contact.Roles__c'];

export default class ContactInfo extends NavigationMixin(LightningElement) 
{
    @api accountId;
    contactId = undefined;
    isEditMode = false;
    showButton = false;
    upsertedContactId = undefined;
    wiredContacts = undefined;
    contacts = undefined;
    viewAllContacts = undefined;

    connectedCallback()
    {
        // Generate a URL to a User record page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordRelationshipPage',
            attributes:
            {
                recordId: this.accountId,
                objectApiName: 'Account',
                relationshipApiName: 'Contacts',
                actionName: 'view'
            },
        }).then((url) => {
            this.viewAllContacts = url;
        });
    }

    @wire (getRelatedListRecords, {parentRecordId: '$contactId', relatedListId: 'Cases', fields: caseFields})
    cases;

    @wire(getRelatedListRecords, {parentRecordId: '$accountId', relatedListId: 'Contacts', fields: contactFields})
    contactInfo(value)
    {
        this.wiredContacts = value;
        const {data,error} = value;
        if(data)
        {
            this.contacts = JSON.parse(JSON.stringify(data.records));
            this.contacts.forEach(con =>
            {
                if(con.fields.Email.value)
                {
                    con.mailtoUrl = 'mailto:'+ con.fields.Email.value;
                    con.Email = con.fields.Email.value;
                }
                if(con.fields.Phone.value)
                {
                    con.phoneUrl = 'tel:'+ con.fields.Phone.value;
                    con.Phone = con.fields.Phone.value;
                }
                con.Name = con.fields.Name.value;
                if(con.fields.Roles__c.value)
                {
                    let roles = con.fields.Roles__c.value;
                    con.Roles = roles.split(";");
                }
                con.contactUrl = 'https://umairtern-dev-ed.develop.lightning.force.com/lightning/r/Contact/'+con.id+'/view';
                con.Title = con.fields.Title.value;   
            });
        }
    }

    closeContactModel(event)
    {
        this.contactId = undefined;
        this.isEditMode = false ;
        this.showButton = false;
    }

    enableDisableForm(isDisabled)
    {
        this.template.querySelectorAll('lightning-input-field').forEach(item=>{item.disabled=isDisabled});
    }

    loadForm(event)
    {
        if(this.contactId)
        {
            this.enableDisableForm(true);
        }
        else{
            this.enableEdit();
        }
    }

    enableEdit(event)
    {
        this.enableDisableForm(false);
        this.showButton = false;
    }

    handleSubmit(event)
    {
        event.preventDefault();
        const allFields = event.detail.fields;
        allFields.AccountId = this.accountId;
        this.template.querySelector('lightning-record-edit-form').submit(allFields);
        if(this.contactId)
        {
            this.showToast('Contact Updated Successfully','Success','success');
        }
        else
        {
            this.showToast('Contact Created Successfully','Success','success');
        }
        this.upsertedContactId = this.contactId;
        console.log('submit me id dalny lagi hai'+this.upsertedContactId);
        this.closeContactModel();
        this.showButton = true;
    }

    handleSuccess(event)
    {
        const allFields = event.detail.fields;
        const fields ={};
        fields.ContactId = event.detail.id;
        fields.AccountId = allFields.AccountId.value;
        fields.Origin = 'Phone';
        fields.Status = 'New';
        fields.SuppliedEmail = allFields.Email.value;
        fields.SuppliedPhone = allFields.Phone.value;
        console.log('UN On Success Fields:',event.detail);
        const recordInput = {apiName:'Case', fields};
        console.log('andar jany laga hai'+this.upsertedContactId);
        console.log('UN Cases: ',JSON.stringify(this.cases));
        if(this.upsertedContactId && this.cases.data.count > 0)
        {
            console.log('War gaya');
            fields.Id = this.cases.data.records[0].id;
            delete recordInput.apiName;
            updateRecord(recordInput)
            .then(result=>{
                console.log('UN On Result:'+JSON.stringify(result));
                this.showToast('Updated Case with ID '+result.id+' Successfully','Success','success');
            }
            )
            .catch(error=>{
                console.log('Error UN',JSON.stringify(error))
                this.showToast('Case Behn Yuwa Geya Hai'+JSON.stringify(error),'oops!','error');
            });
        }
        else
        {
            createRecord(recordInput)
            .then(result=>{
                refreshApex(this.wiredContacts);
                this.showToast('New Case Created Successfully','Success','success');
            }
            )
            .catch(error=>{
                this.showToast('Case Behn Yuwa Geya Hai','oops!','error');
            });

        }
        this.template.querySelectorAll('lightning-input-field').forEach(item=>{item.disabled=true});
    }

    get acceptedFormats()
    {
        return ['.jpg', '.png','jpeg'];
    }

    contactEdit(event)
    {
        this.contactId = event.target.value;
        console.log('UAC: contactId ' + this.contactId );
        this.isEditMode = true;
        this.showButton = true;
        this.loadForm();
    }

    async handleDeleteConfirm(event)
    {
        this.contactId = event.target.value;
        console.log('UAC: contactId ' + this.contactId );

        const result = await LightningConfirm.open(
        {
            message: 'Are you sure you want to delete the record?',
            variant: 'header',
            label: 'Confirm Delete',
            theme: 'inverse'
        })
        if(result===true)
        {
            console.log('UAC: contactId ' + this.contactId );
            
            if(this.cases.data.count>0)
            {
                deleteRecord(this.cases.data.records[0].id)
                .then(result=>{
                    this.showToast('Record deleted successfully','Cases Deleted','success');
                })
                .catch(error=>{
                    console.error('UN Case Delete Error', error);
                });
            }

            setTimeout(()=>
            {
                deleteRecord(this.contactId)
                .then(result=>{
                    this.showToast('Record deleted successfully','Contact Deleted','success');
                    refreshApex(this.wiredContacts);
                })
                .catch(error=>{
                    console.log('UN Delete Contact Error',error);
                });
            }
            ,1000);
        }
    };

    showToast(theMessage, theTitle, theVariant)
    {
        const toast = new ShowToastEvent({title: theTitle, message: theMessage,variant: theVariant});
        this.dispatchEvent(toast);
    }

    navigateToContactRelatedList()
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes:
            {
                recordId: this.accountId,
                objectApiName: 'Account',
                relationshipApiName: 'Contacts',
                actionName: 'view'
            },
        });
    }

    contactActionEvent(theContactId, theMode)
    {
        const contactClickEvent = new CustomEvent('contactaction' , 
        { 
            detail : { recordId : theContactId, mode : theMode }
        });
        this.dispatchEvent(contactClickEvent) ;
    }
}