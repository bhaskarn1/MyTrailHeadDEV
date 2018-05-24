/**
*@name          CCPM_strEmpTriggerHandlerHelper 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          11/08/2017
*@description   This is a helper for CCPM_storeEmployeeTriggerHandler
*@Class         CCPM_strEmpTriggerHandlerHelper
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    11/08/2017   Initial Implementation.
*/
public with sharing class CCPM_strEmpTriggerHandlerHelper 
{
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  flags the record if the Rep Role is changed
	@param        CCPM_storeEmployee__c, CCPM_storeEmployee__c
	@return       void
	*/
    public static void flagRecForBatchProcess(CCPM_storeEmployee__c objNew, CCPM_storeEmployee__c ObjOld){
        system.debug('the new role is'+Objnew.CCPM_storeSource__c);
        system.debug('the soure is'+objOld.CCPM_storeSource__c);
    	if((objNew.CCPM_role__c != ObjOld.CCPM_role__c  && Objnew.CCPM_storeSource__c!=Label.CCPM_telesalesChannelName) || (objNew.CCPM_IsActive__c != ObjOld.CCPM_IsActive__c)) 
         {
    				objNew.CCPM_previousRole__c =  ObjOld.CCPM_role__c;
    				objNew.CCPM_previousactive__c =  ObjOld.CCPM_IsActive__c;
    				objNew.CCPM_IsUpdateFlag__c = true;
    	}    	
    }
}