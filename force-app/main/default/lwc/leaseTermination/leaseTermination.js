import { LightningElement, api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const oppFields = ['Opportunity.Id','Opportunity.Name','Opportunity.AccountId','Opportunity.Lease_Start_Date__c','Opportunity.Lease_End_Date__c','Opportunity.SyncedQuoteId'];
export default class LeaseTermination extends LightningElement
{
    @api recordId= undefined;
    @api isEditMode = undefined;
    opportunity= undefined;

    showModal(show)
    {
        this.isEditMode = show;
    }

    closeModel(event)
    {
        this.isEditMode = false ;
    }
    @wire(getRecord, {recordId:'$recordId', fields:oppFields})
    wiredOpportunity({error,data})
    {
        if(data)
        {
            this.opportunity = JSON.parse(JSON.stringify(data.fields));            
            // this.opportunity.forEach(opp =>
            // {
            //     opp.Id = opp.Id.value;
            //     opp.Name = opp.Name.value;
            //     opp.Lease_Start_Date__c = opp.Lease_Start_Date__c.value;
            //     opp.Lease_End_Date__c = opp.Lease_End_Date__c.value;
            //     opp.AccountId = opp.AccountId.value;
            //     opp.SyncedQuoteId = opp.SyncedQuoteId.value;
            // });
            console.log('Child Component Opportunity'+JSON.stringify(this.opportunity));
        }
        if(error){}
    }
}