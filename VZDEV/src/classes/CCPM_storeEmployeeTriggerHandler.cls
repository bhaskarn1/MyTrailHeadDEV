/**
*@name          CCPM_storeEmployeeTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          11/08/2017
*@description   This is a handler for CCPM_storeEmployeeTrigger
*@Class         CCPM_storeEmployeeTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    11/08/2017   Initial Implementation.
*/
public with sharing class CCPM_storeEmployeeTriggerHandler  implements CCPM_ITriggerHandler{
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean boolTriggerDisabled = false;
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  Checks to see if the trigger has been disabled either by custom setting or by running code
	@param        N/A
	@return       Boolean
	*/ 
    public Boolean IsDisabled()
    {
        CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(UserInfo.getUserId());
	    if(settings != null && settings.CCPM_DisableTrigger__c == true){
	        return true;
	    }
        else
            return boolTriggerDisabled;
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the before insert trigger context
	@param        List<SObject>
	@return       void
	*/     
    public void BeforeInsert(List<SObject> lstNewItems) {
    	/**************Method Declarations Start*/
    	List<CCPM_storeEmployee__c> lstNew = (List<CCPM_storeEmployee__c>) lstNewItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the before update trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, CCPM_storeEmployee__c> mapNew = (Map<id, CCPM_storeEmployee__c>)mapNewItems;
    	Map<id, CCPM_storeEmployee__c> mapOld = (Map<id, CCPM_storeEmployee__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	for(CCPM_storeEmployee__c objStrEmp : mapNew.values()){
    		
    		CCPM_strEmpTriggerHandlerHelper.flagRecForBatchProcess(objStrEmp, mapOld.get(objStrEmp.id)); 	
    	}
    	/**************First loop End*/
    }
 	/**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the before delete trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void BeforeDelete(Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, CCPM_storeEmployee__c> mapOld = (Map<id, CCPM_storeEmployee__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the after insert trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterInsert(Map<Id, SObject> mapNewItems){
    	/**************Method Declarations Start*/
    	Map<id, CCPM_storeEmployee__c> mapNew = (Map<id, CCPM_storeEmployee__c>)mapNewItems;
    	Map<String, Set<String>> mapStoreIdStoreEmpId = new Map<String, Set<String>>();
    	List<Lead> lstLeadToBeConsideredforSharing = new List<Lead>();
        List<leadShare> lstleadShrToInsert    = new List<leadShare>();
        Map<String, List<Lead>> mapStoreIdLeadlist = new Map<String, List<Lead>>();
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	for(CCPM_storeEmployee__c objStrEmp : mapNew.values()){
    		//Validate if Role is Assistant Manager
    		if(objStrEmp.CCPM_role__c == Label.CCPM_storeAssistantManager && objStrEmp.CCPM_Store__c!=null && objStrEmp.CCPM_employee__c!=null
    		  && objStrEmp.CCPM_isStoreActive__c){
    		  	//Put in Map of SE and store associated
    			if(mapStoreIdStoreEmpId.containsKey(objStrEmp.CCPM_Store__c)){
	    			mapStoreIdStoreEmpId.get(objStrEmp.CCPM_Store__c).add(objStrEmp.CCPM_employee__c);
	    		}  	
	    		else{
	    			mapStoreIdStoreEmpId.put(objStrEmp.CCPM_Store__c, new Set<String>{objStrEmp.CCPM_employee__c});
	    		}
    		}
    	}
    	/**************First loop End*/
    	
    	
    	//Code to provide access by iserting records to Leadshare 
    	if(CCPM_Collection.isNotNullEmpty(mapStoreIdStoreEmpId)){
    		//Query for all associated open Leads
    		lstLeadToBeConsideredforSharing = [Select id,Store__c,ownerid from Lead where Store__c in :mapStoreIdStoreEmpId.keySet() AND status IN :CCPM_utility.setleadOpenStatus];
    	}
    	//putting into map by store id
    	if(CCPM_Collection.isNotNullEmpty(lstLeadToBeConsideredforSharing)){
    		for(Lead objl : lstLeadToBeConsideredforSharing){
    			if(mapStoreIdLeadlist.containsKey(objl.Store__c)){
	    			mapStoreIdLeadlist.get(objl.Store__c).add(objl);
	    		}  	
	    		else{
	    			mapStoreIdLeadlist.put(objl.Store__c, new List<Lead>{objl}); 
	    		}
    		}
    	}
    	for(String strStoreId: mapStoreIdLeadlist.keySet()){
    		for(Lead objl: mapStoreIdLeadlist.get(strStoreId)){
    			for(String strStoreRepId : mapStoreIdStoreEmpId.get(objl.Store__c)){
    				lstleadShrToInsert.add(CCPM_globalUtility.apexShareReadAccess(objl.id,strStoreRepId));
    			}
    		}
    	}
    	
    	try{
            //Try to Insert Apex Sharing
            if(CCPM_Collection.isNotNullEmpty(lstleadShrToInsert))
            {
                insert lstleadShrToInsert;
            }
        }
        catch(Exception e)
        {
            //Catch statement in case of failure in DML Statements
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeTriggerHandler','AfterInsert','Exception thrown while inserting Lead Shares',true);
        }
    }
 	/**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the after update trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, CCPM_storeEmployee__c> mapNew = (Map<id, CCPM_storeEmployee__c>)mapNewItems;
    	Map<id, CCPM_storeEmployee__c> mapOld = (Map<id, CCPM_storeEmployee__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the after delete trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterDelete(Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	
    	Map<id, CCPM_storeEmployee__c> mapOld = (Map<id, CCPM_storeEmployee__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the After undelete trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterUndelete(Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, CCPM_storeEmployee__c> mapOld = (Map<id, CCPM_storeEmployee__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
}