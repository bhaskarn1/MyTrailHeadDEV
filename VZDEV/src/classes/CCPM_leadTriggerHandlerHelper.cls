/**
*@name          CCPM_leadTriggerHandlerHelper 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          10/20/2017
*@description   This is a helpper class for CCPM_leadTriggerHandler
*@Class         CCPM_leadTriggerHandlerHelper
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    10/20/2017   Initial Implementation.
Sriraman Sridharan (Deloitte)       12/16/2017  Updated Version.populateMessageToLeadOwnersWithinBusinessHours
*/
public without sharing class CCPM_leadTriggerHandlerHelper  {
    
    public static Set<String> setQueueIDs = CCPM_utility.populateQueueIds();
    public static String strLeadProspectRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId();
    public static String strLeadProspectCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId();
    public static String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
    public static String strLeadCustomerAbandonedVisit = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerAbandonedVisitlead).getRecordTypeId();
    public static String strLeadCustomerQuoteRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerQuotesRT).getRecordTypeId();    
    public static Set<String> setStrSupervisorRoleName = new Set<String>{Label.CCPM_storeManagerRoleName, label.CCPM_storeAssistantManagerRoleName};
    public static Map<String, String> mapQueueNameIDs = CCPM_utility.populateQueueNameIds();
    public static Boolean isCurrentUserTelesalesUser = CCPM_utility.isCurrentUserTelesalesUser();
    public static Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapBusinessHoursNameRec;
    public static Map<String, Map<String, List<CCPM_journeyMessage__c>>> mapTypeEventNameLstJMRec = CCPM_utility.getEventlstJourneyMessageMap();
    public static Map<String, Map<String, List<CCPM_segmentation__c>>> mapSMSFwrk = CCPM_utility.populateSMSFWRKMaps();
    public static Set<String> setProspectRecordTypeids = new Set<String>{strLeadProspectRT, strLeadProspectCartRT};
    public static Set<String> setCustomerRecordTypeids = new Set<String>{strLeadCustomerCartRT,strLeadCustomerAbandonedVisit,strLeadCustomerQuoteRT};
    public static Map<String, Contact> mapMobileNumContact = new Map<String, Contact>(); 
    public static Map<String,String> mapRecTypeSettings =  CCPM_utility.mapRecordTypes();
    public static Set<String> setRecordTypeidsForSMS = new Set<String>{strLeadCustomerAbandonedVisit,strLeadCustomerQuoteRT};
    public static Map<String, CCPM_smsTemplate__c> mapLeadTypeSMSTemplateRec = getSMSTemplateForSMSMsg(); 
    //public static Map<String, Map<String, List<CCPM_smsTemplate__c>>> mapEventlstSMSTemplate = CCPM_utility.getEventlstSMSTemplateMap();
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method which returns the accounts with the uniqueId on lead
@param         Set<String>
@return        Map<String, Account>
*/
    public static Map<String, Account> getAccUniqIDAccountRecMap(Map<String, Account> mapAccUniqIDsAccRec){
        //Populating the map with accountUniqueID from Lead as Key and Account record as value. This is used in after insert/update.
        Map<String, Account> mapAccUniqueIDAccRec = new Map<String, Account>();
        if(CCPM_Collection.isNotNullEmpty(mapAccUniqIDsAccRec)){
            try{
                
                for(Account objAcc : [Select Id,CCPM_accountUniqueID__c,CCPM_SMSOptOut__c, CCPM_store__c, CCPM_accountNumber__c, CCPM_storeID__c 
                                      ,CCPM_store__r.id,CCPM_store__r.CCPM_storeID__c,CCPM_store__r.CCPM_IsActive__c,CCPM_store__r.CCPM_TimeZone__c
                                      from Account Where CCPM_accountUniqueID__c IN : mapAccUniqIDsAccRec.keySet()]){
                                          mapAccUniqueIDAccRec.put(objAcc.CCPM_accountUniqueID__c, objAcc);   
                                          if(objAcc.CCPM_store__c != null && objAcc.CCPM_storeID__c!= null && objAcc.CCPM_store__r.CCPM_IsActive__c){
                                              CCPM_leadTriggerHandler.setStoreId.add(objAcc.CCPM_store__c); 
                                          }                       
                                      }
            }
            catch(Exception e){
                CCPM_leadTriggerHandler.lstleadhdlrLogMsg.add(CCPM_utility.logMessage(e, 'Error', 'CCPM_leadTriggerHandlerHelper', 'getAccUniqIDAccountRecMap', 'Error while finding Account', ''));
            }
        }
        return mapAccUniqueIDAccRec;
    } 
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns true if the lead account has opted out from SMS. 
@param         Lead, Map<String, Account>
@return        Boolean
*/
    public static Boolean checkAccountOptOut(Lead objLead, Map<String, Account> mapAccUniqueIDAccRec){
        Boolean isOptedOut = false;
        
        if(CCPM_Collection.isNotNullEmpty(mapAccUniqueIDAccRec) && mapAccUniqueIDAccRec.containsKey(objLead.CCPM_accountUniqueID__c) 
           && (mapAccUniqueIDAccRec).get(objLead.CCPM_accountUniqueID__c).CCPM_SMSOptOut__c){
               isOptedOut = true;      
           }
        return isOptedOut;
    }
    
    /**
@author        Bharath Ammanamanchi (Deloitte)
@description   This method returns true if the lead or lead account has opted out from SMS. 
@param         Lead, Map<String, Account>
@return        Boolean
*/
    public Static Boolean checkLeadAccountOptOut(Lead objLead){
        Boolean isOptedOut = false;
        
        if(objLead.CCPM_SMSOptOut__c || objLead.CCPM_smsOptOutAccount__c){
            isOptedOut = true;      
        }
        return isOptedOut;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method sets the lead status to eligible.
@param         Lead, Map<String, Account>
@return        void
*/
    public static void setLeadToEligible(Lead objLead, Map<String, Account> mapAccUniqueIDAccRec){
        if(((objLead.RecordTypeId == strLeadProspectRT || objLead.RecordTypeId == strLeadProspectCartRT) 
            && objLead.Status==Label.CCPM_leadStatusNew && objLead.CCPM_mobileNumber__c!=null) || 
           (setCustomerRecordTypeids.contains(objLead.recordTypeId) && String.isNotBlank(objLead.Status) && CCPM_utility.setleadOpenStatus.contains(objLead.status)
            && ((objLead.CCPM_accountUniqueID__c != null && !checkAccountOptOut(objLead, mapAccUniqueIDAccRec)) || objLead.CCPM_isManualLead__c == true)))
        {
            objLead.CCPM_previousLeadStatus__c = objLead.Status;
            objLead.Status=Label.CCPM_LeadEligibleStatus;    
        }
    }
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to share the Lead with the Assistant Managers by inserting  the Assistant Manager into the Leadshare record.
@param         Lead, Map<String, Account>
@return        void
*/
    public static List<LeadShare> populateNewLeadShare(Lead objLead, Map<Id, CCPM_Store__c> mapStore){
        List<LeadShare> lstLeadShare = new List<LeadShare>();
        //  system.debug('mapstore== '+mapStore.containsKey(objLead.Store__c));
        //  system.debug( 'coll== '+CCPM_Collection.isNotNullEmpty(mapStore));
        if(objLead.Store__c!=null && CCPM_Collection.isNotNullEmpty(mapStore) && mapStore.containsKey(objLead.Store__c) && mapStore.get(objLead.Store__c).Store_Employees__r.size() > 0){
            // System.debug('@@@I am inside populateNewLeadShare IF');
            for(CCPM_storeEmployee__c objstrEmp :  mapStore.get(objLead.Store__c).Store_Employees__r){
                if(objstrEmp.CCPM_employee__c != null && objstrEmp.CCPM_employee__c != objLead.OwnerId)
                {
                    if(objstrEmp.CCPM_role__c == Label.CCPM_storeAssistantManagerRoleName){
                        System.debug('@@@I am inside populateNewLeadShare for asstmgr');
                        lstLeadShare.add(CCPM_utility.apexShareEditAccess(objLead.id,objstrEmp.CCPM_employee__c));
                    }
                }
            }
        }
        return lstLeadShare;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to calculate SMS followipDate for Prospects and Leads
@param         Lead, BusinessHours
@return        void
*/ 
    public static void calcSMSFOllowupDateForProspectAndManualLead(Lead objLead, BusinessHours objBhrs){
        
        Datetime datTfollowup = objlead.CCPM_SMSFollowUpDate__c;
        Map<String, List<CCPM_segmentation__c>> mapEvntCalcFolup = mapSMSFwrk.get('EventFwrkActualSMSDtTimeMap');
        Map<String, List<CCPM_segmentation__c>> mapEvntEventSMS = mapSMSFwrk.get('EventFwrkMap');
        if(objLead != null && objBhrs != null && CCPM_Collection.isNotNullEmpty(mapEvntCalcFolup)
           && String.isNotBlank(objLead.CCPM_eventType__c) && mapEvntCalcFolup.containsKey(objLead.CCPM_eventType__c) && mapEvntEventSMS.containsKey(objLead.CCPM_eventType__c)){
               //Converting System.now to the Owner timezone
               DateTime datTNowForEvent = CCPM_utility.getNowInTimeZone(objBhrs.TimeZoneSidkey);
               Datetime datTSMSFollowupStartDate, datTSMSFollowupEndDate;		  
               CCPM_segmentation__c objSeg = mapEvntCalcFolup.get(objLead.CCPM_eventType__c)[0];
               if(String.isNotBlank(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpStartDate__c)){
                   datTSMSFollowupStartDate = CCPM_utility.getDtTimeForTimeZone(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpStartDate__c, objBhrs.TimeZoneSidkey);       
               }
               if(String.isNotBlank(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpEndDate__c)){
                   datTSMSFollowupEndDate = CCPM_utility.getDtTimeForTimeZone(objSeg.CCPM_campaign__r.CCPM_eventSMSFollowUpEndDate__c, objBhrs.TimeZoneSidkey);       
               }
               if(datTfollowup != null){
                   if(datTSMSFollowupStartDate != null && datTNowForEvent <= datTSMSFollowupStartDate && (datTSMSFollowupEndDate == null || (datTSMSFollowupEndDate != null && datTfollowup < datTSMSFollowupEndDate))){
                       datTfollowup = datTSMSFollowupStartDate;    
                   }
                   else if(datTSMSFollowupEndDate != null && datTfollowup >= datTSMSFollowupEndDate){
                       datTfollowup = datTSMSFollowupEndDate;
                   }
               }
           }
        if(datTfollowup != null){
            objlead.CCPM_SMSFollowUpDate__c = datTfollowup;
            datTfollowup = CCPM_utility.calculateTimeToTriggerSMSWithInBusinessHours(objBhrs, datTfollowup);
            objlead.CCPM_ActualSMSScheduleDateTime__c = datTfollowup;
        }
        if(String.isNotBlank(objLead.CCPM_eventType__c) && CCPM_Collection.isNotNullEmpty(mapEvntEventSMS) && mapEvntEventSMS.containsKey(objLead.CCPM_eventType__c)){
            objlead.CCPM_eventTypeCampaign__c = mapEvntEventSMS.get(objLead.CCPM_eventType__c)[0].CCPM_campaign__c;
        }
    }
    

    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create sms message custom object to send initial messages for leads or prospects
@param         Lead, Map<String, Account>
@return        CCPM_SMSMessage__c
*/
    public static CCPM_SMSMessage__c populateInitialSMS(Lead objlead, Map<String, Account> mapAccUniqueIDAccRec){
        CCPM_SMSMessage__c objSmsMessage = null;
        String strCommType = Label.CCPM_taskCommunicationOutbound;
        String strMessage = '';
        
        if(String.isNotBlank(objlead.CCPM_mobileNumber__c) && !CCPM_utility.setleadStatusTOExclude.contains(objlead.Status) && (!CCPM_utility.isCurrentUserTelesalesUser  && objLead.CCPM_leadType__c!=Label.CCPM_telesalesManualPOStype)
           && !(objlead.CCPM_DismissedLead__c&& CCPM_utility.setleadOpenStatus.contains(objLead.status)) && objlead.ownerid!=null && CCPM_Collection.isNotNullEmpty(setQueueIDs) 
           && !setQueueIDs.contains(objlead.ownerid)){
           	
			if(CCPM_utility.isManualLeadOrProspect(objlead)){
				if(String.isNotBlank(objLead.Status) && objLead.Status == Label.CCPM_LeadEligibleStatus){
					objSmsMessage = createSMSFromEventFrwk(objlead);	
				}
			}
            else if(objLead.CCPM_isInitialSMSSent__c == false){
            	objSmsMessage = createSMSFromSMSFwrk(objlead, 'Initial'); 	
            }
		}
        return objSmsMessage;
    }
    
        /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create sms message custom object to send initial messages from SMS Framework
@param         Lead, String
@return        CCPM_SMSMessage__c
*/
    public static CCPM_SMSMessage__c createSMSFromSMSFwrk(Lead objlead, String strSMSType){
    	CCPM_SMSMessage__c objSMSMessage = null;
    	if(!checkLeadAccountOptOut(objlead)){
    		
    		String strMTN = objlead.CCPM_mobileNumber__c;
	        String strCommType = Label.CCPM_taskCommunicationOutbound;
    		String strLiveTextNum = objLead.CCPM_leadType__c.contains('Customer') ? Label.CCPM_liveTextPhoneNumber : Label.CCPM_liveTextNumberNonVerizon;
    		String strMessage = '';
			String strMessageType = ''; 
			Datetime dtTSMSSchedule = null;
    		
			Map<String, List<CCPM_segmentation__c>> mapSmsFwrk = mapSMSFwrk.get('SMSFwrkMap');
			if(CCPM_Collection.isNotNullEmpty(mapSmsFwrk.get(objLead.CCPM_leadType__c))){
				for(CCPM_segmentation__c objSeg : mapSmsFwrk.get(objLead.CCPM_leadType__c)){
					
					if(checkSegFieldContains(objSeg.CCPM_markets__c, objlead.CCPM_storeMarket__c) && checkSegFieldContains(objSeg.CCPM_territories__c, objlead.CCPM_storeTerritory__c) && 
	            		(checkSegFieldContains(objSeg.CCPM_districts1__c, objlead.CCPM_storeDistrict__c) || checkSegFieldContains(objSeg.CCPM_districts2__c, objlead.CCPM_storeDistrict__c) 
	            		|| checkSegFieldContains(objSeg.CCPM_districts3__c, objlead.CCPM_storeDistrict__c))){
	            		
	            		if(CCPM_Collection.isNotNullEmpty(objSeg.CCPM_smsTemplates__r)){
	            			for(CCPM_smsTemplate__c objSMSTemp : objSeg.CCPM_smsTemplates__r){
	            				if(objSMSTemp.CCPM_startDate__c <= System.now() &&(objSMSTemp.CCPM_endDate__c == null || (objSMSTemp.CCPM_endDate__c != null && System.now() <= objSMSTemp.CCPM_endDate__c))){
	            					if(strSMSType == 'Initial' && String.isNotBlank(objSMSTemp.CCPM_initialMessage__c)){
	            						strMessage = objSMSTemp.CCPM_initialMessage__c;
	            						strMessageType = objSMSTemp.CCPM_initialMessageType__c;
	            						dtTSMSSchedule = objlead.CCPM_ActualSMSScheduleDateTime__c;
	            					}
	            					else if(strSMSType == 'FollowUp' && String.isNotBlank(objSMSTemp.CCPM_followupMessage__c)){
	            						strMessage = objSMSTemp.CCPM_followupMessage__c;
	            						strMessageType = objSMSTemp.CCPM_followUpMessageType__c;
	            						dtTSMSSchedule = objlead.CCPM_triggerFollowupSMSDateTime__c;
	            					}
	            				}
	            			}
	            		}			
	            	}
				} 
			}
			else if(strSMSType == 'FollowUp' && String.isNotBlank(objLead.CCPM_leadType__c) && objLead.CCPM_leadType__c == 'Customer Campaign' && String.isNotBlank(objlead.CCPM_CampingFollowUpMessageTemplate__c)){
				strMessage = objlead.CCPM_CampingFollowUpMessageTemplate__c;
				strMessageType = Label.CCPM_CampaignFollowUp;
				dtTSMSSchedule = objlead.CCPM_triggerFollowupSMSDateTime__c;
			}
			
			if(String.isNotBlank(strMessage)){
				objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage,strMTN,strMessageType,strCommType,dtTSMSSchedule,strLiveTextNum);
			}
    	}
    	return objSMSMessage;
    }
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create SMS for prospects and Manual Leads
@param         Lead
@return        CCPM_SMSMessage__c
*/ 
    
    public static Datetime datTSysNowForEvent = CCPM_utility.datTSysNowForEvent; 
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create SMS for prospects and Manual Leads
@param         Lead
@return        CCPM_SMSMessage__c
*/ 
    public static CCPM_SMSMessage__c createSMSFromEventFrwk(Lead objlead){
        Map<String, List<CCPM_segmentation__c>> mapEvntEventSMS = mapSMSFwrk.get('EventFwrkMap');
        CCPM_SMSMessage__c objSMSMessage = null;
        if(CCPM_Collection.isNotNullEmpty(mapEvntEventSMS) && objLead != null && String.isNotBlank(objLead.CCPM_eventType__c) && mapEvntEventSMS.containsKey(objLead.CCPM_eventType__c)){
            BusinessHours objBhrs = CCPM_utility.getBusinessBrsForLead(objlead);
            for(CCPM_segmentation__c objSeg : mapEvntEventSMS.get(objLead.CCPM_eventType__c)){
                if(checkSegFieldContains(objSeg.CCPM_markets__c, objlead.CCPM_storeMarket__c) && checkSegFieldContains(objSeg.CCPM_territories__c, objlead.CCPM_storeTerritory__c) && 
            	  (checkSegFieldContains(objSeg.CCPM_districts1__c, objlead.CCPM_storeDistrict__c) || checkSegFieldContains(objSeg.CCPM_districts2__c, objlead.CCPM_storeDistrict__c) 
            		|| checkSegFieldContains(objSeg.CCPM_districts3__c, objlead.CCPM_storeDistrict__c))){
                       Datetime datTEvntStartDate, datTEvntEndDate;
                       DateTime datTNowForEvent = CCPM_utility.getNowInTimeZone(objBhrs.TimeZoneSidkey);
                       if(objSeg.CCPM_campaign__r.CCPM_eventStartDate__c != null){
                           datTEvntStartDate = CCPM_utility.getDtTimeForTimeZone(objSeg.CCPM_campaign__r.CCPM_eventStartDate__c, objBhrs.TimeZoneSidkey);	       
                       }
                       if(objSeg.CCPM_campaign__r.CCPM_eventEndDate__c != null){
                           datTEvntEndDate = CCPM_utility.getDtTimeForTimeZone(objSeg.CCPM_campaign__r.CCPM_eventEndDate__c, objBhrs.TimeZoneSidkey);	       
                       }
                       
                       if(datTEvntStartDate != null && datTNowForEvent >= datTEvntStartDate && (datTEvntEndDate == null || (datTEvntEndDate != null && datTNowForEvent <= datTEvntEndDate)) && CCPM_Collection.isNotNullEmpty(objSeg.CCPM_smsTemplates__r)){
                           for(CCPM_smsTemplate__c objSMSTemp : objSeg.CCPM_smsTemplates__r){
                               Datetime datTEvntMsgStartDate, datTEvntMsgEndDate;
                               if(objBhrs != null){
                                   if(String.isNotBlank(objSMSTemp.CCPM_eventMessageStartDate__c)){
                                       datTEvntMsgStartDate = CCPM_utility.getDtTimeForTimeZone(objSMSTemp.CCPM_eventMessageStartDate__c, objBhrs.TimeZoneSidkey);                                  		system.debug('==startedate '+datTEvntMsgStartDate);
                                   }
                                   if(String.isNotBlank(objSMSTemp.CCPM_eventMessageEndDate__c)){
                                       datTEvntMsgEndDate = CCPM_utility.getDtTimeForTimeZone(objSMSTemp.CCPM_eventMessageEndDate__c, objBhrs.TimeZoneSidkey);
                                   }
                               }
                               if(datTEvntMsgStartDate < objlead.CCPM_SMSFollowUpDate__c && (datTEvntMsgEndDate == null || (datTEvntMsgEndDate != null && objlead.CCPM_SMSFollowUpDate__c <= datTEvntMsgEndDate))){
                                   String strMTN = objlead.CCPM_mobileNumber__c;
                                   String strCommType = Label.CCPM_taskCommunicationOutbound;
                                   String strSMSMessage = objSMSTemp.CCPM_prospectMessage__c;
                                   String strMessageType = Label.CCPM_MessageTypeProspectFirstSMSPart1; 
                                   String strLiveTextNum = Label.CCPM_liveTextNumberNonVerizon;
                                   if(setCustomerRecordTypeids.contains(objLead.recordTypeId)){
                                       strSMSMessage = objSMSTemp.CCPM_customerMessage__c;
                                       strLiveTextNum = Label.CCPM_liveTextPhoneNumber;
                                   }
                                   objSMSMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strSMSMessage,strMTN,strMessageType,strCommType,objlead.CCPM_ActualSMSScheduleDateTime__c,strLiveTextNum);
                                   if(objSMSTemp.CCPM_doNotOverrideEcode__c){
                                       objSMSMessage.CCPM_dynamicECODE__c = objlead.CCPM_ownerEcode__c;
                                   }
                               }
                           }       
                       }    
                 }
            }
        }
        return objSMSMessage;
    }
    
    
    /**
@author        Sriraman Sridharan(Deloitte)
@description   Method to process messages on update
@param         Lead, Lead, Map<String, Account>
@return        CCPM_SMSMessage__c
*/  
    public static List<CCPM_SMSMessage__c> processSMSMessageOnUpdate(Lead objLead,Lead objLeadOld, Lead objLeadWithRelatedListRecs,Map<String, Account> mapAccUniqueIDAccRec,Map<id,User> mapLeadOwners){
        List<CCPM_SMSMessage__c> lstSMSMsg = new List<CCPM_SMSMessage__c>();
        if(objLead != null){
            //Message to customers if lead
            if(!objLead.CCPM_isInformaticaMerge__c && (((objLead.OwnerId != objLeadOld.OwnerId) && setQueueIDs.contains(objLeadOld.OwnerId)) 
               || (CCPM_utility.isManualLeadOrProspect(objLead) && ((String.isNotBlank(objlead.CCPM_eventType__c) && objLead.CCPM_eventType__c != objLeadOld.CCPM_eventType__c)))
               || (objLead.OwnerId != objLeadOld.OwnerId && !setQueueIDs.contains(objLead.OwnerId))
               || (objLead.CCPM_HotFixFlagToSendInitialSMS__c != objLeadOld.CCPM_HotFixFlagToSendInitialSMS__c && objLead.CCPM_HotFixFlagToSendInitialSMS__c))){
                   
                   CCPM_SMSMessage__c objSMSinitialMessage = populateInitialSMS(objLead, mapAccUniqueIDAccRec);
                   if(objSMSinitialMessage != null){
                       lstSMSMsg.add(objSMSinitialMessage);
                   }
               }
            //Insert Follow up messages
            if(objLead.CCPM_isInitialSMSSent__c!= objLeadOld.CCPM_isInitialSMSSent__c && objLead.CCPM_isInitialSMSSent__c  && !objLead.CCPM_isFollowUpSMSSent__c && !objlead.CCPM_DismissedLead__c){
                CCPM_SMSMessage__c objSMSFollowUpMessage = new CCPM_SMSMessage__c();
                objSMSFollowUpMessage = createSMSFromSMSFwrk(objlead, 'FollowUp');
                if(objSMSFollowUpMessage != null){
                    lstSMSMsg.add(objSMSFollowUpMessage);
                }
            }
            //Insert Message to lead owner on owner change
            if(objLead.OwnerId != objLeadOld.OwnerId && !setQueueIDs.contains(objLead.OwnerId)){
                if((objLead.Status == Label.CCPM_leadStatusQualified && objLead.CCPM_leadSubStatus__c != Label.CCPM_subStatusDisinterested) || 
                   (objLead.Status == Label.CCPM_leadStatusResponded && objLead.CCPM_leadSubStatus__c == Label.CCPM_subStatusActionRequired)){
                       String strMessage = objlead.CCPM_ManuallyChangeOwnershipMessage__c;
                       CCPM_SMSMessage__c objSMSMsgOwnerAndStatusChange = new CCPM_SMSMessage__c();
                       if(CCPM_Collection.isNotNullEmpty(mapLeadOwners) && mapLeadOwners.containsKey(objlead.OwnerId) && mapLeadOwners.get(objlead.OwnerId).mobilephone != null){
                           objSMSMsgOwnerAndStatusChange = populateMessageToLeadOwnersWithinBusinessHours(objlead,strMessage, mapLeadOwners);
                           if(objSMSMsgOwnerAndStatusChange != null){
                               lstSMSMsg.add(objSMSMsgOwnerAndStatusChange);
                           }  
                       }
                   }
            }
            //Insert Message to lead owner on first positive customer response
            if(objLead.CCPM_leadSubStatus__c != objLeadOld.CCPM_leadSubStatus__c &&
               objLead.Status==Label.CCPM_leadStatusResponded && objLead.CCPM_leadSubStatus__c == Label.CCPM_subStatusActionRequired && 
               objLead.CCPM_lastInteraction__c!=objLeadOld.CCPM_lastInteraction__c && CCPM_Collection.isNotNullEmpty(mapLeadOwners)){
                   String strMessage = '';
                   if(objLead.CCPM_Type__c == Label.CCPM_leadTypeCampaignLead) {
                       strMessage = 'Hi '+ mapLeadOwners.get(objLead.OwnerId).firstname + ', a lead contacted for a campaign, '+objLead.LastName+' has responded. Please view \'Leads Requiring Action\' in Salesforce to take action.';
                   } else {
                       strMessage = 'Hi '+ mapLeadOwners.get(objLead.OwnerId).firstname + ', '+objLead.LastName+' has responded. Please review \'Leads Requiring Action\' in Salesforce and take appropriate action.';
                   }
                   CCPM_SMSMessage__c objSMSMsgForCustomerResponse = new CCPM_SMSMessage__c();
                   if(CCPM_Collection.isNotNullEmpty(mapLeadOwners) && mapLeadOwners.containsKey(objlead.OwnerId) && mapLeadOwners.get(objlead.OwnerId).mobilephone != null){
                       objSMSMsgForCustomerResponse = populateMessageToLeadOwnersWithinBusinessHours(objlead,strMessage, mapLeadOwners);
                       if(objSMSMsgForCustomerResponse != null){
                           lstSMSMsg.add(objSMSMsgForCustomerResponse);
                       }
                   }
               }
            
            //Update messages for all conditions
            if(objLeadWithRelatedListRecs != null && CCPM_Collection.isNotNullEmpty(objLeadWithRelatedListRecs.SMS_Message_Sent__r)){
                for(CCPM_SMSMessage__c objSMSMsgForEventChange : objLeadWithRelatedListRecs.SMS_Message_Sent__r){
                    Boolean boolIsChanged = false;
                    if(objSMSMsgForEventChange != null){
                        
                        //Update message on change in event date time
                        if(objLead.CCPM_SMSFollowUpDate__c != objLeadOld.CCPM_SMSFollowUpDate__c){
                            objSMSMsgForEventChange.CCPM_ScheduleDateTime__c = objLead.CCPM_ActualSMSScheduleDateTime__c;
                            boolIsChanged = true;
                        }   
                        //Update owner name on the sms messages on lead owner change
                        if((objLead.OwnerId != objLeadOld.OwnerId && !setQueueIDs.contains(objLead.OwnerId))
                           &&(objSMSMsgForEventChange.CCPM_messageType__c != Label.CCPM_MessageTypeProspectFirstSMSPart1)){
                               
                               if(CCPM_Collection.isNotNullEmpty(mapLeadOwners) && mapLeadOwners.containsKey(objLead.OwnerId)){
                                   updateMessageBodyonLeadOwnerChange(objlead,objLeadOld,objSMSMsgForEventChange, mapLeadOwners);
                                   boolIsChanged = true;
                               }
                           }
                        //Update messages for converted leads 
                        //OR queued leads 
                        //OR responded leads 
                        //OR on Event Change or Owner CHange for prospect/Manual Lead
                        //on owner change for Abandoned Visits and Customer Quotes
                        //OR dismissed leads
                        //OR Informatica Merge
                        system.debug('@@@ CCPM_utility.IsMergedQuoteLead(objlead): ' + CCPM_utility.IsMergedQuoteLead(objlead));
                        system.debug('@@@ !CCPM_utility.IsMergedLeadAbandonedVisit(objLead): ' + CCPM_utility.IsMergedLeadAbandonedVisit(objLead));
                        system.debug('@@@ : ' + objLead.CCPM_informaticaMergeLeadType__c);
                        if((objLead.Status != objLeadOld.Status && CCPM_utility.setleadClosedStatus.contains(objLead.Status))
                           || 
                           (objLead.OwnerId != objLeadOld.OwnerId && setQueueIDs.contains(objLead.OwnerId)) 
                           ||
                           (objLead.Status != objLeadOld.Status && (objLead.Status == Label.CCPM_leadStatusResponded || objLead.Status == Label.CCPM_leadStatusQualified) &&
                            objSMSMsgForEventChange != null && objSMSMsgForEventChange.CCPM_messageType__c == Label.CCPM_MessageTypeFollowUp)
                           ||
                           (CCPM_utility.isManualLeadOrProspect(objLead) && !(CCPM_utility.setleadClosedStatus.contains(objLead.Status)) && String.isNotBlank(objLead.CCPM_eventType__c) &&
                            (objLead.CCPM_eventType__c != objLeadOld.CCPM_eventType__c || (objLead.OwnerId != objLeadOld.OwnerId && !setQueueIDs.contains(objLead.OwnerId))) && objSMSMsgForEventChange.CCPM_messageType__c == Label.CCPM_MessageTypeProspectFirstSMSPart1 && 
                            (objSMSMsgForEventChange.CCPM_MessageStatus__c == Label.CCPM_messageStatusQueued || objSMSMsgForEventChange.CCPM_MessageStatus__c == Label.CCPM_messageStatusError))
                           ||
                           objlead.CCPM_DismissedLead__c&& CCPM_utility.setleadOpenStatus.contains(objLead.status)
                           && CCPM_utility.setSMSMessageTypeforDismissedLead.contains(objSMSMsgForEventChange.CCPM_messageType__c)
                           ||
                           (objLead != null && objLeadOld != null && objLead.Status != null && ccpm_utility.setLeadOpenStatusWithoutNew.contains(objLead.Status) 
                            && objLead.CCPM_Type__c != null && objLead.CCPM_Type__c != Label.CCPM_leadTypeCampaignLead && objLead.CCPM_mobileNumber__c != null 
                            && (objLead.RecordTypeId==strLeadCustomerCartRT  || CCPM_utility.IsMergedQuoteLead(objlead) || objLead.RecordTypeId==strLeadProspectRT || objLead.RecordTypeId==strLeadProspectCartRT)
                            && !objLead.CCPM_smsOptOutAccount__c
                            && !CCPM_utility.IsMergedLeadAbandonedVisit(objlead) //No Follow up to be cancelled for empty store visits
                            && objLeadOld.CCPM_isInformaticaMerge__c == false && objLead.CCPM_isInformaticaMerge__c == true 
                            && objLead.Ownerid!=null && CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objLead.ownerid)
                            && ((!CCPM_utility.IsMergedQuoteLead(objlead) && objLead.LeadSource == Label.CCPM_LeadSourceNetace) || setRecordTypeidsForSMS.contains(objLeadOld.recordTypeId) || 
                  				(CCPM_utility.IsMergedQuoteLead(objlead) && (objLead.LeadSource != Label.CCPM_LeadSourceNetace)))
                            && ((objLead.status!=null && (objLead.status == Label.CCPM_LeadEligibleStatus || objLead.status == Label.CCPM_Contacted)) || (objLead.RecordTypeId==strLeadProspectRT || (objLead.RecordTypeId==strLeadCustomerCartRT && objLead.CCPM_isManualLead__c)))))
                            
                        {
                            system.debug('@@@ : Inside');
                            objSMSMsgForEventChange.CCPM_MessageStatus__c = Label.CCPM_SMSStatusRemoved;
                            boolIsChanged = true;
                        }
                        
                    }
                    if(boolIsChanged){
                        lstSMSMsg.add(objSMSMsgForEventChange);
                    }
                }
            }
        }
        return lstSMSMsg;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create task for Telesales
@param         Lead
@return        Task
*/ 
    public static Task populateActivityForTelesales(Lead objLead){
        Task objTask = null;
        if(!CCPM_utility.setleadStatusTOExclude.contains(objlead.Status) && (isCurrentUserTelesalesUser || objLead.CCPM_leadType__c==Label.CCPM_telesalesManualPOStype))
        {
            //check if the lead owner is a queue
            if(objlead.ownerid!=null && CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objlead.ownerid)){
                if(objlead.recordTypeId == strLeadProspectRT
                   || ( objlead.recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId()
                       && objlead.CCPM_Type__c == Label.CCPM_leadTypeManualLead)){
                           Id idTaskTODORecType = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Label.CCPM_taskToDoRT).getRecordTypeId();
                           objTask = new Task(RecordTypeId = idTaskTODORecType, Subject = Label.CCPM_telesalesTaskSubject, OwnerId = objLead.OwnerId
                                              , ActivityDate = objLead.CCPM_SMSFollowUpDate__c.date(), ReminderDateTime = objLead.CCPM_SMSFollowUpDate__c
                                              , Status = Label.CCPM_telesalesTaskStatus, Priority = Label.CCPM_taskPriorityNormal, WhoId = objLead.Id
                                              , IsReminderSet = true);
                       }   
            }
        }
        return objTask;
    }
    
    
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to Asign Account details to lead if Account Unique Id is found
@param         Lead, Map<String, Account>
@return        void
*/
    public static void assignAccountDetailsToLead(lead objLead, Map<String, Account> mapAccUniqueIDAccRec){
        if(CCPM_Collection.isNotNullEmpty(mapAccUniqueIDAccRec) && String.isNotBlank(objLead.CCPM_accountUniqueID__c) && mapAccUniqueIDAccRec.containsKey(objLead.CCPM_accountUniqueID__c)){
            Account objAccount = mapAccUniqueIDAccRec.get(objLead.CCPM_accountUniqueID__c);
            objlead.CCPM_Account__c     = objAccount.Id;
            objlead.CCPM_accountNumber__c= objAccount.CCPM_accountNumber__c;
        }
    }
    /**
@author        Ritwik Koneru(Deloitte)
@description   Method to get list of contacts with MTN
@param         None
@return        None
*/
    public static void populateMTNContactList (){
        list<String> lstMTN = new list<String>();
        set<String> setMTN = new set<String>();
        if(CCPM_Collection.isNotNullEmpty(mapMobileNumContact)){
            setMTN = mapMobileNumContact.keySet();
            
            lstMTN.addall(setMTN);
            
            String strBuildSOSLQuery = 'FIND ';
            strBuildSOSLQuery = strBuildSOSLQuery + '\''+String.join(lstMTN, ' OR ')+'\' IN PHONE FIELDS RETURNING CONTACT (id, ccpm_itemInterestedIn__c,'+
                'FirstName, LastName, Salutation,CCPM_communicationPreference__c,AccountId,CCPM_state__c,'+
                'CCPM_accountNumber__c, MobilePhone,Email)';
            List<List<sObject>> lstSearchLead = Search.query(strBuildSOSLQuery);
            for(Contact objCon : (List<Contact>)lstSearchLead[0]){
                if(mapMobileNumContact.containsKey(objCon.MobilePhone)){
                    mapMobileNumContact.put(objCon.MobilePhone, objCon);    
                }
            }
        }
    }
    
    /**
@author        Ritwik Koneru(Deloitte)
@description   Method to create or update contact record upon lead insert
@param         Lead, Map<String, Account>
@return        Contact
*/
    public static Contact getAssociatedContactToLead(lead objLead){
        
        Contact objCont = null;
        
        if (objLead.status != Label.CCPM_expiredLeadStatus) {
            objCont = getContactLeadMap(objlead);
            if(mapMobileNumContact.containskey(objLead.ccpm_mobilenumber__c)){
                objCont.id = mapMobileNumContact.get(objLead.ccpm_mobileNumber__c).id != null ? mapMobileNumContact.get(objLead.ccpm_mobileNumber__c).id : null;
            }
        }
        return objCont; 
    }
    
    /**
@author        Ritwik Koneru(Deloitte)
@description   Method to create or update contact record upon lead update
@param         Lead, Lead, Map<String, Account>
@return        Contact
*/
    public static Contact getAssociatedContactToLeadonUpdate(lead objLeadOld, lead objLead){
        
        Contact objCont = null;
        Boolean isValueChanged = false;
       
            if (mapMobileNumContact.containskey(objLead.ccpm_mobilenumber__c)){
                isValueChanged = isLeadValueChanged (objLeadOld,objLead);
                if (isValueChanged){
                    objCont = getContactLeadMap(objlead);
                    objCont.id = mapMobileNumContact.get(objLead.ccpm_mobileNumber__c).id != null ? mapMobileNumContact.get(objLead.ccpm_mobileNumber__c).id : null;
                } 
            } else {
                objCont = getContactLeadMap(objlead);
            }
        return objCont; 
    }
    
    /**
@author        Ritwik Koneru(Deloitte)
@description   Method to return if lead record fields are changed
@param         Lead
@return        Boolean
*/
    public static Boolean isLeadValueChanged(lead objOldLead,lead objLead){
        Boolean isValueChanged = false;
        set<String> fieldSet = new set<String>{'CCPM_usstate__c','ccpm_mobileNumber__c','ccpm_email__c',
            'firstName','lastName','ccpm_accountNumber__c','ccpm_account__c',
            'ccpm_communicationPreference__c','ccpm_itemInterestedIn__c',
            'Salutation'};
                
                for (String str : fieldSet) {
                    if (!isValueChanged){
                        if (objOldLead.get(str) != objLead.get(str)) {
                            isValueChanged = true;
                        }
                    }
                }
        return isValueChanged;
    }
    
    /**
@author        Ritwik Koneru(Deloitte)
@description   Method to return contact record
@param         Lead
@return        Contact
*/
    public static contact getContactLeadMap(lead objLead) {
        
        Contact objCont = new Contact();
        
        objCont.firstName = objlead.firstName;
        objCont.lastName = objLead.lastName;
        objCont.email = objLead.ccpm_email__c;
        objCont.mobilePhone = objLead.ccpm_mobileNumber__c;
        objCont.CCPM_itemInterestedIn__c = (objLead.ccpm_itemInterestedIn__c == '--None--')?'':objLead.ccpm_itemInterestedIn__c;
        objCont.CCPM_communicationPreference__c = (objLead.ccpm_communicationpreference__c=='--None--')?'':objLead.ccpm_communicationpreference__c;   objCont.email = objLead.ccpm_email__c;
        objCont.ccpm_state__c = objLead.ccpm_usstate__c;
        objCont.AccountId = objlead.CCPM_Account__c;
        objCont.ccpm_accountNumber__c = objLead.ccpm_accountNumber__c;
        objCont.salutation = objLead.salutation;
        
        return objCont;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to Asign Owner, Store, Timezone on lead, Store Manager on Lead
@param         Lead, CCPM_Store__c, Boolean
@return        void
*/
    public static void assignOwner(Lead objlead, Lead objLeadOld, Map<Id, CCPM_Store__c> mapStore, Map<String,CCPM_Store__c> mapStoreId, CCPM_storeEmployee__c objcurrUserOrLeadOwnerStrEmpRec,Map<String, CCPM_storeEmployee__c> mapCartLastHandledBy, Map<String, Account> mapAccUniqueIDAccRec){
        boolean boolassignToHQqueue = false;
        boolean boolAssignDoneByCartLasthandledBy = false;
        boolean boolAssignDoneByStoreId = false;
        boolean boolAccountChanged = false;
        boolean boolReassignCommissionableOwner = false;
        boolean boollasthandledByisChanged = false;
        boolean boolstoreIdIsChanged = false;
        boolean boolAccountIdIsChanged = false;
        boolean boolevaluvateOwnerChangeOnUpdate = false;
        
        if(objlead != null && objLeadOld != null){
            if(!setQueueIDs.contains(objLead.OwnerId) && objLead.OwnerId !=  objLeadOld.OwnerId){
                if(objcurrUserOrLeadOwnerStrEmpRec == null){
                    objLead.addError('Please ensure the lead owner is a store employee.');
                }
                else{
                    boolevaluvateOwnerChangeOnUpdate = true;
                }
            }     
            if(objLead.CCPM_cartlastHandledBy__c != objLeadOld.CCPM_cartlastHandledBy__c){
                boollasthandledByisChanged = true;
                boolevaluvateOwnerChangeOnUpdate = true;
            }
            if(objLead.CCPM_storeID__c != objLeadOld.CCPM_storeID__c){
                boolstoreIdIsChanged = true;
                boolevaluvateOwnerChangeOnUpdate = true;
            }
            if(objLead.CCPM_accountUniqueID__c != objLeadOld.CCPM_accountUniqueID__c){
                boolAccountIdIsChanged = true;
                boolevaluvateOwnerChangeOnUpdate = true;
            }
            /*
if(objcurrUserOrLeadOwnerStrEmpRec!= null && objlead.Status!= objLeadOld.Status && objlead.Status == Label.CCPM_leadStatusConverted && objlead.CCPM_cartlastHandledBy__c != null 
&& objlead.CCPM_lastInteraction__c != null && objcurrUserOrLeadOwnerStrEmpRec.CCPM_employee__r.CCPM_commissionableRepID__c != objlead.CCPM_cartlastHandledBy__c){
boolReassignCommissionableOwner = true;
}
*/
        }
        
        Set<String> setTelesalesCustomerType = new Set<String>{Label.CCPM_CustomerTelesalesSFDCManual, Label.CCPM_telesalesManualPOStype};
            if(objLeadOld == null || boolevaluvateOwnerChangeOnUpdate){
                if(objcurrUserOrLeadOwnerStrEmpRec != null){
                    system.debug('@@@ objcurrUserOrLeadOwnerStrEmpRec.CCPM_employee__c:' + objcurrUserOrLeadOwnerStrEmpRec.CCPM_employee__c);
                    objlead.OwnerId = objcurrUserOrLeadOwnerStrEmpRec.CCPM_employee__c;
                    assignStoreDetails(objlead, mapStore.get(objcurrUserOrLeadOwnerStrEmpRec.CCPM_Store__c), true);
                    if(CCPM_Collection.isNotNullEmpty(mapStore) && mapStore.containsKey(objcurrUserOrLeadOwnerStrEmpRec.CCPM_Store__c) && mapStore.get(objcurrUserOrLeadOwnerStrEmpRec.CCPM_Store__c).Store_Employees__r.size() > 0){
                        for(CCPM_storeEmployee__c objstrEmp :  mapStore.get(objcurrUserOrLeadOwnerStrEmpRec.CCPM_Store__c).Store_Employees__r){
                            if(setStrSupervisorRoleName.contains(objstrEmp.CCPM_Role__c)){
                                objlead.CCPM_storeManager__c = objstrEmp.CCPM_employee__c;
                                break;
                            }
                        }
                    }
                }
                else if(objcurrUserOrLeadOwnerStrEmpRec == null && !setTelesalesCustomerType.contains(objlead.CCPM_leadType__c)){
                    if((objLeadOld == null || boollasthandledByisChanged) && objLead.CCPM_cartlastHandledBy__c!=null){
                        system.debug('@@@ :objLead.CCPM_cartlastHandledBy__c : ' + objLead.CCPM_cartlastHandledBy__c);
                        if(CCPM_Collection.isNotNullEmpty(mapCartLastHandledBy) && mapCartLastHandledBy.containsKey(objLead.CCPM_cartlastHandledBy__c)){
                            //Get the store employee for ownership 
                            CCPM_storeEmployee__c objStoreEmp = mapCartLastHandledBy.get(objLead.CCPM_cartlastHandledBy__c);
                            if(objStoreEmp != null){
                                system.debug('@@@ objStoreEmp.CCPM_employee__c: ' + objStoreEmp.CCPM_employee__c);
                                objLead.OwnerId = objStoreEmp.CCPM_employee__c;
                                assignStoreDetails(objlead, mapStore.get(objStoreEmp.CCPM_Store__c), true);
                                for(CCPM_storeEmployee__c objstrEmp :  mapStore.get(objStoreEmp.CCPM_Store__c).Store_Employees__r){
                                    if(setStrSupervisorRoleName.contains(objstrEmp.CCPM_Role__c)){
                                        objlead.CCPM_storeManager__c = objstrEmp.CCPM_employee__c;              
                                        break;
                                    }
                                }
                                boolAssignDoneByCartLasthandledBy = true;
                            }
                        }
                    }
                    
                    if((objLeadOld == null ||boolstoreIdIsChanged) && !boolAssignDoneByCartLasthandledBy && objLead.CCPM_storeID__c!= null){
                        Boolean boolassignToMarketQueue = true;
                        
                        if(CCPM_Collection.isNotNullEmpty(mapStoreId) && mapStoreId.containsKey(objLead.CCPM_storeID__c)){
                            CCPM_store__c objStore = mapStoreId.get(objLead.CCPM_storeID__c);
                            if(objStore != null){
                                assignStoreDetails(objlead, objStore, true);
                                for(CCPM_storeEmployee__c objstrEmp :  objStore.Store_Employees__r){
                                    if(setStrSupervisorRoleName.contains(objstrEmp.CCPM_Role__c)){
                                        objlead.OwnerId = objstrEmp.CCPM_employee__c;
                                        objlead.CCPM_storeManager__c = objstrEmp.CCPM_employee__c;
                                        boolassignToMarketQueue = false;
                                        break;
                                    }
                                }
                            }
                            if(boolassignToMarketQueue && mapStoreId.containsKey(objLead.CCPM_storeID__c) && mapStoreId.get(objLead.CCPM_storeID__c).CCPM_market__c != null && CCPM_Collection.isNotNullEmpty(mapQueueNameIDs) && 
                               mapQueueNameIDs.containsKey(mapStoreId.get(objLead.CCPM_storeID__c).CCPM_market__c)){
                                   objlead.OwnerId = mapQueueNameIDs.get(mapStoreId.get(objLead.CCPM_storeID__c).CCPM_market__c);
                                   objLead.CCPM_storeManager__c = null;
                                   boolAssignDoneByStoreId = true;
                               } 
                            else if(boolassignToMarketQueue == false){
                                boolAssignDoneByStoreId = true;
                            }
                        }
                    }
                    if((objLeadOld == null || boolAccountIdIsChanged) && !boolAssignDoneByCartLasthandledBy && !boolAssignDoneByStoreId && objLead.CCPM_accountUniqueID__c != null && CCPM_Collection.isNotNullEmpty(mapAccUniqueIDAccRec) 
                       && mapAccUniqueIDAccRec.containsKey(objLead.CCPM_accountUniqueID__c) && (mapAccUniqueIDAccRec.get(objLead.CCPM_accountUniqueID__c).CCPM_store__c) != null){
                           Account objacc = mapAccUniqueIDAccRec.get(objLead.CCPM_accountUniqueID__c);
                           Boolean boolassignToMarketQueue = true;
                           if(CCPM_Collection.isNotNullEmpty(mapStore) && mapStore.containsKey(objacc.CCPM_Store__c)){
                               CCPM_store__c objStore = mapStore.get(objacc.CCPM_Store__c);
                               assignStoreDetails(objlead, objStore, true);
                               for(CCPM_storeEmployee__c objstrEmp :  objStore.Store_Employees__r){
                                   if(setStrSupervisorRoleName.contains(objstrEmp.CCPM_Role__c)){
                                       objlead.OwnerId = objstrEmp.CCPM_employee__c;
                                       objlead.CCPM_storeManager__c = objstrEmp.CCPM_employee__c;
                                       boolassignToMarketQueue = false;
                                       break;
                                   } 
                               }
                               if(boolassignToMarketQueue && objacc.CCPM_Store__c != null && mapStore.containsKey(objacc.CCPM_Store__c) 
                                  && mapStore.get(objacc.CCPM_Store__c).CCPM_market__c != null && CCPM_Collection.isNotNullEmpty(mapQueueNameIDs) && 
                                  mapQueueNameIDs.containsKey(mapStore.get(objacc.CCPM_Store__c).CCPM_market__c)){
                                      objlead.OwnerId = mapQueueNameIDs.get(mapStore.get(objacc.CCPM_Store__c).CCPM_market__c);
                                      objLead.CCPM_storeManager__c = null;
                                  }
                               else if(boolassignToMarketQueue){
                                   boolassignToHQqueue = true;
                               }
                           }
                           else{
                               boolassignToHQqueue = true;
                           }
                       }
                    
                    
                    else if(!boolAssignDoneByCartLasthandledBy && !boolAssignDoneByStoreId){
                        boolassignToHQqueue = true;
                    }       
                }       
            }
        
        if(boolassignToHQqueue){
            assignStoreToHeadQuarters(objlead);
        }
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to Asign Store owner to HeadQuarters, does assignemnt for telesales and retail.
@param         Lead
@return        void
*/
    public static void assignStoreToHeadQuarters(Lead objlead){
        objlead.OwnerId = objlead.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName ? mapQueueNameIDs.get(Label.CCPM_hqTelesalesQueueName): mapQueueNameIDs.get(Label.CCPM_headquartersQueueName);
        objLead.Store__c = null;
        objLead.CCPM_storeManager__c = null;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to Asign Store details to lead. Modularizing as Timezone on lead is mandatory.
@param         Lead, CCPM_Store__c
@param         Boolean: Because the requirement is that Customer Cart must not have a Store Id Assigned because its populated from informatica
@return        void
*/
    public static void assignStoreDetails(Lead objlead, CCPM_Store__C objstore, boolean boolAssignStoreId){
        if(objstore != null){
            objlead.store__c = objStore.id;
            objlead.CCPM_storeID__c = String.isNotBlank(objStore.CCPM_storeID__c) && boolAssignStoreId ? objStore.CCPM_storeID__c : null;
            objlead.CCPM_StoreTimeZone__c = String.isNotBlank(objStore.CCPM_TimeZone__c) ? objStore.CCPM_TimeZone__c : null;    
        }
    }
    
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to CCPM_TriggerInitialSMSDateTime__c for lead
@param         Lead, Lead
@return        void
*/
    public static void assignConvOrQualifiedTime(Lead objlead, Lead objLeadOld){
        if(String.isNotBlank(objLead.Status) && objLead.Status != objLeadOld.status )
        {   
            if(objLead.Status == Label.CCPM_leadStatusConverted){
                //Assign current date/time to the date/time field
                objLead.CCPM_convertedDateTime__c = System.now();
            }
            else if(objLead.Status == Label.CCPM_leadStatusQualified){
                objLead.CCPM_qualifiedDateTime__c = System.now();
            }
        }
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to create task for Telesales on update of lead owner from queue to a valid owner
@param         Lead, Lead
@return        CCPM_SMSMessage__c
*/ 
    public static Task populateActivityForTelesalesOnUpdate(Lead objLeadNew,Lead objLeadOld){
        Task objTask = null;
        if(objLeadNew.OwnerId != objLeadOld.OwnerId && setQueueIDs.contains(objLeadOld.OwnerId) 
           && objLeadNew.Status == objLeadOld.Status && objLeadNew.Status == Label.CCPM_LeadEligibleStatus){
               objTask = populateActivityForTelesales(objLeadNew);     
           }
        return objTask;
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to Check if status or sub status has changed
@param         Lead, Lead
@return        CCPM_SMSMessage__c
*/ 
    public static void populatepreviousStatus(Lead objLead,Lead objLeadOld){
        if(objLead.Status!=objLeadOld.Status){
            objLead.CCPM_previousLeadStatus__c=objLeadOld.Status;
        }
        if(objLead.CCPM_leadSubStatus__c!=objLeadOld.CCPM_leadSubStatus__c){
            objLead.CCPM_previousLeadStatus__c=objLeadOld.Status + Label.CCPM_Hypen;
            if(String.isNotBlank(objLeadOld.CCPM_leadSubStatus__c)){
                objLead.CCPM_previousLeadStatus__c += objLeadOld.CCPM_leadSubStatus__c;
            }            
        }
    }
    
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to manage Informatica Merges
@param         Lead, Lead, Map<String, BusinessHours>, BusinessHours
@return        void
*/ 
    public static void manageInformaticaMerge(Lead objLead,Lead objLeadOld){
        if(objLeadOld!=null && String.isNotBlank(objlead.Status) && ccpm_utility.setLeadOpenStatusWithoutNew.contains(objlead.Status) && objlead.CCPM_isInformaticaMerge__c == true 
           && objLeadOld.CCPM_isInformaticaMerge__c == false && objlead.CCPM_mobileNumber__c != null 
           && objlead.Ownerid!=null &&  CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objlead.ownerid) && 
           String.isNotBlank(objLead.CCPM_Type__c) && objLead.CCPM_Type__c != Label.CCPM_leadTypeCampaignLead 
           && !CCPM_utility.IsMergedLeadAbandonedVisit(objlead) && !objlead.CCPM_smsOptOutAccount__c){
               
               if((!CCPM_utility.IsMergedQuoteLead(objlead) && ((String.isNotBlank(objlead.LeadSource) && objlead.LeadSource == Label.CCPM_leadSourceNetace) || 
                   (objlead.RecordTypeId==strLeadProspectRT || (objLead.RecordTypeId==strLeadCustomerCartRT && objLead.CCPM_isManualLead__c) || objLeadOld.RecordTypeId == strLeadCustomerAbandonedVisit))) 
                  ||
                   (CCPM_utility.IsMergedQuoteLead(objlead) && ((objLeadOld.RecordTypeId == strLeadCustomerCartRT && objlead.LeadSource != Label.CCPM_leadSourceNetace) || (objLeadOld.RecordTypeId == strLeadCustomerCartRT && objLeadOld.CCPM_isManualLead__c) ||
                   objLeadOld.CCPM_Type__c == Label.CCPM_leadTypeCampaignLead || objLeadOld.RecordTypeId == strLeadCustomerAbandonedVisit))
                  ||
                   (( objLead.CCPM_informaticaMergeLeadType__c != Label.CCPM_CustomerCampaign) 
                    && (objLead.CCPM_createdChannel__c != null && objLead.CCPM_createdChannel__c != Label.CCPM_telesalesChannelName && objlead.LeadSource != null && 
                      objlead.LeadSource != Label.CCPM_leadSourceNetace && (objLead.recordTypeId == strLeadCustomerCartRT || objlead.RecordTypeId == strLeadProspectCartRT || CCPM_utility.IsMergedQuoteLead(objlead)) &&
                      objlead.Status == Label.CCPM_leadStatusResponded && objlead.CCPM_leadSubStatus__c!= null && objlead.CCPM_leadSubStatus__c == Label.CCPM_LeadCartDisinterested))){
                      //if((objlead.LeadSource != null && objlead.LeadSource == Label.CCPM_leadSourceNetace)|| (objlead.RecordTypeId==strLeadProspectRT || objlead.CCPM_isManualLead__c)){
                      
                      objlead.CCPM_SMSOptOut__c = false;
                      objlead.CCPM_leadSubStatus__c = null;
                      objlead.CCPM_isInitialSMSSent__c = false;
                      objlead.CCPM_isFollowUpSMSSent__c = false;
                      objlead.CCPM_isSMSResponseReceived__c = false;
                      objlead.CCPM_DoubleOptOutSent__c = false;
                      objlead.CCPM_AutoResponseForDoubleOptOutSmsSent__c = false;
                      objlead.CCPM_initialSMSSentDateTime__c = null;
                      objlead.CCPM_followUpSMSDate__c = null;
                      objlead.CCPM_SMSResponseReceivedDateTime__c = null;
                      objLead.CCPM_isProspectSMSsent__c = false;
                      objLead.CCPM_prospectSMSSentDate__c = null;
                      objLead.CCPM_triggerProspectSMSPart1__c = null;
                      objlead.Status = Label.CCPM_LeadEligibleStatus; //Set lead status to eligible
                      
                      calculateActualSMSScheduleDateTime(objlead);     
                  }
           }
        //  }
    }
    
    /**
@author        Sriraman Sridharan(Deloitte)
@description   Method to populate Message To Lead Owners Within BusinessHours
@param         Lead, String, Map<id,User>
@return        void
*/
    public static CCPM_SMSMessage__c populateMessageToLeadOwnersWithinBusinessHours(Lead objlead,String strMessage, Map<id,User> mapLeadOwners){
        BusinessHours bhrs = null;
        if(CCPM_Collection.isNotNullEmpty(mapBusinessHoursNameRec)){
            if(String.isNotBlank(Label.CCPM_defaultLabel) && mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel) != null){
                bhrs = mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel);
            }
            if(String.isNotBlank(objlead.CCPM_StoreTimeZone__c) && mapBusinessHoursNameRec.get(objlead.CCPM_StoreTimeZone__c) != null){
                bhrs = mapBusinessHoursNameRec.get(objlead.CCPM_StoreTimeZone__c);
            }
        }
        Datetime datTBusinessTime = CCPM_utility.calculateTimeToTriggerSMSWithInBusinessHours(bhrs, System.now());
        
        CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
        // String strMessage = objlead.CCPM_ManuallyChangeOwnershipMessage__c;
        if(CCPM_Collection.isNotNullEmpty(mapLeadOwners) && mapLeadOwners.containsKey(objlead.OwnerId) && mapLeadOwners.get(objlead.OwnerId).mobilephone != null){
            String strToPhone = mapLeadOwners.get(objlead.OwnerId).mobilephone;
            objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage,strToPhone,Label.CCPM_messageTypePwnerChangeSMS,Label.CCPM_taskCommunicationOutbound,datTBusinessTime,Label.CCPM_liveTextPhoneNumber);
            objSmsMessage.CCPM_internalCommunication__c=True;
            objSmsMessage.CCPM_sentTo__c=objlead.OwnerId;
        }
        
        return objSmsMessage;
    }
    
    /**
@author        Sriraman Sridharan(Deloitte)
@description   Method to populate Message on Lead Owners change
@param         Lead, Map<String, BusinessHours>, BusinessHours
@return        void
*/
    public static CCPM_SMSMessage__c updateMessageBodyonLeadOwnerChange(Lead objlead,Lead objOldlead,CCPM_SMSMessage__c objSmsMessage, Map<id,User> mapLeadOwners){
        
        
        objSmsMessage.CCPM_sentTo__c=objlead.OwnerId;
        //Checking if the SMS message typ is Managers action required SMS or AM action required SMS for inactivity 3 hours
        if(objSmsMessage.CCPM_messageType__c == Label.CCPM_SmsMessageTypeActionRequired || objSmsMessage.CCPM_messageType__c == Label.CCPM_SmsMessageTypeAssistantManagerActionRequired  && mapLeadOwners.get(objLead.OwnerId).mobilephone != null)
        {
            string strLeadType;
            string strOwnerName;
            if(objLead.RecordTypeId == strLeadProspectRT || objLead.RecordTypeId == strLeadProspectCartRT ){strLeadType = strLeadProspectRT;}
            else strLeadType = Label.CCPM_leadType;
            if(mapLeadOwners.containsKey(objLead.ownerid) && mapLeadOwners.get(objLead.ownerid).firstname!= null){strOwnerName = mapLeadOwners.get(objLead.ownerid).firstname;}
            else strOwnerName = mapLeadOwners.get(objLead.ownerid).lastname;
            
            objSmsMessage.CCPM_toPhoneNumber__c = mapLeadOwners.get(objlead.OwnerId).mobilephone ;
            objSmsMessage.CCPM_internalCommunication__c=True;
            objSmsMessage.CCPM_message__c = 'Action Required: A '+strLeadType+' has responded to your store and '+ strOwnerName +' has not followed up in 3 hours. Please login to Salesforce and view \'Leads Requiring Action\'.';
        }
        //Checking if the type of SMS is Initial SMS
        else if(CCPM_utility.setSMSMessageTypeforDismissedLead.contains(objSmsMessage.CCPM_messageType__c))
        {
            objSmsMessage.CCPM_MessageStatus__c = Label.CCPM_SMSStatusRemoved;
        }
        return objSmsMessage;
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   Method to create sms message custom object to send initial messages for leads or prospects
@param         Lead, Map<String, Account>
@return        CCPM_SMSMessage__c
*/
    public static CCPM_SMSMessage__c populateFollowUpSMS(Lead objlead, Map<String, Account> mapAccUniqueIDAccRec){
        
        CCPM_SMSMessage__c objSmsMessage = null;
        BusinessHours bhrs = null;
        if(CCPM_Collection.isNotNullEmpty(mapBusinessHoursNameRec)){
            if(String.isNotBlank(Label.CCPM_defaultLabel) && mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel) != null){
                bhrs = mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel);
            }
            if(String.isNotBlank(objlead.CCPM_StoreTimeZone__c) && mapBusinessHoursNameRec.get(objlead.CCPM_StoreTimeZone__c) != null){
                bhrs = mapBusinessHoursNameRec.get(objlead.CCPM_StoreTimeZone__c);
            }
        }
        DateTime datFollowUpScheduleTime = CCPM_utility.calculateTimeToTriggerSMSWithInBusinessHours(bhrs, objLead.CCPM_triggerFollowupSMSDateTime__c);
        
        if(String.isNotBlank(objlead.CCPM_mobileNumber__c) && !(CCPM_utility.setleadStatusTOExclude.contains(objLead.Status) || objLead.Status == Label.CCPM_leadStatusConverted) &&
           (objLead.recordTypeId == strLeadProspectRT || objLead.recordTypeId == strLeadProspectCartRT || !checkLeadAccountOptOut(objlead))
           && !CCPM_utility.isCurrentUserTelesalesUser && CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objlead.ownerid)){
               
               //check if the lead owner is a queue and if the lead is in open status
               String strToPhone = objLead.CCPM_mobileNumber__c;
               if(objLead.recordTypeId == strLeadProspectCartRT || objLead.recordTypeId == strLeadProspectRT)
               {
                   String strMessage = objLead.CCPM_ProspectFollowUpSMSBody__c;
                   objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage,strToPhone,Label.CCPM_MessageTypeFollowUp,Label.CCPM_taskCommunicationOutbound,datFollowUpScheduleTime,Label.CCPM_liveTextNumberNonVerizon);
               }
               else if(objLead.recordTypeId == strLeadCustomerCartRT && objLead.CCPM_Type__c != Label.CCPM_leadTypeCampaignLead)
               {
                   String strMessage = objLead.CCPM_followupMessageBody__c;
                   objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage,strToPhone,Label.CCPM_MessageTypeFollowUp,Label.CCPM_taskCommunicationOutbound,datFollowUpScheduleTime,Label.CCPM_liveTextPhoneNumber);
               }
               else if(objLead.recordTypeId == strLeadCustomerCartRT && objLead.CCPM_Type__c == Label.CCPM_leadTypeCampaignLead)
               { //Insert follow up for campaign leads
                   String strMessage = objLead.CCPM_CampingFollowUpMessageTemplate__c ;
                   if(strMessage != null && !String.isBlank(strMessage)){
                       objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage,strToPhone,Label.CCPM_CampaignFollowUp,Label.CCPM_taskCommunicationOutbound,datFollowUpScheduleTime,Label.CCPM_liveTextPhoneNumber);
                       if(objSmsMessage != null && !objLead.CCPM_SMSOptOut__c){
                           objSmsMessage.CCPM_dynamicLeadOwnerName__c = objLead.CCPM_ownerFirstName__c;
                           objSmsMessage.CCPM_dynamicStoreName__c = objLead.CCPM_storeName__c;
                           objSmsMessage.CCPM_dynamicStoreRecommendedHrs__c = objLead.CCPM_storeRecommendedHours__c;
                       }
                   } 
               }
           }
        return objSmsMessage;
    }
    /**
@author        Sriraman Sridharan/ Sudhakara (Deloitte)
@description    Cancel And Create New SmsSchedules for Merge scenarios 
@param         None
@return          
*/ 
    /*    public static void CancelAndCreateNewSmsSchedulesWhileMerge(list<Lead> lstNewLeads,list<Lead> lstOldLeads,Set<String> setQueueID)  
{
// set<String> setQueueID = CCPM_utility.populateQueueIds();
Set<ID> setLeadIDsToFetchSmsMap = new Set<ID>();
map<String,Boolean> mapLead = new map<String,Boolean>();
map<id,list<CCPM_SMSMessage__c>> mapLeadSMS = new map<id,list<CCPM_SMSMessage__c>>();
list<CCPM_SMSMessage__c> lstSMSToUpdate = new list<CCPM_SMSMessage__c>();
for(Integer i =0; i< lstNewLeads.size(); i++){
if(lstNewLeads[i] != null && lstNewLeads[i].Status != null && ccpm_utility.setLeadOpenStatusWithoutNew.contains(lstNewLeads[i].Status) && 
lstNewLeads[i].CCPM_Type__c != null && lstNewLeads[i].CCPM_Type__c != Label.CCPM_leadTypeCampaignLead && lstNewLeads[i].CCPM_mobileNumber__c != null 
&& ((lstNewLeads[i].RecordTypeId == strLeadCustomerCartRT && !lstNewLeads[i].CCPM_smsOptOutAccount__c) || 
(lstOldLeads[i].RecordTypeId==strLeadProspectRT || lstOldLeads[i].RecordTypeId==strLeadProspectCartRT))){
if(lstOldLeads[i].CCPM_isInformaticaMerge__c == false && lstNewLeads[i].CCPM_isInformaticaMerge__c == true &&
lstNewLeads[i].Ownerid!=null && lstOldLeads!=null && !lstOldLeads.isEmpty() && setQueueID!=null && !setQueueID.isEmpty() && 
!setQueueID.contains(lstNewLeads[i].ownerid)){

//Insert selectively 
//All Scenarios : DISRSCE-1746, DISRSCE-1745,DISRSCE-1744
if(lstNewLeads[i].CCPM_createdChannel__c != null && lstNewLeads[i].CCPM_createdChannel__c != Label.CCPM_telesalesChannelName)
{
if((lstNewLeads[i].LeadSource != null && (lstNewLeads[i].LeadSource == Label.CCPM_LeadSourceNetace || (lstNewLeads[i].status!=null && lstNewLeads[i].status == Label.CCPM_LeadEligibleStatus) ))|| (lstNewLeads[i].RecordTypeId==strLeadProspectRT || lstNewLeads[i].CCPM_isManualLead__c))
{
//     system.debug('@@@CCPM_createdChannel__c' + lstNewLeads[i].CCPM_createdChannel__c + '@@@Label.CCPM_telesalesChannelName ' + Label.CCPM_telesalesChannelName);

setLeadIDsToFetchSmsMap.add(lstNewLeads[i].id);
CCPM_SMSMessage__c objSmsMessage = populateInitialMessageForMergeCarts(lstNewLeads[i],setQueueID);
lstSMSToUpdate.add(objSmsMessage);
//   system.debug('@@@mapLead IF 2980: ' + mapLead); 
}
}
//Messages for Telesales Merge
else if(lstNewLeads[i].CCPM_createdChannel__c != null && lstNewLeads[i].CCPM_createdChannel__c == Label.CCPM_telesalesChannelName &&
(lstNewLeads[i].LeadSource != null && lstNewLeads[i].LeadSource == Label.CCPM_LeadSourceNetace) ){
setLeadIDsToFetchSmsMap.add(lstNewLeads[i].id);
CCPM_SMSMessage__c objSmsMessage = populateInitialMessageForMergeCarts(lstNewLeads[i],setQueueID);
lstSMSToUpdate.add(objSmsMessage); 
mapLead.put(lstNewLeads[i].id, Boolean.valueOf(Label.CCPM_boolFalse));
//        system.debug('@@@mapLead : ' + mapLead);
}
} 
}
}
//   system.debug('@@@setLeadIDsToFetchSmsMap : ' + setLeadIDsToFetchSmsMap);
//Removing Existing Schedules
//get the map of lead and the list of scheduled sms messages
if(setLeadIDsToFetchSmsMap != null && setLeadIDsToFetchSmsMap.size()>0){
mapLeadSMS = CCPM_sendSMSMergeManual.createMapLeadSMSRelation(setLeadIDsToFetchSmsMap);
}
if(mapLead!= null && !mapLead.isEmpty()){
CCPM_sendSMSMergeManual.updateTaskRecords(mapLead);
}

for(ID objId : mapLeadSMS.keySet() ){
list<CCPM_SMSMessage__c> lstSmsMessages = mapLeadSMS.get(objId);
if(lstSmsMessages != null && !lstSmsMessages.isEmpty()){//If there are existing schedules
for(CCPM_SMSMessage__c objSmsMsg : lstSmsMessages){
objSmsMsg.CCPM_MessageStatus__c = Label.CCPM_SMSStatusRemoved;
lstSMSToUpdate.add(objSmsMsg);
// system.debug('@@@objSmsMsg :' + objSmsMsg);
}
}
}
//Check if the SMS to Update map is not empty
try{
if(lstSMSToUpdate!=null && lstSMSToUpdate.isEmpty() == false)
{   //Make a callout to the method to Update the SMS records
//     system.debug('@@@lstSMSToUpdate :' + lstSMSToUpdate);
upsert lstSMSToUpdate;
}
}
catch(Exception e)
{
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadTriggerHandlerHelper','CancelAndCreateNewSmsSchedulesWhileMerge','Exception thrown while updating SMS Message Records',true);            
}
}
*/
    /*
@author        Aneesha Ragireddy(Deloitte)
@description   Method to populate CCPM_closedLeadChannel__c based on Closed Lead Source Value
@param         List<Lead>
@return         List of Leads
@User Story     US-2089 
*/
    
    public static void populateClosedLeadChannel(Lead objLead, Lead objLeadOld){
        //Populating Closed Lead Channel as unknown where Lead is in Closed Status and there is no Closed Lead Source value
        if(String.isNotBlank(objLead.Status) && (objLeadOld==null || (objLeadOld!=null && objLead.Status != objLeadOld.Status)) && objLead.Status == Label.CCPM_ClosedLeadChannelStatus){
            if(String.isNotBlank(objLead.CCPM_closedLeadSource__c)){
                string strStatus = '%'+(objLead.Status.trim())+'%';
                //using substring as the picklist value is not getting trimmed.
                string strclosedLeadSource = '%'+((objLead.CCPM_closedLeadSource__c).substring(0)).trim()+'%';
                system.debug('*****strclosedLeadSource******'+strclosedLeadSource);
                //Querying for the Metadata setting where Lead Status and Closed Lead Source values match
                List<CCPM_LeadChannelSetting__mdt> LeadChannelSettings= [Select CCPM_LeadSourceValues__c, CCPM_leadStatusValues__c, CCPM_LeadChannelValue__c 
                                                                         from CCPM_LeadChannelSetting__mdt where CCPM_LeadSourceValues__c like :strclosedLeadSource limit 1];
                if(CCPM_Collection.isNotNullEmpty(LeadChannelSettings)){
                    //populating assosiated Closed Lead Channel on Lead
                    objLead.CCPM_closed_Lead_Channel__c = LeadChannelSettings[0].CCPM_LeadChannelValue__c;
                }
            }
            else
            {objLead.CCPM_closed_Lead_Channel__c = Label.CCPM_unknown;}
        }
    }
    /**
@author        Aneesha Ragireddy(Deloitte)
@description   Method to populate CCPM_closedLeadChannel__c based on Closed Lead Source Value
@param         List<Lead>
@return         List of Leads
@User Story     US-2089 */
    
    public static void populateDismissedChannel(Lead objLead, Lead objLeadOld){    
        
        //Populating Dismissed Lead Channel as unknown where Lead is in Closed Status and there is no Closed Lead Source value
        if(String.isNotBlank(objLead.CCPM_DismissedSource__c) && (objLeadOld==null || (objLeadOld!=null && objLead.CCPM_DismissedSource__c!= objLeadOld.CCPM_DismissedSource__c))){
            objLead.CCPM_IsCartDismissed__c = true;
            objLead.CCPM_DismissedChannel__c = Label.CCPM_unknown;
            string strDismissedSource = '%'+(objLead.CCPM_DismissedSource__c.trim())+'%';
            //Querying for the Metadata setting where Lead Status and Closed Lead Source values match
            // This is a query on Meta Data. Will not be counted against query limits. 
            List<CCPM_LeadChannelSetting__mdt>  lstLeadChannelSettings = [Select CCPM_LeadSourceValues__c, CCPM_leadStatusValues__c, CCPM_LeadChannelValue__c 
                                                                          from CCPM_LeadChannelSetting__mdt where CCPM_LeadSourceValues__c like :strDismissedSource limit 1];  
            if(CCPM_Collection.isNotNullEmpty(lstLeadChannelSettings)){
                //populating assosiated Closed Lead Channel on Lead
                objLead.CCPM_DismissedChannel__c = lstLeadChannelSettings[0].CCPM_LeadChannelValue__c;
            }
        } 
    }    
    
    /**
@author        Anupreeta Chakraborty(Deloitte)
@description   Method to populate Created Channel and Created Lead source and Created Type based on Type, RecordType and Channel.
@param         List<Lead>
@return         List of Leads
*/ 
    public static Lead populateCreatedLeadFields(Lead objLead) {
        Id customerCartRecordTypeId = strLeadCustomerCartRt;
        Id prospectRecordTypeId = strLeadProspectRT;
        Id prospectCartRecordTypeId = strLeadProspectCartRT;
        
        //Manual Leads
        if ((objLead.CCPM_createdChannel__c == Label.CCPM_retailChannelName || objLead.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName) &&
            ((objLead.CCPM_Type__c == Label.CCPM_leadTypeManualLead && objLead.RecordTypeId == customerCartRecordTypeId) || (objLead.CCPM_Type__c == Label.CCPM_leadTypeProspect && objLead.RecordTypeId == prospectRecordTypeId))) {
                objLead.CCPM_Created_Lead_Source__c = Label.CCPM_LeadSourceSalesforce;
            }
        //Abandoned Cart Leads
        if (objLead.CCPM_Type__c == Label.CCPM_leadTypeLead && objLead.RecordTypeId == customerCartRecordTypeId) {
            if (objLead.CCPM_leadChannel__c == Label.CCPM_digitalChannelName) {
                objLead.CCPM_createdChannel__c = Label.CCPM_digitalChannelName;
                objLead.CCPM_Created_Lead_Source__c = objLead.Leadsource;
            }
            if (objLead.CCPM_leadChannel__c == Label.CCPM_retailChannelName) {
                objLead.CCPM_createdChannel__c = Label.CCPM_retailChannelName;
                objLead.CCPM_Created_Lead_Source__c = Label.CCPM_LeadSourceNetace;
            }
        }
        //Campaign Leads
        if (objLead.CCPM_Type__c == Label.CCPM_leadTypeCampaignLead && objLead.RecordTypeId == customerCartRecordTypeId) {
            objLead.CCPM_createdChannel__c = Label.CCPM_retailChannelName;
            objLead.CCPM_Created_Lead_Source__c = Label.CCPM_LeadSourceCRM;
        }
       //Quote Leads
        if (objLead.RecordTypeId == strLeadCustomerQuoteRT) {
            if(objLead.LeadSource != null){
                objLead.CCPM_createdChannel__c = objLead.LeadSource.contains(Label.CCPM_retailChannelName) ? Label.CCPM_retailChannelName : objLead.LeadSource.contains(Label.CCPM_telesalesChannelName) ? Label.CCPM_telesalesChannelName : null;                
                objLead.CCPM_created_Lead_Source__c = objLead.LeadSource;
            }
        }
        //Abandoned Visit Leads
        if (objLead.RecordTypeId == strLeadCustomerAbandonedVisit) {
            objLead.CCPM_created_Lead_Source__c = objLead.LeadSource;      
        }
        //setting values of Created type 
        if (setCustomerRecordTypeids.contains(objLead.recordTypeId)) {
            if (objLead.CCPM_isManualLead__c) {
                objLead.CCPM_CreatedType__c = Label.CCPM_leadTypeManualLead;
            } else if (objLead.CCPM_Created_Lead_Source__c == Label.CCPM_LeadSourceCRM) {
                objLead.CCPM_CreatedType__c = Label.CCPM_leadTypeCampaignLead;
            } else if(objLead.recordTypeId == strLeadCustomerAbandonedVisit){
                objLead.CCPM_CreatedType__c = Label.CCPM_AbandonedVisitLeadCreatedType;
            } else if(objLead.recordTypeId == strLeadCustomerQuoteRT){
                objLead.CCPM_CreatedType__c = Label.CCPM_QuoteleadCreatedType;
            }
            else
                objLead.CCPM_CreatedType__c = Label.CCPM_leadTypeLead;
        } else if (objLead.RecordTypeId == prospectRecordTypeId || objLead.RecordTypeId == prospectCartRecordTypeId) {
            objLead.CCPM_CreatedType__c = Label.CCPM_leadTypeProspect;
        } else {
            objLead.CCPM_CreatedType__c = '';
        }
        
        return objLead;
    }
    
    
    
    
    /**
@author         Sriraman Sridharan
@description    This method populates the initial message
@param          list of new leads
@return         CCPM_SMSMessage__c
*/ 
    
    public static CCPM_SMSMessage__c populateInitialMessageForMergeCarts(lead objlead,Set<String> setQueueIDs){
        
        CCPM_SMSMessage__c objSmsMessage = null;
        if(objlead.ownerid!=null && CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objlead.ownerid)){
            String MTN = objlead.CCPM_mobileNumber__c;
            String strMessage1 = '';
            //SMS initial Messages
            // RecordType is Prospect, Lead Status is not equal to Expired,Dismissed,Responded,Qualified,Converted 
            // AND Event Type is not equal toiPhone X,TMP,Pixel - future device 
            if(CCPM_utility.IsMergedQuoteLead(objlead) && ((objLead.LeadSource != null && objLead.LeadSource != Label.CCPM_LeadSourceNetace) || 
               (objLead.RecordTypeId==strLeadCustomerCartRT && objLead.CCPM_isManualLead__c)) && !objLead.CCPM_smsOptOutAccount__c){
                 system.debug('@@@ : Inside 1');
                CCPM_smsTemplate__c objSMSTemp = mapLeadTypeSMSTemplateRec.get(label.CCPM_CustomerQuotes);
                if(objSMSTemp != null){
                   strMessage1 = objSMSTemp.CCPM_initialMessage__c;
                   objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage1,MTN,objSMSTemp.CCPM_messageType__c,Label.CCPM_taskCommunicationOutbound,objlead.CCPM_ActualSMSScheduleDateTime__c,Label.CCPM_liveTextPhoneNumber);
                }
            }
            else if((objlead.RecordTypeId==Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId()
                && !(CCPM_utility.setleadStatusTOExclude.contains(objlead.Status)) && !CCPM_utility.setleadEventToExclude.contains(objlead.CCPM_eventType__c)) 
               || (objlead.recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId()))
            {                       
                //strMessage1 = objlead.CCPM_prospectSMSBody__c; 
                strMessage1 = objlead.CCPM_initialSMSBody__c;
                objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage1,MTN,Label.CCPM_MessageTypeInitialSMSPart1,Label.CCPM_taskCommunicationOutbound,objlead.CCPM_ActualSMSScheduleDateTime__c,Label.CCPM_liveTextNumberNonVerizon);          
            }
            else if(objlead.recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId() && !CCPM_utility.IsMergedQuoteLead(objlead)){
                strMessage1 = objlead.CCPM_initialSMSBody__c;
                objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage1,MTN,Label.CCPM_MessageTypeInitialSMSPart1,Label.CCPM_taskCommunicationOutbound,objlead.CCPM_ActualSMSScheduleDateTime__c,Label.CCPM_liveTextPhoneNumber);
            }
            else if(setRecordTypeidsForSMS.contains(objLead.recordTypeId) && String.isNotBlank(objLead.CCPM_leadType__c) && !objLead.CCPM_smsOptOutAccount__c){
                system.debug('@@@ : Inside 2');
                CCPM_smsTemplate__c objSMSTemp = mapLeadTypeSMSTemplateRec.get(objLead.CCPM_leadType__c);
                if(objSMSTemp != null){
                    strMessage1 = objSMSTemp.CCPM_initialMessage__c;
                    objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage1,MTN,objSMSTemp.CCPM_messageType__c,Label.CCPM_taskCommunicationOutbound,objlead.CCPM_ActualSMSScheduleDateTime__c,Label.CCPM_liveTextPhoneNumber);
                }
            }
        } 
        return objSmsMessage;
    } 
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to CCPM_ActualSMSScheduleDateTime__c for lead
@param         Lead
@return        void
*/
    public static void calculateActualSMSScheduleDateTime(Lead objlead){
        BusinessHours bhrs = CCPM_utility.getBusinessBrsForLead(objlead);
        Datetime datTActualSMSdate = null;
        if(bhrs != null){
            if(CCPM_utility.isManualLeadOrProspect(objLead)){
                calcSMSFOllowupDateForProspectAndManualLead(objlead, bhrs);
            }
            if(objlead.CCPM_isManualLead__c == false && (setCustomerRecordTypeids.contains(objLead.recordTypeId) || objlead.RecordTypeId == strLeadProspectCartRT)){
                datTActualSMSdate = objlead.RecordTypeId == strLeadCustomerQuoteRT ? System.now().addminutes(integer.valueof(Label.CCPM_initialSMSIntervalforQuote)) : System.now().addminutes(integer.valueof(Label.CCPM_initialSMSInterval));
            }
        }
        if(datTActualSMSdate != null){
            objLead.CCPM_ActualSMSScheduleDateTime__c = CCPM_utility.calculateTimeToTriggerSMSWithInBusinessHours(bhrs, datTActualSMSdate);
        }
    }
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to CCPM_ActualSMSScheduleDateTime__c for lead on update
@param         Lead, Lead
@return        void
*/
    public static void calculateActualSMSScheduleDateTimeOnUpdate(Lead objlead, Lead objLeadOld){
        //populate ActualSMSScheduleDateTime when owner changes from Queue to store emp or Change in Event date time
        if((objLead.OwnerId != null && objLead.OwnerId != objLeadOld.OwnerId && CCPM_Collection.isNotNullEmpty(setQueueIDs) 
            && !setQueueIDs.contains(objlead.ownerid))
           ||(objLead.CCPM_SMSFollowUpDate__c != objLeadOld.CCPM_SMSFollowUpDate__c)
           ||(String.isNotBlank(objlead.CCPM_eventType__c) && objLead.CCPM_eventType__c != objLeadOld.CCPM_eventType__c)
           ||(objLead.CCPM_HotFixFlagToSendInitialSMS__c != objLeadOld.CCPM_HotFixFlagToSendInitialSMS__c && objLead.CCPM_HotFixFlagToSendInitialSMS__c)){
               
               calculateActualSMSScheduleDateTime(objlead);
               
           }
    }   
    
    
    /**
@author        Anupreeta Chakraborty(Deloitte)
@description   Method to assign record type based on lead type on insert/update
@param         Lead
@return        void 
*/    
    public static void assignRecordtypeRelatedtoLeadType(Lead objlead){                            
        if(mapRecTypeSettings.containskey(objLead.CCPM_leadtype__c)){
            //populating associated Recordtype based on Lead type
            objLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(mapRecTypeSettings.get(objLead.CCPM_leadtype__c)).getRecordTypeId();
        }        
    }      
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to get message records for lead types in SMS template object
@param         N/A
@return        Map<String, CCPM_smsTemplate__c>
*/
    public static Map<String, CCPM_smsTemplate__c> getSMSTemplateForSMSMsg(){
        Map<String, CCPM_smsTemplate__c> mapLeadTypeSMSTemplateRec = new Map<String, CCPM_smsTemplate__c>();
        if(CCPM_Collection.isNotNullEmpty(mapRecTypeSettings)){
            for(CCPM_smsTemplate__c objSMSTemp : [Select id, CCPM_leadType__c, CCPM_initialMessage__c, CCPM_followupMessage__c, CCPM_messageType__c
                                                  FROM CCPM_SMSTemplate__c Where CCPM_isActive__c = true AND CCPM_leadType__c IN: mapRecTypeSettings.keySet()
                                                  AND CCPM_startDate__c <= :System.now() AND (CCPM_endDate__c = null OR CCPM_endDate__c >= :System.now())]){
                                                      mapLeadTypeSMSTemplateRec.put(objSMSTemp.CCPM_leadType__c, objSMSTemp);	                                          
                                                  }
        }
        return mapLeadTypeSMSTemplateRec;
    }    
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to return Map of Type and Map of Event type and List of segmentations
@param         N/A
@return        Map<String, Map<String, List<CCPM_segmentation__c>>>
   */
    public static boolean checkSegFieldContains(String strFieldName, String strValue){
    	Boolean boolisContains = false;
    	if(String.isNotBlank(strFieldName) && String.isNotBlank(strValue) && strFieldName.contains(strValue)){
    		boolisContains = true;
    	}
    	return boolisContains;
    } 
 
}