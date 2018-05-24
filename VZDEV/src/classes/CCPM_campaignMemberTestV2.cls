/**
*@name          CCPM_campaignMemberTestV2
*@author        Paras Shah (Deloitte)
*@date          02/19/2018
*@description   The Test Class is meant to unit test the Campaign Member trigger and its handler class
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                   Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)                    02/19/2018              Original Version
*/
@isTest
public class CCPM_campaignMemberTestV2 {

    @testSetup static void createTestData() {
        
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('System Administrator',1);
        insert lstUser;

        String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
        
        list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadCustomerCartRT,false,'Customer Campaign');
        
        lstLead[0].Status = 'Eligible';
        lstLead[0].ownerId = lstUser[0].id;
        insert lstLead[0];
        
        List<CCPM_journeyMessage__c> lstJourneyMessage = ccpm_testDataUtil.createJourneyMessage(1);
        insert lstJourneyMessage;
        
        List<Campaign> lstCampaign          = ccpm_testDataUtil.createCampaign(1);
        lstCampaign[0].CCPM_campaignkey__c  = 'abc';
        lstCampaign[0].CCPM_campaignJourneyMessage__c = lstJourneyMessage[0].id;
        insert lstCampaign;
        
        List<CampaignMember> lstCampaignMember = ccpm_testDataUtil.createCampaignMember(lstCampaign[0].CCPM_campaignkey__c,lstLead[0].id);
        insert lstCampaignMember;
    }   
}