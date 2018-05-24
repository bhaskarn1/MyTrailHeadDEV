/**
*@name          CCPM_taskTriggerHandlerHelper 
*@author        Aneesha Ragireddy (Deloitte)
*@date          10/20/2017
*@description   This is a helpper class for CCPM_taskTriggerHandler
*@Class         CCPM_taskTriggerHandlerHelper
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Aneesha Ragireddy (Deloitte)    10/20/2017   Initial Implementation.
*/
/* This method returns the List of Leads for which Task Status is changed to Completed or Cancelled */ 
public class CCPM_taskTriggerHandlerHelper {
    public static Lead updateLeadReminder(Task objTask, Map<String, Lead> mapLead){
        system.debug('%%%% Inside updateLeadReminder: 16'+ objTask);
        system.debug('%%%% Inside updateLeadReminder: 16'+ mapLead.size());
        Lead objlead = null; 
        if(objTask.Status == Label.CCPM_taskCompleted){
            objlead = new Lead(id = objTask.whoid, CCPM_reminder__c = Label.CCPM_reminderCompleted);
        }
        else if(objTask.Status == Label.CCPM_taskCancelled && CCPM_Collection.isNotNullEmpty(mapLead) && mapLead.containsKey(objTask.whoid))
        {
          system.debug('%%%% Inside Else If : 23');
            if(mapLead.get(objTask.whoid).Tasks == null || mapLead.get(objTask.whoid).Tasks.size() == 0){
               system.debug('%%%% Inside If : 25');
                objlead = new Lead(id = objTask.whoid, CCPM_reminder__c = Label.CCPM_none);
            }
        }
        return objlead;
    }
    
    public static Boolean isTaskRelatedToLead(String whoId){
        String Lead_prefix = Schema.SobjectType.Lead.getKeyPrefix();
        
        return (whoId!=null && whoId.startswith(Lead_prefix)) ? true : false;
        
    }
}