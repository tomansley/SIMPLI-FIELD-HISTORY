/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-20-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-20-2021   tom.h.ansley@medtronic.com   Initial Version
**/
public with sharing class HelperInstall {

    public static final String ACTION_INSTALL   = 'Install';
    public static final String ACTION_UNINSTALL = 'UnInstall';
    public static final String ACTION_UPGRADE   = 'Upgrade';

	public static void sendEmail(String action)
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddr = new List<String>();
		toAddr.add('tom@ansleyllc.com');
		mail.setToAddresses(toAddr);
		mail.setReplyTo('tom@ansleyllc.com');
        mail.setSenderDisplayName('Simpli Enhanced Field History Update');
        String htmlBody = '';

        if (action == ACTION_INSTALL)
        {
            mail.setSubject('Simpli Enhanced Field History Installed Successfully');
            htmlBody = 'Simpli Enhanced Field History Installed Successfully - ';

        } else if (action == ACTION_UNINSTALL)
        {
            mail.setSubject('Simpli Enhanced Field History UnInstalled Successfully');
            htmlBody = 'Simpli Enhanced Field History UnInstalled Successfully - ';

        } else if (action == ACTION_UPGRADE)
        {
            mail.setSubject('Simpli Enhanced Field History Upgraded Successfully');
            htmlBody = 'Simpli Enhanced Field History Upgraded Successfully - ';
        }


        Organization org = [SELECT Name, IsSandbox, OrganizationType, Country, PrimaryContact FROM Organization LIMIT 1];

        if (org.IsSandbox)
            htmlBody += 'Sandbox';
        else
            htmlBody += 'Production';

        htmlBody += '<br/></br>' + org.Name + '/' + org.OrganizationType + '/' + org.Country + '/' + org.PrimaryContact;

		mail.setHtmlBody(htmlBody);
		Messaging.sendEmail(new Messaging.Email[] { mail });
	}
}