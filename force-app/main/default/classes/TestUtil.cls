@isTest
public class TestUtil 
{

    public static Account createAccount(String accountName, Boolean doInsert) 
    {
        Account ac = new Account(Name = accountName, Email__c = 'Test@test.com', Industry = 'Banking');
        
        if(doInsert) insert ac; 

        return ac ;
    }

    public static Contact createContact(Id accountId, String lastName, Boolean doInsert) 
    {
        Contact con = new Contact(LastName = lastName, AccountId = accountId, Phone ='234792749824');
        if(doInsert) insert con; 
        return con ;
    }

    public static Opportunity createOpportunity(Id accountId, String name, String stageName, Date closeDate, Boolean doInsert) 
    {
        Opportunity opp = new Opportunity(Name = name, AccountId = accountId, StageName =stageName, CloseDate= closeDate);
        if(doInsert) insert opp; 
        return opp ;
    }

    public static WorkOrder createWorkOrder(Id accountId, Boolean doInsert, String status, String subject) 
    {
        WorkOrder wo = new WorkOrder(AccountId = accountId, Status = status, Subject = subject);
        if(doInsert) insert wo; 
        return wo ;
    }

    public static Lead_Approver__c createLeadApprover(String leadSource, String rating, Decimal fromRevenue, Decimal toRevenue, Boolean doInsert)
    {
        Lead_Approver__c la = new Lead_Approver__c(Lead_Source__c = leadSource , Rating__c = rating, From_Revenue__c = fromRevenue,To_Revenue__c = toRevenue);
        if(doInsert) insert la ;
        return la ;
    }

    public static Lead createLead(String lastName, String company, String leadSource, String industry, Decimal annualRevenue, Boolean doInsert )
    {
        Lead l = new lead(LastName = lastName,Company = company,Status = 'Not Interested',Email = 'test@ternedge.com',
                            AnnualRevenue = annualRevenue,Industry = industry);

        if(doInsert) insert l;
        return l ;
    }
    public static Interview__c createInterview(String name, Boolean doInsert )
    {
        Interview__c interview = new Interview__c(Name = name,Interview_Date__c = date.today() ,Interviewer__c = UserInfo.getUserId(), Interview_Status__c = 'Scheduled' );

        if(doInsert) insert interview;
        return interview ;
    }
}