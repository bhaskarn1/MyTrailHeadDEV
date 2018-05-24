/**
*@name          CCPM_sendSMSToCustomerCentralRestTest
*@author        Tanweer Maredia(Deloitte)
*@date          05/25/2016
@description    To Test the class CCPM_sendMessagesToCustomerCentralRest


@testClass:     CCPM_sendSMSToCustomerCentralRestTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Tanweer Maredia(Deloitte)    05/25/2016                          Original Version
Sudhakara Reddy Nallamilli(Deloitte) 06/07/2017             Replaced the method name createTask with createTaskWithDescription
*/

@istest(SeeAllData=False)
public class CCPM_sendSMSToCustomerCentralRestTest {    
    /**
*@author        Tanweer Maredia (Deloitte)
*@description   This method creates lead data and user to test Rest API class Method getCustomerInteractions
*@param :       None
*/
    /*
    * Supported Test lead method for create a new lead record inorder to associate lead to Task for API Request
    */
     public static List<lead> testLeadCreation()
    { 
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
        List<lead> lstLead = new List<lead>();
        Lead l1 = new Lead();
        CCPM_testDataFactory.createCustomer(1, 'abc');
        l1.LastName = 'JohnTest';
        l1.FirstName = 'KimerTest';
        l1.Status = 'New';
        l1.CCPM_accountUniqueID__c = '123445Testing';
        l1.CCPM_lastInteraction__c = system.now().addHours(-80);
        l1.CCPM_mobileNumber__c = CCPM_staticConstants.strCustomerMTN;
        l1.Company = '432';
        l1.CCPM_closedLeadSource__c = 'ATG-ECOM-TDOT';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_SMSLegalOptIn__c = true;
        l1.CCPM_storeID__c = objStore.CCPM_storeID__c;
        l1.store__c = objStore.Id;
        l1.CCPM_LeadType__c = 'Customer Abandoned Cart Retail';
        lstLead.add(l1);
        insert lstLead;
        return lstLead;
    }
     /*
     *  Main Test method to create lead and task record in systema and call source method and wrapper method 
     */
      @istest(SeeAllData=False) public static void getCustomerInteractionsTest() {
          List<lead> lstLead = new List<lead>();
          test.startTest();
          lstLead = testLeadCreation();
          System.debug('### Testing lstLead'+ lstLead[0].id);
          CCPM_testDataFactory.createTaskWithDescription(lstLead[0].id,'Inbound','x');
          CCPM_testDataFactory.createTaskWithDescription(lstLead[0].id,'Inbound','Thank you');
          CCPM_testDataFactory.createTaskWithDescription(lstLead.get(0).id,'Outbound','Would you like me to book an appt  to visit my store? If not, what time/day works for you? Reply \"X\" to stop msgs (FreeVzMsg).');
          List<CCPM_sendSMSToCustomerCentralRestWrapper> lstTestLeadsResponse = CCPM_sendMessagesToCustomerCentralRest.getCustomerInteractions();  
          System.debug('@@ Response lstTestLeadsResponse'+ lstTestLeadsResponse);
          System.assertEquals(lstTestLeadsResponse[0].leadId,lstLead[0].id);
          test.stopTest();
          
      }
}