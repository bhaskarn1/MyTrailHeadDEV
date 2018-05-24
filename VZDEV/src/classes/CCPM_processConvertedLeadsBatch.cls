/**
*@name          CCPM_processConvertedLeadsBatch
*@author        Paras Shah (Deloitte)
*@date          12/12/2017
@description    Batch class to process Converted Leads Batch
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				Date          	Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)        		12/12/2017      Original Version

*/

global class CCPM_processConvertedLeadsBatch implements Database.Batchable<sObject>{
    
    //global final string strQuery;
    global String strQuery = '';
    /**
*@author        Paras Shah (Deloitte)
*@description   This Constructor builds up the query to fetch the custom records that .
*@return        Void(None) 
*/ 
    
    global CCPM_processConvertedLeadsBatch(String strAddWhereClause){
		String strDynamicQuery = '';
        strDynamicQuery = Label.CCPM_processConvertedLeads;
        if(String.isNotBlank(strAddWhereClause)){
        	strDynamicQuery = strDynamicQuery +' '+strAddWhereClause;
        } 
        this.strQuery = strDynamicQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Returning the records obtained by querying
        
        return Database.getQueryLocator(strQuery);
    }
    /**
*@author        Paras Shah (Deloitte)
*@description   Execute method in batchable context to make a callout to the handler
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        CCPM_processConvertedLeadsBatchHandler.processConvertedLeads(Scope);
    }
    /**
*@author        Paras Shah (Deloitte)
*@description   This method schedules the Batch class for every 5 min(Need to confirm)
*@return        Void(None)
*/     
    global void finish(Database.BatchableContext BC){
        
    }
}