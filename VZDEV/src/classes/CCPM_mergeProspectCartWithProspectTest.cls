/**
*@name          CCPM_mergeProspectCartWithProspectTest 
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/25/2017
@description    This is the Unit Test Class for the Leads Merging Functionality
                  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/04/2017          Original Version
*/
@isTest(SeeAllData=false)
private class CCPM_mergeProspectCartWithProspectTest {

    static testMethod void mergeProspectWithProspectCartUnitTest() {
        list<lead> lstLeadProspect = new list<lead>();
        list<lead> lstLeadProspectCart = new list<lead>(); 
        list<CCPM_Store__c> lstStoreObj = new list<CCPM_Store__c>();   
        CCPM_Store__c objStore = new CCPM_Store__c();
        set<id> setLeadId = new  set<id>();        
        CCPM_testDataFactory.createCustomSetting();
         // Creating the Store Data using Test Data Factory
        lstStoreObj = CCPM_testDataFactory.createStore(1);
        if(lstStoreObj != NULL && !lstStoreObj.isEmpty() )
        {
         objStore.Id = lstStoreObj[0].Id;
         objStore.Name = lstStoreObj[0].Name;
         objStore.CCPM_storeID__c = lstStoreObj[0].CCPM_storeID__c;         
        }

     // Populating Test Data with the Lead Record Type for the Prospects
       lead l1 = new lead();
 // Scenario with MTN on Prospect       
        l1.LastName = 'ABCMergeOne';
        l1.FirstName = 'TestingOne';
        l1.Status = 'New';
        l1.CCPM_accountUniqueID__c = 'Merge1';
        l1.CCPM_leadType__c = 'Prospect SFDC Manual';
        l1.CCPM_lastInteraction__c = system.now().addHours(-5);
        l1.CCPM_mobileNumber__c = '9999999993';
        l1.Company = '1';
        l1.LeadSource = 'ATG-ECOM-DESK';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l1.store__c = objStore.Id;
        l1.CCPM_tobeMerged__c = false;
        l1.CCPM_SMSLegalOptIn__c = true; 
   //     l1.CCPM_eventType__c = 'Other Event';
        l1.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstLeadProspect.add(l1);
        
        lead l12 = new lead();
        l12.FirstName = 'ABCMergeCart';
        l12.LastName = 'ABCMergeTwelve';
        l12.Status = 'Responded';
        l12.CCPM_accountUniqueID__c = 'Merge12';
        l12.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l12.CCPM_leadSubStatus__c = 'Action Required';
        l12.CCPM_lastInteraction__c = system.now().addHours(-6);
        l12.Company = '1';
        l12.CCPM_mobileNumber__c = '9999991191';
        l12.CCPM_email__c = 'xyz@gmail.com';
        l12.LeadSource = 'ATG-ECOM-DESK';
        l12.CCPM_sendLeadsRequiringActionSMS__c = false;
        l12.CCPM_tobeMerged__c = false;  
        l12.CCPM_SMSLegalOptIn__c = true; 
        l12.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l12.store__c = objStore.Id;
        l12.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
  
        lstLeadProspect.add(l12);
        lead l17 = new lead();
         
        l17.LastName = 'ABCMergeSevteen';
        l17.Status = 'Responded';
        l17.CCPM_accountUniqueID__c = 'Merge17';
        l17.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l17.CCPM_leadSubStatus__c = 'Action Required';
        l17.CCPM_lastInteraction__c = system.now().addHours(-6);
        l17.Company = '1';
      //  l17.CCPM_mobileNumber__c = '9991199992';
        l17.CCPM_email__c = 'pqr@gmail.com';
        l17.LeadSource = 'ATG-ECOM-DESK';
        l17.CCPM_sendLeadsRequiringActionSMS__c = false;
        l17.CCPM_tobeMerged__c = false;  
        l17.CCPM_SMSLegalOptIn__c = true; 
        l17.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l17.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l17.store__c = objStore.Id;
  
        lstLeadProspectCart.add(l17);   
        
        // Populating Test Data with the Lead Record Type for the Prospects
        lead l15 = new lead();
 // Scenario with MTN on Prospect       
        l15.LastName = 'ABCMergeFifteen';
        l15.FirstName = 'TestingFifteen';
        l15.Status = 'New';
        l15.CCPM_accountUniqueID__c = 'Merge15';
        l15.CCPM_leadType__c = 'Prospect SFDC Manual';
        l15.CCPM_lastInteraction__c = system.now().addHours(-5);
        l15.CCPM_mobileNumber__c = '9991199992';
        l15.Company = '1';
        l15.LeadSource = 'ATG-ECOM-DESK';
        l15.CCPM_sendLeadsRequiringActionSMS__c = false;
        l15.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l15.store__c = objStore.Id;
        l15.CCPM_tobeMerged__c = false;
        l15.CCPM_SMSLegalOptIn__c = true; 
        l15.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstLeadProspect.add(l15);
 // Scenario with MTN and with email and without First Name on Prospect         
        lead l2 = new lead();
        l2.LastName = 'ABCMergeTwo';
        l2.Status = 'Responded';
        l2.CCPM_accountUniqueID__c = 'Merge2';
        l2.CCPM_leadType__c = 'Prospect SFDC Manual';
        l2.CCPM_leadSubStatus__c = 'Action Required';
        l2.CCPM_lastInteraction__c = system.now().addHours(-6);
        l2.Company = '2';
        l2.CCPM_mobileNumber__c = '9999999991';
        l2.CCPM_email__c = 'abc@gmail.com';
        l2.LeadSource = 'ATG-ECOM-DESK';
        l2.CCPM_sendLeadsRequiringActionSMS__c = false;
        l2.CCPM_tobeMerged__c = false;  
        l2.CCPM_SMSLegalOptIn__c = true; 
        l2.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l2.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l2.store__c = objStore.Id;
        
        lstLeadProspect.add(l2);
  // Scenario without MTN and with email on Prospect       
        lead l6 = new lead();
        l6.LastName = 'ABCMergeTen';
        l6.FirstName = 'TestingTen';
        l6.Status = 'Responded';
        l6.CCPM_accountUniqueID__c = 'Merge10';
        l6.CCPM_leadType__c = 'Prospect SFDC Manual';
        l6.CCPM_lastInteraction__c = system.now().addHours(-6);
        l6.Company = '2';
        l6.CCPM_email__c = 'abc123@gmail.com';
        l6.LeadSource = 'ATG-ECOM-DESK';
        l6.CCPM_sendLeadsRequiringActionSMS__c = false;
        l6.CCPM_tobeMerged__c = false;
        l6.CCPM_SMSLegalOptIn__c = true; 
        l6.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l6.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l6.store__c = objStore.Id;
        
        lstLeadProspect.add(l6);
        
        lead l10 = new lead();
 // Scenario with MTN on and No Merge Master ID and TobeMerged flag is true on Prospect Cart  
        l10.FirstName = 'ABCMergeEleCart'; 
        l10.LastName = 'ABCMergeEle';
     //   l10.FirstName = 'TestingEle';
        l10.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l10.Status = 'New';
        l10.CCPM_accountUniqueID__c = 'Merge11';
        l10.CCPM_lastInteraction__c = system.now().addHours(-5);
        l10.Company = '2';
        l10.LeadSource = 'ATG-ECOM-GGDESK';
        l10.CCPM_mobileNumber__c = '9992299993';
        l10.CCPM_sendLeadsRequiringActionSMS__c = false;
        l10.CCPM_tobeMerged__c = false;
        l10.CCPM_SMSLegalOptIn__c = true; 
        l10.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l10.store__c = objStore.Id;
        l10.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        
        lstLeadProspect.add(l10);

       Id [] fixedSearchResults= new Id[15];

  // Creating the Prospects
       if(lstLeadProspect!=null && lstLeadProspect.size()>0 && lstLeadProspect.isEmpty()==false)
       {
         insert lstLeadProspect;
         integer i = 0;
        for(lead objLeadProspect: lstLeadProspect)
        {
          if(i < 10) fixedSearchResults[i] = objLeadProspect.id;
          i++;
        }
       
       }
        lead l3 = new lead();
 // Scenario with MTN on and No Merge Master ID and TobeMerged flag is true on Prospect Cart   
        l3.LastName = 'ABCMergeThree';
        l3.FirstName = 'TestingThree';
        l3.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l3.Status = 'New';
        l3.CCPM_accountUniqueID__c = 'Merge3';
        l3.CCPM_lastInteraction__c = system.now().addHours(-5);
        l3.Company = '3';
        l3.LeadSource = 'ATG-ECOM-GGDESK';
        l3.CCPM_mobileNumber__c = '9999999993';
        l3.CCPM_sendLeadsRequiringActionSMS__c = false;
        l3.CCPM_tobeMerged__c = true;
        l3.CCPM_SMSLegalOptIn__c = true; 
        l3.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l3.store__c = objStore.Id;
   //     l3.CCPM_eventType__c = 'Other Event';
        l3.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        
        lstLeadProspectCart.add(l3);
  
        lead l4 = new lead();
        
 // Scenario with MTN on and with Email and With Merge Master ID and TobeMerged flag is true on Prospect Cart  
        l4.LastName = 'ABCMergeFour';
        l4.FirstName = 'TestingFour';
        l4.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l4.Status = 'New';
        l4.CCPM_accountUniqueID__c = 'Merge4';
        l4.CCPM_lastInteraction__c = system.now().addHours(-1);
        l4.Company = '4';
        l4.LeadSource = 'ATG-ECOM-DESK';
        l4.CCPM_mobileNumber__c = '9999999991'; 
        l4.CCPM_sendLeadsRequiringActionSMS__c = false;
   //     l4.CCPM_mergeMasterID__c = lstLeadProspect[1].ID;
        l4.CCPM_tobeMerged__c = true;
        l4.CCPM_SMSLegalOptIn__c = true; 
        l4.CCPM_cartID__c = 'Merge1';
        l4.CCPM_email__c = 'abc@gmail.com';
        l4.CCPM_cartlastHandledBy__c = 'Test1';
        l4.CCPM_createdDate__c = system.now().addHours(-10);
        l4.CCPM_cartModifiedDate__c = system.now().addHours(-1);
        l4.CCPM_cartType__c = 'TestType';
        l4.CCPM_SKU__c = 'Test';
        l4.Phone = '9999999991';
        l4.PostalCode = '43016';
        l4.CCPM_creditApplicationNo__c = 12345;
        l4.CCPM_creditClass__c = 'TestClass';
        l4.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l4.store__c = objStore.Id;
//        l4.CCPM_eventType__c = 'Other Event';
        l4.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
       
        lstLeadProspectCart.add(l4); 
        
        lead l5 = new lead();
 // Scenario without MTN and with Email and With Merge Master ID and TobeMerged flag is true on Prospect Cart  
        l5.LastName = 'ABCMergeFive';
        l5.FirstName = 'TestingFive';
        l5.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l5.Status = 'New';
        l5.CCPM_accountUniqueID__c = 'Merge5';
        l5.CCPM_lastInteraction__c = system.now().addHours(-1);
        l5.Company = '4';
        l5.LeadSource = 'ATG-ECOM-DESK';
    //    l5.CCPM_mobileNumber__c = '9999999992'; 
        l5.CCPM_email__c = 'abc123@gmail.com';
        l5.CCPM_sendLeadsRequiringActionSMS__c = false;
    //    l5.CCPM_mergeMasterID__c = lstLeadProspect[2].ID;
        l5.CCPM_tobeMerged__c = true;
        l5.CCPM_SMSLegalOptIn__c = true; 
        l5.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l5.store__c = objStore.Id;
   //     l5.CCPM_eventType__c = 'Other Event';
        l5.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
       
        lstLeadProspectCart.add(l5); 
        
        lead l7 = new lead();
 // Scenario with MTN on and No Merge Master Record and TobeMerged flag is true on Prospect Cart   
        l7.LastName = 'ABCMergeSeven';
        l7.FirstName = 'TestingSeven';
        l7.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l7.Status = 'New';
        l7.CCPM_accountUniqueID__c = 'Merge7';
        l7.CCPM_lastInteraction__c = system.now().addHours(-7);
        l7.Company = '3';
        l7.LeadSource = 'ATG-ECOM-GGDESK';
        l7.CCPM_mobileNumber__c = '9999999996';
        l7.CCPM_sendLeadsRequiringActionSMS__c = false;
        l7.CCPM_tobeMerged__c = true;
        l7.CCPM_SMSLegalOptIn__c = true; 
        l7.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l7.store__c = objStore.Id;
  //      l7.CCPM_eventType__c = 'Other Event';
        l7.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        
        lead l8 = new lead();
 // Scenario with MTN on and No Merge Master Record and TobeMerged flag is true on Prospect Cart   
        l8.LastName = 'ABCMergeEight';
        l8.FirstName = 'TestingEight';
        l8.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l8.Status = 'New';
        l8.CCPM_accountUniqueID__c = 'Merge8';
        l8.CCPM_lastInteraction__c = system.now().addHours(-7);
        l8.Company = '1';
        l8.LeadSource = 'NETACE';
        l8.CCPM_mobileNumber__c = '9992299993';
        l8.CCPM_sendLeadsRequiringActionSMS__c = false;
        l8.CCPM_tobeMerged__c = true;
        l8.CCPM_SMSLegalOptIn__c = true; 
        l8.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l8.store__c = objStore.Id;
  //      l7.CCPM_eventType__c = 'Other Event';
        l8.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        
        
        lstLeadProspectCart.add(l8);
        
         lead l9 = new lead();
 // Scenario without MTN and with Email and With Merge Master ID and TobeMerged flag is true on Prospect Cart  
        l9.LastName = 'ABCMergeNine';
        l9.FirstName = 'TestingNine';
        l9.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l9.Status = 'New';
        l9.CCPM_accountUniqueID__c = 'Merge9';
        l9.CCPM_lastInteraction__c = system.now().addHours(-1);
        l9.Company = '4';
        l9.LeadSource = 'ATG-ECOM-DESK';
    //    l9.CCPM_mobileNumber__c = '9999999992'; 
        l9.CCPM_email__c = 'xyz@gmail.com';
        l9.CCPM_sendLeadsRequiringActionSMS__c = false;
    //    l9.CCPM_mergeMasterID__c = lstLeadProspect[2].ID;
        l9.CCPM_tobeMerged__c = true;
        l9.CCPM_SMSLegalOptIn__c = true; 
        l9.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l9.store__c = objStore.Id;
   //     l9.CCPM_eventType__c = 'Other Event';
        l9.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
       
        lstLeadProspectCart.add(l9); 
        
        lead l13 = new lead();
        l13.LastName = 'ABCMergeThirteen';
        l13.Status = 'Responded';
        l13.CCPM_accountUniqueID__c = 'Merge13';
        l13.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l13.CCPM_leadSubStatus__c = 'Action Required';
        l13.CCPM_lastInteraction__c = system.now().addHours(-6);
        l13.Company = '1';
        l13.CCPM_mobileNumber__c = '9991199992'; 
     //   l13.CCPM_email__c = 'pqr@gmail.com';
        l13.LeadSource = 'ATG-ECOM-DESK';
        l13.CCPM_sendLeadsRequiringActionSMS__c = false;
        l13.CCPM_tobeMerged__c = true;  
        l13.CCPM_SMSLegalOptIn__c = true; 
        l13.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l13.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l13.store__c = objStore.Id;
  
           lstLeadProspectCart.add(l13);
           
        lead l14 = new lead();
         
        l14.LastName = 'ABCMergeFourteen';
        l14.Status = 'Responded';
        l14.CCPM_accountUniqueID__c = 'Merge14';
        l14.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l14.CCPM_leadSubStatus__c = 'Action Required';
        l14.CCPM_lastInteraction__c = system.now().addHours(-6);
        l14.Company = '1';
        l14.CCPM_mobileNumber__c = '9991199992';
    //    l14.CCPM_email__c = 'pqr@gmail.com';
        l14.LeadSource = 'ATG-ECOM-DESK';
        l14.CCPM_sendLeadsRequiringActionSMS__c = false;
        l14.CCPM_tobeMerged__c = true;  
        l14.CCPM_SMSLegalOptIn__c = true; 
        l14.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l14.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l14.store__c = objStore.Id;
  
        lstLeadProspectCart.add(l14);   
        
        lead l16 = new lead();
         
        l16.LastName = 'ABCMergeSixteen';
        l16.Status = 'Responded';
        l16.CCPM_accountUniqueID__c = 'Merge16';
        l16.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
        l16.CCPM_leadSubStatus__c = 'Action Required';
        l16.CCPM_lastInteraction__c = system.now().addHours(-6);
        l16.Company = '1';
      //  l16.CCPM_mobileNumber__c = '9991199992';
        l16.CCPM_email__c = 'pqr@gmail.com';
        l16.LeadSource = 'ATG-ECOM-DESK';
        l16.CCPM_sendLeadsRequiringActionSMS__c = false;
        l16.CCPM_tobeMerged__c = true;  
        l16.CCPM_SMSLegalOptIn__c = true; 
        l16.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        l16.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l16.store__c = objStore.Id;
        lstLeadProspectCart.add(l16);   

        CCPM_leadHandler.run = true;
        
       test.startTest();
      if(lstLeadProspectCart!=null && lstLeadProspectCart.size()>0 && lstLeadProspectCart.isEmpty()==false )
      {
        
        insert lstLeadProspectCart;
        system.assertNotEquals(null,lstLeadProspectCart);      
        Test.setFixedSearchResults(fixedSearchResults);
      /*  for(lead objLead: lstLeadProspectCart)  
        {
         setLeadId.add(objLead.id); 
        }   
       if(setLeadId != null && setLeadId.isEmpty() == false)  
        CCPM_sendSMSMergeManual.updateSMSMessageRecords(setLeadId,true); */
       }
      test.stopTest(); 
  
        // Creating the object for the scheduler class and invoking the execution
        String CRON_EXP = ccpm_staticConstants.StrCRONInt; 
        CCPM_mergeProspectCartWithProspectJob sch = new CCPM_mergeProspectCartWithProspectJob(); 
        sch.scheduleIt();
     
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_mergeProspectCartWithProspectBatch objLeadMergeBatch = new CCPM_mergeProspectCartWithProspectBatch();
        database.executebatch(objLeadMergeBatch,25); 
        
    }
    
    static testMethod void mergeProspectWithProspectCartUnitTesttwo() 
    {
        list<lead> lstLeadProspect = new list<lead>();
        list<lead> lstLeadProspectCart = new list<lead>(); 
        list<CCPM_Store__c> lstStoreObj = new list<CCPM_Store__c>();   
        CCPM_Store__c objStore = new CCPM_Store__c();
        set<id> setLeadId = new  set<id>();        
        CCPM_testDataFactory.createCustomSetting();
         // Creating the Store Data using Test Data Factory
        lstStoreObj = CCPM_testDataFactory.createStore(1);
        if(lstStoreObj != NULL && !lstStoreObj.isEmpty() )
        {
         objStore.Id = lstStoreObj[0].Id;
         objStore.Name = lstStoreObj[0].Name;
         objStore.CCPM_storeID__c = lstStoreObj[0].CCPM_storeID__c;         
        }

        // Populating Test Data with the Lead Record Type for the Prospects
       lead l1 = new lead();
 // Scenario with MTN on Prospect       
        l1.LastName = 'ABCMergeOne';
        l1.FirstName = 'TestingOne';
        l1.Status = 'New';
        l1.CCPM_accountUniqueID__c = 'Merge1';
        l1.CCPM_leadType__c = 'Prospect SFDC Manual';
        l1.CCPM_lastInteraction__c = system.now().addHours(-5);
        l1.CCPM_mobileNumber__c = '9999999993';
        l1.Company = '1';
        l1.LeadSource = 'ATG-ECOM-DESK';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l1.store__c = objStore.Id;
        l1.CCPM_tobeMerged__c = true;
        l1.CCPM_SMSLegalOptIn__c = true; 
   //     l1.CCPM_eventType__c = 'Other Event';
        l1.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstLeadProspect.add(l1);
     
        
        lead l12 = new lead();
        l12.FirstName = 'ABCMergeCart';
        l12.LastName = 'ABCMergeTwelve';
        l12.Status = 'Responded';
        l12.CCPM_accountUniqueID__c = 'Merge12';
        l12.CCPM_leadType__c = 'Prospect SFDC Manual';
        l12.CCPM_leadSubStatus__c = 'Action Required';
        l12.CCPM_lastInteraction__c = system.now().addHours(-6);
        l12.Company = '1';
        l12.CCPM_mobileNumber__c = '9999999993';
        l12.CCPM_email__c = 'xyz@gmail.com';
        l12.LeadSource = 'ATG-ECOM-DESK';
        l12.CCPM_sendLeadsRequiringActionSMS__c = false;
        l12.CCPM_tobeMerged__c = true;  
        l12.CCPM_SMSLegalOptIn__c = true; 
        l12.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l12.store__c = objStore.Id;
        l12.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
  
        lstLeadProspect.add(l12);
        Id [] fixedSearchResults= new Id[15];

        test.startTest();
      if(lstLeadProspect!=null && lstLeadProspect.size()>0 && lstLeadProspect.isEmpty()==false )
      {
        
        insert lstLeadProspect;
        system.assertNotEquals(null,lstLeadProspect);      
        Test.setFixedSearchResults(fixedSearchResults);
      /*  for(lead objLead: lstLeadProspectCart)  
        {
         setLeadId.add(objLead.id); 
        }   
       if(setLeadId != null && setLeadId.isEmpty() == false)  
        CCPM_sendSMSMergeManual.updateSMSMessageRecords(setLeadId,true); */
       }
        
      test.stopTest(); 
  
        // Creating the object for the scheduler class and invoking the execution
        String CRON_EXP = ccpm_staticConstants.StrCRONInt; 
        CCPM_mergeProspectCartWithProspectJob sch = new CCPM_mergeProspectCartWithProspectJob(); 
        sch.scheduleIt();
     
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_mergeProspectCartWithProspectBatch objLeadMergeBatch = new CCPM_mergeProspectCartWithProspectBatch();
        database.executebatch(objLeadMergeBatch,25); 
        
    }
    
 /* static testMethod void updateSMSMessageRecordsFail() {
      map<id,CCPM_smsmessage__c> mapSMSMessages = new map<id,CCPM_smsmessage__c>();
      CCPM_smsmessage__c objSMS = new CCPM_smsmessage__c();
      mapSMSMessages.put(objSMS.id,objSMS);
      CCPM_sendSMSMergeManual.updateSMSMessageRecords(mapSMSMessages,false); 
  }*/
    
}