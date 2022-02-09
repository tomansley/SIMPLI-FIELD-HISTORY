/*
 * Class to handle the querying and manipulation of meta data information.
 */
public with sharing class HelperMetadata {
    
    public static Map<String, Metadata_Type_Name__mdt> metadataTypes = new Map<String, Metadata_Type_Name__mdt>();

    /*
     * Method which, given the name of the meta data and a field name and value returns the list of 
     * meta data that matches the provided fields criteria. Note that this method returns the data 
     * in no specific order. Also, the name that should be provided to retrieve the meta data comes 
     * from the Metadata_Type_Name__mdt table. The label should be provided. All fields in the table 
     * are returned.
     */
    public static List<SObject> getMetaData(String name, Map<String, String> criteria)
    {
        
        if (metadataTypes.get(name) == null)
        {
            List<Metadata_Type_Name__mdt> types = [SELECT MasterLabel, DeveloperName, Metadata_API_Name__c FROM Metadata_Type_Name__mdt WHERE MasterLabel = :name];
            
            if (types.size() == 0) throw new UtilityMetaDataException('Cannot find requested metadata with name - ' + name);
            
            metadataTypes.put(name, types[0]);
        }
        
        //we build the SOQL query to get the data based on the returned API information.        
        Map<String, Schema.SObjectField> objFields = HelperSchema.getFieldsForObject(metadataTypes.get(name).Metadata_API_Name__c, HelperSchema.NAME);
        
        //make the WHERE clause
        String whereClause = ' WHERE ';
        for (String criteriaKey: criteria.keySet())
        {
            Schema.SObjectField field = HelperSchema.getFieldByKey(metadataTypes.get(name).Metadata_API_Name__c, criteriaKey, HelperSchema.LABEL);
            
            Schema.DisplayType dType = HelperSchema.getFieldType(metadataTypes.get(name).Metadata_API_Name__c, field.getDescribe().getName());
            
            if (dType == Schema.DisplayType.Boolean
            	|| dType == Schema.DisplayType.Date
            	|| dType == Schema.DisplayType.DateTime)
            	whereClause += field + ' = ' + String.escapeSingleQuotes(criteria.get(criteriaKey)) + ' AND ';
            else
                whereClause += field + ' = \'' + String.escapeSingleQuotes(criteria.get(criteriaKey)) + '\' AND ';
        }
        
        whereClause = whereClause.removeEnd(' AND ');
        
        String soql = 'SELECT ' + String.escapeSingleQuotes(String.join(new List<String>(objFields.keySet()), ',')) + ' FROM ' + String.escapeSingleQuotes(metadataTypes.get(name).Metadata_API_Name__c) + whereClause;
        
        HelperSchema.checkSelectAccessible(soql);

        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.READABLE, Database.query(soql));
        
        List<SObject> metaData = (List<SObject>) dec.getRecords();
        
        return metaData;
    }

    public class UtilityMetaDataException extends Exception { }

}