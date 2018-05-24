/**
*@name          CCPM_campaignTriggerHandlerTest 
*@author        Chrissen Joseph (Deloitte)
*@date          Apr 19, 2018
*@description   This is a Test class for
*@Class         CCPM_campaignTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Chrissen Joseph (Deloitte)       04/19/2018   Initial Implementation.
*/

@isTest
private class CCPM_campaignTriggerHandlerTest {
    //This method is to cover the Before Insert and Before Update Scenarios
    static testMethod void myUnitTest1() { 
        Test.startTest();
        try{
            Campaign ca = new Campaign(Name='TestCampaign',
                                       CCPM_leadCustomerType__c = 'Customer',
                                       CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                       CCPM_eventEndDate__c = '2018-09-09 04:04:04',
                                       CCPM_eventSMSFollowUpStartDate__c = '2018-09-09 02:02:02',
                                       CCPM_eventSMSFollowUpEndDate__c = '2018-09-09 04:04:04',
                                       CCPM_eventLabel__c = 'testlabel',
                                       IsActive = true,
                                       recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event Type').getRecordTypeId());
            insert ca;
            ca.CCPM_eventStartDate__c = '2018-09-09';
            ca.CCPM_eventEndDate__c = '2018-09-09';
            ca.CCPM_eventSMSFollowUpStartDate__c = '2018-09-09';
            ca.CCPM_eventSMSFollowUpEndDate__c = '2018-09-09';
            update ca;
        }
        catch(Exception e){           
        }
        Test.stopTest();
    }
    //This method is to cover the negative scenarios in Before Insert 
    static testMethod void myUnitTest12() { 
        Test.startTest();
        try{
            Campaign ca = new Campaign(Name='TestCampaign',
                                       CCPM_leadCustomerType__c = 'Customer',
                                       CCPM_eventStartDate__c = '2018-09-09',
                                       CCPM_eventEndDate__c = '2018-09-09',
                                       CCPM_eventSMSFollowUpStartDate__c = '2018-09-09',
                                       CCPM_eventSMSFollowUpEndDate__c = '2018-09-09',
                                       CCPM_eventLabel__c = 'testlabel',
                                       IsActive = true,
                                       recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event Type').getRecordTypeId());
            insert ca;
        }
        catch(Exception e){           
        }
        Test.stopTest();
    }
    //This method is to cover the negative scenarios in Before Insert 
    static testMethod void myUnitTest13() { 
        Test.startTest();
        try{
            Campaign ca = new Campaign(Name='TestCampaign',
                                       CCPM_leadCustomerType__c = 'Customer',
                                       CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                       CCPM_eventEndDate__c = '2018-09-09 01:01:01',
                                       CCPM_eventSMSFollowUpStartDate__c = '2018-09-09 02:02:02',
                                       CCPM_eventSMSFollowUpEndDate__c = '2018-09-09 02:02:02',
                                       CCPM_eventLabel__c = 'testlabel',
                                       IsActive = true,
                                       recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event Type').getRecordTypeId());
            insert ca;
        }
        catch(Exception e){           
        }
        Test.stopTest();
    }
    //This method is to cover the BeforeDelete class method
    static testMethod void myUnitTest2() {   
        Test.startTest();
        Campaign ca = new Campaign(Name='TestCampaign',
                                   CCPM_leadCustomerType__c = 'Customer',
                                   CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                   CCPM_eventLabel__c = 'testlabel',
                                   IsActive = true);
        insert ca;
        Map<id, Campaign> campMap = new Map<id, Campaign> ([select id from Campaign where id =:ca.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)campMap;
        CCPM_campaignTriggerHandler campHandler = new CCPM_campaignTriggerHandler();
        campHandler.BeforeDelete(mapOld);
        Test.stopTest();
    }
    //This method is to cover the AfterUpdate class method
    static testMethod void myUnitTest3() {   
        Test.startTest();
        Campaign ca = new Campaign(Name='TestCampaign',
                                   CCPM_leadCustomerType__c = 'Customer',
                                   CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                   CCPM_eventLabel__c = 'testlabel',
                                   IsActive = true);
        insert ca;
        Map<id, Campaign> campMap = new Map<id, Campaign> ([select id from Campaign where id =:ca.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)campMap;
        CCPM_campaignTriggerHandler campHandler = new CCPM_campaignTriggerHandler();
        campHandler.AfterUpdate(mapOld,mapOld);
        Test.stopTest();
    }
    //This method is to cover the AfterDelete class method
    static testMethod void myUnitTest4() {   
        Test.startTest();
        Campaign ca = new Campaign(Name='TestCampaign',
                                   CCPM_leadCustomerType__c = 'Customer',
                                   CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                   CCPM_eventLabel__c = 'testlabel',
                                   IsActive = true);
        insert ca;
        Map<id, Campaign> campMap = new Map<id, Campaign> ([select id from Campaign where id =:ca.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)campMap;
        CCPM_campaignTriggerHandler campHandler = new CCPM_campaignTriggerHandler();
        campHandler.AfterDelete(mapOld);
        Test.stopTest();
    }
    //This method is to cover the AfterUndelete class method
    static testMethod void myUnitTest5() {   
        Test.startTest();
        Campaign ca = new Campaign(Name='TestCampaign',
                                   CCPM_leadCustomerType__c = 'Customer',
                                   CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                   CCPM_eventLabel__c = 'testlabel',
                                   IsActive = true);
        insert ca;
        Map<id, Campaign> campMap = new Map<id, Campaign> ([select id from Campaign where id =:ca.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)campMap;
        CCPM_campaignTriggerHandler campHandler = new CCPM_campaignTriggerHandler();
        campHandler.AfterUndelete(mapOld);
        Test.stopTest();
    }
    
}