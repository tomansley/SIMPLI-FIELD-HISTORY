/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-14-2021
 * @last modified by  : tom.h.ansley@medtronic.com
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
            Account acct = HelperTest.insertAccount('Basic Account Insert Test');
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(acct.Id);
        List<Field_History__c> acctHist = FieldHistoryHelper.getFieldHistory('Account', objIds);
        System.assert(acctHist.size() == 1);

        Field_History__c hist = acctHist[0];

        System.assert(hist.Change_Index__c   == 1);
        System.assert(hist.Field_API_Name__c == 'Name');
        System.assert(hist.Field_Name__c     == 'Account Name');
        System.assert(hist.Start_Date__c     == System.today());
        System.assert(hist.End_Date__c       == null);
        System.assert(hist.RecordType.Name   == 'Account');
        System.assert(hist.To_Value__c       == 'Basic Account Insert Test');
        System.assert(hist.From_Value__c     == null);
    }

    static testMethod void testBasicAccountUpdate() 
    {
        Test.startTest();
            Account acct = HelperTest.insertAccount('Basic Account Update Test');

            acct.Name = 'Basic Account Update Test 2';

            update acct;
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(acct.Id);
        List<Field_History__c> acctHist = FieldHistoryHelper.getFieldHistory('Account', objIds);
        System.assert(acctHist.size() == 2);

        Field_History__c hist = acctHist[0];

        System.assert(hist.Change_Index__c   == 1);
        System.assert(hist.Field_API_Name__c == 'Name');
        System.assert(hist.Field_Name__c     == 'Account Name');
        System.assert(hist.Start_Date__c     == System.today());
        System.assert(hist.End_Date__c       == System.today());
        System.assert(hist.RecordType.Name   == 'Account');
        System.assert(hist.To_Value__c       == 'Basic Account Update Test');
        System.assert(hist.From_Value__c     == null);

        hist = acctHist[1];

        System.assert(hist.Change_Index__c   == 2);
        System.assert(hist.Field_API_Name__c == 'Name');
        System.assert(hist.Field_Name__c     == 'Account Name');
        System.assert(hist.Start_Date__c     == System.today());
        System.assert(hist.End_Date__c       == null);
        System.assert(hist.RecordType.Name   == 'Account');
        System.assert(hist.To_Value__c       == 'Basic Account Update Test 2');
        System.assert(hist.From_Value__c     == 'Basic Account Update Test');

    }

    static testMethod void testBasicContactInsert() 
    {
        Test.startTest();
            Account acct = HelperTest.insertAccount('Basic Account Insert Test');
            Contact cont = HelperTest.insertContact('Testy', 'Testerson', acct);
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(cont.Id);
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
            Account acct = HelperTest.insertAccount('Basic Account Insert Test');
            Contact cont = HelperTest.insertContact('Testy', 'Testerson', acct);
            Event evt = HelperTest.insertEvent(acct, cont);
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(evt.Id);
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
            Account acct = HelperTest.insertAccount('Basic Account Insert Test');
            Contact cont = HelperTest.insertContact('Testy', 'Testerson', acct);
            Campaign camp = HelperTest.insertCampaign('Test Campaign');
            CampaignMember member = HelperTest.insertCampaignMember(camp, cont);
        Test.stopTest();
        
        Set<String> objIds = new Set<String>();
        objIds.add(member.Id);
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