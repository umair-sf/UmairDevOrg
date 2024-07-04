@isTest
private class ParentChildTableExtTest
{
    static testMethod void testMethod1()
    {
        ParentChildTableExt cont = new ParentChildTableExt();
        Account ac = new Account(Name='Test', Phone='12345566', Website='https://www.test.com/'); 
        insert ac;
        Contact con = new Contact(FirstName='Test', LastName='Test', Email='test@test.com', Phone='1234567',AccountId=ac.Id);
        insert con;
        Case newCase = new Case(Status='New', Origin='Phone' ,ContactId =con.Id);
        insert newCase;
        cont.acId = ac.Id;
        cont.conId = con.Id;
        cont.getContacts();
        cont.getCases();
        cont.screenToDisplay();
        newCase = new Case();
        cont.screenToDisplay();
        con = new Contact();
        cont.screenToDisplay();
    }
}