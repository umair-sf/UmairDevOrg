public with sharing class FlowRecordVersionChangeTriggerHandler 
{
    public static void validateRecordTriggerdFlow(Set<Id> flowIds) 
    {
        // // Query the FlowVersion records
        // List<FlowVersion> parentFlows = [
        //     SELECT Id, FlowDefinitionId, Status, Definition.DeveloperName
        //     FROM FlowVersion
        //     WHERE Id IN :flowIds AND Definition.DeveloperName LIKE '%ParentFlow%'
        // ];

        // // Define allowed element types for parent flows
        // List<String> allowedElements = new List<String>{'Assignment', 'Decision', 'Loop', 'RecordUpdate', 'Subflow'};

        // // Validate each parent flow
        // for (FlowVersion flow : parentFlows) {
        //     if (flow.Status == 'Active' || flow.Status == 'Draft') {
        //         // Query the elements of the flow
        //         List<FlowElement> elements = [
        //             SELECT ElementType
        //             FROM FlowElement
        //             WHERE FlowVersionId = :flow.Id
        //         ];

        //         // Check for invalid elements
        //         for (FlowElement element : elements) {
        //             if (!allowedElements.contains(element.ElementType)) {
        //                 System.debug('Invalid element found in parent flow: ' + flow.Definition.DeveloperName);
        //                 // Add logic to handle invalid elements, e.g., sending notifications or disabling the flow
        //             }
        //         }
        //     }
        // }
    }
}