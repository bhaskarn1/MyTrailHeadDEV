/**
*@name          CCPM_SMSMessageTriggerHandler
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          06/14/2017
@description    US-500, US-498:SMS Message Trigger to update Lead fields and create tasks for associated Leads
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               				Date                     Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)      06/14/2017              Original Version
*/
public class CCPM_SMSMessageTriggerHandler {
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   Create Part 2 SMS messages with status sent
@param         list of CCPM_SMSMessage__c
@return        Void(None)
*/ 
    public static void InsertSMSMessageRecordsforPart2BeforeUpdate(List<CCPM_SMSMessage__c> lstNewSMSMessages)
    {	
        try{
            System.debug('# List lstNewSMSMessagesPart2-> ' + lstNewSMSMessages);
            insert lstNewSMSMessages;
            System.debug('# Insert Task DML Operation-> ' + lstNewSMSMessages); 
        }
        catch(DMLException e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_SMSMessageTriggerHandler','Insert Part 2 SMS sent','Exception thrown during Insert',true);
        } 
        
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   Update SMS body for part1 and create Part2 in salesforce
@param         list of new CCPM_SMSMessage__c, Map of Old CCPM_SMSMessage__c
@return        Void(None)
*/  
    public static void UpdateSMSMessageRecordsforPart1BeforeUpdate(List<CCPM_SMSMessage__c> lstNewSMSMessages,map<id,CCPM_SMSMessage__c> mapOldSMSMessages)
    {	
        list<CCPM_SMSMessage__c> lstSMSMessagePart2 = new list<CCPM_SMSMessage__c>(); 
        for(CCPM_SMSMessage__c SMS : lstNewSMSMessages)
        {
            if(mapOldSMSMessages.get(SMS.Id).CCPM_MessageStatus__c!=SMS.CCPM_MessageStatus__c && SMS.CCPM_MessageStatus__c==CCPM_staticConstants.strMessageStatusSent )
            {
                if(SMS.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeInitialSMSPart1)
                {
                    lstSMSMessagePart2.addAll(generateSecondSMSPart(SMS,CCPM_staticConstants.strMessageTypeInitialSMSPart2));
                }
                else if(SMS.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart1)
                {
                    lstSMSMessagePart2.addAll(generateSecondSMSPart(SMS,CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart2));
                    
                }
                else if(SMS.CCPM_messageType__c== CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1)
                {
                    lstSMSMessagePart2.addAll(generateSecondSMSPart(SMS,CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2));
                }
                else if(SMS.CCPM_messageType__c== Label.CCPM_customerQuoteSMSPart1)
                {
                    lstSMSMessagePart2.addAll(generateSecondSMSPart(SMS,Label.CCPM_customerQuoteSMSPart2)); 
                }
               else if(SMS.CCPM_messageType__c== Label.CCPM_abandonedVisitInitialSMS)
                {
                    lstSMSMessagePart2.addAll(generateSecondSMSPart(SMS,Label.CCPM_AbandonedVisitInitialSMSPartII)); 
                }
                
            } 
            
        }
        
        if(lstSMSMessagePart2!=null && lstSMSMessagePart2.size()>0)
        {
            InsertSMSMessageRecordsforPart2BeforeUpdate(lstSMSMessagePart2);
        }
    } 
    
   
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   Return Second Part of SMS to be created
@param         CCPM_SMSMessage__c
@return        list of CCPM_SMSMessage__c
*/ 
    public static list<CCPM_SMSMessage__c> generateSecondSMSPart(CCPM_SMSMessage__c objSMS,String strMessageType){
        list<CCPM_SMSMessage__c> lstSMSMessagePart2Temp = new list<CCPM_SMSMessage__c>(); 
        
        list<String> lstSMSBody = objSMS.CCPM_message__c.split('%');
        list<String> lstRequestID = objSMS.CCPM_requestID__c.split('\\^');
        system.debug('lstRequestID->'+lstRequestID);
        objSMS.CCPM_message__c= lstSMSBody[0];
        objSMS.CCPM_requestID__c = lstRequestID[0];
        lstSMSMessagePart2Temp.add(new CCPM_SMSMessage__c(CCPM_communicationDirection__c=objSMS.CCPM_communicationDirection__c,CCPM_leadRecord__c=objSMS.CCPM_leadRecord__c,
                                                      CCPM_LiveTextNumber__c=objSMS.CCPM_LiveTextNumber__c,CCPM_message__c=lstSMSBody[1],CCPM_MessageStatus__c=objSMS.CCPM_MessageStatus__c,CCPM_requestID__c = lstRequestID[1],
                                                      CCPM_responseCode__c=objSMS.CCPM_responseCode__c , CCPM_responseMessage__c = objSMS.CCPM_responseMessage__c, CCPM_messageType__c=strMessageType,
                                                      CCPM_ScheduleDateTime__c=objSMS.CCPM_ScheduleDateTime__c,CCPM_toPhoneNumber__c=objSMS.CCPM_toPhoneNumber__c,CCPM_smssentactualtime__c = objSMS.CCPM_smssentactualtime__c));
        
        return lstSMSMessagePart2Temp;
        
        
    }
    
}