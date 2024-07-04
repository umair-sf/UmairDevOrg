@isTest
private class TestPageExtTest
{
    static testMethod void testMethod1()
    {
        TestPageExt cont = new TestPageExt();
        cont.validateInput();
        cont.showSearchProduct();

        cont.pId = '1A' ;
        cont.getJSONProducts();
        cont.pId = '1' ;
        Test.setMock(HttpCalloutMock.class, new IntegrationMock() );
        cont.getJSONProducts();
        cont.nxtdisableBtn = false;
        cont.backDisableBtn = false;
        cont.productDetails = true;
        cont.getJSONProducts();

        cont.nxtdisableBtn = false;
        cont.backDisableBtn = false;
        cont.bckToSrchBtn = true;
        cont.validateBackBtn();

        TestpageExt.ProductDetail prdd = new TestpageExt.ProductDetail();
        prdd.title = 'String' ;
        prdd.description = '1244';
        prdd.price = 1244;
        prdd.brand = '1244';
        prdd.stock = 1244;
        prdd.category = '1244';
    }
}