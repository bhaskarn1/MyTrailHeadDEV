/**
*@name          CCPM_leadRequiringActionSchedulerTest 
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/04/2017
@description    This is the Unit Test Class for the Leads Action Required SMS Followup Remainder Job
                CCPM_leadReqActRemainderJob  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/04/2017          Original Version
*/
@isTest(SeeAllData=false)
private class CCPM_leadRequiringActionSchedulerTest {
@testSetup
  static void createTestDataForThisClass()
  {
     test.startTest();
     Integer i = 0;        
        
        List<lead> lstLead = new List<lead>();
        list<CCPM_Store__c> lstStoreObj = new list<CCPM_Store__c>();
        CCPM_Store__c objStore = new CCPM_Store__c();
        CCPM_testDataFactory.createCustomSetting();
        integer j = 0; 
        // Creating the Store Data using Test Data Factory
        lstStoreObj = CCPM_testDataFactory.createStore(1);
        system.debug('&&&& lstStoreObj: '+ lstStoreObj.size());
        if(lstStoreObj.size() > 0 && lstStoreObj != NULL)
        {
         system.debug('&&&& lstStoreObj[0]'+ lstStoreObj[0]);
         objStore.Id = lstStoreObj[0].Id;
         objStore.Name = lstStoreObj[0].Name;
         objStore.CCPM_storeID__c = lstStoreObj[0].CCPM_storeID__c;         
        } 
        string strStoreId = objStore.CCPM_storeID__c;
        //string strStoreId1 = lstobjStore[0].Id;
        string strStoreName = objStore.Name;
        system.debug('&&&& Store: '+ lstStoreObj );
        system.debug('&&&& Store[0]: '+ lstStoreObj[0]);
        String managerName = 'Man'+strStoreName;
        String repName = 'SR'+ strStoreName; 
        String CommisionableRepID = 'RID' + repName; 
        String assistantManager = 'AsstM'+ strStoreName;
        CCPM_testDataFactory.createStoreEmployee(managerName,repName,CommisionableRepID,assistantManager,objStore.Id);
        
        lead l1 = new lead();
        
        l1.LastName = 'ABCActionRequiredOne';
        l1.FirstName = 'TestingOne';
        l1.Status = 'New';
        l1.CCPM_lastInteraction__c = system.now().addHours(-5);
        l1.CCPM_mobileNumber__c = '9999999999';
        l1.Company = '1';
        l1.CCPM_closedLeadSource__c = 'ATG-ECOM-TDOT';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_storeID__c = strStoreId;
        l1.store__c = objStore.Id;
        l1.CCPM_LeadType__c = 'Customer SFDC Manual';
        l1.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l1.CCPM_SMSLegalOptIn__c = true;
        
        lstLead.add(l1);
        
        lead l2 = new lead();
        l2.LastName = 'ABCActionRequiredTwo';
        l2.FirstName = 'TestingTwo';
        l2.Status = 'Responded';
        l2.CCPM_leadSubStatus__c = 'Action Required';
        l2.CCPM_lastInteraction__c = system.now().addHours(-6);
        l2.Company = '2';
        l2.CCPM_mobileNumber__c = '9999999999';
        l2.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l2.CCPM_sendLeadsRequiringActionSMS__c = false;
        l2.CCPM_storeID__c = strStoreId;
        l2.store__c = objStore.Id;
      //  l2.CCPM_eventType__c = 'Other Event';
        l2.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l2.CCPM_SMSLegalOptIn__c = true;
        l2.CCPM_LeadType__c = 'Customer SFDC Manual';
       
        
        lstLead.add(l2);
        
        lead l3 = new lead();
        l1 = null;
        l3.LastName = 'ABCActionRequiredThree';
        l3.FirstName = 'TestingThree';
        l3.Status = 'Responded';
        l3.CCPM_leadSubStatus__c = 'Action Required';
        l3.CCPM_lastInteraction__c = system.now().addHours(-5);
        l3.Company = '3';
        l3.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l3.CCPM_mobileNumber__c = '9999999999';
        l3.CCPM_sendLeadsRequiringActionSMS__c = false;
        l3.CCPM_storeID__c = strStoreId;
        l3.store__c = objStore.Id;
    //    l3.CCPM_eventType__c = 'Other Event';
        l3.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l3.CCPM_SMSLegalOptIn__c = true;
        l3.CCPM_LeadType__c = 'Customer SFDC Manual';
      
        lstLead.add(l3);
        lead l4 = new lead();
        l4.LastName = 'ABCActionRequiredFour';
        l4.FirstName = 'TestingFour';
        l4.Status = 'Responded';
        l4.CCPM_leadSubStatus__c = 'Action Required';
        l4.CCPM_lastInteraction__c = system.now().addHours(-1);
        l4.Company = '4';
        l4.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l4.CCPM_mobileNumber__c = '9999999999'; 
        l4.CCPM_sendLeadsRequiringActionSMS__c = false;
        l4.CCPM_storeID__c = strStoreId;
        l4.store__c = objStore.Id;
    //    l4.CCPM_eventType__c = 'Other Event';
        l4.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l4.CCPM_SMSLegalOptIn__c = true;
        l4.CCPM_LeadType__c = 'Customer SFDC Manual';
        
        lstLead.add(l4); 
        
        lead l5 = new lead();
        l5.LastName = 'ABCActionRequiredFive';
        l5.FirstName = 'TestingFive';
        l5.Status = 'Responded';
        l5.CCPM_leadSubStatus__c = 'Action Required';
        l5.CCPM_lastInteraction__c = system.now().addHours(-11);
        l5.Company = '5';
        l5.CCPM_mobileNumber__c = '9999999999';
        l5.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l5.CCPM_sendLeadsRequiringActionSMS__c = false;
        l5.CCPM_storeID__c = strStoreId;
        l5.store__c = objStore.Id;
   //     l5.CCPM_eventType__c = 'Other Event';
        l5.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l5.CCPM_SMSLegalOptIn__c = true;
        l5.CCPM_LeadType__c = 'Customer SFDC Manual';        
        lstLead.add(l5);
        
        lead l6 = new lead();
        l6.LastName = 'ABCActionRequiredSix';
        l6.FirstName = 'TestingSix';
        l6.Status = 'Responded';
        l6.CCPM_leadSubStatus__c = 'Action Required';
        l6.CCPM_lastInteraction__c = system.now().addHours(-10);
        l6.Company = '6';
        l6.CCPM_mobileNumber__c = '9999999999';
        l6.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l6.CCPM_sendLeadsRequiringActionSMS__c = false;
        l6.CCPM_storeID__c = strStoreId;
        l6.store__c = objStore.Id;
   //     l6.CCPM_eventType__c = 'Other Event';
        l6.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l6.CCPM_SMSLegalOptIn__c = true;  
        l6.CCPM_LeadType__c = 'Customer SFDC Manual';         
        lstLead.add(l6);
        
        lead l7 = new lead();
        l7.LastName = 'ABCActionRequiredSeven';
        l7.FirstName = 'TestingSeven';
        l7.Status = 'Responded';
        l7.CCPM_leadSubStatus__c = 'Action Required';
        l7.CCPM_lastInteraction__c = system.now().addHours(-9);
        l7.Company = '7';
        l7.CCPM_mobileNumber__c = '9999999999';
        l7.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l7.CCPM_sendLeadsRequiringActionSMS__c = false;
        l7.CCPM_storeID__c = strStoreId;
        l7.store__c = objStore.Id;
   //     l7.CCPM_eventType__c = 'Other Event';
        l7.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l7.CCPM_SMSLegalOptIn__c = true;   
        l7.CCPM_LeadType__c = 'Customer SFDC Manual';
        
        lstLead.add(l7);
        
        lead l8 = new lead();
        l8.LastName = 'ABCActionRequiredEight';
        l8.FirstName = 'TestingEight';
        l8.Status = 'Responded';
        l8.CCPM_leadSubStatus__c = 'Action Required';
        l8.CCPM_lastInteraction__c = system.now().addHours(-5);
        l8.Company = '8';
        l8.CCPM_mobileNumber__c = '9999999999';
        l8.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l8.CCPM_sendLeadsRequiringActionSMS__c = false;
        l8.CCPM_storeID__c = strStoreId;
        l8.store__c = objStore.Id;
   //     l8.CCPM_eventType__c = 'Other Event';
        l8.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l8.CCPM_SMSLegalOptIn__c = true;
        l8.CCPM_LeadType__c = 'Customer SFDC Manual';
        
        lstLead.add(l8);
        
        lead l9 = new lead();
        l9.LastName = 'ABCActionRequiredNine';
        l9.FirstName = 'TestingNine';
        l9.Status = 'Responded';
        l9.CCPM_leadSubStatus__c = 'Action Required';
        l9.CCPM_lastInteraction__c = system.now().addHours(-8);
        l9.Company = '10';
        l9.CCPM_mobileNumber__c = '9999999999';
        l9.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l9.CCPM_sendLeadsRequiringActionSMS__c = false;
        l9.CCPM_storeID__c = strStoreId;
        l9.store__c = objStore.Id;
  //      l9.CCPM_eventType__c = 'Other Event';
        l9.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l9.CCPM_SMSLegalOptIn__c = true;   
        l9.CCPM_LeadType__c = 'Customer SFDC Manual';         
        lstLead.add(l9);
        
        lead l10 = new lead();
        l10.LastName = 'ABCActionRequiredTen';
        l10.FirstName = 'TestingTen';
        l10.Status = 'Responded';
        l10.CCPM_leadSubStatus__c = 'Action Required';
        l10.CCPM_lastInteraction__c = system.now().addHours(-7);
        l10.Company = '11';
        l10.CCPM_mobileNumber__c = '9999999999';
        l10.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l10.CCPM_sendLeadsRequiringActionSMS__c = false;
        l10.CCPM_storeID__c = strStoreId;
        l10.store__c = objStore.Id;
   //     l10.CCPM_eventType__c = 'Other Event';
        l10.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l10.CCPM_SMSLegalOptIn__c = true;      
        l10.CCPM_LeadType__c = 'Customer SFDC Manual';        
        lstLead.add(l10);
        
        lead l11 = new lead();
        l11.LastName = 'ABCActionRequiredEle';
        l11.FirstName = 'TestingEle';
        l11.Status = 'Responded';
        l11.CCPM_leadSubStatus__c = 'Action Required';
        l11.CCPM_lastInteraction__c = system.now().addHours(-6);
        l11.Company = '12';
        l11.CCPM_mobileNumber__c = '9999999999';
        l11.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l11.CCPM_sendLeadsRequiringActionSMS__c = false;
        l11.CCPM_storeID__c = strStoreId;
        l11.store__c = objStore.Id;
   //     l11.CCPM_eventType__c = 'Other Event';
        l11.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l11.CCPM_SMSLegalOptIn__c = true;    
        l11.CCPM_LeadType__c = 'Customer SFDC Manual';        
        lstLead.add(l11);
        
        lead l12 = new lead();
        l12.LastName = 'ABCActionRequiredTwelve';
        l12.FirstName = 'TestingTwelve';
        l12.Status = 'Responded';
        l12.CCPM_leadSubStatus__c = 'Action Required';
        l12.CCPM_lastInteraction__c = system.now().addHours(-6);
        l12.Company = '13';
        l12.CCPM_mobileNumber__c = '9999999999';
        l12.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l12.CCPM_sendLeadsRequiringActionSMS__c = false;
        l12.CCPM_storeID__c = strStoreId;
        l12.store__c = objStore.Id;
        l12.CCPM_SMSLegalOptIn__c = true;
        l12.CCPM_LeadType__c = 'Customer SFDC Manual';        
        lstLead.add(l12);
        
        lead l13 = new lead();
        l13.LastName = 'ABCActionRequiredThirteen';
        l13.FirstName = 'TestingThirteen';
        l13.Status = 'Responded';
        l13.CCPM_leadSubStatus__c = 'Action Required';
        l13.CCPM_lastInteraction__c = system.now().addHours(-6);
        l13.Company = '14';
        l13.CCPM_mobileNumber__c = '9999999999';
        l13.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l13.CCPM_sendLeadsRequiringActionSMS__c = false;
        l13.CCPM_storeID__c = strStoreId;
        l13.store__c = objStore.Id;
  //      l13.CCPM_eventType__c = 'Other Event';
        l13.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l13.CCPM_SMSLegalOptIn__c = true;    
        l13.CCPM_LeadType__c = 'Customer SFDC Manual';        
        lstLead.add(l13);
        
        lead l14 = new lead();
        l14.LastName = 'ABCActionRequiredFourteen';
        l14.FirstName = 'TestingFourteen';
        l14.Status = 'Responded';
        l14.CCPM_leadSubStatus__c = 'Action Required';
        l14.CCPM_lastInteraction__c = system.now().addHours(-6);
        l14.Company = '15';
        l14.CCPM_mobileNumber__c = '9999999999';
        l14.CCPM_closedLeadSource__c = 'ATG-ECOM-DESK';
        l14.CCPM_sendLeadsRequiringActionSMS__c = false;
        l14.store__c = objStore.Id;
  //      l14.CCPM_eventType__c = 'Other Event';
        l14.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l14.CCPM_SMSLegalOptIn__c = true; 
        l14.CCPM_LeadType__c = 'Customer SFDC Manual';            
        lstLead.add(l14);
        
        insert lstLead;
    test.stopTest();
  }
      
    static testMethod void myUnitTestRemainderJob() {
        
    //  CCPM_leadRequiringActionSchedulerTest.createTestDataForThisClass();
        String CRON_EXP = '0 5 * * * ?'; 
        CCPM_leadRequiringActionScheduler sch = new CCPM_leadRequiringActionScheduler(); 
        sch.shceduleIt();
        system.schedule('CCPM_leadRequiringActionSchedulerTest-5 Mins', CRON_EXP, sch); 
    }
}