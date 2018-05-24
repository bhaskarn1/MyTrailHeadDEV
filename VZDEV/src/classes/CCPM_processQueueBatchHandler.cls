/**
*@name          CCPM_processQueueBatchHandler
*@author        Sriraman Sridharan (Deloitte)
*@date          07/13/2017
@description    Handler class to remove the sms schedules
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date       		Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        07/14/2017    		Original Version
Paras Shah (Deloitte)				09/26/2017			Made changes to accomodate generic logic to process 
														multiple types of request through this batch job - 	DISTSCE-1599							
*/

public class CCPM_processQueueBatchHandler {
    
    /**
*@author        Paras Shah (Deloitte)
*@description   This method processes Queued records and passes the required records to their respective methods
*@Params		List<CCPM_processingQueue__c>
*@return        Void(None)
*/ 
    
    Public static void processQueuedRecords(List<CCPM_processingQueue__c> lstQueuedRecords){
        
        List<CCPM_processingQueue__c> lstSchedulesToBeRemoved 		= new List<CCPM_processingQueue__c>();
        List<CCPM_processingQueue__c> lstConvertedLeadsCartTypes 	= new List<CCPM_processingQueue__c>();
        
        for (CCPM_processingQueue__c objProcessQueue: lstQueuedRecords) {
            if(objProcessQueue.CCPM_queueType__c == CCPM_staticConstants.strCartTypeProcessingforConvertedLeads ) {
                lstConvertedLeadsCartTypes.add(objProcessQueue);
            } else if (objProcessQueue.CCPM_queueType__c == CCPM_staticConstants.strSMSSchedulesToBeRemoved ) {
                lstSchedulesToBeRemoved.add(objProcessQueue);
            }
        }
        
        if(lstSchedulesToBeRemoved!=null && lstSchedulesToBeRemoved.isEmpty()==false) {
            CCPM_RemoveSmsScehdules(lstSchedulesToBeRemoved);
        }
        
        if(lstConvertedLeadsCartTypes!=null && lstConvertedLeadsCartTypes.isEmpty()==false) {
            processConvertedLeadsCartTypes(lstConvertedLeadsCartTypes);
        }
    }
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method removes the schedules
*@Params		List<CCPM_processingQueue__c>
*@return        Void(None)
*/ 
    
    //Public static void CCPM_RemoveSmsScehdules(List<CCPM_SMSSchedulesToBeRemoved__c> lstSchedulesToBeRemoved){
    Public static void CCPM_RemoveSmsScehdules(List<CCPM_processingQueue__c> lstSchedulesToBeRemoved){
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
                    CCPM_LogMessageUtility.logMessage(e,'CCPM_processQueueBatchHandler','RemoveSmsScehdules','Exception thrown while updating list of sms message schedules',ccpm_staticConstants.boolSMSSent);
                }  
            }
            else{
                CCPM_logMessageUtility.logMessage(CCPM_logMessageUtility.LOG_LogLevel.Debug, 'CCPM_processQueueBatchHandler','RemoveSmsScehdules', 'No Schedules To Remove' , ccpm_staticConstants.boolSMSSent);
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
                CCPM_LogMessageUtility.logMessage(e,'CCPM_processQueueBatchHandler','RemoveSmsScehdules','Exception thrown while updating status for the list of records from the custom object',ccpm_staticConstants.boolSMSSent);
            }
        }
    }
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method removes the schedules
*@Params		List<CCPM_processingQueue__c>
*@return        Void(None)
*/ 
    
    //Public static List<CCPM_SMSMessage__c> getSMSScheduleList(List<CCPM_SMSSchedulesToBeRemoved__c> lstSchedulesToBeRemoved){
    Public static List<CCPM_SMSMessage__c> getSMSScheduleList(List<CCPM_processingQueue__c> lstSchedulesToBeRemoved){
        Set<String> setAccountuniqueId = new Set<String>();
        Set<String> setLeadId = new Set<String>();
        List<lead> lstLeadsForRemovingScedules = new List<lead>();
        List<CCPM_SMSMessage__c> lstSmsSchedulesToBeUpdated = new List<CCPM_SMSMessage__c>();
        //map<String,List<CCPM_SMSMessage__c>> mpAccAndSmsSchedules = new map<String,List<CCPM_SMSMessage__c>>();
        system.debug('@@@lstSchedulesToBeRemoved' + lstSchedulesToBeRemoved);
        for(CCPM_processingQueue__c objSchedulesToRemove : lstSchedulesToBeRemoved){
            if(objSchedulesToRemove.CCPM_accountUniqueID__c != null){
                setAccountuniqueId.add(objSchedulesToRemove.CCPM_accountUniqueID__c);
            }
        }
        system.debug('@@@setAccountuniqueId' + setAccountuniqueId);
        if(setAccountuniqueId.size()>0 && setAccountuniqueId!= null){
            try{
                lstLeadsForRemovingScedules = [Select id,Status,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c from lead where CCPM_accountUniqueID__c IN :setAccountuniqueId AND (Status =: CCPM_staticConstants.strLeadStatusNew OR Status =: CCPM_staticConstants.strLeadStatusEligible OR Status =: CCPM_staticConstants.strLeadStatusContacted)];
                system.debug('@@@lstLeadsForRemovingScedules' + lstLeadsForRemovingScedules);
                //CCPM_accountUniqueID__c IN :setAccountuniqueId AND 
            }        
            catch(Exception e)
            {
                //system.debug('@@@e'+ e);
                CCPM_LogMessageUtility.logMessage(e,'CCPM_processQueueBatchHandler','RemoveSmsScehdules','Exception thrown while querying for leads which belong to a set of accounts',ccpm_staticConstants.boolSMSSent);
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
                    CCPM_LogMessageUtility.logMessage(e,'CCPM_processQueueBatchHandler','RemoveSmsScehdules','Exception thrown while querying for leads which belong to a set of accounts',ccpm_staticConstants.boolSMSSent);
                }   
            }  
        }
        return lstSmsSchedulesToBeUpdated;
    }
  
    /**
*@author        Paras Shah (Deloitte)
*@description   This method is used to process Converted Cart Types and create new records in Cart Type object
*@Params		List<CCPM_processingQueue__c>
*@return        Void(None)
*/ 
    
    Public static void processConvertedLeadsCartTypes(List<CCPM_processingQueue__c> lstConvertedLeadsCartTypes){
        //Check if the parameter is not null and process it
        if(lstConvertedLeadsCartTypes != null && lstConvertedLeadsCartTypes.size()>0){ 
            
            // List to hold the Cart Type records
            List<CCPM_CartType__c> lstCartType = new List<CCPM_CartType__c>();
            Set<String> setCartType = new set<String>();

            CCPM_CartType__c objCartType;
            
            //Process through each record in the Queue and create individual Cart type records
            for(CCPM_processingQueue__c objProcessQueue: lstConvertedLeadsCartTypes) {
                
                // String array to hold Cart types separated by Comma
                String[] strCartTypes;
                
                // Split the Cart types based on Comma                 
                if (objProcessQueue.CCPM_cartType__c != null) {
                    strCartTypes=objProcessQueue.CCPM_cartType__c.split(','); 
                }
                
                // Create records for each Cart type
                for(Integer i=0;i<strCartTypes.size();i++)
                {
                    objCartType = new CCPM_CartType__c();
                    
                    objCartType.Lead__c = objProcessQueue.CCPM_LeadID__c;
                    objCartType.CCPM_CartType__c = strCartTypes[i];
                    
                    system.debug('!!!CCPM_CartType__c'+strCartTypes[i]);
                    
                    //Cart type Mapping
                    
                    if (objCartType.CCPM_CartType__c == CCPM_staticConstants.strCartTypeAAL ||
                        objCartType.CCPM_CartType__c == CCPM_staticConstants.strCartTypeEUP ||
                        objCartType.CCPM_CartType__c == CCPM_staticConstants.strCartTypeACC ||
                        objCartType.CCPM_CartType__c == CCPM_staticConstants.strCartTypeNEW) {
                            objCartType.CCPM_CartTypeMapping__c = objCartType.CCPM_CartType__c;
                        }else {
                            objCartType.CCPM_CartTypeMapping__c = CCPM_staticConstants.strCartTypeOTHER;
                        }
                        lstCartType.add(objCartType);
                    	system.debug('!!!lstCartType'+lstCartType);
                }
            }
            
            try
            { 
                if(lstCartType!=null && lstCartType.isEmpty()==false)
                {
                    upsert lstCartType;
                
                } 
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_processQueueBatchHandler','processConvertedLeadsCartTypes','Exception thrown while creating records for Converted Cart Types',true);
            }
            
            // Mark the Queue record as completed
            
            List<CCPM_processingQueue__c> lstMarkCartTypeProcessed = new List<CCPM_processingQueue__c>();
            
            for(CCPM_processingQueue__c objProcessCartType: lstConvertedLeadsCartTypes) {
                if(objProcessCartType.CCPM_Status__c == CCPM_staticConstants.StatusNew){
                    objProcessCartType.CCPM_Status__c = CCPM_staticConstants.StatusCompleted;
                }
                lstMarkCartTypeProcessed.add(objProcessCartType);
            }
            /*
                for(Integer i=0; i<lstConvertedLeadsCartTypes.size();i++){
                if(lstConvertedLeadsCartTypes[i].CCPM_Status__c == CCPM_staticConstants.StatusNew){
                lstConvertedLeadsCartTypes[i].CCPM_Status__c = CCPM_staticConstants.StatusCompleted;
                }
                }
            */
            try{
                Update lstMarkCartTypeProcessed;
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_processQueueBatchHandler','processConvertedLeadsCartTypes','Exception thrown while updating status for the list of records from the custom object',ccpm_staticConstants.boolSMSSent);
            }
            
        }
    }
}