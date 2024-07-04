public with sharing class LeadTableExt
{
	public List<Lead> leads {get; set;}
	public String leadId {get; set;}

    public String sortByDirection {get; set;}
    private String sortByField;

    public LeadTableExt()
    {
        this.sortByField = 'Name';
        this.sortByDirection = 'ASC';

        this.viewData();
    }

    public String getsortByField()
    {
        return sortByField;
    }

    public void setsortByField(String userInput)
    {
        if(userInput != this.sortByField) this.sortByDirection = null;
        this.sortByField = userInput;

        this.sortByDirection = this.sortByDirection == 'DESC' ? 'ASC' : 'DESC';
    }

    public void viewData()
    {
        

        String fullSortStr = this.sortByField + ' ' + this.sortByDirection;
        this.leads = Database.query('SELECT Id, Name, State, Status, Email, Company, CreatedDate, CreatedById, IsUnreadByOwner FROM Lead Order By '+fullSortStr+' NULLS LAST');
    }

    public PageReference edit()
    {
		return new PageReference('/'+this.leadId+'/e?retURL=/apex/LeadTable?sfdc.tabName={!$CurrentPage.parameters.sfdc.tabName}');
	}

	public PageReference deleteRecord()
    {
    	delete new Lead(id=this.leadId);
		return new PageReference('/apex/LeadTable?sfdc.tabName={!$CurrentPage.parameters.sfdc.tabName}');
	}
}