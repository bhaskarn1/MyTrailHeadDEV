/**
*@name          CCPM_CampaignMemberHandler
*@author        Sriraman Sridharan (Deloitte)
*@date          09/21/2017
@description    The Triger Handler on the Campaign Member Object is intended to support the trigger
@testClass      CCPM_ITRMessageHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          09/21/2017              Original Version
*/

public class CCPM_ITRMessageHandler {
    
    public static set<String> strWordsFromDataDictionary = CCPM_utility.getStringFromDataDictionary();
    public static List<LOG_LogMessage__c> lstleadhdlrLogMsg = new List<LOG_LogMessage__c>();
    public static String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
    public static String strLeadCustomerQuoteRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerQuotesRT).getRecordTypeId();   
    public static String strLeadCustomerAbandonedVisit = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerAbandonedVisitlead).getRecordTypeId();
    public static Set<String> setCustomerRecordTypeids = new Set<String>{strLeadCustomerCartRT,strLeadCustomerAbandonedVisit,strLeadCustomerQuoteRT};
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to create initial message records for the leads during creation
@param         list of new leads
@return        Void
*/ 
    public static List<LiveText__ITR_Message__c> processITRs(list<LiveText__ITR_Message__c> lstNewITRRecords){
        Map<String,LiveText__ITR_Message__c> mapItrIDAndItrRecord = new Map<String,LiveText__ITR_Message__c>();
        Map<String,String> mapItrIDAndleadID = new Map<String,String>();
        set<string> setleadID = new set<string>();
        set<string> setLeadStoreID=new set<string>();
        set<string> setUserID=new set<string>();
        set<lead> setLeads = new set<lead>();
        list<lead> lstAllLeads = new list<lead>();
        map<id,User> mapOwnerFirstname = new map<id,User>();
        map<id,list<CCPM_storeEmployee__c>> mapManagersContact = new map<id,list<CCPM_storeEmployee__c>>();
        list<CCPM_storeEmployee__c> lstManagers = new list<CCPM_storeEmployee__c>();
        list<task> lstCreateTaskCustomerResponse    = new list<task>();
        List<CCPM_SMSMessage__c> lstSMSMessages     = new List<CCPM_SMSMessage__c>();
        Set<CCPM_SMSMessage__c> setSMSMessages  = new Set<CCPM_SMSMessage__c>();
        Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
        CCPM_SMSMessage__c objSmsManager = new CCPM_SMSMessage__c();
        BusinessHours bhrs = null;
        Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapGetBusinessHours();
        List<LiveText.ScheduleItem> lstSMIall       = new List<LiveText.ScheduleItem>();
        for(LiveText__ITR_Message__c objITRRecord : lstNewITRRecords){
            if(objITRRecord.LiveText__Message__c != null && !String.isEmpty(objITRRecord.LiveText__Message__c) && !String.isBlank(objITRRecord.LiveText__Message__c)){
                String strmessage = objITRRecord.LiveText__Message__c;
                mapItrIDAndItrRecord.put(objITRRecord.Id, objITRRecord);
                mapItrIDAndleadID.put(objITRRecord.Id, objITRRecord.LiveText__Lead__c);
                setleadID.add(objITRRecord.LiveText__Lead__c);
            }
        }
        map<id, lead> mapLead = getRelatedLeads(setleadID); //Get the map of lead records
        List<lead> lstleads = mapLead.values();
        system.debug('@@@processITRs');
        //Iterate through leads
        for(lead objlead : lstleads){
            setLeadStoreID.add(objlead.store__c);
            setUserID.add(objlead.OwnerId);
        }
        lstManagers = getRelatedStoreEmployees(setLeadStoreID); //Get list of store employees who are managers/asst managers
        mapOwnerFirstname = getRelatedUsers(setUserID); //Get the first name and last name of the lead owners
        mapManagersContact = getMapStoreAndManagers(lstManagers); //construct mapManagersContact
        //suppress messages to managers based on custom setting 
        Map<String, CCPM_suppressOutboundSMS__c> mapSuppressOutboundMessage = CCPM_staticConstants.mapSuppressOutboundMessage;
        Set<CCPM_suppressOutboundSMS__c> setSuppressOutboundMessage = new Set<CCPM_suppressOutboundSMS__c>();
        if(mapSuppressOutboundMessage != null && !mapSuppressOutboundMessage.isEmpty()){
            For(string strkey : mapSuppressOutboundMessage.keySet()){
                CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = new CCPM_suppressOutboundSMS__c();
                objSuppressOutboundMessage = mapSuppressOutboundMessage.get(strkey);
                //Check for Market/Territory/District
                if(objSuppressOutboundMessage.IsActive__c){
                    setSuppressOutboundMessage.add(objSuppressOutboundMessage);
                }
            }
        }
        //Iterate through ITR MEssage Records
        for(LiveText__ITR_Message__c objITRRecord : lstNewITRRecords){
            //Customer Response Logic
            if(objITRRecord.LiveText__Lead__c != null && !mapItrIDAndleadID.isEmpty() && !mapLead.isEmpty() && mapItrIDAndleadID.containsKey(objITRRecord.Id) && mapItrIDAndleadID.get(objITRRecord.Id) != null 
               && mapLead.containsKey(mapItrIDAndleadID.get(objITRRecord.Id)) && mapLead.get(mapItrIDAndleadID.get(objITRRecord.Id)) != null){
                   LiveText.ScheduleItem objSMIall;
                   lead objleadForList;
                   lead objLeadRef = mapLead.get(mapItrIDAndleadID.get(objITRRecord.Id));
                   boolean flagDataDictionary = false;
                   System.debug('@@@strWordsFromDataDictionary' + strWordsFromDataDictionary);
                   for(String objString :strWordsFromDataDictionary){
                       if(objITRRecord.LiveText__Message__c.containsIgnoreCase(objString)){
                           flagDataDictionary =true;
                       }
                   }
                   if(CCPM_utility.setLeadOpenStatusWithoutNew.contains(objLeadRef.Status)){                          
                       //Process customer response
                       if(!flagDataDictionary && (!objLeadRef.CCPM_Account__r.CCPM_SMSOptOut__c )){
                           objSMIall = ProcessCustomerResponse(objITRRecord,mapLead.get(mapItrIDAndleadID.get(objITRRecord.Id)));
                       }
                   }
                   //Process leads
                   objleadForList = ProcessLeads(objITRRecord,mapLead.get(mapItrIDAndleadID.get(objITRRecord.Id)),flagDataDictionary);
                   if(objSMIall != null){
                       lstSMIall.add(objSMIall);
                   } 
                   if(objleadForList != null){
                       setLeads.add(objleadForList);
                   }
                   
                   //Create tasks
                   Task objTask =createToDoTaskforCustomerResponse(mapLead.get(mapItrIDAndleadID.get(objITRRecord.Id)),objITRRecord);
                   if(objTask!=null)
                   {
                       lstCreateTaskCustomerResponse.add(objTask);
                   }
                   Task objTaskInteractionHistory =createInteractionTaskforCustomerResponse(mapLead.get(mapItrIDAndleadID.get(objITRRecord.Id)),objITRRecord);
                   if(objTaskInteractionHistory!=null)
                   {
                       lstCreateTaskCustomerResponse.add(objTaskInteractionHistory);
                   }
               }
        }
        //Send Message to Managers
        for(Lead objLeadForMessage : setLeads){
            //Get businesshour related to Lead store
            bhrs = CCPM_utility.getBusinessHrForLead(objLeadForMessage );   
            
            DateTime datTBusinessTime = bhrs != null ? CCPM_utility.calculateTimeWithInBusinessHours(bhrs, System.now()): null;           
            
            if(objLeadForMessage.Status==CCPM_staticConstants.strLeadStatusResponded && objLeadForMessage.CCPM_leadSubStatus__c == CCPM_staticConstants.strLeadSubStatusActionRequired
               && objLeadForMessage.store__c != null && mapManagersContact.containsKey(objLeadForMessage.store__c)){
                   for(CCPM_storeEmployee__c objStoreManager : mapManagersContact.get(objLeadForMessage.store__c) )
                   {                       
                       if(objLeadForMessage.OwnerId!=objStoreManager.CCPM_employee__c )
                       {
                           objSmsManager=SendSMSToManagers(objLeadForMessage,objStoreManager,mapOwnerFirstname,datTBusinessTime,setSuppressOutboundMessage);
                           if( objSmsManager!=null)
                           {
                               lstSMSMessages.add(objSmsManager);
                           }
                       }      
                   }
               }
        }
        try{
            insertSmsMessages(lstSMSMessages); //Insert SMS Messages
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','processITRs','Exception thrown while inserting SMS Messages','');
            lstleadhdlrLogMsg.add(log);            
        }
        system.debug('@@@lstSMIall: ' + lstSMIall);
        livetext.ScheduleMessageAction.scheduleMessages(lstSMIall);  //Scheduling the list of SMS "Schedule Items" to be actually sent to the Customer
        lstAllLeads.addAll(setLeads);
        try{
            updateLeadsAndAccount(lstAllLeads); //Update leads and accounts
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','processITRs','Exception thrown while updating Leads and Accounts','');
            lstleadhdlrLogMsg.add(log);            
        }
        try {
            insertTaskRecords(lstCreateTaskCustomerResponse); //Insert task records
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','processITRs','Exception thrown while inserting Task records','');
            lstleadhdlrLogMsg.add(log);            
        }
        
        //insert all errors
        if(CCPM_Collection.isNotNullEmpty(lstleadhdlrLogMsg)){
            try{
                upsert lstleadhdlrLogMsg;
            }
            catch(DMLException e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_ITRMessageHandler','processITRs','Exception thrown while upserting Error messages',true);
            }
        }
        
        return lstNewITRRecords;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to process the customer responses
@param         
@return        List<LiveText.ScheduleItem>
*/     
    public static LiveText.ScheduleItem ProcessCustomerResponse(LiveText__ITR_Message__c objITRRecord,lead objlead){
        // instance of livetext schedule item
        LiveText.ScheduleItem objSI = new LiveText.ScheduleItem(); 
        String strITRMessage = objITRRecord.LiveText__Message__c;
        Integer[] chars = strITRMessage.getChars();
        String strFinalITRMessage = strITRMessage;
        if(chars.size() == 3 && ( CCPM_utility.setAsciiSpecialString.contains(String.valueOf(chars[0])) || CCPM_utility.setAsciiSpecialString.contains(String.valueOf(chars[2]))))
        {
            strFinalITRMessage = strITRMessage.substring(1, 2);
        }
        system.debug('@@@strFinal : ' +strFinalITRMessage);
        system.debug('@@@' + objlead.RecordTypeId + ' ' + objlead.CCPM_isSMSResponseReceived__c + ' ' + objlead.CCPM_SMSOptOut__c + ' ' + !String.isEmpty(strFinalITRMessage) + ' ' + !String.isBlank(strFinalITRMessage));
        if(setCustomerRecordTypeids.contains(objLead.recordTypeId) && !objlead.CCPM_DoubleOptOutSent__c && !String.isEmpty(strFinalITRMessage) && !String.isBlank(strFinalITRMessage) &&
           (strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOut || strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall) && !objlead.CCPM_SMSOptOut__c){
               objSI.Message = objlead.CCPM_DoubleOptOutSmsBody__c;
           }
        else if(setCustomerRecordTypeids.contains(objLead.recordTypeId) && objlead.CCPM_isSMSResponseReceived__c && objlead.CCPM_SMSOptOut__c && !String.isEmpty(strFinalITRMessage) && !String.isBlank(strFinalITRMessage) &&
                (strFinalITRMessage==CCPM_staticConstants.strCustomerResponseForOptOut || strFinalITRMessage==CCPM_staticConstants.strCustomerResponseForOptOutSmall)){
                    system.debug('@@@X'); 
                    objSI.Message          = objlead.CCPM_CustomerResponseMessageBody__c;
                }
        else if((objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || objlead.RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID) 
                && !objlead.CCPM_SMSOptOut__c && !String.isEmpty(strFinalITRMessage) && !String.isBlank(strFinalITRMessage) && !objlead.CCPM_SMSOptOut__c && 
                (strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOut || strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall) ){
                    objSI.Message  = objlead.CCPM_CustomerResponseMsgBodyforProsp__c;
                }
        else if(!(objlead.Status == CCPM_staticConstants.strLeadStatusResponded && objlead.CCPM_leadSubStatus__c == CCPM_staticConstants.strLeadSubStatusActionRequired) && !objlead.CCPM_SMSOptOut__c){
            if(objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || objlead.RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID){
                objSI.Message   = objlead.CCPM_SMSResponseBodyForProspect__c;
            }
            else{
                objSI.Message           = objlead.CCPM_SMSResponseBody__c;
            }
        }
        objSI.ObjectId          = objlead.Id;
        //Setting the reference string for Process Customer Response
        objSI.ReferenceId       = CCPM_staticConstants.strReferenceProcessCustomerResponse; 
        //Setting the SMS body
        //Setting the customer number to whom the message shall be sent
        objSI.ToPhoneNumber     = objITRRecord.LiveText__Originating_Number__c;
        //Setting the Live Text Number from which the message is to be sent
        if(objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID)
        {
            objSI.LiveTextNumber    = CCPM_staticConstants.strLivetextPhoneNumberNonVerizon;
        }
        else
        {
            objSI.LiveTextNumber    = CCPM_staticConstants.strLivetextPhoneNumber;
        }
        if(objSI.Message != null && !String.isEmpty(objSI.Message)){
            return objSI;
        }
        else{
            return null;
        }
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to process the customer responses
@param         
@return        set<lead>
*/     
    public static lead ProcessLeads(LiveText__ITR_Message__c objITRRecord, lead objlead, boolean flagDataDictionary){
        //Process customer response logic
        //First response for customer, Prospect cart and prospect 
        if(CCPM_utility.setLeadOpenStatusWithoutNew.contains(objlead.Status)){
            String strITRMessage = objITRRecord.LiveText__Message__c;
            Integer[] chars = strITRMessage.getChars();
            String strFinalITRMessage = strITRMessage;
            if(chars.size() == 3 && (CCPM_utility.setAsciiSpecialString.contains(String.valueOf(chars[0])) || CCPM_utility.setAsciiSpecialString.contains(String.valueOf(chars[2]))))
            {
                strFinalITRMessage = strITRMessage.substring(1, 2);
            }
            system.debug('@@@strFinal : ' +strFinalITRMessage);
            //Populate previous status to contacted if the current status is eligible -> Hotfix for Heroku issue where there is a delay in the lead update
            if(objlead.Status==CCPM_staticConstants.strLeadStatusEligible){
                objlead.CCPM_previousLeadStatus__c = CCPM_staticConstants.strLeadStatusContacted;
            }
            if(!objlead.CCPM_isSMSResponseReceived__c && flagDataDictionary){
                objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                objlead.CCPM_isSMSResponseReceived__c = true;
                objlead.CCPM_lastInteraction__c = system.now();
                objlead.Status=CCPM_staticConstants.strLeadStatusQualified;
                objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusDisinterested;
            }
            else if(objlead.CCPM_isSMSResponseReceived__c && flagDataDictionary){
                objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                objlead.CCPM_lastInteraction__c = system.now();
                objlead.Status=CCPM_staticConstants.strLeadStatusQualified;
                objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusDisinterested;
            }
            else if(!objlead.CCPM_isSMSResponseReceived__c && !String.isEmpty(strFinalITRMessage) && !String.isBlank(strFinalITRMessage) &&
                    (strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOut || strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall)){
                        if(setCustomerRecordTypeids.contains(objLead.recordTypeId) || objlead.RecordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID){
                            objlead.CCPM_SMSOptOut__c = true;
                            objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                            objlead.CCPM_isSMSResponseReceived__c = true;
                            objlead.CCPM_lastInteraction__c = system.now();
                            objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                            objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusCartDisinterested;
                            objlead.CCPM_AutoResponseForDoubleOptOutSmsSent__c = true;
                            objlead.CCPM_DoubleOptOutSent__c = true;
                        }
                        else if(objlead.RecordTypeId == CCPM_staticConstants.strProspectRecordTypeID){
                            objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                            objlead.CCPM_isSMSResponseReceived__c = true;
                            objlead.CCPM_lastInteraction__c = system.now();
                            objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                            objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusOptedOut;
                        }
                    }
            else if(!objlead.CCPM_isSMSResponseReceived__c){
                objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                objlead.CCPM_isSMSResponseReceived__c = true;
                objlead.CCPM_lastInteraction__c = system.now();
                objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusActionRequired;
            } 
            //Pre Defined sms
            /*else if(objLead.CCPM_isSMSResponseReceived__c && !objLead.CCPM_finalPreDefinedSMSFlag__c && objLead.CCPM_firstPredefinedSMSFlag__c){
                objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                objlead.CCPM_lastInteraction__c = system.now();
                objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusActionRequired; 
            }*/
            //Response to double opt out message
            else if(objLead.CCPM_isSMSResponseReceived__c && setCustomerRecordTypeids.contains(objLead.recordTypeId)){
                if(!String.isEmpty(strFinalITRMessage) && !String.isBlank(strFinalITRMessage) && (strFinalITRMessage==CCPM_staticConstants.strCustomerResponseForOptOut || strFinalITRMessage==CCPM_staticConstants.strCustomerResponseForOptOutSmall) && objlead.CCPM_DoubleOptOutSent__c){
                    objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                    objlead.CCPM_lastInteraction__c = system.now();
                    objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                    objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusOptedOut;
                    if(!objlead.CCPM_AutoResponseForDoubleOptOutSmsSent__c){
                        objlead.CCPM_AutoResponseForDoubleOptOutSmsSent__c = true;
                    }
                    objLead.CCPM_UpdateAccountOptOut__c =true;  //Update account
                }
                else if( !String.isEmpty(strFinalITRMessage) && !String.isBlank(strFinalITRMessage) && (strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOut || strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall)&& !objLead.CCPM_DoubleOptOutSent__c ){
                    objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                    system.debug('first else if== '+strFinalITRMessage);
                    objlead.CCPM_lastInteraction__c = system.now();
                    objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                    objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusCartDisinterested;
                    objlead.CCPM_DoubleOptOutSent__c = true;
                    objlead.CCPM_SMSOptOut__c = true; 
                }
                else{
                    system.debug('fiest else== '+strFinalITRMessage+ '== '+objlead.CCPM_isSMSResponseReceived__c+ ' = '+objlead.RecordTypeId);
                    objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                    objlead.CCPM_lastInteraction__c = system.now();
                    objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                    objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusActionRequired;
                }
            }
            //update leads for Other responses for prospects or prospect carts
            else if(objlead.CCPM_isSMSResponseReceived__c && (objlead.RecordTypeId == CCPM_staticConstants.strProspectRecordTypeID || objlead.RecordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID)){                       
                if(!String.isEmpty(strFinalITRMessage) && !String.isBlank(strFinalITRMessage) && (strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOut || strFinalITRMessage==CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall)){
                    system.debug('first else if== '+strFinalITRMessage+ '== '+objlead.CCPM_isSMSResponseReceived__c+ ' = '+objlead.RecordTypeId);
                    objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                    objlead.CCPM_lastInteraction__c = system.now();
                    objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                    objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusOptedOut;
                }
                else{
                    system.debug('fiest else== '+strFinalITRMessage+ '== '+objlead.CCPM_isSMSResponseReceived__c+ ' = '+objlead.RecordTypeId);
                    objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
                    objlead.CCPM_lastInteraction__c = system.now();
                    objlead.Status=CCPM_staticConstants.strLeadStatusResponded;
                    objlead.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusActionRequired;
                }
            }
        }
        else{
            objLead.CCPM_isSMSResponseReceived__c = true;
            objlead.CCPM_SMSResponseReceivedDateTime__c = system.now();
            objlead.CCPM_lastInteraction__c = system.now();
        }
        return objlead;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to process the customer responses
@param         list of leads and list of accounts
@return        void
*/     
    public static void updateLeadsAndAccount(list<lead> lstLeads){
        set<string> setAccountID = new set<string>();
        List<Account> lstAccounts = new List<Account>();
        try{
            if(lstLeads != null && lstLeads.size()>0){
                update lstLeads; 
            }
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','updateLeadsAndAccount','Exception thrown while updating leads','');
            lstleadhdlrLogMsg.add(log);            
        }
        for(Lead objLead : lstLeads){
            if(objLead.CCPM_UpdateAccountOptOut__c && !objLead.CCPM_Account__r.CCPM_SMSOptOut__c){
                setAccountID.add(objLead.CCPM_Account__c);
            }
        }
        if(setAccountID != null && !setAccountID.isEmpty()){
            try{
                lstAccounts = [Select id, name,CCPM_SMSOptOut__c,CCPM_SalesforceOptOutDateTime__c from Account where id IN :setAccountID For Update]; 
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','updateLeadsAndAccount','Exception thrown while querying for Accounts','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        if(lstAccounts != null && !lstAccounts.isEmpty()){
            for(Account objAccount : lstAccounts){
                objAccount.CCPM_SMSOptOut__c = true;
                objAccount.CCPM_SalesforceOptOutDateTime__c = system.now();
            }
            try{
                update lstAccounts; 
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','updateLeadsAndAccount','Exception thrown while updating accounts','');
                lstleadhdlrLogMsg.add(log);
            }
        }
    }    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to get the map of lead records
@param         set of lead IDs
@return        map<id,lead>
*/     
    public static map<id,lead> getRelatedLeads(set<String> setleadID){
        Map<id, lead> mapLead = new map<id, lead>();
        try{
            mapLead = new map<id, lead>([Select id, name,store__c,store__r.CCPM_TimeZone__c,CCPM_Type__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_previousLeadStatus__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c from lead where id IN :setleadID For Update]); 
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','getRelatedLeads','Exception thrown while querying for leads','');
            lstleadhdlrLogMsg.add(log);
        }
        return mapLead;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to get the list of store employee records
@param         set of lead IDs
@return        map<id,lead>
*/     
    public static list<CCPM_storeEmployee__c> getRelatedStoreEmployees(set<string> setLeadStoreID){
        list<CCPM_storeEmployee__c> lstManagers = new list<CCPM_storeEmployee__c>();
        if(setLeadStoreID != null && !setLeadStoreID.isEmpty()){
            try{
                lstManagers=[select CCPM_employee__c,CCPM_employee__r.firstname,CCPM_store__r.id,CCPM_employee__r.MobilePhone,CCPM_employee__r.IsActive,CCPM_role__c from CCPM_storeEmployee__c where (CCPM_role__c= :CCPM_staticConstants.strStoreManager or CCPM_role__c= :CCPM_staticConstants.strStoreAssistantManager) and CCPM_store__r.id in :setLeadStoreID and CCPM_IsActive__c = true and CCPM_employee__r.IsActive = true];
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','getRelatedLeads','Exception thrown while querying for leads','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        return lstManagers;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to get the list of store employee records
@param         set of lead IDs
@return        map<id,lead>
*/     
    public static map<id,list<CCPM_storeEmployee__c>> getMapStoreAndManagers(list<CCPM_storeEmployee__c> lstManagers) {
        map<id,list<CCPM_storeEmployee__c>> mapManagersContact = new map<id,list<CCPM_storeEmployee__c>>();
        for(CCPM_storeEmployee__c objManager:lstManagers)
        {
            if(!mapManagersContact.containsKey(objManager.CCPM_store__r.id)){
                list<CCPM_storeEmployee__c> lstAddmanagersToAssociatedStoreIds= new list<CCPM_storeEmployee__c>();
                lstAddmanagersToAssociatedStoreIds.add(objManager);
                mapManagersContact.put(objManager.CCPM_store__r.id,lstAddmanagersToAssociatedStoreIds);
            }
            else{
                list<CCPM_storeEmployee__c> lstmagers = mapManagersContact.get(objManager.CCPM_store__r.id);
                lstmagers.add(objManager);
                mapManagersContact.put(objManager.CCPM_store__r.id,lstmagers);
            }
        }
        return mapManagersContact;
    }  
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to get the map of user records
@param         set of lead IDs
@return        map<id,lead>
*/     
    public static map<id,User> getRelatedUsers(set<String> setUserID){
        map<id,User> mapOwnerFirstname = new map<id,User>();
        if(setUserID != null && !setUserID.isEmpty()){
            try{
                mapOwnerFirstname=new map<id,User>([select firstname,lastname,mobilephone from user where id in :setUserID]);
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','getRelatedLeads','Exception thrown while querying for leads','');
                lstleadhdlrLogMsg.add(log);
            } 
        }
        return mapOwnerFirstname;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to insert list of task records
@param         list of task records
@return        void
*/ 
    Public static void insertTaskRecords(list<task> lstCreateTaskCustomerResponse){
        try
        {
            //Inserting the set of tasks created after receiving Customer Response(Bulk Insert)
            if( lstCreateTaskCustomerResponse.size() > 0 && lstCreateTaskCustomerResponse != null )
            {
                insert lstCreateTaskCustomerResponse;
            }
        }
        catch(Exception e)
        {
            //Logging Exception in case of DML Exception
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','insertTaskRecords','Exception thrown while inserting task and Updating Interaction History','');
            lstleadhdlrLogMsg.add(log);
        }
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to insert list of sms message records
@param         list of task records
@return        void
*/ 
    Public static void insertSmsMessages(list<CCPM_SMSMessage__c> lstSMSMessages){
        try
        {
            //Inserting the set of tasks created after receiving Customer Response(Bulk Insert)
            if( lstSMSMessages.size() > 0 && lstSMSMessages != null )
            {
                insert lstSMSMessages;
            }
        }
        catch(Exception e)
        {
            //Logging Exception in case of DML Exception
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_ITRMessageHandler','insertSmsMessages','Exception thrown while inserting SMSMessages records for AM and Managers','');
            lstleadhdlrLogMsg.add(log);
        }
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is used to create task once the Process Customer Response SMS is sent with record tpye: Interaction History
@param         Lead Record, ITR Record created after receiving a response from Customer
@return        Task
*/      
    @TestVisible
    public static Task createInteractionTaskforCustomerResponse(lead objlead,LiveText__ITR_Message__c ITR)
    {
        // instance of task object
        Task objTask            = new task();
        //Setting the Assigned to ID
        objTask.OwnerId         = CCPM_staticConstants.strDataIntegrationUserID;
        //Setting Task Type
        objTask.Type            = CCPM_staticConstants.strTaskTypeSMS;
        //Setting Communication Direction
        objTask.CCPM_communicationDirection__c=CCPM_staticConstants.strTaskCommunicationDirection;
        //Setting the Comments field with message received from Customer
        objTask.Description     = ITR.LiveText__Message__c;
        //Setting the Record type of task to be created and associated fields
        objTask.RecordTypeId    = CCPM_staticConstants.strTaskInteractionHistoryRecordType;
        // set the priority of the task to normal
        objTask.Priority        = CCPM_staticConstants.strTaskPriorityNormal;
        // set the status of task to completed
        objTask.Status          = CCPM_staticConstants.strTaskCompleted;
        // set the subject of the task
        objTask.Subject         = CCPM_staticConstants.strTaskSubjectTextMessageReceived;
        // associate the task to lead record
        objTask.whoid           = ITR.LiveText__Lead__c;
        //Custom field for interaction bubble
        objTask.CCPM_SMSMessageType__c = CCPM_staticConstants.strMessageTypeProcessCustomerResponse;
        return objTask; 
    }
    
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method is used to create task once the Process Customer Response SMS is sent with record tpye: TO DO
@param          Lead Record, ITR Record created after receiving a response from Customer
@return         Task
*/      
    @TestVisible
    public static Task createToDoTaskforCustomerResponse(lead objlead,LiveText__ITR_Message__c ITR)
    {   
        if(objlead.CCPM_isLeadOwnerActive__c)
        {
            Task objTask            = new task();
            //Setting the Assigned to ID
            objTask.OwnerId         = objlead.OwnerId;
            //Setting Task Type
            objTask.Type            = CCPM_staticConstants.strTaskTypeSMS;    
            //Setting Communication Direction
            objTask.CCPM_communicationDirection__c  = CCPM_staticConstants.strTaskCommunicationDirection;        
            //Setting the Comments field with message received from Customer
            objTask.Description     = ITR.LiveText__Message__c;
            //Setting the Record type of task to be created and associated fields
            objTask.RecordTypeId    = CCPM_staticConstants.strTaskToDoRecordType;
            // set the date as today
            objTask.ActivityDate    = System.today();
            // set the priority of the task to high
            objTask.Priority        = CCPM_staticConstants.strTaskPriorityHigh;
            // set the status of the 
            objTask.Status          = CCPM_staticConstants.strTaskNotStarted;
            // set subject for the task
            objTask.Subject         = 'SMS for Review [' +  string.valueOf(objlead.LastName) +']';  
            
            // link the task to lead/cart
            objTask.Whoid           = objlead.id;
            
            return objTask; 
        }
        else{
            return null; 
        }
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is used to compose and add Managers SMS to SMSMessages Object
@param         Lead Record, ITR Record created after receiving a response from Customer,Manager Details, Map of users containing id and Firstname
@return        CCPM_SMSMessage__c
*/  
    @TestVisible 
    public static CCPM_SMSMessage__c SendSMSToManagers (lead objlead,CCPM_storeEmployee__c ObjManagerAssistantManager,map<id,User> mapOwnerFirstname, DateTime datTWithinBusinessHours,Set<CCPM_suppressOutboundSMS__c> setSuppressOutboundMessage)
    {   
        if(ObjManagerAssistantManager.CCPM_employee__r.MobilePhone!=null && mapOwnerFirstname!=null && mapOwnerFirstname.isEmpty()==false && (mapOwnerFirstname.get(objlead.ownerid).firstname!=null || mapOwnerFirstname.get(objlead.ownerid).lastname!=null))
        {
            CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
            //Populating the fields required to insert into the SMSMessage Object
            objSmsMessage.CCPM_leadRecord__c = objlead.Id;
            objSmsMessage.CCPM_LiveTextNumber__c = CCPM_staticConstants.strLivetextPhoneNumber;
            if(setSuppressOutboundMessage != null && !setSuppressOutboundMessage.isEmpty()){
                For(CCPM_suppressOutboundSMS__c objSuppressOutboundMessage : setSuppressOutboundMessage){
                    //Check for Market/Territory/District
                    if(objSuppressOutboundMessage.IsActive__c && objlead.CCPM_storeDistrict__c!= null && objSuppressOutboundMessage.District__c != null && objSuppressOutboundMessage.District__c == objlead.CCPM_storeDistrict__c){
                        if(objlead.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objlead.CCPM_storeTerritory__c
                           && objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                               objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                               objSmsMessage.CCPM_removedByLocationSetting__c = True;
                           }
                    }
                    else if(objSuppressOutboundMessage.IsActive__c && objSuppressOutboundMessage.District__c == null){
                        if(objlead.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objlead.CCPM_storeTerritory__c){
                            if(objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                                objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                                objSmsMessage.CCPM_removedByLocationSetting__c = True;
                            }
                        }
                        else if(objSuppressOutboundMessage.Territory__c == null){
                            if(objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                                objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                                objSmsMessage.CCPM_removedByLocationSetting__c = True;
                            }
                        }
                    }
                }
            }
            if(objSmsMessage.CCPM_MessageStatus__c != CCPM_staticConstants.strMessageStatusRemoved){
                objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusQueued;
            }
            objSmsMessage.CCPM_ScheduleDateTime__c = datTWithinBusinessHours;
            objSmsMessage.CCPM_toPhoneNumber__c = ObjManagerAssistantManager.CCPM_employee__r.MobilePhone;
            objSmsMessage.CCPM_SMSFailCounter__c = '0';
            objSmsMessage.CCPM_communicationDirection__c=CCPM_StaticConstants.strTaskCommunicationOutbound;
            objSmsMessage.CCPM_internalCommunication__c=True;
            objSmsMessage.CCPM_sentTo__c=ObjManagerAssistantManager.CCPM_employee__c;
            
            //Setting the reference string and Message Type for SMS to Managers/Assistant Managers
            if(objManagerAssistantManager.CCPM_role__c==CCPM_staticConstants.strStoreManager)
            {
                objSmsMessage.CCPM_referenceId__c       = CCPM_staticConstants.strStoreManager; 
                objSmsMessage.CCPM_messageType__c       = CCPM_staticConstants.strMessageTypeManagers;
            }
            else
            {
                objSmsMessage.CCPM_referenceId__c       = CCPM_staticConstants.strStoreAssistantManager;
                objSmsMessage.CCPM_messageType__c       = CCPM_staticConstants.strMessageTypeAssistantManagers;
            }
            if(mapOwnerFirstname.get(objlead.ownerid).firstname!=null && mapOwnerFirstname.get(objlead.ownerid).lastname!=null)
            {
                objSmsMessage.CCPM_message__c            = 'Hi '+ObjManagerAssistantManager.CCPM_employee__r.firstname+', '+Objlead.lastname+' has responded to ' + mapOwnerFirstname.get(objlead.ownerid).firstname +' '+ mapOwnerFirstname.get(objlead.ownerid).lastname+ '. To review the lead login to Salesforce and view the \'Leads Requiring Action\' report.'; 
            }
            else if(mapOwnerFirstname.get(objlead.ownerid).firstname==null && mapOwnerFirstname.get(objlead.ownerid).lastname!=null)
            {
                objSmsMessage.CCPM_message__c            = 'Hi '+ObjManagerAssistantManager.CCPM_employee__r.firstname+', '+Objlead.lastname+' has responded to ' +  mapOwnerFirstname.get(objlead.ownerid).lastname+ '. To review the lead login to Salesforce and view the \'Leads Requiring Action\' report.';  
            }
            else{
                objSmsMessage.CCPM_message__c           = 'Hi '+ObjManagerAssistantManager.CCPM_employee__r.firstname+', '+Objlead.lastname+' has responded to ' +  mapOwnerFirstname.get(objlead.ownerid).firstname+ '. To review the lead login to Salesforce and view the \'Leads Requiring Action\' report.';  
            }
            //Setting the SMS body
            
            return objSmsMessage;
        }
        else{
            return null;
        }
    }    
}