/**
 * @description       : Helper class to aid in the handling of DML transactions
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 02-09-2022
 * @last modified by  : tom@ansleyllc.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   09-08-2020   tom.h.ansley@medtronic.com   Initial Version
**/
public with sharing class HelperDatabase {

    //--------------------------------------------------------------------------------------------------------------------------
    // INSERT
    //--------------------------------------------------------------------------------------------------------------------------

    public static Database.SaveResult[] insertRecords(List<SObject> data) 
    {

        return insertRecords(data, true); 
    }

    public static Database.SaveResult[] insertRecords(List<SObject> data, Boolean allOrNone) 
    {

        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.CREATABLE, data);

        List<Database.SaveResult> results = Database.insert(dec.getRecords(), allOrNone);


        return results;
    }

    public static Database.SaveResult[] insertRecord(SObject data) 
    {
        List<SObject> records = new List<SObject>();
        records.add(data);

        return insertRecords(records);
    }

    public static List<Database.UpsertResult> upsertRecords(List<SObject> data, String objAPIName) 
    {
        return upsertRecords(data, objAPIName, null, true); 
    }

    public static List<Database.UpsertResult> upsertRecords(List<SObject> data, String objAPIName, String externalIdField, Boolean allOrNone) 
    {
        List<Database.UpsertResult> results = null;

        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.UPSERTABLE, data);        

        if (externalIdField != null)
        {
            Schema.SObjectField field = HelperSchema.getFieldSchema(objAPIName, externalIdField);
            results = Database.upsert(dec.getRecords(), field, allOrNone);
        } else {    
            results = Database.upsert(dec.getRecords(), allOrNone);
        }

        return results;        
    }

}