/**
*@name          CCPM_SMSMessageBatchHandler
*@author        Brigadesh Chandrasekar (Deloitte)
*@date          05/07/2017
@description    Handler class to send SMS Messages by reading messages from CCPM_SMSMessage object. The handler class makes an API callout to Heywire API to send message and updates the status of SMS Message to Sent
@testClass      
Modification    Log: manjunath keshava(deloitte)07/13/2017-->Force Reviewer changes
------------------------------------------------------------------------------------
Developer             				  Date                                Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)    05/07/2017                          Original Version
Brigadesh Chandrasekar(Deloitte)    08/03/2017                          Added logic to capture RequestID
Brigadesh Chandrasekar(Deloitte)    09/28/2017                          Modified logic to handle Campaign SMS related Stories - Includes Synchronous Batch Jobs change/Includes Changes made for inserting Campaign Initial SMS and Follow Up SMS
*/
public class CCPM_SMSMessageBatchHandler {
    
    //List of Leads marked with Success SMS status
    public static map<id,CCPM_SMSMessage__c> mpLeadSuccess = new map<id,CCPM_SMSMessage__c>();
    public static set<id> setLeadSuccessIds = new set<id>();
    //List of SMSMessafes Object to update for a succesfule call out
    public static list<CCPM_SMSMessage__c> lstSuccessSMS = new List<CCPM_SMSMessage__c>();
    public static list<CCPM_SMSMessage__c> lstSMSMessageAll = new List<CCPM_SMSMessage__c>();
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method makes the callout for each record obtained from the batch.
*@return        Void(None)
*/  
    
    Public static void sendSMSViaHeyWire(list<CCPM_SMSMessage__c> lstSMSMessageSent)
    {	
        //For each record in SMSMessage
        for(CCPM_SMSMessage__c SMSMessage : lstSMSMessageSent )
        { 	
            if(SMSMessage.CCPM_message__c!=null)
            {
                //Check if SMS is Initial SMS or Prospect 1st SMSs
                if((SMSMessage.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeInitialSMSPart1 ||SMSMessage.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1||SMSMessage.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart1) && SMSMessage.CCPM_MessageStatus__c==CCPM_staticConstants.strMessageStatusQueued)
                {
                    //Split the Message based on split criteria
                    List<String> lstSMSBodySplit = new List<String>();
                    CCPM_SMSMessage__c SMSMessagePart2 = new CCPM_SMSMessage__c();
                    lstSMSBodySplit = SMSMessage.CCPM_message__c.split('%');
                    //Check if the SMS is Initial SMS
                    if(SMSMessage.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeInitialSMSPart1)
                    {
                        SMSMessagePart2=createRecordsForSmsMessageObject(SMSMessage.CCPM_leadRecord__c, lstSMSBodySplit[1],SMSMessage.CCPM_toPhoneNumber__c, CCPM_staticConstants.strMessageTypeInitialSMSPart2, CCPM_staticConstants.strTaskCommunicationOutbound,SMSMessage.CCPM_ScheduleDateTime__c,CCPM_staticConstants.strMessageStatusQueued,SMSMessage.CCPM_LiveTextNumber__c);
                    }
                    else if(SMSMessage.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart1)
                    {
                         SMSMessagePart2=createRecordsForSmsMessageObject(SMSMessage.CCPM_leadRecord__c, lstSMSBodySplit[1],SMSMessage.CCPM_toPhoneNumber__c, CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart2, CCPM_staticConstants.strTaskCommunicationOutbound,SMSMessage.CCPM_ScheduleDateTime__c,CCPM_staticConstants.strMessageStatusQueued,SMSMessage.CCPM_LiveTextNumber__c);
                    }
                    else if(SMSMessage.CCPM_messageType__c==CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1)
                    {	
                        SMSMessagePart2=createRecordsForSmsMessageObject(SMSMessage.CCPM_leadRecord__c, lstSMSBodySplit[1],SMSMessage.CCPM_toPhoneNumber__c, CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2,CCPM_staticConstants.strTaskCommunicationOutbound,SMSMessage.CCPM_ScheduleDateTime__c,CCPM_staticConstants.strMessageStatusQueued,SMSMessage.CCPM_LiveTextNumber__c);
                    }
                    //Assign the 1st part of the SMS body
                    
                    SMSMessage.CCPM_message__c=lstSMSBodySplit[0];
                    //Format SMS part 1
                    String SMSPart1BodyFormatted= formatMessage(lstSMSBodySplit[0]);
                    //Format SMS part 2
                    String SMSPart2BodyFormatted= formatMessage(lstSMSBodySplit[1]);
                    //Make a callout for the 1st part of SMS to go out
                    HttpResponse responsepart1 = CCPM_HttpCallOutUtility.createHeyWireHttpRequest(SMSPart1BodyFormatted,SMSMessage.CCPM_formattedtoPhone__c,SMSMessage.CCPM_LiveTextNumber__c);                 
                    //Timer Logic to ensure the order of SMS being sent out
                    
                    //Make a callout for the 2nd part of SMS to go out
                    HttpResponse responsepart2 = CCPM_HttpCallOutUtility.createHeyWireHttpRequest(SMSPart2BodyFormatted,SMSMessage.CCPM_formattedtoPhone__c,SMSMessage.CCPM_LiveTextNumber__c); 
                    //Update SMS Message Records based on Response codes received
                    processResponseStatusCode(responsepart1,SMSMessage);
                    processResponseStatusCode(responsepart2,SMSMessagePart2);
                    
                }
                else{
                    String SMSBodyFormatted= formatMessage(SMSMessage.CCPM_message__c);
                    //Make a Heywire callout for each record obtained and capture the response 	    
                    HttpResponse response = CCPM_HttpCallOutUtility.createHeyWireHttpRequest(SMSBodyFormatted,SMSMessage.CCPM_formattedtoPhone__c,SMSMessage.CCPM_LiveTextNumber__c);
                    processResponseStatusCode(response,SMSMessage );
                }
            }   
        }
        //Creating a list to hold the Lead records for which SMS were sent out successfully
        list<Lead> lstLead = new list<Lead>();
        if(setLeadSuccessIds!=null && !setLeadSuccessIds.isEmpty())
        {
            //Get the list of Lead records for whom the fields need to be updated based on the success response codes
            lstLead = [select id,ownerid,CCPM_isInitialSMSSent__c,CCPM_isFollowUpSMSSent__c,CCPM_isProspectSMSsent__c,CCPM_prospectSMSSentDate__c,CCPM_initialSMSSentDateTime__c,CCPM_followUpSMSDate__c,CCPM_lastInteraction__c from lead where id in :setLeadSuccessIds ];
        }
        //Map to hold the lead records as values and ID as key
        map<id,Lead> mpLead = new map<id,Lead>();
        for (Lead l : lstLead)
        {
            mpLead.put(l.Id,l);
        }
        //Upsert the SMSMessage Records in bulk
        updateSMSMessageSentFields(lstSMSMessageAll);
        if( lstLead != null && lstLead.size() > 0  && !lstLead.isEmpty() )
        {	
            //Making a callout to the method which updates the Lead records accordingly
            updateLeadFields(mpLeadSuccess,lstLead);
            //Making a callout to the Method that creates Tasks on succesful SMS sent status
            createInteractionTouchPoint(lstSuccessSMS,mpLead);
            
        }
        
    }
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Processing Response Status Code and inserting SMS messages
*@return        Void(None)
*/
    public static void processResponseStatusCode(HttpResponse response, CCPM_SMSMessage__c SMSMessage )
    {
        try{
            SMSMessage.CCPM_requestID__c= response.getHeader(CCPM_staticConstants.strRequestID);
        }
        catch(Exception e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_SMSMessageBatchHandler','Error Thrown while extracting the RequestID','Exception thrown because of RequestID Header',true);
        }
        if(response != null && response.getStatusCode() == CCPM_staticConstants.intSuccessResponseCode)
        {	
            //lstLeadSuccess.add(SMSMessage.CCPM_leadRecord__c);
            //Updating the status of the SMSMessage Record
            SMSMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusSent;
            if(SMSMessage.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeInitialSMSPart2 || SMSMessage.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart2 || SMSMessage.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2 ||  SMSMessage.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeFollowUpSMS || SMSMessage.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeCampaignFollowUpSMS)
            {	
                mpLeadSuccess.put(SMSMessage.CCPM_leadRecord__c,SMSMessage);
                
            }
            //Adding the SMSMessage object into the list that keeps track of records to be updated based on response codes
            lstSuccessSMS.add(SMSMessage);
            //Adding Id's of Leads for which SMS has been sent succesfully
            setLeadSuccessIds.add(SMSMessage.CCPM_leadRecord__c); 
        }
        //When the response code is not received or refers to failure
        else
        {   //Update the fail counter
            SMSMessage.CCPM_SMSFailCounter__c = CCPM_staticConstants.strEmpty + (Integer.valueOf(SMSMessage.CCPM_SMSFailCounter__c) + 1);
            //Checking for the max number of retrials
            if(Integer.valueOf(SMSMessage.CCPM_SMSFailCounter__c) < Integer.valueOf(CCPM_staticConstants.strSMSFailCounter))
            {	
                //Update status to Error
                SMSMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusError;
            }
            else
            {	//Update status to Resend Failed
                SMSMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusResendFailed;
            }
            
        }
        
        if(response != null)
        {   //Update the response code and response status in SMSMessage record
            SMSMessage.CCPM_responseCode__c = CCPM_staticConstants.strEmpty + response.getStatusCode();
            SMSMessage.CCPM_responseMessage__c = response.getStatus();  
        }
        lstSMSMessageAll.add(SMSMessage);
    }
    
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method creates task for successful SMS sent on Lead Record
*@return        Void(None)
*/  
    public static void createInteractionTouchPoint(List<CCPM_SMSMessage__c> lstSuccessMessages,map<id,Lead> mpLead)
    {
        List<Task> lstTask = new List<Task>();
        for(CCPM_SMSMessage__c SMS : lstSuccessMessages)
        {
            if(SMS.CCPM_leadRecord__c!=null)
            {
                Task objTask 			= new task();
                //Setting the Assigned to ID
                objTask.OwnerId			= mpLead.get(SMS.CCPM_leadRecord__c).ownerId;
                //Setting Task Type
                objTask.Type			= CCPM_staticConstants.strTaskTypeSMS;
                //Setting Communication Direction
                objTask.CCPM_communicationDirection__c=CCPM_staticConstants.strTaskCommunicationOutbound;
                //Setting the Comments field with message received from Customer
                objTask.Description		= SMS.CCPM_message__c;
                //Setting the Record type of task to be created and associated fields
                objTask.RecordTypeId	= CCPM_staticConstants.strTaskInteractionHistoryRecordType;
                // set the priority of the task to normal
                objTask.Priority		= CCPM_staticConstants.strTaskPriorityNormal;
                // set the status of task to completed
                objTask.Status			= CCPM_staticConstants.strTaskCompleted;
                // set the subject of the task
                objTask.Subject			= CCPM_staticConstants.strTaskSubjectTextMessageSent;
                //Set the Message Type on Task
                objTask.CCPM_SMSMessageType__c=SMS.CCPM_messageType__c;
                //system.debug('the type is '+objTask.CCPM_SMSMessageType__c);
                // associate the task to lead record
                objTask.whoid			= SMS.CCPM_leadRecord__c;
                
                
                lstTask.add(objTask);    
            }
        }
        try{
            if(lstTask!=null && lstTask.size()>0 && !lstTask.isEmpty())
            {
                insert lstTask;
            }
        }
        catch(DMLException e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_SMSMessageSentBatchHandler','Insert Task Records for SMS sent','Exception thrown during Insert',true);
        }        
        
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method updates the SMSMessage Records based on response received in bulk
*@return        Void(None)
*/  
    public static void updateSMSMessageSentFields(List<CCPM_SMSMessage__c> lstSMSMessageSent)
    {
        try{
            if(lstSMSMessageSent!=null && lstSMSMessageSent.size()>0 &&!lstSMSMessageSent.isEmpty() )
            {
                upsert lstSMSMessageSent;
            }
        }
        catch(DMLException e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_SMSMessageSentBatchHandler','Updating SMS Message Sent Records','Exception thrown during Update',true);
        }
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method updates the Lead Records based on response received in bulk
*@return        Void(None)
*/  
    public static void updateLeadFields(map<id,CCPM_SMSMessage__c> mpLeadSuccesses,List<Lead> lstLead)
    {
        for(Lead l : lstLead)
        {	
            if(mpLeadSuccesses.containsKey(l.Id))
            {
                if(mpLeadSuccesses.get(l.id).CCPM_messageType__c == CCPM_staticConstants.strMessageTypeInitialSMSPart2 || mpLeadSuccesses.get(l.id).CCPM_messageType__c == CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart2 )
                {	
                    //Setting the flags on lead records once Initial SMS part 2 is sent.
                    l.CCPM_isInitialSMSSent__c 					= true;
                    l.CCPM_initialSMSSentDateTime__c 			= System.now();
                    l.CCPM_lastInteraction__c 					= System.now();
                    l.Status 									= CCPM_StaticConstants.strLeadStatusContacted;
                    
                }
                else if(mpLeadSuccesses.get(l.id).CCPM_messageType__c == CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2)
                {	
                    //Setting the flags on Lead records once Prospesct SMS part 2 is sent
                    l.CCPM_isProspectSMSsent__c					= true;
                    l.CCPM_prospectSMSSentDate__c				= System.now();
                    l.CCPM_lastInteraction__c					= System.now();
                    l.Status									= CCPM_StaticConstants.strLeadStatusContacted;
                }
                else if(mpLeadSuccesses.get(l.id).CCPM_messageType__c == CCPM_staticConstants.strMessageTypeFollowUpSMS || mpLeadSuccesses.get(l.id).CCPM_messageType__c == CCPM_staticConstants.strMessageTypeCampaignFollowUpSMS )
                {
                    //Setting the flags on Lead Records once Follow-Up SMS is sent
                    l.CCPM_isFollowUpSMSSent__c					= true;
                    l.CCPM_followUpSMSDate__c					= System.now();
                    l.CCPM_lastInteraction__c					= System.now();
                    l.Status									= CCPM_StaticConstants.strLeadStatusContacted;    
                }
            }
        }
        try{
            if(lstlead!=null && lstlead.size()>0 && !lstlead.isEmpty())
            {
                //Updating Lead Records with the flags in Bulk
                update lstlead;
            }
        }
        catch(DMLException e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_SMSMessageSentBatchHandler','Updating Lead records on successful sent SMS','Exception thrown during Update of Lead',true);
        }
        
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method creates records for sms messages object for part 2 SMS
@param         list of new leads
@return        Void(None)
*/ 
    public static CCPM_SMSMessage__c createRecordsForSmsMessageObject(id iDLead, String strMessage, String strToPhone, String strMessageType, String strCommunicationDirection,datetime datTScheduleTime,String strMessageStatus,String strLivetextPhoneNumber)   
    {
        CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
        objSmsMessage.CCPM_leadRecord__c = iDLead;
        objSmsMessage.CCPM_LiveTextNumber__c = strLivetextPhoneNumber;
        objSmsMessage.CCPM_message__c = strMessage;
        objSmsMessage.CCPM_MessageStatus__c = strMessageStatus;
        objSmsMessage.CCPM_messageType__c = strMessageType;
        objSmsMessage.CCPM_referenceId__c = strMessageType +iDLead;
        objSmsMessage.CCPM_ScheduleDateTime__c = datTScheduleTime;
        objSmsMessage.CCPM_toPhoneNumber__c = strToPhone;
        objSmsMessage.CCPM_SMSFailCounter__c = '0';
        objSmsMessage.CCPM_communicationDirection__c= strCommunicationDirection;
        return objSmsMessage;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method formats the SMS body to be sent.
@param         list of new leads
@return        Void(None)
*/ 
    
    public static string formatMessage(string strSMSBodySplit)
    {
        List<String> lstSMSFormat=strSMSBodySplit.split(CCPM_staticConstants.strSpace);
        String strSMSFormatParts=CCPM_staticConstants.strEmpty;
        for(string s: lstSMSFormat )
        {
            strSMSFormatParts=strSMSFormatParts+CCPM_staticConstants.strPlus+s;
        }
        return strSMSFormatParts;
    }
    
    
    
    
    
    
    
}