/**
*@name          CCPM_NPSTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          01/10/2018
*@description   This is a controller or class
*@Class         CCPM_NPSTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    01/10/2018   Initial Implementation.
Anupreeta Chakraborty (Deloitte)   01/11/2018   US -2359 Implementation of NPS data update on related Account.
*/
public with sharing class CCPM_NPSTriggerHandler implements CCPM_ITriggerHandler{
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean boolTriggerDisabled = false;
    public static List<LOG_LogMessage__c> lstNPShdlrLogMsg = new List<LOG_LogMessage__c>();
    
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
        List<CCPM_NPS__c> lstNew = (List<CCPM_NPS__c>) lstNewItems;
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
        Map<id, CCPM_NPS__c> mapNew = (Map<id, CCPM_NPS__c>)mapNewItems;
        Map<id, CCPM_NPS__c> mapOld = (Map<id, CCPM_NPS__c>)mapOldItems;
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
        Map<id, CCPM_NPS__c> mapOld = (Map<id, CCPM_NPS__c>)mapOldItems;
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
        Map<id, CCPM_NPS__c> mapNew = (Map<id, CCPM_NPS__c>)mapNewItems;
        Map<id, Account> mapAccntToUpdate = new Map<id, Account>();        

        /**************Method Declarations end*/    
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/

        for(CCPM_NPS__c objNPS : mapNew.values()){
            Account accntToUpdate;
            if(objNPS.CCPM_AccountHolderName__c != null){
                Account objAcc = new Account(Id=objNPS.CCPM_AccountHolderName__c);
                if(mapAccntToUpdate.containsKey(objNPS.CCPM_AccountHolderName__c)){
                    objAcc = mapAccntToUpdate.get(objNPS.CCPM_AccountHolderName__c);
                    if(objNPS.CCPM_dateSurveyCompleted__c!= null &&((objAcc.CCPM_NPSDateSurveyCompleted__c==null)||(objAcc.CCPM_NPSDateSurveyCompleted__c < objNPS.CCPM_dateSurveyCompleted__c))){
                    accntToUpdate = CCPM_NPSTriggerHandlerHelper.populateNPSAccountfields(objNPS);                        
                    }
                }
                else{
                    if(objNPS.CCPM_dateSurveyCompleted__c!= null &&((objNPS.CCPM_Account_Date_Survey_Completed__c==null)||objNPS.CCPM_Account_Date_Survey_Completed__c < objNPS.CCPM_dateSurveyCompleted__c)){
                    accntToUpdate = CCPM_NPSTriggerHandlerHelper.populateNPSAccountfields(objNPS);  
                    }
                }                
            }
            if(accntToUpdate != null){
                        mapAccntToUpdate.put(accntToUpdate.id,accntToUpdate);  
                    }
        }

        /**************First loop End*/
        try{
            if(CCPM_Collection.isNotNullEmpty(mapAccntToUpdate)){
                update mapAccntToUpdate.values();   
            }
        }
        catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_NPSTriggerHandler','AfterInsert','Exception thrown while updating Account with NPS data','');
            lstNPShdlrLogMsg.add(log); 
        }
        //insert all errors
        if(CCPM_Collection.isNotNullEmpty(lstNPShdlrLogMsg)){
            try{
                upsert lstNPShdlrLogMsg;
            }
            catch(DMLException e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_NPSTriggerHandler','AfterInsert','Exception thrown while upserting error logs for NPS trigger inside CCPM_NPSTriggerHandler',true);
            }
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
        Map<id, CCPM_NPS__c> mapNew = (Map<id, CCPM_NPS__c>)mapNewItems;
        Map<id, CCPM_NPS__c> mapOld = (Map<id, CCPM_NPS__c>)mapOldItems;
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
        
        Map<id, CCPM_NPS__c> mapOld = (Map<id, CCPM_NPS__c>)mapOldItems;
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
        Map<id, CCPM_NPS__c> mapOld = (Map<id, CCPM_NPS__c>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
}