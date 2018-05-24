/**
*@name          CCPM_leadTriggerHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          10/11/2017
*@description   This is a controller or class
*@Class         CCPM_leadTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    10/11/2017   Initial Implementation.
Sriraman Sridharan (Deloitte)      12/5/2017    Update Version.
Sriraman Sridharan (Deloitte)      12/15/2017   Before Update Methods. 
Sriraman Sridharan (Deloitte)      12/22/2017   After Insert Methods.
Sriraman Sridharan (Deloitte)      01/05/2018   After Update Methods.
Brigadesh Chandrasekar(Deloitte)   03/11/2018   Changes in Lead ownership conditions to include POS Leads in Before INsert and Before Update
*/
public without sharing class CCPM_leadTriggerHandler implements CCPM_ITriggerHandler {
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean boolTriggerDisabled = false;
    //Set if account Unique id and account Record
    public static Set<String> setAccUniqueID = new Set<String>();
    public static Map<String, String> mapProfileNameID = CCPM_utility.getProfileNameIDMap(); 
    public static String strUserProfileId=UserInfo.getProfileId();
    public static Map<String, Account> mapAccUniqueIDAccRec = new Map<String, Account>();
    public static String strLeadProspectRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectRT).getRecordTypeId();
    public static String strLeadProspectCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId();
    public static String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
    public static String strLeadCustomerAbandonedVisit = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerAbandonedVisitlead).getRecordTypeId();
    public static String strLeadCustomerQuoteRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerQuotesRT).getRecordTypeId();
    public static List<LOG_LogMessage__c> lstleadhdlrLogMsg = new List<LOG_LogMessage__c>();
    public static Set<String> setQueueIDs = CCPM_leadTriggerHandlerHelper.setQueueIDs;
    //populated by execution of CCPM_leadTriggerHandlerHelper.getAccUniqIDAccountRecMap
    public static Set<String> setStoreId = new Set<String>(); // to collect all the store record ids in the current trigger context.
    public static Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapBusinessHoursNameRec;
    public static Boolean isCurrentUserTelesalesUser = CCPM_utility.isCurrentUserTelesalesUser();
    Set<String> setCartLastHandledBy = new Set<String>();
    public static Map<String, CCPM_Store__c> mapStoreId = new Map<String, CCPM_Store__c>();//map of Informatica store id and the store object. This is not a map between SFDC Store ID and Store Object.
    Map<id,Lead> mapExistingRelatedRecs = new Map<id,Lead>();
    public static Map<Id, CCPM_Store__c> mapStore = new Map<Id, CCPM_Store__c>();// THis is a map between the SFDC Store ID and the store record
    public static Map<String, String> mapQueueNameIds = CCPM_utility.populateQueueNameIds(); 
    public static Set<String> setCustomerRecordTypeids = new Set<String>{strLeadCustomerCartRT,strLeadCustomerAbandonedVisit,strLeadCustomerQuoteRT};
    public static Set<String> setRecordTypeidsForSMS = new Set<String>{strLeadCustomerAbandonedVisit,strLeadCustomerQuoteRT};
    public static Set<String> setManualLeadProspectLeadType = CCPM_utility.getSetFromString(Label.CCPM_manualLeadProspectLeadType, ',');

            /**
@author       Bharath Ammanamanchi (Deloitte)
@description  Checks to see if the trigger has been disabled either by custom setting or by running code
@param        N/A  
@return       Boolean
*/ 
            public Boolean IsDisabled()
        {
            CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(UserInfo.getUserId());
            system.debug('@@@CCPM_DisableOldTriggerForTest__c : ' +settings.CCPM_DisableOldTriggerForTest__c) ;
            if(settings != null && settings.CCPM_DisableTrigger__c == true){
                return true;
            }
            else if(settings != null && settings.CCPM_DisableOldTriggerForTest__c == true){
                return true;
            }
            else{
                return boolTriggerDisabled;
            }  
        }        
    
    /**
@author       Bharath Ammanamanchi (Deloitte)
@description  is called in the before insert trigger context
@param        List<SObject>
@return       void
*/     
    public void BeforeInsert(List<SObject> lstNewItems) {
        /**************Method Declarations Start*/
        List<Lead> lstNew = (List<Lead>) lstNewItems;
        CCPM_storeEmployee__c objcurrUserStrEmpRec = null;
        Map<String, CCPM_storeEmployee__c> mapCartLastHandledBy = new Map<String, CCPM_storeEmployee__c>();       
        /**************Method Declarations end*/
        CCPM_leadTriggerHandlerHelper.mapMobileNumContact.clear();
        /**************First Loop Start*/
        for(Lead objLead : lstNew){
            if(objLead.CCPM_leadType__c == null){
                objLead.adderror('Please select Lead type'); 
            }
            else{
                CCPM_leadTriggerHandlerHelper.assignRecordtypeRelatedtoLeadType(objLead);
            }           
            CCPM_leadTriggerHandlerHelper.populateDismissedChannel(objLead, null);
            CCPM_leadTriggerHandlerHelper.populateClosedLeadChannel(objLead, null);
            if(objLead.CCPM_accountUniqueID__c!=null){
                mapAccUniqueIDAccRec.put(objLead.CCPM_accountUniqueID__c, new Account());
            }
            
            //This is collected for ownership assignment
            
            if(objLead.CCPM_cartlastHandledBy__c != null){
                //add last cart handled by field to the list from all the leads
                setCartLastHandledBy.add(objLead.CCPM_cartlastHandledBy__c);
            }
            if(objLead.CCPM_storeID__c != null){
                //add store ID field to the list from all the leads
                mapStoreId.put(objLead.CCPM_storeID__c, new CCPM_Store__c());
            }
            //Lead source for Telesales and Manual Lead
            if(CCPM_Collection.isNotNullEmpty(setManualLeadProspectLeadType) && setManualLeadProspectLeadType.contains(objLead.CCPM_leadType__c)) {
                objLead.LeadSource = Label.CCPM_LeadSourceSalesforce;
            } 
            //Telesales
            if(isCurrentUserTelesalesUser == true || objLead.CCPM_leadType__c==Label.CCPM_telesalesManualPOStype) {
                objLead.CCPM_createdChannel__c = Label.CCPM_telesalesChannelName;
                objLead.CCPM_reminder__c = Label.CCPM_reminderScheduled;
            } 
            else {
                objLead.CCPM_createdChannel__c = Label.CCPM_retailChannelName;
                objLead.CCPM_reminder__c = Label.CCPM_none;
                if((objLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId()
                    || objLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId()) 
                   && (objLead.CCPM_leadChannel__c == Label.CCPM_retailChannelName || objLead.CCPM_leadChannel__c == Label.CCPM_digitalChannelName))
                {
                    objLead.CCPM_createdChannel__c = objLead.CCPM_leadChannel__c;
                }
            }
            
            
            //US516
            if(strUserProfileId != mapProfileNameID.get(Label.CCPM_integrationUserProfileName)) {
                objLead.CCPM_dateAndTimeConsentAgreed__c = system.now();       
                objLead.CCPM_consentChannelSigned__c = Label.CCPM_LeadRetail;
            }
            
            // Formating the MTN by removing the non digits
            if(objLead.CCPM_mobileNumber__c!= NULL)
            {
                objLead.CCPM_mobileNumber__c = objLead.CCPM_mobileNumber__c.replaceAll(Label.CCPM_nondigits, '');
                objLead.CCPM_isMTNAvailable__c=true;
                if(objLead.CCPM_confirmMTN__c != NULL)
                {
                    objLead.CCPM_confirmMTN__c = objLead.CCPM_confirmMTN__c.replaceAll(Label.CCPM_nondigits, '');
                }
                if(objLead.CCPM_accountUniqueID__c!=null){
                    CCPM_leadTriggerHandlerHelper.mapMobileNumContact.put(objLead.CCPM_mobileNumber__c, new Contact());
                }
                
            }  
            //Merge Flag to be marked true for prospect and manual lead if mobile number is not null and status is open
            if(objLead.RecordTypeId == strLeadProspectRT || (objLead.RecordTypeId == strLeadCustomerCartRT && objLead.CCPM_isManualLead__c == true)
               && objLead.CCPM_mobileNumber__c != NULL && String.isNotBlank(objLead.status) && CCPM_utility.setleadOpenStatus.contains(objLead.status)){
                   if(objLead.RecordTypeId != strLeadProspectRT){
                       objLead.CCPM_tobeMerged__c = true;
                   }
                       objLead.CCPM_mfToBeMerged__c = true;                  
               }
            
            //Added by Anupreeta Chakraborty (Deloitte) for US-2240, Logic to update the Created Channel and Created Lead source based on Type, RecordType and Channel  
            CCPM_leadTriggerHandlerHelper.populateCreatedLeadFields(objLead); 
            
        }
        /**************First loop End*/
        //This query is to get the store ID of all the Reps in the CartLastHandledby field. This includes the current owner also.
        try{
            for(CCPM_storeEmployee__c objStrEmp : [Select CCPM_Store__c,CCPM_employee__c,CCPM_IsActive__c,CCPM_Store__r.CCPM_storeID__c,
                                                   CCPM_store__r.CCPM_TimeZone__c,CCPM_Store__r.CCPM_IsActive__c,CCPM_Store__r.CCPM_market__c,
                                                   CCPM_employee__r.CCPM_commissionableRepID__c
                                                   from CCPM_storeEmployee__c 
                                                   where (CCPM_employee__r.CCPM_commissionableRepID__c IN: setCartLastHandledBy OR CCPM_employee__c = : UserInfo.getUserId()) 
                                                   AND CCPM_IsActive__c = true and CCPM_employee__r.isActive = true AND CCPM_isStoreActive__c = true]){
                                                       
                                                       if(objStrEmp.CCPM_employee__c == UserInfo.getUserId()){
                                                           objcurrUserStrEmpRec = new CCPM_storeEmployee__c();
                                                           objcurrUserStrEmpRec = objStrEmp;
                                                       } 
                                                       else
                                                       {
                                                           mapCartLastHandledBy.put(objStrEmp.CCPM_employee__r.CCPM_commissionableRepID__c, objStrEmp);
                                                       }
                                                       if(objStrEmp.CCPM_Store__c != null){
                                                           setStoreId.add(objStrEmp.CCPM_Store__c);
                                                       }
                                                   }
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandlerNew','BeforeInsert','Exception thrown while querying for store employee','');
            lstleadhdlrLogMsg.add(log);
        }
        //this is to add all Account records to a map with Account Unique ID field on lead being the Key. 
        //All the stores ids on the account are also added to setStoreId
        mapAccUniqueIDAccRec = CCPM_leadTriggerHandlerHelper.getAccUniqIDAccountRecMap(mapAccUniqueIDAccRec);
        
        //This query gets all the Supervisors for the Stores related to the reps in cart handled by and current user.
        if(CCPM_Collection.isNotNullEmpty(setStoreId) || CCPM_Collection.isNotNullEmpty(mapStoreId.keySet())){
            try{
                mapStore = new Map<Id, CCPM_Store__c>([Select Name, Id, CCPM_storeID__c, CCPM_market__c, CCPM_TimeZone__c, CCPM_IsActive__c, 
                                                       (Select Id, CCPM_Store__c, CCPM_employee__c, CCPM_role__c, CCPM_IsActive__c, CCPM_previousactive__c, 
                                                        CCPM_PreviousRole__c 
                                                        From Store_Employees__r 
                                                        Where CCPM_IsActive__c = true AND CCPM_employee__r.isActive = true
                                                        AND (CCPM_Role__c IN : CCPM_leadTriggerHandlerHelper.setStrSupervisorRoleName OR CCPM_employee__r.CCPM_commissionableRepID__c IN: setCartLastHandledBy)  
                                                        Order By CCPM_Role__c ASC) 
                                                       From CCPM_Store__c Where CCPM_IsActive__c = true AND (id IN :setStoreId OR CCPM_storeID__c IN:mapStoreId.keySet())]);
                //system.debug('@@@mapStore : ' + mapStore + ' setStoreId : ' +setStoreId + ' setStrSupervisorRoleName : ' + CCPM_leadTriggerHandlerHelper.setStrSupervisorRoleName + '@@@mapStoreId.keySet() : ' + mapStoreId.keySet());
                system.debug('@@@mapStore before Insert: ' + mapStore );
            }
            catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','BeforeInsert','Exception thrown while querying for the map mapStore','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        if(CCPM_Collection.isNotNullEmpty(mapStoreId)){
            for(id idStr : mapStore.keyset()){
                if(mapStoreId.containsKey(mapStore.get(idStr).CCPM_storeID__c)){
                    mapStoreId.put(mapStore.get(idStr).CCPM_storeID__c, mapStore.get(idStr));
                }
            }
        }
        
        /**************Second Loop Start*/
        for(Lead objLead : lstNew){
            CCPM_leadTriggerHandlerHelper.assignAccountDetailsToLead(objLead, mapAccUniqueIDAccRec);
            CCPM_leadTriggerHandlerHelper.setLeadToEligible(objLead, mapAccUniqueIDAccRec);
            //Assign Owenrship for leads on insert
            CCPM_leadTriggerHandlerHelper.assignOwner(objLead, null, mapStore, mapStoreId, objcurrUserStrEmpRec, mapCartLastHandledBy, mapAccUniqueIDAccRec);
            if(CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objlead.ownerid)){
                CCPM_leadTriggerHandlerHelper.calculateActualSMSScheduleDateTime(objlead);
            }
            
            
            
        }
        /**************Second loop End*/
        
        /**************Methods calling functionalities in other classes start. */
        
        //CCPM_leadTriggerHandlerHelper.ESMSFWKCalculateSMSFOllowupDate(lstNew, null);
        /**************Methods calling functionalities in other classes end.*/
        
    }
    /**
@author       Bharath Ammanamanchi (Deloitte)
@description  is called in the before update trigger context
@param        List<SObject>
@return       void
*/ 
    public void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Lead> mapNew = (Map<id, Lead>)mapNewItems;
        Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
        Map<String, CCPM_storeEmployee__c> mapOwnerIdAndStoreEmployee = new Map<String, CCPM_storeEmployee__c>();
        CCPM_storeEmployee__c objcurrUserStrEmpRec = new CCPM_storeEmployee__c();
        Map<String, CCPM_storeEmployee__c> mapCartLastHandledBy = new Map<String, CCPM_storeEmployee__c>();
        
        List<CCPM_SMSMessage__c> lstSMSMessages = new List<CCPM_SMSMessage__c>();
        list<lead> lstLeadsForFieldUpdateDuringInformaticaMerge = new List<lead>();
        Set<String> setStore = new Set<String>();
        Set<String> setLeadClosedStatus = CCPM_utility.getSetFromString(Label.CCPM_leadClosedStatus, ',');
        /**************Method Declarations end*/
        
        CCPM_leadTriggerHandlerHelper.mapMobileNumContact.clear();
        /**************First Loop Start*/
        for(Lead objLead : mapNew.values()){           
            Lead objLeadOld = mapOld.get(objLead.id);
            if(objLead.CCPM_leadType__c == null){
                objLead.adderror('Please select Lead type'); 
            }
            else if((objLead.CCPM_leadtype__c!=objLeadOld.CCPM_leadtype__c)){
                //Calling assignRecordtypeRelatedtoLeadType method      
                system.debug('@@@ChangeRT');     
                CCPM_leadTriggerHandlerHelper.assignRecordtypeRelatedtoLeadType(objLead);
            }
            //Calling the populateDismissedChannel method
            CCPM_leadTriggerHandlerHelper.populateDismissedChannel(objLead, objLeadOld);
            if(objLead.CCPM_mobileNumber__c !=  null && objLead.CCPM_accountUniqueID__c!=null){
                CCPM_leadTriggerHandlerHelper.mapMobileNumContact.put(objLead.CCPM_mobileNumber__c, new Contact());
            }
            //Calling the populateClosedLeadChannel method  
            
            CCPM_leadTriggerHandlerHelper.populateClosedLeadChannel(objLead, objLeadOld);
            
            // checking for this condition in case the record is getting in the same context the record was inserted.   
            if(objLead.CCPM_accountUniqueID__c!=null && !mapAccUniqueIDAccRec.containsKey(objLead.CCPM_accountUniqueID__c)){
                mapAccUniqueIDAccRec.put(objLead.CCPM_accountUniqueID__c, new Account());
            }
            //Lead source for Telesales and Manual Lead
            if(CCPM_Collection.isNotNullEmpty(setManualLeadProspectLeadType) && setManualLeadProspectLeadType.contains(objLead.CCPM_leadType__c)) {
                objLead.LeadSource = Label.CCPM_LeadSourceSalesforce;
            } 
            if(objLead.OwnerId != null && objLead.OwnerId != objLeadOld.OwnerId && !setQueueIDs.contains(objLead.OwnerId)){
                mapOwnerIdAndStoreEmployee.put(objLead.OwnerId, null);
            }
            
            if(objLead.Status == Label.CCPM_leadStatusConverted || objLead.Status == Label.CCPM_leadStatusQualified){
                CCPM_leadTriggerHandlerHelper.assignConvOrQualifiedTime(objLead, objLeadOld);
            }
            
            if(objLead.CCPM_SMSLegalOptIn__c == true && objLeadOld.CCPM_SMSLegalOptIn__c == false 
               && strUserProfileId!=mapProfileNameID.get(Label.CCPM_integrationUserProfileName)){  
                   objLead.CCPM_dateAndTimeConsentAgreed__c = system.now();
                   objLead.CCPM_consentChannelSigned__c     = Label.CCPM_LeadRetail;
               }
            
            
            //This is collected for ownership assignment
            if(objLead.CCPM_cartlastHandledBy__c != null){
                //add last cart handled by field to the list from all the leads
                setCartLastHandledBy.add(objLead.CCPM_cartlastHandledBy__c);
            }
            if(objLead.CCPM_storeID__c != null){
                //add store ID field to the list from all the leads
                mapStoreId.put(objLead.CCPM_storeID__c, new CCPM_Store__c());
            }
            // Logic to update the Lead Status to blank for Closed Lead Statuses
            if(setLeadClosedStatus.size() > 0 && setLeadClosedStatus.contains(objLead.Status)){
                objLead.CCPM_leadSubStatus__c = '';
            }
            //Update Prior Status
            
            CCPM_leadTriggerHandlerHelper.populatepreviousStatus(objLead, objLeadOld);
            
            // Formating the MTN by removing the non digits
            if(objLead.CCPM_mobileNumber__c!= NULL)
            {
                objLead.CCPM_mobileNumber__c = objLead.CCPM_mobileNumber__c.replaceAll(Label.CCPM_nondigits, '');
                objLead.CCPM_isMTNAvailable__c=true;
                if(objLead.CCPM_confirmMTN__c != NULL)
                {
                    objLead.CCPM_confirmMTN__c = objLead.CCPM_confirmMTN__c.replaceAll(Label.CCPM_nondigits, '');
                }  
            }  
            
            if(objLead.CCPM_accountUniqueID__c!=null && !setAccUniqueID.contains(objLead.CCPM_accountUniqueID__c)){
                setAccUniqueID.add(objLead.CCPM_accountUniqueID__c);
            }
            
            //populating the Originating Lead Owner and the Originating Store on the Lead Record, when the Lead Owner and store are Updated for converted carts
            if(objlead.Ownerid!=null && objLeadOld!=null &&  objLeadOld.ownerid!=null &&  objlead.Status==Label.CCPM_leadStatusConverted && objlead.Status!=objLeadOld.Status
               && CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objlead.ownerid))
            { 
                objlead.CCPM_originatingRep__c = objLeadOld.ownerid; 
            }
            if(objlead.Store__c!=null && objLeadOld!=null && objLeadOld.Store__c!=null && objlead.Status==Label.CCPM_leadStatusConverted && objlead.Status!=objLeadOld.Status )
            {
                objlead.CCPM_originatingStore__c = objLeadOld.Store__c; 
            }
            //Informatica Merge
            CCPM_leadTriggerHandlerHelper.manageInformaticaMerge(objlead,objLeadOld);
            
        }
        /**************First loop End*/
        try{
            for(CCPM_storeEmployee__c objStrEmp : [Select CCPM_Store__c,CCPM_employee__c,CCPM_IsActive__c,CCPM_Store__r.CCPM_storeID__c,
                                                   CCPM_store__r.CCPM_TimeZone__c,CCPM_Store__r.CCPM_IsActive__c,CCPM_Store__r.CCPM_market__c,
                                                   CCPM_employee__r.CCPM_commissionableRepID__c
                                                   from CCPM_storeEmployee__c 
                                                   where (CCPM_employee__r.CCPM_commissionableRepID__c IN: setCartLastHandledBy OR CCPM_employee__c IN: mapOwnerIdAndStoreEmployee.keySet()) 
                                                   AND CCPM_IsActive__c = true and CCPM_employee__r.isActive = true AND CCPM_isStoreActive__c = true])
            {
                if(mapOwnerIdAndStoreEmployee.containsKey(objStrEmp.CCPM_employee__c)){
                    mapOwnerIdAndStoreEmployee.put(objStrEmp.CCPM_employee__c, objStrEmp);
                } 
                if(objStrEmp.CCPM_employee__c == UserInfo.getUserId()){
                    objcurrUserStrEmpRec = new CCPM_storeEmployee__c();
                    objcurrUserStrEmpRec = objStrEmp;
                } 
                else
                {
                    mapCartLastHandledBy.put(objStrEmp.CCPM_employee__r.CCPM_commissionableRepID__c, objStrEmp);
                }
                if(objStrEmp.CCPM_Store__c != null){
                    setStoreId.add(objStrEmp.CCPM_Store__c);
                }
            }
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','BeforeUpdate','Exception thrown while querying for store employee','');
            lstleadhdlrLogMsg.add(log);
        }
        //this is to add all Account records to a map with Account Unique ID field on lead being the Key. 
        //All the stores ids on the account are also added to setStoreId
        if(CCPM_Collection.isNotNullEmpty(mapAccUniqueIDAccRec)){
            mapAccUniqueIDAccRec = CCPM_leadTriggerHandlerHelper.getAccUniqIDAccountRecMap(mapAccUniqueIDAccRec);
        }
        
        if(CCPM_Collection.isNotNullEmpty(setStoreId) || CCPM_Collection.isNotNullEmpty(mapStoreId.keySet())){
            try{
                mapStore = new Map<Id, CCPM_Store__c>([Select Name, Id, CCPM_storeID__c, CCPM_market__c, CCPM_TimeZone__c, CCPM_IsActive__c, 
                                                       (Select Id, CCPM_Store__c, CCPM_employee__c, CCPM_role__c, CCPM_IsActive__c, CCPM_previousactive__c, 
                                                        CCPM_PreviousRole__c 
                                                        From Store_Employees__r 
                                                        Where CCPM_IsActive__c = true AND CCPM_employee__r.isActive = true
                                                        AND (CCPM_Role__c IN : CCPM_leadTriggerHandlerHelper.setStrSupervisorRoleName OR CCPM_employee__r.CCPM_commissionableRepID__c IN: setCartLastHandledBy)  
                                                        Order By CCPM_Role__c ASC) 
                                                       From CCPM_Store__c Where CCPM_IsActive__c = true AND (id IN :setStoreId OR CCPM_storeID__c IN:mapStoreId.keySet())]);
                
            }
            catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','BeforeUpdate','Exception thrown while querying for the map mapStore','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        if(CCPM_Collection.isNotNullEmpty(mapStoreId)){
            for(id idStr : mapStore.keyset()){
                if(mapStoreId.containsKey(mapStore.get(idStr).CCPM_storeID__c)){
                    mapStoreId.put(mapStore.get(idStr).CCPM_storeID__c, mapStore.get(idStr));
                }
            }
        }
        
        /**************Second Loop Start*/
        for(Lead objLead : mapNew.values()){
            
            Lead objLeadOld = mapOld.get(objLead.id);
            /*
            if (objLead.ownerId != objLeadOld.ownerId && setQueueIDs.contains(objLead.OwnerId)) {
                objLead.CCPM_businessCardLimit__c = 0;    
            }*/
            
            if(objLead.CCPM_accountUniqueID__c != null && objLead.CCPM_accountUniqueID__c != objLeadOld.CCPM_accountUniqueID__c){
                CCPM_leadTriggerHandlerHelper.assignAccountDetailsToLead(objLead, mapAccUniqueIDAccRec);
            }
            //Assign Owenrship for leads on insert
            CCPM_leadTriggerHandlerHelper.assignOwner(objLead, objLeadOld, mapStore, mapStoreId, mapOwnerIdAndStoreEmployee.get(objLead.OwnerId), mapCartLastHandledBy, mapAccUniqueIDAccRec);
            CCPM_leadTriggerHandlerHelper.calculateActualSMSScheduleDateTimeOnUpdate(objlead, objLeadOld);
            
            //update Last Interaction Before Closed field for open leads
            if(objLead.Status != null && CCPM_utility.setleadOpenStatus.contains(objLead.status)){
                objLead.CCPM_Last_Interaction_Before_Closed__c = objLead.CCPM_lastInteraction__c;    
            }
            
            Datetime triggerFollowupSMSDateTime;
            if(objLead.CCPM_ActualSMSScheduleDateTime__c != null && objLead.CCPM_isInitialSMSSent__c!= objLeadOld.CCPM_isInitialSMSSent__c && objLead.CCPM_isInitialSMSSent__c  && !objLead.CCPM_isFollowUpSMSSent__c && !objlead.CCPM_DismissedLead__c){
                triggerFollowupSMSDateTime = objLead.CCPM_ActualSMSScheduleDateTime__c.addminutes(Integer.valueof(Label.CCPM_followUpSMSInterval));
                if(objLead.recordTypeId != strLeadProspectRT){
                    if(objLead.Store__c != null && String.isNotBlank(objLead.CCPM_StoreTimeZone__c)){
                        objLead.CCPM_triggerFollowupSMSDateTime__c = CCPM_utility.calculateTimeToTriggerSMSWithInBusinessHours(mapBusinessHoursNameRec.get(objLead.CCPM_StoreTimeZone__c), triggerFollowupSMSDateTime);     
                    }
                    else{
                        objLead.CCPM_triggerFollowupSMSDateTime__c = CCPM_utility.calculateTimeToTriggerSMSWithInBusinessHours(mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel), triggerFollowupSMSDateTime);
                    }
                }
            }
        }
        /**************Second loop End*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
    }
    /**
@author       Bharath Ammanamanchi (Deloitte)
@description  is called in the before delete trigger context
@param        List<SObject>
@return       void
*/ 
    public void BeforeDelete(Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
    /**
@author       Bharath Ammanamanchi (Deloitte)
@description  is called in the after insert trigger context
@param        List<SObject>
@return       void
*/ 
    public void AfterInsert(Map<Id, SObject> mapNewItems){
        /**************Method Declarations Start*/
        Map<id, Lead> mapNew = (Map<id, Lead>)mapNewItems;
        List<CCPM_SMSMessage__c> lstSmsMessage = new List<CCPM_SMSMessage__c>();
        List<Task> lstTaskTOUpsert = new List<Task>();
        Set<String> setLeadIdToCloseTasks = new Set<String>();
        List<LeadShare> lstLeadShareToInsert    = new List<LeadShare>();
        set<string> setLeadWithoutAccounts = new set<string>();
        list<Lead> lstLeadToCont = new list<lead>();
        Contact objCont = new Contact();
        Map<String,Contact> mapCont = new Map<String,Contact>();
        // ForUAT2
        map<String,group> mapStoreRoleAndGroup = new map<String,group>();
        map<String,String> mapRoleAndStoreID = new map<String,String>();
        
        if(CCPM_Collection.isNotNullEmpty(mapAccUniqueIDAccRec)){
            mapAccUniqueIDAccRec = CCPM_leadTriggerHandlerHelper.getAccUniqIDAccountRecMap(mapAccUniqueIDAccRec);
        }
        CCPM_leadtriggerhandlerhelper.populateMTNContactList();
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        for(Lead objlead : mapNew.values()){
            //inserts records in the sms messages object when a lead/prospect record is created.
            CCPM_SMSMessage__c smsMsgOne = CCPM_leadTriggerHandlerHelper.populateInitialSMS(objlead, mapAccUniqueIDAccRec);
            if (String.isNotBlank(objLead.CCPM_Account__c)){
                objCont = ccpm_leadTriggerHandlerHelper.getAssociatedContactToLead(objlead);
                
                //system.debug('@@@objCont : ' + objCont);
                if(objCont != null){
                    if (!mapCont.containsKey(objCont.MobilePhone)) {
                        mapCont.put(objCont.MobilePhone, objCont);
                    }
                }
            }
            
            
            if(isCurrentUserTelesalesUser == true || objLead.CCPM_leadType__c==Label.CCPM_telesalesManualPOStype){
                Task objTask = CCPM_leadTriggerHandlerHelper.populateActivityForTelesales(objlead);
                if(objTask != null){
                    lstTaskTOUpsert.add(objTask);
                    //if the lead needs a new task created then we add it to set to query for any tasks which are connected to these leads
                    setLeadIdToCloseTasks.add(objlead.Id);
                }
            }
            
            if(smsMsgOne != null){
                lstSmsMessage.add(smsMsgOne);
            }
            
            if(objlead.CCPM_storeIDReference__c != null){
                String strStoreID = objlead.CCPM_storeIDReference__c;
                String strRole = 'Store ('+strStoreID.substring(0, strStoreID.length()-2)+'-'+strStoreID.substring(strStoreID.length()-2,strStoreID.length())+') Store Manager';
                mapRoleAndStoreID.put(strRole,objlead.CCPM_storeIDReference__c);
            } 
            //To Log Error Messages for the Customer Carts with an Invalid Account Unique Ids
            if( setCustomerRecordTypeids.contains(objLead.recordTypeId) && objLead.CCPM_Account__c == null) 
            {
                setLeadWithoutAccounts.add(objLead.ID);
            }
            
        }
        /**************First loop End*/
        
        //To Log Error Messages for the Customer Carts with an Invalid Account Unique Ids
        //ForUAT2
        try{
            if(CCPM_Collection.isNotNullEmpty(mapRoleAndStoreID.keySet())){
                for(group objGrp :[select id,RelatedId,Related.name from group where type ='Role' AND Related.name IN :mapRoleAndStoreID.keySet()]){
                    if(String.isNotBlank(objGrp.Related.name) && mapRoleAndStoreID.containsKey(objGrp.Related.name) && mapRoleAndStoreID.get(objGrp.Related.name) != null){
                        mapStoreRoleAndGroup.put(mapRoleAndStoreID.get(objGrp.Related.name), objGrp);
                    }
                }
            }
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandlerNew','AfterInsert','Exception thrown while querying for groups','');
            lstleadhdlrLogMsg.add(log);
        }
        
        /**************Second Loop Start*/
        for(Lead objlead : mapNew.values()){
            
            List<LeadShare> lstLeadShare = new List<leadShare>();
            if(objlead.CCPM_storeIDReference__c != null && mapStoreRoleAndGroup.containsKey(objlead.CCPM_storeIDReference__c) && mapStoreRoleAndGroup.get(objlead.CCPM_storeIDReference__c) != null){
                lstLeadShare.add(CCPM_utility.apexShareEditAccess(objLead.id,mapStoreRoleAndGroup.get(objlead.CCPM_storeIDReference__c).id));
            }
            
            if(CCPM_Collection.isNotNullEmpty(lstLeadShare)){
                lstLeadShareToInsert.addall(lstLeadShare);
            }
            
        } 
        /**************Second loop End*/
        
        if(CCPM_Collection.isNotNullEmpty(setLeadWithoutAccounts)){
            String strLeadWithoutAccountsMsg = 'The following leads dont have a valid account associated with them : ' + setLeadWithoutAccounts;
            LOG_LogMessage__c log = CCPM_utility.logMessage('Error','CCPM_leadTriggerHandler','AfterInsert',strLeadWithoutAccountsMsg,'');
            lstleadhdlrLogMsg.add(log);
        }
        
        //Task for telesales
        for(Task objt : [Select id, Status From Task Where WhoId IN:setLeadIdToCloseTasks AND Status != 'Closed' AND IsClosed = false]){
            objt.Status = 'Closed';
            lstTaskTOUpsert.add(objt);
        }
        
        if (CCPM_Collection.isNotNullEmpty(mapCont.values())) {
            try {
                // system.debug('@@@mapCont.values() : ' + mapCont.values());
                upsert mapCont.values();
            } catch (DMLException e) {
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterInsert','Exception thrown while upserting contact','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        
        if(CCPM_Collection.isNotNullEmpty(lstSmsMessage))
        {
            //insert the list of sms messages records
            try{
                insert lstSmsMessage;
            }
            catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterInsert','Exception thrown while inserting messages','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        if(CCPM_Collection.isNotNullEmpty(lstTaskTOUpsert)){
            //insert the list of sms messages records
            try{
                upsert lstTaskTOUpsert;
            }
            catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterInsert','Exception thrown while upserting tasks','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        //Insert Lead Shares
        
        if(CCPM_Collection.isNotNullEmpty(lstLeadShareToInsert))
        {   
            try{
                //Setting the Sharing settings required for the Manager & Assistant Manager to view the records associated with their Store
                insert lstLeadShareToInsert;
            }
            catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterInsert','Exception thrown while inserting lead shares','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        //insert all errors
        if(CCPM_Collection.isNotNullEmpty(lstleadhdlrLogMsg)){
            try{
                upsert lstleadhdlrLogMsg;
            }
            catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterInsert','Exception thrown while upserting error logs','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        
    }
    /**
@author       Bharath Ammanamanchi (Deloitte)
@description  is called in the after update trigger context
@param        List<SObject>
@return       void
*/ 
    public void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Lead> mapNew = (Map<id, Lead>)mapNewItems;
        Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
        Map<id,User> mapLeadOwners = new Map<id,User>();
        List<LiveText__ITR_Message__c> lstDeleteITRMessages = new List<LiveText__ITR_Message__c>();
        map<String,Boolean> mapTelesalesLeadsToCancelTasks = new map<String,Boolean>();
        if(CCPM_Collection.isNotNullEmpty(mapAccUniqueIDAccRec)){
            mapAccUniqueIDAccRec = CCPM_leadTriggerHandlerHelper.getAccUniqIDAccountRecMap(mapAccUniqueIDAccRec);
        }
        
        Set<String> setLeadIdToCloseTasks = new Set<String>(); 
        List<Task> lstTaskTOUpsert = new List<Task>();
        List<CampaignMember> lstCampignMember = new List<CampaignMember>();
        List<CCPM_SMSMessage__c> lstSmsMessage = new List<CCPM_SMSMessage__c>();
        List<CCPM_journey__c> lstJourney = new List<CCPM_journey__c>();
        List<LeadShare> lstLeadShareToInsert    = new List<LeadShare>();
        List<LeadShare> lstLeadShareToDelete    = new List<LeadShare>();
        //ForUAT2
        map<String,group> mapStoreRoleAndGroup = new map<String,group>();
        map<String,String> mapRoleAndStoreID = new map<String,String>();
        
        Set<ID> setExpiredLeadIDs = new Set<ID>();
        Set<id> setCampaignMemberLeadid= new Set<id>();
        Set<id> setOwnerId= new Set<id>();
        Map<String,Contact> mapCont = new Map<String,Contact>();
        Contact objCont = new Contact();
        
        CCPM_leadtriggerhandlerhelper.populateMTNContactList();
        
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */ 
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        for(Lead objlead : mapNew.values()){
            
            Lead objLeadOld = mapOld.get(objLead.id);
            mapExistingRelatedRecs.put(objLead.id, new Lead());
            
            if (String.isNotBlank(objLead.CCPM_Account__c)){
                objCont = ccpm_leadTriggerHandlerHelper.getAssociatedContactToLeadOnUpdate(objLeadOld,objlead);
                system.debug('@@@objCont : ' + objCont);
                if (objCont != null) {
                    if (!mapCont.containsKey(objCont.MobilePhone)) {
                        mapCont.put(objCont.MobilePhone, objCont);
                    }
                }
            }
            
            //Telesales
            Task objTask = new Task();
            if(isCurrentUserTelesalesUser == true || objLead.CCPM_leadType__c==Label.CCPM_telesalesManualPOStype){
                objTask = CCPM_leadTriggerHandlerHelper.populateActivityForTelesalesOnUpdate(objlead, mapOld.get(objlead.id));
                if(objTask != null){
                    lstTaskTOUpsert.add(objTask);
                    setLeadIdToCloseTasks.add(objlead.Id);
                }
            }
            //Get Owner ID if the owner changes
            if(!setQueueIDs.contains(objLead.OwnerId)){
                setOwnerId.add(objLead.OwnerId);
            }
            //Collect closed leads to Delete ITRs
            //Check if mtn has an effect CCPM_mobileNumber__c
            if(CCPM_utility.setleadClosedStatus.contains(objLead.status) && objLead.Status != objLeadOld.Status){
                setExpiredLeadIDs.add(objLead.id);
            }
            
            if(objlead.RecordTypeId==strLeadCustomerCartRT && objlead.CCPM_Type__c == Label.CCPM_leadTypeCampaignLead &&
               objlead.CCPM_isSMSResponseReceived__c==true && objLead.CCPM_isSMSResponseReceived__c != objLeadOld.CCPM_isSMSResponseReceived__c){
                   setCampaignMemberLeadid.add(objLead.id);
               }
            /********Need to Modify this if lead share is controlled using public group for assistant managers***********/
            if(objLead.Store__c != null && objLead.Store__c != objLeadOld.Store__c){
                setStoreId.add(objLeadOld.Store__c);
            }
            if(objlead.CCPM_storeIDReference__c != null && objlead.CCPM_storeIDReference__c != objLeadOld.CCPM_storeIDReference__c){
                String strStoreID = objlead.CCPM_storeIDReference__c;
                String strRole = 'Store ('+strStoreID.substring(0, strStoreID.length()-2)+'-'+strStoreID.substring(strStoreID.length()-2,strStoreID.length())+') Store Manager';
                mapRoleAndStoreID.put(strRole,objlead.CCPM_storeIDReference__c);
            }
            /********Need to Modify this if lead share is controlled using public group for assistant managers***********/
            
        }
        /**************First loop End*/
        
        if (CCPM_Collection.isNotNullEmpty(mapCont.values())) {
            try {
                upsert mapCont.values();
            } catch (DMLException e) {
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterInsert','Exception thrown while upserting contact','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        
        //this is to get all store records along with the old store id after owership change
        //  system.debug('@@@mapExistingRelatedRecs : ' + mapExistingRelatedRecs);
        try{
            if(CCPM_Collection.isNotNullEmpty(mapExistingRelatedRecs)){
                mapExistingRelatedRecs = 
                    new Map<Id, Lead>([Select id, ownerid,
                                       (Select Id, CCPM_ScheduleDateTime__c, CCPM_leadRecord__c, CCPM_messageType__c, ccpm_smstimezone__c,CCPM_MessageStatus__c 
                                        From SMS_Message_Sent__r Where (CCPM_MessageStatus__c =: Label.CCPM_messageStatusQueued OR CCPM_MessageStatus__c =: Label.CCPM_messageStatusError))
                                       From Lead Where id IN:mapExistingRelatedRecs.keyset()]);
            }
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while querying for mapExistingRelatedRecs','');
            lstleadhdlrLogMsg.add(log);
        }
        //   system.debug('@@@mapExistingRelatedRecs After Query: ' + mapExistingRelatedRecs);
        
        if(CCPM_Collection.isNotNullEmpty(setStoreId) || CCPM_Collection.isNotNullEmpty(mapStoreId.keySet())){
            try{
                mapStore = new Map<Id, CCPM_Store__c>([Select Name, Id, CCPM_storeID__c, CCPM_market__c, CCPM_TimeZone__c, CCPM_IsActive__c, 
                                                       (Select Id, CCPM_Store__c, CCPM_employee__c, CCPM_role__c, CCPM_IsActive__c, CCPM_previousactive__c, 
                                                        CCPM_PreviousRole__c 
                                                        From Store_Employees__r 
                                                        Where CCPM_IsActive__c = true 
                                                        AND (CCPM_Role__c IN : CCPM_leadTriggerHandlerHelper.setStrSupervisorRoleName OR CCPM_employee__r.CCPM_commissionableRepID__c IN: setCartLastHandledBy)  
                                                        Order By CCPM_Role__c ASC) 
                                                       From CCPM_Store__c Where CCPM_IsActive__c = true AND (id IN :setStoreId OR CCPM_storeID__c IN:mapStoreId.keySet())]);
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while querying for the map mapStore','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        //ForUAT2
        
        try{
            if(CCPM_Collection.isNotNullEmpty(mapRoleAndStoreID.keySet())){
                for(group objGrp :[select id,RelatedId,Related.name from group where type ='Role' AND Related.name IN :mapRoleAndStoreID.keySet()]){
                    if(String.isNotBlank(objGrp.Related.name) && mapRoleAndStoreID.containsKey(objGrp.Related.name) && mapRoleAndStoreID.get(objGrp.Related.name) != null){
                        mapStoreRoleAndGroup.put(mapRoleAndStoreID.get(objGrp.Related.name), objGrp);
                    }
                }
            }
        }
        Catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandlerNew','AfterInsert','Exception thrown while querying for groups','');
            lstleadhdlrLogMsg.add(log);
        }
        
        //Query for ITRs
        if(CCPM_Collection.isNotNullEmpty(setExpiredLeadIDs)){
            try{
                lstDeleteITRMessages=[select id,LiveText__Lead__c from LiveText__ITR_Message__c where LiveText__Lead__c IN :setExpiredLeadIDs];
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while querying for the ITRS','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        
        //Query for campaign members
        if(CCPM_Collection.isNotNullEmpty(setCampaignMemberLeadid)){
            try{
                for(CampaignMember objCampaignMember : [select leadId,HasResponded,status from CampaignMember where leadId IN: setCampaignMemberLeadid]){
                    objCampaignMember.status = Label.CCPM_leadStatusResponded;
                    lstCampignMember.add(objCampaignMember);
                }
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while querying for the Campaign members','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        
        //Queery for Users
        if(CCPM_Collection.isNotNullEmpty(setOwnerId)){
            try{
                mapLeadOwners = new map<id,User>([select id,MobilePhone,firstname,LastName from user where id in :setOwnerId and mobilephone!=null and isactive=true]);
            }Catch(Exception e)
            {
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while querying for the owner details','');
                lstleadhdlrLogMsg.add(log);            
            }
        }
        /**************Second Loop Start*/
        for(Lead objlead : mapNew.values()){
            Lead objLeadOld = mapOld.get(objLead.id);
            //   system.debug('@@@mapLeadOwners : ' + mapLeadOwners);
            //inserts or update records in the sms messages object when a lead/prospect record is created.
            CCPM_SMSMessage__c[] lstSMSmsg = CCPM_leadTriggerHandlerHelper.processSMSMessageOnUpdate(objlead, objLeadOld, mapExistingRelatedRecs.get(objlead.Id), mapAccUniqueIDAccRec, mapLeadOwners);
            if(CCPM_Collection.isNotNullEmpty(lstSMSmsg)){
                lstSmsMessage.addall(lstSMSmsg);
            }
            //Informatica Merge Scenario
            
            if(objLead != null && objLeadOld != null && objLead.Status != null && ccpm_utility.setLeadOpenStatusWithoutNew.contains(objLead.Status) 
               && objLead.CCPM_Type__c != null && objLead.CCPM_Type__c != Label.CCPM_leadTypeCampaignLead && !CCPM_utility.IsCampaignLead(objLead) && objLead.CCPM_mobileNumber__c != null
               && objLeadOld.CCPM_isInformaticaMerge__c == false && objLead.CCPM_isInformaticaMerge__c == true && (!objlead.CCPM_DismissedLead__c)
               && objLead.Ownerid!=null && CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objLead.ownerid)
               && ((!CCPM_utility.IsMergedQuoteLead(objlead) && objLead.LeadSource == Label.CCPM_LeadSourceNetace) || setRecordTypeidsForSMS.contains(objLeadOld.recordTypeId) || 
                   (CCPM_utility.IsMergedQuoteLead(objlead) && (objLead.LeadSource != Label.CCPM_LeadSourceNetace)))
               && (!CCPM_utility.IsMergedLeadAbandonedVisit(objLead) || objLeadOld.RecordTypeId == strLeadCustomerAbandonedVisit) && !objLead.CCPM_smsOptOutAccount__c
               && (objLead.RecordTypeId==strLeadCustomerCartRT || objLead.RecordTypeId==strLeadProspectRT || CCPM_utility.IsMergedQuoteLead(objlead) ||
                   objLead.RecordTypeId==strLeadProspectCartRT || (objLead.RecordTypeId==strLeadCustomerCartRT && objLead.CCPM_isManualLead__c))){
                       
                       if(objLead.CCPM_createdChannel__c != null && objLead.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName){
                           mapTelesalesLeadsToCancelTasks.put(objLead.id, Boolean.valueOf(Label.CCPM_boolFalse));
                       }
                       CCPM_SMSMessage__c objSmsMessageForMerge = CCPM_leadTriggerHandlerHelper.populateInitialMessageForMergeCarts(objLead,setQueueIDs);
                       if(objSmsMessageForMerge != null){
                           lstSmsMessage.add(objSmsMessageForMerge);
                       }
                   }
            List<LeadShare> lstLeadShare = new List<leadShare>();
            //ForUAT2   
            if(objlead.Store__c != objLeadOld.Store__c){
                if(objlead.CCPM_storeIDReference__c != null && mapStoreRoleAndGroup.containsKey(objlead.CCPM_storeIDReference__c) && mapStoreRoleAndGroup.get(objlead.CCPM_storeIDReference__c) != null){
                    lstLeadShare.add(CCPM_utility.apexShareEditAccess(objLead.id,mapStoreRoleAndGroup.get(objlead.CCPM_storeIDReference__c).id));
                }
            }
            if(CCPM_Collection.isNotNullEmpty(lstLeadShare)){
                lstLeadShareToInsert.addall(lstLeadShare);
            }
            /*
if(objLeadOld.Store__c!= null){
lstLeadShare = CCPM_leadTriggerHandlerHelper.populateNewLeadShare(objlead, mapStore);
if(objlead.Store__c != objLeadOld.Store__c){
if(CCPM_Collection.isNotNullEmpty(mapExistingRelatedRecs) && mapExistingRelatedRecs.containsKey(objLeadOld.id) && CCPM_Collection.isNotNullEmpty(mapExistingRelatedRecs.get(objLeadOld.id).Shares)){
lstLeadShareToDelete.addall(mapExistingRelatedRecs.get(objLeadOld.id).Shares);
}
}
}
if(CCPM_Collection.isNotNullEmpty(lstLeadShare)){
lstLeadShareToInsert.addall(lstLeadShare);
}
*/
        }
        /**************Second Loop End*/
        for(Task objt : [Select id, Status From Task Where WhoId IN:setLeadIdToCloseTasks AND Status != 'Closed' AND IsClosed = false]){
            objt.Status = 'Closed';
            lstTaskTOUpsert.add(objt);
        }
        if(CCPM_Collection.isNotNullEmpty(lstTaskTOUpsert))
        {
            //insert the list of sms messages records
            try{
                upsert lstTaskTOUpsert;
            }
            Catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while upserting tasks','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        //Update campaign member
        if(CCPM_Collection.isNotNullEmpty(lstCampignMember))
        {
            try{
                update lstCampignMember;
            }
            Catch(Exception e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while updating the Campaign members','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        //Delete ITR Records
        if(CCPM_Collection.isNotNullEmpty(lstDeleteITRMessages))
        {
            //insert the list of sms messages records
            try{
                delete lstDeleteITRMessages;
            }
            Catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while deleting ITRS','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        
        //Insert Lead Shares
        if(CCPM_Collection.isNotNullEmpty(lstLeadShareToInsert))
        {   
            try{
                //Setting the Sharing settings required for the Manager & Assistant Manager to view the records associated with their Store
                insert lstLeadShareToInsert;
            }
            Catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while inserting lead shares','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        if(CCPM_Collection.isNotNullEmpty(lstSmsMessage))
        {
            //upsert the list of sms messages records
            try{
                upsert lstSmsMessage;
            }
            Catch(DMLException e){
                LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_leadTriggerHandler','AfterUpdate','Exception thrown while upserting sms messages','');
                lstleadhdlrLogMsg.add(log);
            }
        }
        //Cancell Telesales tasks for merge leads
        if(CCPM_Collection.isNotNullEmpty(mapTelesalesLeadsToCancelTasks)){
            CCPM_sendSMSMergeManual.updateTaskRecords(mapTelesalesLeadsToCancelTasks);
        }
        //insert all errors
        if(CCPM_Collection.isNotNullEmpty(lstleadhdlrLogMsg)){
            upsert lstleadhdlrLogMsg;
        }
    }
    /**
@author       Bharath Ammanamanchi (Deloitte)
@description  is called in the after delete trigger context
@param        List<SObject>
@return       void
*/ 
    public void AfterDelete(Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        
        Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
    /**
@author       Bharath Ammanamanchi (Deloitte)
@description  is called in the After undelete trigger context
@param        List<SObject>
@return       void
*/ 
    public void AfterUndelete(Map<Id, SObject> mapOldItems){
        /**************Method Declarations Start*/
        Map<id, Lead> mapOld = (Map<id, Lead>)mapOldItems;
        /**************Method Declarations end*/
        
        /**************Methods calling functionalities in other classes start. */
        
        /**************Methods calling functionalities in other classes end.*/
        
        /**************First Loop Start*/
        
        /**************First loop End*/
    }
}