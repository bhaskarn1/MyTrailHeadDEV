/**
*@name          CCPM_leadsAwaitingChildApexController
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          12/07/2017
*@description   For "Leads Awaiting Response Child" Component in UI
Modification    Log:
------------------------------------------------------------------------------------
Developer                                     Date               Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)             12/11/2017         Original Version       
Paras Shah (Deloitte)                        01/09/2017         Added 'with sharing' as part of Spring '18 release changes
*/

public with sharing class CCPM_leadsAwaitingChildApexController {       
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method makes a call out to HeyWire
*@return        Void(None)
*/
    @AuraEnabled
    public static integer makeCalloutHeywire(string strDeveloperName,Lead objLead)
    {   
        String SMSMessageContent;
        HttpResponse response;
        String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
        String strLeadCustomerAbandonedVisit = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerAbandonedVisitlead).getRecordTypeId();
        String strLeadCustomerQuoteRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerQuotesRT).getRecordTypeId(); 
        Set<String> setCustomerRecordTypeids = new Set<String>{strLeadCustomerCartRT,strLeadCustomerAbandonedVisit,strLeadCustomerQuoteRT};
            
            System.debug('strDeveloperName->'+strDeveloperName);
        System.debug('objLead->'+objLead);
        
        if(objLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId())
        {   
            System.debug('Inside Customer cart');
            if(CCPM_utility.mapMDTProspectSMSBody.containskey(strDeveloperName))
            {
                SMSMessageContent= CCPM_utility.mapMDTProspectSMSBody.get(strDeveloperName);
                System.debug('SMSMessageContent->'+SMSMessageContent);
                if(!String.isBlank(SMSMessageContent))
                {   
                    string SMSMessageContentTemp = SMSMessageContent.replace(ccpm_staticConstants.StrSpace , ccpm_staticConstants.StrPlus);
                    if(objLead.CCPM_ownerEcode__c!=null)
                    {
                        SMSMessageContentTemp=SMSMessageContentTemp.replace('[ECODE]',objLead.CCPM_ownerEcode__c);
                        SMSMessageContent=SMSMessageContent.replace('[ECODE]',objLead.CCPM_ownerEcode__c);
                    }
                    else if( objLead.CCPM_storeEcode__c!=null)
                    {
                        SMSMessageContentTemp=SMSMessageContentTemp.replace('[ECODE]',objLead.CCPM_storeEcode__c);
                        SMSMessageContent=SMSMessageContent.replace('[ECODE]',objLead.CCPM_storeEcode__c);
                    }
                    else
                    {
                        SMSMessageContentTemp=SMSMessageContentTemp.replace('[ECODE]','');
                        SMSMessageContent=SMSMessageContent.replace('[ECODE]','');
                        
                    }
                    response= CCPM_HttpCallOutUtility.createHeyWireHttpRequest(SMSMessageContentTemp, objLead.CCPM_mobileNumber__c, Label.CCPM_liveTextNumberNonVerizon);
                }
            }
            
            
        }
        else if(setCustomerRecordTypeids.contains(objLead.RecordTypeId))
        {   
            System.debug('Inside Customer cart');
            SMSMessageContent= CCPM_utility.mapMDTCustCartSMSBody.get(strDeveloperName);
            if(!String.isBlank(SMSMessageContent))
            {
                string SMSMessageContentTemp = SMSMessageContent.replace(ccpm_staticConstants.StrSpace , ccpm_staticConstants.StrPlus);
                if(objLead.CCPM_ownerEcode__c!=null)
                {
                    SMSMessageContentTemp=SMSMessageContentTemp.replace('[ECODE]',objLead.CCPM_ownerEcode__c);
                    SMSMessageContent=SMSMessageContent.replace('[ECODE]',objLead.CCPM_ownerEcode__c);
                }
                else if( objLead.CCPM_storeEcode__c!=null)
                {
                    SMSMessageContentTemp=SMSMessageContentTemp.replace('[ECODE]',objLead.CCPM_storeEcode__c);
                    SMSMessageContent=SMSMessageContent.replace('[ECODE]',objLead.CCPM_storeEcode__c);
                }
                else
                {
                    SMSMessageContentTemp=SMSMessageContentTemp.replace('[ECODE]','');
                    SMSMessageContent=SMSMessageContent.replace('[ECODE]','');
                    
                }
                response= CCPM_HttpCallOutUtility.createHeyWireHttpRequest(SMSMessageContentTemp, objLead.CCPM_mobileNumber__c, Label.CCPM_liveTextPhoneNumber);
            }
        }
        if(response != null && response.getStatusCode() == CCPM_staticConstants.intSuccessResponseCode)
        {   
            createInteractionTouchPoint(SMSMessageContent,CCPM_staticConstants.strMessageTypePreDefinedSMS,objLead);
            updateLead(objLead,strDeveloperName);
            return response.getStatusCode();
        }
        
        return null;
    }
    
    
    
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method creates task for successful SMS sent on Lead Record
*@return        Void(None)
*/  
    public static void createInteractionTouchPoint(string SMSBody,string strMsgType,Lead objLead)
    {
        Task objTask            = new task();
        //Setting the Assigned to ID
        objTask.OwnerId         = objLead.ownerId;
        //Setting Task Type
        objTask.Type            = CCPM_staticConstants.strTaskTypeSMS;
        //Setting Communication Direction
        objTask.CCPM_communicationDirection__c=CCPM_staticConstants.strTaskCommunicationOutbound;
        //Setting the Comments field with message received from Customer
        objTask.Description     = SMSBody;
        //Setting the Record type of task to be created and associated fields
        objTask.RecordTypeId    = CCPM_staticConstants.strTaskInteractionHistoryRecordType;
        // set the priority of the task to normal
        objTask.Priority        = CCPM_staticConstants.strTaskPriorityNormal;
        // set the status of task to completed
        objTask.Status          = CCPM_staticConstants.strTaskCompleted;
        // set the subject of the task
        objTask.Subject         = CCPM_staticConstants.strTaskSubjectTextMessageSent;
        //Set the Message Type on Task
        objTask.CCPM_SMSMessageType__c=strMsgType;
        //system.debug('the type is '+objTask.CCPM_SMSMessageType__c);
        // associate the task to lead record
        objTask.whoid           = objLead.id;
        
        try{
            insert objTask;
        }
        catch(DMLException e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadsAwaitingChildApexController','Insert Task Records for SMS sent','Exception thrown during Insert',true);
            
        }        
        
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method updates the Lead with appropiate Flags for pre-defined SMS
*@return        Void(None)
*/  
    public static void updateLead(Lead objLead, String strSmsName) {
        objLead.CCPM_lastInteraction__c=System.now();
        boolean boolIsChangeMade=false;
        String strPromoLabel = '';
        if (String.isNotBlank(strSmsName) && strSmsName.tolowercase().contains('promo')) {
            list<CCPM_promoMessage__mdt> lstPromoMsgMdt = [SELECT id,MasterLabel
                                                           FROM CCPM_promoMessage__mdt
                                                           WHERE DeveloperName =: strSmsName
                                                           LIMIT 1];
            if (lstPromoMsgMdt[0] != null) {
                strPromoLabel = lstPromoMsgMdt[0].masterLabel;
            }
        }
        
        if(!objLead.CCPM_firstPredefinedSMSFlag__c) {
            if (strSmsName.tolowercase().contains('promo')) {
                objLead.CCPM_promoFirstSent__c=strPromolabel;
                objLead.CCPM_promoFirstSentDate_Time__c=system.now();
                objLead.CCPM_lastPromoSent__c = strPromoLabel;
            }
            objLead.CCPM_firstPredefinedSMSFlag__c=true; 
            boolIsChangeMade=true;
        } else if(!objLead.CCPM_finalPreDefinedSMSFlag__c) {
            if (strSmsName.tolowercase().contains('promo')) {
                objLead.CCPM_promoSecondSent__c=strPromolabel;
                objLead.CCPM_promoSecondSentDate_Time__c=system.now();
                objLead.CCPM_lastPromoSent__c = strPromoLabel;
            }
            objLead.CCPM_finalPreDefinedSMSFlag__c=true;
            boolIsChangeMade=true;
        }
        try{
            if(boolIsChangeMade) {
                update objLead;
            }
        }
        catch(DMLException e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadsAwaitingChildApexController','Error received while trying to update Lead with appropriate pre-defined flags','Exception thrown during Update',true);
        }                
    }
    
    /**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This Method checks if the current user is allowed to send SMS.
*@return        Boolean
*/  
    @AuraEnabled
    public static Boolean profileRestrictedfromSendingSMS() {
        list<String> lstRestrictedProfilesForSendSMS = CCPM_utility.getListFromString(Label.CCPM_restrictedProfilesForSendSMS,',');
        Map<String, String> mapProfileIDName = CCPM_utility.getProfileIdNameMap(); 
        
        Boolean isProfileRestricted = lstRestrictedProfilesForSendSMS.contains(mapProfileIDName.get(userinfo.getProfileId())) ? true : false;
        return isProfileRestricted;
    }
}