public with sharing class InterviewSchedulerExt_UAC
{
    public Integer totalRecords {get; set;}
    public Integer size {get;set;}
    public Integer gotoPage {get;set;}
    public String interviewId ;
    public Boolean showTable {get; set;}
    public Interview__c interviewToEdit {get; set;}

    public Decimal rating {get; set;}
    public String comments {get; set;}
    public List<SelectOption> interviewStatusOptions {get; set;}
    public String interviewStatus {get; set;}

    public List<Interview__c> Interviews{get; set;}

    public String query {get; set; }

    public PaginationWrapper pw 
    {
        get
        {
            if(pw == null)
            {
                pw = new PaginationWrapper();
                pw.ssc = this.ssc ;
            }
            System.debug('UAC: Interview PW records ' + pw.ssc.getRecords() );
            return pw ;
        }
        private set ;
    }

    public InterviewSchedulerExt_UAC()
    {
        this.gotoPage = 1;
        this.size = 2;
        this.showTable = true;
        this.Interviews = [SELECT Id, Interview_Date__c, Interviewer__c, Interview_Rating__c, Interview_Status__c, Comments__c FROM Interview__c WHERE Interview_Status__c='Scheduled'];
        this.interviewStatusOptions = new List<SelectOption>();
        interviewStatusOptions.add(new SelectOption ('Completed','Completed'));
        interviewStatusOptions.add(new SelectOption ('Pending','Pending'));
        interviewStatusOptions.add(new SelectOption ('Scheduled','Scheduled'));

        this.query = 'SELECT Id, Interview_Date__c, Interviewer__c, Interview_Rating__c, Interview_Status__c, Comments__c FROM Interview__c WHERE Interview_Status__c=\'Scheduled\'' ;
    }

    public String getInterviewId()
    {
        return this.interviewId ;
    }

    public void setInterviewId(String value)
    {
        this.interviewId = value ;
        System.debug('UAC: interviewId ' +this.interviewId );
    }

    public ApexPages.StandardSetController ssc
    {
        get
        {
            if(ssc==null)
            {
                String searchQuery=' SELECT Id, Interview_Date__c, Interviewer__c, Interview_Rating__c, Interview_Status__c, Comments__c FROM Interview__c WHERE Interview_Status__c=\'Scheduled\'' ;
                System.debug('UN searchQuery:'+searchQuery);
                ssc = new ApexPages.StandardSetController(Database.getQueryLocator(searchQuery));
                ssc.setPageSize(this.size);
                this.totalRecords = ssc.getResultSize(); 
            }
            return ssc;
        }
        set;
    }

    public List<SObject> getInterviews()
    {
        //List<SObject> interviews = [SELECT Id, Interview_Date__c, Interviewer__c, Interview_Rating__c, Interview_Status__c, Comments__c FROM Interview__c WHERE Interview_Status__c='Scheduled'];
        return ssc.getRecords();
    }

    public void edit()
    {
        this.showTable = false;
        //ssc=null; // Don't need to relead records from the database, the result which you have find your desired record as below
        
        for(Interview__c interview : (List<Interview__c>) ssc.getRecords())
        {
            if(interview.Id == this.interviewId )
            {
                this.interviewToEdit = interview ;
                this.comments = interview.Comments__c;
                this.rating = interview.Interview_Rating__c;
                this.interviewStatus= interview.Interview_Status__c;
            }
        }
    }

    public void save()
    {
        //update interviewToEdit;
        Interview_Edit_Event__e interviewEdit = new Interview_Edit_Event__e(Interview_Id__c=this.interviewId,Comments__c= this.comments, Interview_Rating__c=this.rating ,Status__c=this.interviewStatus);
        EventBus.publish(interviewEdit);

        this.showTable=true;
        ssc=null;
    }

    public PageReference cancel()
    {
        this.showTable=true;
        return null;
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
}