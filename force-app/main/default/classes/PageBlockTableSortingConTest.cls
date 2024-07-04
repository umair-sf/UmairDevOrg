@isTest
private class PageBlockTableSortingConTest
{
    static testMethod void testMethod1()
    {
    	Account ac = TestUtil.createAccount('Test', true);
        PageBlockTableSortingCon cont = new PageBlockTableSortingCon();
        cont.getSortDirection();
        cont.setSortDirection('ASC');
        cont.getAccounts();
        cont.viewData();
        cont.sortExpression = '';
        cont.getSortDirection();
        cont.sortExpression = '';
    }
}