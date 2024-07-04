/*=====================================================================
* Deloitte India
* Name:BTL_WebLeadsHelper
* Description: This class is a helper class and supports Webleads trigger for insert and update methods.
* Created Date: 14/07/2019
* Created by & for : Ashima - CRM-144
*
* Date Modified                Modified By                  Description of the update
* []                              []                             []
=====================================================================*/
public class BTL_WebLeadsHelper {
    /*---------------------------------------------------------
Method Name : insertLeadInterest
Created by & for : Ashima - CRM-144
Description : Created to create new interest as per the given conditions.
Reference: After Insert TriggerHandler
---------------------------------------------------------*/
    public static void insertLeadInterest1(map<Id,Lead> webLeadMp,List<BTL_Web_Lead__c> newList){
        List<BTL_Interests__c> lstInterests = new List<BTL_Interests__c>();
        for(BTL_Web_Lead__c objWebLead : newList){
            Lead ld=webLeadMp.get(objWebLead.Id);
            BTL_Interests__c objInterests = new BTL_Interests__c();
            if(objWebLead.BTL_Enquiry_Type__c == BTL_Constants.lease_Enquiry){
                objInterests.RecordTypeId = BTL_Constants.leasingEnquiryId;
            }
            else{
                objInterests.RecordTypeId = BTL_Constants.generalEnquiryId;
            }
            objInterests.BTL_Lead__c = ld.Id;
            if(objWebLead.BTL_Project1__c != null){
                objInterests.BTL_Project_Picklist__c = objWebLead.BTL_Project1__c;
            }
            else{
                objInterests.BTL_Project_Picklist__c = 'Not Specified';
            }
            objInterests.BTL_Product_Category__c = objWebLead.BTL_Product_Category1__c;
            objInterests.BTL_Bedroom__c = objWebLead.BTL_Bedroom1__c;
            objInterests.BTL_UTM_Campaign__c = objWebLead.BTL_UTM_Campaign__c;
            objInterests.BTL_UTM_Medium__c = objWebLead.BTL_UTM_Medium__c;
            objInterests.BTL_UTM_Source__c = objWebLead.BTL_UTM_Source__c;
            objInterests.BTL_Channel__c = objWebLead.BTL_Lead_Channel_Frontend__c;
            objInterests.BTL_Lead_Source__c = objWebLead.BTL_Lead_Channel__c;
            objInterests.BTL_Sub_Channel__c = objWebLead.BTL_Sub_Channel__c;
            objInterests.BTL_Web_Lead_Number__c = objWebLead.Name;
            objInterests.BTL_Enquiry_Details__c = objWebLead.BTL_Notes__c;
            //objInterests.CreatedDate = objWebLead.CreatedDate;
            objInterests.BTL_Expected_Move_In_Date__c = objWebLead.BTL_Expected_Move_In_Date__c;
            objInterests.OwnerId = Ld.ownerId;
            if(objWebLead.BTL_Desired_Budget__c != null){
                objInterests.BTL_Maximum_Rent__c = Decimal.valueOf(objWebLead.BTL_Desired_Budget__c);
            }
            lstInterests.add(objInterests);
        }
        if(!lstInterests.Isempty()){
            Insert lstInterests;
        }
    }
    /*---------------------------------------------------------
Method Name : insertOppInterest
Created by & for : Ashima - CRM-144
Description : Created to create new interest as per the given conditions.
Reference: After Insert TriggerHandler
---------------------------------------------------------*/
    public static void insertOppInterest1(map<Id,Opportunity>lstOppsMp,List<BTL_Web_Lead__c> newList){
        List<BTL_Interests__c> lstInterests = new List<BTL_Interests__c>();
        for(BTL_Web_Lead__c objWebLead : newList){
            Opportunity opp=lstOppsMp.get(objWebLead.Id);
            BTL_Interests__c objInterests = new BTL_Interests__c();
            if(objWebLead.BTL_Enquiry_Type__c == BTL_Constants.lease_Enquiry){
                objInterests.RecordTypeId = BTL_Constants.leasingEnquiryId;
            }
            else{
                objInterests.RecordTypeId = BTL_Constants.generalEnquiryId;
            }
            objInterests.BTL_Opportunity__c = opp.Id;
            if(objWebLead.BTL_Project1__c != null){
                objInterests.BTL_Project_Picklist__c = objWebLead.BTL_Project1__c;
            }
            else{
                objInterests.BTL_Project_Picklist__c = 'Not Specified';
            }
            objInterests.BTL_Product_Category__c = objWebLead.BTL_Product_Category1__c;
            objInterests.BTL_Bedroom__c = objWebLead.BTL_Bedroom1__c;
            objInterests.BTL_UTM_Campaign__c = objWebLead.BTL_UTM_Campaign__c;
            objInterests.BTL_UTM_Medium__c = objWebLead.BTL_UTM_Medium__c;
            objInterests.BTL_UTM_Source__c = objWebLead.BTL_UTM_Source__c;
            objInterests.BTL_Channel__c = objWebLead.BTL_Lead_Channel_Frontend__c;
            objInterests.BTL_Lead_Source__c = objWebLead.BTL_Lead_Channel__c;
            objInterests.BTL_Sub_Channel__c = objWebLead.BTL_Sub_Channel__c;
            objInterests.BTL_Enquiry_Details__c = objWebLead.BTL_Notes__c;
            objInterests.BTL_Web_Lead_Number__c = objWebLead.Name;
            //objInterests.CreatedDate = objWebLead.CreatedDate;
            objInterests.BTL_Expected_Move_In_Date__c = objWebLead.BTL_Expected_Move_In_Date__c;
            objInterests.OwnerId = opp.ownerId;
            if(objWebLead.BTL_Desired_Budget__c != null){
                objInterests.BTL_Maximum_Rent__c = Decimal.valueOf(objWebLead.BTL_Desired_Budget__c);
            }
            lstInterests.add(objInterests);
        }
        if(!lstInterests.Isempty()){
            Insert lstInterests;
        }
    }
    /*---------------------------------------------------------
Method Name : insertLead
Created by & for : Ashima - CRM-144
Description : Created to create new lead & interest as per the given conditions.
Reference: After Insert TriggerHandler
---------------------------------------------------------*/
    public static void insertLead(List<BTL_Web_Lead__c> newList){
        //List<BTL_APILogs__c> errorLogs = new List<BTL_APILogs__c>();
        String recordId;
        String propName = '';
        try{
            if(!newList.isEmpty()){
                List<BTL_Interests__c> lstInterests = new List<BTL_Interests__c>();
                Map<String,ID> mapPropertyNameId = new Map<String,ID>();
                Set<string> setProjNames = new Set<string>();
                List<Lead> lstLeads = new List<Lead>();
                for(BTL_Web_Lead__c objWebLead : newList){
                    recordId = objWebLead.id;
                    /*if(objWebLead.BTL_Property1__c != null){
propName = objWebLead.BTL_Property1__c;
}*/
                    Lead objLead = new Lead();
                    objLead.FirstName = objWebLead.BTL_First_Name__c;
                    objLead.LastName = objWebLead.BTL_Last_Name__c;
                    objLead.BTL_Eloqua_Rating_Grade__c = objWebLead.BTL_Eloqua_Lead_Rating__c;
                    objLead.BTL_Site_Lead__c = objWebLead.BTL_Site_Lead__c;
                    //objLead.CreatedDate = objWebLead.CreatedDate;
                    // if(String.valueOf(objWebLead.BTL_Mobile__c).contains('+971')){
                    //     objLead.BTL_Mobile_Format__c = 'United Arab Emirates (+971)';
                    //     String phone1 = String.valueOf(objWebLead.BTL_Mobile__c.substring(4,String.valueOf(objWebLead.BTL_Mobile__c).length()));
                    //     String phone = phone1.replace('-', '').replace('(', '').replace(')', '').replaceAll( '\\s+', '');
                    //     objLead.MobilePhone = phone;
                    // }
                    // else{
                    //     objLead.BTL_Mobile_Format__c = 'Others';
                    //     String phone = String.valueOf(objWebLead.BTL_Mobile__c.replace('-', '').replace('(', '').replace(')', '').replaceAll( '\\s+', ''));
                    //     objLead.MobilePhone = phone;
                    // }
                    objLead.Email = objWebLead.BTL_Email__c;
                    // objLead.BTL_Expected_Move_In_Date__c = objWebLead.BTL_Expected_Move_In_Date__c;
                    // objLead.BTL_Availability_Start_Date__c = objWebLead.BTL_Availability_Start_Date__c;
                    // objLead.BTL_Campaign_Name__c = objWebLead.BTL_Campaign_Name__c;
                    // objLead.BTL_First_Contact_Made__c = objWebLead.BTL_First_Contact_Made__c;
                    if(objWebLead.BTL_Lead_Source__c != null){
                        objLead.LeadSource = objWebLead.BTL_Lead_Source__c;
                    }
                    else{
                        objLead.LeadSource = 'Website';
                    }
                    // objLead.BTL_Lead_Channel__c = objWebLead.BTL_Lead_Channel__c;
                    // objLead.BTL_Lead_Channel_Frontend__c = objWebLead.BTL_Lead_Channel_Frontend__c;
                    // objLead.BTL_Sub_Channel__c = objWebLead.BTL_Sub_Channel__c;
                    // objLead.BTL_Auto_Coded_Source__c = objWebLead.BTL_Auto_Coded_Source__c;
                    // objLead.BTL_Lead_Type__c = objWebLead.BTL_Lead_Type__c;
                    // objLead.BTL_Nationality__c = objWebLead.BTL_Nationality__c;
                    // objLead.Salutation = objWebLead.BTL_Salutation__c;
                    // objLead.Company  = objWebLead.BTL_Company__c;
                    // objLead.Industry = objWebLead.BTL_Industry__c;
                    // objLead.NumberOfEmployees  = Integer.valueOf(objWebLead.BTL_No_of_Employees__c);
                    // objLead.BTL_Country_Code__c = objWebLead.BTL_Country_ISO_Code__c;
                    // objLead.Status = objWebLead.BTL_Status__c;
                    // objLead.BTL_DCM_Site__c = objWebLead.BTL_DCM_Site__c;
                    // objLead.BTL_Device_Category__c = objWebLead.BTL_Device_Category__c;
                    // objLead.BTL_Default_Channel_Grouping__c = objWebLead.BTL_Default_Channel_Grouping__c;
                    // objLead.Description = objWebLead.BTL_Notes__c;
                    // objLead.BTL_Plan_Type__c = objWebLead.BTL_Plan_Type__c;
                    // objLead.BTL_DCM_Placement__c = objWebLead.BTL_DCM_Placement__c;
                    // objLead.BTL_Tenant_Info__c = objWebLead.BTL_Tenant_Information__c;
                    // objLead.BTL_Event_ID__c = objWebLead.BTL_Event_ID__c;
                    // objLead.BTL_Preferred_Language__c = objWebLead.BTL_Preferred_Language__c;
                    // objLead.BTL_Residence__c = objWebLead.BTL_Residence__c;
                    // objLead.BTL_Source_Medium__c = objWebLead.BTL_Source_Medium__c;
                    // objLead.BTL_Website_Date__c = objWebLead.BTL_Website_Date__c;
                    // if(objWebLead.BTL_Project1__c != null){
                    //     objLead.BTL_Project__c = objWebLead.BTL_Project1__c;
                    // }
                    // else{
                    //     objLead.BTL_Project__c = 'Not Specified';
                    //     //objLead.BTL_Preferred_Community__c = 'our community';
                    // }
                    // objLead.BTL_Bedroom__c = objWebLead.BTL_Bedroom1__c;
                    // objLead.BTL_Product_Category__c= objWebLead.BTL_Product_Category1__c;
                    // objLead.BTL_Expected_Move_In_Date__c = objWebLead.BTL_Expected_Move_In_Date__c;
                    //objLead.BTL_Project__c = objWebLead.BTL_Project1__c;
                    // if(objWebLead.BTL_Project1__c != null){
                    //     setProjNames.add(objWebLead.BTL_Project1__c);
                    //     objLead.BTL_Preferred_Community__c = String.join(new List<String>(setProjNames), '/ ');
                    // }
                    // if(objWebLead.BTL_Enquiry_Type__c == BTL_Constants.lease_Enquiry){
                    //     objLead.BTL_Interest_Type__c = BTL_Constants.lease_Enquiry;
                    // }
                    // else{
                    //     objLead.BTL_Interest_Type__c = BTL_Constants.general_Enquiry;
                    // }
                    lstLeads.add(objLead);    
                }  
                if(!lstLeads.isEmpty()){
                    insert lstLeads;    
                }
                /*  if(propName != '' || propName != null){
lstProperty  = [select id,name,BTL_Yardi_Property_Code__c from BTL_Properties__c where name = :propName];
}
if(lstProperty.size()>0){
for(BTL_Web_Lead__c objWebLead : newList){
recordId = objWebLead.id;
for(BTL_Properties__c objProp : lstProperty){
if(objWebLead.BTL_Property1__c == objProp.name){
mapPropertyNameId.put(objWebLead.BTL_Property1__c, objProp.id);
}    
}
}
}*/
                for(BTL_Web_Lead__c objWebLead : newList){
                    for(Lead objLead : lstLeads){
                        if(objLead.Email == objWebLead.BTL_Email__c){
                            BTL_Interests__c objInt = new BTL_Interests__c();
                            if(objWebLead.BTL_Enquiry_Type__c == BTL_Constants.lease_Enquiry){
                                objInt.RecordTypeId = BTL_Constants.leasingEnquiryId;
                                objInt.BTL_Preference__c = true;
                            }
                            else{
                                objInt.RecordTypeId = BTL_Constants.generalEnquiryId;
                            }
                            objInt.BTL_Lead__c = objLead.id;
                            if(objWebLead.BTL_Project1__c != null){
                                objInt.BTL_Project_Picklist__c = objWebLead.BTL_Project1__c;
                            }
                            else{
                                objInt.BTL_Project_Picklist__c = 'Not Specified';
                            }
                            objInt.BTL_Product_Category__c = objWebLead.BTL_Product_Category1__c;
                            objInt.BTL_Bedroom__c = objWebLead.BTL_Bedroom1__c;
                            objInt.BTL_UTM_Campaign__c = objWebLead.BTL_UTM_Campaign__c;
                            objInt.BTL_UTM_Medium__c = objWebLead.BTL_UTM_Medium__c;
                            objInt.BTL_Channel__c = objWebLead.BTL_Lead_Channel_Frontend__c;
                            objInt.BTL_Sub_Channel__c = objWebLead.BTL_Sub_Channel__c;
                            objInt.BTL_Lead_Source__c = objWebLead.BTL_Lead_Channel__c;
                            objInt.BTL_UTM_Source__c = objWebLead.BTL_UTM_Source__c;
                            objInt.BTL_Enquiry_Details__c = objWebLead.BTL_Notes__c;
                            objInt.BTL_Web_Lead_Number__c = objWebLead.Name;
                            objInt.BTL_Expected_Move_In_Date__c = objWebLead.BTL_Expected_Move_In_Date__c;
                            //objInt.CreatedDate = objWebLead.CreatedDate;
                            if(objWebLead.BTL_Desired_Budget__c != null){
                                objInt.BTL_Maximum_Rent__c = Decimal.valueOf(objWebLead.BTL_Desired_Budget__c);
                            }
                            //objInt.BTL_Property__c = mapPropertyNameId.get(objWebLead.BTL_Property1__c);
                            lstInterests.add(objInt);
                        }
                    }
                }
                if(!lstInterests.isEmpty()){
                    insert lstInterests;
                }
            }
        }
        catch(Exception ex){
            
        }
    }
}