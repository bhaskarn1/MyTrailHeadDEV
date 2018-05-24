/**
*@name          CCPM_TriggerDispatcher 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          10/05/2017
*@description   The dispatcher is responsible for making sure all of the applicable methods on your trigger handler are called, 
depending on the current trigger context
*@Class         CCPM_TriggerDispatcher
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    10/05/2017   Initial Implementation.
*/
@isTest
public class CCPM_TriggerDispatcherTest {
    @isTest
    public static void TriggerDispatcherTest()
    {
        CCPM_testdataFactory.createCustomSetting();
        CCPM_leadtriggerHandler.boolTriggerDisabled=true;
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';  
        objcart.CCPM_accountUniqueID__c='23467';
        // objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';        
        objCart.CCPM_LeadType__c = 'Prospect SFDC Manual'; 
        insert objCart;
        CCPM_leadtriggerHandler.boolTriggerDisabled=false;
        List<Lead> lstLead = [Select id From Lead];
        System.assertEquals(1, lstLead.size());
        delete objcart;
        lstLead = [Select id From Lead];
        System.assertEquals(0, lstLead.size());
        undelete objcart;
        lstLead = [Select id From Lead];
        System.assertEquals(1, lstLead.size());
        
        objCart.Company = '2';
        
        update objCart;
        
        objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';  
        objcart.CCPM_accountUniqueID__c='23467';
        // objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        //datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';        
        objCart.CCPM_LeadType__c = 'Prospect SFDC Manual';         insert objCart;
        
        lstLead = [Select id From Lead];
        System.assertEquals(2, lstLead.size());
        
       
        
        
        
        
    }
}