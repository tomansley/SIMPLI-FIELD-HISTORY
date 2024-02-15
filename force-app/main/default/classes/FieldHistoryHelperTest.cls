/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 02-14-2024
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-13-2021   tom.h.ansley@medtronic.com   Initial Version
**/
@isTest
public with sharing class FieldHistoryHelperTest 
{

    static testMethod void testBasicAccountInsert() 
    {
        Test.startTest();
            Id acctId = HelperTest.insertAccount('Basic Account Insert Test');
        Test.stopTest();

        Set<String> objIds = new Set<String>();
        objIds.add(acctId);
        List<Field_History__c> acctHist = FieldHistoryHelper.getFieldHistory('Account', objIds);
        System.assertEquals(2, acctHist.size());

        Field_History__c hist = acctHist[0];

        System.assertEquals(1, hist.Change_Index__c);
        System.assertEquals('Name', hist.Field_API_Name__c);
        System.assertEquals('Account Name', hist.Field_Name__c);
        System.assertEquals(System.today(), hist.Start_Date__c);
        System.assertEquals(null, hist.End_Date__c);
        System.assertEquals('Account', hist.RecordType.Name);
        System.assertEquals('Basic Account Insert Test', hist.To_Value__c);
        System.assertEquals(null, hist.From_Value__c);

        hist = acctHist[1];

        System.assertEquals(1, hist.Change_Index__c);
        System.assertEquals('AnnualRevenue', hist.Field_API_Name__c);
        System.assertEquals('Annual Revenue', hist.Field_Name__c);
        System.assertEquals(System.today(), hist.Start_Date__c);
        System.assertEquals(null, hist.End_Date__c);
        System.assertEquals('Account', hist.RecordType.Name);
        System.assertEquals('125000', hist.To_Value__c);
        System.assertEquals(null, hist.From_Value__c);


    }

    static testMethod void testBasicAccountUpdate() 
    {
        Test.startTest();
            Id acctId = HelperTest.insertAccount('Basic Account Update Test');

            Account acct = [SELECT Id FROM Account WHERE Id = :acctId];
            acct.Name = 'Basic Account Update Test 2';

            update acct;
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(acctId);
        List<Field_History__c> acctHist = FieldHistoryHelper.getFieldHistory('Account', objIds);
        System.assertEquals(3, acctHist.size());

        Field_History__c hist = acctHist[0];

        System.assertEquals(1, hist.Change_Index__c);
        System.assertEquals('Name', hist.Field_API_Name__c);
        System.assertEquals('Account Name', hist.Field_Name__c);
        System.assertEquals(System.today(), hist.Start_Date__c);
        System.assertEquals(System.today(), hist.End_Date__c);
        System.assertEquals('Account', hist.RecordType.Name);
        System.assertEquals('Basic Account Update Test', hist.To_Value__c);
        System.assertEquals(null, hist.From_Value__c);

        hist = acctHist[1];

        System.assertEquals(1, hist.Change_Index__c);
        System.assertEquals('AnnualRevenue', hist.Field_API_Name__c);
        System.assertEquals('Annual Revenue', hist.Field_Name__c);
        System.assertEquals(System.today(), hist.Start_Date__c);
        System.assertEquals(null, hist.End_Date__c);
        System.assertEquals('Account', hist.RecordType.Name);
        System.assertEquals('125000', hist.To_Value__c);
        System.assertEquals(null, hist.From_Value__c);

        hist = acctHist[2];

        System.assertEquals(2, hist.Change_Index__c);
        System.assertEquals('Name', hist.Field_API_Name__c);
        System.assertEquals('Account Name', hist.Field_Name__c);
        System.assertEquals(System.today(), hist.Start_Date__c);
        System.assertEquals(null, hist.End_Date__c);
        System.assertEquals('Account', hist.RecordType.Name);
        System.assertEquals('Basic Account Update Test 2', hist.To_Value__c);
        System.assertEquals('Basic Account Update Test', hist.From_Value__c);

    }

    static testMethod void testBasicAccountDelete() 
    {
        Id acctId = HelperTest.insertAccount('Basic Account Delete Test');
        Test.startTest();
            Account acct = new Account(Id = acctId);
            delete acct;
        Test.stopTest();

        Set<String> objIds = new Set<String>();
        objIds.add(acctId);
        List<Field_History__c> acctHist = FieldHistoryHelper.getFieldHistory('Account', objIds);
        System.assertEquals(0, acctHist.size());
    }

    static testMethod void testBasicContactInsert() 
    {
        Test.startTest();
            Id acctId = HelperTest.insertAccount('Basic Account Insert Test');
            Id contId = HelperTest.insertContact('Testy', 'Testerson', acctId);
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(contId);
        List<Field_History__c> contHist = FieldHistoryHelper.getFieldHistory('Contact', objIds);
        System.assert(contHist.size() == 1);

        Field_History__c hist = contHist[0];

        System.assert(hist.Change_Index__c   == 1);
        System.assert(hist.Field_API_Name__c == 'Email');
        System.assert(hist.Field_Name__c     == 'Email');
        System.assert(hist.Start_Date__c     == System.today());
        System.assert(hist.End_Date__c       == null);
        System.assert(hist.RecordType.Name   == 'Contact');
        System.assert(hist.To_Value__c       == 'testy.testerson@testerllc.com');
        System.assert(hist.From_Value__c     == null);
    }

    static testMethod void testBasicUserUpdate() 
    {
        Test.startTest();
            User usr = [SELECT Department FROM User WHERE Id = :UserInfo.getUserId()];
            usr.Department = 'Test Dept';
            update usr;
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(usr.Id);
        List<Field_History__c> usrHist = FieldHistoryHelper.getFieldHistory('User', objIds);
        System.assert(usrHist.size() == 1);

        Field_History__c hist = usrHist[0];

        System.assert(hist.Change_Index__c   == 1);
        System.assert(hist.Field_API_Name__c == 'Department');
        System.assert(hist.Field_Name__c     == 'Department');
        System.assert(hist.Start_Date__c     == System.today());
        System.assert(hist.End_Date__c       == null);
        System.assert(hist.RecordType.Name   == 'User');
        System.assert(hist.To_Value__c       == 'Test Dept');
    }

    static testMethod void testBasicEventInsert() 
    {
        Test.startTest();
            Id acctId = HelperTest.insertAccount('Basic Account Insert Test');
            Id contId = HelperTest.insertContact('Testy', 'Testerson', acctId);
            Id evtId = HelperTest.insertEvent(acctId, contId);
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(evtId);
        List<Field_History__c> evtHist = FieldHistoryHelper.getFieldHistory('Event', objIds);
        System.assert(evtHist.size() == 1);

        Field_History__c hist = evtHist[0];

        System.debug(LoggingLevel.DEBUG, 'HIST = ' + hist);

        System.assert(hist.Change_Index__c   == 1);
        System.assert(hist.Field_API_Name__c == 'Subject');
        System.assert(hist.Field_Name__c     == 'Subject');
        System.assert(hist.Start_Date__c     == System.today());
        System.assert(hist.End_Date__c       == null);
        System.assert(hist.RecordType.Name   == 'Event');
        System.assert(hist.To_Value__c       == 'Meeting');
    }

    static testMethod void testBasicCampaignMemberInsert() 
    {
        Test.startTest();
            Id acctId = HelperTest.insertAccount('Basic Account Insert Test');
            Id contId = HelperTest.insertContact('Testy', 'Testerson', acctId);
            Id campId = HelperTest.insertCampaign('Test Campaign');
            Id campMemId = HelperTest.insertCampaignMember(campId, contId);
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(campMemId);
        List<Field_History__c> memberHist = FieldHistoryHelper.getFieldHistory('CampaignMember', objIds);
        System.assert(memberHist.size() == 1);

        Field_History__c hist = memberHist[0];

        System.debug(LoggingLevel.DEBUG, 'HIST = ' + hist);

        System.assert(hist.Change_Index__c   == 1);
        System.assert(hist.Field_API_Name__c == 'Status');
        System.assert(hist.Field_Name__c     == 'Status');
        System.assert(hist.Start_Date__c     == System.today());
        System.assert(hist.End_Date__c       == null);
        System.assert(hist.RecordType.Name   == 'CampaignMember');
        System.assert(hist.To_Value__c       == 'Sent');
    }

}