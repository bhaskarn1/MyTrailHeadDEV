/**
*@name          CCPM_CampaignMember
*@author        Sriraman Sridharan (Deloitte)
*@date          09/21/2017
@description    The Triger on the Campaign Member Object is intended to send messages to the campaings
@testClass      CCPM_CampaignMemberTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          09/21/2017              Original Version

*/
trigger CCPM_ITRMessageTrigger on LiveText__ITR_Message__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    CCPM_TriggerDispatcher.Run(new CCPM_ITRMessageTriggerHandler());
}