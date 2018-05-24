/**
*@name          RemoveSmsScheduleBatch
*@author        Sriraman Sridharan (Deloitte)
*@date          07/14/2017
@description    Batch class to remove the sms schedules
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        07/14/2017                       Original Version
*/

global class CCPM_RemoveSmsScheduleBatch implements Database.Batchable<sObject>{
    
    global final string strQuery;
    global string status = CCPM_staticConstants.StatusNew;
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This Constructor builds up the query to fetch the custom records that .
*@return        Void(None) 
*/ 
    
    global CCPM_RemoveSmsScheduleBatch(){
        // Construct the Query for the custom object
        
       this.strQuery = 'select id, name, CCPM_accountUniqueID__c, CCPM_storeID__c, CCPM_Status__c, CCPM_InsertedDateTime__c from CCPM_SMSSchedulesToBeRemoved__c where CCPM_Status__c ='+ '\'' + status + '\'' +' limit '+CCPM_staticConstants.strRemoveSmsScheduleBatchLimit;
    	//system.debug('@@@Querry ' +this.strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Returning the records obtained by querying
        system.debug('@@@Querry' + this.strQuery);
        return Database.getQueryLocator(this.strQuery);
    }
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   Execute method in batchable context to make a callout to the handler
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<CCPM_SMSSchedulesToBeRemoved__c> scope) {
        system.debug('# List of records from query in batchable context -> '+scope);
        CCPM_RemoveSmsScheduleBatchHandler.CCPM_RemoveSmsScehdules(Scope);
    }
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method schedules the Batch class for every 5 min(Need to confirm)
*@return        Void(None)
*/     
    global void finish(Database.BatchableContext BC){
        
    }
}