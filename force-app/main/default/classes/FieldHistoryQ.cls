/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 02-01-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-13-2021   tom.h.ansley@medtronic.com   Initial Version
**/
public without sharing class FieldHistoryQ implements Queueable {

	private Map<String, Map<Id, SObject>> vLookupsByFieldName      = null; //holds all lookup data by field name
	private List<SObject> newRecords                               = null; //SObjects holding the NEW field change values.
	private Map<Id, SObject> oldRecords                            = null; //SObjects holding the OLD field change values.
	private Map<Id, List<String>> allObjChanges                    = null; //map holding all field changes for each SObject in newRecords.
	private String objLabel                                        = null; //Object Label e.g. Account, CVG Sales And Implant
	private String objType                                         = null; //Object API Name e.g. Account, CVG_Sales_And_Implants__c
    private List<Field_History_Setting__mdt> fieldConfigs = null; //holds all the  tracking metadata for the provided objects
	
	public FieldHistoryQ(List<SObject> newRecords, Map<Id, SObject> oldRecords, Map<Id, List<String>> allObjChanges, List<Field_History_Setting__mdt> fieldConfigs)
	{
		
		if (newRecords == null || allObjChanges == null) throw new FieldHistoryException('The input variables newRecords and allObjChanges cannot be null when instantiating FieldHistoryQ');
		
		this.fieldConfigs  = fieldConfigs;
		this.newRecords    = newRecords;
		this.oldRecords    = oldRecords;
		this.allObjChanges = allObjChanges;
		this.objType       = HelperSchema.getObjectType(newRecords[0]);
		this.objLabel      = HelperSchema.getObjectLabel(newRecords[0]);		
		
		String debug = '\n-----------------------------------------\n';
		debug += 'Creating FieldHistoryQ\n';
		debug += '--- New SObject Size   - ' + newRecords.size() + '\n';
		if (oldRecords != null)
			debug += '--- Old SObject Size   - ' + oldRecords.size() + '\n';
		else 
			debug += '--- Old SObject Size   - null\n';
		debug += '--- Obj Changes Size   - ' + allObjChanges.size() + '\n';
		debug += '--- Obj Type           - ' + objType + '\n';
		debug += '-----------------------------------------\n';
		System.debug(debug);
	}
	
	public void execute(System.QueueableContext context)
	{
		
		String debug = '\n-----------------------------------------\n';
		debug += 'Starting Processing For FieldHistoryQ\n';
		debug += '--- New SObject Size   - ' + newRecords.size() + '\n';
		if (oldRecords != null)
			debug += '--- Old SObject Size   - ' + oldRecords.size() + '\n';
		else 
			debug += '--- Old SObject Size   - null\n';
		debug += '--- Obj Changes Size   - ' + allObjChanges.size() + '\n';
		debug += '--- Obj Type           - ' + objType + '\n';
		debug += '-----------------------------------------\n';
		System.debug(LoggingLevel.DEBUG, debug);
		
		RecordType rt = HelperRecordType.getRecordType('simpli_fhist__Field_History__c', objType);
		
		if (rt == null) throw new FieldHistoryException('The provided object does not have an associated record type (' + objLabel + '). Please check the  Field History object to resolve');
		
		Map<String, Schema.SObjectField> historyFields = HelperSchema.getFieldsForObject('simpli_fhist__Field_History__c', HelperSchema.NAME);

		//we may have configured fields which are lookups in which case we get the lookup objects name
		setVLookupData(newRecords, oldRecords, fieldConfigs);

		//--------------------------------------------------------------------------------------------
		//1. First thing we do is create the SOQL statement to get all the existing field history for 
		//   the fields that have been changed. Note that we get all fields for the  field 
		//   history object dynamically so that if a new object is added as a lookup the code will still 
		//   work as expected.
		//--------------------------------------------------------------------------------------------

		//we use the objType to query on the lookup field. But for standard objects
		//the object type will not have an __c. So we add it.
		String objAPIName = objType;
		if (!objAPIName.contains('__c'))
			objAPIName += '__c';

		String soql = 'SELECT ';
		
		for (Schema.SObjectField field: historyFields.values())
			soql += field.getDescribe().getName() + ', ';
			
		soql = soql.removeEnd(', ');
		
		soql += ' FROM Field_History__c WHERE RecordTypeId = \'' + rt.Id + '\' AND (';
		
		for (Id objId: allObjChanges.keySet())
		{
			
			List<String> objFieldChanges = allObjChanges.get(objId);
			
			for (String fieldChange: objFieldChanges)
			{
				soql += '(' + objAPIName + ' = \'' + objId + '\' AND Field_API_Name__c = \'' + fieldChange + '\') OR ';
			}
		}
		
		soql = soql.removeEnd(' OR ');
		soql += ') ORDER BY ' + objAPIName + ' ASC, Field_API_Name__c ASC, Change_Index__c DESC';
		
		System.debug(LoggingLevel.DEBUG, 'SOQL - ' + soql);
		
        HelperSchema.checkSelectAccessible(soql);
		List<Field_History__c> allObjFieldHistoriesList = Database.query(soql);



		//--------------------------------------------------------------------------------------------
		//2. Now that we have the data we need to organize it by object Id and field API name.
		//   Fortunately we have ordered the data so this should be fairly easy!
		//--------------------------------------------------------------------------------------------
		Map<Id, Map<String, List<Field_History__c>>> allObjFieldHistories = new Map<Id, Map<String, List<Field_History__c>>>();

		for (Field_History__c fieldHistory: allObjFieldHistoriesList)
		{
			
			//1. Get the objects Id
			String objId = (String) fieldHistory.get(objAPIName);
			
			//2. get all field history for the obj
			Map<String, List<Field_History__c>> objFieldHistory = allObjFieldHistories.get(objId);
			
			//3. If no history yet then create map.
			if (objFieldHistory == null)
			{
				objFieldHistory = new Map<String, List<Field_History__c>>();
				allObjFieldHistories.put(objId, objFieldHistory);
			}
			
			//4. get the history for this particular field 
			List<Field_History__c> fieldHistoryList = objFieldHistory.get(fieldHistory.Field_API_Name__c);
			
			//5. If no field history yet then create map
			if (fieldHistoryList == null)
			{
				fieldHistoryList = new List<Field_History__c>();
				objFieldHistory.put(fieldHistory.Field_API_Name__c, fieldHistoryList);
			}
			
			fieldHistoryList.add(fieldHistory);
						
		}

		System.debug(LoggingLevel.DEBUG, 'All Obj Field History - ' + allObjFieldHistories);

		//--------------------------------------------------------------------------------------------
		//3. Now that we have the data organized we go through the new changes and process them.
		//
		//   a) Update end date of prior field history record (if it exists)
		//   b) Create new field history record.
		//--------------------------------------------------------------------------------------------
		List<Field_History__c> allObjFieldHistoriesUpserted = new List<Field_History__c>();

		for (SObject newRecord: newRecords)
		{

			System.debug(LoggingLevel.DEBUG, 'Working on new record - ' + newRecord);

			//get the objects field history
			Map<String, List<Field_History__c>> objFieldHistories = allObjFieldHistories.get(newRecord.Id);

			System.debug(LoggingLevel.DEBUG, 'Object field histories - ' + objFieldHistories);

			//get the list of fields that have changed.
			List<String> objChanges = allObjChanges.get(newRecord.Id);
			
			System.debug(LoggingLevel.DEBUG, 'Fields that have changed for object - ' + objChanges);
			
			if (objChanges == null)
				break;
				
			for (String objChange: objChanges)
			{

				System.debug(LoggingLevel.DEBUG, 'Working on change - ' + objChange);

				Decimal highestIndex = 0;
				Field_History__c lastFieldHistory = null;
				
				//only handle previous field histories if we have any to deal with.
				if (objFieldHistories != null)
				{
					List<Field_History__c> fieldHistories = objFieldHistories.get(objChange);

					highestIndex = FieldHistoryHelper.getHighestChangeIndex(fieldHistories);
					
					System.debug(LoggingLevel.DEBUG, 'Highest Index - ' + highestIndex);
					
					// a) Update end date of prior field history record (if it exists)
					if (fieldHistories != null && fieldHistories.size() > 0)
					{
						lastFieldHistory = fieldHistories.get(0);
						lastFieldHistory.End_Date__c = System.today();
						
						System.debug(LoggingLevel.DEBUG, 'Field history record updated - ' + lastFieldHistory);
						
						allObjFieldHistoriesUpserted.add(lastFieldHistory);
						
					}

				}
				
				Schema.DescribeFieldResult fieldDescribe = HelperSchema.getFieldByKey(objType, objChange, HelperSchema.NAME).getDescribe();

				//  b) Create new field history record.
				Field_History__c newFieldHistory = new Field_History__c();
				newFieldHistory.put(objAPIName, String.escapeSingleQuotes(newRecord.Id));
				newFieldHistory.Change_Index__c   = highestIndex + 1;
				newFieldHistory.Field_API_Name__c = objChange;
				newFieldHistory.Field_Name__c     = fieldDescribe.getLabel();
				newFieldHistory.Start_Date__c     = System.today();
				newFieldHistory.RecordTypeId      = rt.Id;

				//if we have a lookup field then go get the name of the object.
				if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE)
				{

					//get the list of vlookup values
					Map<Id, SObject> vLookups = vLookupsByFieldName.get(fieldDescribe.getName());

					//get the lookup value specific to this object.
					SObject obj = vLookups.get(String.valueOf(newRecord.get(objChange)));

					if (obj != null && obj.get('Name') != null)
						newFieldHistory.To_Value__c = String.valueOf(obj.get('Name'));

					if (oldRecords != null) //it could be an insert
					{
						//get the lookup value specific to this object.
						obj = vLookups.get(String.valueOf(oldRecords.get(newRecord.Id).get(objChange)));

						if (obj != null && obj.get('Name') != null)
							newFieldHistory.From_Value__c = String.valueOf(obj.get('Name'));

					}

				//if its just a regular field.
				} else {

					newFieldHistory.To_Value__c = String.valueOf(newRecord.get(objChange));

					if (oldRecords != null)
						newFieldHistory.From_Value__c = String.valueOf(oldRecords.get(newRecord.Id).get(objChange));

				}
					
				
				if (lastFieldHistory != null)
					newFieldHistory.Previous_Cumulative_Duration__c = lastFieldHistory.Cumulative_Duration__c;
				
				//get the running contact
    			newFieldHistory.Running_User__c       = UserInfo.getUserId();
				
				System.debug(LoggingLevel.DEBUG, 'Field history record created - ' + newFieldHistory);

				allObjFieldHistoriesUpserted.add(newFieldHistory);
				
			}
			
		}
		
		HelperDatabase.upsertRecords(allObjFieldHistoriesUpserted, 'simpli_fhist__Field_History__c');
		
	}

	private void setVLookupData(List<SObject> newRecords, Map<Id, SObject> oldRecords, List<Field_History_Setting__mdt> fieldConfigs)
	{
		vLookupsByFieldName = new Map<String, Map<Id, SObject>>();

		//for all metadata fields being tracked.
		for (Field_History_Setting__mdt fieldConfig: fieldConfigs)
		{
			//if the field is a LOOKUP
			if (HelperSchema.getFieldType(fieldConfig.Object_API_Name__c, fieldConfig.Field_API_Name__c) == Schema.DisplayType.REFERENCE)
			{
				//get all Ids in that field for NEW and OLD records
				Set<Id> fieldIds = new Set<Id>();
				for (SObject newObj: newRecords)
				{
					if (newObj.get(fieldConfig.Field_API_Name__c) != null)
						fieldIds.add(String.valueOf(newObj.get(fieldConfig.Field_API_Name__c)));
				}
				if (oldRecords != null)
				{
					for (SObject oldObj: oldRecords.values())
					{
						if (oldObj.get(fieldConfig.Field_API_Name__c) != null)
							fieldIds.add(String.valueOf(oldObj.get(fieldConfig.Field_API_Name__c)));
					}
				}

				String soql = 'SELECT Id, Name FROM ' + fieldConfig.Field_Lookup_Object__c + ' WHERE Id IN :fieldIds';
				System.debug(LoggingLevel.DEBUG, 'SOQL - ' + soql);

                HelperSchema.checkSelectAccessible(soql);
				vLookupsByFieldName.put(fieldConfig.Field_API_Name__c, new Map<Id, SObject>(Database.query(soql)));

			}
		}

	}

}