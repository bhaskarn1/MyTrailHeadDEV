/**
*@name          CCPM_processCCTBatchJob
*@author        Brigadesh Chandrasekar (Deloitte)
*@date          02/17/2018
@description    To Schedule Converted Cart Type
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                          				 Date                           Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar (Deloitte)    			02/17/2018                     Original Version 

*/ 
global class CCPM_processCCTBatchJob implements Schedulable {
    /* 
* Method Name: execute
* Author     : Brigadesh C(Deloitte)
* Date       : 02/17/2018
* Description: This method is used to execute the batch job with specific batch size    
*/  
    
    global void execute(SchedulableContext BG)    
    {
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_processCommissionableCartType objProcessCommissionableCartType =new CCPM_processCommissionableCartType();
        database.executebatch(objProcessCommissionableCartType,integer.valueof(Label.CCPM_cartTypeJobChunks));
    }   
}