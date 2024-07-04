public with sharing class IntegrationQueueable implements Queueable, Database.AllowsCallouts
{
	public List<Id> recordIds = new List<Id>();
	public String methodName;

    public IntegrationQueueable(String methodName, List<Id> recordIds) 
    {
        System.debug('UAC: constructor of queuebale class ');
        this.recordIds = recordIds ;
        this.methodName = methodName;
    }

    public void execute(QueueableContext context) 
    {
    	switch on this.methodName
    	{
    		when 'Lead_Sender'
    		{
    			LeadTriggerHandler.sendLeadInfoToMohsinOrgFuture(recordIds);
    		}
    	}
    }
}