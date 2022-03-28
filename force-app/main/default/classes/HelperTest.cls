/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 02-09-2022
 * @last modified by  : tom@ansleyllc.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-13-2021   tom.h.ansley@medtronic.com   Initial Version
**/
public with sharing class HelperTest 
{

    public static Id insertAccount(String name)
    {
		Account acc = new Account(Name = name);
		acc.BillingStreet = '2334 N. Michigan Avenue, Suite 1500';
		acc.BillingCity = 'Chicago';
		acc.BillingState = 'IL';
		acc.BillingPostalCode = '60601';
        acc.BillingCountry = 'USA';
        acc.AnnualRevenue = 125000;
        Database.SaveResult[] sResults = HelperDatabase.insertRecord(acc);
		
		return sResults[0].id;
    }

    public static Id insertContact(String firstName, String lastName, Id acctId)
    {
        Contact cont = new Contact();
        cont.FirstName = firstName;
        cont.LastName  = lastName;
        cont.Email     = 'testy.testerson@testerllc.com';
        cont.AccountId = acctId;

        Database.SaveResult[] sResults = HelperDatabase.insertRecord(cont);
		
		return sResults[0].id;
    }
    
    public static Id insertEvent(Id acctId, Id contId)
    {
        Event evt                    = new Event();
        evt.WhatId                   = acctId;
        evt.WhoId                    = contId;
        evt.StartDateTime            = System.now().addDays(20);
        evt.ActivityDateTime         = evt.StartDateTime;
        evt.EndDateTime              = System.now().addDays(21);
        evt.Description              = 'Test Event';
        evt.Subject                  = 'Meeting';
        evt.IsAllDayEvent            = false;
                    
        Database.SaveResult[] sResults = HelperDatabase.insertRecord(evt);

        return sResults[0].id;
    }

    public static Id insertCampaign(String name)
    {
        Campaign camp = new Campaign ();
        camp.Name     = name;
        camp.Type     = 'Conference';
        camp.IsActive = true;
        
        Database.SaveResult[] sResults = HelperDatabase.insertRecord(camp);

        return sResults[0].id;

    }

    public static Id insertCampaignMember(Id campId, Id contId)
    {
        CampaignMember member = new CampaignMember();
        member.ContactId      = contId;
        member.CampaignId     = campId;
        member.Status         = 'Sent';

        Database.SaveResult[] sResults = HelperDatabase.insertRecord(member);

        return sResults[0].id;

    }
}