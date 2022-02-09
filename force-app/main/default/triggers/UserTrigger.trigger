/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 01-13-2021
 * @last modified by  : tom.h.ansley@medtronic.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   01-13-2021   tom.h.ansley@medtronic.com   Initial Version
**/
trigger UserTrigger on User (after insert, after update, after delete) 
{
    FieldHistoryHelper.processFieldHistoryTracking(Trigger.new, Trigger.oldMap);
}