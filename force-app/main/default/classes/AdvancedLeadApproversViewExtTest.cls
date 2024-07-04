@isTest
private class AdvancedLeadApproversViewExtTest
{
    static testMethod void testMethod1()
    {
    	Lead_Approver__c la = new Lead_Approver__c();
        la.To_Revenue__c = 50000;
        la.From_Revenue__c = 100000;
        la.Rating__c = 'Hot';
        la.Lead_Source__c= 'Web';

        insert la;

        AdvancedLeadApproversViewExt cont = new AdvancedLeadApproversViewExt();
        cont.laId = la.Id;
        cont.getLeadApprovers();
        cont.searchKey = 'test';
        cont.search();
        
        cont.gotoPage();
        cont.gotoPage=2;
        cont.gotoPage();
        cont.getsortByField();
        cont.setsortByField('To_Revenue__c');
        
        cont.newRage();
        cont.edit();
        cont.clear();
        cont.deleteRecord();


    }
}