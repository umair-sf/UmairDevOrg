import { LightningElement, api } from 'lwc';
import Ternedgelogo from '@salesforce/resourceUrl/Ternedgelogo';

export default class TernEdgeLoader extends LightningElement 
{
    logoURL = Ternedgelogo ;
    
    connectedCallback()
    {
        //console.log('UAC: logoURL ', Ternedgelogo );
    }
}