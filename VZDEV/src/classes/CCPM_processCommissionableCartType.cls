/**
*@name          CCPM_processCommissionableCartType
*@author        Brigadesh Chandrasekar (Deloitte)
*@date          02/14/2018
@description    Batch class to process converted Leads to extract the commisionable Cart Type Records and mark Lead commissionable
@testClass      CCPM_processCCTBatchHandlerTestClass
Modification    Log:
------------------------------------------------------------------------------------
Developer             							  Date          	Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)        		12/12/2017        Original Version

*/

global class CCPM_processCommissionableCartType implements Database.Batchable<sObject>{
    
    //global final string strQuery;
    global String strQuery = '';
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Constructor builds up the query to fetch the custom records that .
*@return        Void(None) 
*/ 
    
    global CCPM_processCommissionableCartType(){
        strQuery = Label.CCPM_processConvertedLeads;
        this.strQuery = strQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Returning the records obtained by querying
        return Database.getQueryLocator(strQuery);
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Execute method that calls the batch handler to process converted carts for identifying commissionable eligible
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        CCPM_processCCTBatchHandler.extractCartTypes(Scope);
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Unused Method, but have to be implemented in a batchable context
*@return        Void(None)
*/     
    global void finish(Database.BatchableContext BC){
        
    }
}