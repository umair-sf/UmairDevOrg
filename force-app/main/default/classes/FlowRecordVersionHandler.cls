public with sharing class FlowRecordVersionHandler 
{
    private static List<Id> cacheRecordIds = new List<Id>();
    private static List<Case> sobjects;
    private static Boolean isCacheValid = false;

    @InvocableMethod(label='Get Accounts ' description='Returns the list of accounts')
    public static List<Result> invocableGetaccounts(List<DynamicQueryParams> queryParams)
    {
        // Get the parameters sent by flow
        DynamicQueryParams queryParam = queryParams[0];

        System.debug('UAC: queryParam.whereClause ' + queryParam.whereClause );
        System.debug('UAC: queryParam.recordIds ' + queryParam.recordIds );
        System.debug('UAC: queryParam.baseQuery ' + queryParam.baseQuery );

        // When IDs are come first time, or IDs are changed in next invocation
        if(queryParam.recordIds != null && (cacheRecordIds.size() == 0 || !cacheRecordIds.equals(queryParam.recordIds)))
        {
            cacheRecordIds = queryParam.recordIds;
            isCacheValid = false;
        }

        System.debug('UAC: isCacheValid ' + isCacheValid );
        
        String query = queryParam.baseQuery.contains('*') ? getAllObjectFields(queryParam.baseQuery) : queryParam.baseQuery;

        if(!isCacheValid)
        {

            // When RecordIds and optionally other fields filters recieved from flow for query
            if(cacheRecordIds.size() > 0)
            {
                query += ' WHERE Id IN: ' + cacheRecordIds + (String.isNotBlank(queryParam.whereClause) ? queryParam.whereClause : '' );
            }

            // When only other fields filter received from flow
            if(cacheRecordIds.size() == 0 && String.isNotBlank(queryParam.whereClause) )
            {
                query += queryParam.whereClause.toUpperCase().contains('WHERE') ? queryParam.whereClause : ' WHERE '+ queryParam.whereClause ;
            }
            
            System.debug('UAC: query '+query);
            sobjects = Database.query(query) ;

            // Set to true to not run the query in next invocation from the flow 
            isCacheValid = true;
        }
        System.debug('UAC: sobjects ' + sobjects );

        Result response = new Result();
        List<Result> results = new List<Result>();
        results.add(response);

        response.records = sobjects ;
        
        System.debug('UAC: results ' + results );

        return results;
    }

    /**
     * Method to perform a dynamic query for an object.
     * @param query The dynamic query string. Example: 'SELECT * FROM Account'.
     * @return List of sObjects resulting from the query or an empty list if the query is invalid.
     */
    private static String getAllObjectFields(String query )
    {
        // Normalize the query string
        query = query.trim();

        // Extract the object name
        String objectName = query.substring(14).trim(); // 14 is the length of "SELECT * FROM"
        
        List<String> objectFields = new List<String>(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keyset());

        String fieldNames = String.join(objectFields, ', ');

        String dynamicQuery = 'SELECT ' + fieldNames + ' FROM ' + objectName ; 

        return dynamicQuery ;
    }

    public class DynamicQueryParams
    {
        @InvocableVariable(label='Base Query' required=true)
        public String baseQuery;
        
        @InvocableVariable (label='Record Ids' description='Give list of Ids of quering object.')
        public List<Id> recordIds;
        
        @InvocableVariable (label='Where Caluse' description='Don\'t add binding variables in the where caluse.')
        public String whereClause;
    }

    public class Result
    {
        @InvocableVariable(label='Output Object Type' description='Specify an object to cast returned List of sObject')
        public List<SObject> records ;
    }











































    public static Boolean RUN_ONCE = true ;
    public static String outxmlstring = '' ;
    public static Map<String,Integer> nodesMap = new Map<String,Integer>{'records' => 0, 'actioncalls' => 0, 'recordtriggertype' => 0, 'triggertype' => 0, 'object' => 0, 'targetreference' => 0,
                                                                        'recorddeletes' => 0, 'recordcreates' => 0, 'recordlookups' => 0, 'recordupdates' => 0, 'assignments' => 0, 'subflows' => 0,
                                                                        'screens' => 0 };

    @future(callout=true)
    public static void retrieveFlowElements(Map<String,String> flowNamesMap) 
    {
        FlowRecordVersionHandler.RUN_ONCE = false ;
        Map<String,String> flowDurableIdToType = new Map<String,String>();
        Map<String,String> flowNameToLatestVersionid = new Map<String,String>();
        Set<String> durableIds = new Set<String>();

        for(FlowRecord fc : [SELECT Id, FlowDefinition, Type FROM FlowRecord WHERE Id IN : flowNamesMap.values()])
        {
            durableIds.add(fc.FlowDefinition);
        }
        System.debug('UAC: flowDurableIdToType ' + flowDurableIdToType );

        for(FlowDefinitionView fdv : [SELECT Id, DurableId, ApiName, VersionNumber, TriggerType, ActiveVersionId FROM FlowDefinitionView WHERE DurableId IN :durableIds AND ActiveVersionId != NULL ])
        {
            flowDurableIdToType.put(fdv.ApiName, fdv.TriggerType);
        }

        for(String flowName : flowNamesMap.keySet() )
        {
            if(flowDurableIdToType.get(flowName) != 'RecordBeforeSave' && flowDurableIdToType.get(flowName) != 'RecordAfterSave' ) continue ; 

            String soapRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">' +
                        '<soapenv:Header>' +
                            '<met:SessionHeader>' +
                                '<met:sessionId>' + UserInfo.getSessionId() + '</met:sessionId>' +
                            '</met:SessionHeader>' +
                        '</soapenv:Header>' +
                        '<soapenv:Body>' +
                            '<met:readMetadata>' +
                                '<met:type>Flow</met:type>' +
                                '<met:fullNames>' + flowName + '</met:fullNames>' +
                            '</met:readMetadata>' +
                        '</soapenv:Body>' +
                    '</soapenv:Envelope>';

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL.getOrgDomainURL().toExternalForm() + '/services/Soap/m/60.0');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '""');
            req.setBody(soapRequest);

            HttpResponse res = http.send(req);

            String responseXml = res.getBody();

            System.debug('UAC: responseXml ' + responseXml );

            parseFlowMetadataResponse(responseXml);

            Flow__c flow = new Flow__c(Name = flowName, Action_Calls__c = 0, Record_Deletes__c = 0, Record_Creates__c = 0, Record_Lookups__c = 0, Record_Updates__c = 0, Sub_Flows__c = 0, Screens__c = 0  );
            
            Boolean isApplicable = false ;

            Map<String,String> fieldsMap = new Map<String,String>{  'actioncalls' => 'Action_Calls__c', 'recorddeletes' => 'Record_Deletes__c', 'recordcreates' => 'Record_Creates__c', 
                                                                    'recordlookups' => 'Record_Lookups__c', 'recordupdates' => 'Record_Updates__c', 'subflows' => 'Sub_Flows__c', 'screens' => 'Screens__c' };

            for(String element : nodesMap.keySet())
            {
                Integer value = nodesMap.get(element);

                if(value > 0) 
                {
                    if(fieldsMap.containsKey(element) ) flow.put(fieldsMap.get(element), Decimal.valueOf(value)) ;
                    isApplicable = true ;
                }
            }
            if(isApplicable)
            {
                upsert flow Flow__c.Name ;
            }
        }
    }


    private static void parseFlowMetadataResponse(String xmlString) 
    {       
        Dom.Document xmlDOC = new DOM.Document();
        xmlDOC.load(xmlString);

        Dom.XMLNode rootElement = xmlDOC.getRootElement();
        outxmlstring= xmlDOC.getRootElement().getName();
        System.debug('UAC: outxmlstring ' + outxmlstring );

        for(Dom.XMLNode xmlnodeobj: xmlDOC.getRootElement().getChildElements())
        {       
            loadChilds(xmlnodeobj);
        }

        System.debug('UAC: nodesMap ' + nodesMap );  
        System.debug('UAC: outxmlstring ' + outxmlstring );  

    }

    private static void loadChilds(DOM.XMLNode xmlnode)
    {
        List<Dom.XMLNode> childs = xmlnode.getChildElements() ; 
        //System.debug('UAC: xmlnode.getName() ' + xmlnode.getName() + ' childs ' + childs  );
        if(nodesMap.containsKey(xmlnode.getName().toLowerCase())) nodesMap.put(xmlnode.getName().toLowerCase(), nodesMap.get(xmlnode.getName().toLowerCase()) + 1 );

        for(Dom.XMLNode child : childs )
        {
            // if(child.getText()!= null)
            // {
            //  outxmlstring+='\n'+child.getName()+': '+child.getText() + 'count: ' + child.getAttributeCount();
            // }
            loadChilds(child);      
        }
    }

    

}