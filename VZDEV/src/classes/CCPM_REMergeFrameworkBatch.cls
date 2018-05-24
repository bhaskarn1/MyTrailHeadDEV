/**
*@name          CCPM_REMergeFrameworkBatch 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          01/22/2018
*@description   This is a controller or class
*@Class         CCPM_REMergeFrameworkBatch
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    01/22/2018   Initial Implementation.
*/
global class CCPM_REMergeFrameworkBatch implements Database.Batchable<sObject>,Schedulable{

    global string strQuery = '';
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
	*/ 
    global CCPM_REMergeFrameworkBatch (String strObjectAPIName){
    	
		String strBuildQuery = CCPM_REMergeHandler.REgetMergeQueryWOWhereClause(strObjectAPIName);
		if(strObjectAPIName == 'Lead'){
			strBuildQuery = strBuildQuery+' Where CCPM_mfToBeMerged__c = true AND RecordTypeId IN: setMFLeadRecordTypeIds Order By CreatedDate ASC';	
		}
		this.strQuery = strBuildQuery;
    	
    }
    
    global CCPM_REMergeFrameworkBatch(){
    	
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //declaring the set here so that it will be available for the query defined in the constructor.
        Set<String> setMFLeadRecordTypeIds = new Set<String>{CCPM_utility.strLeadCustomerCartRT, CCPM_utility.strLeadProspectRT, CCPM_utility.strLeadProspectCartRT};
    	return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bc, list<lead> Scope){
    	CCPM_REMergeHandler.REMergeRecords(Scope, 'SOSL');
    }
    
    global void finish(Database.BatchableContext BC){
    	
    }
    
    global void execute(SchedulableContext sc) {
        CCPM_REMergeFrameworkBatch mergeBatch = new CCPM_REMergeFrameworkBatch('Lead');
        database.executebatch(mergeBatch);
    }
    
}