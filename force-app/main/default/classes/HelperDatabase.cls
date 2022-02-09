/**
 * @description       : Helper class to aid in the handling of DML transactions
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-13-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   09-08-2020   tom.h.ansley@medtronic.com   Initial Version
**/
public with sharing class HelperDatabase {

    //--------------------------------------------------------------------------------------------------------------------------
    // INSERT
    //--------------------------------------------------------------------------------------------------------------------------

    public static Database.SaveResult[] insertRecords(List<SObject> data, String objAPIName) 
    {

        return insertRecords(data, objAPIName, true); 
    }

    public static Database.SaveResult[] insertRecords(List<SObject> data, String objAPIName, Boolean allOrNone) 
    {

        HelperSchema.checkObjectPermissions(objAPIName, HelperSchema.CREATABLE);

        return Database.insert(data, allOrNone);
    }

    public static Database.SaveResult[] insertRecord(SObject data, String objAPIName) 
    {
        List<SObject> records = new List<SObject>();
        records.add(data);

        return insertRecords(records, objAPIName);
    }

    //--------------------------------------------------------------------------------------------------------------------------
    // UPDATE
    //--------------------------------------------------------------------------------------------------------------------------
/*
    public static Database.SaveResult[] updateRecord(SObject data, String objAPIName) 
    {
        List<SObject> records = new List<SObject>();
        records.add(data);

        return updateRecords(records, objAPIName);
        
    }

    public static Database.SaveResult[] updateRecords(List<SObject> data, String objAPIName) 
    {
        return updateRecords(data, objAPIName, true); 
    }

    public static Database.SaveResult[] updateRecords(List<SObject> data, String objAPIName, Boolean allOrNone) 
    {

        HelperSchema.checkObjectPermissions(objAPIName, HelperSchema.UPDATEABLE);

        return Database.update(data, allOrNone);
        
    }
*/

    //--------------------------------------------------------------------------------------------------------------------------
    // UPSERT
    //--------------------------------------------------------------------------------------------------------------------------

/*    public static List<Database.UpsertResult> upsertRecord(SObject data, String objAPIName) 
    {
        List<SObject> records = new List<SObject>();
        records.add(data);

        return upsertRecords(records, objAPIName);
    }

    public static List<Database.UpsertResult> upsertRecord(SObject data, String objAPIName, String externalIdField) 
    {
        List<SObject> records = new List<SObject>();
        records.add(data);

        return upsertRecords(records, objAPIName, externalIdField, true);
        
    }
*/
    public static List<Database.UpsertResult> upsertRecords(List<SObject> data, String objAPIName) 
    {
        return upsertRecords(data, objAPIName, null, true); 
    }

    public static List<Database.UpsertResult> upsertRecords(List<SObject> data, String objAPIName, String externalIdField, Boolean allOrNone) 
    {

        HelperSchema.checkObjectPermissions(objAPIName, HelperSchema.CREATABLE);
        HelperSchema.checkObjectPermissions(objAPIName, HelperSchema.UPDATEABLE);

        if (externalIdField != null)
        {
            Schema.SObjectField field = HelperSchema.getFieldSchema(objAPIName, externalIdField);
            return Database.upsert(data, field, allOrNone);
        } else 
            return Database.upsert(data, allOrNone);
        
    }

    //--------------------------------------------------------------------------------------------------------------------------
    // DELETE
    //--------------------------------------------------------------------------------------------------------------------------
/*
    public static Database.DeleteResult[] deleteRecords(List<SObject> data, String objAPIName) 
    {

        return deleteRecords(data, objAPIName, true); 
    }

    public static Database.DeleteResult[] deleteRecords(List<SObject> data, String objAPIName, Boolean allOrNone) 
    {

        HelperSchema.checkObjectPermissions(objAPIName, HelperSchema.DELETABLE);

        return Database.delete(data, allOrNone);
    }

    public static Database.DeleteResult[] deleteRecord(SObject data, String objAPIName) 
    {
        List<SObject> records = new List<SObject>();
        records.add(data);

        return deleteRecords(records, objAPIName);
    }
*/
}