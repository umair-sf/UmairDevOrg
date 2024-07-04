public with sharing class AccountClonerExt
{
	public String accId {get; set;}

    public AccountClonerExt(ApexPages.StandardController sc)
    {
        this.accId = sc.getId();
    }

    public PageReference accountClonerWithChildren()
    {
    	Account cloneAcc = new Account();

        try
        {
            Account acc = [SELECT Name, Phone, (select FirstName, LastName, AccountId from contacts), (select Name, StageName, AccountId, CloseDate from Opportunities ), (select Subject, AccountId, Status from WorkOrders) FROM Account WHERE Id = :accId];
            acc.name = acc.Name+' Clone';
            cloneAcc = acc.clone(false,true,false,false);
            insert cloneAcc;

            List<Contact> dupContacts = new List<Contact>();
            for(Contact con : acc.Contacts)
            {
                con.AccountId = cloneAcc.Id;
                Contact newCon = con.clone(false,true,false,false);
                dupContacts.add(newCon);
            }

            List<Opportunity> dupOpportunities = new List<Opportunity>();
            for(Opportunity opp : acc.Opportunities)
            {
                opp.AccountId = cloneAcc.Id;
                Opportunity newOpp = opp.clone(false,true,false,false);
                dupOpportunities.add(newOpp);
            }

            List<WorkOrder> dupWorkOrders = new List<WorkOrder>();
            for(WorkOrder workOrder : acc.WorkOrders)
            {
                workOrder.AccountId = cloneAcc.Id;
                WorkOrder newWorkOrder = workOrder.clone(false,true,false,false);
                dupWorkOrders.add(newWorkOrder);
            }

            if(dupContacts.size()>0) insert dupContacts;
            if(dupOpportunities.size()>0) insert dupOpportunities;
            if(dupWorkOrders.size()>0) insert dupWorkOrders;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
            return null;
        }

    	return new PageReference('/'+cloneAcc.Id);
    }
}