public with sharing class BookAppointmentExt
{
	public String specialization {get; set;}
    public String selectedTime {get; set;}
	public List<SelectOption> specializations {get; set;}

    public Time appTime{get;set;}
    public Time phyTime{get;set;}

    public List<String> timeslots {get; set;}
    public List<Physician__c> availablePhysicians{get; set;}
    public Appointment__c app {get; set;}
    public Id phyId{get; set;}

    public String startEventDt{get; set;}
    public String endEventDt{get; set;}
    public EventDetails eventDetails{get; set;}
    public Physician__c phy{get; set;}

    public BookAppointmentExt(ApexPages.StandardController sc)
    {
        specializations = new List<SelectOption>();
        for(Specialization__c spec : [SELECT Id, Name FROM Specialization__c])
        {
        	specializations.add(new SelectOption(spec.Name, spec.Name));
        }
        this.app = (Appointment__c)sc.getRecord();
        this.availablePhysicians = new List<Physician__c>();
        this.phy = new Physician__c();
    }
    public void selectedPhysicians()
    {
        Id specId = [SELECT Id FROM Specialization__c WHERE Name =:this.specialization].Id;
        this.availablePhysicians = [SELECT Id, Name FROM Physician__c WHERE 
                                    Id IN (select Physician__c from Physician_Specialist__c where Specialization__c = :specId)];
    }
    public void selectedTimeSlot()
    {
        this.appTime = Time.newInstance(Integer.valueof(selectedTime.substring(0,2)),Integer.valueof(selectedTime.substring(3,5)),0,0);

        Timezone phyTimezone = Timezone.getTimezone(phy.Physician_Timezone__c);
        Timezone appTimezone = Timezone.getTimezone(app.Timezone__c);

        Integer patientOffset = appTimezone.getOffset(app.Appointment_Date__c)/1000/60;
        Integer docOffset = phyTimezone.getOffset(app.Appointment_Date__c)/1000/60;
        Integer requiredOffset = docOffset-patientOffset;

        this.phyTime = this.appTime.addMinutes(requiredOffset);

        this.startEventDt = String.valueOf(this.app.Appointment_Date__c)+'T'+String.valueOf(this.phyTime);
        this.endEventDt = String.valueOf(this.app.Appointment_Date__c)+'T'+String.valueOf(this.phyTime.addMinutes(30));
    }

    public void timeSlotsMaker()
    {
        this.timeslots = new List<String>();
        this.phy = [SELECT Id,Start_Hours__c, Start_Minutes__c, Start_Meridiem__c,
                        End_Hours__c,End_Minutes__c, End_Meridiam__c,
                        Email__c, Physician_Timezone__c, Name, Access_Token__c
                        FROM Physician__c WHERE Id =: this.phyId];

        Timezone phyTimezone = Timezone.getTimezone(phy.Physician_Timezone__c);
        Timezone appTimezone = Timezone.getTimezone(app.Timezone__c);

        Integer patientOffset = appTimezone.getOffset(app.Appointment_Date__c)/1000/60;
        Integer docOffset = phyTimezone.getOffset(app.Appointment_Date__c)/1000/60;
        Integer requiredOffset = docOffset-patientOffset;

        Integer startHour = Integer.valueof(phy.Start_Hours__c);
        Integer startMin = Integer.valueof(phy.Start_Minutes__c)-requiredOffset;
        if(phy.Start_Meridiem__c == 'PM')
        {
            startHour = startHour +12;
        }

        Integer endHour = Integer.valueof(phy.End_Hours__c);
        Integer endMin = Integer.valueof(phy.End_Minutes__c)-requiredOffset;
        if(phy.End_Meridiam__c == 'PM')
        {
            endHour = endHour +12;
        }
        // Set<String> existingTimeSlots = new Set<String>();
        // for(Appointment__c app : [SELECT Id,Existing_Appointment__c FROM Appointment__c WHERE Physician__c =: phyId])
        // {
        //     existingTimeSlots.add(app.Existing_Appointment__c); //date + timeslot 
        // }
        Time startTm = Time.newInstance(startHour,startMin,0,0);
        Time endTm = Time.newInstance(endHour,endMin,0,0);
        Decimal opHours = ((endHour + (decimal.valueof(endMin)/60))-(startHour + (decimal.valueof(startMin)/60)))*60/30;

        for(Integer i=0 ; i<opHours; i++)
        {
            Integer minAdd = i*30;
            Integer maxAdd = (i+1)*30;
            String secTime = (i == (Integer.valueof(opHours)))? String.valueof(endTm) : String.valueof(startTm.addMinutes(maxAdd));
            String finalSlot = String.valueof(startTm.addMinutes(minAdd))+'-'+secTime;
            finalSlot = finalSlot.replace(':00.000Z', '');
            timeslots.add(finalSlot);
            // String newSlot = String.valueof(app.Appointment_Date__c)+finalSlot;
            // if(!existingTimeSlots.contains(newSlot))
            // {
            //     timeslots.add(newSlot);
            // }
        }
    }

    public PageReference createEvent()
    {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Appointment__c newApp = new Appointment__c();

        Http h = new Http();
        String reqBody = '{"end":{"dateTime":"'+this.endEventDt+'",'+
                            '"timeZone":""},'+
                            '"start":{"dateTime":"'+this.startEventDt+'",'+
                            '"timeZone":""},'+
                            '"attendees":[{"email":"'+this.app.Email__c+'","displayName":"'+this.app.Name+'"}],'+
                            '"description":"Appointment with '+this.app.Name+'",'+
                            '"location":"",'+
                            '"summary":"From Medical Clinic","colorId":"7"}';
        System.debug('UN: Request Body='+reqBody);
        req.setMethod('POST');
        req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+phy.Email__c+'/events');
        req.setBody(reqBody);
        req.setHeader('Content-Length', String.valueOf(reqBody.length()));
        req.setHeader('Content-Type', 'text/plain');
        req.setHeader('Authorization', 'Bearer '+''+this.phy.Access_Token__c+'');
        res = h.send(req);
        System.debug('UN: Response Body='+res.getBody());
        if(res.getStatusCode()==200)
        {
            this.eventDetails = (EventDetails)JSON.deserialize(res.getBody(), EventDetails.class);
            newApp.Age__c = this.app.Age__c;
            newApp.Specialization__c = [SELECT Id FROM Specialization__c WHERE Name =:this.specialization].Id;
            newApp.Name = this.app.Name;
            newApp.Email__c = this.app.Email__c;
            newApp.Physician__c = this.phyId;
            newApp.Gender__c = this.app.Gender__c;
            newApp.Timezone__c = this.app.Timezone__c;
            newApp.Doctor_Appointment_Date__c = Datetime.newInstance(this.app.Appointment_Date__c, this.phyTime);
            newApp.Patient_Appointment_Date__c = Datetime.newInstance(this.app.Appointment_Date__c, this.appTime);
            newApp.Phone__c = this.app.Phone__c;
            newApp.Google_Event_ID__c = this.eventDetails.id;
            newApp.Google_Event_URL__c = this.eventDetails.htmlLink;
            insert newApp;
            return new PageReference('/'+newApp.Id);
        }
        return null;
    }
    public Class EventDetails
    {
        public String id{get; set;}
        public String htmlLink{get; set;}
    }
}