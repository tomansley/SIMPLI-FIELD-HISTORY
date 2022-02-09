/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-20-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   10-10-2020   tom.h.ansley@medtronic.com   Initial Version
**/
global with sharing class ScriptInstall implements InstallHandler {

	global void onInstall(InstallContext context) 
	{
		if(context.previousVersion() == null)
		{
            HelperInstall.sendEmail(HelperInstall.ACTION_INSTALL);
            
		} else if(context.previousVersion().compareTo(new Version(1,0)) == 0) 
		{
		}

		if(context.isUpgrade())
		{
            HelperInstall.sendEmail(HelperInstall.ACTION_UPGRADE);
		}

		if(context.isPush()) 
		{
		}
	}

}