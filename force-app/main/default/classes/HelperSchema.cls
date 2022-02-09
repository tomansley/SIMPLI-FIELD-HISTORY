/**
 * @File Name          : HelperSchema.cls
 * @Description        : 
 * @Author             : tom.h.ansley@medtronic.com
 * @Group              : 
 * @Last Modified By   : tom.h.ansley@medtronic.com
 * @Last Modified On   : 01-14-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   tom.h.ansley@medtronic.com     Initial Version
**/
public with sharing class HelperSchema {

	public static Map<String, Schema.SObjectType> objectDescribeByName = new Map<String, Schema.SObjectType>();
	public static Map<String, Schema.SObjectType> objectDescribeByPrefix = new Map<String, Schema.SObjectType>();
	public static Map<String, Map<String, Schema.SObjectField>> objectDescribeFieldsByObjectNameAndKey = new Map<String, Map<String, Schema.SObjectField>>();

	public static final String LABEL = 'label';
    public static final String NAME = 'name';
    public static final String DOMAIN_NAME = 'simpli_fhist__';

    public static final String ACCESSIBLE = 'accessible';
    public static final String CREATABLE  = 'creatable';
    public static final String DELETABLE  = 'deletable';
    public static final String MERGEABLE  = 'mergeable';
    public static final String QUERYABLE = 'queryable';
    public static final String SEARCHABLE = 'searchable';
    public static final String UNDELETABLE = 'undeletable';
    public static final String UPDATEABLE = 'updateable';

	/*
	 * Method to return a describe result for a given object and field.
     * HelperSchema.getFieldDescribeResult('Opportunity','Alias');  
	 */
	public static Schema.DescribeFieldResult getFieldDescribeResult(String obj, String field)
	{
        System.debug(LoggingLEvel.DEBUG, 'getFieldDescribeResult(' + obj + ', ' + field + ')');
        Schema.DescribeFieldResult result = null;
        
        initSObjectSchema(obj);

        //see if there is a regular field name
        Schema.SObjectField sField = getFieldByKey(obj, field, NAME);

        //see if there is a field with an Id at the end. i.e. ContactId
        if (sField == null)
            sField = getFieldByKey(obj, field + 'Id', NAME);
        
        //see if there is a lookup field name
        if (sField == null)
            sField = getFieldByKey(obj, field.removeEnd('__r') + '__c', NAME);

        if (sField != null)
             result = sField.getDescribe();

            //see if we are working with a relationship field
        if (result == null)
        {
            List<Schema.ChildRelationship> relationships = getObjectSchema(obj).getChildRelationships();

            for (Schema.ChildRelationship relationship: relationships)
            {
                if (relationship.getRelationshipName() == field)
                {
                    result = getFieldDescribeResult(relationship.getChildSObject().getDescribe().getName(), field);
                }
            }
        }

		return result;
	}

	/*
	 * Method that returns the describe result of an SObject.
     * System.debug(LoggingLevel.DEBUG, 'RESULT - ' + HelperSchema.getObjectSchema('simpli_fhist__List_View_Org_Wide_Setting__mdt'));
	 */
	public static Schema.DescribeSObjectResult getObjectSchema(String name)
	{
		initSObjectSchema(name);
        Schema.SObjectType objType = objectDescribeByName.get(name);
        if (objType != null)
            return objType.getDescribe();
        
        return null;
    }
    

	public static String getObjectType(SObject obj)
	{
		return obj.getSObjectType().getDescribe().getName();
    }
    
    public static Schema.SObjectField getFieldSchema(String obj, String field)
    {
        return getFieldByKey(obj, field, NAME);
    }
    
    public static String getObjectLabel(Sobject obj)
	{
		return obj.getSObjectType().getDescribe().getLabel();
	}
	
	public static Schema.DisplayType getFieldType(String obj, String field)
	{
		
		Schema.DisplayType fieldType = null;
		
		Schema.SObjectField objField = getFieldByKey(obj, field, NAME);
		
		if (objField != null)
			fieldType = objField.getDescribe().getType();
		
		return fieldType;
		
    }
    
	/*
	 * Method which, given an object API name and a field label or name returns the schema of the field.
	 */
	public static Schema.SObjectField getFieldByKey(String obj, String key, String keyType)
	{

        //initialize if necessary
		initSObjectSchema(obj);

		//get the fields of the object in question
		Map<String, Schema.SObjectField> fieldsByKeyType = objectDescribeFieldsByObjectNameAndKey.get(obj + ':' + keyType);

		//get the field by key
		Schema.SObjectField field = fieldsByKeyType.get(key.toLowerCase());

		return field;
		
	}
	
	/*
	 * Method which given an object API name returns those fields that are available for the object.
	 * The returned map has its keys based on either the fields Label or Name, depending on the 
	 * provided keyType.
     * System.debug(LoggingLevel.DEBUG, 'RESULT - ' + HelperSchema.getFieldsForObject('simpli_fhist__List_View_Org_Wide_Setting__mdt', HelperSchema.NAME));
	 */
	public static Map<String, Schema.SObjectField> getFieldsForObject(String obj, String keyType)
	{
		//initialize if necessary
		initSObjectSchema(obj);
		
		return objectDescribeFieldsByObjectNameAndKey.get(obj + ':' + keyType);

    }
        
    public static void checkObjectPermissions(String objAPIName, String action)
    {
        if (objAPIName == 'simpli_fhist__Field_History__c')
        { 
            if (action == CREATABLE) checkFileUploadConfigCreatable();
            else if (action == UPDATEABLE) checkFileUploadConfigUpdateable();
            else throw new FieldHistoryException('No permission check for simpli_fhist__Field_History__c with action - ' + action);

        } else {
            if (action == CREATABLE) checkObjectCreatable(objAPIName);
            else if (action == UPDATEABLE) checkObjectUpdateable(objAPIName);
            else throw new FieldHistoryException('No permission check for ' + objAPIName + ' with action - ' + action);
            
        }
    }

	private static void checkFileUploadConfigCreatable()
    {
        HelperSchema.checkObjectCreatable('simpli_fhist__Field_History__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Account__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Contact__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Event__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__User__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__CampaignMember__c');

        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Change_Index__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__End_Date__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Event__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Field_API_Name__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Field_Name__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__From_Value__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Previous_Cumulative_Duration__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Running_User__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__Start_Date__c');
        HelperSchema.checkObjectFieldCreateable('simpli_fhist__Field_History__c', 'simpli_fhist__To_Value__c');
    }

	private static void checkFileUploadConfigUpdateable()
    {
        HelperSchema.checkObjectUpdateable('simpli_fhist__Field_History__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Account__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Contact__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Event__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__User__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__CampaignMember__c');

        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Change_Index__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__End_Date__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Event__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Field_API_Name__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Field_Name__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__From_Value__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Previous_Cumulative_Duration__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Running_User__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__Start_Date__c');
        HelperSchema.checkObjectFieldUpdateable('simpli_fhist__Field_History__c', 'simpli_fhist__To_Value__c');
    }
	
	//------------------------------------------------
	// PRIVATE METHODS BELOW
	//------------------------------------------------
    
    private static void initSObjectSchema(String obj)
    {
        initSObjectSchema(obj, true);
    }

	/*
	 * Method to initialize an sobject schema if it hasn't already been initialized. This has a small hack
	 * in it to detect if an object name being requested needs a domain prefix. If it does then it rerequests
	 * the schema. Once the schema is returned it places the schema into the map with both the domain prefix
	 * and without it. This hack ensures that tests will run in both the package dev org and other orgs.
     * HelperSchema.initSObjectSchema('simpli_fhist__File_Upload_Config__c');
     * HelperSchema.initSObjectSchema('');
	 */
	private static void initSObjectSchema(String obj, Boolean allowRecurring)
	{
		//if this object has not been described yet get the data
		if (objectDescribeByName.get(obj) == null)
		{
			System.debug(LoggingLevel.DEBUG, 'Trying to initialize schema with name - ' + obj);
			Schema.SObjectType objSchema = Schema.getGlobalDescribe().get(obj);
			if (objSchema != null)
			{
				System.debug(LoggingLevel.DEBUG, 'Found schema with name - ' + obj);
                objectDescribeByName.put(obj, objSchema);
                
                List<Schema.SObjectField> fields = objSchema.getDescribe().fields.getMap().values();

                Map<String,Schema.SObjectField> fieldsByLabel = new Map<String,Schema.SObjectField>();
                Map<String,Schema.SObjectField> fieldsByName = new Map<String,Schema.SObjectField>();

                for (Schema.SObjectField objField: fields)
                {
                    fieldsByName.put(objField.getDescribe().getName().toLowerCase(), objField);
                    fieldsByLabel.put(objField.getDescribe().getLabel().toLowerCase(), objField);
                }
				objectDescribeFieldsByObjectNameAndKey.put(obj + ':' + LABEL, fieldsByLabel);
				objectDescribeFieldsByObjectNameAndKey.put(obj + ':' + NAME, fieldsByName);

				//if schema contain "simpli_lv" then remove and try again (this is the hack)
				if (obj.contains(DOMAIN_NAME))
				{
					objectDescribeByName.put(obj.removeStart(DOMAIN_NAME), objSchema);
    
                    objectDescribeFieldsByObjectNameAndKey.put(obj.removeStart(DOMAIN_NAME) + ':' + LABEL, fieldsByLabel);
                    objectDescribeFieldsByObjectNameAndKey.put(obj.removeStart(DOMAIN_NAME) + ':' + NAME, fieldsByName);
				}

			} else if (allowRecurring) {
				System.debug(LoggingLevel.DEBUG, 'NO schema with name - ' + obj);
				initSObjectSchema(DOMAIN_NAME + obj, false);
			}
		}
		
	}

	private static String scrubFieldName(String fieldName)
    {
        //remove whitespace
        fieldName = fieldName.deleteWhitespace();

        //remove toLabel keyword
        if (fieldName.contains('toLabel(')) fieldName = fieldName.substringBetween('(', ')');
        
        return fieldName;
    }


    //---------------------------------------------------------------------------------
    // ACCESSIBILITY METHODS
    //---------------------------------------------------------------------------------
    public static void checkSelectAccessible(String selectStr) 
    {

        List<String> fields = selectStr.substringBetween('SELECT', 'FROM').split(',');
        
        String objAPIName = null;
        if (!selectStr.containsIgnoreCase('WHERE'))
            objAPIName = selectStr.substringAfter('FROM ');
        else
            objAPIName = selectStr.substringBetween('FROM ', ' WHERE');
        
        HelperSchema.checkObjectAccessible(objAPIName);

        for (String field: fields)
        {
            //do security validation on additional fields. If the field is a lookup the security is performed later
            if (!field.contains('.'))
                HelperSchema.checkObjectFieldAccessible(objAPIName, field);
        }
 
    }
    
    /*
	 * Method to determine if an SObject field is accessible. This is used
	 * for security to ensure user is allowed to see a field for the given object.
	 */
	public static Boolean checkObjectFieldAccessible(String objName, String fieldName, Boolean throwExc)
	{
		System.debug(LoggingLevel.DEBUG, 'checkObjectFieldAccessible called with objName - ' + objName + '.' + fieldName.deleteWhitespace());

        fieldName = scrubFieldName(fieldName);

        Schema.DescribeFieldResult fieldDesc = getFieldDescribeResult(objName, fieldName);
		if (fieldDesc != null && fieldDesc.isAccessible()) {
			return true;
		} else {
			if (throwExc)
				throw new FieldHistoryException('Field with name ' + objName + '.' + fieldName + ' is not accessible or does not exist. Please check user permissions');
			return false;
		}
	}

	/*
	 * Method to determine if an SObject field is accessible. This is used
	 * for security to ensure user is allowed to see a field for the given object.
	 */
	public static void checkObjectFieldAccessible(String objName, String fieldName)
	{
		checkObjectFieldAccessible(objName, fieldName, true);
	}

    /*
	 * Method to determine if an SObject field is createable. This is used
	 * for security to ensure user is allowed to set a field for the given object.
	 */
	public static Boolean checkObjectFieldCreateable(String objName, String fieldName, Boolean throwExc)
	{
		System.debug(LoggingLevel.DEBUG, 'checkObjectFieldCreateable called with objName - ' + objName + '.' + fieldName.deleteWhitespace());

        fieldName = scrubFieldName(fieldName);

		if (getFieldDescribeResult(objName, fieldName).isCreateable()) {
			return true;
		} else {
			if (throwExc)
				throw new FieldHistoryException('Field with name ' + objName + '.' + fieldName.deleteWhitespace() + ' is not creatable or does not exist. Please check user permissions');
			return false;
		}
	}

	/*
	 * Method to determine if an SObject field is createable. This is used
	 * for security to ensure user is allowed to set a field for the given object.
	 */
	public static void checkObjectFieldCreateable(String objName, String fieldName)
	{
		checkObjectFieldCreateable(objName, fieldName, true);
	}

	/*
	 * Method to determine if an SObject field is createable. This is used
	 * for security to ensure user is allowed to set a field for the given object.
	 */
	public static Boolean checkObjectFieldUpdateable(String objName, String fieldName, Boolean throwExc)
	{
		System.debug(LoggingLevel.DEBUG, 'checkObjectFieldUpdateable called with objName - ' + objName + '.' + fieldName.deleteWhitespace());

        fieldName = scrubFieldName(fieldName);

		if (getFieldDescribeResult(objName, fieldName).isUpdateable()) {
			return true;
		} else {
			if (throwExc)
				throw new FieldHistoryException('Field with name ' + objName + '.' + fieldName + ' is not updateable or does not exist. Please check user permissions');
			return false;
		}
	}

	/*
	 * Method to determine if an SObject field is createable. This is used
	 * for security to ensure user is allowed to set a field for the given object.
	 */
	public static void checkObjectFieldUpdateable(String objName, String fieldName)
	{
		checkObjectFieldUpdateable(objName, fieldName, true);
	}

	/*
	 * Method to determine if an SObject is createable. This is used
	 * for security to ensure user is allowed to create records for the given object.
	 */
	public static Boolean checkObjectCreateable(String objName, Boolean throwExc)
	{
		System.debug(LoggingLevel.DEBUG, 'checkObjectCreateable called with objName - ' + objName);

		if (getObjectSchema(objName).isCreateable()) {
			return true;
		} else {
			if (throwExc)
				throw new FieldHistoryException('Records of type ' + objName + ' are not creatable or do not exist. Please check user permissions');
			return false;
		}
	}

	/*
	 * Method to determine if an SObject is createable. This is used
	 * for security to ensure user is allowed to create records for the given object.
	 */
	public static void checkObjectCreatable(String objName)
	{
		checkObjectCreateable(objName, true);
	}

	/*
	 * Method to determine if an SObject is accessible. This is used
	 * for security to ensure user is allowed to create records for the given object.
	 */
	public static Boolean checkObjectAccessible(String objName, Boolean throwExc)
	{
		System.debug(LoggingLevel.DEBUG, 'checkObjectAccessible called with objName - ' + objName);

		if (getObjectSchema(objName).isAccessible()) {
			return true;
		} else {
			if (throwExc)
				throw new FieldHistoryException('Records of type ' + objName + ' are not accessible or do not exist. Please check user permissions');
			return false;
		}
	}

	/*
	 * Method to determine if an SObject is accessible. This is used
	 * for security to ensure user is allowed to create records for the given object.
	 */
	public static void checkObjectAccessible(String objName)
	{
		checkObjectAccessible(objName, true);
	}

    /*
	 * Method to determine if an SObject is createable. This is used
	 * for security to ensure user is allowed to create records for the given object.
	 */
	public static Boolean checkObjectUpdateable(String objName, Boolean throwExc)
	{
		System.debug(LoggingLevel.DEBUG, 'checkObjectUpdateable called with objName - ' + objName);

		if (getObjectSchema(objName).isUpdateable()) {
			return true;
		} else {
			if (throwExc)
				throw new FieldHistoryException('Records of type ' + objName + ' are not updateable or do not exist. Please check user permissions');
			return false;
		}
	}

	/*
	 * Method to determine if an SObject is createable. This is used
	 * for security to ensure user is allowed to create records for the given object.
	 */
	public static void checkObjectUpdateable(String objName)
	{
		checkObjectUpdateable(objName, true);
	}

}