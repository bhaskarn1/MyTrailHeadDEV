/**
@author        Manjunath Keshava (Deloitte)
@description	Scheduling the CCPM_ProspectManualLeadUpdateBatch 
@param         None
@return          
*/ 
global with sharing class CCPM_ProspectManualLeadUpdateBatchJob implements Schedulable 
{
   global void execute(SchedulableContext sc)
   {
       CCPM_ProspectManualLeadUpdateBatch objLeadbatch = new CCPM_ProspectManualLeadUpdateBatch();
       integer intBatchSize                             = integer.valueof(Label.CCPM_ProspectManualLeadsBatchSize);
	   Database.executeBatch(objLeadbatch,intBatchSize);
   }
}