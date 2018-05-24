/**
*@name          CCPM_expireInActiveLeadsJob
*@author        Paras Shah (Deloitte)
*@date          05/24/2017
@description    Job to schedule batch to expire Inactive Leads
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Paras Shah (Deloitte)   05/24/2017                          Original Version   
    
*/  

global class CCPM_expireInActiveLeadsJob implements Schedulable 
{
   
  global void execute(SchedulableContext BG)    
  {
    // Creating the object for the Batch Class and invoking the batch execution  
    CCPM_expireInActiveLeadsBatch objExpireInActiveLeads = new CCPM_expireInActiveLeadsBatch();
    integer intBatchSize                            = 200;
    database.executebatch(objExpireInActiveLeads,intBatchSize); 
  }   
   
}