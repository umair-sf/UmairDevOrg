public with sharing class TerminationTriggerHandler
{
    public static void calculateDates(List<Termination_Request__c> terminations) 
    {
        Map<Id,List<Termination_Request__c>> oppIdtoTerminations = new Map<Id,List<Termination_Request__c>>();
        List<Termination_Config__c> terminationConfig = Termination_Config__c.getall().values();
        List<Termination_Line_Item__c> terminationLineItemsToInsert = new List<Termination_Line_Item__c>();
        List<Termination_Request__c> terminationsToInsert = new List<Termination_Request__c>();

        for(Termination_Request__c termination : terminations)
        {
            List<Termination_Request__c> tempList = oppIdtoTerminations.get(termination.opportunity__c);
            if(tempList == null)
            {
                tempList = new List<Termination_Request__c>();
                oppIdtoTerminations.put(termination.opportunity__c, tempList);
            }
            tempList.add(termination);
        }

        for(Opportunity opp : [SELECT Id, Name, AccountId, SyncedQuoteId, Lease_Start_Date__c, Lease_End_Date__c FROM Opportunity WHERE Id IN :oppIdtoTerminations.keySet()])
        {
            for(Termination_Request__c termination : oppIdtoTerminations.get(opp.Id))
            {
                Date leaseStartDate = opp.Lease_Start_Date__c;
                Date leaseEndDate = opp.Lease_End_Date__c;
                Date letterDate = termination.Termination_Notice_Date__c;
                Date minimumStayDate = termination.Minimum_Stay_Date__c;
                Date keyHandoverDate = termination.Key_Handover_Date__c;
                Date noticePeriodEndDate = termination.Notice_Period_End_Date__c;
                Date exitPenaltyEndDate = termination.Exit_Penalty_End_Date__c;
                Date fodDate = termination.Financial_Obligation_Date__c;
                String penaltyNotes = termination.Penalty_Notes__c;

                //Months between lease start and end date
                Integer monthBetween = leaseStartDate.monthsBetween(leaseEndDate);

                for(Termination_Config__c config : terminationConfig)
                {
                    //Choosing right configration
                    if(config.Minimum_Lease_Duration__c <= monthBetween && config.Maximum_Lease_Duration__c >= monthBetween)
                    {
                        termination.Configuration_Name__c = config.Name;

                        // Date by which Notice should be submitted
                        Date expectedNoticePeriod = config.Notice_Period__c == -1? leaseEndDate : leaseEndDate.addMonths(-Integer.valueOf(config.Notice_Period__c)).addDays(1);
                        
                        // Calculate Minimum Stay Date
                        minimumStayDate = monthBetween <= 12 ? leaseEndDate : leaseStartDate.addMonths(Integer.valueOf(config.Minimum_Stay__c)).addDays(-1);
                        
                        // Calculate Notice Period End Date
                        noticePeriodEndDate = letterDate.addMonths(Integer.valueOf(config.Notice_Period__c)).addDays(-1);
                        
                        // Calculate Penalty Notes
                        penaltyNotes = String.valueOf(expectedNoticePeriod);

                        //If Early Termination with Minimum Stay Completed
                        if(keyHandoverDate < leaseEndDate && keyHandoverDate > minimumStayDate)
                        {
                            exitPenaltyEndDate = keyHandoverDate.addMonths(Integer.valueOf(config.Exit_Penalty__c)).addDays(-1);
                            termination.Is_Minimum_Stay_Completed__c = true;
                            termination.Is_Early_Termination__c = true;
                        }
                        //If Early Termination with Minimum Stay Not Completed
                        else if(keyHandoverDate < leaseEndDate && keyHandoverDate < minimumStayDate)
                        {
                            exitPenaltyEndDate = minimumStayDate;
                            termination.Is_Minimum_Stay_Completed__c = false;
                            termination.Is_Early_Termination__c = true;
                        }
                        //If exceeded termination
                        else if(keyHandoverDate > leaseEndDate && letterDate > leaseEndDate)
                        {
                            exitPenaltyEndDate = keyHandoverDate.addMonths(Integer.valueOf(config.Exit_Penalty__c)).addDays(-1);
                            termination.Is_Early_Termination__c = false;
                            termination.Is_Minimum_Stay_Completed__c = true;
                        }
                        else
                        {
                            exitPenaltyEndDate = null;
                        }

                        //Calculating FOD Date
                        //If Minimum Stay is not Completed
                        if(letterDate <= expectedNoticePeriod && keyHandoverDate < minimumStayDate)
                        {
                            fodDate = minimumStayDate;
                        }
                        //In Case of Notice Penalty
                        else if(letterDate > expectedNoticePeriod && keyHandoverDate <= leaseEndDate)
                        {
                            fodDate = keyHandoverDate.addMonths(Integer.valueOf(config.Notice_Period__c)).addDays(-1);
                        }
                        //In Case of Exceeding Lease End Date
                        else if(letterDate > expectedNoticePeriod && keyHandoverDate > leaseEndDate)
                        {
                            fodDate = keyHandoverDate.addMonths(Integer.valueOf(config.Notice_Period__c+config.Exit_Penalty__c)).addDays(-1);
                        }
                        else
                        {
                            fodDate = leaseEndDate;
                        }

                        termination.Financial_Obligation_Date__c = fodDate;
                        termination.Exit_Penalty_End_Date__c = exitPenaltyEndDate;
                        termination.Penalty_Notes__c = penaltyNotes;
                        termination.Notice_Period_End_Date__c = noticePeriodEndDate;
                        termination.Minimum_Stay_Date__c = minimumStayDate;
                    }
                }
                Integer leaseDuration = leaseStartDate.daysBetween(leaseEndDate)+1;
                termination.Lease_Duration_Days__c = leaseDuration;
                termination.Is_Early_Termination__c = leaseStartDate.daysBetween(keyHandoverDate)+1 < leaseDuration;
                if(String.isNotBlank(opp.AccountId)) termination.Account__c = opp.AccountId;
                if(String.isNotBlank(opp.SyncedQuoteId)) termination.Quote__c = opp.SyncedQuoteId;
            }
        }
    }

    public static void insertTerminationLineItems(List<Termination_Request__c> terminations)
    {
        Map<Id,List<Termination_Request__c>> oppIdtoTerminations = new Map<Id,List<Termination_Request__c>>();
        List<Termination_Line_Item__c> terminationLineItemsToInsert = new List<Termination_Line_Item__c>();

        for(Termination_Request__c termination : terminations)
        {
            List<Termination_Request__c> tempList = oppIdtoTerminations.get(termination.opportunity__c);
            if(tempList == null)
            {
                tempList = new List<Termination_Request__c>();
                oppIdtoTerminations.put(termination.opportunity__c, tempList);
            }
            tempList.add(termination);
        }

        for(Opportunity opp : [SELECT Id, (select Id, Quantity, TotalPrice, Name, OpportunityId, Product2Id, PricebookEntryId, ListPrice from OpportunityLineItems) FROM Opportunity WHERE Id IN :oppIdtoTerminations.keySet()])
        {
            for(Termination_Request__c termination : oppIdtoTerminations.get(opp.Id))
            {
                for(OpportunityLineItem oli : opp.OpportunityLineItems)
                {
                    Termination_Line_Item__c tli = new Termination_Line_Item__c();
                    tli.Termination_Request__c = termination.Id;
                    tli.Amount__c = oli.TotalPrice;
                    tli.Charge_Type__c = 'Rent';
                    tli.End_Date__c = null;
                    tli.Penalty_Type__c = 'Notice Period';
                    tli.Rate__c = oli.ListPrice;
                    tli.Start_Date__c = null;
                    tli.Unit_Name__c = oli.Name;

                    terminationLineItemsToInsert.add(tli);
                }
            }
        }
        if(terminationLineItemsToInsert.size()>0) insert terminationLineItemsToInsert;
    }

    // public static void calculateDates(List<Termination_Request__c> terminations) 
    // {
    //     Map<Id,List<Termination_Request__c>> oppIdtoTerminations = new Map<Id,List<Termination_Request__c>>();
    //     List<Termination_Config__c> terminationConfig = Termination_Config__c.getall().values();
    //     List<Termination_Line_Item__c> terminationLineItemsToInsert = new List<Termination_Line_Item__c>();

    //     for(Termination_Request__c termination : terminations)
    //     {
    //         List<Termination_Request__c> tempList = oppIdtoTerminations.get(termination.opportunity__c);
    //         if(tempList == null)
    //         {
    //             tempList = new List<Termination_Request__c>();
    //             oppIdtoTerminations.put(termination.opportunity__c, tempList);
    //         }
    //         tempList.add(termination);
    //     }

    //     for(Opportunity opp : [SELECT Id, Name, AccountId, SyncedQuoteId, Lease_Start_Date__c, Lease_End_Date__c, (select Id, Quantity, TotalPrice, Name, OpportunityId,
    //                             Product2Id, PricebookEntryId, ListPrice from OpportunityLineItems) FROM Opportunity WHERE Id IN :oppIdtoTerminations.keySet()])
    //     {
    //         for(Termination_Request__c termination : oppIdtoTerminations.get(opp.Id))
    //         {
    //             termination.Unit_Names__c = '';
    //             for(OpportunityLineItem oli : opp.OpportunityLineItems)
    //             {
    //                 termination.Unit_Names__c += oli.Name + ' ,';
    //                 Termination_Line_Item__c terminationLineItem = new Termination_Line_Item__c();
    //                 terminationLineItem.Termination_Request__c = termination.Id;
    //                 terminationLineItem.Amount__c = oli.TotalPrice;
    //                 terminationLineItem.Charge_Type__c = 'Rent';
    //                 terminationLineItem.End_Date__c = null;
    //                 terminationLineItem.Penalty_Type__c = 'Notice Period';
    //                 terminationLineItem.Rate__c = oli.ListPrice;
    //                 terminationLineItem.Start_Date__c = null;
    //                 terminationLineItem.Unit_Name__c = oli.Name;

    //                 terminationLineItemsToInsert.add(terminationLineItem);
    //             }
    //             termination.Unit_Names__c = termination.Unit_Names__c.left(termination.Unit_Names__c.length()-1);

    //             Date leaseStartDate = opp.Lease_Start_Date__c;
    //             Date leaseEndDate = opp.Lease_End_Date__c;
    //             Date letterDate = termination.Termination_Notice_Date__c;
    //             Date minimumStayDate = termination.Minimum_Stay_Date__c;
    //             Date keyHandoverDate = termination.Key_Handover_Date__c;
    //             Date noticePeriodEndDate = termination.Notice_Period_End_Date__c;
    //             Date exitPenaltyEndDate = termination.Exit_Penalty_End_Date__c;
    //             Date fodDate = termination.Financial_Obligation_Date__c;

    //             String penaltyNotes = termination.Penalty_Notes__c;

    //             if(leaseStartDate !=null && leaseEndDate !=null)
    //             {
    //                 //Month(s) between lease start and end date
    //                 Integer monthBetween = leaseStartDate.monthsBetween(leaseEndDate);

    //                 for(Termination_Config__c config : terminationConfig)
    //                 {
    //                     //Choosing right configration
    //                     if(config.Minimum_Lease_Duration__c <= monthBetween && config.Maximum_Lease_Duration__c >= monthBetween)
    //                     {
    //                         termination.Configuration_Name__c = config.Name;

    //                         // Date by which Notice should be submitted
    //                         Date expectedNoticePeriod = config.Notice_Period__c == -1? leaseEndDate : leaseEndDate.addMonths(-Integer.valueOf(config.Notice_Period__c)).addDays(1);
                            
    //                         // Calculate Minimum Stay Date
    //                         minimumStayDate = monthBetween <= 12 ? leaseEndDate : leaseStartDate.addMonths(Integer.valueOf(config.Minimum_Stay__c)).addDays(-1);
                            
    //                         // Calculate Notice Period End Date
    //                         noticePeriodEndDate = letterDate.addMonths(Integer.valueOf(config.Notice_Period__c)).addDays(-1);
                            
    //                         // Calculate Penalty Notes
    //                         penaltyNotes = String.valueOf(expectedNoticePeriod);

    //                         //If Early Termination with Minimum Stay Completed
    //                         if(keyHandoverDate < leaseEndDate && keyHandoverDate > minimumStayDate)
    //                         {
    //                             exitPenaltyEndDate = keyHandoverDate.addMonths(Integer.valueOf(config.Exit_Penalty__c)).addDays(-1);
    //                             termination.Is_Minimum_Stay_Completed__c = true;
    //                             termination.Is_Early_Termination__c = true;
    //                         }
    //                         //If Early Termination with Minimum Stay Not Completed
    //                         else if(keyHandoverDate < leaseEndDate && keyHandoverDate < minimumStayDate)
    //                         {
    //                             exitPenaltyEndDate = minimumStayDate;
    //                             termination.Is_Minimum_Stay_Completed__c = false;
    //                             termination.Is_Early_Termination__c = true;
    //                         }
    //                         //If exceeded termination
    //                         else if(keyHandoverDate > leaseEndDate && letterDate > leaseEndDate)
    //                         {
    //                             exitPenaltyEndDate = keyHandoverDate.addMonths(Integer.valueOf(config.Exit_Penalty__c)).addDays(-1);
    //                             termination.Is_Early_Termination__c = false;
    //                             termination.Is_Minimum_Stay_Completed__c = true;
    //                         }
    //                         else
    //                         {
    //                             exitPenaltyEndDate = null;
    //                         }

    //                         //Calculating FOD Date
    //                         //If Minimum Stay is not Completed
    //                         if(letterDate <= expectedNoticePeriod && keyHandoverDate < minimumStayDate)
    //                         {
    //                             fodDate = minimumStayDate;
    //                         }
    //                         //In Case of Notice Penalty
    //                         else if(letterDate > expectedNoticePeriod && keyHandoverDate <= leaseEndDate)
    //                         {
    //                             fodDate = keyHandoverDate.addMonths(Integer.valueOf(config.Notice_Period__c)).addDays(-1);
    //                         }
    //                         //In Case of Exceeding Lease End Date
    //                         else if(letterDate > expectedNoticePeriod && keyHandoverDate > leaseEndDate)
    //                         {
    //                             fodDate = keyHandoverDate.addMonths(Integer.valueOf(config.Notice_Period__c+config.Exit_Penalty__c)).addDays(-1);
    //                         }
    //                         else
    //                         {
    //                             fodDate = leaseEndDate;
    //                         }

    //                         termination.Financial_Obligation_Date__c = fodDate;
    //                         termination.Exit_Penalty_End_Date__c = exitPenaltyEndDate;
    //                         termination.Penalty_Notes__c = penaltyNotes;
    //                         termination.Notice_Period_End_Date__c = noticePeriodEndDate;
    //                         termination.Minimum_Stay_Date__c = minimumStayDate;
    //                     }
    //                 }
    //                 Integer leaseDuration = leaseStartDate.daysBetween(leaseEndDate)+1;
    //                 termination.Lease_Duration_Days__c = leaseDuration;
    //                 termination.Is_Early_Termination__c = leaseStartDate.daysBetween(keyHandoverDate)+1 < leaseDuration;
    //             }
    //             if(String.isNotBlank(opp.AccountId)) termination.Account__c = opp.AccountId;
    //             if(String.isNotBlank(opp.SyncedQuoteId)) termination.Quote__c = opp.SyncedQuoteId;
    //         }
    //     }
    //     if(terminationLineItemsToInsert.size()>0) insert terminationLineItemsToInsert;
    // }
}