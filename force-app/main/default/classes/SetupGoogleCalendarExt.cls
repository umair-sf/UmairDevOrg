public with sharing class SetupGoogleCalendarExt
{
    public String authCode {get; set;}

    public String phyId{get; set;}
    public List<Physician__c> phy{get; set;}
    public GetToken tokens {get; set;}

    public String key {get; set;}
    public String secret {get; set;}
    public String email {get; set;}
    public String state {get;set;}

    public Boolean disableBtn{get; set;}

    public SetupGoogleCalendarExt(ApexPages.StandardController sc)
    {
    	this.disableBtn = String.isBlank(sc.getId());
    	this.authCode = Apexpages.currentpage().getparameters().get('code');
    	this.phyId = String.isNotBlank(sc.getId())? sc.getId() : Apexpages.currentpage().getparameters().get('state');
    	if(String.isNotBlank(this.authCode))
    	{
    		this.disableBtn = true;
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Authorized Successfully!' ));
    	}
    	this.phy = [SELECT Id, Client_Id__c, Client_Secret__c, Access_Token__c, Authorization_Code__c, Email__c FROM Physician__c WHERE Id =: this.phyId];
    	for(Physician__c physician : this.phy)
    	{
    		this.key = physician.Client_Id__c;
        	this.secret = physician.Client_Secret__c;
        	this.email = physician.Email__c;
    	}
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
    }

    public void getAccessToken()
    {
    	if(String.isBlank(this.key)|| String.isBlank(this.key))
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Populate Client Id & Client Secret!' ));
    		return;
    	}
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
        String redirect_uri;
        User loggedinUser = [SELECT Id, ContactId FROM User WHERE Id =: Userinfo.getUserId()];
        if(String.isNotBlank(loggedinUser.ContactId))
        {
            redirect_uri = baseUrl+'/terndoctor/apex/SetupGoogleCalendar';
        }
        else
        {
            redirect_uri = baseUrl+'/apex/SetupGoogleCalendar';
        }
        //string redirect_uri = 'https://umairtern-dev-ed--c.develop.vf.force.com/apex/SetupGoogleCalendar';
        String scope='https://www.googleapis.com/auth/calendar.events';
        String tokenUrl='https://oauth2.googleapis.com/token';
    
        this.key = EncodingUtil.urlEncode(this.key,'UTF-8');
        redirect_uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        System.debug('redirect_uri =' + redirect_uri);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse response = new HttpResponse();

        req.setMethod('POST');
        req.setEndpoint(tokenUrl);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        String messageBody = 'code='+this.authCode+
            '&client_id='+this.key+
            '&client_secret='+secret+
            '&redirect_uri='+redirect_uri+
            '&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        
        response = http.send(req);
        System.debug('UN: Response: '+response.getBody());
        this.tokens = (GetToken) JSON.deserialize(response.getBody(), GetToken.class);
        if(response.getStatusCode()==200)
        {
        	for(Physician__c physician : this.phy)
	    	{
	    		physician.Authorization_Code__c = this.authCode;
	    		physician.Access_Token__c = tokens.access_token;
	    		physician.Refresh_Token__c = tokens.refresh_token;
	    	}
	        update this.phy;
	        this.disableBtn = false;
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record Updated Successfully!' ));
        }
    }
    public PageReference getAuthCode()
    {
    	if(String.isBlank(this.key)|| String.isBlank(this.key))
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Populate Client Id & Client Secret!' ));
    		return null;
    	}
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
        String redirect_uri;
        User loggedinUser = [SELECT Id, ContactId FROM User WHERE Id =: Userinfo.getUserId()];
        if(String.isNotBlank(loggedinUser.ContactId))
        {
            redirect_uri = baseUrl+'/terndoctor/apex/SetupGoogleCalendar';
        }
        else
        {
            redirect_uri = baseUrl+'/apex/SetupGoogleCalendar';
        }
        
        String authUrl='https://accounts.google.com/o/oauth2/v2/auth';
        String scope='https://www.googleapis.com/auth/calendar.events';
    
        this.key = EncodingUtil.urlEncode(key,'UTF-8');
        redirect_uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        System.debug('redirect_uri =' + redirect_uri);
        String authuri = '';
        authuri = authUrl+'?'+
            'prompt=consent'+
            '&access_type=offline'+
            '&client_id='+this.key+
            '&response_type=code'+
            '&scope='+scope+
            '&redirect_uri='+redirect_uri+
            '&login_hint='+this.email+
			'&state='+this.phyId;
    	return new PageReference(authuri);
    }
    public PageReference back()
    {
    	return new PageReference('/'+this.phyId);
    }

    public class GetToken
    {
        public String access_token {get; set;}
        public String refresh_token {get; set;}
    }
}