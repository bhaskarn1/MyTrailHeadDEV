/**
*@name          CCPM_expireInActiveLeadsBatchTest
*@author        Paras Shah (Deloitte)
*@date          05/25/2017
@description    This is a test class for CCPM_expireInActiveLeadsBatch


@testClass:     CCPM_expireInActiveLeadsBatchTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)    05/25/2017                          Original Version
*/

@istest(SeeAllData=False)
public class CCPM_expireInActiveLeadsBatchTest {    
    
    public static list<string> lstAccountUniqueID=new list<string>();
    
    /**
*@author        Paras Shah (Deloitte)
*@description   This method is targeted to test the CCPM_SMSInteractionHistoryController class
*@param :       None
*/
    @istest(SeeAllData=False) public static void testLeadCreation()
    {   
        List<lead> lstLead = new List<lead>();
        Lead l1 = new Lead();
        
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        
 //       Id customerCartRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer Cart').getRecordTypeId();
        list<CCPM_Store__c> lstObjStore = CCPM_testDataFactory.createStore(CCPM_staticConstants.NoOfRecords);
        CCPM_testDataFactory.createCustomer(1, 'abc');
 
        l1.LastName = 'ABCActionRequiredOne';
        l1.FirstName = 'TestingOne';
        l1.Status = 'New';
        l1.CCPM_accountUniqueID__c = 'abc0';
        l1.CCPM_lastInteraction__c = system.now().addHours(-800);
        l1.CCPM_mobileNumber__c = '9999999999';
        l1.Company = '1';
        l1.CCPM_SMSLegalOptIn__c = True;
        l1.CCPM_closedLeadSource__c = 'ATG-ECOM-TDOT';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_storeID__c = lstObjStore[0].CCPM_storeid__c;
    //    l1.RecordTypeId = customerCartRecordTypeId;
        l1.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';

        lstLead.add(l1);
        
        insert lstLead;

        
        Database.executeBatch(new CCPM_expireInActiveLeadsBatch(),200);

        test.stopTest();
    }        
  }