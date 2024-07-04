public without sharing class AggregateCalculatorExt
{
	public Integer matricMarks {get; set;}
	public Integer interMarks {get; set;}
	public Integer testMarks {get; set;}

	public Integer totalMatric{get;set;}
	public Integer totalInter{get;set;}

	public List<SelectOption> totalMatricMarkslist {get; set;}
	public List<SelectOption> totalInterMarkslist {get; set;}

	public Decimal aggregate{get;set;}

    public AggregateCalculatorExt()
    {
        this.totalMatricMarkslist = new List<SelectOption>();
        totalMatricMarkslist.add(new SelectOption('1100','1100'));
        totalMatricMarkslist.add(new SelectOption('1050','1050'));
        totalMatricMarkslist.add(new SelectOption('900','900'));

        this.totalInterMarkslist = new List<SelectOption>();
        totalInterMarkslist.add(new SelectOption('1100','1100'));
        totalInterMarkslist.add(new SelectOption('1050','1050'));
        totalInterMarkslist.add(new SelectOption('900','900'));
    }
    public void calculation()
    {
        this.aggregate=0.0;
        // if(String.isBlank(matricMarks) || String.isBlank(interMarks) || String.isBlank(testMarks))
        // {
        //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Marks to get the Aggregate'));
        //     return;
        // }
        if(matricMarks<=0 || matricMarks>totalMatric)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter correct Matric Marks'));
            return;
        }
        if(interMarks<=0 || interMarks>totalInter)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter correct Inter Marks'));
            return;
        }
        if(testMarks<=0 || testMarks>200)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter correct Test Marks'));
            return;
        }
        Decimal matricPercentage = ((decimal.valueOf(this.matricMarks)/decimal.valueOf(this.totalMatric))*20).setScale(2);
        Decimal interPercentage = ((decimal.valueOf(this.interMarks)/decimal.valueOf(this.totalInter))*30).setScale(2);
        Decimal testPercentage = ((decimal.valueOf(this.testMarks)/200)*50).setScale(2);
        this.aggregate= matricPercentage +interPercentage +testPercentage;
    }
}