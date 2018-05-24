/**
*@name          CCPM_lead
*@author        Sriraman Sridharan (Deloitte)
*@date          03/12/2018
@description    Trigger on User Object
@testClass      CCPM_user
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          03/12/2018              Original Version
*/
trigger CCPM_user on User (before insert, before update,after insert, after update) {
    
    CCPM_TriggerDispatcher.Run(new CCPM_userTriggerHandler());
    
}