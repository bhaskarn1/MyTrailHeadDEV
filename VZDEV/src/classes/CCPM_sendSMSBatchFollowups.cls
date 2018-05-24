/**
*@name          CCPM_sendSMSBatch
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          09/26/2017
@description    Batch class to send SMS messages to customers & prospects by reading messages from “CCPM_SMSMessage"
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli(Deloitte)    09/26/2017                          Original Version
                                                                            DISTSCE-1589- Added SMS MessageTypes for SMS Batch Jobs
*/
global class CCPM_sendSMSBatchFollowups implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable{

   global Database.QueryLocator start(Database.BatchableContext BC){
   	   string strQuery;
       string Queued = CCPM_staticConstants.strMessageStatusQueued;
       string Error = CCPM_staticConstants.strMessageStatusError;
       // Capturing the SMS Message Types from the custom settings specific to this batch job
        set<string> setSMSMessageTypes = new set<string>();
     	string strFollowupSMSTypes = Label.CCPM_followupMessageTypes;
        if(strFollowupSMSTypes != null && !string.isBlank(strFollowupSMSTypes)){
            setSMSMessageTypes = new set<String>(strFollowupSMSTypes.Split(CCPM_staticConstants.strColon));
        } 
        //Capturing the current System Time
        datetime datTCurrentTime     = Datetime.now();
        SYSTem.debug('Datetime Now-> '+Datetime.now());
        System.debug('System Now-> ' + System.now());
        system.debug('setSMSMessageTypes: '+ setSMSMessageTypes);
        //Getting the Date/Time formatted.
        String strCurrentTime        = datTCurrentTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        System.debug('# Current time of the system recorded -> '+strCurrentTime);
        // Building up the Query string for Execute method
        strQuery='select id,name,CCPM_LiveTextNumber__c,CCPM_formattedtoPhone__c,CCPM_messageType__c,CCPM_leadRecord__c,CCPM_leadRecord__r.CCPM_isInitialSMSSent__c,CCPM_leadRecord__r.CCPM_isFollowUpSMSSent__c,CCPM_leadRecord__r.CCPM_isProspectSMSsent__c,CCPM_message__c,CCPM_MessageStatus__c,CCPM_responseCode__c,CCPM_responseMessage__c,CCPM_ScheduleDateTime__c,CCPM_SMSFailCounter__c,CCPM_toPhoneNumber__c from CCPM_SMSMessage__c where (CCPM_MessageStatus__c=:'+CCPM_staticConstants.strMessageStatusQueued+' or CCPM_MessageStatus__c=:'+CCPM_staticConstants.strMessageStatusError+') and CCPM_ScheduleDateTime__c<'+strCurrentTime+' and CCPM_leadRecord__c != '+'null '+ ' and CCPM_messageType__c in :setSMSMessageTypes  order by CCPM_ScheduleDateTime__c limit '+CCPM_staticConstants.strBatchLimit;			
         System.debug('Query->'+strQuery);
        //Returning the records obtained by querying
        system.debug('setSMSMessageTypes: '+ setSMSMessageTypes);
        return Database.getQueryLocator(strQuery);
        
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Execute method in batchable context to make a callout to the handler
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<CCPM_SMSMessage__c> scope) {
        system.debug('# List of SMS Message Sent Records obtained from query in batchable context -> '+scope);
        CCPM_SMSMessageBatchHandler.sendSMSViaHeyWire(Scope);
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This method schedules the Batch class for every 5 min(Need to confirm)
*@return        Void(None)
*/     
    global void execute(SchedulableContext sc)
    {
        CCPM_sendSMSBatchFollowups objsendSMSBatchFollowups =new CCPM_sendSMSBatchFollowups();
        database.executebatch(objsendSMSBatchFollowups,integer.valueof(CCPM_staticConstants.strBatchChunk));
    
    }
    
}