/**
*@name          CCPM_SmsMessageHandlerTest 
*@author        Manjunath Keshava (Deloitte)
*@date          06/13/2017
@description    This is the Unit Test Class for the CCPM_SmsMessageHandler Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    10/25/2017                           Original Version
*/
@isTest
public class CCPM_SmsMessageHandlerTest 
{
    
    @isTest
    public static void CCPM_createMapofStoreandListofAssociatedManagersTest()
    {
        CCPM_testdataFactory.createCustomSetting();
        list<lead> lstLead = new list<lead>();
        list<CCPM_store__C> lststore =  CCPM_testDataFactory.createStore(1);
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstEmployee= [select id,CCPM_employee__c from CCPM_storeEmployee__c where CCPM_role__c='Sales Rep'];
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';  
        objcart.CCPM_accountUniqueID__c='23467';
        // objCart.CCPM_eventType__c = 'SMB';
        objcart.Store__c=lststore[0].id;
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
      //  objCart.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId(); 
        objCart.CCPM_LeadType__c = 'Prospect SFDC Manual';
        insert objCart;
        lstLead.add(objCart);
        map<id,list<CCPM_storeEmployee__c>> MapEmp = new map<id,list<CCPM_storeEmployee__c>>();
        MapEmp.put(objcart.id,lstEmployee);
        list<CCPM_SMSMessage__c> lstmessage = CCPM_testDataFactory.insertSMSObjectRecord(1, 'Hi', 'newProspectSms1',objcart.id);
        insert lstmessage;
        system.debug('%%%%%%%%%msgIS%%'+lstmessage);
        //CCPM_SmsMessageHandler.CCPM_createMapofStoreandListofAssociatedManagers(lstLead);
    }
    
    
}