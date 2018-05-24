/**
*@name          CCPM_updateAccountUniqueIDJob
*@author        Sriraman Sridharan (Deloitte)
*@date          11/02/2017
@description    Scheduler to run the Batch Job to update account unique ID's for 11/02/2017  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                           Date                           Description
------------------------------------------------------------------------------------
Sriraman Sridharan (Deloitte)    11/02/2017                     Original Version   
   
*/ 
global class CCPM_updateAccountUniqueIDJob implements Schedulable {
/* 
* Method Name: execute
* Author     : Sriraman Sridharan (Deloitte)
* Date       : 11/02/2017 
* Description: This method is used to execute the batch job with specific batch size    
*/  
    
    global void execute(SchedulableContext BG)    
    {
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_updateAccountUniqueIDBatch objUpdateAccount =new CCPM_updateAccountUniqueIDBatch();
        database.executebatch(objUpdateAccount,integer.valueof(CCPM_staticConstants.strBatchChunk));
    }   
}