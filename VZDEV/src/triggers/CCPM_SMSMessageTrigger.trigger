/**
*@name          CCPM_SMSMessageTrigger
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          06/14/2017
@description    
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                    Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)      06/14/2017              Original Version
*/
trigger CCPM_SMSMessageTrigger on CCPM_SMSMessage__c (before insert, before update,after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            CCPM_SMSMessageTriggerHandler.UpdateSMSMessageRecordsforPart1BeforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    
    
   /* if(Trigger.isafter){
        if(Trigger.isInsert){
            //Creating Interaction Touchpoints for SMS Messages corresponding to SMS body Part 2
            CCPM_SMSMessageTriggerHandler.createInteractionTouchPointForSMSMessagePartIIAfterInsert(Trigger.new);
            //Updating Lead fields after sending out Initial SMS and Prospect 1st SMS
            CCPM_SMSMessageTriggerHandler.updateLeadFieldsInitialProspectSMSAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate)
        {   //Creating Interaction Touchpoints for SMS Message corresponding to Part1 SMS / Single Body SMS
            CCPM_SMSMessageTriggerHandler.createInteractionTouchPointForSMSMessageAfterUpdate(Trigger.new, Trigger.oldMap);
            //Updating Lead fields for Follow-Up SMS sent
            CCPM_SMSMessageTriggerHandler.updateLeadFieldsFollowUpAfterUpdate(Trigger.new,Trigger.oldMap);
            
        }
    }*/
    
}