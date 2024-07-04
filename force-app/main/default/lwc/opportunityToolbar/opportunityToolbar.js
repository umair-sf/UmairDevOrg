import { LightningElement, api } from 'lwc';

export default class opportunityToolbar extends LightningElement
{
    @api recordId = undefined;
    showModal=false;
    terminationForm(event)
    {
        this.showModal=!this.showModal;
        // this.template.querySelectorAll('c-lease-termination').showModal(true);
    }
}