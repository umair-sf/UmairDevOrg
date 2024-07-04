global class EventAlert implements Database.Batchable<sObject>, Schedulable
{
    public String query;

    global EventAlert()
    {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id, Name, Start_Date__c, Event_Link__c FROM Conference__c WHERE Start_Date__c = NEXT_N_DAYS:4]);
    }

    global void execute(SchedulableContext sd)
    {
        Database.executeBatch(new EventAlert());
    }

    global void execute(Database.BatchableContext bc, List<Sobject> scope)
    {
        List<Conference__c> conferences = (List<Conference__c>)scope;
        List<Attendees__c> attendees = [SELECT Name, Email__c FROM Attendees__c];
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        List<String> attendeeEmails = new List<String>();

        for(Attendees__c atend:attendees)
        {
            attendeeEmails.add(atend.Email__c);
        }

        for(Conference__c conf:conferences)
        {
            if(Date.today()+3==conf.Start_Date__c || Date.today()+2==conf.Start_Date__c || Date.today()+1==conf.Start_Date__c)
            {
                Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                emailMsg.setToAddresses(attendeeEmails);

                String emailSubject = 'New Salesforce event is about to happen!';
                emailMsg.setSubject(emailSubject);
                String displayName = 'Notification from Umair Org';
                emailMsg.setSenderDisplayName(displayName);
                String emailBody = 'Hi, '
                +'Hope you are doing good. Please RSVP for the upcomming Salesforce event using the below link.'
                +conf.Name+''
                +'Event Date: '+conf.Start_Date__c
                +'Registration Link: '+conf.Event_Link__c
                +'Regards,'
                +'Umair Nisar';
                emailMsg.setHtmlBody(emailBody);
                emailList.add(emailMsg);
            }
        }
        Messaging.sendEmail(emailList);
    }

    global void finish(Database.BatchableContext bc)
    {

    }
}