import { LightningElement, api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

const documentFields = ['Document__c.Name','Document__c.File_Public_Link__c','Document__c.Is_File_Attached__c','Document__c.Is_Mandatory__c'];

export default class DocumentView extends LightningElement
{
    @api recordId = undefined;
    documents = undefined;
    iconName = undefined;
    selectedDocId = undefined;

    @wire(getRelatedListRecords, {parentRecordId: '$recordId', relatedListId: 'Documents__r', fields: documentFields})
    documentInfo(value)
    {
        const {data,error} = value;
        if(data)
        {
            this.documents = JSON.parse(JSON.stringify(data.records));
            console.log('UN Related Documents'+JSON.stringify(this.documents));
            
            this.documents.forEach(doc =>
            {
                doc.Icon = doc.fields.Is_File_Attached__c.value ? "utility:success" : "utility:warning";
                doc.ColorClass = doc.fields.Is_File_Attached__c.value ? "success" : (!doc.fields.Is_File_Attached__c.value && doc.fields.Is_Mandatory__c.value ? "required" : "optional");
                doc.Link = doc.fields.File_Public_Link__c.value? doc.fields.File_Public_Link__c.value :'/'+doc.id;
                doc.Name = doc.fields.Name.value;
            });
        }
        if(error)
        {
            console.log('Contact Wire Error: ',error);
        }
    }

    handleDocumentSelection(event)
    {
        this.selectedDocId = event.detail.name;
    }
}