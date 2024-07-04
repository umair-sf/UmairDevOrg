@isTest
private class BookAppointmentExtTest 
{
    static testMethod void testMethod1() 
    {
    	Physician__c phy = new Physician__c(Start_Hours__c='9', Start_Minutes__c='00', Start_Meridiem__c='AM',
                        End_Hours__c='5',End_Minutes__c='00', End_Meridiam__c='PM',
                        Email__c='test@test.com', Physician_Timezone__c='Asia/Karachi', Name='test', Access_Token__c='test');
    	insert phy;
    	Specialization__c sp = new Specialization__c(Name='Test');
    	insert sp;
    	Appointment__c app = new Appointment__c(Name='Test',Specialization__c=sp.Id,Physician__c=phy.Id,Timezone__c='Asia/Karachi',Appointment_Date__c=Date.today());
    	insert app;

    	Physician_Specialist__c ps = new Physician_Specialist__c(Physician__c=phy.Id, Specialization__c=sp.Id);
    	insert ps;
        BookAppointmentExt cont = new BookAppointmentExt(new ApexPages.StandardController(app));

        cont.selectedTime='09:00-10:00';
        cont.phyId = phy.Id;
        cont.specialization = sp.Name;
        cont.timeSlotsMaker();
        cont.selectedPhysicians();
        cont.selectedTimeSlot();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new IntegrationMock() );
        Test.stopTest();
        cont.createEvent();
    }
}