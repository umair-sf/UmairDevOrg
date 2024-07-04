@isTest
private class EventAlertTest
{
    static testMethod void testMethod1()
    {
    	List<Conference__c> confs = new List<Conference__c>();
		Conference__c con = new Conference__c(Name='Test',Start_Date__c=Date.today()+1,Event_Link__c='Test');
		confs.add(con);
        insert confs;
        Attendees__c atend = new Attendees__c(Name='Test',Email__c='test@test.com');
        insert atend;
        Test.startTest();
	        EventAlert ea = new EventAlert();
	        Database.QueryLocator ql = ea.start(null);
			ea.execute(null);
			ea.execute(null,confs);
			ea.Finish(null);
        Test.stopTest();
    }
}