/**
 * @File Name          : HelperSchema.cls
 * @Description        : 
 * @Author             : tom.h.ansley@medtronic.com
 * @Group              : 
 * @Last Modified By   : tom@ansleyllc.com
 * @Last Modified On   : 02-09-2022
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

}