import { LightningElement, wire } from 'lwc';
import getContactList from '@salesforce/apex/ContactController.getContacts';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import LEADSOURCE_FIELD from "@salesforce/schema/Contact.LeadSource";


const columns =
[
    { label: 'Name', type:"nameBadge", typeAttributes : {name : {fieldName : "Name"}} },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Logo', type:"logoType", typeAttributes : {logoUrl : {fieldName : "logo__c"}} },
    { label: 'Lead Source', type:"customPicklist", editable : true, fieldName : "LeadSource",
        typeAttributes :
        {
            options : {fieldName : "picklistOptions"},
            value : {fieldName : "LeadSource"},
            context : {fieldName : "Id"}
        }},
    { label: 'Rank', fieldName: 'rank__c',
        cellAttributes :
        { 
            class: {fieldName : "rankStyle"},
            iconName : {fieldName : "rankIcon"}
        }},
    { label: 'Account Name', fieldName: 'accountLink', type: 'url',
        typeAttributes:
        {
            label : {fieldName : 'accountName'},
            target : '_blank'
        }
     },
];

export default class AdvanceContactDatatable extends LightningElement
{
    contacts = undefined;
    columns = columns;
    leadSourceOptions = undefined;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, { recordTypeId: "$contactObjectInfo.data.defaultRecordTypeId", fieldApiName: LEADSOURCE_FIELD })
    getPicklistOptions({data,error})
    {
        if(data)
        {
            this.leadSourceOptions = data.values;
            console.log('UN: LeadSource Options '+ JSON.stringify(this.leadSourceOptions));
        }
        else if(error)
        {
            console.log('UN: LeadSource Options Loading Error '+ JSON.stringify(error));
        }
    }
    
    @wire(getContactList, {picklist : "$leadSourceOptions"})
    wiredContacts({data,error})
    {
        if(data)
        {
            console.log('UN: Contacts '+ JSON.stringify(data));
            this.contacts = data.map(con => {
                let accountLink = '/' + con.AccountId;
                let accountName = con.Account.Name;
                let picklistOptions = this.leadSourceOptions;
                let rankStyle = con.rank__c > 1 ? "slds-text-color_destructive slds-icon-text-error" : "slds-text-color_success slds-icon-text-success";
                let rankIcon = con.rank__c > 1 ? "utility:down" : "utility:up";
                return {...con, accountLink: accountLink, accountName:accountName, rankStyle : rankStyle, rankIcon : rankIcon, picklistOptions : picklistOptions};
            });
            console.log('UN: Contacts '+ JSON.stringify(this.contacts));
        }
        if(error)
        {
            console.log('UN: Contact Loading Error '+ JSON.stringify(error));
        }
    }
}