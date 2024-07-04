@isTest
private class LeadTableExtTest
{
    static testMethod void testMethod1()
    {
    	Lead ld = new Lead(LastName='Test',Company='Test',Email='test@test.com');
        insert ld;
        LeadTableExt cont = new LeadTableExt();
        cont.leadId = ld.Id;
        cont.setsortByField('Company');
        cont.getsortByField();

        cont.edit();
        cont.deleteRecord();

    }
}