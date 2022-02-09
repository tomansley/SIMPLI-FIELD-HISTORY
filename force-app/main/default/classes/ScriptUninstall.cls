/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-20-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-05-2020   tom.h.ansley@medtronic.com   Initial Version
**/
global with sharing class ScriptUninstall implements UninstallHandler {
	
	global void onUninstall(UninstallContext context) 
	{
        HelperInstall.sendEmail(HelperInstall.ACTION_UNINSTALL);
	}



}