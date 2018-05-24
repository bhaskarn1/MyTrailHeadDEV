/**
*@name          CCPM_storeEmployeeBatch
*@author        Tanweer Maredia (Deloitte)
*@date          11/05/2017
@description    This Batch class is to update the store employee record and inactive employee
@testClass      
Modification    Log:
----------------------------------------------------------------------------------------
Developer               			  Date                                Description
----------------------------------------------------------------------------------------
Tanweer Maredia(Deloitte)    11/05/2017                          Original Version
*/

global class CCPM_storeEmployeeBatch implements Database.Batchable<sObject>,Schedulable{
    global final String strQuery;
    
    /**
*@author        Tanweer Maredia (Deloitte)
*@description   This Constructor builds up the query for store employee Information based on conditions specified.
*@return        Void(None)
*/ 
    global CCPM_storeEmployeeBatch() {
        
       
        // Building up the Query string for Execute method
        this.strQuery =Label.CCPM_storeEmployeeBatchQuery;
       	
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Returning the records obtained by querying
        return Database.getQueryLocator(this.strQuery);
        
    }
    
    /**
*@author        Tanweer Maredia (Deloitte)
@Modification Manjunath Keshava(Deloitte)
*@description   Providing records access to new employee and remove access from old employee
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<CCPM_storeEmployee__c> scope) 
    {
        System.debug('@@@Inside execute batch lstLeadsAssociatedToStoreEmployees records'+scope);
        List<Lead> lstLeadsAssociatedToStoreEmployees = CCPM_storeEmployeeBatchHandler.getListofOpenLeadsForUpdatedEmployees(scope);
        Map<String,Group> mapDistrictAndGroup = CCPM_leadHandlerAssignOwnership.getMapOfStoreDistrictAndGroup();
        system.debug('mapDistrictAndGroup'+ mapDistrictAndGroup);
        List<BusinessHours> lstBusinessHours = CCPM_utility.getBusinessHours();
        BusinessHours objDefaultBusinessHour = CCPM_utility.objDefaultBusinessHour;
       
        system.debug('getBusinessHours'+ lstBusinessHours);
        // Updating store employee records 
        
        List<CCPM_storeemployee__c> lstStoreEmployeeAfterUpdatingOwner = new List<CCPM_StoreEmployee__c>();
        lstStoreEmployeeAfterUpdatingOwner = CCPM_storeEmployeeBatchHandler.updateOwnerForAssociatedLeads(scope, lstLeadsAssociatedToStoreEmployees,mapDistrictAndGroup,lstBusinessHours,objDefaultBusinessHour);
   		//CCPM_storeEmployeeBatchHandler.updateOwnerForAssociatedLeads(scope, lstLeadsAssociatedToStoreEmployees,mapDistrictAndGroup,lstBusinessHours);
        system.debug('@@@lstStoreEmployeeAfterUpdatingOwner: ' + lstStoreEmployeeAfterUpdatingOwner);
       
        CCPM_storeEmployeeBatchHandler.decideLeadShareAccessForEmployee(scope);
       
         for(CCPM_StoreEmployee__c sE : scope)
        { 
            //Updating the Update flag to false  
            sE.CCPM_IsUpdateFlag__c = false;
            
        } 
        try{
            //Bulk updating the UpdatedFlag
            Update scope;
        }
        catch(DMLException e){
            
            CCPM_LogMessageUtility.logMessage(e,'CCPM_StoreEmployee__c','Chaning Owner/Flag','Exception thrown while updating scope in Execute Method',true);
            
        }
        
        
    }
    /**
*@author        Tanweer Maredia (Deloitte)
*@description   Querying the jobs processed in the batch
*@return        Void(None)
*/ 
    global void finish(Database.BatchableContext BC){
        //Queries the status of the jobs processed
       /* AsyncApexJob a = [SELECT 
                          Id
                          , Status
                          , NumberOfErrors
                          , JobItemsProcessed
                          , TotalJobItems
                          , CreatedBy.Email
                          FROM AsyncApexJob 
                          WHERE Id = :BC.getJobId()]; */
        
    } 
    /**
*@author        Tanweer Maredia (Deloitte)
*@description   This method schedules the Batch class once every day
*@return        Void(None)
*/     
    global void execute(SchedulableContext sc)
    {
       
    	integer intBatchSize = integer.valueof(Label.CCPM_StoreEmployeeBatchSize); 
       CCPM_storeEmployeeBatch objStoreEmployeeBatch = new CCPM_storeEmployeeBatch();
       database.executebatch(objStoreEmployeeBatch,intBatchSize); 
        //CCPM_storeEmployeeBatch test = new CCPM_storeEmployeeBatch();
		//System.schedule('test - 5 Mins', '0 5 * * * ?', test);
		//System.schedule('test - 5 Mins', '0 5 * * * ?', test);
        
    }
}