/**
*@name          CCPM_mergeLeadCartsWithManualLeadsBatch
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/18/2017
@description    US-495,US-496 and US-497 Batch Job to Merge the Lead Carts with Master Manual Lead  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    08/04/2017          Original Version 
*/ 

global class CCPM_mergeLeadCartsWithManualLeadsBatch implements Database.Batchable<sObject>
{
    
/* 
* Method Name: start
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 08/04/2017
* Description: This method is going to initiate the database query through the standard batch process
*              and fetch the Lead Carts which are to be merged with the master Manual Leads.     
*/
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        // Fetching Prospect Carts which are flaged for Merging with a Master Record from the Custom Label
        string strMergeQuery = Label.CCPM_leadMergeManualLeadsBatchQuery;
        strMergeQuery = string.escapeSingleQuotes(strMergeQuery);
        // Set of Ids for the Lead Record Type Ids
        set<id> setRecordTypeIds = new set<id>();
        setRecordTypeIds.add(CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
       // system.debug('&&&& Merge Manual Leads Batch Query : '+ strMergeQuery);
        return Database.getQueryLocator(strMergeQuery);

    }
 /* 
* Method Name: execute
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 08/04/2017
* Description: This method is going to merge the Lead Carts with the corresponding Manual Leads.
*                   
*/   
    global void execute(Database.BatchableContext bc, list<lead> Scope)
    {
      CCPM_mergeProspectCartwithProspectUtil.processMergeLeadCartsWithManualLeads(scope);     
    }
/* 
* Method Name: Finish
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 08/04/2017
* Description: This method is used to send notifications once the batch is completed    
*/    
    global void finish(Database.BatchableContext BC)
    {
    /* AsyncApexJob objAsyncApexJob = [SELECT Id, Status,ExtendedStatus, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
     if(objAsyncApexJob.NumberOfErrors > 0 || Test.isRunningTest())
     {
      // Send an email to the Apex job's submitter for notifying the job failure.
      Messaging.SingleEmailMessage objSingleMail = new Messaging.SingleEmailMessage();
      string strTextBody;
      strTextBody = 'This batch Apex job processed ' + objAsyncApexJob.TotalJobItems + ' batches with '+ objAsyncApexJob.NumberOfErrors + ' failures.';
      if(objAsyncApexJob.ExtendedStatus != NULL)
       strTextBody = strTextBody + 'with error : '+ objAsyncApexJob.ExtendedStatus;
      String[] lsttoAddresses = new String[] {objAsyncApexJob.CreatedBy.Email};
      objSingleMail.setToAddresses(lsttoAddresses);
      objSingleMail.setSubject('Prospect Carts Merge Batch Job Failure Notification with Job Id: ' + BC.getJobId() + ' and Status : '+ objAsyncApexJob.Status);   
      objSingleMail.setPlainTextBody(strTextBody);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objSingleMail }); 
     } */
    }
}