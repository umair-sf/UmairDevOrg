public with sharing class TablePaginationExt
{
	public Integer totalRecords {get; set;}
	public Integer size {get;set;}
	public Integer gotoPage {get;set;}
	//public String dynamicSearchQuery {get; set;}
	public List<Interview__c> listofRecords{get; set;}
	public String formId {get; set;}
    public PaginationWrapper pw {get; set; }
    public Boolean displayPagination {get; set; }
    public String records_query {get; set; }
    public List<String> fields {get; set; }

    public ApexPages.StandardSetController ssc
    {
        get
        {
            if(ssc==null)
            {
                parseFields();
                ssc = new ApexPages.StandardSetController(Database.getQueryLocator(records_query));
                ssc.setPageSize(this.size);
                this.totalRecords = ssc.getResultSize(); 
            }
            return ssc;
        }
        set;
    } 

    public List<SObject> getRecords()
    {
        return ssc.getRecords();
    }

    public TablePaginationExt()
    {
        this.fields = new List<String>();
        this.gotoPage = 1;
    	this.size = 2;
    }

    private void parseFields()
    {
        //String thirecords_query = ' SELECT Id, Interview_Date__c, Interviewer__c, Interview_Rating__c, Interview_Status__c, Comments__c FROM Interview__c WHERE Interview_Status__c=\'Scheduled\'' ;
        String fields_query = this.records_query.trim().subString(6) ;
        fields_query = fields_query.left(fields_query.indexOfIgnoreCase('FROM')-1).trim() ;
        System.debug(fields_query);
        this.fields = fields_query.split(',');
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
}