public with sharing class TernFlyExt
{
	public List<SelectOption> originList{get;set;}
	public String selectedOrigin{get;set;}

	public List<SelectOption> destinationList;
	public String selectedDestination{get;set;}

	public List<SelectOption> tripTypes{get;set;}
	public String tripType{get;set;}

    public List<FlightInfo> availableFlights{get;set;}
	public String passangerQty{get; set;}

    public Date depDate{get;set;}
    public Date returnDate{get;set;}

    public TernFlyExt()
    {
        this.originList = new List<SelectOption>();
        this.tripTypes = new List<SelectOption>();
        
        this.tripType = 'One Way';
    	for( Airport__c ap : [SELECT Id, Name FROM Airport__c])
    	{
    		this.originList.add(new SelectOption(ap.Id,ap.Name));
            this.selectedOrigin=ap.Id;
    	}
    	
    	this.tripTypes.add(new SelectOption('One Way','One Way'));
    	this.tripTypes.add(new SelectOption('Return','Return'));
    }

    public List<SelectOption> getDestinationList()
    {
        this.destinationList = new List<SelectOption>();
        for( Airport_Flight__c ap : [SELECT Destination__c, Destination__r.Name FROM Airport_Flight__c WHERE Origin__c =: this.selectedOrigin])
        {
            this.destinationList.add(new SelectOption(ap.Destination__c,ap.Destination__r.Name));
        }
        return destinationList;
    }

    public void search()
    {
        this.availableFlights = new List<FlightInfo>();
        List<Airport_Flight__c> airportFlights = new List<Airport_Flight__c>();
    	if(!this.passangerQty.isNumeric())
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter valid No. of Passangers' ));
    		return;
    	}
        if(this.returnDate<Date.today() || this.depDate<Date.today())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter today\'s or future Date' ));
            return;
        }
        if(String.isNotBlank(String.valueOf(this.returnDate)) && this.tripType == 'Return')
        {
            airportFlights = [SELECT Id, Origin__r.Airport__c, Origin__r.Timezone__c, Destination__r.Timezone__c,
                                Destination__r.Airport__c, Flight__r.Operator__c, Duration_Hour__c, Duration_Minutes__c,
                                Departure_Date__c, Departure_Hour__c, Departure_Minutes__c, Economy_Class_Price__c,
                                Business_Class_Price__c, Currency__c FROM Airport_Flight__c
                                WHERE (Origin__c=:this.selectedOrigin OR Origin__c=:this.selectedDestination)
                                AND (Destination__c=:this.selectedDestination OR Destination__c=:this.selectedOrigin)
                                AND (Departure_Date__c=:this.depDate OR Departure_Date__c=:this.returnDate)];
        }
        else
        {
            airportFlights = [SELECT Id, Origin__r.Name, Origin__r.Airport__c, Origin__r.Timezone__c, Destination__r.Timezone__c,
                                Destination__r.Airport__c, Destination__r.Name, Flight__r.Operator__c, Duration_Hour__c, Duration_Minutes__c,
                                Departure_Date__c, Departure_Hour__c, Departure_Minutes__c, Economy_Class_Price__c,
                                Business_Class_Price__c, Currency__c FROM Airport_Flight__c WHERE Origin__c=:this.selectedOrigin
                                AND Destination__c=:this.selectedDestination AND Departure_Date__c=:this.depDate];
        }
    	
        if(airportFlights.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Oops! no flight found' ));
            return;
        }

        for(Airport_Flight__c af : airportFlights)
        {
            //Converting Flight Time into Mins
            Integer timeInMins = (Integer.valueOf(af.Duration_Hour__c)*60)+Integer.valueOf(af.Duration_Minutes__c);
            System.debug('UN: timeInMins'+timeInMins); //60

            Datetime originDt = Datetime.newInstance(af.Departure_Date__c, Time.newInstance(Integer.valueOf(af.Departure_Hour__c), Integer.valueOf(af.Departure_Minutes__c), 0, 0));
            System.debug('UN: originDt'+originDt); //2023-10-31 18:00:00

            Timezone originTimezone = Timezone.getTimezone(af.Origin__r.Timezone__c);
            System.debug('UN: originTimezone'+originTimezone); //Asia/Karachi

            Timezone desTimezone = Timezone.getTimezone(af.Destination__r.Timezone__c);
            System.debug('UN: desTimezone'+desTimezone); //Asia/Dubai

            Integer originOffset = originTimezone.getOffset(originDt.date())/1000/60;
            System.debug('UN: originOffset'+originOffset); //300

            Integer desOffset = desTimezone.getOffset(originDt.date())/1000/60;
            System.debug('UN: desOffset'+desOffset);//240

            Integer requiredOffset = originOffset-desOffset;
            System.debug('UN: requiredOffset'+requiredOffset); //300-240=60

            Datetime destinationDt = originDt.addMinutes(timeInMins-requiredOffset); //2023-10-31 18:00:00 + 60 -60
            System.debug('UN: destinationDt'+destinationDt); //2023-10-31 18:00:00

            FlightInfo fi = new FlightInfo();
            fi.operator= af.Flight__r.Operator__c;
            fi.flightDuration= af.Duration_Hour__c +'H '+ af.Duration_Minutes__c+'M';
            fi.econPrice= af.Currency__c+' '+String.valueOf(Integer.valueOf(passangerQty)*af.Economy_Class_Price__c);
            fi.businessPrice= af.Currency__c+' '+String.valueOf(Integer.valueOf(passangerQty)*af.Business_Class_Price__c);
            fi.origin=af.Origin__r.Name+' ('+af.Origin__r.airport__c+')';
            fi.destination=af.Destination__r.Name+' ('+af.Destination__r.airport__c+')';
            fi.originTime=String.valueOf(originDt).removeEnd(':00');
            System.debug('UN: originTime'+fi.originTime);
            fi.destinationTime=String.valueOf(destinationDt).removeEnd(':00');
            System.debug('UN: destinationTime'+fi.destinationTime);
            this.availableFlights.add(fi);
        }
    }

    public class FlightInfo
    {
        public String operator{get;set;}
        public String flightDuration{get;set;}
        public String origin{get;set;}
        public String destination{get;set;}
        public String econPrice{get;set;}
        public String businessPrice{get;set;}
        public String originTime{get;set;}
        public String destinationTime{get;set;}
    }
}