/**
*@name          CCPM_processQueueJob
*@author        Paras Shah (Deloitte)
*@date          09/26/2017
@description    To process Queued records from the Process Queue object 
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                           Date                           Description
------------------------------------------------------------------------------------
Paras Shah (Deloitte)    			09/26/2017                     Original Version  - DISTSCE-1599
   
*/ 
global class CCPM_processQueueJob implements Schedulable {
/* 
* Method Name: execute
* Author     : Paras Shah (Deloitte)
* Date       : 09/26/2017
* Description: This method is used to execute the batch job with specific batch size    
*/  
    
    global void execute(SchedulableContext BG)    
    {
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_processQueueBatch objProcessQueue =new CCPM_processQueueBatch();
        database.executebatch(objProcessQueue,integer.valueof(CCPM_staticConstants.strProcessQueueBatchChunk));
    }   
}