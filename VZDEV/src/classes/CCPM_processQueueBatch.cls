/**
*@name          CCPM_processQueueBatch
*@author        Paras Shah (Deloitte)
*@date          09/26/2017
@description    Batch class to process Queue records from Process Queue object
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date          Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        07/14/2017      Original Version
Paras Shah(Deloitte)				09/26/2017		Updated the Apex Class to reflect the new 	CCPM_processQueueBatchHandler class and 	
													CCPM_processingQueue__c object - DISTSCE-1599
*/

global class CCPM_processQueueBatch implements Database.Batchable<sObject>{
    
    //global final string strQuery;
    global string status = CCPM_staticConstants.StatusNew;
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This Constructor builds up the query to fetch the custom records that .
*@return        Void(None) 
*/ 
    
    global CCPM_processQueueBatch(){
        // Construct the Query for the custom object
        
       //this.strQuery = 'select id, name, CCPM_accountUniqueID__c, CCPM_storeID__c, CCPM_Status__c, CCPM_queueType__c, CCPM_LeadID__c, CCPM_cartType__c,CCPM_InsertedDateTime__c from CCPM_processingQueue__c where CCPM_Status__c ='+ '\'' + status + '\'' +' limit '+CCPM_staticConstants.strRemoveSmsScheduleBatchLimit;
    	//system.debug('@@@Querry ' +this.strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Returning the records obtained by querying
        String strQuery = '';
        strQuery = Label.CCPM_processQueueBatch + '\'' + status + '\'';
        //system.debug('@@@Querry' + this.strQuery);
        return Database.getQueryLocator(strQuery);
    }
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   Execute method in batchable context to make a callout to the handler
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<CCPM_processingQueue__c> scope) {
        //system.debug('# List of records from query in batchable context -> '+scope);
        CCPM_processQueueBatchHandler.processQueuedRecords(Scope);
    }
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method schedules the Batch class for every 5 min(Need to confirm)
*@return        Void(None)
*/     
    global void finish(Database.BatchableContext BC){
        
    }
}