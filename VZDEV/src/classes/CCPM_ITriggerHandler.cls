/**
*@name          CCPM_ITriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          10/5/2017
*@description   This is a interface as part of the Trigger Framework 
*@Class         CCPM_ITriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    10/05/2017   Initial Implementation.
*/
public interface CCPM_ITriggerHandler  {
    
    void BeforeInsert(List<SObject> lstnewItems);
 
    void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems);
 
    void BeforeDelete(Map<Id, SObject> mapOldItems);
 
    void AfterInsert(Map<Id, SObject> mapNewItems);
 
    void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems);
 
    void AfterDelete(Map<Id, SObject> mapOldItems);
 
    void AfterUndelete(Map<Id, SObject> mapOldItems);
 
    Boolean IsDisabled();
}