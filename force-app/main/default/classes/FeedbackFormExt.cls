public with sharing class FeedbackFormExt
{
	public Integer totalRecords {get; set;}
	public Integer size {get;set;}
	public Integer gotoPage {get;set;}
    public String feedbackId {get; set;}

    public FeedbackFormExt()
    {
    	this.gotoPage = 1;
    	this.size = 5;
    }

    public ApexPages.StandardSetController ssc
    {
    	get
    	{
    		if(ssc==null)
    		{
                String searchQuery='SELECT Id, Feedback_Date__c, Feedback_Giver__c, Feedback_Type__c, Feedback_Details__c, Feedback_Rating__c, Interview__c, Name FROM Feedback__c' ;

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

    public void gotoPage()
    {
    	Integer pageLimit = math.round(decimal.valueOf(this.totalRecords)/decimal.valueOf(this.size));
    	Integer remainder = math.mod(this.totalRecords,this.size);
    	if(remainder < 50) pageLimit+=1;

    	if(this.gotoPage > pageLimit)
    	{
    		this.gotoPage = pageLimit;
    		ssc.setPageNumber(pageLimit);
    	}
    	else
    	{
    		ssc.setPageNumber(this.gotoPage);
    	}
    }

    public PageReference edit()
    {
		return new PageReference('/'+this.feedbackId+'/e?retURL=/apex/FeedbackForm?sfdc.tabName={!$CurrentPage.parameters.sfdc.tabName}');
	}

    public List<Feedback__c> getFeedbacks()
    {   
        return (List<Feedback__c>) ssc.getRecords();
    }
}