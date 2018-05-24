/**
*@name          CCPM_journey
*@author        Bharath Ammanamanchi (Deloitte)
*@date          04/05/2018
@description    This is a trigger for CCPM_journey__c which is called on after delete, after insert, after undelete, after update, before delete, before insert, before update of a record.
@testClass      
Modification    Log:
----------------------------------------------------------------------------------------------------------
Developer                                Date                                Description
----------------------------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)          04/05/2018                          Original Version
*/
trigger CCPM_journey on CCPM_journey__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    CCPM_TriggerDispatcher.Run(new CCPM_journeyTriggerHandler());
}