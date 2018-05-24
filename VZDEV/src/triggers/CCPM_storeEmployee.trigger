/**
*@name          CCPM_storeEmployee
*@author        Paras Shah (Deloitte)
*@date          08/08/2017
@description    Trigger for Store Employee object
@testClass      CCPM_storeEmployeeTest
Modification    Log:
------------------------------------------------------------------------------------
Developer              					 Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)  				  08/08/2017                          Original Version - Added as a part of US 1615
Sriraman Sridharan(Deloitte)										      Updated Version -  1714, 1718, 1751
Brigadesh Chandrasekar(Deloitte	)     08/28/2017						  Updated Version -  1719	
Tanweer Maridia(Deloitte)             11/07/2017                          Moved the code to batch. 
Bharath Ammanamanchi (Deloitte)       11/08/2017                          Transition to Trigger Framework and optimized the code. 
*/
/*
trigger CCPM_storeEmployee on CCPM_storeEmployee__c (before insert, before update, after insert, after update, after delete) {
    
    if(Trigger.isBefore) {
        List<Lead> lstLeadsAssociatedToStoreEmployees = CCPM_storeEmployeeHandler.getListofOpenLeadsForUpdatedEmployees(Trigger.new, Trigger.oldMap);
        Map<String,Group> mapDistrictAndGroup = CCPM_leadHandlerAssignOwnership.getMapOfStoreDistrictAndGroup();
        //List<BusinessHours> lstBusinessHours = CCPM_LeadHandler.getBusinessHours();
        BusinessHours objDefaultBusinessHour = CCPM_utility.objDefaultBusinessHour;
        List<BusinessHours> lstBusinessHours = new List<BusinessHours>();
        if(objDefaultBusinessHour ==null){
       		  lstBusinessHours = CCPM_utility.getBusinessHours();
        }
        else{
          lstBusinessHours.add(objDefaultBusinessHour);
        }
        if(Trigger.isUpdate) {
             
            List<CCPM_storeemployee__c> lstStoreEmployeeAfterUpdatingOwner = new List<CCPM_StoreEmployee__c>();
            lstStoreEmployeeAfterUpdatingOwner = CCPM_storeEmployeeHandler.updateOwnerForAssociatedLeads(Trigger.new, Trigger.old, lstLeadsAssociatedToStoreEmployees,mapDistrictAndGroup,lstBusinessHours);
            system.debug('@@@lstStoreEmployeeAfterUpdatingOwner: ' + lstStoreEmployeeAfterUpdatingOwner);
            
            //List<CCPM_storeemployee__c> lstStoreEmployee = new List<CCPM_StoreEmployee__c>();
            //lstStoreEmployee = CCPM_storeEmployeeHandler.deleteLeadSharingRecordsForInActiveStoreEmployee(Trigger.new, Trigger.oldMap);
            
        }
    }
    
    if(trigger.isAfter) {
        
        if(trigger.isInsert) {
            
            // Provide Lead Sharing to the newly added Store Employee who is an AM
            CCPM_storeEmployeeHandler.provideLeadShareAccessOnInsert(trigger.new);
        }

        if(trigger.isUpdate) {
            //Provide or Delete Leadshares on update of Store Employee record
            CCPM_storeEmployeeHandler.decideLeadShareAccessForEmployee(Trigger.new, Trigger.oldMap);
        }        
    }

}
*/


trigger CCPM_storeEmployee on CCPM_storeEmployee__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    CCPM_TriggerDispatcher.Run(new CCPM_storeEmployeeTriggerHandler());
    
}