/**
*@name          CCPM_segmentationTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          04/14/2018
*@description   This is a handler for CCPM_segmentation trigger. 
*@Class         CCPM_segmentationTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    04/14/2018   Initial Implementation.
*/
public with sharing class CCPM_segmentationTriggerHandler implements CCPM_ITriggerHandler{
    
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
    	List<CCPM_segmentation__c> lstNew = (List<CCPM_segmentation__c>) lstNewItems;
    	Map<String, Campaign> mapCampaign = new Map<String, Campaign>();
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	for(CCPM_segmentation__c objSeg : lstNew){
    		if(objSeg.CCPM_campaign__c !=  null && objSeg.CCPM_isActive__c){
    			mapCampaign.put(objSeg.CCPM_campaign__c, new Campaign());
    		}
    	}
    	/**************First loop End*/
    	
    	mapCampaign = new Map<String, Campaign>([Select id, Name, (Select Id, CCPM_districts1__c, CCPM_districts2__c, CCPM_districts3__c, CCPM_markets__c, CCPM_territories__c From CCPM_segmentations__r Where CCPM_isActive__c = true) From Campaign Where Id IN: mapCampaign.keyset()]);
    	
    	/**************Second Loop Start*/
    	for(CCPM_segmentation__c objSeg : lstNew){
    		
    		Set<String> setDistricts = new Set<String>();
			if(String.isNotBlank(objSeg.CCPM_districts1__c)){
				setDistricts.addAll(CCPM_utility.getSetFromString(objSeg.CCPM_districts1__c , ';'));
			}
			if(String.isNotBlank(objSeg.CCPM_districts2__c)){
				setDistricts.addAll(CCPM_utility.getSetFromString(objSeg.CCPM_districts2__c , ';'));
			}
			if(String.isNotBlank(objSeg.CCPM_districts3__c)){
				setDistricts.addAll(CCPM_utility.getSetFromString(objSeg.CCPM_districts3__c , ';'));
			}
    		
    		if(objSeg.CCPM_campaign__c !=  null && objSeg.CCPM_isActive__c){
    			Campaign objCampaign = mapCampaign.get(objSeg.CCPM_campaign__c);
    			if(CCPM_Collection.isNotNullEmpty(objCampaign.CCPM_segmentations__r)){
    				for(CCPM_segmentation__c objSegCampaign : objCampaign.CCPM_segmentations__r){
	    				Set<String> setSegCampaignDistricts = new Set<String>();
	    				if(String.isNotBlank(objSegCampaign.CCPM_districts1__c)){
	    					setSegCampaignDistricts.addAll(CCPM_utility.getSetFromString(objSegCampaign.CCPM_districts1__c , ';'));
	    				}
	    				if(String.isNotBlank(objSegCampaign.CCPM_districts2__c)){
	    					setSegCampaignDistricts.addAll(CCPM_utility.getSetFromString(objSegCampaign.CCPM_districts2__c , ';'));
	    				}
	    				if(String.isNotBlank(objSegCampaign.CCPM_districts3__c)){
	    					setSegCampaignDistricts.addAll(CCPM_utility.getSetFromString(objSegCampaign.CCPM_districts3__c , ';'));
	    				}
	    				List<String> lstOverlappingDisct = new List<String>();
	    				for(String strDisct : setDistricts){
	    					if(setSegCampaignDistricts.contains(strDisct)){
	    						lstOverlappingDisct.add(strDisct);
	    					}
	    				}
	    				if(CCPM_Collection.isNotNullEmpty(lstOverlappingDisct)){
	    					objSeg.addError('Overlapping Disctricts found for <u><i>'+ objCampaign.Name +'</i></u> : '+String.join(lstOverlappingDisct, ','), false);
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
    	Map<id, CCPM_segmentation__c> mapNew = (Map<id, CCPM_segmentation__c>)mapNewItems;
    	Map<id, CCPM_segmentation__c> mapOld = (Map<id, CCPM_segmentation__c>)mapOldItems;
    	Map<String, Campaign> mapCampaign = new Map<String, Campaign>();
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	for(CCPM_segmentation__c objSeg : mapNew.values()){
    		if(objSeg.CCPM_campaign__c !=  null && objSeg.CCPM_isActive__c){
    			mapCampaign.put(objSeg.CCPM_campaign__c, new Campaign());
    		}
    	}
    	/**************First loop End*/
    	
    	mapCampaign = new Map<String, Campaign>([Select id, Name, (Select Id, CCPM_districts1__c, CCPM_districts2__c, CCPM_districts3__c, CCPM_markets__c, CCPM_territories__c From CCPM_segmentations__r Where CCPM_isActive__c = true) From Campaign Where Id IN: mapCampaign.keyset()]);
    	
    	/**************Second Loop Start*/
    	for(CCPM_segmentation__c objSeg : mapNew.values()){
    		
    		Set<String> setDistricts = new Set<String>();
			if(String.isNotBlank(objSeg.CCPM_districts1__c)){
				setDistricts.addAll(CCPM_utility.getSetFromString(objSeg.CCPM_districts1__c , ';'));
			}
			if(String.isNotBlank(objSeg.CCPM_districts2__c)){
				setDistricts.addAll(CCPM_utility.getSetFromString(objSeg.CCPM_districts2__c , ';'));
			}
			if(String.isNotBlank(objSeg.CCPM_districts3__c)){
				setDistricts.addAll(CCPM_utility.getSetFromString(objSeg.CCPM_districts3__c , ';'));
			}
    		
    		if(objSeg.CCPM_campaign__c !=  null && objSeg.CCPM_isActive__c){
    			Campaign objCampaign = mapCampaign.get(objSeg.CCPM_campaign__c);
    			if(CCPM_Collection.isNotNullEmpty(objCampaign.CCPM_segmentations__r)){
    				for(CCPM_segmentation__c objSegCampaign : objCampaign.CCPM_segmentations__r){
	    				Set<String> setSegCampaignDistricts = new Set<String>();
	    				if(String.isNotBlank(objSegCampaign.CCPM_districts1__c)){
	    					setSegCampaignDistricts.addAll(CCPM_utility.getSetFromString(objSegCampaign.CCPM_districts1__c , ';'));
	    				}
	    				if(String.isNotBlank(objSegCampaign.CCPM_districts2__c)){
	    					setSegCampaignDistricts.addAll(CCPM_utility.getSetFromString(objSegCampaign.CCPM_districts2__c , ';'));
	    				}
	    				if(String.isNotBlank(objSegCampaign.CCPM_districts3__c)){
	    					setSegCampaignDistricts.addAll(CCPM_utility.getSetFromString(objSegCampaign.CCPM_districts3__c , ';'));
	    				}
	    				List<String> lstOverlappingDisct = new List<String>();
	    				for(String strDisct : setDistricts){
	    					if(setSegCampaignDistricts.contains(strDisct)){
	    						lstOverlappingDisct.add(strDisct);
	    					}
	    				}
	    				if(CCPM_Collection.isNotNullEmpty(lstOverlappingDisct)){
	    					objSeg.addError('Overlapping Disctricts found for <u><i>'+ objCampaign.Name +'</i></u> : '+String.join(lstOverlappingDisct, ','), false);
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
    	Map<id, CCPM_segmentation__c> mapOld = (Map<id, CCPM_segmentation__c>)mapOldItems;
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
    	Map<id, CCPM_segmentation__c> mapNew = (Map<id, CCPM_segmentation__c>)mapNewItems;
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
    	Map<id, CCPM_segmentation__c> mapNew = (Map<id, CCPM_segmentation__c>)mapNewItems;
    	Map<id, CCPM_segmentation__c> mapOld = (Map<id, CCPM_segmentation__c>)mapOldItems;
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
    	
    	Map<id, CCPM_segmentation__c> mapOld = (Map<id, CCPM_segmentation__c>)mapOldItems;
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
    	Map<id, CCPM_segmentation__c> mapOld = (Map<id, CCPM_segmentation__c>)mapOldItems;
    	/**************Method Declarations end*/
    	
    	/**************Methods calling functionalities in other classes start. */
    	
    	/**************Methods calling functionalities in other classes end.*/
    	
    	/**************First Loop Start*/
    	
    	/**************First loop End*/
    }
    
}