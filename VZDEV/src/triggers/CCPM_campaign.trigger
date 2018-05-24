/**
*@name          CCPM_campaign
*@author        Bharath Ammanamanchi (Deloitte)
*@date          04/14/2018
@description    This is a trigger for Campaign which is called on after delete, after insert, after undelete, after update, before delete, before insert, before update of a record.
@testClass      
Modification    Log:
----------------------------------------------------------------------------------------------------------
Developer                                Date                                Description
----------------------------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)          04/14/2018                          Original Version
*/
trigger CCPM_campaign on Campaign (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	CCPM_TriggerDispatcher.Run(new CCPM_campaignTriggerHandler());
}