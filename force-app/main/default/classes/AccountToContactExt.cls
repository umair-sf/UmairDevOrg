public with sharing class AccountToContactExt
{
    @AuraEnabled
    public static List<Contact> getAccountContacts(String accountId)
    {
        return [SELECT Id, Name, Email, Title, Phone, Department FROM Contact WHERE AccountId =:accountId];
    }
    @AuraEnabled
    public static List<Contact> getAllContacts()
    {
        return [SELECT Id, Name, Email, Title, Phone, Department FROM Contact LIMIT 100];
    }
    @AuraEnabled
    public static List<Account> getAllAccounts()
    {
        return [SELECT Name, Email__c, Parent.Name, Phone, Website,BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account ORDER BY Name NULLS LAST LIMIT 100];
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunities( String accountId )
    {
        return [SELECT Id, Name, Amount, Type, Owner.Name, LeadSource, OwnerId, AccountId, Account.Name, Account.Phone, Account.Email__c,
                StageName, CloseDate, Pricebook2Id FROM Opportunity WHERE AccountId =: accountId];
    }

    @AuraEnabled
    public static List<Product> getAllProducts(String opportunityId, String priceBookId)
    {
        List<Product> allProducts = new List<Product>();
        Set<String> productIds = new Set<String>();
        
        List<OpportunityLineItem> oppLineItems = [SELECT Id, Family__c, Name, Quantity, UnitPrice, ProductCode,PricebookEntryId, TotalPrice, Product2Id FROM OpportunityLineItem WHERE OpportunityId =:opportunityId];
        for(OpportunityLineItem oli : oppLineItems)
        {
            Product prd = new Product();
            prd.OliId = oli.Id;
            prd.Id = oli.Product2Id;
            prd.Name = oli.Name;
            prd.ProductFamily = oli.Family__c ;
            prd.ProductCode = oli.ProductCode;
            prd.Quantity = oli.Quantity;
            prd.PriceBookEntryId = oli.PricebookEntryId;
            prd.UnitPrice = oli.UnitPrice;
            prd.TotalPrice = oli.TotalPrice;
            allProducts.add(prd);
            productIds.add(oli.Product2Id);
        }

        for(Product2 product : [SELECT Id, Name, ProductCode, Family , (select Id,UnitPrice from PricebookEntries where Pricebook2Id =:priceBookId) FROM Product2 WHERE Id NOT IN :productIds ])
        {
            for(PricebookEntry pbe : product.PricebookEntries)
            {
                Product prd = new Product();
                prd.Id = product.Id;
                prd.Name = product.Name;
                prd.ProductFamily = product.Family ;
                prd.ProductCode = product.ProductCode;
                prd.Quantity = 0;
                prd.PriceBookEntryId = pbe.Id;
                prd.UnitPrice = pbe.UnitPrice;
                allProducts.add(prd);
            }
        }
        
        System.debug('UN: allProducts size '+ allProducts.size() );
        System.debug('UN: allProducts '+ allProducts );

        return allProducts;
    }

    public class Product
    {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ProductCode;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public String PriceBookEntryId;
        @AuraEnabled public String ProductFamily;
        @AuraEnabled public String OliId;
        @AuraEnabled public Decimal TotalPrice;
    }

    @AuraEnabled
    public static List<Account> getAllRelatedAccounts()
    {
        Map<String,Account> accountMap = new Map<String,Account>();

        List<Opportunity> opps = [SELECT Id, Name, Amount, Type, AccountId,Account.Name,Account.Website,Account.Email__c, Account.Industry, StageName, CloseDate FROM Opportunity
                                    WHERE CloseDate >= NEXT_N_WEEKS:3 AND AccountId != NULL];
        for(Opportunity opp : opps)
        {
            Account ac = new Account();
            ac.Id = opp.AccountId;
            ac.Name = opp.Account.Name;
            ac.Website = opp.Account.Website;
            ac.Email__c = opp.Account.Email__c;
            ac.Industry = opp.Account.Industry;

            accountMap.put(opp.AccountId,ac);
        }
        System.debug('UN: '+accountMap.values());
        return accountMap.values();
    }
}