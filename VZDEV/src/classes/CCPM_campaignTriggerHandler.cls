/**
*@name          CCPM_campaignTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          04/14/2018
*@description   This is a handler for CCPM_segmentation trigger. 
*@Class         CCPM_campaignTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    04/14/2018   Initial Implementation.
*/
public with sharing class CCPM_campaignTriggerHandler implements CCPM_ITriggerHandler{
    
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
    	List<Campaign> lstNew = (List<Campaign>) lstNewItems;
    	
    	List<String> lstError = new List<String>();
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	for(Campaign objCampaign: lstNew){
    		DateTime dtmEvntStDate, dtmEvntEndDate,dtmEvntSMSStDate, dtmEvntSMSEndDate;
    		if(String.isNotBlank(objCampaign.CCPM_eventStartDate__c)){
    			try{
    				dtmEvntStDate = DateTime.valueofGmt(objCampaign.CCPM_eventStartDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventStartDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objCampaign.CCPM_eventEndDate__c)){
    			try{
    				dtmEvntEndDate = DateTime.valueofGmt(objCampaign.CCPM_eventEndDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventEndDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objCampaign.CCPM_eventSMSFollowUpStartDate__c)){
    			try{
    				dtmEvntSMSStDate = DateTime.valueofGmt(objCampaign.CCPM_eventSMSFollowUpStartDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventSMSFollowUpStartDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objCampaign.CCPM_eventSMSFollowUpEndDate__c)){
    			try{
    				dtmEvntSMSEndDate = DateTime.valueofGmt(objCampaign.CCPM_eventSMSFollowUpEndDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventSMSFollowUpEndDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		
    		if(dtmEvntStDate != null && dtmEvntEndDate != null && dtmEvntEndDate <= dtmEvntStDate){
    			lstError.add('Event Start Date cannot be greater than Event End Date.');
    		}
    		if(dtmEvntSMSStDate != null && dtmEvntSMSEndDate != null && dtmEvntSMSEndDate <= dtmEvntSMSStDate){
    			lstError.add('Event SMS Follow up Start Date cannot be greater than Event SMS Follow up End Date.');
    		}
    		if(CCPM_Collection.isNotNullEmpty(lstError)){
    			objCampaign.addError(String.join(lstError, '</br>'), false);
    		}
    	}
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
    	Map<id, Campaign> mapNew = (Map<id, Campaign>)mapNewItems;
    	Map<id, Campaign> mapOld = (Map<id, Campaign>)mapOldItems;
    	
    	List<String> lstError = new List<String>();
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	for(Campaign objCampaign: mapNew.values()){
    		DateTime dtmEvntStDate, dtmEvntEndDate,dtmEvntSMSStDate, dtmEvntSMSEndDate;
    		if(String.isNotBlank(objCampaign.CCPM_eventStartDate__c)){
    			try{
    				dtmEvntStDate = DateTime.valueofGmt(objCampaign.CCPM_eventStartDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventStartDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objCampaign.CCPM_eventEndDate__c)){
    			try{
    				dtmEvntEndDate = DateTime.valueofGmt(objCampaign.CCPM_eventEndDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventEndDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objCampaign.CCPM_eventSMSFollowUpStartDate__c)){
    			try{
    				dtmEvntSMSStDate = DateTime.valueofGmt(objCampaign.CCPM_eventSMSFollowUpStartDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventSMSFollowUpStartDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objCampaign.CCPM_eventSMSFollowUpEndDate__c)){
    			try{
    				dtmEvntSMSEndDate = DateTime.valueofGmt(objCampaign.CCPM_eventSMSFollowUpEndDate__c);
    			}
    			catch(Exception e){
    				objCampaign.CCPM_eventSMSFollowUpEndDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		
    		if(dtmEvntStDate != null && dtmEvntEndDate != null && dtmEvntEndDate <= dtmEvntStDate){
    			lstError.add('Event Start Date cannot be greater than Event End Date.');
    		}
    		if(dtmEvntSMSStDate != null && dtmEvntSMSEndDate != null && dtmEvntSMSEndDate <= dtmEvntSMSStDate){
    			lstError.add('Event SMS Follow up Start Date cannot be greater than Event SMS Follow up End Date.');
    		}
    		if(CCPM_Collection.isNotNullEmpty(lstError)){
    			objCampaign.addError(String.join(lstError, '</br>'), false);
    		}
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
    	Map<id, Campaign> mapOld = (Map<id, Campaign>)mapOldItems;
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
    	Map<id, Campaign> mapNew = (Map<id, Campaign>)mapNewItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
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
    	Map<id, Campaign> mapNew = (Map<id, Campaign>)mapNewItems;
    	Map<id, Campaign> mapOld = (Map<id, Campaign>)mapOldItems;
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
    	
    	Map<id, Campaign> mapOld = (Map<id, Campaign>)mapOldItems;
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
    	Map<id, Campaign> mapOld = (Map<id, Campaign>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
    
}