/**
*@name          CCPM_ITRMessageTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          10/162017
*@description   This is a controller or class
*@Class         CCPM_ITRMessageTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    10/16/2017   Initial Implementation.
*/
public with sharing class CCPM_ITRMessageTriggerHandler implements CCPM_ITriggerHandler {
    
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
    	List<LiveText__ITR_Message__c> lstNew = (List<LiveText__ITR_Message__c>) lstNewItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	//CCPM_ITRMessageHandler.processITRs(Trigger.new);
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
    	Map<id, LiveText__ITR_Message__c> mapNew = (Map<id, LiveText__ITR_Message__c>)mapNewItems;
    	Map<id, LiveText__ITR_Message__c> mapOld = (Map<id, LiveText__ITR_Message__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	CCPM_ITRMessageHandler.processITRs(mapNew.values());
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
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
    	Map<id, LiveText__ITR_Message__c> mapOld = (Map<id, LiveText__ITR_Message__c>)mapOldItems;
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
    	Map<id, LiveText__ITR_Message__c> mapNew = (Map<id, LiveText__ITR_Message__c>)mapNewItems;
        
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	CCPM_ITRMessageHandler.processITRs(mapNew.values());
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the after update trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, LiveText__ITR_Message__c> mapNew = (Map<id, LiveText__ITR_Message__c>)mapNewItems;
    	Map<id, LiveText__ITR_Message__c> mapOld = (Map<id, LiveText__ITR_Message__c>)mapOldItems;
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
    	Map<id, LiveText__ITR_Message__c> mapOld = (Map<id, LiveText__ITR_Message__c>)mapOldItems;
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
    	Map<id, LiveText__ITR_Message__c> mapOld = (Map<id, LiveText__ITR_Message__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
}