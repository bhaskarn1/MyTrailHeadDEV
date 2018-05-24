/**
*@name          CCPM_clickToCallController 
*@author        Ritwik Koneru (Deloitte)
*@date          02/08/2018
*@description   This is a controller or class
*@Class         CCPM_clickToCallController
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Ritwik Koneru (Deloitte)    	04/03/2018   	Initial Implementation.
*/

public class CCPM_clickToCallController {
	
    public static String strCallNotes = 
        Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Notes').getRecordTypeId();
    
    /**
	@author       Ritwik Koneru (Deloitte)
	@description  This is initial method called when the component loads
	@param        respWrapper
	@return       getResponse
	*/ 
    @AuraEnabled
    public static respWrapper getResponse (String leadId, Boolean isIpad) {
        
        Boolean boolIsCallInProgress = false;
        respWrapper objWrap = new respWrapper();
        integer intCallDetSize = 0;
        
        lead objLead = [SELECT id,ccpm_mobileNumber__c,status,CCPM_leadSubStatus__c,CCPM_Account__r.CCPM_hasOptedOutOfCall__c,
                        		CCPM_account__c, (select id,CCPM_callStatus__c from Call_Details__r)
                          FROM Lead
                         WHERE id =: leadId];
        
        if (CCPM_Collection.isNotNullEmpty(objLead.call_details__r)) {
            intCallDetSize = objlead.call_details__r.size();
            for (CCPM_callDetails__c objCd : objLead.call_details__r) {
                if (objCd.CCPM_callStatus__c == 'Call In-Progress') {
                    boolIsCallInProgress = true;
                    break;
                }
            }
        }

        if (isIpad) {
           
            objWrap.statusCode = label.ccpm_statusCode;
            objWrap.errorMessage = 'This feature is available on the Desktop version of Salesforce at this time.';
        } else if (String.isNotBlank(objLead.CCPM_account__c ) && objLead.CCPM_Account__r.CCPM_hasOptedOutOfCall__c){
            objWrap.statusCode = label.ccpm_statusCode;
            objWrap.errorMessage = label.CCPM_optOutError;
            
        } else if (boolIsCallInProgress) {
            objWrap.statusCode = label.ccpm_statusCode;
            objWrap.errorMessage = label.CCPM_callInProgError;
            
        } else if (!CCPM_utility.lstCallNowLeadStatus.contains(objLead.Status) || 
                  !CCPM_utility.lstCallNowLeadSubStatus.contains(objlead.CCPM_leadSubStatus__c)){
                      system.debug('=== '+objLead.CCPM_leadSubStatus__c+' = '+CCPM_utility.lstCallNowLeadSubStatus);
    		objWrap.statusCode = label.ccpm_statusCode;
            objWrap.errorMessage = Label.CCPM_statusError;		
           
        } else {
            User objUser = [SELECT id,mobilephone,profile.Name
                            FROM user 
                            WHERE id=: userinfo.getuserid()];
            system.debug('==== profile'+objUser.profile.name);
            if(String.isBlank(objUser.mobilePhone)) {
                objWrap.statusCode = label.ccpm_statusCode;
                objWrap.errorMessage = label.CCPM_mobilePhoneError;
            } else if(!CCPM_Utility.lstCallNowProfiles.contains(objUSer.profile.Name)){
                objWrap.statusCode = Label.CCPM_statusCode;
                objWrap.errorMessage = Label.CCPM_callNowProfileError;
            } else {
                
                String uniqueId = calculateUniqueNum(leadId, intCallDetSize);
                Boolean isSandbx = ccpm_utility.isRunningInASandbox;
                String strChannel = isSandbx?Label.CCPM_sandboxChannel:Label.CCPM_prodChannel;
                
                CCPM_clickToCallService.CtiRetailOutboundServicePort objClickToCall = 
                    new CCPM_clickToCallService.CtiRetailOutboundServicePort();
          system.debug(+objUser.mobilePhone.replaceAll('\\D',''));
                try {
                    CCPM_clickToCallService.optInSFDCServiceResponse objResponse = 
                        objClickToCall.makeCtiCall(userinfo.getUserId(), uniqueId,objUser.mobilePhone.replaceAll('\\D','') ,objLead.ccpm_mobileNumber__c, strChannel);
                    
                    system.debug ('Respon==== '+objResponse);
                    if (objResponse.serviceBody != null) {
                        objWrap.statusCode = objResponse.serviceBody.errorCode;
                    }
                    
                    if (objWrap.statusCode != '00000') {
                        objWrap.errorMessage = objResponse.serviceBody.errorMessage;
                        map<String,String> errMap = CCPM_utility.ivrErrMap();
                        for (String str : errMap.keySet()) {
                            if (objWrap.statusCode == str) {
                                objwrap.errorMessage = errMap.get(str);
                            }
                        }
                    } else {
                        CCPM_callDetails__c objCallDet = new CCPM_callDetails__c();
                        objCallDet.CCPM_callStatus__c = Label.CCPM_callDetStatus;
                        objCallDet.CCPM_IVRID__c = uniqueId;
                        objCallDet.CCPM_callStartTime__c = system.now();
                        objCallDet.CCPM_lead__c = leadId;
                        try {
                            insert objCallDet;
                            Task objTask = new Task();
                            objTask.WhoId = leadId;
                            objTask.CCPM_notes__c = Label.CCPM_taskNotes;
                            objTask.status = Label.CCPM_taskStatus;
                            objTask.Subject = Label.CCPM_taskSubject;
                            objTask.activityDate = system.today().adddays(1);
                            objTask.recordTypeId = strCallNotes;
                            objTask.CCPM_callDetails__c = objCallDet.id;
                            
                            insert objTask;
                            
                            objWrap.objTask = objTask;
                            objwrap.statusValues = CCPM_utility.lstTaskStatValues;

                        } catch (DMLException e) {
                            objWrap.statusCode = label.ccpm_statusCode;
                            objWrap.errorMessage = e.getMessage();
                        }
                    }
                } catch (system.calloutexception e){
                    objWrap.statusCode = label.ccpm_statusCode;
                    objWrap.errorMessage = e.getMessage();
                }
            }
        }
        
        system.debug('===='+objWrap);
        return objWrap;
    }
    
    /**
	@author       Ritwik Koneru (Deloitte)
	@description  Method to calculate unique number
	@param        String
	@return       calculateUniqueNum
	*/ 
    
    public static String calculateUniqueNum(String leadId, integer callDetSize) {
        
        callDetSize += 1;
        String uniqueNum = leadId+String.valueof(callDetSize);
        return uniqueNum;
    }
    
    /**
	@author       Ritwik Koneru (Deloitte)
	@description  Method to update Task Record
	@param        Task
	@return       updateTaskRecord
	*/
    
    @Auraenabled
    public static void updateTaskRecord (Task objTask) {
    	try {
            update objTask;
        } catch (dmlexception e) {
            throw new auraHandledException ('Error while saving changes. Please try again.');
        }
    }
    
    /**
	@author       Ritwik Koneru (Deloitte)
	@description  Wrapper class to send initital response
	@param        String
	*/
    
    public class respWrapper{
        @Auraenabled public Task objTask{get;set;}
        @Auraenabled public String statusCode{get;set;}
        @Auraenabled public String errorMessage{get;set;}
        @Auraenabled public list<String> statusValues{get;set;}
    }
}