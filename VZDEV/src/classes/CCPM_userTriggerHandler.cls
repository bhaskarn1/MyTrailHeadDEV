/**
*@name          ccpm_userTriggerHandler 
*@author        Sriraman Sridharan (Deloitte)
*@date          10/16/2017
*@description   This is a Handler for user tirgger. 
*@Class         ccpm_userTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Sriraman Sridharan (Deloitte)    03/12/2017   Initial Implementation.
*/

public without sharing class CCPM_userTriggerHandler implements CCPM_ITriggerHandler {

    public static Boolean boolTriggerDisabled = false;
    /**
	@author       Sriraman Sridharan (Deloitte)
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
	@author       Sriraman Sridharan (Deloitte)
	@description  is called in the before insert trigger context
	@param        List<SObject>
	@return       void
	*/     
    public void BeforeInsert(List<SObject> lstNewItems) {
    	/**************Method Declarations Start*/
        List<User> lstNew = (List<User>) lstNewItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
        for(User objUser : lstNew){
            if(String.isNotBlank(objUser.CCPM_employeeID__c) && objUser.CCPM_employeeID__c.length()<7){
                objUser.CCPM_employeeID__c = objUser.CCPM_employeeID__c.leftPad(7,'0');
                
            }
        }
    	/**************First loop End*/
    }
    /**
	@author       Sriraman Sridharan (Deloitte)
	@description  is called in the before update trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, User> mapNew = (Map<id, User>) mapNewItems;
    	Map<id, User> mapOld = (Map<id, User>) mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	for(User objUser : mapNew.values()){
            User objUserOld = mapOld.get(objUser.id);
            if(objUser.CCPM_employeeID__c != objUserOld.CCPM_employeeID__c && String.isNotBlank(objUser.CCPM_employeeID__c) && objUser.CCPM_employeeID__c.length()<7){
                objUser.CCPM_employeeID__c = objUser.CCPM_employeeID__c.leftPad(7,'0');
                
            }
        }
    	/**************First loop End*/
    }
 	/**
	@author       Sriraman Sridharan (Deloitte)
	@description  is called in the before delete trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void BeforeDelete(Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    //$$	Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Sriraman Sridharan (Deloitte)
	@description  is called in the after insert trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterInsert(Map<Id, SObject> mapNewItems){
    	/**************Method Declarations Start*/
    //$$	Map<id, Lead> mapNew = (Map<id, Lead>)mapNewItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Sriraman Sridharan (Deloitte)
	@description  is called in the after update trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    //$$	Map<id, Lead> mapNew = (Map<id, Lead>)mapNewItems;
    //$$	Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Sriraman Sridharan (Deloitte)
	@description  is called in the after delete trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterDelete(Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	
    //$$	Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
 	/**
	@author       Sriraman Sridharan (Deloitte)
	@description  is called in the After undelete trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void AfterUndelete(Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    //$$	Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }

}