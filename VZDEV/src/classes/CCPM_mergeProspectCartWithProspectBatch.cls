/**
*@name          CCPM_mergeProspectCartWithProspectBatch
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/18/2017
@description    US-362 and US-393 Batch Job to Merge the Prospect Cart with Master Prospect  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/18/2017          Original Version 
Sudhakara Reddy Nallamilli (Deloitte)    06/26/2017          US-481, US-482 
*/ 

global class CCPM_mergeProspectCartWithProspectBatch implements Database.Batchable<sObject>
{
    
/* 
* Method Name: start
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 05/17/2017
* Description: This method is going to initiate the database query through the standard batch process
*              and fetch the prospect carts which are to be merged with the master prospects.     
*/
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        // Fetching Prospect Carts which are flaged for Merging with a Master Record from the Custom Label
        string strMergeQuery = Label.CCPM_leadMergeBatchQuery;
        strMergeQuery = string.escapeSingleQuotes(strMergeQuery);
        set<id> setRecordTypeIds = new set<id>();
        setRecordTypeIds.add(CCPM_staticConstants.strProspectRecordTypeID);
        setRecordTypeIds.add(CCPM_staticConstants.strProspectAbandonedCartRecordTypeID);
       // system.debug('&&&& Merge Manual Leads Batch Query : '+ strMergeQuery);
        return Database.getQueryLocator(strMergeQuery);

    }
 /* 
* Method Name: execute
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 05/17/2017
* Description: This method is going to merge the prospect carts with the corresponding Prospects.
*                   
*/   
    global void execute(Database.BatchableContext bc, list<lead> Scope)
    {
      CCPM_mergeProspectCartwithProspectUtil.processProspectCarts(Scope);     
    }
/* 
* Method Name: Finish
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 05/17/2017
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