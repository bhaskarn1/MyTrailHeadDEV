/**
*@name          RemoveSmsScheduleBatch
*@author        Sriraman Sridharan (Deloitte)
*@date          07/13/2017
@description    Handler class to remove the sms schedules
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        07/14/2017                       Original Version
*/

public class CCPM_RemoveSmsScheduleBatchHandler {
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method removes the schedules
*@Params		List<CCPM_SMSSchedulesToBeRemoved__c>
*@return        Void(None)
*/ 
    
    Public static void CCPM_RemoveSmsScehdules(List<CCPM_SMSSchedulesToBeRemoved__c> lstSchedulesToBeRemoved){
        //Check if the parameter is not null and process it
        if(lstSchedulesToBeRemoved != null && lstSchedulesToBeRemoved.size()>0){
            
            //get the list of sms schedules to be removed
            List<CCPM_SMSMessage__c> lstSmsSchedulesToBeUpdated = getSMSScheduleList(lstSchedulesToBeRemoved);
            
            if(lstSmsSchedulesToBeUpdated != null && lstSmsSchedulesToBeUpdated.size()>0){
                for(CCPM_SMSMessage__c objSmsSchedule : lstSmsSchedulesToBeUpdated){
                    if(objSmsSchedule.CCPM_MessageStatus__c == CCPM_staticConstants.strMessageStatusQueued){
                        objSmsSchedule.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                    }
                }
                //Update the sms message records
                try{
                    Update lstSmsSchedulesToBeUpdated;
                }
                catch(Exception e){
                    CCPM_LogMessageUtility.logMessage(e,'RemoveSmsScheduleBatchHandler','RemoveSmsScehdules','Exception thrown while updating list of sms message schedules',ccpm_staticConstants.boolSMSSent);
                }  
            }
            else{
                    CCPM_logMessageUtility.logMessage(CCPM_logMessageUtility.LOG_LogLevel.Debug, 'RemoveSmsScheduleBatchHandler','RemoveSmsScehdules', 'No Schedules To Remove' , ccpm_staticConstants.boolSMSSent);
            }
            //Update the status for custom object
            for(Integer i=0; i<lstSchedulesToBeRemoved.size();i++){
                if(lstSchedulesToBeRemoved[i].CCPM_Status__c == CCPM_staticConstants.StatusNew){
                    lstSchedulesToBeRemoved[i].CCPM_Status__c = CCPM_staticConstants.StatusCompleted;
                }
                else{
                    lstSchedulesToBeRemoved[i].CCPM_Status__c = CCPM_staticConstants.StatusRejected;
                }
            }
            try{
                Update lstSchedulesToBeRemoved;
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'RemoveSmsScheduleBatchHandler','RemoveSmsScehdules','Exception thrown while updating status for the list of records from the custom object',ccpm_staticConstants.boolSMSSent);
            }
        }
    }
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method removes the schedules
*@Params		List<CCPM_SMSSchedulesToBeRemoved__c>
*@return        Void(None)
*/ 
    
    Public static List<CCPM_SMSMessage__c> getSMSScheduleList(List<CCPM_SMSSchedulesToBeRemoved__c> lstSchedulesToBeRemoved){
        Set<String> setAccountuniqueId = new Set<String>();
        Set<String> setLeadId = new Set<String>();
        List<lead> lstLeadsForRemovingScedules = new List<lead>();
        List<CCPM_SMSMessage__c> lstSmsSchedulesToBeUpdated = new List<CCPM_SMSMessage__c>();
        //map<String,List<CCPM_SMSMessage__c>> mpAccAndSmsSchedules = new map<String,List<CCPM_SMSMessage__c>>();
        for(CCPM_SMSSchedulesToBeRemoved__c objSchedulesToRemove : lstSchedulesToBeRemoved){
            if(objSchedulesToRemove.CCPM_accountUniqueID__c != null){
                setAccountuniqueId.add(objSchedulesToRemove.CCPM_accountUniqueID__c);
            }
        }
        //system.debug('@@@setAccountuniqueId' + setAccountuniqueId);
        if(setAccountuniqueId.size()>0 && setAccountuniqueId!= null){
            try{
                lstLeadsForRemovingScedules = [Select id,Status,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c from lead where CCPM_accountUniqueID__c IN :setAccountuniqueId AND (Status =: CCPM_staticConstants.strLeadStatusNew OR Status =: CCPM_staticConstants.strLeadStatusEligible OR Status =: CCPM_staticConstants.strLeadStatusContacted)];
            	//system.debug('@@@lstLeadsForRemovingScedules' + lstLeadsForRemovingScedules);
                //CCPM_accountUniqueID__c IN :setAccountuniqueId AND 
            }        
            catch(Exception e)
            {
                //system.debug('@@@e'+ e);
                CCPM_LogMessageUtility.logMessage(e,'RemoveSmsScheduleBatchHandler','RemoveSmsScehdules','Exception thrown while querying for leads which belong to a set of accounts',ccpm_staticConstants.boolSMSSent);
            }
            if(lstLeadsForRemovingScedules!= null && lstLeadsForRemovingScedules.size()>0){
                for(lead objleadsForID : lstLeadsForRemovingScedules){
                    if(objleadsForID.id != null){
                        setLeadId.add(objleadsForID.id);
                    }
                }
                try{
                    if(setLeadId != null && !setLeadId.isEmpty()){
                        lstSmsSchedulesToBeUpdated = [Select Id,CCPM_toPhoneNumber__c,CCPM_ScheduleDateTime__c,CCPM_messageType__c,CCPM_MessageStatus__c from CCPM_SMSMessage__c where CCPM_leadRecord__c IN :setLeadId AND CCPM_MessageStatus__c =:CCPM_staticConstants.strMessageStatusQueued];
                        //system.debug('@@@lstSmsSchedulesToBeUpdated' + lstSmsSchedulesToBeUpdated);
                    }
                }        
                catch(Exception e)
                {
                    CCPM_LogMessageUtility.logMessage(e,'RemoveSmsScheduleBatchHandler','RemoveSmsScehdules','Exception thrown while querying for leads which belong to a set of accounts',ccpm_staticConstants.boolSMSSent);
                }   
            }  
        }
        return lstSmsSchedulesToBeUpdated;
    }
}