/**
*@name          CCPM_mergeProspectCartWithProspectTest 
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/25/2017
@description    This is the Unit Test Class for the Leads Merging Functionality
                  
@testClass      
Modification    Log: US-429, US-495, US-496 and US-497
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/04/2017          Original Version
*/
@isTest(SeeAllData=false)
private class CCPM_mergeLeadCartsWithManualLeadsTest {

    static testMethod void mergeLeadCartsWithManualLeadsUnitTest() {
        // TO DO: implement unit test
        list<lead> lstManualLeads = new list<lead>();
        list<lead> lstLeadCarts = new list<lead>(); 
        list<CCPM_Store__c> lstStoreObj = new list<CCPM_Store__c>();   
        CCPM_Store__c objStore = new CCPM_Store__c();
                 
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
        l1.LastName = 'ABCMergeMLOne';
        l1.FirstName = 'TestingMLOne';
        l1.Status = 'New';
        l1.CCPM_accountUniqueID__c = 'MergeML1';
        l1.CCPM_isManualLead__c = true;
        l1.CCPM_leadType__c = 'Customer SFDC Manual';
        l1.CCPM_lastInteraction__c = system.now().addHours(-5);
        l1.CCPM_mobileNumber__c = '9999999991';
        l1.Company = '1';
        l1.LeadSource = 'ATG-ECOM-DESK';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l1.store__c = objStore.Id;
        l1.CCPM_tobeMerged__c = false;
        l1.CCPM_SMSLegalOptIn__c = true; 
   //     l1.CCPM_eventType__c = 'Other Event';
        l1.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstManualLeads.add(l1);
        
        
        // Populating Test Data with the Lead Record Type for the Prospects
        lead l2 = new lead();
 // Scenario with MTN on Prospect       
        l2.LastName = 'ABCMergeMLTwo';
        l2.FirstName = 'TestingMLTwo';
        l2.Status = 'New';
        l2.CCPM_accountUniqueID__c = 'MergeML2';
        l2.CCPM_isManualLead__c = true;
        l2.CCPM_leadType__c = 'Customer SFDC Manual';
        l2.CCPM_lastInteraction__c = system.now().addHours(-5);
        l2.CCPM_mobileNumber__c = '9999999992';
        l2.Company = '1';
        l2.LeadSource = 'ATG-ECOM-DESK';
        l2.CCPM_sendLeadsRequiringActionSMS__c = false;
        l2.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l2.store__c = objStore.Id;
        l2.CCPM_tobeMerged__c = false;
        l2.CCPM_SMSLegalOptIn__c = true; 
   //     l1.CCPM_eventType__c = 'Other Event';
        l2.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstManualLeads.add(l2);
        
            // Populating Test Data with the Lead Record Type for the Prospects
        lead l3 = new lead();
 // Scenario with MTN on Prospect       
        l3.LastName = 'ABCMergeMLThree';
        l3.FirstName = 'TestingMLThree';
        l3.Status = 'New';
        l3.CCPM_accountUniqueID__c = 'MergeML3';
        l3.CCPM_isManualLead__c = true;
        l3.CCPM_leadType__c = 'Customer SFDC Manual';
        l3.CCPM_lastInteraction__c = system.now().addHours(-5);
        //l3.CCPM_mobileNumber__c = '9999999992';
        l3.CCPM_email__c = 'abc@gmail.com';
        l3.Company = '1';
        l3.LeadSource = 'ATG-ECOM-DESK';
        l3.CCPM_sendLeadsRequiringActionSMS__c = false;
        l3.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l3.store__c = objStore.Id;
        l3.CCPM_tobeMerged__c = false;
        l3.CCPM_SMSLegalOptIn__c = true; 
   //     l1.CCPM_eventType__c = 'Other Event';
        l3.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstManualLeads.add(l3);
        
        Id [] fixedSearchResults= new Id[15];

  // Creating the Prospects
       if(lstManualLeads!=null && lstManualLeads.size()>0 && !lstManualLeads.isEmpty())
       {
         insert lstManualLeads;
         integer i = 0;
        for(lead objManualLead: lstManualLeads)
        {
          if(i < 10) fixedSearchResults[i] = objManualLead.id;
          i++;
        }
       
       }
       
       lead lc1 = new lead();
 // Scenario with MTN on and No Merge Master ID and TobeMerged flag is true on Prospect Cart   
        lc1.LastName = 'ABCMergeMLCOne';
        lc1.FirstName = 'TestingMLCOne';
        lc1.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
        lc1.Status = 'New';
        lc1.CCPM_SMSOptOut__c = true;
        lc1.CCPM_cartUniqueID__c = 'MergeMLC1';
        lc1.CCPM_accountUniqueID__c = 'MergeMLC1';
        lc1.CCPM_lastInteraction__c = system.now().addHours(-5);
        lc1.Company = '3';
        lc1.LeadSource = 'ATG-ECOM-GGDESK';
        lc1.CCPM_mobileNumber__c = '9999999991';
        lc1.CCPM_sendLeadsRequiringActionSMS__c = false;
        lc1.CCPM_tobeMerged__c = true;
        lc1.CCPM_SMSLegalOptIn__c = true; 
        lc1.CCPM_storeID__c = objStore.CCPM_storeID__c;
        lc1.store__c = objStore.Id;
   //     lc1.CCPM_eventType__c = 'Other Event';
        lc1.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        
        lstLeadCarts.add(lc1);
  
        lead lc2 = new lead();
        
 // Scenario with MTN on and with Email and With Merge Master ID and TobeMerged flag is true on Prospect Cart  
        lc2.LastName = 'ABCMergeMLCTwo';
        lc2.FirstName = 'TestingMLCTwo';
        lc2.CCPM_leadType__c = 'Customer Abandoned Cart Digital';
        lc2.Status = 'New';
        lc2.CCPM_accountUniqueID__c = 'MergeMLC2';
        lc2.CCPM_cartUniqueID__c = 'MergeMLC2';
        lc2.CCPM_lastInteraction__c = system.now().addHours(-1);
        lc2.Company = '4';
        lc2.LeadSource = 'ATG-ECOM-DESK';
        lc2.CCPM_mobileNumber__c = '9999999992'; 
        lc2.CCPM_sendLeadsRequiringActionSMS__c = false;
   //     lc2.CCPM_mergeMasterID__c = lstLeadProspect[1].ID;
        lc2.CCPM_tobeMerged__c = true;
        lc2.CCPM_SMSLegalOptIn__c = true; 
        lc2.CCPM_cartID__c = 'MergeMLC2';
       // lc2.CCPM_email__c = 'abc@gmail.com';
        lc2.CCPM_cartlastHandledBy__c = 'MergeMLC2';
        lc2.CCPM_createdDate__c = system.now().addHours(-10);
        lc2.CCPM_cartModifiedDate__c = system.now().addHours(-1);
        lc2.CCPM_cartType__c = 'TestType';
        lc2.CCPM_SKU__c = 'Test';
        lc2.Phone = '9999999991';
        lc2.PostalCode = '43016';
        lc2.CCPM_creditApplicationNo__c = 12345;
        lc2.CCPM_creditClass__c = 'TestClass';
        lc2.CCPM_storeID__c = objStore.CCPM_storeID__c;
        lc2.store__c = objStore.Id;
//        lc2.CCPM_eventType__c = 'Other Event';
        lc2.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
       
        lstLeadCarts.add(lc2); 
        
        lead lc3 = new lead();
 // Scenario with MTN on and No Merge Master ID and TobeMerged flag is true on Prospect Cart   
        lc3.LastName = 'ABCMergeMLCThree';
        lc3.FirstName = 'TestingMLCThree';
        lc3.CCPM_leadType__c = 'Customer Abandoned Cart Digital';
        lc3.Status = 'New';
        lc3.CCPM_SMSOptOut__c = true;
        lc3.CCPM_cartUniqueID__c = 'MergeMLC';
        lc3.CCPM_accountUniqueID__c = 'MergeMLC3';
        lc3.CCPM_lastInteraction__c = system.now().addHours(-5);
        lc3.Company = '3';
        lc3.LeadSource = 'ATG-ECOM-GGDESK';
    //    lc3.CCPM_mobileNumber__c = '9999999991';
        lc3.CCPM_email__c = 'abc@gmail.com';
        lc3.CCPM_sendLeadsRequiringActionSMS__c = false;
        lc3.CCPM_tobeMerged__c = true;
        lc3.CCPM_SMSLegalOptIn__c = true; 
        lc3.CCPM_storeID__c = objStore.CCPM_storeID__c;
        lc3.store__c = objStore.Id;
   //     lc3.CCPM_eventType__c = 'Other Event';
        lc3.CCPM_SMSFollowUpDate__c = system.now().addDays(1);
        
        lstLeadCarts.add(lc3);
        
   //     test.startTest();
        if(lstLeadCarts!=null && !lstLeadCarts.isEmpty())
        {          
          insert lstLeadCarts;
          Test.setFixedSearchResults(fixedSearchResults);
        //  system.assertNotEquals(null,lstLeadCarts); 
        }
     //   test.stopTest(); 
        
         // Creating the object for the scheduler class and invoking the execution
        String CRON_EXP = ccpm_staticConstants.StrCRONInt; 
        CCPM_mergeLeadCartsWithManualLeadsJob sch = new CCPM_mergeLeadCartsWithManualLeadsJob(); 
        sch.scheduleIt();
     
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_mergeLeadCartsWithManualLeadsBatch objLeadMergeBatch = new CCPM_mergeLeadCartsWithManualLeadsBatch();
        database.executebatch(objLeadMergeBatch,25);         
        
    }

    static testMethod void mergeLeadCartsWithManualLeadsUnitTestTwo() 
    {
         // TO DO: implement unit test
        list<lead> lstManualLeads = new list<lead>();
        list<lead> lstLeadCarts = new list<lead>(); 
        list<CCPM_Store__c> lstStoreObj = new list<CCPM_Store__c>();   
        CCPM_Store__c objStore = new CCPM_Store__c();
                 
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
        l1.LastName = 'ABCMergeMLOne';
        l1.FirstName = 'TestingMLOne';
        l1.Status = 'New';
        l1.CCPM_accountUniqueID__c = 'MergeML1';
        l1.CCPM_isManualLead__c = true;
        l1.RecordTypeId = CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
        l1.CCPM_leadType__c = 'Customer Abandoned Cart Digital';
        l1.CCPM_lastInteraction__c = system.now().addHours(-5);
        l1.CCPM_mobileNumber__c = '9999999991';
        l1.Company = '1';
        l1.LeadSource = 'ATG-ECOM-DESK';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l1.store__c = objStore.Id;
        l1.CCPM_tobeMerged__c = false;
        l1.CCPM_SMSLegalOptIn__c = true; 
   //     l1.CCPM_eventType__c = 'Other Event';
        l1.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstManualLeads.add(l1);
        
        
        // Populating Test Data with the Lead Record Type for the Prospects
        lead l2 = new lead();
 // Scenario with MTN on Prospect       
        l2.LastName = 'ABCMergeMLTwo';
        l2.FirstName = 'TestingMLTwo';
        l2.Status = 'New';
        l2.CCPM_accountUniqueID__c = 'MergeML2';
        l2.CCPM_isManualLead__c = true;
        l2.CCPM_leadType__c = 'Customer SFDC Manual';
        l2.CCPM_lastInteraction__c = system.now().addHours(-5);
        l2.CCPM_mobileNumber__c = '9999999991';
        l2.Company = '1';
        l2.LeadSource = 'ATG-ECOM-DESK';
        l2.CCPM_sendLeadsRequiringActionSMS__c = false;
        l2.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l2.store__c = objStore.Id;
        l2.CCPM_tobeMerged__c = false;
        l2.CCPM_SMSLegalOptIn__c = true; 
   //     l1.CCPM_eventType__c = 'Other Event';
        l2.CCPM_SMSFollowUpDate__c = system.now().addDays(1);

        lstManualLeads.add(l2);
        
       Id [] fixedSearchResults= new Id[15];

      // Creating the Prospects
       if(lstManualLeads!=null && lstManualLeads.size()>0 && !lstManualLeads.isEmpty())
       {
         insert lstManualLeads;
         integer i = 0;
        for(lead objManualLead: lstManualLeads)
        {
          if(i < 10) fixedSearchResults[i] = objManualLead.id;
          i++;
        }
       
       }    
        // Creating the object for the scheduler class and invoking the execution
        String CRON_EXP = ccpm_staticConstants.StrCRONInt; 
        CCPM_mergeLeadCartsWithManualLeadsJob sch = new CCPM_mergeLeadCartsWithManualLeadsJob(); 
        sch.scheduleIt();
     
        // Creating the object for the Batch Class and invoking the batch execution  
        CCPM_mergeLeadCartsWithManualLeadsBatch objLeadMergeBatch = new CCPM_mergeLeadCartsWithManualLeadsBatch();
        database.executebatch(objLeadMergeBatch,25);  
        
    }    
    
}