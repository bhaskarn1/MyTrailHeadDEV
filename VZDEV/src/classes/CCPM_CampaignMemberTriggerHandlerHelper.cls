/**
*@name          CCPM_CampaignMemberTriggerHandlerHelper 
*@author        Sriraman Sridharan (Deloitte)
*@date          10/05/2017
*@description   This is a helpper class for CCPM_CampaignMemberTriggerHandler
*@Class         CCPM_CampaignMemberTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Sriraman Sridharan                 10/05/2017   Initial Implementation.
Bharath Ammanamanchi               02/15/207    Code cleanup. 

*/
public class CCPM_CampaignMemberTriggerHandlerHelper {
    public static Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapGetBusinessHours();
    
    
     /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to update the Lead on Campaign Member update
@param         Lead, Map<String, Account>
@return        CCPM_SMSMessage__c
*/
    public static void updateLeadFromCampaignMemeber(Lead objLead, Campaign objCampaignIn){
        if(objLead != null && objCampaignIn != null && CCPM_Collection.isNotNullEmpty(objCampaignIn.CCPM_smsTemplates__r)){
            CCPM_leadTriggerHandlerHelper.calculateActualSMSScheduleDateTime(objLead);
            objLead.CCPM_CampingFollowUpMessageTemplate__c = objCampaignIn.CCPM_smsTemplates__r[0].CCPM_followupMessage__c;
        }
    }
     /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create sms message custom object to send initial messages for Campaigns
@param         Lead, Map<String, Account>
@return        CCPM_SMSMessage__c
*/
    public static CCPM_SMSMessage__c createSMSForCampaignMember(Lead objLead, Campaign objCampaignIn){
        CCPM_SMSMessage__c objSMSMsg = null;
        if(objLead != null && objCampaignIn != null && CCPM_Collection.isNotNullEmpty(objCampaignIn.CCPM_smsTemplates__r) && !objLead.CCPM_DismissedLead__c){ 
            CCPM_smsTemplate__c objSMSTemp = objCampaignIn.CCPM_smsTemplates__r[0];
            String strMessage = objSMSTemp.CCPM_initialMessage__c;
            objSMSMsg = CCPM_utility.createRecordsForSmsMessageObject(objLead,strMessage,objLead.CCPM_mobileNumber__c,Label.CCPM_leadTypeCampaignInitialSMSPart1,Label.CCPM_taskCommunicationOutbound,objLead.CCPM_ActualSMSScheduleDateTime__c,Label.CCPM_liveTextPhoneNumber);
            if(objSMSMsg != null){
                objSMSMsg.CCPM_smsTemplate__c = objSMSTemp.id;
                objSMSMsg.CCPM_dynamicECODE__c = objLead.CCPM_storeEcode__c;
            }
        }
        return objSMSMsg;
    }
}