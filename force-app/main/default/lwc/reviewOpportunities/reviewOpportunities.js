import { LightningElement } from 'lwc';
import getOpportunities from '@salesforce/apex/AccountToContactExt.getOpportunities';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import getAllRelatedAccounts from '@salesforce/apex/AccountToContactExt.getAllRelatedAccounts';
import getAllProducts from '@salesforce/apex/AccountToContactExt.getAllProducts';
import {loadStyle} from 'lightning/platformResourceLoader'
import COLORS from '@salesforce/resourceUrl/COLORS'
export default class ReviewOpportunities extends LightningElement
{
    isLoading = false ;
    opportunities = undefined;
    accounts = undefined;
    selectedAccount = undefined;
    oppLineItems = undefined;
    draftValues = undefined; 
    selectedAccountId = undefined;
    selectedOpportunityId = undefined;
    selectedPriceBookId = undefined;
    selectedAccountOpprtunity = undefined;
    showAccountTable = true;
    showOpportunityTable = false;
    isCssLoaded = false;
    filterSelected = false;

    filteredOpps = undefined;
    owners = undefined;
    selectedOwners = undefined;
    leadSources = undefined;
    selectedLeadSources = undefined;
    selectedStageNames = undefined;
    stageNames = undefined;

    filteredProducts = undefined;
    productCodes = undefined;
    selectedProductCode = undefined;
    productFamilies = undefined;
    selectedProductFamilies = undefined;

    connectedCallback()
    {
        this.loadAccounts();
    }

    
    handleSelection(event)
    {
        this.selectedOwners = event.detail.value;
        this.handleFilter();
    }

    handleLeadSourceSelection(event)
    {
        this.selectedLeadSources = event.detail.value;
        this.handleFilter();
    }

    handleStageNameSelection(event)
    {
        this.selectedStageNames = event.detail.value;
        this.handleFilter();
    }

    handleProductFamilySelection(event)
    {
        this.selectedProductFamilies = event.detail.value;
        this.handleFilter();
    }

    handleProductCodeSelection(event)
    {
        this.selectedProductCode = event.detail.value;
        this.handleFilter();
    }

    handleFilter(event)
    {
        this.filteredOpps = this.opportunities;
        this.filteredProducts = this.oppLineItems;

        if(this.selectedProductFamilies && this.selectedProductFamilies.length > 0)
        {
            this.filteredProducts = this.filteredProducts.filter(prd =>
            {   
                return this.selectedProductFamilies.indexOf(prd.ProductFamily) > -1;
            });
        }

        if(this.selectedProductCode && this.selectedProductCode.length > 0)
        {
            this.filteredProducts = this.filteredProducts.filter(prd =>
            {   
                return this.selectedProductCode.indexOf(prd.ProductCode) > -1;
            });
        }

        if(this.selectedOwners && this.selectedOwners.length > 0)
        {
            this.filteredOpps = this.filteredOpps.filter(opp =>
            {   
                return this.selectedOwners.indexOf(opp.OwnerId) > -1;
            });
        }

        if(this.selectedLeadSources && this.selectedLeadSources.length > 0)
        {
            this.filteredOpps = this.filteredOpps.filter(opp =>
            {   
                return this.selectedLeadSources.indexOf(opp.LeadSource) > -1;
            });
        }

        if(this.selectedStageNames && this.selectedStageNames.length > 0)
        {
            this.filteredOpps = this.filteredOpps.filter(opp =>
            {   
                return this.selectedStageNames.indexOf(opp.StageName) > -1;
            });
        }
    }

    handleSort(filterList)
    {
        let fieldName = 'label' ;
        let sortResult = Object.assign([], filterList) ;
        
        let sortedData = sortResult.sort( (a, b) => 
        {
            if(!b[fieldName]) return 2;
            if(a[fieldName] < b[fieldName]) return  -1;
            if(a[fieldName] > b[fieldName]) return  1;
            return 0 ;
        });
    }

    showFilterPanel(event)
    {
        this.filterSelected = !this.filterSelected;
    }


    handleOpportunities(event)
    {
        this.showAccountTable = false;
        this.showOpportunityTable = true;

        this.selectedAccountId = event.detail.row.Id;
        this.selectedAccount = [event.detail.row];
        console.log(JSON.stringify('Selected Account Id: ' + this.selectedAccountId));
        this.loadOpportunities();
    }

    handleOppLineItems(event)
    {
        this.showOpportunityTable = false;

        this.selectedAccountOpprtunity = [event.detail.row];
        this.selectedOpportunityId = event.detail.row.Id;
        this.selectedPriceBookId = event.detail.row.Pricebook2Id;

        console.log(JSON.stringify(this.selectedOpportunityId));
        console.log('SELECTED OPP '+ JSON.stringify(event.detail.row));
        this.loadProducts();
    }

    handleSelectedAccountRowAction(event)
    {
        this.showAccountTable = true;
        this.selectedAccount = undefined;
        this.filteredOpps = undefined;
        this.filteredProducts = undefined;
        this.selectedAccountOpprtunity = undefined;
        this.showOpportunityTable = false;
    }

    handleSelectedAccountOppRowAction(event)
    {
        this.filteredProducts = undefined;
        this.selectedAccountOpprtunity = undefined;
        this.showOpportunityTable = true;
    }

    loadProducts()
    {
        this.owners = [];
        this.productCodes = [];
        this.selectedProductCode = [];
        this.productFamilies = [];
        this.selectedProductFamilies = [];

        getAllProducts({opportunityId:this.selectedOpportunityId, priceBookId:this.selectedPriceBookId})
        .then(result=>
        {
            this.oppLineItems = result.map(item=>
            {
                return {...item,'QuantityBackground':'datatable-editable'}
            });
            this.oppLineItems.forEach(prd =>
            {
                if(this.productCodes.findIndex(pc => pc.value == prd.ProductCode)== -1) this.productCodes.push({label:prd.ProductCode ,value: prd.ProductCode});
                if(this.productFamilies.findIndex(pf => pf.value == prd.ProductFamily)== -1) this.productFamilies.push({label:prd.ProductFamily ,value: prd.ProductFamily});
            });
            this.filteredProducts = this.oppLineItems;
            console.log('Fetched Products: '+ JSON.stringify(this.filteredProducts));
        })
        .catch(error=>
        {
            console.log('Error = '+ JSON.stringify(error));
        });
    }

    loadAccounts()
    {
        getAllRelatedAccounts()
        .then(result=>
        {
            this.accounts = result;
            console.log('this.accounts = '+ JSON.stringify(this.accounts));
        })
        .catch(error=>
        {
            console.log('Error = '+ JSON.stringify(error));
        });
    }

    handleRefresh(event)
    {
        if(this.selectedAccountId) this.loadOpportunities();
        this.loadAccounts();
        if(this.selectedOpportunityId && this.selectedPriceBookId) this.loadProducts();
    }

    loadOpportunities()
    {
        this.isLoading = true ;
        this.owners = [];
        this.selectedOwners = [];
        this.leadSources = [];
        this.selectedLeadSources = [];
        this.stageNames = [];
        this.selectedStageNames = [];
        this.productCodes = [];

        getOpportunities({accountId : this.selectedAccountId})
        .then(result=>
        {
            this.opportunities = result;
            this.opportunities.forEach(opp=>
            {
                opp.AccountName = opp.Account.Name;
                opp.AccountPhone = opp.Account.Phone;
                opp.AccountEmail = opp.Account.Email__c;
                opp.OwnerName = opp.Owner.Name;
                if(this.owners.findIndex(ow => ow.value == opp.OwnerId)== -1) this.owners.push({label:opp.OwnerName ,value: opp.OwnerId});
                if(opp.LeadSource && this.leadSources.findIndex(ls => ls.value == opp.LeadSource)== -1) this.leadSources.push({label:opp.LeadSource ,value: opp.LeadSource});
                if(opp.StageName && this.stageNames.findIndex(sn => sn.value == opp.StageName)== -1) this.stageNames.push({label:opp.StageName ,value: opp.StageName});
            });
            this.filteredOpps = this.opportunities;
            this.owners = handleSort(this.owners);
            this.isLoading = false;
            console.log('Fetched Opps: '+ JSON.stringify(this.filteredOpps));
        })
        .catch(error=>
        {
            this.isLoading = false ;
            console.log('Error = '+ JSON.stringify(error));
        });
    }

    handleCancelAction(event)
    {
        this.draftValues = [];
    }

    handleBackAction(event)
    {
        if(this.showAccountTable===false && this.showOpportunityTable===true) this.handleSelectedAccountRowAction();
        if(this.showAccountTable===false && this.showOpportunityTable===false) this.handleSelectedAccountOppRowAction();
    }

    handleSave(event)
    {
        this.isLoading = true ;
        this.draftValues = event.detail.draftValues;
        const resultInputs = this.draftValues.map(prd=>
        {
            let unitPrice = this.oppLineItems.find(oli=>oli.PriceBookEntryId === prd.PriceBookEntryId).UnitPrice;
            let opportunityLineItem = {
                
                Id : this.oppLineItems.find(oli=>oli.PriceBookEntryId === prd.PriceBookEntryId).OliId,
                OpportunityId : this.selectedOpportunityId,
                PricebookEntryId : prd.PriceBookEntryId,
                Quantity : prd.Quantity, //3
                TotalPrice : unitPrice * prd.Quantity,
            };
            const fields = opportunityLineItem;
            return fields;
        });

        let promises = resultInputs.map(fields=>
        {
            if(fields.Id)
            {
                delete fields.OpportunityId;
                delete fields.PricebookEntryId;
                delete fields.TotalPrice;
                console.log('UN Fields: '+JSON.stringify({fields}));
                updateRecord({fields});
            }
            else
            {
                delete fields.Id;
                createRecord({apiName:'OpportunityLineItem', fields});
            }
        });

        Promise.all(promises)
        .then(result =>
        {
            this.draftValues = [];
            this.isLoading = false ;
            setTimeout(()=>
            {
                this.loadProducts();
            }
            ,1000);
            })
        .catch(error =>
        {
            this.isLoading = false ;
        });
    }

    account_columns = [ { label: 'Name', fieldName: 'Name', type:'button', typeAttributes: { label: { fieldName: 'Name' }, variant:'base'}},
                        { label: 'Email', fieldName: 'Email__c', type:'email'},
                        { label: 'Website', fieldName: 'Website'},
                        { label: 'Industry', fieldName: 'Industry'}];

    opportunity_columns = [ { label: 'Name', fieldName: 'Name', type:'button', typeAttributes: { label: { fieldName: 'Name' }, variant:'base'}},
                            { label: 'Stage Name', fieldName: 'StageName'},
                            { label: 'Lead Source', fieldName: 'LeadSource'},
                            { label: 'Close Date', fieldName: 'CloseDate',type:'date'},
                            { label: 'Amount', fieldName: 'Amount',type:'currency'}];

    account_opportunity_columns = [ { label: 'Account Name', fieldName: 'AccountName', type:'button', typeAttributes: { label: { fieldName: 'Name' }, variant:'base'}},
                                    { label: 'Account Email', fieldName: 'AccountEmail',type:'email'},
                                    { label: 'Account Phone', fieldName: 'AccountPhone',type:'Phone'},
                                    { label: 'Name', fieldName: 'Name', type:'button', typeAttributes: { label: { fieldName: 'Name' }, variant:'base'}},
                                    { label: 'Stage Name', fieldName: 'StageName'},
                                    { label: 'Close Date', fieldName: 'CloseDate',type:'date'}];

    oppLineItem_columns = [ { label: 'Name', fieldName: 'Name'},
                            { label: 'Product Code', fieldName: 'ProductCode'},
                            { label: 'Product Family', fieldName: 'ProductFamily'},
                            { label: 'Quantity', fieldName: 'Quantity', editable:true, type:'number', cellAttributes: {class: {fieldName: 'QuantityBackground'}}},
                            { label: 'Unit Price', fieldName: 'UnitPrice',type:'currency'},
                            { label: 'Total Price', fieldName: 'TotalPrice',type:'currency'}];
    
    renderedCallback()
    { 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }

}