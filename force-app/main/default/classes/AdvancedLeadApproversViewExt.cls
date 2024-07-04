public with sharing class AdvancedLeadApproversViewExt
{
	public Integer totalRecords {get; set;}
	public Integer size {get;set;}
	public Integer gotoPage {get;set;}
	public Boolean isAllSelected {get;set;}
    public String searchKey {get;set;}
    public String laId {get; set;}
    public String sortByDirection {get; set;}
    private String sortByField;
    public String searchQuery{get; set;}

    public AdvancedLeadApproversViewExt()
    {
    	this.gotoPage = 1;
    	this.size = 10;
        this.sortByField = 'Name';
        this.sortByDirection = 'ASC';
        this.isAllSelected = false;
    }

    public ApexPages.StandardSetController ssc
    {
    	get
    	{
    		if(ssc==null)
    		{
                String fullSortStr = this.sortByField + ' ' + this.sortByDirection;
                this.searchQuery='    SELECT Id, Name, Approver1__c, Approver2__c, Approver4__c, Approver3__c, Approver5__c,'+
                                        ' From_Revenue__c, Lead_Source__c, To_Revenue__c, Rating__c From Lead_Approver__c ' ;
                
                // if(String.isNotBlank(searchKey))
                // {
                //     searchQuery +=  ' WHERE Name LIKE \'%'+ searchKey + '%\' OR Approver1__r.Name LIKE \'%'+ searchKey + '%\''+
                //                         ' OR Approver2__r.Name LIKE \'%'+ searchKey + '%\' OR Approver3__r.Name LIKE \'%'+ searchKey + '%\''+
                //                         ' OR Approver4__r.Name LIKE \'%'+ searchKey + '%\'OR Approver5__r.Name LIKE \'%'+ searchKey + '%\'' ;
                // }
                // if(String.isNotBlank(searchKey) && searchKey.isNumeric())
                // {
                // 	Integer rev = Integer.valueOf(searchKey);
                //     searchQuery +=  'OR From_Revenue__c ='+rev+' OR To_Revenue__c ='+rev ;
                // }

                if(String.isNotBlank(searchKey))
                {
                    searchQuery +=  ' WHERE Search_String__c LIKE \'%'+ searchKey + '%\'';
                }

                searchQuery += ' ORDER BY '+ fullSortStr +' NULLS LAST';

    			ssc = new ApexPages.StandardSetController(Database.getQueryLocator(searchQuery));
    			ssc.setPageSize(this.size);
    			this.totalRecords = ssc.getResultSize(); 
    		}
    		return ssc;
    	}
    	set;
    }

    public void newRage()
    {
    	ssc.setPageSize(size);
    	this.gotoPage = 1;
    }

    // Setting Page Number in set Controller from InputText
    public void gotoPage()
    {
    	Integer pageLimit = math.round(decimal.valueOf(this.totalRecords)/decimal.valueOf(this.size));
    	Integer remainder = math.mod(this.totalRecords,this.size);
    	if(remainder < 50) pageLimit+=1;

    	If(this.gotoPage > pageLimit)
    	{
    		this.gotoPage = pageLimit;
    		ssc.setpageNumber(pageLimit);
    	}
    	else
    	{
    		ssc.setpageNumber(this.gotoPage);
    	}
    }

    // Method to call set Controller for data
    public void search()
    {
        ssc= null;
    }

    // Method to load fresh records from set Controller
    public void clear()
    {
        this.searchKey = '';
        ssc = null ;
    }

    // call standard record edit page and return back to custom VF page
    public PageReference edit()
    {
		return new PageReference('/'+this.laId+'/e?retURL=/apex/AdvancedLeadApproversView?sfdc.tabName={!$CurrentPage.parameters.sfdc.tabName}');
	}

	// Delete records whoes Id is passed by delete commandlink 
	public void deleteRecord()
    {
    	delete [SELECT Id FROM Lead_Approver__c WHERE Id =:this.laId];
    	this.sortByField = 'Name';
        this.sortByDirection = 'ASC';
        ssc = null ;    	
	}

	//getter for the sorting colomn
	public String getsortByField()
    {
        return sortByField;
    }

    // setter which is setting direction of sort and sorting colomn field
    public void setsortByField(String userInput)
    {
        if(userInput != this.sortByField) this.sortByDirection = 'ASC';
        this.sortByField = userInput;
        this.sortByDirection = this.sortByDirection == 'DESC' ? 'ASC' : 'DESC';
    }

    // LeadApprovers getter which is initiating LeadApprInfo Wrapper Class
    public List<LeadApprInfo> getLeadApprovers()
    {   
        List<LeadApprInfo> leadApprovers = new List<LeadApprInfo>();

        for(Lead_Approver__c la : (List<Lead_Approver__c>) ssc.getRecords() )
        {
            LeadApprInfo lai = new LeadApprInfo();
            lai.isSelected = this.isAllSelected;
            lai.la = la;
            leadApprovers.add(lai);
        }
        return leadApprovers ;
    }

    public class LeadApprInfo
    {
        public Boolean isSelected {get;set;}
        public Lead_Approver__c la {get;set;}
    }
}