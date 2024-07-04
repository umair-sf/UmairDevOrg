@isTest
private class AccountClonerExtTest
{
    static testMethod void testMethod1()
    {
        Account ac = TestUtil.createAccount('Test', true);
        TestUtil.createContact(ac.Id, 'Test', true);
        TestUtil.createOpportunity(ac.Id, 'Test', 'Prospect', date.today(), true);
        TestUtil.createWorkOrder(ac.Id, true, 'new', 'test');

        AccountClonerExt cont = new AccountClonerExt(new ApexPages.StandardController(ac));
        cont.accountClonerWithChildren();
    }
}