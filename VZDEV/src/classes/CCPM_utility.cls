/**
*@name          CCPM_utility
*@author        Sriraman Sridharan (Deloitte)
*@date          09/21/2017
@description    The Utility class contains all the variables and the methods that will be referenced multiple times in handler classes
@testClass      CCPM_utilityTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          09/26/2017              Original Version

*/
public without sharing class CCPM_utility {
    public static BusinessHours objDefaultBusinessHour;
    public static Map<String, BusinessHours> mapBusinessHoursNameRec = mapGetBusinessHours();
    // Adding group from leadhandlerAssignOwnership (Solving Defect Too many SOQL query)
    public static Map<String,Group> mapCopyDistrictAndGroup;
    public static Set<String> setleadEventToExclude = getSetFromString(Label.CCPM_LeadEventToExclude, ',');
    public static Set<String> setleadOpenStatus = getSetFromString(Label.CCPM_leadOpenStatusValues, ',');
    public static Set<String> setleadStatusTOExclude = getSetFromString(Label.CCPM_SMSExcludeStatus, ',');
    public static Set<String> setCartTypeValues = getSetFromString(Label.CCPM_cartTypeValues, ',');
    public static Set<String> setOpenLeadStatus = getSetFromString(Label.CCPM_openLeadStatus, ',');
    public static list<String> lstTaskStatValues = getListFromString(Label.CCPM_taskStatusValues,',');
    public static list<String> lstCallNowProfiles = getListFromString(Label.CCPM_callNowProfiles,',');
    public static list<String> lstCallNowLeadStatus = getListFromString(Label.CCPM_callNowLeadStatus,',');
    public static list<String> lstCallNowLeadSubStatus = getListFromString(Label.CCPM_callNowLeadSubStatus,',');
    public static Boolean isCurrentUserTelesalesUser = isCurrentUserTelesalesUser();
    public static Boolean isCurrentUserSalesRep = isCurrentUserSalesRep();
    public static set<String> setAsciiSpecialString = new  set<String>{'8220','8221', '8216', '8217', '34' ,'39'};
        public static set<String> setsmsTypeOnTask = getSetFromString(Label.CCPM_SMSTypesOnTask, ',');
    public static Set<String> setleadClosedStatus = getSetFromString(Label.CCPM_leadClosedStatus, ',');
    public static Set<String> setLeadOpenStatusWithoutNew = getSetFromString(Label.CCPM_leadOpenStatusWithoutNew, ',');
    public static Map<String, CCPM_suppressOutboundSMS__c>  mapSuppressOutboundMessageGetAll = CCPM_suppressOutboundSMS__c.getAll();
    public static CCPM_testSettings__c csTestSetting    = CCPM_testSettings__c.getInstance(UserInfo.getUserId());
    public static String strLeadProspectRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId();
    public static String strLeadProspectCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId();
    public static String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
    //public static Map<String, Map<String, List<CCPM_journeyMessage__c>>> mapTypeEventNameLstJMRec = getEventlstJourneyMessageMap();
    public static Set<String> setSMSMessageTypeforDismissedLead = getSetFromString(Label.CCPM_MessageTypeforDismissedLead, ',');
    public static Boolean isNoActiveManager = false;
    public static Set<String> setRectTypestoExpire = getSetFromString(Label.CCPM_setRectTypestoExpire, ',');
    public static Datetime datTSysNowForEvent = CCPM_utility.csTestSetting.CCPM_sytemNow__c == null ? System.now() : CCPM_utility.csTestSetting.CCPM_sytemNow__c;
    public static Boolean isRunningInASandbox = URL.getSalesforceBaseUrl().toExternalForm() != Label.CCPM_PRODUrl ? True : False;
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to create list of business hours
@param         none
@return        List<BusinessHours>
*/     
    public static List<BusinessHours> getBusinessHours(){
        List<BusinessHours> lstBusinessHours = [Select Id,name,IsDefault From BusinessHours Where IsActive = true];
        for(BusinessHours bhrs : lstBusinessHours){
            if(bhrs.IsDefault){
                objDefaultBusinessHour = bhrs;
                break;
            }
        }
        return lstBusinessHours;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to check if the lead is a an abandoned visit cart
@param         none
@return        List<BusinessHours>
*/     
    public static Boolean IsMergedLeadAbandonedVisit(Lead objLead){
        if(objLead.CCPM_informaticaMergeLeadType__c != null && objLead.CCPM_informaticaMergeLeadType__c == Label.CCPM_AbandonedVisitLead){
            return True;
        }
        else return False; 
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to check if the lead is a an abandoned visit cart
@param         none
@return        List<BusinessHours>
*/     
    public static Boolean IsMergedQuoteLead(Lead objLead){
        if(objLead.CCPM_informaticaMergeLeadType__c != null && objLead.CCPM_informaticaMergeLeadType__c == Label.CCPM_CustomerQuotes){
            return True;
        }
        else return False; 
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to check if the lead is a an abandoned visit cart
@param         none
@return        List<BusinessHours>
*/     
    public static Boolean IsCampaignLead(Lead objLead){
        if(objLead.CCPM_informaticaMergeLeadType__c != null && objLead.CCPM_informaticaMergeLeadType__c == Label.CCPM_CustomerCampaign){
            return True;
        }
        else return False; 
    }
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method is targeted to create Map of timezone string and business hours. It will also determine the default businesshour 
@param         none
@return        Map<String, BusinessHours>
*/    
    public static Map<String, BusinessHours> mapGetBusinessHours(){
        
        Map<String, BusinessHours> mapBussHrsNameRec = new Map<String, BusinessHours>();
        for(BusinessHours bhrs : [Select Id,name,IsDefault,TimeZoneSidkey From BusinessHours Where IsActive = true]){
            if(bhrs.IsDefault){
                objDefaultBusinessHour = bhrs;
                mapBussHrsNameRec.put(Label.CCPM_defaultLabel, objDefaultBusinessHour);
            }
            String timeZone = bhrs.Name.split('-')[1].trim();
            mapBussHrsNameRec.put(timeZone, bhrs);
        }
        return mapBussHrsNameRec;
    }
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns all the ids of the queues in the org. 
@param         none
@return        Set<String>
*/  
    public static Set<String> populateQueueIds(){
        Set<String> setQueueIDs = new Set<String>();
        for(Group objGrp :[Select id, name from Group where Type = 'Queue']){
            setQueueIDs.add(objGrp.id);
        }
        return setQueueIDs;
    }      
    
    /**
@author         Sriraman Sridharan
@description    This method retrieves the business hours by retrirving the business hours defined
at the org level
@param          list of new leads
@return         Void(None)
*/  
    public static DateTime calculateTimeWithInBusinessHours(BusinessHours bh, Datetime inputDatetime) {
        // retrieves list of business hours which are active
        // if date/time is within the business hours, if yes then no change 
        if(BusinessHours.isWithin(bh.id,inputDatetime)){
            return inputDatetime;
        }
        // if date/time is outside the business hours, then get the next date/time
        else{
            Datetime nextstart;
            nextStart = BusinessHours.nextStartDate(bh.id, inputDatetime); 
            return nextStart;
        }
    }
    /**
@author         Sriraman Sridharan
@description    This method retrieves the words from the data dictionary
@param          none
@return         Set<String>
*/  
    public static set<String> getStringFromDataDictionary() {
        List<CCPM_dataDictionary__c> objDataDictionary = new List<CCPM_dataDictionary__c>();
        set<String> strWordsFromDataDictionary = new set<String>();
        try{
            objDataDictionary  = [select id,CCPM_StringForexclusion__c,CCPM_IsActive__c from CCPM_dataDictionary__c where CCPM_IsActive__c = true];
        }
        Catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_utility','getStringFromDataDictionary','Exception thrown while querying for static resource',true); 
        }
        if(objDataDictionary!=null){
            //String contents = objDataDictionary.body.toString();
            for(CCPM_dataDictionary__c objDD : objDataDictionary) {
                if(objDD.CCPM_StringForexclusion__c != null){
                    strWordsFromDataDictionary.add(objDD.CCPM_StringForexclusion__c);
                }
            }
        }
        return strWordsFromDataDictionary;
    }
    
    
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns Set when provided with a label and a seperator 
@param         String, String 
@return        Set<String>
*/
    public Static Set<String> getSetFromString(String strCustomLabel, String strSeperator){
        
        Set<String> setToReturn = new Set<String>();
        if(strCustomLabel != null){
            if(strCustomLabel.contains(strSeperator)){
                for(String strValue : strCustomLabel.split(strSeperator)){
                    setToReturn.add(strValue);
                }
            }
            else{
                setToReturn.add(strCustomLabel);
            }
        }
        return setToReturn;
    }
    /**
@author        Paras Shah (Deloitte)
@description   This method returns List when provided with a label and a seperator 
@param         String, String 
@return        Set<String>
*/
    public Static List<String> getListFromString(String strCustomLabel, String strSeperator){
        
        List<String> lstToReturn = new List<String>();
        if(strCustomLabel != null){
            if(strCustomLabel.contains(strSeperator)){
                for(String strValue : strCustomLabel.split(strSeperator)){
                    lstToReturn.add(strValue);
                }
            }
            else{
                lstToReturn.add(strCustomLabel);
            }
        }
        return lstToReturn;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns a set with lead status to exclude 
@param         none
@return        Map<String, BusinessHours>
*/
    
    
    public static Set<String> setGetSMSStatusTOExclude(){
        Set<String> setStatus = new Set<String>();
        for(String strStatus : Label.CCPM_SMSExcludeStatus.split(',')){
            setStatus.add(strStatus);
        }
        return setStatus;
    }
    
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns true if the current user is telesales user 
@param         none
@return        Boolean
*/  
    @AuraEnabled
    public static Boolean isCurrentUserTelesalesUser(){
        Boolean boolIsTeleSalesUser = false;
        Integer objstrEmpCount = 0;
        try{
            objstrEmpCount = [Select count() from CCPM_storeEmployee__c Where CCPM_storeSource__c =: Label.CCPM_telesalesChannelName and CCPM_employee__c =: UserInfo.getUserId() and CCPM_IsActive__c=true];
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }        
        if(objstrEmpCount != 0){
            boolIsTeleSalesUser = true;
        }
        system.debug('***boolIsTeleSalesUser***'+boolIsTeleSalesUser);
        return boolIsTeleSalesUser;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns true if the current user is an active sales rep from an active store 
@param         none
@return        Boolean
*/  
    public static Boolean isCurrentUserSalesRep(){
        Boolean boolIsSalesRep = false;
        Integer objstrEmpCount = [Select count() from CCPM_storeEmployee__c Where CCPM_role__c = 'Sales Rep' AND CCPM_employee__c =: UserInfo.getUserId() and CCPM_IsActive__c=true AND CCPM_isStoreActive__c = true];
        System.debug('******objstrEmpCount*********'+objstrEmpCount);
        if(objstrEmpCount != 0){
            boolIsSalesRep = true;
        }
        
        return boolIsSalesRep;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns true if the lead is a manual lead or prospect. 
@param         none
@return        Boolean
*/  
    public static Boolean isManualLeadOrProspect(Lead objLead){
        boolean isManualOrPros = false; 
        if((objLead.recordTypeId == strLeadCustomerCartRT && objlead.CCPM_Type__c == Label.CCPM_leadTypeManualLead)|| (objLead.recordTypeId == strLeadProspectRT)){
            isManualOrPros = true; 
            System.debug('POS Change->'+isManualOrPros);
        }
        return isManualOrPros;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@Modification  Moved to utility Class By Bharath Ammanamanchi(Deloitte) 
@description   This method creates records for sms messages object when a lead/prospect record is created.
@param         list of new leads
@return        Void(None)
*/ 
    public static CCPM_SMSMessage__c createRecordsForSmsMessageObject(Lead objlead, String strMessage, String strToPhone, String strMessageType, String strCommunicationDirection,datetime datTScheduleTime, String strLiveTextPhoneNumber){
        CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
        objSmsMessage.CCPM_leadRecord__c = objlead.Id;
        objSmsMessage.CCPM_LiveTextNumber__c = strLivetextPhoneNumber;
        objSmsMessage.CCPM_message__c = strMessage; 
        objSmsMessage.CCPM_dynamicLeadOwnerName__c=objlead.CCPM_ownerFirstName__c;
        Boolean boolisRemoved = false;
        Map<String, CCPM_suppressOutboundSMS__c> mapSuppressOutboundMessage = mapSuppressOutboundMessageGetAll;
        if(mapSuppressOutboundMessage != null && !mapSuppressOutboundMessage.isEmpty()){
            For(string strkey : mapSuppressOutboundMessage.keySet()){
                CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = new CCPM_suppressOutboundSMS__c();
                objSuppressOutboundMessage = mapSuppressOutboundMessage.get(strkey);
                //Check for Market/Territory/District
                if(objSuppressOutboundMessage.IsActive__c && objlead.CCPM_storeDistrict__c!= null && objSuppressOutboundMessage.District__c != null && objSuppressOutboundMessage.District__c == objlead.CCPM_storeDistrict__c){
                    if(objlead.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objlead.CCPM_storeTerritory__c
                       && objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                           objSmsMessage.CCPM_MessageStatus__c = Label.CCPM_SMSStatusRemoved;
                           objSmsMessage.CCPM_removedByLocationSetting__c = True;
                           // system.debug('@@@Inside District');
                       }
                }
                else if(objSuppressOutboundMessage.IsActive__c && objSuppressOutboundMessage.District__c == null){
                    if(objlead.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objlead.CCPM_storeTerritory__c){
                        if(objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                            objSmsMessage.CCPM_MessageStatus__c = Label.CCPM_SMSStatusRemoved;
                            objSmsMessage.CCPM_removedByLocationSetting__c = True;
                            // system.debug('@@@Inside Territory');
                        }
                    }
                    else if(objSuppressOutboundMessage.Territory__c == null){
                        if(objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                            objSmsMessage.CCPM_MessageStatus__c = Label.CCPM_SMSStatusRemoved;
                            objSmsMessage.CCPM_removedByLocationSetting__c = True;
                            //system.debug('@@@Inside Market');
                        }
                    }
                }
            }
        }
        if(objSmsMessage.CCPM_MessageStatus__c != Label.CCPM_SMSStatusRemoved){
            objSmsMessage.CCPM_MessageStatus__c = Label.CCPM_messageStatusQueued;
        }
        if(String.isNotBlank(objlead.Store__c+'')){
            if(String.isNotBlank(objlead.CCPM_storeName__c)){
                objSMSMessage.CCPM_dynamicStoreName__c=objlead.CCPM_storeName__c;
            }
            if(String.isNotBlank(objlead.CCPM_storeRecommendedHours__c)){
                objSMSMessage.CCPM_dynamicStoreRecommendedHrs__c=objlead.CCPM_storeRecommendedHours__c;
            }
        }
        if(String.isNotBlank(objlead.CCPM_ownerEcode__c)){
            objSMSMessage.CCPM_dynamicECODE__c=objlead.CCPM_ownerEcode__c;
        }
        else if(String.isNotBlank(objlead.CCPM_storeEcode__c)){
            objSMSMessage.CCPM_dynamicECODE__c=objlead.CCPM_storeEcode__c;
        }     
        objSmsMessage.CCPM_messageType__c = strMessageType;
        objSmsMessage.CCPM_referenceId__c = strMessageType +objlead.id;
        objSmsMessage.CCPM_ScheduleDateTime__c = datTScheduleTime;
        objSmsMessage.CCPM_toPhoneNumber__c = strToPhone;
        objSmsMessage.CCPM_SMSFailCounter__c = '0';
        objSmsMessage.CCPM_communicationDirection__c= strCommunicationDirection;
        return objSmsMessage;
    }
    
    
    
    /********************************************************************************************************
* @author       Bharath Ammanamanchi
* @date         2017-10-25
* @description  This methods logs a message by providing as input the list of all the possible parameters
*               This methods provides the most extensive options
* @param        logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
* @param        source (String): the source of the message (Interface name, Functionality name, ...)
* @param        sourceFunction (String): the calling method (ClassName.MethodName)  
* @param        message (String): the message to log    
* @param        strackTrace (String): The stack trace of the exception 
* @return       LOG_LogMessage__c: the log message that has been created
*********************************************************************************************************/
    public static LOG_LogMessage__c logMessage(String logLevel, String source, String sourceFunction, String message, String strackTrace) 
    {
        LOG_LogMessage__c log = new LOG_LogMessage__c();
        
        log.CCPM_source__c = source;
        log.CCPM_sourceFunction__c = sourceFunction;
        log.CCPM_stackTrace__c = strackTrace;
        log.CCPM_message__c = message; 
        log.CCPM_debugLevel__c = logLevel;
        return  log;     
    }
    
    /********************************************************************************************************
* @author       Bharath Ammanamanchi
* @date         2017-10-25
* @description  This methods logs a message by providing as input the list of all the possible parameters
*               This methods provides the most extensive options
* @param        logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
* @param        source (String): the source of the message (Interface name, Functionality name, ...)
* @param        sourceFunction (String): the calling method (ClassName.MethodName)  
* @param        message (String): the message to log    
* @param        strackTrace (String): The stack trace of the exception 
* @return       LOG_LogMessage__c: the log message that has been created
*********************************************************************************************************/
    public static LOG_LogMessage__c logMessage(Exception exc, String logLevel, String source, String sourceFunction, String message, String strackTrace) 
    {
        if(String.isNotBlank(message)){
            message = 'Message: ' + message + '\n';
            
        }
        message += 'Exception Type: ' + exc.getTypeName() + '\nException Line Nr: ' + exc.getLineNumber();
        message += '\nException Message: ' + exc.getMessage();
        LOG_LogMessage__c log = new LOG_LogMessage__c();
        
        log.CCPM_source__c = source;
        log.CCPM_sourceFunction__c = sourceFunction;
        log.CCPM_stackTrace__c = strackTrace;
        log.CCPM_message__c = message; 
        log.CCPM_debugLevel__c = logLevel;
        return  log;     
    }
    
    public static CCPM_storeEmployee__c objCurrUserStoreEmp = getUserStoreEmpRec(UserInfo.getUserId());
    
    public static CCPM_storeEmployee__c getUserStoreEmpRec(String strUserId){
        List<CCPM_storeEmployee__c> objStrEmp = new List<CCPM_storeEmployee__c>();
        if(String.isNotBlank(strUserId)){
            try{
                objStrEmp = [Select id, CCPM_Store__r.CCPM_zipcode__c, CCPM_Store__r.CCPM_street__c, CCPM_Store__r.CCPM_state__c, 
                             CCPM_Store__r.CCPM_phone__c, CCPM_Store__r.CCPM_city__c, CCPM_Store__r.Name, CCPM_Store__r.CCPM_market__c,
                             CCPM_Store__r.CCPM_district__c, CCPM_Store__r.CCPM_territory__c, CCPM_Store__r.CCPM_source__c, 
                             CCPM_Store__r.CCPM_TimeZone__c, CCPM_Store__c 
                             From CCPM_storeEmployee__c WHERE CCPM_employee__c = : strUserId AND CCPM_IsActive__c = true limit 1] ;   
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_utility','getUserStoreEmpRec','Exception thrown while querying for Store Employee',true); 
            }
        }
        if(CCPM_Collection.isNotNullEmpty(objStrEmp)){
            return objStrEmp[0]; 
        }
        else return null;
    }
    
    public static Map<String, String> mapMDTProspectSMSBody = new Map<String, String>();
    public static Map<String, String> mapMDTCustCartSMSBody = new Map<String, String>();
    public static List<CCPM_promoMessage__mdt> lstPreDefinedSMSRecords = getMdtPreDefinedSMSRecords();
    public static List<CCPM_promoMessage__mdt> getMdtPreDefinedSMSRecords(){
        List<CCPM_promoMessage__mdt> lstPromoMsg = [Select MasterLabel, DeveloperName, CCPM_dispalyOrignialMessage__c, 
                                                    CCPM_finalPreDefinedResponse__c, CCPM_firstPreDefinedResponse__c,
                                                    CCPM_MessageContentForLeads__c, CCPM_messageContentForProspects__c
                                                    From CCPM_promoMessage__mdt Order By MasterLabel ASC];
        for(CCPM_promoMessage__mdt mdtPM : lstPromoMsg){
            mapMDTProspectSMSBody.put(mdtPM.DeveloperName, checkForDynamicContentInMsg('', mdtPM.CCPM_messageContentForProspects__c));
            mapMDTCustCartSMSBody.put(mdtPM.DeveloperName, checkForDynamicContentInMsg('(FreeVzMsg)', mdtPM.CCPM_MessageContentForLeads__c));   
            
        }
        return lstPromoMsg;
    }
    
    public static String checkForDynamicContentInMsg(String suffix, String strMsgContent){
        String strMessage = strMsgContent;
        if(objCurrUserStoreEmp!= null && String.isNotBlank(strMessage)){
            if(strMsgContent == 'Yes! Our Store Address Is:-'){
                String strStreet = objCurrUserStoreEmp.CCPM_Store__r.CCPM_street__c != null ? objCurrUserStoreEmp.CCPM_Store__r.CCPM_street__c : '';
                String strCity = objCurrUserStoreEmp.CCPM_Store__r.CCPM_city__c != null ? objCurrUserStoreEmp.CCPM_Store__r.CCPM_city__c : '';
                String strZipCode = objCurrUserStoreEmp.CCPM_Store__r.CCPM_zipcode__c != null ? objCurrUserStoreEmp.CCPM_Store__r.CCPM_zipcode__c : '';
                strMessage = strMsgContent + ' '+strStreet + ' ' +  strCity + ' ' + strZipCode + '.'+ suffix;          
            }
            if(strMsgContent == 'Please call the store to discuss further'){
                String strPhone = objCurrUserStoreEmp.CCPM_Store__r.CCPM_phone__c != null ? objCurrUserStoreEmp.CCPM_Store__r.CCPM_phone__c : '';
                strMessage = strMsgContent +' '+strPhone + '.'+ suffix;
            }
        }
        return strMessage;
    }
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
Sriraman -> Moved this to Utility class.
*@description   This method is targeted to handle the operations on lead records after updating/Inserting to Set Sharing Rules
*@param         Id of the Record that needs Sharing Settings, Id of the User who is given the Write Access on the record
*@return        LeadShare Record
**/     
    public static leadshare apexShareEditAccess(id idRecordId, id idUserOrGroupId){
        
        // Create new sharing object for Cart
        leadshare CCPM_leadShr      = new leadshare();
        
        // Set the ID of record being shared.
        CCPM_leadShr.leadId         = idRecordId;
        
        // Set the ID of user or group being granted access.
        CCPM_leadShr.UserOrGroupId  = idUserOrGroupId;
        
        // Set the access level.
        CCPM_leadShr.leadAccessLevel= 'Edit';
        
        // Database.SaveResult sr   = Database.insert(CCPM_leadShr,false);
        // Returning the leadshare created
        return CCPM_leadShr;
    }
    /**
@author         Sriraman Sridharan
@description    This method retrieves the business hours by retrirving the business hours defined
at the org level
@param          list of new leads
@return         Void(None)
*/  
    public static DateTime calculateTimeToTriggerSMSWithInBusinessHours(BusinessHours bh, Datetime inputDatetime) {
        if(bh != null && inputDatetime != null){
            if(BusinessHours.isWithin(bh.id,inputDatetime)){
                return inputDatetime;
            }
            else{
                Datetime nextstart;
                nextStart = BusinessHours.nextStartDate(bh.id, inputDatetime); 
                return nextStart;
            }
        }
        else{
            return null;
        }
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns map of Profile Name with Profile Id 
@param         none
@return        Boolean
*/  
    public static Map<String, String> getProfileNameIDMap(){
        Map<String, String> mapProfileNameId = new Map<String, String>();
        
        for(Profile objp : [Select id, Name from Profile]){
            mapProfileNameId.put(objp.Name, objp.Id);
        }
        return mapProfileNameId;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns a map of all the names and ids of the queues in the org. 
@param         none
@return        Map<String, String>
*/  
    public static Map<String, String> populateQueueNameIds(){
        Map<String, String> mapQueueNameIDs = new Map<String, String>();
        for(Group objGrp :[Select id, name from Group where Type = 'Queue']){
            mapQueueNameIDs.put(objGrp.Name, objGrp.id);
        }
        return mapQueueNameIDs;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns a map of all the names and ids of the queues in the org. 
@param         none
@return        Map<String, String>
*/  
    public static BusinessHours getBusinessHrForLead(Lead objLead){
        BusinessHours bhrs = null;
        if(CCPM_Collection.isNotNullEmpty(mapBusinessHoursNameRec)){
            if(String.isNotBlank(Label.CCPM_defaultLabel) && mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel) != null){
                bhrs = mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel);
            }
            if(String.isNotBlank(objLead.Store__r.CCPM_timezone__c) && mapBusinessHoursNameRec.get(objLead.Store__r.CCPM_timezone__c) != null){     
                bhrs = mapBusinessHoursNameRec.get(objLead.Store__r.CCPM_timezone__c);
            }   
        }
        return bhrs;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns true if the field value is provided is not null and the value provided is not null and the values are equal. 
@param         String, String
@return        Boolean
*/ 
    public static Boolean checkField(String strFieldValue, String strValueToCheck){
        boolean boolReturnValue = false;
        if(String.isNotBlank(strFieldValue) && String.isNotBlank(strValueToCheck) && strFieldValue == strValueToCheck){
            boolReturnValue = true;
        } 
        return boolReturnValue;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns task record of type Interaction History. 
@param         String, String
@return        Boolean
*/ 
    public static Task createTaskRecordFromLead(Lead objLead, String strSMSMessage, String strMessageType, String strRecordTypeName){
        String recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
        Task objTask            = new Task(OwnerId= objLead.ownerId, Type = 'SMS', CCPM_communicationDirection__c=Label.CCPM_taskCommunicationOutbound, Description = strSMSMessage,
                                           RecordTypeId = recordTypeId, Priority = Label.CCPM_taskPriorityNormal, Status = Label.CCPM_taskCompleted, 
                                           Subject = Label.CCPM_taskSubjectTextMessageSent, CCPM_SMSMessageType__c = strMessageType, whoid = objLead.Id);
        
        return objTask;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to return business hrs 
@param         Lead
@return        BusinessHours
*/
    public static BusinessHours getBusinessBrsForLead(Lead objlead){
        BusinessHours bhrs = null;
        if(CCPM_Collection.isNotNullEmpty(mapBusinessHoursNameRec)){
            if(String.isNotBlank(Label.CCPM_defaultLabel) && mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel) != null){
                bhrs = mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel);
            }
            if(String.isNotBlank(objlead.CCPM_StoreTimeZone__c) && mapBusinessHoursNameRec.get(objlead.CCPM_StoreTimeZone__c) != null){
                bhrs = mapBusinessHoursNameRec.get(objlead.CCPM_StoreTimeZone__c);
            }
        }
        return bhrs;
    }
    
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create map of all the event type Journey messages
@param         N/A
@return        void
*/
    public static Map<String, Map<String, List<CCPM_journeyMessage__c>>> getEventlstJourneyMessageMap(){
        Map<String, Map<String, List<CCPM_journeyMessage__c>>> mapTypeEventNameLstJMRec = new Map<String, Map<String, List<CCPM_journeyMessage__c>>>();
        String strRecTypeId = Schema.SObjectType.CCPM_journeyMessage__c.getRecordTypeInfosByName().get('Event Message').getRecordTypeId();
        mapTypeEventNameLstJMRec.put('CalcualteSMSFollowupMap', new Map<String, List<CCPM_journeyMessage__c>>());
        mapTypeEventNameLstJMRec.put('EventSMSMap', new Map<String, List<CCPM_journeyMessage__c>>());
        for(CCPM_journeyMessage__c objJM : [Select id, CCPM_prospectMessage__c, CCPM_eventType__c, CCPM_eventStartDate__c, CCPM_eventSMSFollowUpStartDate__c, 
                                            CCPM_eventSMSFollowUpEndDate__c, CCPM_eventEndDate__c, CCPM_customerMessage__c, CCPM_calculateSMSFollowup__c,
                                            CCPM_startDateTime__c, CCPM_endDateTime__c, CCPM_overrideEcode__c  
                                            From CCPM_journeyMessage__c Where CCPM_isActive__c = true AND RecordTYpeId=:strRecTypeId]){
                                                if(objJM.CCPM_calculateSMSFollowup__c == true){
                                                    mapTypeEventNameLstJMRec.get('CalcualteSMSFollowupMap').put(objJM.CCPM_eventType__c, new List<CCPM_journeyMessage__c>{objJM});
                                                }
                                                if(objJM.CCPM_eventSMSFollowUpStartDate__c != null){
                                                    objJM.CCPM_startDateTime__c = CCPM_datetimeConversionClass.datetimeConversion(objJm.CCPM_eventSMSFollowUpStartDate__c,Userinfo.getTimeZone()+'');
                                                }
                                                if(objJM.CCPM_eventSMSFollowUpEndDate__c != null){
                                                    objJM.CCPM_endDateTime__c = CCPM_datetimeConversionClass.datetimeConversion(objJm.CCPM_eventSMSFollowUpEndDate__c,Userinfo.getTimeZone()+'');
                                                }
                                                if(mapTypeEventNameLstJMRec.get('EventSMSMap').containsKey(objJM.CCPM_eventType__c)){
                                                    mapTypeEventNameLstJMRec.get('EventSMSMap').get(objJM.CCPM_eventType__c).add(objJM);
                                                }
                                                else{
                                                    mapTypeEventNameLstJMRec.get('EventSMSMap').put(objJM.CCPM_eventType__c, new List<CCPM_journeyMessage__c>{objJM});
                                                }
                                                
                                            }
        return mapTypeEventNameLstJMRec;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create map of all the event type Journey messages
@param         N/A
@return        void

public static Map<String, Map<String, List<CCPM_journeyMessage__c>>> getEventlstJourneyMessageMap(){
Map<String, Map<String, List<CCPM_journeyMessage__c>>> mapTypeEventNameLstJMRec = new Map<String, Map<String, List<CCPM_journeyMessage__c>>>();
String strRecTypeId = Schema.SObjectType.CCPM_smsTemplate__c.getRecordTypeInfosByName().get('Event Message Template').getRecordTypeId();
}    */
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to return Datetime in GMT for the datetime value which is provided as string in the new timezone
@param         String, String
@return        datetime
*/
    public static datetime getDtTimeForTimeZone(string strInConvertDate,string strInTimeZone){
        DateTime dtmInputTimeInGMT = DateTime.valueofGmt(strInConvertDate);
        TimeZone tzInputTimeZone = TimeZone.getTimeZone(strInTimeZone);
        integer intOffsetToInputTimeZone = tzInputTimeZone.getOffset(dtmInputTimeInGMT);
        DateTime dtmCorrectedDateTime = DateTime.valueOf(dtmInputTimeInGMT.addMinutes(intOffsetToInputTimeZone* -1 / (1000 * 60)));
        return dtmCorrectedDateTime;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to return System.now in the timezone provided
@param         String
@return        datetime
*/    
    public static datetime getNowInTimeZone(string strInTimeZone){
        TimeZone tzInputTimeZone = TimeZone.getTimeZone(strInTimeZone);
        Integer intOffsetToInputTimeZone = tzInputTimeZone.getOffset(datTSysNowForEvent);
        TimeZone tzCurrentUserTimeZone = UserInfo.getTimeZone();
        integer intOffsetToUserTimeZone = tzCurrentUserTimeZone.getOffset(datTSysNowForEvent);
        integer intCorrection = intOffsetToInputTimeZone - intOffsetToUserTimeZone;
        DateTime dtmCorrectedDateTime = DateTime.valueOf(datTSysNowForEvent.addMinutes(intCorrection / (1000 * 60)));
        return dtmCorrectedDateTime;
    }
    
    /**
@author       Anupreeta Chakraborty (Deloitte)
@description  Method is called for setting map for recordtypes
@param        void
@return       Map<String,String>
*/
    
    public static Map<String, String> mapRecordTypes(){
        Map<String, String> mapRecType = new Map<String,String>();
        for(CCPM_Lead_Record_type_setting__mdt rectype : [select label, CCPM_Record_Type__c from CCPM_Lead_Record_type_setting__mdt]){
            mapRecType.put(rectype.label, rectype.CCPM_Record_Type__c);
        }
        return mapRecType;
    } 
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to return Maps required for SMS Framework including Event Framework From Campaign, Segmentation and SMS Template.
These maps will be used to calculate the Actual SMS DateTime, Followup SMS Date Time and Create SMS for initial Messages, Followup Messages and Event Messages
@param         N/A
@return        Map<String, Map<String, List<CCPM_segmentation__c>>>
*/    
    public static Map<String, Map<String, List<CCPM_segmentation__c>>> populateSMSFWRKMaps(){
        Map<String, Map<String, List<CCPM_segmentation__c>>> mapSMSFWRK = new Map<String, Map<String, List<CCPM_segmentation__c>>>();
        mapSMSFWRK.put('EventFwrkActualSMSDtTimeMap', new Map<String, List<CCPM_segmentation__c>>());
        mapSMSFWRK.put('EventFwrkMap', new Map<String, List<CCPM_segmentation__c>>());
        mapSMSFWRK.put('SMSFwrkMap', new Map<String, List<CCPM_segmentation__c>>());
        String strSegQuery = 'Select CreatedDate, id, CCPM_campaign__c, CCPM_channels__c, CCPM_markets__c, CCPM_territories__c, CCPM_districts1__c, CCPM_districts2__c, CCPM_districts3__c,'+
            'CCPM_campaign__r.Name, CCPM_campaign__r.CCPM_eventStartDate__c, CCPM_campaign__r.CCPM_eventEndDate__c, CCPM_campaign__r.CCPM_recordTypeName__c,'+
            'CCPM_campaign__r.CCPM_eventSMSFollowUpStartDate__c, CCPM_campaign__r.CCPM_eventSMSFollowUpEndDate__c, CCPM_campaign__r.CCPM_leadCustomerType__c,'+
            'CCPM_campaign__r.CCPM_leadType__c, '+
            '(Select id, CCPM_eventMessageStartDate__c, CCPM_eventMessageEndDate__c, CCPM_startDate__c, CCPM_endDate__c, CCPM_customerMessage__c, '+
            'CCPM_prospectMessage__c,CCPM_doNotOverrideEcode__c, CCPM_initialMessage__c, CCPM_followupMessage__c, '+
            'CCPM_followUpMessageType__c, CCPM_initialMessageType__c '+
            'FROM CCPM_smsTemplates__r Where CCPM_isActive__c = true Order By CreatedDate ASC)'+
            'From CCPM_segmentation__c Where CCPM_isActive__c = true AND CCPM_campaign__r.IsActive=true Order By CreatedDate ASC';
        List<CCPM_segmentation__c> lstSeg  = Database.query(strSegQuery);
        if(CCPM_Collection.isNotNullEmpty(lstSeg)){
            for(CCPM_segmentation__c objSeg : lstSeg){
                if(objSeg.CCPM_campaign__r.CCPM_recordTypeName__c == 'Event Type'){
                    if(String.isNotBlank(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpStartDate__c) || String.isNotBlank(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpEndDate__c)){
                        mapSMSFWRK.get('EventFwrkActualSMSDtTimeMap').put(objSeg.CCPM_campaign__r.Name, new List<CCPM_segmentation__c>{objSeg});
                    }
                    if(mapSMSFWRK.get('EventFwrkMap').containsKey(objSeg.CCPM_campaign__r.Name)){
                        mapSMSFWRK.get('EventFwrkMap').get(objSeg.CCPM_campaign__r.Name).add(objSeg);
                    }
                    else{
                        mapSMSFWRK.get('EventFwrkMap').put(objSeg.CCPM_campaign__r.Name, new List<CCPM_segmentation__c>{objSeg});
                    }
                }
                if(objSeg.CCPM_campaign__r.CCPM_recordTypeName__c == 'Other Lead Type'){
                    if(mapSMSFWRK.get('SMSFwrkMap').containsKey(objSeg.CCPM_campaign__r.CCPM_leadType__c)){
                        mapSMSFWRK.get('SMSFwrkMap').get(objSeg.CCPM_campaign__r.CCPM_leadType__c).add(objSeg);
                    }
                    else{
                        mapSMSFWRK.get('SMSFwrkMap').put(objSeg.CCPM_campaign__r.CCPM_leadType__c, new List<CCPM_segmentation__c>{objSeg});
                    }
                    
                }
            }	
        }
        return mapSMSFWRK;
    }
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to return Map of Type and Map of Event type and List of segmentations
@param         N/A
@return        Map<String, Map<String, List<CCPM_segmentation__c>>>
*/    
    public static Map<String, Map<String, List<CCPM_segmentation__c>>> getMapLeadTypeMapEvntLstSmsTemp(){
        Map<String, Map<String, List<CCPM_segmentation__c>>> mapTypeEvntTypeLstSegmtMap = new Map<String, Map<String, List<CCPM_segmentation__c>>>();
        
        mapTypeEvntTypeLstSegmtMap.put('CalcualteSMSFollowupMap', new Map<String, List<CCPM_segmentation__c>>());
        mapTypeEvntTypeLstSegmtMap.put('EventSMSMap', new Map<String, List<CCPM_segmentation__c>>());
        String strSegQuery = 'Select id, CCPM_campaign__c, CCPM_channels__c, CCPM_markets__c, CCPM_territories__c, CCPM_districts1__c, CCPM_districts2__c, CCPM_districts3__c,'+
            'CCPM_campaign__r.Name, CCPM_campaign__r.CCPM_eventStartDate__c, CCPM_campaign__r.CCPM_eventEndDate__c,'+
            'CCPM_campaign__r.CCPM_eventSMSFollowUpStartDate__c, CCPM_campaign__r.CCPM_eventSMSFollowUpEndDate__c, CCPM_campaign__r.CCPM_leadCustomerType__c,'+
            '(Select id, CCPM_eventMessageStartDate__c, CCPM_eventMessageEndDate__c, CCPM_startDate__c, CCPM_endDate__c, CCPM_customerMessage__c, '+
            'CCPM_prospectMessage__c,CCPM_doNotOverrideEcode__c, CCPM_followUpMessageType__c, CCPM_initialMessageType__c  FROM CCPM_smsTemplates__r Where CCPM_isActive__c = true)'+
            'From CCPM_segmentation__c Where CCPM_isActive__c = true AND CCPM_campaign__r.IsActive=true';
        List<CCPM_segmentation__c> lstSeg  = Database.query(strSegQuery);
        if(CCPM_Collection.isNotNullEmpty(lstSeg)){
            for(CCPM_segmentation__c objSeg : lstSeg){
                if(String.isNotBlank(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpStartDate__c) || String.isNotBlank(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpEndDate__c)){
                    mapTypeEvntTypeLstSegmtMap.get('CalcualteSMSFollowupMap').put(objSeg.CCPM_campaign__r.Name, new List<CCPM_segmentation__c>{objSeg});
                }
                if(mapTypeEvntTypeLstSegmtMap.get('EventSMSMap').containsKey(objSeg.CCPM_campaign__r.Name)){
                    mapTypeEvntTypeLstSegmtMap.get('EventSMSMap').get(objSeg.CCPM_campaign__r.Name).add(objSeg);
                }
                else{
                    mapTypeEvntTypeLstSegmtMap.get('EventSMSMap').put(objSeg.CCPM_campaign__r.Name, new List<CCPM_segmentation__c>{objSeg});
                }
            }
        }        
        return mapTypeEvntTypeLstSegmtMap;
    }
    /**
@author        Aneesha Ragireddy(Deloitte)
@description   Method to return Journey record to be inserted when Lead is marked as Converted/Expired
@param         Lead
@return        Jounrney
*/
    public static CCPM_Journey__c createJourneyForCLosedLead(Lead objLead){
        CCPM_Journey__c objJourney = new CCPM_Journey__c();
        if(objLead.recordTypeId != strLeadProspectRT && objLead.recordTypeId != strLeadProspectCartRT){
            objJourney.CCPM_mobileNumber__c = objLead.CCPM_mobileNumber__c;
            objJourney.CCPM_channel__c = objLead.CCPM_leadChannel__c;
            objJourney.CCPM_Type__c = objLead.CCPM_Type__c;
            objJourney.CCPM_leadSource__c = objLead.LeadSource;
            objJourney.CCPM_leadStatus__c = objLead.Status;
            objJourney.CCPM_active__c = False;
            objJourney.CCPM_isMerged__c = objLead.CCPM_isMerged__c;
            objJourney.CCPM_account__c = objLead.CCPM_Account__c;
            objJourney.CCPM_isInitialSMSSent__c = objLead.CCPM_isInitialSMSSent__c;
            objJourney.CCPM_isFollowUpSMSSent__c = objLead.CCPM_isFollowUpSMSSent__c;
            objJourney.CCPM_isProspectSMSsent__c = objLead.CCPM_isProspectSMSsent__c;
            objJourney.CCPM_doubleOptOutSent__c	= objLead.CCPM_DoubleOptOutSent__c;
            objJourney.CCPM_SMSOptOut__c	= objLead.CCPM_SMSOptOut__c;
            objJourney.CCPM_createdDate__c	= objLead.CCPM_CreatedDate__c;
        }
        return objJourney;
    } 
    
    
    /**
@author        Ritwik Koneru(Deloitte)
@description   Method to return IVR Error Mapping customer metadata record
@param         None
@return        map<String,string>
*/
    public static map<String,string> ivrErrMap () {
        
        map<String,String> retMap = new map<String,String>();
        for (CCPM_ivrErrorMapping__mdt objIvr : [SELECT id,MasterLabel,CCPM_errorMessage__c FROM CCPM_ivrErrorMapping__mdt]) {
            retMap.put(objIvr.MasterLabel,objIvr.CCPM_errorMessage__c);
        }
        
        return retMap;
    }
    
    /**
@author        Anupreeta Chakraborty(Deloitte)
@description   Method to return map of profile Ids and profile names
@param         None
@return        map<String,string>
*/
    public static map<String,string> getProfileIdNameMap(){
        Map<String, String> mapProfileIdName = new Map<String, String>();
        
        for(Profile objp : [Select id, Name from Profile]){
            mapProfileIdName.put(objp.Id, objp.Name);
        }
        return mapProfileIdName;
    }
}