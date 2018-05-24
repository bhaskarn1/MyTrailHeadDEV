/**
*@name          CCPM_sendSMSBatchCampaignTest
*@author        Soumya Panguluri(Deloitte)
*@date          10/01/2017
@description    To Test the Batch Class CCPM_sendSMSBatchCampaign


@testClass:     CCPM_sendSMSBatchCampaignTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Soumya Panguluri(Deloitte)     10/01/2017                         Original Version
*/
@isTest
public class CCPM_sendSMSBatchCampaignTest {
    
        /**
@author        Soumya Panguluri(Deloitte)
@description   This method is targeted to create Data required for the test class and run the batch processes.
*/     
    static testMethod void sendSMSTestMethod()
    {
                Test.startTest();
        //CCPM_testDataFactory.createCustomer(1, 'abc');
        //CCPM_globalSetting__c gs = CCPM_globalSetting__c.getInstance();
        //CreateData('3213187287', gs.CCPM_leadProspectRecordType__c,null,true,null);
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testDataFactory.createCustomer(1, 'abc');
        CCPM_sendMessageUsingApexTest.CreateData();
        list<Lead> lstLead=new List<Lead>([select id, ownerid from lead limit 1]);
                system.debug('the smsobj'+lstLead);
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        List<CCPM_SMSMessage__c> lstSMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi:HI',CCPM_staticConstants.strMessageStatusError,lstLead[0].id);
        //system.debug('the smsobj'+SMSObjRecord);
        for(CCPM_SMSMessage__c objMessage : lstSMSObjRecord) {
            objMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusQueued;
            objMessage.CCPM_ScheduleDateTime__c = System.now().addHours(-1);
        }
        if(lstSMSObjRecord!=null)
        insert lstSMSObjRecord;
        system.assertEquals('Hi:HI', lstSMSObjRecord[0].CCPM_message__c);
        CCPM_sendSMSBatchCampaign smsBatch = new CCPM_sendSMSBatchCampaign();
        DataBase.executeBatch(smsBatch);
        Datetime dt = Datetime.now().addMinutes(-5);
        String CRON_EXP = ccpm_staticConstants.StrCRONInt; 
        CCPM_sendSMSBatchCampaign sch = new CCPM_sendSMSBatchCampaign();
        system.schedule('CCPM_sendSMSBatch-5 Mins', CRON_EXP, sch);
        DataBase.executeBatch(sch);
        Test.stopTest();
    }  
}