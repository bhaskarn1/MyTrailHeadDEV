/**
*@name          CCPM_mergeProspectCartWithProspectJob
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/18/2017
@description    US-362 and US-393 To Schedule the Leads Prospect Cart Merge Batch Job  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/18/2017          Original Version  
Manjunath Keshava(Deloitte)              07/14/2017           Added Null checks (US-1618)

    
*/  

global class CCPM_mergeProspectCartWithProspectJob implements Schedulable 
{
/* 
* Method Name: scheduleIt
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 05/17/2017
* Description: This method is used to schedule the job   
*/  	
  @TestVisible
  private string scheduleIt()
  {
    String StrCRONEXP = ccpm_staticConstants.StrCRONEXP;
    CCPM_mergeProspectCartWithProspectJob objSch = new CCPM_mergeProspectCartWithProspectJob(); 
    return system.schedule('CCPM_leadMergeProspectCartSchedulerTest- 10 Mins', StrCRONEXP, objSch); 
  }
  
/* 
* Method Name: execute
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 05/17/2017
* Description: This method is used to execute the batch job with specific batch size    
*/     
  global void execute(SchedulableContext BG)    
  {
    // Creating the object for the Batch Class and invoking the batch execution  
    CCPM_mergeProspectCartWithProspectBatch objLeadMergeBatch= new CCPM_mergeProspectCartWithProspectBatch();
    integer intBatchSize                                     = integer.valueof(Label.CCPM_mergeBatchSize);
    database.executebatch(objLeadMergeBatch,intBatchSize); 
  }   
   
}