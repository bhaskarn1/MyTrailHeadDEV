/**
*@name          CCPM_NPS
*@author        Bharath Ammanamanchi (Deloitte)
*@date          01/10/2018
@description    This is a trigger for CCPM_NPS__c which is called on after delete, after insert, after undelete, after update, before delete, before insert, before update of a record.
@testClass      
Modification    Log:
----------------------------------------------------------------------------------------------------------
Developer                                Date                                Description
----------------------------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)          01/10/2018                          Original Version
*/
trigger CCPM_NPS on CCPM_NPS__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    CCPM_TriggerDispatcher.Run(new CCPM_NPSTriggerHandler());
}