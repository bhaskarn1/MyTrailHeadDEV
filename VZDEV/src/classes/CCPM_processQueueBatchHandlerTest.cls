/**
*@name          CCPM_processQueueBatchHandlerTest 
*@author        Manjunath Keshava (Deloitte)
*@date          06/13/2017
@description    This is the Unit Test Class for the CCPM_processQueueBatchHandler Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    10/25/2017               			 Original Version
*/
@isTest
public class CCPM_processQueueBatchHandlerTest
{
    @istest
    public static void processQueuedRecordsTest()
    {
        CCPM_testdataFactory.createCustomSetting();
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
        objCart.CCPM_LeadType__c = 'Prospect Abandoned Cart Digital';
        insert objCart;
        list<CCPM_processingQueue__c> lstobjProcessQueue= new  list<CCPM_processingQueue__c>();
        CCPM_processingQueue__c objProcessQueue1 = new CCPM_processingQueue__c();
        objProcessQueue1.CCPM_queueType__c='Cart Type Processing for Converted Leads';
        objProcessQueue1.CCPM_cartType__c='';
        objProcessQueue1.CCPM_Status__c='New';
        lstobjProcessQueue.add(objProcessQueue1);
        CCPM_processingQueue__c objProcessQueue2 = new CCPM_processingQueue__c();
        objProcessQueue2.CCPM_leadID__c=objCart.id;
        objProcessQueue2.CCPM_queueType__c='SMS Schedules To Be Removed';
        objProcessQueue2.CCPM_accountUniqueID__c='23467';
        objProcessQueue2.CCPM_Status__c='New';
        lstobjProcessQueue.add(objProcessQueue2);
        /*CCPM_processingQueue__c objProcessQueue3 = new CCPM_processingQueue__c();
        //objProcessQueue3.CCPM_queueType__c='strToUpdateTeleSalesLead';
        //objProcessQueue3.CCPM_Status__c='New';
        //lstobjProcessQueue.add(objProcessQueue3);
        CCPM_processingQueue__c objProcessQueue4 = new CCPM_processingQueue__c();
        //objProcessQueue4.CCPM_queueType__c='To Update Tele Sales Lead';
        objProcessQueue4.CCPM_Status__c='New';
        lstobjProcessQueue.add(objProcessQueue4);*/
        insert lstobjProcessQueue;
        list<CCPM_SMSMessage__c> lstSmsSchedule = new list<CCPM_SMSMessage__c> ();
        CCPM_SMSMessage__c objsms= new CCPM_SMSMessage__c();
        objsms.CCPM_leadRecord__c=objcart.id;
        objsms.CCPM_MessageStatus__c='Queued';
        lstSmsSchedule.add(objsms);
        insert lstSmsSchedule;
        CCPM_processQueueBatchHandler.processQueuedRecords(lstobjProcessQueue);
        //CCPM_processQueueBatchHandler.updateOwnershipAndFieldsForLeads(lstobjProcessQueue);
        CCPM_processQueueBatchHandler.CCPM_RemoveSmsScehdules(lstobjProcessQueue);  
        /*CCPM_processQueueBatch objProcessQueue =new CCPM_processQueueBatch();
		integer intBatchSize   = integer.valueof(Label.CCPM_mergeBatchSize);
		database.executebatch(objProcessQueue,intBatchSize);*/
    }
    
}