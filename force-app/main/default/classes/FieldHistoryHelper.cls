/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 02-09-2022
 * @last modified by  : tom@ansleyllc.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-13-2021   tom.h.ansley@medtronic.com   Initial Version
**/
global with sharing class FieldHistoryHelper {


    /**
    * @description Method which can be called by a trigger to process the new and old records. This is the only method
    *              made available through the API which can be used by the end user developers.
    * @author tom.h.ansley@medtronic.com | 01-13-2021 
    * @param newRecords new records that are being processed by the trigger. NOTE if records are being deleted this variable will be null.
    * @param oldRecords old record data for those records that are being processed. NOTE if records are being inserted this variable will be null.
    **/
    global static void processFieldHistoryTracking(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        if (Trigger.isAfter)
        {
    
            if (Trigger.isInsert)
            {
                handleFieldHistoryTracking(newRecords, null);
    
            } else if (Trigger.isUpdate)
            {
                handleFieldHistoryTracking(newRecords, oldRecords);
            
            } else if (Trigger.isDelete)
            {
                handleFieldHistoryTracking(null, oldRecords);
            }
        
        }
    }

    /*
     * Method to identify whether any fields in the provided SObject data 
     * is to have their history tracked, and if so, starts the process.
     */
	public static Map<Id, List<String>> handleFieldHistoryTracking(List<SObject> newRecords, Map<Id, SObject> oldRecords)
	{
		Map<Id, List<String>> allObjChanges = new Map<Id, List<String>>();
		Map<Id, SObject> changedRecords = new Map<Id, SObject>();
		
		System.debug(LoggingLevel.DEBUG, 'Starting handleFieldHistoryTracking');
		
		try {
			if (newRecords == null) return null;
			if (newRecords.size() == 0) return new Map<Id, List<String>>();
			
			//1. get the type and label of the object we are dealing with.
			String objType = HelperSchema.getObjectType(newRecords[0]);
			String objLabel = HelperSchema.getObjectLabel(newRecords[0]);		
			
			System.debug(LoggingLevel.DEBUG, 'Object Type - ' + objType + ', Object Label - ' + objLabel);
			
			//2. get all field configurations for the given object type.
			Map<String, String> criteria = new Map<String, String>();
			criteria.put('Object API Name', objType);
			criteria.put('Is Active', 'true');
			
			List<Field_History_Setting__mdt> fieldConfigs = (List<Field_History_Setting__mdt>) HelperMetaData.getMetaData('Field History Setting', criteria);
			
			if (fieldConfigs.size() == 0) return new Map<Id, List<String>>();
			
			System.debug(LoggingLevel.DEBUG, 'Field configs retrieved for object of type ' + objType + ' - ' + fieldConfigs);
			
			for (SObject newRecord: newRecords)
			{

				List<String> objChanges = allObjChanges.get(newRecord.Id);
				
				if (objChanges == null)
					objChanges = new List<String>();
				
				for (Field_History_Setting__mdt fieldConfig: fieldConfigs)
				{

					Object newFieldData = null;
					try {
						newFieldData = newRecord.get(fieldConfig.Field_API_Name__c);
					} catch (Exception ex)
					{
						System.debug(LoggingLevel.ERROR, 'The field with API name ' + fieldConfig.Field_API_Name__c + ' cannot be found on the SObject ' + objType + '. Please check the field history configuration - ' + fieldConfig.MasterLabel);	
					}	
							
					//if we are inserting and we have a value then add to records 
					if (oldRecords == null && newFieldData != null)
					{
						changedRecords.put(newRecord.Id, newRecord);
						objChanges.add(fieldConfig.Field_API_Name__c);
					
						System.debug(LoggingLevel.DEBUG, 'Field history to be updated (INSERT) - ' + fieldConfig.Field_Label__c + '(' + fieldConfig.Field_API_Name__c + ') - ' + newRecord.get(fieldConfig.Field_API_Name__c));
						
					//if we are updating
					} else if (oldRecords != null) {
						
						SObject oldRecord = oldRecords.get(newRecord.Id);
						
						Object oldFieldData = oldRecord.get(fieldConfig.Field_API_Name__c);
						
						if (newFieldData != oldFieldData)
						{
							changedRecords.put(newRecord.Id, newRecord);
							objChanges.add(fieldConfig.Field_API_Name__c);					

							System.debug(LoggingLevel.DEBUG, 'Field history to be updated (UPDATE) - ' + fieldConfig.Field_Label__c + '(' + fieldConfig.Field_API_Name__c + ') - FROM - ' + oldRecord.get(fieldConfig.Field_API_Name__c) + ' - TO - ' + newRecord.get(fieldConfig.Field_API_Name__c));
						}
						
					} 
						
				}

				if (!objChanges.isEmpty())
					allObjChanges.put(newRecord.Id, objChanges); 
				
			}
			
			//only add to transaction queue if we have field updates.
			if (changedRecords.size() > 0)
			{
				FieldHistoryQ asyncJob = new FieldHistoryQ(changedRecords.values(), oldRecords, allObjChanges, fieldConfigs);
				System.enqueueJob(asyncJob);
			}
		} catch (Exception e) {
            throw new FieldHistoryException('There was an error during field history processing - ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		return allObjChanges;
	}
	
	/*
	 * Method to get the highest change index for a list of provided field history records.
	 */
	public static Decimal getHighestChangeIndex(List<Field_History__c> fieldHistories)
	{
		Decimal index = 0;
		
		if (fieldHistories == null) return index;
		
		for (Field_History__c fieldHistory: fieldHistories)
		{
			if (fieldHistory.Change_Index__c > index)
				index = fieldHistory.Change_Index__c;
		}
		
		return index;
    }
    
    public static List<Field_History__c> getFieldHistory(String objType, Set<String> objIds)
    {
        String soql = 'SELECT Id, ' + 
                             'simpli_fhist__Change_Index__c, ' + 
                             'simpli_fhist__Field_API_Name__c, ' + 
                             'simpli_fhist__Field_Name__c, ' + 
                             'simpli_fhist__Start_Date__c, ' + 
                             'simpli_fhist__End_Date__c, ' + 
                             'RecordTypeId, ' + 
                             'RecordType.Name, ' + 
                             'simpli_fhist__To_Value__c, ' + 
                             'simpli_fhist__From_Value__c, ' + 
                             'simpli_fhist__Previous_Cumulative_Duration__c, ' + 
                             'simpli_fhist__Running_User__c ' + 
                      'FROM simpli_fhist__Field_History__c ' + 
                      'WHERE ' + objType + '__c IN :objIds ' +
                      'ORDER BY ' + objType + '__c, Change_Index__c ASC';
                      
        System.debug(LoggingLevel.DEBUG, 'SOQL - ' + soql);

        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.READABLE, Database.query(soql));

        List<Field_History__c> results = (List<Field_History__c>) dec.getRecords();

        return results;
    }
	
}