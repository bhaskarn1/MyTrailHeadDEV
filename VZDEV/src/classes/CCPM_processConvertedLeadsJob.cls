/**
*@name          CCPM_processConvertedLeadsJob
*@author        Paras Shah (Deloitte)
*@date          12/12/2017
@description    To process Converted Leads to create Cart Type records
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                           Date                           Description
------------------------------------------------------------------------------------
Paras Shah (Deloitte)    			12/12/2017                     Original Version
   
*/ 
global class CCPM_processConvertedLeadsJob implements Schedulable {
/* 
* Method Name: execute
* Author     : Paras Shah (Deloitte)
* Date       : 12/12/2017  
* Description: This method is used to execute the batch job with specific batch size    
*/  
    
    global void execute(SchedulableContext BG)    
    {
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_processConvertedLeadsBatch objProcessConvertedLeads =new CCPM_processConvertedLeadsBatch('');
        database.executebatch(objProcessConvertedLeads);
    }   
}