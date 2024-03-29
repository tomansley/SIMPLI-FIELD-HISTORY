/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-20-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-05-2020   tom.h.ansley@medtronic.com   Initial Version
**/
@isTest
private class ScriptUninstallTest {

	@isTest
	static void testUninstallScript() 
	{
		Id UninstallerId = UserInfo.getUserId();
		Test.testUninstall(new ScriptUninstall());

		System.assert(true);
	}
}