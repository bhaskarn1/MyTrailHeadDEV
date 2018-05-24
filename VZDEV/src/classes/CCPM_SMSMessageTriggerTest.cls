/**
*@name          CCPM_SMSMessageTriggerTest
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          07/17/2017
@description    Test class for CCPM_SMSMessageTrigger
@testClass      CCPM_SMSMessageTriggerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                 Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)       07/17/2017          Original Version
*/
@isTest
public class CCPM_SMSMessageTriggerTest {
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    Public static void CreateData()
    {	
        list<string> lstAccountUniqueID=new list<string>();
        list<string> lstLastName=new list<string>();
        list<string> lstcartUniqueId=new list<string>();
        list<string> lststoreID=new list<string>();
        list<string> lstcartLastHandledBy=new list<string>();
        list<id> lstLeadId= new list<id>();
        list<Lead> lstLead=new list<Lead>();
        
        //Create Custom setting
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testDataFactory.createCustomer(1, 'abc');
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lstStore!= null && lstStore.size()>0 && lstStore.isEmpty()==false){
            lststoreID.add(lstStore[0].CCPM_storeID__c);
        }
        list<Account > lstCustomer=[select CCPM_accountUniqueID__c from Account limit 1];
        if(lstCustomer!= null && lstCustomer.size()>0 &&lstCustomer.isEmpty()==false ){
            lstAccountUniqueID.add(lstCustomer[0].CCPM_accountUniqueID__c);
        }
        lstLastName.add('TestLastName');
        lstcartUniqueId.add('TestCartUniqueId');
        lstcartLastHandledBy.add('LHB'); 
        CCPM_testDataFactory.createCartdefaultRecordType(1, lstAccountUniqueID, lstLastName, lstcartUniqueId, lststoreID, lstcartLastHandledBy);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        if(lstLead!= null && lstLead.size()>0 && lstLead.isEmpty()==false)
        {
            lstLeadId.add(lstLead[0].id);
        }
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        
    }
    
    /**
*@author        Brigadesh Chandrasekar(Deloitte)
*@description   This test method is targeted to test the Trigger logic for initial SMS
*@param :       None
*/
    static testMethod void sendInitialSMSPart1(){
        
        CreateData();
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeInitialSMSPart1,lstLead[0].id);
        insert SMSObjRecord;
        system.debug('@@@ SMSObjRecord' +SMSObjRecord);
        SMSObjRecord[0].CCPM_responseCode__c = '204';
        SMSObjRecord[0].CCPM_responseMessage__c = 'No Content';
        SMSObjRecord[0].CCPM_requestID__c = 'abc^def';
        SMSObjRecord[0].CCPM_MessageStatus__c='Sent';
        update SMSObjRecord[0];
        System.assert(SMSObjRecord[0].CCPM_MessageStatus__c == CCPM_staticConstants.strMessageStatusSent);
        
    }
    
    /**
*@author        Brigadesh Chandrasekar(Deloitte)
*@description   This test method is targeted to test the Trigger logic for Prospect 1st SMS
*@param :       None
*/
    static testMethod void sendProspectSMSPart1(){
        
        CreateData();
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi%HI',CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1,lstLead[0].id);
        insert SMSObjRecord;
        system.debug('@@@ SMSObjRecord' +SMSObjRecord);
        SMSObjRecord[0].CCPM_responseCode__c = '204';
        SMSObjRecord[0].CCPM_responseMessage__c = 'No Content';
        SMSObjRecord[0].CCPM_requestID__c = 'abc^def';
        SMSObjRecord[0].CCPM_MessageStatus__c='Sent';
        update SMSObjRecord[0];
        System.assert(SMSObjRecord[0].CCPM_MessageStatus__c == CCPM_staticConstants.strMessageStatusSent);
        
    }
    
    /**
*@author        Brigadesh Chandrasekar(Deloitte)
*@description   This test method is targeted to test the Trigger logic for FollowUp SMS
*@param :       None
*/
    static testMethod void FollowUpSMS(){
        
        CreateData();
        list<Lead> lstLead = [select id, ownerid from lead where ownerid!= NULL limit 1];
        List<CCPM_SMSMessage__c> SMSObjRecord = CCPM_testDataFactory.insertSMSObjectRecord(50,'Hi',CCPM_staticConstants.strMessageTypeFollowUpSMS,lstLead[0].id);
        insert SMSObjRecord;
        system.debug('@@@ SMSObjRecord' +SMSObjRecord);
        SMSObjRecord[0].CCPM_responseCode__c = '204';
        SMSObjRecord[0].CCPM_responseMessage__c = 'No Content';
        SMSObjRecord[0].CCPM_requestID__c = 'abc';
        SMSObjRecord[0].CCPM_MessageStatus__c='Sent';
        update SMSObjRecord[0];
        System.assert(SMSObjRecord[0].CCPM_MessageStatus__c == CCPM_staticConstants.strMessageStatusSent);  
        
    }
    
    
    
}