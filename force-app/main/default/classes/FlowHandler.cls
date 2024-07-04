public with sharing class FlowHandler 
{
    public static List<Id> cacheRecordIds = new List<Id>();
    private static List<SObject> sobjects;
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
        System.debug('UAC: query ' + query );

        if(!isCacheValid)
        {

            // When RecordIds and optionally other fields filters recieved from flow for query
            if(cacheRecordIds.size() > 0)
            {
                query += ' WHERE Id IN: cacheRecordIds '  + (String.isNotBlank(queryParam.whereClause) ? queryParam.whereClause : '' );
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

}