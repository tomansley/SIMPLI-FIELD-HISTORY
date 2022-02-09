/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-14-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-13-2021   tom.h.ansley@medtronic.com   Initial Version
**/
public with sharing class HelperRecordType {

    private static List<RecordType> recordTypes = null;
    private static Map<String, List<RecordType>> recordTypesByObject = null;
    private static Map<String, RecordType> recordTypesByDevName = null;

    public static List<RecordType> getRecordTypesForObject(String objName)
    {
        if (recordTypesByObject == null) populateRecordTypesByObject();

        return recordTypesByObject.get(objName);
    }

	public static RecordType getRecordType(Id recordTypeId)
	{
        RecordType rType = null;
        
        if (recordTypes == null) getRecordTypes();
        
        for (RecordType recordtype: recordTypes)
        {
            if (recordtype.Id == recordTypeId)
            {
                rType = recordtype;
                break;
            }
        }
        
        return rType;
	}

    public static RecordType getRecordType(String sObjectType, String name)
    {
        RecordType rType = null;
        
        if (recordTypes == null) getRecordTypes();
        
        for (RecordType recordtype: recordTypes)
        {
            if (recordtype.Name == name && recordtype.SobjectType == sObjectType)
            {
                rType = recordtype;
                break;
            }
        }
        
        if (rType == null) throw new HelperRecordTypeException('Record type not found - ' + sObjectType + '.' + name);
        
        return rType;
    }

    /*
     * Method to get a specific record type by the developer name.
     */
    public static RecordType getRecordTypeByDevName(String devName)
    {
        RecordType rType = null;
        
        if (recordTypes == null) getRecordTypes();
        
        rType = recordTypesByDevName.get(devName);

        if (rType == null) throw new HelperRecordTypeException('Record type with dev name not found - ' + devName);
        
        return rType;
    }

    /*
     * Method to get a specific record type by the developer name.
     */
    public static RecordType getRecordTypeByDevName(String obj, String devName)
    {
        RecordType rType = null;
        
        if (recordTypes == null) getRecordTypes();
        
        rType = recordTypesByDevName.get(obj + ':' + devName);

        if (rType == null) throw new HelperRecordTypeException('Record type with dev name not found - ' + devName);
        
        return rType;
    }

    private static void populateRecordTypesByObject()
    {
        if (recordTypes == null) getRecordTypes();

        recordTypesByObject = new Map<String, List<RecordType>>();
        for (RecordType rt: recordTypes)
        {
            String sObjectType = rt.SObjectType;
            List<RecordType> objRTs = recordTypesByObject.get(sObjectType);
            if (objRTs == null)
            {
                objRTs = new List<RecordType>();
                recordTypesByObject.put(sObjectType, objRTs);
            }

            objRTs.add(rt);
        }
    }
    
    private static void getRecordTypes()
    {
        recordTypes = [SELECT Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp 
                       FROM RecordType
                       ORDER BY SObjectType, Name
                       LIMIT 5000]; //limit to pass security review

        recordTypesByDevName = new Map<String, RecordType>();

        for (RecordType recordType: recordTypes)
            recordTypesByDevName.put(recordType.SobjectType + ':' + recordType.DeveloperName, recordType);
                        
        //String debug = '\n\n--------------------- Record Types ---------------------\n';
        //for (RecordType rt: recordTypes)
        //	debug += ' SObject - ' + rt.SObjectType + ', Name - ' + rt.Name + ', Dev Name - ' + rt.DeveloperName + '\n';
        //debug += '--------------------- Record Types ---------------------\n';
        //
        //System.debug(LoggingLevel.DEBUG, debug);
                        
    }
    
    public class HelperRecordTypeException extends Exception { }
}