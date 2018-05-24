/**
*@name          CCPM_smsTemplateTriggerHandlerTest
*@author        Danielle Morse (Deloitte)
*@date          04/19/2018
*@description   The Test Class is meant to unit test the smsTemplate trigger and its handler class
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                   Description
------------------------------------------------------------------------------------
Danielle Morse (Deloitte)                    04/19/2018              Original Version
*/
@isTest
public class CCPM_smsTemplateTriggerHandlerTest {
    
    public static FINAL String strRecTypeId = Schema.SObjectType.CCPM_smsTemplate__c.getRecordTypeInfosByName().get('Event Message Template').getRecordTypeId();
    public static FINAL Date TODAY = date.today();
    
    @testSetup static void testDataSetup(){
        List<Campaign> lstCampaign = CCPM_testDataUtil.createCampaign(1);
        lstCampaign[0].Name = 'Test SMS Campaign';
        insert lstCampaign;
        
        List<CCPM_Segmentation__c> lstSegmentation= CCPM_testDataUtil.createSegmentation(1);
        lstSegmentation[0].CCPM_districts1__c = 'CC01';
        lstSegmentation[0].CCPM_channels__c = 'Retail';
        lstSegmentation[0].CCPM_markets__c = 'Pacific';
        lstSegmentation[0].CCPM_territories__c = 'Mountain';        
        insert lstSegmentation;
    }
    
    
    @isTest
    public static void insertCorrDateFormats(){
        String strEvtMsgStartDateIncorrect = '12/1/' + TODAY.year();
        String strEvtMsgEndDateIncorrect = '12/31/' + (TODAY.year() + 1);
        String strEvtMsgStartDateCorrect = TODAY.year() + '-12-01 12:00:00';
        String strEvtMsgEndDateCorrect = (TODAY.year() + 1) + '-12-31 12:00:00';
        Boolean boolErrMsgDisplayed = false;
        
        String strCampaignId = [SELECT Id FROM Campaign LIMIT 1].Id;
        String strSegmentationId = [SELECT Id FROM CCPM_Segmentation__c LIMIT 1].Id;
        
        List<CCPM_smsTemplate__c> lstSMSTemp = CCPM_testDataUtil.createSMSTemplate(1);
        lstSMSTemp[0].recordTypeId = strRecTypeId;
        lstSMSTemp[0].CCPM_isActive__c = true;
        lstSMSTemp[0].CCPM_campaign__c	= strCampaignId;
        lstSMSTemp[0].CCPM_segmentation__c	= strSegmentationId;
        lstSMSTemp[0].CCPM_eventMessageStartDate__c	= strEvtMsgStartDateIncorrect;
        lstSMSTemp[0].CCPM_eventMessageEndDate__c	= strEvtMsgEndDateIncorrect;
        
        // Test that the template is not inserted if the Event Message Start & End Dates are not in the correct format
        try{
            insert lstSMSTemp;
        }
        catch (Exception e){
            boolErrMsgDisplayed = e.getMessage().contains('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
            System.assert(boolErrMsgDisplayed, 'Expected error message did not display when Event Message Start & End Dates were entered incorrectly on SMSTemplate creation');
        }
        
        // Test that the smsTemplate is inserted if the Event Message Start & End Dates are entered in the correct format
        boolErrMsgDisplayed = false;
        
        lstSMSTemp[0].CCPM_eventMessageStartDate__c = strEvtMsgStartDateCorrect;
        lstSMSTemp[0].CCPM_eventMessageEndDate__c = strEvtMsgEndDateCorrect;
        
        insert lstSMSTemp;
        
    }
    
    @isTest
    public static void updateCorrDateFormats(){
        String strEvtMsgStartDateIncorrect = '12/1/' + TODAY.year();
        String strEvtMsgEndDateIncorrect = '12/31/' + (TODAY.year() + 1);
        String strEvtMsgStartDateCorrect = TODAY.year() + '-12-01 12:00:00';
        String strEvtMsgEndDateCorrect = (TODAY.year() + 1) + '-12-31 12:00:00';
        Boolean boolErrMsgDisplayed = false;
        
        String strCampaignId = [SELECT Id FROM Campaign LIMIT 1].Id;
        String strSegmentationId = [SELECT Id FROM CCPM_Segmentation__c LIMIT 1].Id;
        
        List<CCPM_smsTemplate__c> lstSMSTemp = CCPM_testDataUtil.createSMSTemplate(1);
        
        lstSMSTemp[0].recordTypeId = strRecTypeId;
        lstSMSTemp[0].CCPM_isActive__c = true;
        lstSMSTemp[0].CCPM_campaign__c	= strCampaignId;
        lstSMSTemp[0].CCPM_segmentation__c	= strSegmentationId;
        lstSMSTemp[0].CCPM_eventMessageStartDate__c	= strEvtMsgStartDateCorrect;
        lstSMSTemp[0].CCPM_eventMessageEndDate__c	= strEvtMsgEndDateCorrect;
        
        // List with correct dates should insert correctly
        insert lstSMSTemp;
        
        // With incorrect dates should throw an error
        CCPM_smsTemplate__c objSMSTemp = [SELECT Id FROM CCPM_smsTemplate__c LIMIT 1];
        objSMSTemp.CCPM_eventMessageStartDate__c = strEvtMsgStartDateIncorrect;
        objSMSTemp.CCPM_eventMessageEndDate__c = strEvtMsgEndDateIncorrect;
        
        try{
            update objSMSTemp;
        }
        catch (Exception e){
            boolErrMsgDisplayed = e.getMessage().contains('Invalid Date: Please enter in the format YYYY-MM-DD HH:MM:SS');
            System.assert(boolErrMsgDisplayed,'Unexpected error message displayed when Event Message Start & End Dates were entered correctly on SMSTemplate creation');
        }          
    }
    
    @isTest
    public static void insertStartDateAfterEndDate(){
        String strCampaignId = [SELECT Id FROM Campaign LIMIT 1].Id;
        String strSegmentationId = [SELECT Id FROM CCPM_Segmentation__c LIMIT 1].Id;
        String strEvtMsgStartDate = TODAY.year() + '-12-01 12:00:00';
        String strEvtMsgEndDate = TODAY.year() + '-10-31 12:00:00';
        Boolean boolErrMsgDisplayed = false;        
        
        List<CCPM_smsTemplate__c> lstSMSTemp = CCPM_testDataUtil.createSMSTemplate(1);
        lstSMSTemp[0].recordTypeId = strRecTypeId;
        lstSMSTemp[0].CCPM_isActive__c = true;
        lstSMSTemp[0].CCPM_campaign__c	= strCampaignId;
        lstSMSTemp[0].CCPM_segmentation__c	= strSegmentationId;
        lstSMSTemp[0].CCPM_eventMessageStartDate__c	= strEvtMsgStartDate;
        lstSMSTemp[0].CCPM_eventMessageEndDate__c	= strEvtMsgEndDate;
        
        try{
            insert lstSMSTemp; 
        }
        
        catch(Exception e){
            boolErrMsgDisplayed = e.getMessage().contains('SMS Start Date cannot be greater than SMS End Date.');
            System.assert(boolErrMsgDisplayed, 'Expected error message did not display when Event Message Start Date was after the Event Message End Date');
        }
    }
    
    
    @isTest
    public static void insertCorrDateRange(){
        
        String strEvtMsgStartDateR1 = TODAY.year() + '-12-01 12:00:00';
        String strEvtMsgEndDateR1 = TODAY.year() + '-12-31 12:00:00';
        String strEvtMsgStartDateR1Overlap = TODAY.year() + '-12-09 12:00:00';
        String strEvtMsgEndDateR1Overlap = TODAY.year() + '-12-21 12:00:00';        
        String strEvtMsgStartDateR2 = (TODAY.year() + 1) + '-11-01 12:00:00';
        String strEvtMsgEndDateR2 = (TODAY.year() + 1) + '-11-20 12:00:00';
        Boolean boolErrMsgDisplayed = false;
        
        String strCampaignId = [SELECT Id FROM Campaign LIMIT 1].Id;
        String strSegmentationId = [SELECT Id FROM CCPM_Segmentation__c LIMIT 1].Id;
        
        // Template with correct date format should be inserted no problem                                                    
        List<CCPM_smsTemplate__c> lstSMSTemp1 = CCPM_testDataUtil.createSMSTemplate(1);
        lstSMSTemp1[0].recordTypeId = strRecTypeId;
        lstSMSTemp1[0].CCPM_isActive__c = true;
        lstSMSTemp1[0].CCPM_campaign__c	= strCampaignId;
        lstSMSTemp1[0].CCPM_segmentation__c	= strSegmentationId;
        lstSMSTemp1[0].CCPM_eventMessageStartDate__c	= strEvtMsgStartDateR1;
        lstSMSTemp1[0].CCPM_eventMessageEndDate__c	= strEvtMsgEndDateR1;
        insert lstSMSTemp1;
        
        
        // New template with overlapping Start date should throw an error on insertion
        List<CCPM_smsTemplate__c> lstSMSTemp2 = CCPM_testDataUtil.createSMSTemplate(1);
        lstSMSTemp2[0].recordTypeId = strRecTypeId;
        lstSMSTemp2[0].CCPM_isActive__c = true;
        lstSMSTemp2[0].CCPM_campaign__c	= strCampaignId;
        lstSMSTemp2[0].CCPM_segmentation__c	= strSegmentationId;
        lstSMSTemp2[0].CCPM_eventMessageStartDate__c	= strEvtMsgStartDateR1Overlap;
        lstSMSTemp2[0].CCPM_eventMessageEndDate__c	= strEvtMsgEndDateR1Overlap;
        try{
            insert lstSMSTemp2;
        }
        catch (Exception e){
            System.debug('error message: ' + e.getMessage());
            boolErrMsgDisplayed = e.getMessage().contains('Dates overlapping with');
            System.assert(boolErrMsgDisplayed, 'Expected error message did not display when Event Message Start Date overlapped with an existing one on SMS template creation');
        } 
    }
    
    @isTest
    public static void updateCorrDateRange(){
        
        String strEvtMsgStartDateR1 = TODAY.year() + '-12-01 12:00:00';
        String strEvtMsgEndDateR1 = TODAY.year() + '-12-31 12:00:00';
        String strEvtMsgStartDateR1Overlap = TODAY.year() + '-12-09 12:00:00';
        String strEvtMsgEndDateR1Overlap = TODAY.year() + '-12-21 12:00:00';        
        String strEvtMsgStartDateR2 = TODAY.year() + '-11-01 12:00:00';
        String strEvtMsgEndDateR2 = TODAY.year() + '-11-20 12:00:00';
        
        Boolean boolErrMsgDisplayed = false;
        
        String strCampaignId = [SELECT Id FROM Campaign LIMIT 1].Id;
        String strSegmentationId = [SELECT Id FROM CCPM_Segmentation__c LIMIT 1].Id;
        
        // New templates with non-overlapping Start dates should not throw an error on insertion
        List<CCPM_smsTemplate__c> lstSMSTemp1 = CCPM_testDataUtil.createSMSTemplate(2);
        lstSMSTemp1[0].recordTypeId = strRecTypeId;
        lstSMSTemp1[0].CCPM_isActive__c = true;
        lstSMSTemp1[0].CCPM_campaign__c	= strCampaignId;
        lstSMSTemp1[0].CCPM_segmentation__c	= strSegmentationId;
        lstSMSTemp1[0].CCPM_eventMessageStartDate__c	= strEvtMsgStartDateR1;
        lstSMSTemp1[0].CCPM_eventMessageEndDate__c	= strEvtMsgEndDateR1;
        
        lstSMSTemp1[1].recordTypeId = strRecTypeId;
        lstSMSTemp1[1].CCPM_isActive__c = true;
        lstSMSTemp1[1].CCPM_campaign__c	= strCampaignId;
        lstSMSTemp1[1].CCPM_segmentation__c	= strSegmentationId;
        lstSMSTemp1[1].CCPM_eventMessageStartDate__c	= strEvtMsgStartDateR2;
        lstSMSTemp1[1].CCPM_eventMessageEndDate__c	= strEvtMsgEndDateR2;
        
        insert lstSMSTemp1;
        CCPM_smsTemplateTriggerHandler objTest = new CCPM_smsTemplateTriggerHandler();
        objTest.AfterDelete(null);
        objTest.AfterDelete(null);
        objTest.AfterUpdate(null,null);
        
        // Updating an existing template to an overlapping date range should throw an error on update
        
        CCPM_smsTemplate__c objSMSTemp = [SELECT Id FROM CCPM_smsTemplate__c WHERE CCPM_eventMessageStartDate__c =: strEvtMsgStartDateR2
                                          AND CCPM_eventMessageEndDate__c =: strEvtMsgEndDateR2 LIMIT 1];
        objSMSTemp.CCPM_eventMessageStartDate__c = strEvtMsgStartDateR1Overlap;
        objSMSTemp.CCPM_eventMessageEndDate__c = strEvtMsgEndDateR1Overlap;
        
        try{
            update objSMSTemp;
        }
        catch (Exception e){
            System.debug('error message: ' + e.getMessage());
            boolErrMsgDisplayed = e.getMessage().contains('Dates overlapping with');
            System.assert(boolErrMsgDisplayed, 'Expected error message did not display when Event Message Start Date overlapped with an existing one on SMS template creation');
        }
    }
}