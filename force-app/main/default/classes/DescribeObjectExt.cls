public with sharing class DescribeObjectExt
{
	public List<SelectOption> sObjectName {get;set;}
	public String sObjectSelected {get;set;}

	public Integer totalFields {get;set;}
	public Integer totalCusFields {get;set;}
	public Integer totalStandFields {get;set;}

	public Integer totalRecordTypes {get;set;}
	public Integer totalChild {get;set;}

	public Integer totalObjects {get;set;}
	public Integer totalStandObjects {get;set;}
	public Integer totalCusObjects {get;set;}

	public Boolean disabledSec {get;set;}

	public Map<String, Schema.SObjectType> gd {get; set;}
	public List<FieldsDetail> fieldDetailLst {get;set;}
	public List<RecordTypeDetail> recordTypeDetailLst {get;set;}
	public List<ChildRelInfo> childRelInfoLst {get;set;}

    public DescribeObjectExt()
    {
    	this.disabledSec = false;
    	this.childRelInfoLst = new List<ChildRelInfo>();
    	this.fieldDetailLst = new List<FieldsDetail>();
    	this.recordTypeDetailLst = new List<RecordTypeDetail>();
    	this.sObjectName = new List<SelectOption>(); 
        this.gd = Schema.getGlobalDescribe();

        Set<String> objNames = new Set<String>();

        Integer counter=0;
        for(String key : gd.keySet())
		{
			if(counter<1000)
			{
				sObjectName.add(new SelectOption(key,String.valueOf(gd.get(key))));
				counter++;
			}
			if(key.endsWith('__c'))
			{
				objNames.add(key);
			}
		}
		sObjectName.sort();
		this.totalObjects = gd.size();
		this.totalCusObjects = objNames.size();
		this.totalStandObjects = totalObjects - totalCusObjects;
    }
    public void getFields()
    {
    	this.disabledSec = true;
    	this.sObjectSelected = sObjectSelected.capitalize();
		Schema.DescribeSObjectResult sObjectResult = gd.get(this.sObjectSelected).getDescribe();

		Map<String, SObjectField> fieldsMap = sObjectResult.fields.getMap();
		this.totalFields = fieldsMap.size();
		Set<String> cusFieldNames = new Set<String>();

		for(String fieldName : fieldsMap.keySet()) 
		{
		    DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
		    
		    FieldsDetail fdDtl = new FieldsDetail();
		    fdDtl.labelName = fieldResult.getLabel();
		    fdDtl.type = String.valueOf(fieldResult.getType());
		    fdDtl.fieldLength = fieldResult.getLength();
		    fdDtl.apiName = fieldResult.getName();

		    fieldDetailLst.add(fdDtl);

		    if(fieldName.endsWith('__c'))
		    {
		    	cusFieldNames.add(fieldName);
		    }
		}
		this.totalCusFields = cusFieldNames.size();
		this.totalStandFields = this.totalFields - this.totalCusFields;

		Map<String,Schema.RecordTypeInfo> recordTypesMap = sObjectResult.getRecordTypeInfosByDeveloperName();
		this.totalRecordTypes =  recordTypesMap.size();
		for(String rtDDevName : recordTypesMap.keySet())
		{
		    Schema.RecordTypeInfo rtInfo = recordTypesMap.get(rtDDevName) ;
		    RecordTypeDetail rtDtl = new RecordTypeDetail();

		    rtDtl.name =rtInfo.getName();
		    rtDtl.recordtypeid =rtInfo.getRecordTypeId();
		    rtDtl.isDefault =rtInfo.isDefaultRecordTypeMapping();
		    rtDtl.available =rtInfo.isAvailable();

		    recordTypeDetailLst.add(rtDtl);
		}

		List<Schema.ChildRelationship> childRelLst = sObjectResult.getChildRelationships();
		this.totalChild =  childRelLst.size();
		for(Schema.ChildRelationship childRel : childRelLst)
		{
		    ChildRelInfo childRelInfo = new ChildRelInfo();

		    childRelInfo.childObject =String.valueOf(childRel.getChildSObject());
		    childRelInfo.relationshipName =String.valueOf(childRel.getRelationshipName());
		    childRelInfo.field =String.valueOf(childRel.getField());
		    childRelInfo.cascadeDelete =childRel.isCascadeDelete();

		    childRelInfoLst.add(childRelInfo);
		}
    }
    public Class FieldsDetail
    {
    	public String labelName {get;set;}
    	public String type{get;set;}
    	public Integer fieldLength{get;set;}
    	public String apiName{get;set;}
    }
    public Class RecordTypeDetail
    {
    	public String recordtypeid {get;set;}
    	public String name{get;set;}
    	public Boolean isDefault{get;set;}
    	public Boolean available{get;set;}
    }
    public Class ChildRelInfo
    {
    	public String childObject {get;set;}
    	public String relationshipName {get;set;}
    	public String field {get;set;}
    	public Boolean cascadeDelete {get;set;}
    }
}

// Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

// 



// System.debug('UAC: sObjectResult ' +  sObjectResult);

// Map<String,Schema.RecordTypeInfo> recordTypesMap = sObjectResult.getRecordTypeInfosByDeveloperName() ; 
// for(String rtDDevName : recordTypesMap.keySet())
// {
//     Schema.RecordTypeInfo rtInfo = recordTypesMap.get(rtDDevName) ;

//     System.debug('UAC: RT Name ' + rtInfo.getName() );
//     System.debug('UAC: RT DevName ' + rtInfo.getDeveloperName() );
//     System.debug('UAC: RT ID ' + rtInfo.getRecordTypeId() );
//     System.debug('UAC: RT IsAvailable ' + rtInfo.isAvailable() );
// }

// Map<String, SObjectField> fieldsMap = sObjectResult.fields.getMap();
// System.debug('UAC: fieldsMap size ' + fieldsMap.size() );

// for(String fieldName : fieldsMap.keySet()) 
// {
//     DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
//     System.debug('UAC: fieldName ' + fieldResult.getLabel() + ' getLocalName ' + fieldResult.getLocalName() );
//     System.debug('UAC: getName ' + fieldResult.getName() + ' getType ' + fieldResult.getType() );

//     // if(fieldResult.getType() == Schema.DisplayType.PICKLIST)
//     // {
//     //     List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
//     //     for(Schema.PicklistEntry ple : picklistEntries )
//     //     {
//     //         System.debug('UAC: ple ' + ple.getLabel() + ' ple getValue ' + ple.getValue() +  ' Active ' + ple.isActive() + ' default ' + ple.isDefaultValue() );
//     //     }
//     // }
// }


// Id setRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Community_Account').getRecordTypeId();