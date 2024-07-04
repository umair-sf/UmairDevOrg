import { LightningElement,api,wire,track} from 'lwc';
import { updateRecord, getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getAllAccounts from '@salesforce/apex/AccountToContactExt.getAllAccounts';
import getAllContacts from '@salesforce/apex/AccountToContactExt.getAllContacts';
import Toast from 'lightning/toast';

export default class AccountDataTable extends LightningElement
{
    accounts = undefined;
    draftValues = [];
    sortBy=undefined;
    sortDirection=undefined;
    isLoading = false;
    contacts=undefined;
    activeTab='Account';
    isDelete = false;
    showModal = false;
    showButton = undefined;
    selectedRecordId=undefined;
    actionName=undefined;
    mapMarkers=undefined;

    field1=undefined;
    field2=undefined;
    field3=undefined;
    field4=undefined;
    field5=undefined;

    account_columns = [ { label: 'Name', fieldName: 'NameURL', type:'url', typeAttributes: {label: { fieldName: 'Name' },target: '_blank'} , sortable:true, cellAttributes: {iconName: 'utility:identity'}},
                        { label: 'Website', fieldName: 'Website', type: 'url', editable	:true , sortable:true, cellAttributes: {iconName: 'utility:world'}},
                        { label: 'Phone', fieldName: 'Phone', type: 'phone', editable:true , sortable:true, cellAttributes: {iconName: 'utility:call'}},
                        { label: 'Parent Account', fieldName: 'ParentURL', type:'url', typeAttributes: {label: { fieldName: 'ParentName' },target: '_blank'}, sortable:true, cellAttributes: {iconName: 'utility:user'}},
                        { label: 'Email', fieldName: 'Email__c', type:'email', editable	:true , sortable:true},
                        { type:'action',typeAttributes: { rowActions: [ { label: 'View', name: 'view', iconName:'utility:preview'},
                                                                        { label: 'Edit', name: 'edit', iconName:'utility:edit'},
                                                                        { label: 'Delete', name: 'delete', iconName:'utility:delete'},
                                                                        { label: 'Location', name: 'location', iconName:'utility:checkin'}]}}];
    
    contact_columns = [ { label: 'Name', fieldName: 'NameURL', type:'url', typeAttributes: {label: { fieldName: 'Name' },target: '_blank'} , sortable:true},
    { label: 'Title', fieldName: 'Title', editable:true , sortable:true},
    { label: 'Phone', fieldName: 'Phone', type: 'phone', editable:true , sortable:true},
    { label: 'Department', fieldName: 'Department', editable:true , sortable:true},
    { label: 'Email', fieldName: 'Email', type:'email', editable	:true , sortable:true},
    { type:'action',typeAttributes: { rowActions: [ { label: 'View', name: 'view', iconName:'utility:preview'},
                                                    { label: 'Edit', name: 'edit', iconName:'utility:edit'},
                                                    { label: 'Delete', name: 'delete', iconName:'utility:delete'}]}}];
    connectedCallback()
    {
        this.loadData();
    }

    //ACTIVE TAB
    handleTabChange(event)
    {
        this.activeTab = event.target.value;
    }
    
    //SORT
    handleSort(event)
    {
        this.isLoading = true;
        let fieldName = event.detail.fieldName ;
        let sortDirection = event.detail.sortDirection ;
        this.sortBy = fieldName ;
        this.sortDirection = sortDirection ;
        let sortResult = [];

        switch(this.activeTab)
        {
            case 'Account':
                sortResult = Object.assign([], this.accounts) ;
                break;
            case 'Contact':
                sortResult = Object.assign([], this.contacts) ;
                break;
            case 'Opportunity':
                //sortResult = Object.assign([], this.accounts) ;
                break;
        }

        if(fieldName == 'NameURL') fieldName = 'Name';
        if(fieldName == 'ParentURL') fieldName = 'ParentName';
        
        let sortedData = sortResult.sort( (a, b) => 
        {
            if(!b[fieldName]) return 2;
            if(a[fieldName] < b[fieldName]) return sortDirection === 'asc' ? -1 : 1 ;
            if(a[fieldName] > b[fieldName]) return sortDirection === 'asc' ? 1 : -1 ;
            return 0 ;
        });
        switch(this.activeTab)
        {
            case 'Account':
                this.accounts = sortedData;
                break;
            case 'Contact':
                this.contacts = sortedData;
                break;
            case '':
                //sortResult = Object.assign([], this.accounts) ;
                break;
        }
        this.isLoading = false;
    }

    //CLOSE MODEL
    closeContactModel(event)
    {
        this.showModal= false;
        this.isDelete = false;
    }

    //ROW ACTIONS
    handleRowActions(event)
    {
        this.actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('UN Row: '+JSON.stringify(row));
        this.selectedRecordId = row.Id;

        switch (this.actionName)
        {
            case 'view':
                this.showModal=true;
                this.getFormData();
                this.showButton=false;
                break;
            case 'edit':
                this.showModal=true;
                this.showButton=true;
                this.getFormData();
                break;
            case 'delete':  
                this.isDelete = true;
                break;
            case 'location':  
                this.showModal=true;
                this.showButton=false;
                this.accounts.forEach(ac=>{
                    if(ac.Id===this.selectedRecordId)
                    {
                        this.mapMarkers = [
                        {
                            location: {
                                City: ac.BillingCity,
                                Country: ac.BillingCountry,
                                PostalCode: ac.BillingPostalCode,
                                State: ac.BillingState,
                                Street: ac.BillingStreet
                            },
                    
                            value: this.selectedRecordId,
                    
                            icon: 'standard:account',
                            title: row.Name,
                            description: 'Bla Bla Bla',
                        }];
                    }
                });
                break;
        }
    }

    getFormData()
    {
        if(this.activeTab==='Account')
        {
            this.field1='Name';
            this.field2='Website';
            this.field3='Phone';
            this.field4='ParentId';
            this.field5='Email__c';
        }
        else if(this.activeTab==='Contact')
        {
            this.field1='Name';
            this.field2='Title';
            this.field3='Phone';
            this.field4='Email';
            this.field5='Department';
        }
    }

    //LOAD FORM
    loadForm(event)
    {
        if(this.actionName==='view')
        {
            this.enableDisableForm(true);
        }
        else
        {
            this.enableDisableForm(false);
        }
    }
    enableDisableForm(isDisabled)
    {
        this.template.querySelectorAll('lightning-input-field').forEach(item=>{item.disabled=isDisabled});
    }

    //DELETE
    handleDelete(event)
    {
        deleteRecord(this.selectedRecordId)
        .then(result=>{
            this.loadData();
            this.closeContactModel();
            this.showToast('Record deleted successfully','Record Deleted','success');
        })
        .catch(error=>{
            console.log('UN DeleteError',error);
        });
    }

    //SUCCESS
    handleSuccess(event)
    {
        const fields = event.detail.fields ;

        this.loadData();
        this.closeContactModel();
        //this.showToast('Record edited successfully','Record Editied','success');

        // const toast = new ShowToastEvent(
        // {
        //     title: 'Record Saved', 
        //     message: '{0} Record has been updated succesfully, related account is {1}', 
        //     messageData : 
        //     [
        //         {
        //             label : fields.Name.value,
        //             url : '/' + event.detail.id 
        //         },
        //         {
        //             label : 'Tern Edge',
        //             url : 'https://www.ternedge.com' 
        //         }
        //     ],
        //     variant: 'success',
        //     mode : 'sticky'
        // });
        // this.dispatchEvent(toast);
        let messageLinks = 
        {
            recordLink :{ label : fields.Name.value, url : '/' + event.detail.id }
        }
        this.showToastMessage( 'Record Saved', '{recordLink} Record has been updated succesfully', 'success', 'sticky', messageLinks) ;
    }
    //SAVE 
    handleSave(event)
    {
        this.isLoading = true;
        this.draftValues = event.detail.draftValues;
        const resultInputs = this.draftValues.map(ac=>
        {
            const fields = ac;
            return {fields};
        });
        console.log('Un resultInputs: '+JSON.stringify(resultInputs));  
        let promises = resultInputs.map(resultInput=> updateRecord(resultInput));

        Promise.all(promises)
        .then(result =>
        {
            this.loadData();
            let objectName = this.activeTab==='Account'? 'Accounts' : (this.activeTab==='Contact'? 'Contacts': 'Opportunities'); 
            this.showToast(objectName+' updated successfully', objectName+' Updated', 'success');
            this.draftValues = [];
        })
        .catch(error =>
        {
            console.log('Un Promise Error');  
        });
    }

    //LOAD RECORDS
    loadData(event)
    {
        this.loadAccounts();
        //this.loadContacts();
    }

    //LOAD ACCOUNTS
    loadAccounts(event)
    {
        this.isLoading = true;
        getAllAccounts()
        .then(result=>
        {
            this.accounts=result;
            this.accounts.forEach(account=>
            {
                account.ParentName = '' ;
                if(account.ParentId)
                {
                    account.ParentName = account.Parent.Name
                    account.ParentURL = '/'+account.ParentId;
                }
                account.NameURL = '/' + account.Id;
            });
            this.isLoading = false;
            console.log('Accounts = '+JSON.stringify(this.accounts));
        })
        .catch(error=>
        {
            this.isLoading = false;
            console.log('Error = '+ JSON.stringify(error));
        });
    }

    //LOAD CONTACTS
    loadContacts(event)
    {
        this.isLoading = true;
        getAllContacts()
        .then(result=>
        {
            this.contacts=result;
            this.contacts.forEach(contact=>
            {
                contact.NameURL = '/' + contact.Id;
            });
            this.isLoading = false;
            console.log('Contacts = '+JSON.stringify(this.contacts));
        })
        .catch(error=>
        {
            this.isLoading = false;
            console.log('Error = '+ JSON.stringify(error));
        });
    }

    //TOAST
    showToast(theMessage, theTitle, theVariant)
    {
        const toast = new ShowToastEvent({title: theTitle, message: theMessage,variant: theVariant});
        this.dispatchEvent(toast);
    }

    showToastMessage(theLabel, theMessage, theVariant, theMode, theMessageLinks)
    {
        Toast.show(
        {
            label: theLabel ,
            message: theMessage ,
            messageLinks: theMessageLinks,
            mode: theMode,
            variant: theVariant
        }, this);
    }
}