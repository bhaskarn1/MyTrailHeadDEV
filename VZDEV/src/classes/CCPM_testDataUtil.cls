/**
  *@name         :   CCPM_testDataUtil
  *@author       :   Ritwik K (Deloitte)
  *@date         :   01/25/2018
  *@description  :   This class is used for returning test data.
Modification Log :
------------------------------------------------------------------------------------
Developer                   Date                                Description
------------------------------------------------------------------------------------
Ritwik K(Deloitte)          01/25/2018                          Original Version
*/

@isTest(SeeAllData=false)
public class CCPM_testDataUtil {
        
    final static String LOCALE_EN_US = 'en_US';
    final static integer intMTN = 1111111111;
    final static String test = 'test';
    
    /**
      * @description: Creates test users that can be inserted in a setup or test method
      * @param: profileName Name of profile to use
      * @param: numUsers The number of users to create
      * @return: List of users to be inserted
    **/
    
    public static List<User> createTestUsers(String profileName, Integer numUsers) {
        
        List<User> lstUser = new List<User>();
        Profile objProfile = [Select id 
                                FROM Profile 
                               WHERE name=:profileName];
        
        for(Integer i=0;i<numUsers;i++) {
            User objUser = new User();
            objUser.FirstName         = profileName+i;
            objUser.LastName          = test;
            objUser.Email             = 'Test123@deloitte.com';
            objUser.Alias             = test + i;
            objUser.Username          = test + i + '123@deloitte.com';
            objUser.LocaleSidKey      = LOCALE_EN_US;
            objUser.TimeZoneSidKey    = 'GMT';
            objUser.ProfileID         = objProfile.Id;
            objUser.LanguageLocaleKey = LOCALE_EN_US;
            objUser.EmailEncodingKey  = 'UTF-8';
            objUser.CCPM_employeeID__c = '12345'+i;
            objUser.MobilePhone = String.valueof(intMTN+i);
            lstUser.add(objUser);
        }
        return lstUser;
    }
 
    /**
      * @description: Creates test lead records that can be inserted in a setup or test method
      * @param: num The number of leads to create
      * @return: List of leads to be inserted
    **/    
    
    public static list<lead> createLead (integer num, String recordTypeId, Boolean isManualLead, String leadType) {
        
        list<lead> lstLead = new list<lead>();
        for (integer i=0;i<num;i++) {
            lead objLead = new lead();
            //objLead.Status = 'New'; //added by Paras
            objLead.CCPM_mobileNumber__c = String.valueof(intMTN+i);
            objLead.CCPM_SMSLegalOptIn__c = true;
            objLead.FirstName = test;
            objLead.LastName = test;
            objLead.Company = String.valueof(i);
            objLead.CCPM_confirmMTN__c = String.valueOf(intMTN+i);
            objLead.CCPM_accountUniqueID__c = '010101';
            objLead.RecordTypeId = recordTypeId;
            objLead.CCPM_isManualLead__c = isManualLead;
            objlead.ccpm_leadtype__c = leadtype;
            lstLead.add(objLead);
        }
       
        return lstLead;
    }
    /**
      * @description: Creates test lead records that can be inserted in a setup or test method
      * @param: num The number of leads to create
      * @return: List of leads to be inserted
    **/    
    
    public static list<lead> createLeadWithMTN (integer num, String recordTypeId, Boolean isManualLead, String leadType,String strMTN) {
        
        list<lead> lstLead = new list<lead>();
        for (integer i=0;i<num;i++) {
            lead objLead = new lead();
            //objLead.Status = 'New'; //added by Paras
            objLead.CCPM_mobileNumber__c = String.valueof(strMTN);
            objLead.CCPM_SMSLegalOptIn__c = true;
            objLead.FirstName = test;
            objLead.LastName = test;
            objLead.Company = String.valueof(i);
            objLead.CCPM_confirmMTN__c = String.valueOf(intMTN+i);
            objLead.CCPM_accountUniqueID__c = '010101';
            objLead.RecordTypeId = recordTypeId;
            objLead.CCPM_isManualLead__c = isManualLead;
            objlead.ccpm_leadtype__c = leadtype;
            //objlead.ccpm_leadtype__c = leadType
            lstLead.add(objLead);
        }
       
        return lstLead;
    }    
    /**
      * @description: Creates test store records that can be inserted in a setup or test method
      * @param: num The number of stores to create
      * @return: List of stores to be inserted
    **/    
    
    public static list<CCPM_store__c> createStore (integer num) {
        
        list<CCPM_store__c> lstStore = new list<CCPM_store__c>();
        for (integer i=0;i<num;i++) {
            CCPM_store__c objStore = new CCPM_store__c();
            objStore.Name = test + i;
            objStore.CCPM_storeID__c = test + i;
            objStore.CCPM_district__c = test + i;
            objStore.CCPM_market__c = test + i;
            objStore.ccpm_territory__c = test + i;
            objStore.ccpm_isActive__c = true;
            objStore.CCPM_TimeZone__c = 'EST';
            lstStore.add(objStore);
        }
        
        return lstStore;
    }
    
    /**
      * @description: Creates test store employee records that can be inserted in a setup or test method
      * @param: num The number of store employees to create
      * @param: storeId The parent Id of store to be mapped to
      * @param: userId The ID of look up user
      * @return: List of store employee to be inserted
    **/    
    
    public static list<CCPM_storeEmployee__c> createStoreEmployee (integer num, id storeId, id userId, String empRole) {
        
        list<CCPM_storeEmployee__c> lstStoreEmployee = new list<CCPM_storeEmployee__c>();
        String storeEmployeeUniqueId = (String)userID + (String)storeID;
        for (integer i=0;i<num;i++) {
            CCPM_storeEmployee__c objStoreEmp = new CCPM_storeEmployee__c();
            objStoreEmp.CCPM_Store__c = storeId;
            objStoreEmp.CCPM_employee__c = userId;
            objStoreEmp.CCPM_IsActive__c = true;
            objStoreEmp.CCPM_role__c = empRole;
            objStoreEmp.CCPM_uniqueStoreEmployeeID__c = storeEmployeeUniqueId;
            lstStoreEmployee.add(objStoreEmp);
        }
        
        return lstStoreEmployee;
    }
    
    /**
      * @description: Creates test Account records that can be inserted in a setup or test method
      * @param: num The number of Accounts to create
      * @return: List of Accounts to be inserted
    **/    
    
    public static list<Account> createAccount (integer num) {
        
        list<Account> lstAcc = new list<Account>();
        for (integer i=0;i<num;i++) {
            Account objAcc = new Account();
            objAcc.name = test + i;
            objAcc.CCPM_accountNumber__c = test + i;
            objAcc.CCPM_accountUniqueID__c = '010101';
            lstAcc.add(objAcc);
        }
        
        return lstAcc;
    }
    
    /**
      * @description: Creates test SMS Message records that can be inserted in a setup or test method
      * @param: num The number of SMS Messages to create
      * @Param: leadId The id of look up lead
      * @return: List of SMS Messages to be inserted
    **/    
    
    public static list<CCPM_SMSMessage__c> createSMSMessage (integer num, id leadId) {
        
        list<CCPM_SMSMessage__c> lstMessage = new list<CCPM_SMSMessage__c>();
        for (integer i=0;i<num;i++) {
            CCPM_SMSMessage__c objSMSMessage = new CCPM_SMSMessage__c();
            objSMSMessage.CCPM_leadRecord__c = leadId;
            lstMessage.add(objSMSMessage);
        }
        
        return lstMessage;
    }
    
    /**
      * @description: Creates test SMS Template records that can be inserted in a setup or test method
      * @param: num The number of SMS Templates to create
      * @param: isActive Boolean if the SMS Templates should be marked as active
      * @param: recTypeID The Record Type ID of the Templates to create
      * @return: List of SMS Templates to be inserted
    **/    
    
        public static list<CCPM_smsTemplate__c> createSMSTemplate (Integer num) {
        
        list<CCPM_smsTemplate__c> lstTemplate = new list<CCPM_smsTemplate__c>();
        for (integer i=0;i<num;i++) {
            CCPM_smsTemplate__c objSMSTemplate = new CCPM_smsTemplate__c();
            lstTemplate.add(objSMSTemplate);
        }
        
        return lstTemplate;
    }
    
/*    public static list<CCPM_smsTemplate__c> createSMSTemplate (Integer num, Boolean isActive, String recTypeID, String evtMsgStartDate, 
                                                               String evtMsgEndDate, String campaignID, String segmentationID) {
        
        list<CCPM_smsTemplate__c> lstTemplate = new list<CCPM_smsTemplate__c>();
        for (integer i=0;i<num;i++) {
            CCPM_smsTemplate__c objSMSTemplate = new CCPM_smsTemplate__c();
            objSMSTemplate.CCPM_isActive__c = isActive;
            objSMSTemplate.recordTypeId = recTypeID;
            objSMSTemplate.CCPM_eventMessageStartDate__c = evtMsgStartDate;
            objSMSTemplate.CCPM_eventMessageEndDate__c = evtMsgEndDate;
            objSMSTemplate.CCPM_campaign__c = campaignID;
            objSMSTemplate.CCPM_segmentation__c = segmentationID;
            lstTemplate.add(objSMSTemplate);
        }
        
        return lstTemplate;
    }
    */
    
    /**
      * @description: Creates Segmentation
      * @param: num The number of Segmentations to create
      * @return: List of Segmentations to be inserted
    **/    
    
    public static list<CCPM_segmentation__c> createSegmentation (integer num) {
        list<CCPM_segmentation__c> lstSegmentation = new list<CCPM_segmentation__c>();
        for (integer i=0;i<num;i++){
            CCPM_segmentation__c objSegmentation = new CCPM_segmentation__c();
            lstSegmentation.add(objSegmentation);
        }
        return lstSegmentation;
    }
    
    
    /**
      * @description: Creates Journey Message
      * @param: num The number of Journey Messages to create
      * @return: List of Journey Messages to be inserted
    **/    
    
    public static list<CCPM_journeyMessage__c> createJourneyMessage (integer num) {
        
        list<CCPM_journeyMessage__c> lstJourneyMessage = new list<CCPM_journeyMessage__c>();
        for (integer i=0;i<num;i++) {
            CCPM_journeyMessage__c objJourneyMessage = new CCPM_journeyMessage__c();
            objJourneyMessage.CCPM_customerMessage__c = 'Custom Message';
            lstJourneyMessage.add(objJourneyMessage);
        }
        return lstJourneyMessage;
    }
    
    /**
      * @description: Creates Campaign
      * @param: num The number of Campaigns to be created
      * @return: List of Campaigns to be inserted
    **/    
    
    public static list<Campaign> createCampaign (integer num) {
        
        list<Campaign> lstCampaign = new list<Campaign>();
        for (integer i=0;i<num;i++) {
            Campaign objCampaign = new Campaign();
            lstCampaign.add(objCampaign);
        }
        return lstCampaign;
    }
    
    /**
      * @description: Creates Campaign Member
      * @param: num The number of Campaigns to be created
      * @return: List of Campaigns to be inserted
    **/    
    
    public static list<CampaignMember> createCampaignMember (String strCampaignKey,id idLeadID) {
        
        list<CampaignMember> lstCampaignMember = new list<CampaignMember>();
        CampaignMember objCampaignMember = new CampaignMember();
        objCampaignMember.LeadId = idLeadID;
        objCampaignMember.CCPM_campaignkey__c = strCampaignKey;
        lstCampaignMember.add(objCampaignMember);
        return lstCampaignMember;
    }
    
    /**
      * @description: Creates test NPS records that can be inserted in a setup or test method
      * @param: num The number of NPS records to create
      * @return: List of NPS records to be inserted
    **/    
    
    public static list<CCPM_NPS__c> createNPSRec (integer num) {
        
        list<CCPM_NPS__c> lstNPS = new list<CCPM_NPS__c>();
        for (integer i=0;i<num;i++) {
            CCPM_NPS__c objNPS = new CCPM_NPS__c();
            lstNPS.add(objNPS);
        }
        
        return lstNPS;
    }
    
    /**
      * @description: Creates test Task records that can be inserted in a setup or test method
      * @param: num The number of Task records to create
      * @return: List of Task records to be inserted
    **/    
    
    public static list<Task> createTask (integer num,id whoId) {
        
        list<Task> lstTask = new list<Task>();
        for (integer i=0;i<num;i++) {
            Task objTask = new Task();
            objtask.whoId = whoId;
            objTask.type = 'SMS';
            objTask.priority = 'Normal';
            objTask.status = 'In Progress';
            objTask.Description = 'Test123';
            lstTask.add(objTask);
        }
        
        return lstTask;
    }
}