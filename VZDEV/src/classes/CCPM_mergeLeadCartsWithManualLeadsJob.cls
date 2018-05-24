/**
*@name          CCPM_mergeLeadCartsWithManualLeadsJob
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          08/04/2017
@description    US-495,US-496 and US-497 To Schedule the Manual Lead Carts Merge Batch Job  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    08/04/2017          Original Version  
    
*/  

global class CCPM_mergeLeadCartsWithManualLeadsJob implements Schedulable 
{
/* 
* Method Name: scheduleIt
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 08/04/2017
* Description: This method is used to schedule the job   
*/  	
  @TestVisible
  private string scheduleIt()
  {
    String StrCRONEXP = ccpm_staticConstants.StrCRONEXP;
    CCPM_mergeLeadCartsWithManualLeadsJob objSch = new CCPM_mergeLeadCartsWithManualLeadsJob(); 
    return system.schedule('CCPM_leadMergeManualLeadsSchedulerTest- 10 Mins', StrCRONEXP, objSch); 
  }
  
/* 
* Method Name: execute
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 08/04/2017
* Description: This method is used to execute the batch job with specific batch size    
*/     
  global void execute(SchedulableContext BG)    
  {
    // Creating the object for the Batch Class and invoking the batch execution  
    CCPM_mergeLeadCartsWithManualLeadsBatch objManualLeadMergeBatch= new CCPM_mergeLeadCartsWithManualLeadsBatch();
    integer intBatchSize                                     = integer.valueof(Label.CCPM_mergeManualLeadsBatchSize);
    database.executebatch(objManualLeadMergeBatch,intBatchSize); 
  }   
   
}