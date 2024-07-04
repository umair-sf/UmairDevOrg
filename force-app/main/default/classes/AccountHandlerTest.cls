@isTest
private class AccountHandlerTest
{
    static testMethod void testMethod1()
    {
        Account childAc = TestUtil.createAccount('Test1', true);
        TestUtil.createContact(childAc.Id, 'Test', true);

        Account parentAc = TestUtil.createAccount('Test2', true);
        childAc.ParentId = parentAc.Id;
        update childAc;
    }
}