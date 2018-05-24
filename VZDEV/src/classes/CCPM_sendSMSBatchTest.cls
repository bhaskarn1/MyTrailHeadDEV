/**
*@name          CCPM_sendSMSBatchTest
*@author        Aneesha Ragireddy (Deloitte)
*@date          05/19/2017
@description    To Test the Batch Class sendSMSBatch


@testClass:     CCPM_sendSMSBatchTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Aneesha(Deloitte)      05/19/2017                         Original Version
*/
@isTest
public class CCPM_sendSMSBatchTest {
    
    static testMethod void sendSMSTestMethod()
    {
                Test.startTest();
        //CCPM_testDataFactory.createCustomer(1, 'abc');
        //CCPM_globalSetting__c gs = CCPM_globalSetting__c.getInstance();
        //CreateData('3213187287', gs.CCPM_leadProspectRecordType__c,null,true,null);
        //CCPM_testDataFactory.createCustomSetting();
        //CCPM_testDataFactory.createCustomer(1, 'abc');
        CCPM_sendMessageUsingApexTest.CreateData();
        list<Lead> lstLead=new List<Lead>([select id, ownerid from lead limit 1]);
                system.debug('the smsobj'+lstLead);
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        List<CCPM_SMSMessage__c> lstSMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi:HI',CCPM_staticConstants.strMessageStatusError,lstLead[0].id);
        //system.debug('the smsobj'+SMSObjRecord);
        if(lstSMSObjRecord!=null)
        insert lstSMSObjRecord;
        system.assertEquals('Hi:HI', lstSMSObjRecord[0].CCPM_message__c);
        CCPM_sendSMSBatch smsBatch = new CCPM_sendSMSBatch();
        DataBase.executeBatch(smsBatch);
        Datetime dt = Datetime.now().addMinutes(-5);
        String CRON_EXP = ccpm_staticConstants.StrCRONInt; 
        CCPM_sendSMSBatch sch = new CCPM_sendSMSBatch();
        system.schedule('CCPM_sendSMSBatch-5 Mins', CRON_EXP, sch);
        DataBase.executeBatch(sch);
        Test.stopTest();
    }  
}