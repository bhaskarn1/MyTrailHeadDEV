@isTest
public class CCPM_SMSMessageTriggerHandlerTest {
@isTest
     public static void InsertSMSMessageRecordsforPart2BeforeUpdateTest(){
         CCPM_testDataFactory.createCustomSetting();
         CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strContractTerminatingSoon);
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
         system.debug('lstLead' +lstLead);
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeInitialSMSPart1,lstLead[0].id);
        insert SMSObjRecord;
        CCPM_SMSMessageTriggerHandler.InsertSMSMessageRecordsforPart2BeforeUpdate(SMSObjRecord);
    }
    
@isTest
    public static void UpdateSMSMessageRecordsforPart1BeforeUpdateTest(){
        CCPM_testDataFactory.createCustomSetting();
         //CCPM_staticconstants.strMessageStatusSent='sent';
        CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strContractTerminatingSoon);
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(1, 'Hi%HI', CCPM_staticConstants.strMessageTypeInitialSMSPart1, lstLead[0].id);
        insert SMSObjRecord;
        system.debug('SMSObjRecord1' +SMSObjRecord);
        //CCPM_SMSMessage__c newSMSObj = new CCPM_SMSMessage__c();
        //newSMSObj.id=SMSObjRecord[0].id;
        SMSObjRecord[0].CCPM_message__c = 'Test%test';
        //SMSObjRecord[0].CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusSent;
        system.debug('SMSObjRecord' +SMSObjRecord);
        List<CCPM_SMSMessage__c> newSMSObjRecord = new List<CCPM_SMSMessage__c>();
        for(CCPM_SMSMessage__c c: SMSObjRecord){
            c.CCPM_requestID__c = '65791bda-40fb-4d00\\^a35c-7b7cd314ae6b';
            c.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusSent;
            newSMSObjRecord.add(c);
        }
        
       // SMSObjRecord.add(newSMSObj);
        
        
     /*   List<CCPM_SMSMessage__c> lstSMSObjRecord = new List<CCPM_SMSMessage__c>();
        CCPM_SMSMessage__c smsMessageObj = new CCPM_SMSMessage__c();
        if(lstSMSObjRecord.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusQueued){
        lstSMSObjRecord.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusSent;
        } */
        update newSMSObjRecord; 
       
    }
    @isTest
    public static void UpdateSMSMessageRecordsforPart1BeforeUpdateTestPart2(){
         CCPM_testDataFactory.createCustomSetting();
         //CCPM_staticconstants.strMessageStatusSent='sent';
        CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strContractTerminatingSoon);
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(1, 'Hi%HI', CCPM_staticConstants.strMessageTypeCampaignInitialSMSPart1, lstLead[0].id);
        insert SMSObjRecord;
        system.debug('SMSObjRecord1' +SMSObjRecord);
        //CCPM_SMSMessage__c newSMSObj = new CCPM_SMSMessage__c();
        //newSMSObj.id=SMSObjRecord[0].id;
        SMSObjRecord[0].CCPM_message__c = 'Test%test';
        //SMSObjRecord[0].CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusSent;
        system.debug('SMSObjRecord' +SMSObjRecord);
        List<CCPM_SMSMessage__c> newSMSObjRecord = new List<CCPM_SMSMessage__c>();
        for(CCPM_SMSMessage__c c: SMSObjRecord){
            c.CCPM_requestID__c = '65791bda-40fb-4d00\\^a35c-7b7cd314ae6b';
            c.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusSent;
            newSMSObjRecord.add(c);
        }
        
       // SMSObjRecord.add(newSMSObj);
        
        
     /*   List<CCPM_SMSMessage__c> lstSMSObjRecord = new List<CCPM_SMSMessage__c>();
        CCPM_SMSMessage__c smsMessageObj = new CCPM_SMSMessage__c();
        if(lstSMSObjRecord.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusQueued){
        lstSMSObjRecord.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusSent;
        } */
        update newSMSObjRecord;    
    }
        @isTest
    public static void UpdateSMSMessageRecordsforPart1BeforeUpdateTestPart3(){
         CCPM_testDataFactory.createCustomSetting();
         //CCPM_staticconstants.strMessageStatusSent='sent';
        CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strContractTerminatingSoon);
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(1, 'Hi%HI', CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1, lstLead[0].id);
        insert SMSObjRecord;
        system.debug('SMSObjRecord1' +SMSObjRecord);
        //CCPM_SMSMessage__c newSMSObj = new CCPM_SMSMessage__c();
        //newSMSObj.id=SMSObjRecord[0].id;
        SMSObjRecord[0].CCPM_message__c = 'Test%test';
        //SMSObjRecord[0].CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusSent;
        system.debug('SMSObjRecord' +SMSObjRecord);
        List<CCPM_SMSMessage__c> newSMSObjRecord = new List<CCPM_SMSMessage__c>();
        for(CCPM_SMSMessage__c c: SMSObjRecord){
            c.CCPM_requestID__c = '65791bda-40fb-4d00\\^a35c-7b7cd314ae6b';
            c.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusSent;
            newSMSObjRecord.add(c);
        }
        
       // SMSObjRecord.add(newSMSObj);
        
        
     /*   List<CCPM_SMSMessage__c> lstSMSObjRecord = new List<CCPM_SMSMessage__c>();
        CCPM_SMSMessage__c smsMessageObj = new CCPM_SMSMessage__c();
        if(lstSMSObjRecord.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusQueued){
        lstSMSObjRecord.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusSent;
        } */
        update newSMSObjRecord;    
    }

}