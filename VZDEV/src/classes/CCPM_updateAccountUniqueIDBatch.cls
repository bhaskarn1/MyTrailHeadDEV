/**
*@name          CCPM_updateAccountUniqueIDBatch
*@author        Sriraman Sridharan (Deloitte)
*@date          11/02/2017
@description    Batch Job to update account unique ID's for 11/02/2017
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        11/02/2017                       Original Version
*/

global class CCPM_updateAccountUniqueIDBatch implements Database.Batchable<sObject>{
    
    global final string strQuery;
   
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This Constructor builds up the query to fetch the custom records that .
*@return        Void(None) 
*/ 
    
    global CCPM_updateAccountUniqueIDBatch(){
        // Construct the Query for the custom object
        
       this.strQuery = label.CCPM_accountUniqueIdBatchQuery;
    	//system.debug('@@@Querry ' +this.strQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Returning the records obtained by querying
        //system.debug('@@@Querry' + this.strQuery);
        return Database.getQueryLocator(this.strQuery);
    }
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   Execute method in batchable context to make a callout to the handler
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
       // system.debug('# List of records from query in batchable context -> '+scope);
        CCPM_updateAccountUniqueIDBatchHandler.processAccounts(Scope);
    }
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method schedules the Batch class for every 5 min(Need to confirm)
*@return        Void(None)
*/     
    global void finish(Database.BatchableContext BC){
        
    }
}