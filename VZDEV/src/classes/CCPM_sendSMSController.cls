/**
*@name          CCPM_sendSMSController 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          02/08/2018
*@description   This is a controller or class
*@Class         CCPM_sendSMSController
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    02/08/2018   Initial Implementation.
*/
public with sharing class CCPM_sendSMSController  {
    public static list<String> lstRestrictedProfilesForSendSMS = CCPM_utility.getListFromString(Label.CCPM_restrictedProfilesForSendSMS,',');
    public static list<String> lstProfilesAllowedForFreeFormSMS = CCPM_utility.getListFromString(Label.CCPM_allowedProfilesForFreeFormSMS,',');            
    public static Map<String, String> mapProfileIDName = CCPM_utility.getProfileIdNameMap();     
    
    /**
    @author       Bharath Ammanamanchi (Deloitte)
    @description  This is initial method called when the component loads
    @param        String
    @return       SendSMSWrapper
    */ 
    @AuraEnabled
    public static SendSMSWrapper getLeadAndSendSMSWrapperInfo(String strLeadId){
        SendSMSWrapper objSendSMSWrapper = new SendSMSWrapper('');
        
        if(String.isNotBlank(strLeadId)){
            Lead objLead = [Select id, store__c,Status, CCPM_leadSubStatus__c, CCPM_qualifiedSubStatusForPreDefinedSMS__c, CCPM_firstPredefinedSMSFlag__c,CCPM_finalPreDefinedSMSFlag__c, 
                            RecordType.Name, CCPM_ownerEcode__c,CCPM_storeEcode__c, CCPM_mobileNumber__c, ownerId  
                            FROM Lead Where id =:strLeadId];
            if(objLead != null){
                objSendSMSWrapper = new SendSMSWrapper(objLead);
            }
        }
        
        return objSendSMSWrapper;
    }
    
    /**
    @author       Bharath Ammanamanchi (Deloitte)
    @description  This is initial method called when the component loads
    @param        String
    @return       SendSMSWrapper
    */ 
    @AuraEnabled
    public static Integer sendPreDefinedSMSToCustomer (Lead objLead,String strMessageLabel, String strSMSMessageBody, List<String> lstFoulWords){
        Integer intResponse = 0;
        List<LOG_LogMessage__c> lstLogMessage = new List<LOG_LogMessage__c>();
        
        if(objLead != null && String.isNotBlank(strSMSMessageBody) && String.isNotBlank(strMessageLabel)){
            String strLivetextPhoneNumber = Label.CCPM_liveTextNumberNonVerizon;
            String strMTN = objLead.CCPM_mobileNumber__c;
            strMTN = strMTN.replaceAll(Label.CCPM_nondigits, '');
            
            Set<String> setProspectRecordTypeNames = new Set<String>{Label.CCPM_leadProspectRT, Label.CCPM_leadProspectCartRT};
            Set<String> setCustomerRecordTypeNames = new Set<String>{Label.CCPM_leadCustomerCartRT};
            if(CCPM_Collection.isNotNullEmpty(setCustomerRecordTypeNames) && setCustomerRecordTypeNames.contains(objLead.RecordType.Name)){
                strLivetextPhoneNumber = Label.CCPM_liveTextPhoneNumber;
            }
            
            String strPromolabel = 'System Generated';
            if(strMessageLabel.toLowerCase().contains('promo')){
                strPromolabel = strMessageLabel.replace('Promo', '');
            }
            else if(strMessageLabel == 'Custom Reply'){
                strPromolabel = strMessageLabel;
                if(CCPM_Collection.isNotNullEmpty(setCustomerRecordTypeNames) && setCustomerRecordTypeNames.contains(objLead.RecordType.Name)){
                    strSMSMessageBody = strSMSMessageBody+'(FreeVzMsg)';
                }
                if(CCPM_Collection.isNotNullEmpty(lstFoulWords)){
                    try{
                        createCustomeMessageRecord (objLead,strSMSMessageBody,'Blocked', lstFoulWords,strMessageLabel);
                    }
                    catch(Exception e){
                        lstLogMessage.add(CCPM_utility.logMessage(e, 'Error', 'CCPM_sendSMSController', 'sendPreDefinedSMSToCustomer', 'Exception thrown while Creating Custom Message Object for Blocked', ''));
                        throw new AuraHandledException('Exception thrown while sending SMS. Please contact Adminstrator.');
                    }
                    
                    return intResponse;
                }
            }
            
            System.debug('*****objLead******'+objLead);
            System.debug('*****strSMSMessageBody******'+strSMSMessageBody);
            
            
            String strSMSMessageBodyForURL = strSMSMessageBody.replace(' ', '+');
            HTTPResponse httpResponseFromHeywire = new httpResponse();
            try{
                if(test.isRunningTest()){
                    httpResponseFromHeywire.setStatusCode(204);
                } else {
                    httpResponseFromHeywire = CCPM_HttpCallOutUtility.createHeyWireHttpRequest(strSMSMessageBodyForURL,strMTN,strLivetextPhoneNumber);
                }
                if(httpResponseFromHeywire.getStatusCode() == Integer.valueOf(Label.CCPM_successResponseCode)){
                    intResponse = httpResponseFromHeywire.getStatusCode();
                }
                else{
                    try{
                        createCustomeMessageRecord (objLead,strSMSMessageBody,'Send Failure', lstFoulWords,strMessageLabel);
                    }
                    catch(Exception e){
                        throw new AuraHandledException('Exception thrown while sending SMS. Please contact Adminstrator.');
                    }
                    lstLogMessage.add(CCPM_utility.logMessage('Error', 'CCPM_sendSMSController', 'sendPreDefinedSMSToCustomer', 'Problem while Sending SMS. Response Code from Haywire : '+httpResponseFromHeywire.getStatusCode(), ''));
                    throw new AuraHandledException('Error while sending SMS. Please contact Adminstrator.');
                }
            }
            catch(Exception e){
                lstLogMessage.add(CCPM_utility.logMessage(e, 'Error', 'CCPM_sendSMSController', 'sendPreDefinedSMSToCustomer', 'Exception thrown while Sending SMS', ''));
                throw new AuraHandledException('Exception thrown while Sending SMS. Please contact Adminstrator.');
            }
            
            if(intResponse == Integer.valueOf(Label.CCPM_successResponseCode)){
                Lead objLeadRecord = new Lead(Id= objLead.id, Status = objLead.Status, CCPM_leadSubStatus__c = objLead.ccpm_leadSubStatus__c, //CCPM_Last_Interaction_Before_Closed__c = System.now(),
                                              CCPM_lastInteraction__c = System.now(),CCPM_lastPromoSent__c=strPromolabel);
                if(objLead.CCPM_firstPredefinedSMSFlag__c == false){
                    objLeadRecord.CCPM_promoFirstSent__c=strPromolabel;
                    objLeadRecord.CCPM_promoFirstSentDate_Time__c=system.now();
                    objLeadRecord.CCPM_firstPredefinedSMSFlag__c = true;
                }
                else if(objLead.CCPM_firstPredefinedSMSFlag__c == true && objLead.CCPM_finalPreDefinedSMSFlag__c == false){
                    objLeadRecord.CCPM_promoSecondSent__c=strPromolabel;
                    objLeadRecord.CCPM_promoSecondSentDate_Time__c=system.now();
                    objLeadRecord.CCPM_finalPreDefinedSMSFlag__c = true; 
                }
                if(objLeadRecord!=null){
                    try{
                        update objLeadRecord;
                    }
                    catch(Exception e){
                        lstLogMessage.add(CCPM_utility.logMessage(e, 'Error', 'CCPM_sendSMSController', 'sendPreDefinedSMSToCustomer', 'Exception thrown updating Lead', ''));
                        throw new AuraHandledException('Exception thrown while sending SMS. Please contact Adminstrator ');
                    }
                }
                Task objTask = CCPM_utility.createTaskRecordFromLead(objLead, strSMSMessageBody, Label.CCPM_messageTypePreDefinedSMS, Label.CCPM_taskInteractionHistoryRTName);
                if(objTask != null){
                    try{
                        insert objTask;
                    }
                    catch(Exception e){
                        lstLogMessage.add(CCPM_utility.logMessage(e, 'Error', 'CCPM_sendSMSController', 'sendPreDefinedSMSToCustomer', 'Exception thrown while Creating Task for Interaction history', ''));
                        throw new AuraHandledException('Exception thrown while sending SMS. Please contact Adminstrator.');
                    }
                }
                try{
                    createCustomeMessageRecord (objLead,strSMSMessageBody,'Sent', lstFoulWords, strMessageLabel); 
                }
                catch(Exception e){
                    throw new AuraHandledException('Exception thrown while sending SMS. Please contact Adminstrator.');
                }
            }
            if(CCPM_Collection.isNotNullEmpty(lstLogMessage)){
                insert lstLogMessage;
            }
        }
        return intResponse;
    } 
    
    public static void createCustomeMessageRecord (Lead objLead,String strSMSMessageBody, String strStatus, List<String> lstFoulWords, String strMessageLabel){
        if(objLead != null && String.isNotBlank(strSMSMessageBody) && String.isNotBlank(strStatus) && 
          (String.isNotBlank(strMessageLabel) && strMessageLabel == 'Custom Reply')){
            CCPM_customMessage__c objCM = 
                        new CCPM_customMessage__c(CCPM_lead__c = objLead.Id, CCPM_messageText__c = strSMSMessageBody, 
                            CCPM_status__c = strStatus, CCPM_store__c = objLead.Store__c);
            if(CCPM_Collection.isNotNullEmpty(lstFoulWords)){
                objCM.CCPM_foulWords__c = String.join(lstFoulWords, ',');
            }
            insert objCM;
        }
    }
    
    /**
    *@author        Bharath Ammanamanchi (Deloitte)
    *@description   Wrapper class to provision a datastructure for the controller
    *@return        None
    */ 
    public class SendSMSWrapper {
        @AuraEnabled public Lead objLead{get;set;}
        @AuraEnabled public Map<String, String> mapSmsMessage{get;set;}
        @AuraEnabled public List<String> lstSubStatusValues{get;set;}
        @AuraEnabled public String strMessage{get;set;}
        @AuraEnabled public Set<String> setRestrictedWords{get;set;}
        Set<String> setProspectRecordTypeNames = new Set<String>{Label.CCPM_leadProspectRT, Label.CCPM_leadProspectCartRT};
        Set<String> setCustomerRecordTypeNames = new Set<String>{Label.CCPM_leadCustomerCartRT,Label.CCPM_AbandonedVisitLead,Label.CCPM_CustomerQuotesRT};
        
        public SendSMSWrapper(String strMsgIn){
            objLead = new Lead();
            mapSmsMessage = new Map<String, String>();
            lstSubStatusValues = new List<String>();
            strMessage = strMsgIn;
            setRestrictedWords = new Set<String>();
        }
        
        public SendSMSWrapper(Lead objLeadIn){
            String strMsg = '';
            Set<String> setRestrictWords = new Set<String>();
            if(objLeadIn != null){
                boolean boolDoNotShowCustomReply = lstProfilesAllowedForFreeFormSMS.contains(mapProfileIDName.get(userinfo.getProfileId())) ? false : true;
                
                if(!boolDoNotShowCustomReply){
                    for(CCPM_dataDictionary__c objDD : [Select CCPM_StringForexclusion__c, id From CCPM_dataDictionary__c Where CCPM_IsActive__c = true]){
                        setRestrictWords.add(objDD.CCPM_StringForexclusion__c);
                    }
                }
                if(lstRestrictedProfilesForSendSMS.contains(mapProfileIDName.get(userinfo.getProfileId()))){
                    strMsg = 'You do not have permission to send SMS.';
                }               
                if(!CCPM_utility.checkField(objLeadIn.Status, Label.CCPM_leadStatusResponded) || !CCPM_utility.checkField(objLeadIn.CCPM_leadSubStatus__c, Label.CCPM_subStatusActionRequired)){
                    strMsg = 'Lead has to be in Responded - Action Required State.';
                }
                if(objLeadIn.CCPM_finalPreDefinedSMSFlag__c){
                    strMsg = '2 SMS Messages have already been sent to the Customer';
                }
                if(strMsg != '') {
                    this(strMsg);
                }
                else{
                    String strEcode = '';
                    if(objLeadIn.CCPM_ownerEcode__c != null)
                        {strEcode = objLeadIn.CCPM_ownerEcode__c;}
                    else if(objLeadIn.CCPM_storeEcode__c != null)
                        {strEcode = objLeadIn.CCPM_storeEcode__c;}
                    System.debug('******strEcode********'+strEcode);
                    Map<String, String> mapPromoNameAndMessage = new Map<String, String>();
                    if(Label.CCPM_none!=null)
                        {mapPromoNameAndMessage.put(Label.CCPM_none, Label.CCPM_none);}
                    if(setProspectRecordTypeNames.contains(objLeadIn.RecordType.Name))
                        {strMsg = 'Prospect';}
                    else if(setCustomerRecordTypeNames.contains(objLeadIn.RecordType.Name))
                        {strMsg = 'Customer';}
                    System.debug('********mapPromoNameAndMessage101********'+mapPromoNameAndMessage);
                    if(CCPM_Collection.isNotNullEmpty(CCPM_utility.lstPreDefinedSMSRecords)){
                        for(CCPM_promoMessage__mdt mdtPM : CCPM_utility.lstPreDefinedSMSRecords){
                            String strSMSMsg = '';
                            if(boolDoNotShowCustomReply && mdtPM.MasterLabel == 'Custom Reply'){
                                setRestrictWords = new Set<String>();
                                continue;
                            }   
                            if(objLeadIn.CCPM_firstPredefinedSMSFlag__c){
                                if(mdtPM.CCPM_finalPreDefinedResponse__c){
                                    strSMSMsg = getSMSPickListDisplayValue(objLeadIn, mdtPM);
                                }
                            }
                            else {
                                if(mdtPM.CCPM_firstPreDefinedResponse__c){
                                    strSMSMsg = getSMSPickListDisplayValue(objLeadIn, mdtPM);
                                }
                            }
                            System.debug('***In here 193**'+strSMSMsg);
                            if(strSMSMsg.contains('[ECODE]')){
                                strSMSMsg = strSMSMsg.replace('[ECODE]',strEcode);
                                System.debug('***In here**'+strSMSMsg);
                            }
                            
                            String strKey = mdtPM.MasterLabel;
                            System.debug('*****strKey********'+strKey);
                            if(mdtPM.CCPM_dispalyOrignialMessage__c){
                                strKey = strSMSMsg;
                            }
                            if(String.isNotBlank(strKey)){
                                mapPromoNameAndMessage.put(strKey, strSMSMsg);  
                            }
                        }
                    }
                    System.debug('***mapPromoNameAndMessage* '+mapPromoNameAndMessage);
                    objLeadIn.Status = Label.CCPM_leadStatusQualified;
                    this.objLead = objLeadIn;
                    this.mapSmsMessage = mapPromoNameAndMessage;
                    this.lstSubStatusValues = getLeadSubStatus();
                    this.strMessage = strMsg;
                    this.setRestrictedWords = setRestrictWords;
                }
            }
        }
        
        public String getSMSPickListDisplayValue(Lead objLead, CCPM_promoMessage__mdt mdtPM){
            String strSMSMsg = '';
            if(setProspectRecordTypeNames.contains(objLead.RecordType.Name)){
                strSMSMsg = CCPM_utility.checkForDynamicContentInMsg('', mdtPM.CCPM_messageContentForProspects__c);    
            }
            else if(setCustomerRecordTypeNames.contains(objLead.RecordType.Name)){
                strSMSMsg = CCPM_utility.checkForDynamicContentInMsg('(FreeVzMsg)', mdtPM.CCPM_MessageContentForLeads__c);
            }   
            return strSMSMsg;
        }
        
        public List<String> getLeadSubStatus(){
            List<String> lstOptions = new List<String>{Label.CCPM_none};
            Schema.DescribeFieldResult getLeadQualifiedSubStatus = lead.CCPM_qualifiedSubStatusForPreDefinedSMS__c.getDescribe();
            List<Schema.PicklistEntry> lstPicklistValuesLeadSubStatus = getLeadQualifiedSubStatus.getPicklistValues();
            for (Schema.PicklistEntry strSubStatus: lstPicklistValuesLeadSubStatus) {
                lstOptions.add(strSubStatus.getLabel());
            }
            return lstOptions;
        }
    }
    
}