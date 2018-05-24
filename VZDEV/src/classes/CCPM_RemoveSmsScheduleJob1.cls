/**
*@name          CCPM_mergeProspectCartWithProspectJob
*@author        Sriraman Sridharan (Deloitte)
*@date          05/18/2017
@description    US-362 and US-393 To Schedule the RemoveSmsSchedule Batch Job  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               			Date                           Description
------------------------------------------------------------------------------------
Sriraman Sridharan (Deloitte)    07/13/2017          			Original Version   
   
*/ 
global class CCPM_RemoveSmsScheduleJob1 implements Schedulable {
/* 
* Method Name: execute
* Author     : Sriraman Sridharan (Deloitte)
* Date       : 07/13/2017
* Description: This method is used to execute the batch job with specific batch size    
*/  
    
    global void execute(SchedulableContext BG)    
    {
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_RemoveSmsScheduleBatch objRemoveSms =new CCPM_RemoveSmsScheduleBatch();
        database.executebatch(objRemoveSms,integer.valueof(CCPM_staticConstants.strBatchChunk));
    }   
}