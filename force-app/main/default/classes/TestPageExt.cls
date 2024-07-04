public with sharing class TestPageExt
{
    public String pId {get; set;}
    public ProductDetail prdDetail {get; set;}
    public List<Account> accounts {get; set;}

    public Boolean nxtDisableBtn {get; set;}
    public Boolean backDisableBtn{get; set;}
    public Boolean bckToSrchBtn{get; set;}

    public Boolean searchProduct{get; set;}
    public Boolean productDetails{get; set;}
    public Boolean accountTable{get; set;}

    public TestPageExt()
    {
        this.nxtdisableBtn = true;
        this.backDisableBtn = true;
        this.bckToSrchBtn = false;

        this.productDetails = false;
        this.searchProduct = true;
        this.accountTable = false;

        this.accounts = new List<Account>();
    	this.prdDetail = new ProductDetail();
    }

    public void validateInput()
    {
        this.nxtDisableBtn = String.isBlank(pId);
    }

    //Enabling Product Search From Back to Search Product Button
    public void showSearchProduct()
    {
        this.nxtdisableBtn = false;
        this.backDisableBtn = true;
        this.bckToSrchBtn = false;

        this.productDetails = false;
        this.searchProduct = true;
        this.accountTable = false;
    }

    public void validateBackBtn()
    {
        //Comming back to Search Product Page Using Back Button From Product Detail Page
        if(this.nxtdisableBtn == false && this.backDisableBtn == false)
        {
            this.searchProduct = true;
            this.accountTable = false;
            this.productDetails = false;
            this.backDisableBtn = true;
        }

        //Comming back to Product Details Page Using Back Button From Account Table Page
        if(this.bckToSrchBtn == true)
        {
            this.nxtdisableBtn = false;
            this.backDisableBtn = false;
            this.bckToSrchBtn = false;

            this.productDetails = true;
            this.searchProduct = false;
            this.accountTable = false;
        }
    }

    public void getJSONProducts()
    {
    	if(String.isBlank(pId) || !pId.isNumeric())
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Valid Product Id!'));
    		return;
    	}
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint('https://dummyjson.com/products/'+pId);
        req.setMethod('GET');
        res = http.send(req);
        String resJSON = res.getBody()+'}';
        prdDetail = (ProductDetail) JSON.deserialize(resJSON, ProductDetail.class);
        this.accounts = [SELECT Name, Industry, AnnualRevenue, Phone FROM Account LIMIT 5];

        //Enabling Product Details 
        if(this.nxtdisableBtn == false && this.backDisableBtn == true && this.searchProduct==true )
        {
            this.nxtdisableBtn = false;
            this.backDisableBtn = false;
            this.bckToSrchBtn = false;

            this.productDetails = true;
            this.searchProduct = false;
            this.accountTable = false;
            return;
        }

        //Enabling Account Table and Back to Search Product Button
        if(this.nxtdisableBtn == false && this.backDisableBtn == false && this.productDetails==true )
        {
            this.nxtdisableBtn = true;
            this.backDisableBtn = false;
            this.bckToSrchBtn = true;

            this.productDetails = false;
            this.searchProduct = false;
            this.accountTable = true;
        }
    }

    public class ProductDetail
    {
        public String title {get; set;}
        public String description {get; set;}
        public Integer stock {get; set;}
        public Integer price {get; set;}
        public String brand {get; set;}
        public String category {get; set;}
    }
}