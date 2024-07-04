public with sharing class RelatedInterviewGetterExt
{
	public String jobAppId {get; set;}
	private List<Interview__c> relatedInterviews;
    public RelatedInterviewGetterExt()
    {
    }
    public List<Interview__c> getInterviews()
    {
        this.relatedInterviews = [SELECT Id, Name, Interview_Date__c, Interviewer__c, Interview_Rating__c, Interview_Status__c, Comments__c
        						  FROM Interview__c WHERE Job_Applications__c = :this.jobAppId];
    	return relatedInterviews;
    }
}