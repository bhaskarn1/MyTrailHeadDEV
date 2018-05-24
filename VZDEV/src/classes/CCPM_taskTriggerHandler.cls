/**
*@name          CCPM_taskTriggerHandler 
*@author        Aneesha Ragireddy (Deloitte)
*@date          11/09/2017
*@description   This is a handler for CCPM_task.trigger
*@Class         CCPM_taskTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Aneesha Ragireddy (Deloitte)       11/09/2017   Initial Implementation.
*/
public with sharing class CCPM_taskTriggerHandler  implements CCPM_ITriggerHandler{
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean boolTriggerDisabled = false;
    Set<String> setTaskOpenStatus = CCPM_utility.getSetFromString(Label.CCPM_telesalesTaskStatus, ',');
    public static Map<String, Lead> mapLead = new Map<String, Lead>();
    
    public static List<LOG_LogMessage__c> lstleadhdlrLogMsg = new List<LOG_LogMessage__c>(); 
    /**
    @author       Aneesha Ragireddy (Deloitte)
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
    @author       Aneesha Ragireddy (Deloitte)
    @description  is called in the before insert trigger context
    @param        List<SObject>
    @return       void
    */     
    public void BeforeInsert(List<Task> lstNewItems) {
        /**************Method Declarations Start*/
        //set<id> leadId=new set<id>();
        
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
 
        /**************First loop End*/
    }
    /**
    @author       Aneesha Ragireddy (Deloitte)
    @description  is called in the before update trigger context
    @param        List<SObject>
    @return       void
    */ 
    public void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Task> mapNew = (Map<id, Task>)mapNewItems;
        Map<id, Task> mapOld = (Map<id, Task>)mapOldItems;
        
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        for(Task objTask : mapNew.values()){
            
            if(CCPM_taskTriggerHandlerHelper.isTaskRelatedToLead(objTask.whoId)){
                mapLead.put(objTask.whoId, new Lead());
            }
            
        }
        /**************First loop End*/
        

    }
    /**
    @author       Aneesha Ragireddy (Deloitte)
    @description  is called in the before delete trigger context
    @param        List<SObject>
    @return       void
    */ 
    public void BeforeDelete(Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Task> mapOld = (Map<id, Task>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
    /**
    @author       Aneesha Ragireddy (Deloitte)
    @description  is called in the after insert trigger context
    @param        List<SObject>
    @return       void
    */ 
    public void AfterInsert(Map<Id, SObject> mapNewItems){
        /**************Method Declarations Start*/
        Map<id, Task> mapNew = (Map<id, Task>)mapNewItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
        if(CCPM_Collection.isNotNullEmpty(lstleadhdlrLogMsg)){
            upsert lstleadhdlrLogMsg;
        }
    }
    /**
    @author       Aneesha Ragireddy (Deloitte)
    @description  is called in the after update trigger context
    @param        List<SObject>
    @return       void
    */ 
    public void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Task> mapNew = (Map<id, Task>)mapNewItems;
        Map<id, Task> mapOld = (Map<id, Task>)mapOldItems;
        List<Lead> lstLead = new List<Lead>();
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        system.debug('%%%% Inside : AfterUpdate 144'+ mapLead.size());
        if(CCPM_Collection.isNotNullEmpty(mapLead)){
           system.debug('%%%% Inside : AfterUpdate 146'+ mapLead.size());
            mapLead = new Map<String, Lead>([Select id, (Select id, Status from Tasks WHERE RecordType.Name =:Label.CCPM_taskToDoRT and Status IN:setTaskOpenStatus Order By CreatedDate DESC) 
                                FROM Lead where id IN:mapLead.keySet()]);
        }
        
        /**************First Loop Start*/
        for(Task objTask : mapNew.values()){
            
            if(CCPM_taskTriggerHandlerHelper.isTaskRelatedToLead(objTask.whoId)){
                Lead objNew = CCPM_taskTriggerHandlerHelper.updateLeadReminder(objTask, mapLead);
                if(objNew != null){
                    lstLead.add(objNew);
                }
            }
        }
        /**************First loop End*/
        if(CCPM_Collection.isNotNullEmpty(lstLead)){
            try{
                update lstLead;
            }  
            catch(exception e){
                lstleadhdlrLogMsg.add(CCPM_utility.logMessage(e, 'Error', 'CCPM_taskTriggerHandler', 'BeforeUpdate', 'Error while updating leads from reminder', ''));  
            }
        }
        
        if(CCPM_Collection.isNotNullEmpty(lstleadhdlrLogMsg)){
            upsert lstleadhdlrLogMsg;
        }
    }
    /**
    @author       Aneesha Ragireddy (Deloitte)
    @description  is called in the after delete trigger context
    @param        List<SObject>
    @return       void
    */ 
    public void AfterDelete(Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        
        Map<id, Task> mapOld = (Map<id, Task>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
    /**
    @author       Aneesha Ragireddy (Deloitte)
    @description  is called in the After undelete trigger context
    @param        List<SObject>
    @return       void
    */ 
    public void AfterUndelete(Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Task> mapOld = (Map<id, Task>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
    
    
}