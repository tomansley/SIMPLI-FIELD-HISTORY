/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-14-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-13-2021   tom.h.ansley@medtronic.com   Initial Version
**/
public with sharing class HelperTest 
{

    public static Account insertAccount(String name)
    {
		Account acc = new Account(Name = name);
		acc.BillingStreet = '2334 N. Michigan Avenue, Suite 1500';
		acc.BillingCity = 'Chicago';
		acc.BillingState = 'IL';
		acc.BillingPostalCode = '60601';
        acc.BillingCountry = 'USA';
        acc.AnnualRevenue = 125000;
        HelperDatabase.insertRecord(acc, 'Account');
		
		return acc;
    }

    public static Contact insertContact(String firstName, String lastName, Account acct)
    {
        Contact cont = new Contact();
        cont.FirstName = firstName;
        cont.LastName  = lastName;
        cont.Email     = 'testy.testerson@testerllc.com';
        cont.AccountId = acct.Id;

        HelperDatabase.insertRecord(cont, 'Contact');
		
		return cont;
    }
    
    public static Event insertEvent(Account acct, Contact cont)
    {
        Event evt                    = new Event();
        evt.WhatId                   = acct.Id;
        evt.WhoId                    = cont.Id;
        evt.StartDateTime            = System.now().addDays(20);
        evt.ActivityDateTime         = evt.StartDateTime;
        evt.EndDateTime              = System.now().addDays(21);
        evt.Description              = 'Test Event';
        evt.Subject                  = 'Meeting';
        evt.IsAllDayEvent            = false;
                    
        HelperDatabase.insertRecord(evt, 'Event');

        return evt;
    }

    public static Campaign insertCampaign(String name)
    {
        Campaign camp = new Campaign ();
        camp.Name     = name;
        camp.Type     = 'Conference';
        camp.IsActive = true;
        
        HelperDatabase.insertRecord(camp, 'Campaign');

        return camp;

    }

    public static CampaignMember insertCampaignMember(Campaign camp, Contact cont)
    {
        CampaignMember member = new CampaignMember();
        member.ContactId      = cont.id;
        member.CampaignId     = camp.Id;
        member.Status         = 'Sent';

        HelperDatabase.insertRecord(member, 'CampaignMember');

        return member;

    }
}