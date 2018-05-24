/**
*@name          CCPM_account
*@author        Deepak Mazumdar (Deloitte)
*@date          1/31/2017
@description    Trigger to populate store reference based on store id
@testClass      CCPM_accountHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Deepak Mazumdar(Deloitte)       1/31/2016                           Original Version
Sriraman Sridharan(Deloitte)    1/31/2016                           Original Version
*/
trigger CCPM_account on Account (before insert, before update) {
    CCPM_TriggerDispatcher.Run(new CCPM_accountTriggerHandler());
}