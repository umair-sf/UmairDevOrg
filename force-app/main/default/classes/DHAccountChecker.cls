/*
Batch Job Requirements:
1- Develop a batch job to check all your org’s accounts in DH system one by one, you have to use above
end point to call the web service by passing the DH Account ID in accountId parameter.

2- If you pass a blank account Id, it will return you random 1000 accounts, you have to find out matching
account based on Name, Business Park and License No, if found, then move that account and contact info to your org
and fill the DH_Account_Id__c. if multiple match found then use first one, if not found, ignore and move to next account.

3- If you find the matching account based on the DH Account ID then you have to check what field’s values are
different than your account and contact records, only update those records if you find any discrepancy in field’s data.

4- You may need to create some fields in your org which are included in the web service response, you have to
identify data type based on the response.

5- you need to send an email to me and yourself stating that how many accounts and contacts processed,
means how many accounts/contacts created or updated.
*/

global class DHAccountChecker implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful
{
    public String query;
    public Boolean accesstokenValidator;
    public Integer accUpdated;
    public Integer conUpdated;
    public Integer conInserted;

    global DHAccountChecker()
    {
        accUpdated =0;
        conUpdated =0;
        conInserted=0;
        accesstokenValidator= false;
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT LegalFramework__c,IsFortune500__c,CustomerClassification__c,BusinessParkName__c,AccountType__c,
                                            AccountStatus__c,VisaCategory__c,ProductType__c,LicenseExpiryDate__c,LicenseFirstIssueDate__c,
                                            LicenseIssueDate__c,LicenseNo__c,LicenseStatus__c,LicenseType__c,DH_Account_ID__c,Phone,Name,Id,
                                            (select Id,AccountId,PassportExpiryDate__c,PassportNo__c,PassportIssueDate__c,MobilePhone,Phone,
                                                Type__c,Role__c,Email,DH_Contact_ID__c,IsActive__c,FirstName,LastName from contacts)
                                            FROM Account WHERE Id='001Ho00001DXzaI']);
    }

    global void execute(SchedulableContext sd)
    {
        Database.executeBatch(new DHAccountChecker(), 1);
    }

    global void execute(Database.BatchableContext bc, List<Sobject> scope)
    {
        accesstokenValidator=false;
        List<Account> accounts = (List<Account>)scope;
        List<Account> accToUpdate = new List<Account>();
        List<Contact> conToInsert = new List<Contact>();
        List<Contact> conToUpdate = new List<Contact>();
        List<DHAccounts> accountsFromDH = new List<DHAccounts>();
        List<DHAccounts> dhAccToUpdate = new List<DHAccounts>();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        AccessToken at = new AccessToken();

        Map<String,List<Contact>> acIdToCons = new Map<String,List<Contact>>();
        Map<String,List<DHContact>> dhaccIdToDhcons = new Map<String,List<DHContact>>();

        DH_System__c dhConfig = [SELECT Username__c,Password__c,Client_Secret__c,Client_Id__c FROM DH_System__c LIMIT 1];

        if(accesstokenValidator==false)
        {
            req.setMethod('POST');
            req.setEndpoint('https://tecomgroup--terminator.sandbox.my.salesforce.com/services/oauth2/token?grant_type=password'+
                            '&client_id='+dhConfig.Client_Id__c+
                            '&client_secret='+dhConfig.Client_Secret__c+
                            '&username='+dhConfig.Username__c+'&password='+dhConfig.Password__c);
            res = h.send(req);
            at = (AccessToken)JSON.deserialize(res.getBody(),AccessToken.class);
            accesstokenValidator=true;
        }

        for(Account ac : accounts)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();

            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer '+at.access_token);
            
            
            List<DHAccounts> matchedAccounts = new List<DHAccounts>();

            if(String.isNotBlank(ac.DH_Account_ID__c))
            {
                for(Contact con : ac.Contacts)
                {
                    List<Contact> accTempList = acIdToCons.get(ac.DH_Account_ID__c);
                    if(accTempList==null)
                    {
                        accTempList = new List<Contact>();
                        acIdToCons.put(ac.DH_Account_ID__c, accTempList);
                    }
                    accTempList.add(con);
                }
            }

            //Fetching 1000 records for blank DH_Account_Id__c
            if(String.isBlank(ac.DH_Account_ID__c) && accountsFromDH.size()==0)
            {
                request.setEndpoint('https://tecomgroup--terminator.sandbox.my.salesforce.com/services/apexrest/accountsinfo?accountId=');
                response = http.send(request);
                accountsFromDH = (List<DHAccounts>)JSON.deserialize(response.getBody(),List<DHAccounts>.class);
            }

            //Fetching record based on DH_Account_Id__c
            if(String.isNotBlank(ac.DH_Account_ID__c))
            {
                request.setEndpoint('https://tecomgroup--terminator.sandbox.my.salesforce.com/services/apexrest/accountsinfo?accountId='+ac.DH_Account_ID__c);
                response = http.send(request);
                dhAccToUpdate = (List<DHAccounts>)JSON.deserialize(response.getBody(),List<DHAccounts>.class);
            }

            //Check for matching account based on Name, License No and Business Park
            if(String.isBlank(ac.DH_Account_ID__c) && accountsFromDH.size()>0 && dhAccToUpdate==null)
            {
                for(DHAccounts dhAcc : accountsFromDH)
                {
                    String name;
                    if(String.isNotBlank(dhAcc.Name)) name = dhAcc.Name.right(6);

                    if(ac.Name == dhAcc.Name.replace(name,'') && ac.BusinessParkName__c == dhAcc.BusinessParkName &&
                        (ac.LicenseNo__c.replace('null-','').replace('null','')) == (dhAcc.LicenseNo.replace('null-','').replace('null','')))
                    {
                        matchedAccounts.add(dhAcc);
                    }
                    if(matchedAccounts.size()>0) dhAccToUpdate.add(matchedAccounts.get(0));
                }
            }
            if(dhAccToUpdate.size()==0) continue;

            for(DHAccounts dhAcc : dhAccToUpdate)
            {
                for(DHContact dhCon : dhAcc.contacts)
                {
                    List<DHContact> dhAccTempList = dhaccIdToDhcons.get(dhAcc.Id);
                    if(dhAccTempList==null)
                    {
                        dhAccTempList = new List<DHContact>();
                        dhaccIdToDhcons.put(dhAcc.Id, dhAccTempList);
                    }
                    dhAccTempList.add(dhCon);
                }
                

                String name;
                if(String.isNotBlank(dhAcc.Name)) name = dhAcc.Name.right(6);

                //Condition will check if DH_Account_ID__c is null or if DH_Account_ID__c is not null then it will check for field's data difference
                if(String.isBlank(ac.DH_Account_ID__c)||(String.isNotBlank(ac.DH_Account_ID__c) && (ac.Name != dhAcc.Name.replace(name,'')||ac.BusinessParkName__c != dhAcc.BusinessParkName||
                    (ac.LicenseNo__c.replace('null-','').replace('null',''))!=( dhAcc.LicenseNo.replace('null-','').replace('null','')) ||
                    ac.LegalFramework__c != dhAcc.LegalFramework || ac.IsFortune500__c != dhAcc.IsFortune500 || ac.Phone != dhAcc.Phone ||
                    ac.CustomerClassification__c != dhAcc.CustomerClassification || ac.VisaCategory__c != dhAcc.VisaCategory || ac.DH_Account_ID__c != dhAcc.Id  ||
                    ac.AccountType__c != dhAcc.AccountType || ac.AccountStatus__c != dhAcc.AccountStatus || ac.LicenseFirstIssueDate__c != dhAcc.LicenseFirstIssueDate ||
                    ac.ProductType__c != dhAcc.ProductType ||ac.LicenseExpiryDate__c != dhAcc.LicenseExpiryDate || ac.LicenseIssueDate__c != dhAcc.LicenseIssueDate ||
                    ac.LicenseStatus__c != dhAcc.LicenseStatus || ac.LicenseType__c != dhAcc.LicenseType)))
                {
                    ac.LegalFramework__c = dhAcc.LegalFramework;
                    ac.IsFortune500__c = dhAcc.IsFortune500;
                    ac.CustomerClassification__c = dhAcc.CustomerClassification;
                    ac.BusinessParkName__c = dhAcc.BusinessParkName;
                    ac.AccountType__c = dhAcc.AccountType;
                    ac.AccountStatus__c = dhAcc.AccountStatus;
                    ac.VisaCategory__c = dhAcc.VisaCategory;
                    ac.ProductType__c = dhAcc.ProductType;
                    ac.LicenseExpiryDate__c = dhAcc.LicenseExpiryDate;
                    ac.LicenseFirstIssueDate__c = dhAcc.LicenseFirstIssueDate;
                    ac.LicenseIssueDate__c = dhAcc.LicenseIssueDate;
                    ac.LicenseNo__c = dhAcc.LicenseNo.replace('null-','').replace('null','');
                    ac.LicenseStatus__c = dhAcc.LicenseStatus;
                    ac.LicenseType__c = dhAcc.LicenseType;
                    ac.DH_Account_ID__c = dhAcc.Id;
                    ac.Phone = dhAcc.Phone;
                    ac.Name = dhAcc.Name.replace(name,'');
                    accToUpdate.add(ac);
                }
            }
        }
        Map<String,String> accIdtoDHaccId = new Map<String,String>();
        for(Account ac : [SELECT Id,DH_Account_ID__c FROM Account WHERE DH_Account_ID__c IN :dhaccIdToDhcons.keySet()])
        {
            accIdtoDHaccId.put(ac.DH_Account_ID__c,ac.Id);
        }

        for(DHAccounts dhAcc : dhAccToUpdate)
        {
            for(DHContact dhcon: dhaccIdToDhcons.get(dhAcc.Id))
            {
                String lName;
                if(String.isNotBlank(dhCon.LastName)) lName = dhCon.LastName.right(6);
                Contact con = new Contact();
                if(acIdToCons.containsKey(dhAcc.Id))
                {
                    for(Contact acCon: acIdToCons.get(dhAcc.Id))
                    {
                        if(acCon.DH_Contact_ID__c == dhCon.Id &&  acCon.PassportExpiryDate__c != dhCon.PassportExpiryDate || acCon.PassportNo__c != dhCon.PassportNo ||
                            acCon.PassportIssueDate__c != dhCon.PassportIssueDate || acCon.MobilePhone != dhCon.MobilePhone || acCon.Phone != dhCon.Phone ||
                            acCon.Type__c != dhCon.Type || acCon.Role__c != dhCon.Role || acCon.Email != dhCon.Email || acCon.IsActive__c != dhCon.IsActive ||
                            acCon.FirstName != dhCon.FirstName || acCon.LastName != dhCon.LastName.replace(lName,''))
                        {
                           con.Id = acCon.Id;
                        }
                    }
                }
                con.PassportExpiryDate__c = dhCon.PassportExpiryDate;
                con.PassportNo__c = dhCon.PassportNo;
                con.AccountId = accIdtoDHaccId.get(dhAcc.Id);
                con.PassportIssueDate__c = dhCon.PassportIssueDate;
                con.MobilePhone = dhCon.MobilePhone;
                con.Phone = dhCon.Phone;
                con.Type__c = dhCon.Type;
                con.Role__c = dhCon.Role;
                con.Email = dhCon.Email;
                con.DH_Contact_ID__c = dhCon.Id;
                con.IsActive__c = dhCon.IsActive;
                con.FirstName = dhCon.FirstName;
                con.LastName = dhCon.LastName.replace(lName,'');

                if(String.isBlank(con.Id))
                {
                    conToInsert.add(con);
                }
                if(String.isNotBlank(con.Id))
                {
                    conToUpdate.add(con);
                }
               
            }
        }
        
        accUpdated += accToUpdate.size();
        conUpdated += conToUpdate.size();
        conInserted += conToInsert.size();

        if(accToUpdate.size()>0) update accToUpdate;
        if(conToInsert.size()>0) insert conToInsert;
        if(conToUpdate.size()>0) update conToUpdate;
    }

    //Summary of records processed is sending in finish method. The code is commented because the permission is disabled in the org.
    //The code of sending email is working perfectly fine. I have checked it in Bilal's Org.
    global void finish(Database.BatchableContext bc)
    {
        System.debug('UN: accUpdated Sumamry '+accUpdated);
        System.debug('UN: conUpdated Sumamry '+conUpdated);
        System.debug('UN: conInserted Sumamry '+conInserted);
        // List<Messaging.Email> emailList = new List<Messaging.Email>();
        // List<String> toEmails = new List<String>();
        // toEmails.add('umairnisar2017@gmail.com');
        // toEmails.add('uxmn.ali@gmail.com');

        // Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        // emailMsg.setToAddresses(toEmails);

        // String emailSubject = 'Summary of Batch job for synchronizing Accounts with DH system';
        // emailMsg.setSubject(emailSubject);
        // String displayName = 'Summary from Umair Org';
        // emailMsg.setSenderDisplayName(displayName);

        // emailMsg.setHtmlBody('Batch job for synchronizing Accounts with DH system is finished. Below is the summary of records processed:'+'<br/>'+
        //     '<br/>Accounts Updated: '+accUpdated+
        //     '<br/>Contacts Updated: '+conUpdated+
        //     '<br/>Contacts Inserted: '+conInserted);
        // emailList.add(emailMsg);

        //Messaging.sendEmail(emailList);
    }

    public class AccessToken
    {
        String access_token;
    }

    public class DHAccounts
    {
        String VisaCategory;
        String ProductType;
        String Phone;
        String Name;
        String LicenseType;
        String LicenseStatus;
        String LicenseNo;
        Date LicenseIssueDate;
        Date LicenseFirstIssueDate;
        Date LicenseExpiryDate;
        String LegalFramework;
        Boolean IsFortune500;
        String Id;
        String CustomerClassification;
        List<DHContact> contacts;
        String BusinessParkName;
        String AccountType;
        String AccountStatus;
    }

    public class DHContact
    {
        String Type;
        String Role;
        String Phone;
        String PassportNo;
        Date PassportIssueDate;
        Date PassportExpiryDate;
        String MobilePhone;
        String LastName;
        Boolean IsActive;
        String Id;
        String FirstName;
        String Email;
    }
}