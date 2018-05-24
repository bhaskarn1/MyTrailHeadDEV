/**
*@name          CCPM_SMSMessageBatchHandlerTest
*@author        Aneesha Ragireddy (Deloitte)
*@date          05/22/2017
@description    Test class for CCPM_SMSMessageBatchHandler
@testClass      CCPM_SMSMessageBatchHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                        Description
------------------------------------------------------------------------------------
Aneesha Ragireddy(Deloitte)       05/22/2017          Original Version
*/
@isTest
public class CCPM_SMSMessageBatchHandlerTest {
    static testMethod void sendInitialSMSPart1(){
        
        CCPM_sendMessageUsingApexTest.CreateData();
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeInitialSMSPart1,lstLead[0].id);
        insert SMSObjRecord;
        system.debug('@@@ SMSObjRecord' +SMSObjRecord);
        Test.startTest();
        
        CCPM_SMSMessageBatchHandler smsBatchHandler = new CCPM_SMSMessageBatchHandler();
        CCPM_SMSMessageBatchHandler.sendSMSViaHeyWire(SMSObjRecord);
        
        Test.stopTest();
    }
    
    static testMethod void sendProspectSMSPart1(){
        CCPM_sendMessageUsingApexTest.CreateData();
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= null limit 1];
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1,lstLead[0].id);
        insert SMSObjRecord;
        system.debug('@@@ SMSObjRecord' +SMSObjRecord);
        Test.startTest();
        
        CCPM_SMSMessageBatchHandler smsBatchHandler = new CCPM_SMSMessageBatchHandler();
        CCPM_SMSMessageBatchHandler.sendSMSViaHeyWire(SMSObjRecord);
        
        Test.stopTest();
    }
    
    static testMethod void CreateInteractionTouchPoint(){
        CCPM_sendMessageUsingApexTest.CreateData();
        
        
        list<Lead> lstLead=new List<Lead>([select id, ownerid from lead limit 1]);
        System.debug('lstLead Created->'+lstLead);
        map<id,Lead> mpLead = new map<id,Lead>();
        for (Lead l : lstLead)
        {
            mpLead.put(l.Id,l);
        }
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1,lstLead[0].id);
        insert SMSObjRecord;
        Test.startTest();
        
        CCPM_SMSMessageBatchHandler smsBatchHandler = new CCPM_SMSMessageBatchHandler();
        CCPM_SMSMessageBatchHandler.createInteractionTouchPoint(SMSObjRecord,mpLead);
        
        Test.stopTest();
    }
    
    static testMethod void updateLeadFields(){
        CCPM_sendMessageUsingApexTest.CreateData();
        
        
        list<Lead> lstLead=new List<Lead>([select id, ownerid from lead limit 1]);
        map<id,CCPM_SMSMessage__c> mpLead = new map<id,CCPM_SMSMessage__c>();
        
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeInitialSMSPart2,lstLead[0].id);
        insert SMSObjRecord;
        
        
        
        mpLead.put(lstLead[0].id,SMSObjRecord[0]);
        
        
        Test.startTest();
        
        CCPM_SMSMessageBatchHandler smsBatchHandler = new CCPM_SMSMessageBatchHandler();
        CCPM_SMSMessageBatchHandler.updateLeadFields(mpLead, lstLead);
        
        Test.stopTest();
    }
    
    static testMethod void updateLeadFieldsProspectPart2(){
        CCPM_sendMessageUsingApexTest.CreateData();
        
        
        list<Lead> lstLead=new List<Lead>([select id, ownerid from lead limit 1]);
        map<id,CCPM_SMSMessage__c> mpLead = new map<id,CCPM_SMSMessage__c>();
        
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        
        
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi hi%HI hi',CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2,lstLead[0].id);
        insert SMSObjRecord;
        
        
        
        mpLead.put(lstLead[0].id,SMSObjRecord[0]);
        
        
        Test.startTest();
        
        CCPM_SMSMessageBatchHandler smsBatchHandler = new CCPM_SMSMessageBatchHandler();
        CCPM_SMSMessageBatchHandler.updateLeadFields(mpLead, lstLead);
        
        Test.stopTest();
    }
    
    static testMethod void updateLeadFieldsFollowUp(){
        CCPM_sendMessageUsingApexTest.CreateData();
        
        
        list<Lead> lstLead=new List<Lead>([select id, ownerid from lead limit 1]);
        map<id,CCPM_SMSMessage__c> mpLead = new map<id,CCPM_SMSMessage__c>();
        
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        
        
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeFollowUpSMS,lstLead[0].id);
        insert SMSObjRecord;
        
        
        
        mpLead.put(lstLead[0].id,SMSObjRecord[0]);
        
        
        Test.startTest();
        
        CCPM_SMSMessageBatchHandler smsBatchHandler = new CCPM_SMSMessageBatchHandler();
        CCPM_SMSMessageBatchHandler.updateLeadFields(mpLead, lstLead);
        
        Test.stopTest();
    }
    
    
}