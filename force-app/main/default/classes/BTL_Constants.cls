/**
 * @File Name          : BTL_Constants.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 26/2/2020, 12:01:40 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    18/1/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class BTL_Constants{

    //Lead Interest Type
    public static final String general_Enquiry = 'General Enquiry';
    public static final String lease_Enquiry = 'Lease Enquiry';
    
    //Lead Status
    public static final String converted = 'Converted';
    public static final String closed = 'Closed';
    public static final String working = 'Working';
    public static final String verification = 'Verified';
    public static final String qualified = 'Qualified';

    //Enquiry Status
    public static final String enquiryClosed = 'Closed';
    public static final String enquiryOpen = 'Open';
    
    //Lead Manual Status
    public static final String qualified_Manual = 'Qualified';
    public static final String closed_Manual = 'Closed';
    
    //Lead Status Reason
    public static final String non_Responsive_Lead = 'Non Responsive Lead';
    public static final String autoClose = 'Auto Non-Responsive Closure';
    public static final String generalEnquiry  = 'General Enquiry';
    public static final String openLead = 'Open';
    public static final String inProgress = 'In Progress';

    //Lead Source
    public static final String website = 'Website';
    public static final String walk_Ins = 'Walk Ins';
    public static final String call_Centre = 'Call Centre';

    //Lead Type
    public static final String individual = 'Individual';
    public static final String corporate = 'Corporate';
    public static final String business = 'Business';

    //Lead Rating
    public static final String super_Hot = 'Super Hot';
    public static final String hot = 'Hot';
    public static final String warm = 'Warm';
    public static final String cold = 'Cold';
    
    //Queue
    public static final String call_Center = 'Call Center';
    
    //Event Status
    public static final String open = 'Open';
    public static final String Contacted = 'Contacted';
    public static final String contactedFollowUp = 'Contacted and needs follow-up';
    public static final String non_Responsive = 'Non-Responsive';
    public static final String not_Required = 'Not Required';

    //Event Subject
    public static final String call = 'Call';
    public static final String leadCall = 'Contact Lead';
    
    //Event Type
    public static final String meeting = 'Meeting';

    //Event Call Number
    public static final String fisrtCall = 'First Call';
    public static final String firstFollowUpCall = 'First Follow-Up Call';
    public static final String secondFollowUpCall = 'Second Follow-Up Call';
    public static final String thirdFollowUpCall = 'Third Follow-Up Call';

    //Offering Status
    public static final String offered = 'Offered';
    public static final String interestedInViewing = 'Interested in Viewing';
    public static final String finalized = 'Finalized';
    public static final String sentBooking = 'Sent For Booking';
    public static final String offeringCancelled = 'Booking Cancelled';
    public static final String offeringContracted = 'Sent For Contracting';
    public static final String offeringClosedWon = 'Closed Won';
    public static final String offeringClosedLost = 'Closed Lost';



    //Opportunity stagename
    public static final String qualification = 'Qualification';
    public static final String readyForViewing = 'Ready For Viewing';
    public static final String viewingScheduled = 'Viewing Scheduled';
    public static final String viewingCompleted = 'Viewing Completed';
    public static final String waitlisted= 'Waitlisted';
    public static final String readyForBooking = 'Ready For Booking';
    public static final String sentForBooking = 'Sent For Booking';
    public static final String bookingCancelledExpired = 'Booking Cancelled/Expired';
    public static final String sentForContracting = 'Sent For Contracting';
    public static final String closedLost = 'Closed Lost';
    public static final String closedWon = 'Closed Won';
    

    //Opportunity Reason for reassignment
    public static final String readyForScheduling = 'Customer ready for viewing within 7 days(Call Centre Only)';
    public static final String qualifiedLead = 'Qualified Lead (Call Center Only)';

    //Opportunity Reason for Closing
    public static final String custNotReachable = 'Customer Not reachable';

    //Days
    public static final String friday = 'Friday';
    public static final String saturday = 'Saturday';

    //Visit scheduling Status
    public static final String vs_open = 'Open';
    public static final String vs_nonResponsive = 'Non-Responsive';
    public static final String vs_closed = 'Closed';
    public static final String vs_working = 'Working';
    public static final String vs_visitClosed = 'Visited & Closed';

    //Visit Schedule Status Reason
    public static final String customerNotReachable = 'Customer not reachable';
    
    //Yardi Prebook API Mock Response
    public static final string YardiPreBookAPIResponse ='{"Prebook_UnitStatus": "Available"}';
    
    //Yardi Prebook API Mock Response
    public static final string YardiProspectInboundBook ='{"Prosp_Inbound_book": "Successfully Imported"}';    
    
    //Yardi Prebook API Mock Response
    public static final string CRMExtendBookingYardi = '{"CRMExtendBooking":{"ImportCustomTableResult":{"Status":"Success","Message": null}}}';
   
    public static final string YardiProspectInboundIssue = '{"Response": "Successfully Imported-t0014917"}';
    
    //Sobjects API Names
    public static final String UnitVisits = 'BTL_Unit_Visits__c';
    public static final String Offerings = 'BTL_Offerings__c';
    public static final String Opportunity = 'Opportunity';

    //Yardi API Success Messages
    public static final String UnitStatusAvailable = 'Available';
    public static final String ProspectingDone = 'Successfully Imported';

    //Tenant Information
    public static final String newLead = 'New Lead';
    public static final String returningLead = 'Returning Lead';
    public static final String existingTenant = 'Existing Tenant';
    public static final String returningTenant = 'Returning Tenant';
    
    //Template Names
    public static final String New_Lead_creation = 'New_Lead_creation_Communication_Custom';
    public static final String New_Returning_Lead = 'New_Returning_Lead_Custom';
    public static final String New_Returning_Lead_existing_tenant = 'New_Returning_Lead_existing_tenant_Custom';
    public static final String Intimate_Lead_Closure = 'Lead_closing_Custom';
    public static final String Intimate_Opp_Closure = 'Opportunity_closing_Custom';
    public static final String Automated_Availability_Details='BTL_Automated_availability_details';
    public static final String General_Enquiry_Closure='General_Enquiry_Closure_Custom';
    public static final String Unavailable_Bookings = 'BTL_Unavailable_Bookings';
    public static final String Returning_Opportunity = 'Returning_Opportunity_Custom';
    
    //Account Tenant
    public static final String tenant = 'Tenant';
    public static final String closed_lead = 'Closed Lead';
    public static final String Extenant = 'Ex-Tenant';
    public static final String lead = 'Active Lead';
    
    //Unit Category
    public static final String Villa='Villa';
    public static final String Apartment='Apartment';
    public static final String SupervisorRoom ='Supervisor Room';
    
    
    //Communication Trigger Point Object Names
    public static final String leadObj = 'Lead';
    public static final String leadNonRspnsv = 'Non Responsive Lead';
    public static final String OppNonRspnsv = 'Non Responsive Opportunity';
    public static final String newReturningLead = 'New Returning Lead';
    public static final String callBackRequest = 'Call Back Request';
    public static final String AppointmentReminder = 'Appointment Reminder';
    public static final String AppointmentConfirmation = 'Appointment Confirmation';    
    
    //Sender Display Name
    public static final String DAM = 'Dubai Asset Management';
    public static final String DAMcustomercare = 'customercare@dubaiam.ae';
    
    //Booking cancellation reason
    public static final String autoExpired = 'Auto expired';
    
    //Profile Name 
    public static final String call_Center_Profile = 'BTL Call Centre Profile';
    public static final String leasingAgentProfile = 'BTL Leasing Profile';
    public static final String adminProfile = 'System Administrator';
    public static final String integrationProfile = 'BTL Integration Users';
    public static final String retailProfile = 'Retail Profile'; //added by Nareg EI

    
    //Error Message
    public static final String error_Msg = 'You cannot create this lead, as there exists a blacklisted account with these credentials.';
    
    //Interest Record Types
    public static final Id leasingEnquiryId = Schema.SObjectType.BTL_Interests__c.getRecordTypeInfosByName().get('Leasing Enquiry').getRecordTypeId();
    public static final Id generalEnquiryId = Schema.SObjectType.BTL_Interests__c.getRecordTypeInfosByName().get('General Enquiry').getRecordTypeId();
    
    //Account Record Types
    public static final Id corpCustRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Account').getRecordTypeId(); 
   // public static final Id individRecordtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    
    //Account access Level
    public static final String Edit = 'Edit';
    public static final String TeamMemberManager = 'Account Manager';
    
    //Error Message
    public static final String reasonForReassign = 'You cannot select this value.';
    
    //Error Message
    public static final String leadReassignmentError = 'Some Leads cannot be updated due to data issue!!';
    public static final String oppReassignmentError = 'Some Opportunities cannot be updated due to data issue!!';
    
    //Unit Status
    public static final String unitBooked = 'Booked';
    public static final String unitLeased = 'Leased';
    
    public static final String unitAvailable = 'Available';
    
    //Unit Visits Status
    public static final String Viewed = 'Viewed';
    
    //Yardi Status Code
    public static final String opportunityWon = '2';
    public static final String opportunityLost = '3';
    
    //Booking Status Code
    public static final String bookingExpired = 'Expired';
    public static final String bookingCancelled = 'Cancelled';
    public static final String bookingSent = 'Sent For Booking';
    public static final String bookingContracting = 'Sent For Contracting'; 
    public static final String bookingWon = 'Closed Won'; 
    public static final String bookingLost = 'Closed Lost'; 
    
    
    //FirstContactType Code
    public static final String faceToFace= 'Face-to-Face';
    public static final String WalkIn= 'Walk-In';
    
    //Error message
    public static final String tenantTypeBlank = 'Please fill in Tenant Type';
    
    //String messages
    public static final String stageCancelled = 'stageCancelled';
    public static final String incorrectOfferings = 'incorrectOfferings';
    public static final String inputCheck = 'inputCheck';
    
    //Folder Name
    public static final String damCommunicationTemps = 'DAM Communication Templates';
    
    //From Email
     public static final String noReply = 'noreply@dubaiam.ae';
     
     //Account Record Types
     public static final String personAccount = 'Person Account';
     public static final String corpAccount = 'Corporate Account';
}