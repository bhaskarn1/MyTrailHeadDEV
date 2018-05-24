/**
*@name          CCPM_CampaignMemberTriggerHandler 
*@author        Sriraman Sridharan (Deloitte)
*@date          10/05/2017
*@description   This is a controller or class
*@Class         CCPM_CampaignMemberTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Sriraman Sridharan,
Bharath Ammanamanchi (Deloitte)    10/05/2017   Initial Implementation.
Brigadesh Chandrasekar(Deloitte)   10/15/2017   Modified Version to account for Dynamic URL,Dynamic Store Ecode and Dynamic DATE on SMS body
*/
public class CCPM_CampaignMemberTriggerHandler implements CCPM_ITriggerHandler{
    
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    public static Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapBusinessHoursNameRec;
    public static String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
    public static DateTime dtmSysNow = System.now();
    /**
	@author       Bharath Ammanamanchi (Deloitte)
				  Brigadesh Chandrasekar (Deloitte)
	@description  Checks to see if the trigger has been disabled either by custom setting or by running code
	@param        N/A
	@return       Boolean
	*/ 
    public Boolean IsDisabled()
    {
        system.debug('!!! CCPM_CampaignMemberTriggerHandler !!!');
        CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(UserInfo.getUserId());
        if(settings != null && settings.CCPM_DisableTrigger__c == true){
            return true;
        }
        else
            return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems) {

        
        /**************Method Declarations Start*/
        List<CampaignMember> lstNew = (List<CampaignMember>)newItems;
        
        List<CCPM_SMSMessage__c> lstSmsMessage = new List<CCPM_SMSMessage__c>();
        Map<id, Lead> mapLeadsToBeUpdated = new map<id, Lead>();
        Map<id, Campaign> mapCampaign = new map<id, Campaign>();
        Map<id, Lead> mapLead = new map<id, Lead>();
        
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop for before Update Start*/
        
        if(lstNew!=null && lstNew.size()>0){
            for(CampaignMember objCampaignMember: lstNew){
                //Get the set of leads and campaigns
                if(objCampaignMember.LeadId != null){
                    //add Lead field to the list from all the leads
                    mapLead.put(objCampaignMember.LeadId, new Lead());
                }
                if(objCampaignMember.CampaignId != null){
                    //add Campaign field to the list from all the Campaigns
                    mapCampaign.put(objCampaignMember.CampaignId, new Campaign());
                }
            }
        }
        
        /**************First loop for Before Update End*/
        
        //Fetch the related open leads
        try{
            mapLead = new Map<id, Lead>([SELECT id,name,RecordTypeId,CCPM_isManualLead__c,CCPM_Account__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_StoreTimeZone__c,
            							CCPM_cartID__c,CCPM_mobileNumber__c,CCPM_storeEcode__c, Store__c,CCPM_storeName__c,CCPM_Type__c,CCPM_ownerFirstName__c,
            							CCPM_storeRecommendedHours__c,OwnerId,CCPM_SMSOptOut__c,CCPM_triggerInitialSMSDateTime__c,CCPM_CampingFollowUpMessageTemplate__c,
            							Store__r.CCPM_market__c,Store__r.CCPM_territory__c,Store__r.CCPM_district__c,CCPM_storeDistrict__c,CCPM_storeTerritory__c,CCPM_storeMarket__c 
            							From Lead 
										Where Id IN :mapLead.keySet() AND Status IN :CCPM_Utility.setOpenLeadStatus]);
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'scheduleMessages','scheduleMessages','Exception thrown while querying for leads',true); 
        }
        //Fetch the campaigns
        try{
            mapCampaign = new Map<id, Campaign>([SELECT id,name,                                      
            									(Select Id, CCPM_followupMessage__c, CCPM_initialMessage__c 
            										From CCPM_smsTemplates__r 
            										Where CCPM_isActive__c = true AND CCPM_startDate__c <=: dtmSysNow AND CCPM_endDate__c >= :dtmSysNow Order by CreatedDate Desc Limit 1)
            									From Campaign 
            									Where Id IN :mapCampaign.keySet()]);        
           
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'scheduleMessages','scheduleMessages','Exception thrown while querying for leads',true); 
        }
        
        /**************Second Loop Start*/
        for(CampaignMember objCampMem: lstNew){
        	Lead objLead;
            Campaign objCampaign;
            
            if(objCampMem.LeadId != null && mapLead.containsKey(objCampMem.LeadId)){
                objLead = mapLead.get(objCampMem.LeadId);  
            }
            
            if(objCampMem.CampaignId != null && mapCampaign.containsKey(objCampMem.CampaignId)){
                objCampaign = mapCampaign.get(objCampMem.CampaignId);
            }
            if(objLead == null){
            	objCampMem.addError('The assigned Lead does not qualify as a campaign member');
            }
            if(objCampaign == null){
            	objCampMem.addError('The assigned Campaign does not qualify as a campaign member');
            }

            if(objLead != null && objCampaign != null && CCPM_Collection.isNotNullEmpty(objCampaign.CCPM_smsTemplates__r) 
            	&& objLead.RecordTypeId == strLeadCustomerCartRT && objLead.CCPM_Type__c == Label.CCPM_leadTypeCampaignLead
            	&& !objLead.CCPM_Account__r.CCPM_SMSOptOut__c){
            		CCPM_CampaignMemberTriggerHandlerHelper.updateLeadFromCampaignMemeber(objLead, objCampaign);
            		mapLeadsToBeUpdated.put(objLead.Id, objLead);
            		
            		CCPM_SMSMessage__c objSmsMessage = CCPM_CampaignMemberTriggerHandlerHelper.createSMSForCampaignMember(objLead, objCampaign);
            		if(objSmsMessage != null){
            			lstSmsMessage.add(objSmsMessage);
            		}
            	}
        }
        /**************Second Loop End*/
        
        if(CCPM_Collection.isNotNullEmpty(lstSmsMessage)){
            try{
                insert lstSmsMessage;
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_CampaignMemberHandler','BeforeInsert','Exception thrown while inserting SMSMessages for the Lead owner',true);
            }
        }
        
        if(CCPM_Collection.isNotNullEmpty(mapLeadsToBeUpdated)){ 
            try{
                update mapLeadsToBeUpdated.values(); 
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_CampaignMemberHandler','BeforeInsert','Exception thrown while Updating leads',true);
            }
        }
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  is called in the before update trigger context
	@param        List<SObject>
	@return       void
	*/ 
    public void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, CampaignMember> mapNew = (Map<id, CampaignMember>)mapNewItems;
        Map<id, CampaignMember> mapOld = (Map<id, CampaignMember>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
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
        Map<id, CampaignMember> mapOld = (Map<id, CampaignMember>)mapOldItems;
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
        Map<id, CampaignMember> mapNew = (Map<id, CampaignMember>)mapNewItems;
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
        Map<id, CampaignMember> mapNew = (Map<id, CampaignMember>)mapNewItems;
        Map<id, CampaignMember> mapOld = (Map<id, CampaignMember>)mapOldItems;
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
        
        Map<id, CampaignMember> mapOld = (Map<id, CampaignMember>)mapOldItems;
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
        Map<id, CampaignMember> mapOld = (Map<id, CampaignMember>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
}