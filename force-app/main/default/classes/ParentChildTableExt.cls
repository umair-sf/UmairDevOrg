public with sharing class ParentChildTableExt
{
	public List<Account> accounts{get; set;}
	public List<Contact> contacts{get; set;}
	public List<Case> caseList {get; set;}

	public String acId {get; set;}
	public String conId {get; set;}

	public Boolean bckBtn {get; set;}

	public Contact relContact {get; set;}
	public List<Account> relAcc {get; set;}

    public ParentChildTableExt()
    {
    	this.conId = '';
    	this.acId = '';
    	this.accounts = [SELECT Id, Name, Phone, Website FROM Account];  

    	this.relAcc = new List<Account>();
    	this.relContact = new Contact();
    	
    	this.contacts = new List<Contact>();
    	this.caseList = new List<Case>();

    	this.bckBtn = false;
    }

    public PageReference getContacts()
    {
    	this.contacts = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId =: acId];
    	this.relAcc = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :acId];
    	this.bckBtn = true;
    	return null;
    }

    public PageReference getCases()
    {
    	this.caseList = [SELECT CaseNumber, Status, Origin FROM Case WHERE ContactId =: conId];
    	this.relContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id =: conId];
    	this.relAcc = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :acId];	
    	this.bckBtn = true;
    	return null;
    }

    public PageReference screenToDisplay()
    {
    	if(this.caseList.size()>0)
    	{
	    	this.bckBtn = true;
            this.caseList = new List<Case>();
	    	return null;
    	}
    	if(this.contacts.size()>0)
    	{
            this.contacts = new List<Contact>();
	    	this.bckBtn = false;
	    	return null;
    	}
        return null;
    }
}