trigger FlowRecordVersion on FlowRecordVersion(before insert, after update) 
{
    Map<String,String> flowNamesMap = new Map<String,String>();

	for(FlowRecordVersion flow : Trigger.new) 
	{

        flowNamesMap.put(flow.Name, flow.FlowRecordId);

        //flow.addError('You are not allowed to activate flow');
    }

    System.debug('UAC: flowNamesMap ' + flowNamesMap );
    FlowRecordVersionHandler.retrieveFlowElements(flowNamesMap);
}


/*

>>> FlowDefinitionView
Id: 						3ddHo0000000WhDIAU
Flow Durable Id : 			300Ho0000000WhDIAU
LatestVersionId: 			301Ho000000EFAkIAO
ActivatedVersionId: 		301Ho000000EFAiIAO
TriggerObjectOrEventLabel: 	Feedback
TriggerObjectOrEventId : 	Feedback__c 
RecordTriggerType: 			Update, CreateAndUpdate, Delete
TriggerType: 				RecordAfterSave, RecordBeforeSave, PlatformEvent, Scheduled, 
VersionNumber : 			2


>>> FlowRecord
Id : 						2aFHo00000001SAMAY	
FlowDefinition (lookup):	300Ho0000000WhDIAU
Type: 						RecordAfterSave, RecordBeforeSave, PlatformEvent, Scheduled, 
ProgressStatus:				InProgress, Draft 
FlowType:					RecTrigAfterSave

>>> FlowRecordVersion
FlowRecordId (lookup):		2aFHo00000001SAMAY
VersionNumber:				3
ProgressStatus:				InProgress, Draft
ActivatedbyId:				005xxxxxxxxx
ActivatedDate:				2023-09-26T07:20:46

*/