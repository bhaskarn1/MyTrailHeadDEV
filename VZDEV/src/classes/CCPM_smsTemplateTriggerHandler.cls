/**
*@name          CCPM_smsTemplateTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          04/06/2018
*@description   This is a template class for Tirgger Framework. 
*@Class         CCPM_smsTemplateTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    04/06/2018   Initial Implementation.
*/
public with sharing class CCPM_smsTemplateTriggerHandler  implements CCPM_ITriggerHandler{
    
    public static String strEventSMSTemplate = Schema.SObjectType.CCPM_smsTemplate__c.getRecordTypeInfosByName().get('Event Message Template').getRecordTypeId();
    
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
    	List<CCPM_smsTemplate__c> lstNew = (List<CCPM_smsTemplate__c>) lstNewItems;
    	Map<String, Campaign> mapCampaign = new Map<String, Campaign>();
    	Map<String, CCPM_segmentation__c> mapSegmentation = new Map<String, CCPM_segmentation__c>();
    	List<String> lstError = new List<String>();
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
        for(CCPM_smsTemplate__c objSMSTemp : lstNew){
        	if(objSMSTemp.CCPM_isActive__c){
        		if(objSMSTemp.CCPM_campaign__c != null){
	        		mapCampaign.put(objSMSTemp.CCPM_campaign__c, new Campaign());
	        	}
	        	if(objSMSTemp.CCPM_segmentation__c != null){
	        		mapSegmentation.put(objSMSTemp.CCPM_segmentation__c, new CCPM_segmentation__c());
	        	}
        	}
        }
    	/**************First loop End*/
    	
    	if(CCPM_Collection.isNotNullEmpty(mapCampaign)){
    		mapCampaign = new Map<String, Campaign>([Select id, Name , (Select Name, CCPM_endDate__c, CCPM_startDate__c From CCPM_smsTemplates__r) From Campaign Where Id IN: mapCampaign.keySet()]);
    	}
    	if(CCPM_Collection.isNotNullEmpty(mapSegmentation)){
    		mapSegmentation = new Map<String, CCPM_segmentation__c>([Select id, (Select Name, CCPM_endDate__c, CCPM_eventMessageEndDate__c, CCPM_eventMessageStartDate__c, CCPM_startDate__c From CCPM_smsTemplates__r) From CCPM_segmentation__c Where id IN:mapSegmentation.keySet()]);
    	}
    	/**************Second Loop Start*/
        for(CCPM_smsTemplate__c objSMSTemp : lstNew){
        	
            DateTime dtmNewEvntMsgStDate, dtmNewEvntMsgEndDate;
            if(String.isNotBlank(objSMSTemp.CCPM_eventMessageStartDate__c)){
    			try{
    				dtmNewEvntMsgStDate = DateTime.valueofGmt(objSMSTemp.CCPM_eventMessageStartDate__c);
    			}
    			catch(Exception e){
    				objSMSTemp.CCPM_eventMessageStartDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objSMSTemp.CCPM_eventMessageEndDate__c)){
    			try{
    				dtmNewEvntMsgEndDate = DateTime.valueofGmt(objSMSTemp.CCPM_eventMessageEndDate__c);
    			}
    			catch(Exception e){
    				objSMSTemp.CCPM_eventMessageEndDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if((dtmNewEvntMsgStDate != null && dtmNewEvntMsgEndDate != null && dtmNewEvntMsgEndDate <= dtmNewEvntMsgStDate) || 
    			(objSMSTemp.CCPM_startDate__c != null && objSMSTemp.CCPM_endDate__c != null && objSMSTemp.CCPM_endDate__c <= objSMSTemp.CCPM_startDate__c) ){
    			objSMSTemp.addError('SMS Start Date cannot be greater than SMS End Date.');
    		}
    		if(objSMSTemp.CCPM_isActive__c){
    			if(objSMSTemp.CCPM_campaign__c != null){
	        		Campaign objCampaign = mapCampaign.get(objSMSTemp.CCPM_campaign__c); 
	        		
	        		for(CCPM_smsTemplate__c objExistSMSTemp : objCampaign.CCPM_smsTemplates__r){
	        			if(!(objExistSMSTemp.CCPM_endDate__c <= objSMSTemp.CCPM_startDate__c || objExistSMSTemp.CCPM_startDate__c >=objSMSTemp.CCPM_endDate__c)){
	        				objSMSTemp.addError('Dates overlapping with '+ objExistSMSTemp.Name);			
	        			}
	        		}
	        	}
	        	if(objSMSTemp.CCPM_segmentation__c != null){
	        		CCPM_segmentation__c objSeg = mapSegmentation.get(objSMSTemp.CCPM_segmentation__c);
	        		
	        		for(CCPM_smsTemplate__c objExistSMSTemp : objSeg.CCPM_smsTemplates__r){
	        			if(!(objExistSMSTemp.CCPM_endDate__c <= objSMSTemp.CCPM_startDate__c || objExistSMSTemp.CCPM_startDate__c >=objSMSTemp.CCPM_endDate__c)){
	        				objSMSTemp.addError('Dates overlapping with '+ objExistSMSTemp.Name);			
	        			}
	        			DateTime dtmExistEvntMsgStDate, dtmExistEvntMsgEndDate;	
	        			if(String.isNotBlank(objExistSMSTemp.CCPM_eventMessageStartDate__c)){
		        			dtmExistEvntMsgStDate = DateTime.valueofGmt(objExistSMSTemp.CCPM_eventMessageStartDate__c);
		        		}
		        		if(String.isNotBlank(objExistSMSTemp.CCPM_eventMessageEndDate__c)){
		        			dtmExistEvntMsgEndDate = DateTime.valueofGmt(objExistSMSTemp.CCPM_eventMessageEndDate__c);
		        		}  
		        		if(!(dtmExistEvntMsgEndDate <= dtmNewEvntMsgStDate || dtmExistEvntMsgStDate >=dtmNewEvntMsgEndDate)){
	        				objSMSTemp.addError('Dates overlapping with '+ objExistSMSTemp.Name);			
	        			}    			
	        		}
	        	}
    		}
        }
    	/**************Second loop End*/
    }
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the before update trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, CCPM_smsTemplate__c> mapNew = (Map<id, CCPM_smsTemplate__c>)mapNewItems;
    	Map<id, CCPM_smsTemplate__c> mapOld = (Map<id, CCPM_smsTemplate__c>)mapOldItems;
    	
    	Map<String, Campaign> mapCampaign = new Map<String, Campaign>();
    	Map<String, CCPM_segmentation__c> mapSegmentation = new Map<String, CCPM_segmentation__c>();
    	List<String> lstError = new List<String>();
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
        for(CCPM_smsTemplate__c objSMSTemp : mapNew.values()){
        	if(objSMSTemp.CCPM_isActive__c){
        		if(objSMSTemp.CCPM_campaign__c != null){
	        		mapCampaign.put(objSMSTemp.CCPM_campaign__c, new Campaign());
	        	}
	        	if(objSMSTemp.CCPM_segmentation__c != null){
	        		mapSegmentation.put(objSMSTemp.CCPM_segmentation__c, new CCPM_segmentation__c());
	        	}
        	}
        }
    	/**************First loop End*/
    	
    	if(CCPM_Collection.isNotNullEmpty(mapCampaign)){
    		mapCampaign = new Map<String, Campaign>([Select id, Name , (Select Name, CCPM_endDate__c, CCPM_startDate__c From CCPM_smsTemplates__r) From Campaign Where Id IN: mapCampaign.keySet()]);
    	}
    	if(CCPM_Collection.isNotNullEmpty(mapSegmentation)){
    		mapSegmentation = new Map<String, CCPM_segmentation__c>([Select id, (Select Name, CCPM_endDate__c, CCPM_eventMessageEndDate__c, CCPM_eventMessageStartDate__c, CCPM_startDate__c From CCPM_smsTemplates__r) From CCPM_segmentation__c Where id IN:mapSegmentation.keySet()]);
    	}
    	/**************Second Loop Start*/
        for(CCPM_smsTemplate__c objSMSTemp : mapNew.values()){
        	
            DateTime dtmNewEvntMsgStDate, dtmNewEvntMsgEndDate;
            if(String.isNotBlank(objSMSTemp.CCPM_eventMessageStartDate__c)){
    			try{
    				dtmNewEvntMsgStDate = DateTime.valueofGmt(objSMSTemp.CCPM_eventMessageStartDate__c);
    			}
    			catch(Exception e){
    				objSMSTemp.CCPM_eventMessageStartDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if(String.isNotBlank(objSMSTemp.CCPM_eventMessageEndDate__c)){
    			try{
    				dtmNewEvntMsgEndDate = DateTime.valueofGmt(objSMSTemp.CCPM_eventMessageEndDate__c);
    			}
    			catch(Exception e){
    				objSMSTemp.CCPM_eventMessageEndDate__c.addError('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
    			}
    		}
    		if((dtmNewEvntMsgStDate != null && dtmNewEvntMsgEndDate != null && dtmNewEvntMsgEndDate <= dtmNewEvntMsgStDate) || 
    			(objSMSTemp.CCPM_startDate__c != null && objSMSTemp.CCPM_endDate__c != null && objSMSTemp.CCPM_endDate__c <= objSMSTemp.CCPM_startDate__c) ){
    			objSMSTemp.addError('SMS Start Date cannot be greater than SMS End Date.');
    		}
    		if(objSMSTemp.CCPM_isActive__c){
    			if(objSMSTemp.CCPM_campaign__c != null ){
	        		Campaign objCampaign = mapCampaign.get(objSMSTemp.CCPM_campaign__c); 
	        		
	        		for(CCPM_smsTemplate__c objExistSMSTemp : objCampaign.CCPM_smsTemplates__r){
	        			if((objSMSTemp.id != objExistSMSTemp.Id) && !(objExistSMSTemp.CCPM_endDate__c <= objSMSTemp.CCPM_startDate__c || objExistSMSTemp.CCPM_startDate__c >=objSMSTemp.CCPM_endDate__c)){
	        				objSMSTemp.addError('Dates overlapping with '+ objExistSMSTemp.Name);			
	        			}
	        		}
	        	}
	        	if(objSMSTemp.CCPM_segmentation__c != null){
	        		CCPM_segmentation__c objSeg = mapSegmentation.get(objSMSTemp.CCPM_segmentation__c);
	        		
	        		for(CCPM_smsTemplate__c objExistSMSTemp : objSeg.CCPM_smsTemplates__r){
	        			if(objSMSTemp.id != objExistSMSTemp.Id){
	        				if(!(objExistSMSTemp.CCPM_endDate__c <= objSMSTemp.CCPM_startDate__c || objExistSMSTemp.CCPM_startDate__c >=objSMSTemp.CCPM_endDate__c)){
	        				objSMSTemp.addError('Dates overlapping with '+ objExistSMSTemp.Name);			
		        			}
		        			DateTime dtmExistEvntMsgStDate, dtmExistEvntMsgEndDate;	
		        			if(String.isNotBlank(objExistSMSTemp.CCPM_eventMessageStartDate__c)){
			        			dtmExistEvntMsgStDate = DateTime.valueofGmt(objExistSMSTemp.CCPM_eventMessageStartDate__c);
			        		}
			        		if(String.isNotBlank(objExistSMSTemp.CCPM_eventMessageEndDate__c)){
			        			dtmExistEvntMsgEndDate = DateTime.valueofGmt(objExistSMSTemp.CCPM_eventMessageEndDate__c);
			        		}  
			        		if(!(dtmExistEvntMsgEndDate <= dtmNewEvntMsgStDate || dtmExistEvntMsgStDate >=dtmNewEvntMsgEndDate)){
		        				objSMSTemp.addError('Dates overlapping with '+ objExistSMSTemp.Name);			
		        			}   
	        			}	        			 			
	        		}
	        	}
    		}
        }
    	/**************Second loop End*/
    }
 	/**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the before delete trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void BeforeDelete(Map<Id, SObject> mapOldItems){
    	/**************Method Declarations Start*/
    	Map<id, CCPM_smsTemplate__c> mapOld = (Map<id, CCPM_smsTemplate__c>)mapOldItems;
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
    	Map<id, CCPM_smsTemplate__c> mapNew = (Map<id, CCPM_smsTemplate__c>)mapNewItems;
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
    	Map<id, CCPM_smsTemplate__c> mapNew = (Map<id, CCPM_smsTemplate__c>)mapNewItems;
    	Map<id, CCPM_smsTemplate__c> mapOld = (Map<id, CCPM_smsTemplate__c>)mapOldItems;
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
    	
    	Map<id, CCPM_smsTemplate__c> mapOld = (Map<id, CCPM_smsTemplate__c>)mapOldItems;
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
    	Map<id, CCPM_smsTemplate__c> mapOld = (Map<id, CCPM_smsTemplate__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
}