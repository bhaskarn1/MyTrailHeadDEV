/**
*@name          CCPM_journeyTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          04/05/2018
*@description   This is a controller or class
*@Class         CCPM_journeyTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    04/05/2018   Initial Implementation.
*/
public with sharing class CCPM_journeyTriggerHandler implements CCPM_ITriggerHandler{
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean boolTriggerDisabled = false;
     public static List<LOG_LogMessage__c> lstjourneyhdlrLogMsg = new List<LOG_LogMessage__c>();
    
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
        List<CCPM_journey__c> lstNew = (List<CCPM_journey__c>) lstNewItems;
        //Set<Id> acctIds = new Set<Id>();
        Map<string, Account> mapAccount = new Map<string, Account>();
        for(CCPM_Journey__c objJourney : lstNew){
            mapAccount.put(objJourney.CCPM_Account__c, new Account()); 
        }
        system.debug('*****check 1****'+mapAccount);
        mapAccount = new map<string, Account>([select id, CCPM_mobileNumber__c, (select id, mobilePhone from Contacts) from Account where Id in :mapAccount.keySet()]);
      
        
        //List<Account> lstAccount = [select id, CCPM_mobileNumber__c, (select id, mobilePhone from Contacts) from Account where Id in :acctIds];
        
        //Map<string,Contact> phoneContactMap = new Map<string,Contact>();
        
    /*  for(Account objAcc : lstAccount){           
            for(Contact objCon : objAcc.Contacts)
                phoneContactMap.put(objCon.MobilePhone,objCon);
        } */
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        for(CCPM_journey__c objJourney : lstNew){
            Account objAcc = mapAccount.get(objJourney.CCPM_account__c);
            if(objAcc!= null && CCPM_Collection.isNotNullEmpty(objAcc.Contacts)){
                for(Contact objCon : objAcc.Contacts){
                    if(objCon != null && string.isNotBlank(objJourney.CCPM_mobileNumber__c) && objCon.MobilePhone == objJourney.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty))
                    {
                        objJourney.CCPM_contact__c = objCon.Id;
                    }
                }           
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
        Map<id, CCPM_journey__c> mapNew = (Map<id, CCPM_journey__c>)mapNewItems;
        Map<id, CCPM_journey__c> mapOld = (Map<id, CCPM_journey__c>)mapOldItems;
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
        Map<id, CCPM_journey__c> mapOld = (Map<id, CCPM_journey__c>)mapOldItems;
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
        Map<id, CCPM_journey__c> mapNew = (Map<id, CCPM_journey__c>)mapNewItems;
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
        Map<id, CCPM_journey__c> mapNew = (Map<id, CCPM_journey__c>)mapNewItems;
        Map<id, CCPM_journey__c> mapOld = (Map<id, CCPM_journey__c>)mapOldItems;
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
        
        Map<id, CCPM_journey__c> mapOld = (Map<id, CCPM_journey__c>)mapOldItems;
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
        Map<id, CCPM_journey__c> mapOld = (Map<id, CCPM_journey__c>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
}