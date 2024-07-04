trigger BTL_WebLeadsTrigger on  BTL_Web_Lead__c (before Insert, after insert, before update, after Update , before delete, after delete, after undelete) {
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean runMyTrigger = true;
    // Global settings for org level to prevent trigger from firing
    
   
    
        if(trigger.isBefore && trigger.isInsert){
        }
        else if(trigger.isBefore && trigger.isUpdate){
        }
        else if(trigger.isBefore && trigger.isDelete){
            
        }
        else if(trigger.isAfter && trigger.isInsert){
         BTL_WebLeadsHandler.afterInsert(trigger.New);
        }
        else if(trigger.isAfter && trigger.isUpdate){

        }
        else if(trigger.isAfter && trigger.isDelete){
        
        }
    
}