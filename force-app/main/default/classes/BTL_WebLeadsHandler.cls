/*=====================================================================
* Deloitte India
* Name:BTL_WebLeadsHandler
* Description: This class is a handler class and supports Webleads trigger for insert and update methods.
* Created Date: 14/07/2019
*  Created by & for : Ashima - CRM-144
*
* Date Modified                Modified By                  Description of the update
* []                              []                             []
=====================================================================*/
public class BTL_WebLeadsHandler {
    /*---------------------------------------------------------
Method Name : afterInsert
Created by & for : Ashima - CRM-144
Description : Created to check if there is an exiting lead with same credentials after Insert.
Reference: After Insert Trigger
---------------------------------------------------------*/
    public static void afterInsert(List<BTL_Web_Lead__c> newList){
        Set<String> setMobile = new Set<String>();
        Set<String> setEmails = new Set<String>();
        Set<String> setLastName = new Set<String>();
        Set<String> setLeadType = new Set<String>();
        Set<String> setOppType = new Set<String>();
        Map<String,Lead> mapLeads = new  Map<String,Lead>();
        Map<String,Lead> mapLeads1 = new  Map<String,Lead>();
        Map<String,Lead> mapLeads2 = new  Map<String,Lead>();
        String email_Phn = '';
        String email_LastName = '';
        String LastName_Phn = '';
        String email_PhnOpp = '';
        String email_NameOpp = '';
        String Name_Phn = '';
        Map<String,Opportunity> mapOpps = new  Map<String,Opportunity>();
        Map<String,Opportunity> mapOpps1 = new  Map<String,Opportunity>();
        Map<String,Opportunity> mapOpps2 = new  Map<String,Opportunity>();
        List<BTL_Web_Lead__c> lstWebLeads = new List<BTL_Web_Lead__c>();
        List<BTL_Web_Lead__c> lstWebLeadsForOpp = new List<BTL_Web_Lead__c>();
        List<BTL_Web_Lead__c> lstWebLeadsUnique = new List<BTL_Web_Lead__c>();
        List<Lead> lstLeads = new List<Lead> ();
        for(BTL_Web_Lead__c objWebLead : newList){
            if(objWebLead.BTL_Mobile__c != null){
                String phone = String.valueOf(objWebLead.BTL_Mobile__c.replaceAll('971','').replace('-', '').replace('+', '').replace('(', '').replace(')', '').replaceAll( '\\s+', ''));
                setMobile.add(phone);
            }
            setEmails.add(objWebLead.BTL_Email__c);
            setLastName.add(objWebLead.BTL_Last_Name__c);
            setLeadType.add(objWebLead.BTL_Lead_Type__c);
            if(objWebLead.BTL_Lead_Type__c == BTL_Constants.individual || objWebLead.BTL_Lead_Type__c == BTL_Constants.business){
                setOppType.add('Person Account');
            }
            if(objWebLead.BTL_Lead_Type__c == 'Corporate'){
                setOppType.add('Corporate Account');
            }
        }
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstLeads = [select id,MobilePhone,Email,LastName,BTL_Lead_Type__c,LeadSource,OwnerId from Lead where (Status != : BTL_Constants.converted AND BTL_Lead_Type__c IN : setLeadType) AND (MobilePhone In : setMobile OR Email In : setEmails OR LastName In : setLastName)];
        //lstLeads = [select id,MobilePhone,Email,LastName,BTL_Lead_Type__c,LeadSource,OwnerId from Lead where (Status != : BTL_Constants.converted) AND ((MobilePhone In : setMobile AND Email In : setEmails AND BTL_Lead_Type__c IN : setLeadType) OR (Email In : setEmails AND LastName In : setLastName AND BTL_Lead_Type__c IN : setLeadType) OR  (MobilePhone In : setMobile AND LastName In : setLastName AND BTL_Lead_Type__c IN : setLeadType))];
        system.debug('ones:'+lstLeads );
        if(lstLeads.size()>0){
            for(Lead objLead :lstLeads){
                email_Phn = String.valueOf(objLead.Email) + String.valueOf(objLead.MobilePhone);
                email_LastName = String.valueOf(objLead.Email) + (String.valueOf(objLead.LastName).toUpperCase());
                LastName_Phn = (String.valueOf(objLead.LastName).toUpperCase()) + String.valueOf(objLead.MobilePhone);
                mapLeads.put(email_Phn,objLead);
                mapLeads1.put(email_LastName,objLead);
                mapLeads2.put(LastName_Phn,objLead);
            }
        }
        lstOpp = [select id,BTL_Mobile__c,BTL_Email__c,Account.Name,Account.Recordtype.name,OwnerId,LeadSource from Opportunity where (StageName != :BTL_Constants.closedLost AND StageName != : BTL_Constants.closedWon AND Account.recordtype.name IN : setOppType) AND (Account.Name In : setLastName OR BTL_Mobile__c In : setMobile OR BTL_Email__c In : setEmails)];
        if(lstOpp.size()>0){
            for(Opportunity Opp : lstOpp){
                email_PhnOpp = String.valueOf(Opp.BTL_Email__c) + String.valueOf(Opp.BTL_Mobile__c);
                mapOpps.put(email_PhnOpp,Opp);
                email_NameOpp = String.valueOf(Opp.BTL_Email__c) + (String.valueOf(Opp.Account.Name).toUpperCase());
                mapOpps1.put(email_NameOpp,Opp);
                Name_Phn = String.valueOf(Opp.BTL_Mobile__c) + (String.valueOf(Opp.Account.Name).toUpperCase());
                mapOpps2.put(Name_Phn,Opp);
            }
        }
        List<Opportunity> opp=new List<Opportunity>();
        map<Id,Lead> webLeadmp=new map<Id,Lead>();
        map<Id,Opportunity>oppmp=new map<Id,Opportunity>();
        for(BTL_Web_Lead__c objWebLead : newList){
            if(objWebLead.BTL_Mobile__c != null){
                String phone = String.valueOf(objWebLead.BTL_Mobile__c.replaceAll('971','').replace('-', '').replace('+', '').replace('(', '').replace(')', '').replaceAll( '\\s+', ''));
                if(mapLeads.containskey(objWebLead.BTL_Email__c + phone)){
                    lstWebLeads.add(objWebLead);
                    webLeadmp.put(objWebLead.Id,mapLeads.get(objWebLead.BTL_Email__c + phone));
                }
                else if(mapLeads1.containskey(objWebLead.BTL_Email__c + String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase())){
                    lstWebLeads.add(objWebLead);
                    webLeadmp.put(objWebLead.Id,mapLeads1.get(objWebLead.BTL_Email__c + String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase()));
                }
                else if(mapLeads2.containskey(String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase() + phone)){
                    lstWebLeads.add(objWebLead);
                    webLeadmp.put(objWebLead.Id,mapLeads2.get(String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase() + phone));
                }
                else if(mapOpps.containskey(objWebLead.BTL_Email__c + phone)){
                    lstWebLeadsForOpp.add(objWebLead);
                    opp.add(mapOpps.get(objWebLead.BTL_Email__c + phone));
                    oppmp.put(objWebLead.Id,mapOpps.get(objWebLead.BTL_Email__c + phone));
                }
                else if(mapOpps1.containskey(objWebLead.BTL_Email__c + String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase())){
                    lstWebLeadsForOpp.add(objWebLead);
                    opp.add(mapOpps1.get(objWebLead.BTL_Email__c + String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase()));
                    oppmp.put(objWebLead.Id,mapOpps1.get(objWebLead.BTL_Email__c + String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase()));
                }
                else if(mapOpps2.containskey(phone+String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase())){
                    lstWebLeadsForOpp.add(objWebLead);
                    opp.add(mapOpps2.get(phone+String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase()));
                    oppmp.put(objWebLead.Id,mapOpps2.get(phone+String.valueOf(objWebLead.BTL_Last_Name__c).toUpperCase()));
                }
                else{
                    lstWebLeadsUnique.add(objWebLead);
                }
            }
        }
        if(lstWebLeads.size()> 0){
            BTL_WebLeadsHelper.insertLeadInterest1(webLeadmp,lstWebLeads);
        }
        if(lstWebLeadsForOpp.size()> 0){
            BTL_WebLeadsHelper.insertOppInterest1(oppmp,lstWebLeadsForOpp);
        }
        if(lstWebLeadsUnique.size()> 0){
            BTL_WebLeadsHelper.insertLead(lstWebLeadsUnique);
        }
    }
}