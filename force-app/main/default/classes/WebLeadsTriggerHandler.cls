public with sharing class WebLeadsTriggerHandler
{
    public static void afterInsert(List<BTL_Web_Lead__c> newWebLeads)
    {
        Set<String> webLeadMobile = new Set<String>();
        Set<String> webLeadEmail = new Set<String>();
        Set<String> webLeadLastName = new Set<String>();
        Set<String> webLeadLeadType = new Set<String>();
        Set<String> acRecordTypeName = new Set<String>();
        
        List<Lead> leadsToInsert = new List<Lead>();
        List<BTL_Interests__c> enquiriesToInsert = new List<BTL_Interests__c>();

        Map<String,Lead> dupKeyToLead = new Map<String,Lead>();
        Map<String,Opportunity> dupKeyToOpp = new Map<String,Opportunity>();

        for(BTL_Web_Lead__c webLead : newWebLeads)
        {
        	if(String.isNotBlank(webLead.BTL_Mobile__c))
        	{
                String mobile = String.valueOf(webLead.BTL_Mobile__c.replaceAll('971','').replace('-', '').replace('+', '').replace('(', '').replace(')', '').replaceAll( '\\s+', ''));
        		webLeadMobile.add(mobile);
        	}
        	if(String.isNotBlank(webLead.BTL_Email__c))
        	{
        		webLeadEmail.add(webLead.BTL_Email__c);
        	}
        	if(String.isNotBlank(webLead.BTL_Last_Name__c))
        	{
        		webLeadLastName.add(webLead.BTL_Last_Name__c);
        	}
        	if(String.isNotBlank(webLead.BTL_Lead_Type__c))
        	{
        		webLeadLeadType.add(webLead.BTL_Lead_Type__c);
        		if(webLead.BTL_Lead_Type__c == 'Individual')
        		{
        			acRecordTypeName.add('Retail Account');
        		}
        		if(webLead.BTL_Lead_Type__c == 'Corporate')
        		{
        			acRecordTypeName.add('Corporate Account');
        		}
        	}
        }

        List<Lead> dupLeads = [SELECT Id, MobilePhone, Email, LastName, BTL_Lead_Type__c, LeadSource, OwnerId FROM Lead
        						WHERE (IsConverted = false AND BTL_Lead_Type__c IN : webLeadLeadType) AND
        						(MobilePhone IN :webLeadMobile OR Email IN :webLeadEmail OR LastName IN :webLeadLastName)];

        List<Opportunity> dupOpp = [SELECT Id, BTL_Mobile__c, BTL_Email__c, Account.Name, Account.Recordtype.Name, LeadSource, OwnerId FROM Opportunity
        								WHERE (IsClosed = false AND Account.Recordtype.Name IN :acRecordTypeName)
        								AND (Account.Name IN :webLeadLastName OR BTL_Mobile__c IN :webLeadMobile OR BTL_Email__c IN :webLeadEmail)];

       	for(Lead l : dupLeads)
       	{
       		String dupKey = (l.MobilePhone+ l.Email).replace('null','');
       		dupKeyToLead.put(dupKey, l);

            dupKey = (l.Email+ l.LastName.toUpperCase()).replace('null','');
            dupKeyToLead.put(dupKey, l);

            dupKey = (l.MobilePhone+ l.LastName.toUpperCase()).replace('null','');
            dupKeyToLead.put(dupKey, l);
       	}

       	for(Opportunity opp : dupOpp)
       	{
       		String dupKey = (opp.BTL_Mobile__c+ opp.BTL_Email__c).replace('null','');
            dupKeyToOpp.put(dupKey, opp);

            dupKey = (opp.BTL_Email__c+ opp.Account.Name.toUpperCase()).replace('null','');
            dupKeyToOpp.put(dupKey, opp);

            dupKey = (opp.BTL_Mobile__c+ opp.Account.Name.toUpperCase()).replace('null','');
            dupKeyToOpp.put(dupKey, opp);
       	}
        
        for(BTL_Web_Lead__c webLead : newWebLeads)
        {
            if(String.isBlank(webLead.BTL_Mobile__c)) continue;

            String mobile = String.valueOf(webLead.BTL_Mobile__c.replaceAll('971','').replace('-', '').replace('+', '').replace('(', '').replace(')', '').replaceAll( '\\s+', ''));
        	
            BTL_Interests__c enquiry = new BTL_Interests__c(BTL_Product_Category__c = webLead.BTL_Product_Category1__c, BTL_Bedroom__c = webLead.BTL_Bedroom1__c,
                                                            BTL_UTM_Campaign__c = webLead.BTL_UTM_Campaign__c, BTL_UTM_Medium__c = webLead.BTL_UTM_Medium__c,
                                                            BTL_UTM_Source__c = webLead.BTL_UTM_Source__c, BTL_Channel__c = webLead.BTL_Lead_Channel_Frontend__c,
                                                            BTL_Lead_Source__c = webLead.BTL_Lead_Channel__c, BTL_Sub_Channel__c = webLead.BTL_Sub_Channel__c, BTL_Web_Lead_Number__c = webLead.Name,
                                                            BTL_Enquiry_Details__c = webLead.BTL_Notes__c, BTL_Expected_Move_In_Date__c = webLead.BTL_Expected_Move_In_Date__c);

            enquiry.RecordTypeId = webLead.BTL_Enquiry_Type__c == BTL_Constants.lease_Enquiry? BTL_Constants.leasingEnquiryId : BTL_Constants.generalEnquiryId;
            enquiry.BTL_Maximum_Rent__c = String.isNotBlank(webLead.BTL_Desired_Budget__c)? Decimal.valueOf(webLead.BTL_Desired_Budget__c): null;
            enquiry.BTL_Project_Picklist__c = String.isNotBlank(webLead.BTL_Project1__c)? webLead.BTL_Project1__c : 'Not Specified';

            Lead ld = new Lead();
            Opportunity opp = new Opportunity();

            if(dupKeyToLead.containsKey((mobile+webLead.BTL_Email__c).replace('null','')))
            {
                ld = dupKeyToLead.get((mobile+webLead.BTL_Email__c).replace('null',''));
                enquiry.OwnerId = ld.OwnerId;
            }
            else if(dupKeyToLead.containsKey((webLead.BTL_Email__c+webLead.BTL_Last_Name__c.toUpperCase()).replace('null','')))
            {
                ld = dupKeyToLead.get((webLead.BTL_Email__c+webLead.BTL_Last_Name__c.toUpperCase()).replace('null',''));
                enquiry.OwnerId = ld.OwnerId;
            }
            else if(dupKeyToLead.containsKey((mobile+webLead.BTL_Email__c).replace('null','')))
            {
                ld = dupKeyToLead.get((mobile+webLead.BTL_Email__c).replace('null',''));
                enquiry.OwnerId = ld.OwnerId;
            }
            else if(dupKeyToOpp.containsKey((mobile+webLead.BTL_Email__c).replace('null','')))
            {
                opp = dupKeyToOpp.get((mobile+webLead.BTL_Email__c).replace('null',''));
                enquiry.OwnerId = opp.OwnerId;
            }
            else if(dupKeyToOpp.containsKey((webLead.BTL_Email__c+webLead.BTL_Last_Name__c.toUpperCase()).replace('null','')))
            {
                opp = dupKeyToOpp.get((webLead.BTL_Email__c+webLead.BTL_Last_Name__c.toUpperCase()).replace('null',''));
                enquiry.OwnerId = opp.OwnerId;
            }
            else if(dupKeyToOpp.containsKey((mobile+webLead.BTL_Email__c).replace('null','')))
            {
                opp = dupKeyToOpp.get((mobile+webLead.BTL_Email__c).replace('null',''));
                enquiry.OwnerId = opp.OwnerId;
            }
            else
            {
            	ld = new Lead(LastName = webLead.BTL_Last_Name__c, BTL_Eloqua_Rating_Grade__c = webLead.BTL_Eloqua_Lead_Rating__c,
                                  BTL_Site_Lead__c = webLead.BTL_Site_Lead__c, Email = webLead.BTL_Email__c);

                ld.Company = String.isNotBlank(webLead.BTL_Company__c)? webLead.BTL_Company__c : '[Not Specified]';
	            ld.LeadSource = String.isNotBlank(webLead.BTL_Lead_Source__c) ? webLead.BTL_Lead_Source__c : 'Website' ;

	            leadsToInsert.add(ld);
            }
            enquiry.BTL_Lead__c= ld.Id;
            enquiry.BTL_Opportunity__c= opp.Id;
            enquiriesToInsert.add(enquiry);
        }
        if(leadsToInsert.size()>0)
        {
            insert leadsToInsert;
            for(BTL_Interests__c enquiry : enquiriesToInsert)
            {
                for(Lead ld : leadsToInsert)
                {
                    enquiry.BTL_Lead__c = ld.Id;
                }
            }
        } 
        if(enquiriesToInsert.size()>0) insert enquiriesToInsert;
    }
}