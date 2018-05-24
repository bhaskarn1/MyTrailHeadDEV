/**
*@name          CCPM_processQueueBatchTest
*@author        Paras Shah (Deloitte)
*@date          09/29/2017
@description    To Test the Batch class CCPM_processQueueBatchTest


@testClass:     CCPM_processQueueBatchTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)    09/29/2017                          Original Version
CCPM_processQueue__c
*/

@isTest
public class CCPM_processQueueBatchTest {
    
    public static void createData(){
        //test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        List<CCPM_processingQueue__c> lstSMSSchedules = new List<CCPM_processingQueue__c>();
        List<String> stUniqueID = new List<String>();
        List<lead> lstlead = new List<lead>();
        //Create Account Unique ID's
        /*
        for(Integer i=0; i< CCPM_staticConstants.NoOfRecords; i++){
            stUniqueID.add(CCPM_testDataFactory.generateRandomString(10));
            //stUniqueID.add('Unique'+i);
        }*/
        CCPM_testDataFactory.createCustomer(CCPM_staticConstants.NoOfRecords, 'RSH');
        list<Account> lstAccounts = [Select id, CCPM_accountUniqueID__c from Account where CCPM_accountUniqueID__c != NULL limit :CCPM_staticConstants.NoOfRecords ];
        //Create leads for every account
        for(Integer j=0; j< CCPM_staticConstants.NoOfRecords; j++){
            lead objCart = new lead();
                objCart.LastName=CCPM_testDataFactory.generateRandomString(10);
                objCart.Status='New';
                objCart.CCPM_accountUniqueID__c = lstAccounts[j].CCPM_accountUniqueID__c;
                objCart.CCPM_mobileNumber__c = '3213187287';
                objCart.CCPM_email__c ='test@gmail.com';
                objCart.Company ='Deloitte';
                objCart.RecordTypeId = CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
                lstlead.add(objCart);
        }
        system.debug('@@@lstlead' + lstlead);
        
        try{
            insert lstlead;
        }catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'RemoveSmsScheduleBatchHandlerTest','Test Method','Exception thrown while updating list of sms message schedules',ccpm_staticConstants.boolSMSSent);
        }
        List<lead> lstAlllead = [Select id,Status,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c from lead];
        system.debug('@@@lstAlllead' + lstAlllead);
        List<CCPM_SMSMessage__c> insSMSMessageObj= new List<CCPM_SMSMessage__c>();
        //Create SMS Message Records
        for(Integer i=0; i< lstAlllead.size(); i++){
            /*system.debug('@@@lstAlllead[i].id ' +lstAlllead[i].id);
            system.debug('@@@lstAlllead[i].CCPM_accountUniqueID__c ' +lstAlllead[i].CCPM_accountUniqueID__c);*/
            CCPM_SMSMessage__c insSMSMessageObjRecord= CCPM_testDataFactory.insertSMSRecord(CCPM_staticConstants.NoOfRecords,'Test',CCPM_staticConstants.strMessageTypeInitialSMSPart1,lstAlllead[i].id);
            insSMSMessageObj.add(insSMSMessageObjRecord);
        }
        try{
            system.debug('@@@insSMSMessageObj' + insSMSMessageObj);
            insert insSMSMessageObj;
        }catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'RemoveSmsScheduleBatchHandlerTest','Test Method','Exception thrown while updating list of sms message schedules',ccpm_staticConstants.boolSMSSent);
        }
        List<CCPM_SMSMessage__c> lstSmsMessage = [Select id, name,CCPM_leadRecord__c,CCPM_leadRecord__r.CCPM_accountUniqueID__c from CCPM_SMSMessage__c];
        system.debug('@@@lstSmsMessage' + lstSmsMessage);
        //Create revords in the Queue for sms schedules to be removed
        for(Integer i=0; i< lstAccounts.size(); i++){
            lstSMSSchedules.add(new CCPM_processingQueue__c(
                CCPM_accountUniqueID__c = lstAccounts[i].CCPM_accountUniqueID__c,
                CCPM_storeID__c = CCPM_testDataFactory.generateRandomString(10),
                CCPM_InsertedDateTime__c = system.now(),
                CCPM_Status__c = CCPM_staticConstants.StatusNew,
                CCPM_SObjectType__c = CCPM_staticConstants.SObjectTypeAccount
            ));
        }
        try{
            insert lstSMSSchedules;
        }catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'RemoveSmsScheduleBatchHandlerTest','Test Method','Exception thrown while updating list of sms message schedules',ccpm_staticConstants.boolSMSSent);
        }
        List<CCPM_processingQueue__c> lstSmsMessageToRemove = [Select id, name,CCPM_accountUniqueID__c from CCPM_processingQueue__c];
        system.debug('@@@lstSmsMessageToRemove' + lstSmsMessageToRemove);
        
        system.debug('@@@stUniqueID' + stUniqueID);
        List<lead> lstLeadsForRemovingScedules = [Select id,Status,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c from lead];
        //where CCPM_accountUniqueID__c IN :stUniqueID

       /* For(Integer i=0;i<stUniqueID.size();i++){
            //String test =stUniqueID.get(i);
            String strQuery;
            List<lead> lstLeadsForRemovingScedules = [Select id,Status,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c from lead where CCPM_accountUniqueID__c =:stUniqueID[i]];
            //this.strQuery = 'select id, name, CCPM_accountUniqueID__c, CCPM_storeID__c, CCPM_Status__c, CCPM_InsertedDateTime__c from CCPM_SMSSchedulesToBeRemoved__c where CCPM_Status__c ='+ '\'' + status + '\'' +' limit '+CCPM_staticConstants.strRemoveSmsScheduleBatchLimit;
            system.debug('@@@lstLeadsForRemovingScedulesInTest' + lstLeadsForRemovingScedules);
        } */
        system.debug('@@@lstLeadsForRemovingScedulesInTest2' + lstLeadsForRemovingScedules);
    }
    
    
    public static testMethod void RemoveScheduleTest(){
        
        createData();
        /*
        List<lead> lstLeadsForRemovingScedulestest = [Select id,Status,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c from lead];
        system.debug('@@@lstLeadsForRemovingScedulestest3' + lstLeadsForRemovingScedulestest);
        */
        
        String CRON_EXP = '0 0 * * * ?'; 
        CCPM_processQueueJob scheduledJob = new CCPM_processQueueJob(); 
        system.schedule('CCPM_processQueueJob', CRON_EXP, scheduledJob);
        
        CCPM_processQueueBatch RemoveSms =new CCPM_processQueueBatch();
        database.executebatch(RemoveSms,integer.valueof(CCPM_staticConstants.strBatchChunk));

        //test.stopTest();        
    }
    
}