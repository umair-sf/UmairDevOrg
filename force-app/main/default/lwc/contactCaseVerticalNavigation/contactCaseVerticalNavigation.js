import { LightningElement,api,wire,track} from 'lwc';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';

const contactFields = ['Contact.Name','Contact.Id'];
const caseFields = ['Case.CaseNumber','Case.ContactId','Case.Id'];

export default class ContactCaseVerticalNavigation extends NavigationMixin(LightningElement)
{
    @api recordId = undefined;
    contacts=undefined;
    selectedContactId = undefined;
    cases = undefined;
    selectedCaseId = undefined;

    navigateToViewContacttPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.selectedContactId,
                objectApiName: 'Contact',
                actionName: 'view'
            },
        });
    }
    
    @wire(getRelatedListRecords, {parentRecordId: '$recordId', relatedListId: 'Contacts', fields: contactFields})
    contactInfo(value)
    {
        const {data,error} = value;
        if(data)
        {
            this.contacts = JSON.parse(JSON.stringify(data.records));
            console.log('UN Related Contacts'+JSON.stringify(this.contacts));
            
            this.contacts.forEach(con =>
            {
                con.Name = con.fields.Name.value;
            });
        }
        if(error)
        {
            console.log('Contact Wire Error: ',error);
        }
    }

    @wire(getRelatedListRecords, {parentRecordId: '$selectedContactId', relatedListId: 'Cases', fields: caseFields})
    caseInfo(value)
    {
        const {data,error} = value;
        if(data)
        {
            this.cases = JSON.parse(JSON.stringify(data.records));
            console.log('UN Related Cases'+JSON.stringify(this.cases));
            
            this.cases.forEach(cs =>
            {
                cs.CaseNumber = cs.fields.CaseNumber.value;
            });
        }
        if(error)
        {
            console.log('Case Wire Error: ',error);
        }
    }

    hanldeContactSelect(event)
    {
        this.selectedContactId = event.detail.name;
        console.log('UN ContactId : '+this.selectedContactId);
    }

    hanldeCaseSelect(event)
    {
        this.selectedCaseId = event.detail.name;
        console.log('UN ContactId : '+this.selectedCaseId);
    }

    get acceptedFormats()
    {
        return ['.jpg', '.png','.jpeg','.pdf'];
    }

    showToast(theMessage, theTitle, theVariant)
    {
        const toast = new ShowToastEvent({title: theTitle, message: theMessage,variant: theVariant});
        this.dispatchEvent(toast);
    }
}