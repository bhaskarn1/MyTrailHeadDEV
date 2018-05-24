/**
*@name          CCPM_REMergeHandlerTest 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          03/21/2018
*@description   This is a Test class for CCPM_REMergeHandler
*@Class         CCPM_REMergeHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    03/21/2018   Initial Implementation.
*/

@isTest
private class CCPM_REMergeHandlerTest {
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
	*/ 
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        CCPM_REMergeHandler objREMergeHandler = new CCPM_REMergeHandler();
        
        //Set String of MTN
        //
        Set<String> setNewMTN 		=  new Set<String>();
        Set<String> setLeadStatus 	=  new Set<String>();
        
        List<Lead> lstLead = CCPM_testDataUtil.createLead(1,'01241000000jxif',false,'Customer Abandoned Visit');
        //lstLead.add(CCPM_testDataUtil.createLead(123,'0121b0000000CQF',false,'Customer Abandoned Cart'));
        //lstLead[0].status = 'Qualified';
        //lstLead[0].CCPM_leadSubStatus__c = 'In Discussion';
            
        insert lstLead;
        CCPM_REMergeHandler.REReturnExisitngRecordBYSOSL(setNewMTN,setLeadStatus);
        //CCPM_REMergeHandler.REReturnExisitngRecordBYSOQL(setNewMTN,setLeadStatus);
        
        CCPM_REMergeHandler.REReturnLeadsSortedByMTN(lstLead);
        
        CCPM_REMergeHandler.REMergeRecords(lstLead,'SOSL');
        
        Lead objLead = new Lead();
        CCPM_REMergeHandler.parseStringWithTag('<w>Status</w>',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag('<l>Status<l>',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag('<s>Status</s>',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag('<v>Test</v>',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag('<conStr>Hello, World</conStr>',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag(' ',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag(' * v',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag(' / v',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag(' % v',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag(' - v',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag(' | v',objLead,objLead, objLead);
        CCPM_REMergeHandler.parseStringWithTag(' * v * m * m',objLead,objLead, objLead);
        
        CCPM_REMergeHandler.checkforTagsandOperators('%');
        CCPM_REMergeHandler.evaluavateDate(' - 2');
        
        List<CCPM_RERecord__c> lstCreateRERecord = new List<CCPM_RERecord__c>();
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('Existing Record'));
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('New Record'));
        
        insert lstCreateRERecord;
        
        List<CCPM_Rule__c> lstRules = new List<CCPM_Rule__c>();
        lstRules.add(CCPM_REMergeTestDataFactory.createRules(lstCreateRERecord[0].id,lstCreateRERecord[1].id,'strUnique','New Record','Rule123'));
        insert lstRules;
		
        List<CCPM_Criteria__c> lstCriteriaDouble = new List<CCPM_Criteria__c>();
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Equals',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Not Equal To',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Contains',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Does Not Contain',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Starts With',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Ends with',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Greater Than',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Greater Or Equal',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Less Than',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDouble.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Less Or Equal',lstCreateRERecord[0].id,lstRules[0].id));
        
        insert lstCriteriaDouble;
        
        //CCPM_Criteria__c objCriteria = new CCPM_Criteria__c();
        //objCriteria = CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Equals',lstCreateRERecord[0].id,lstRules[0].id);
        //insert objCriteria;
        
        for( CCPM_Criteria__c objCriteria: lstCriteriaDouble) {
            CCPM_REMergeHandler.evaluateCriteria(objLead,objCriteria);
        }
    }
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
	*/ 
    static testMethod void testEvaluateCriteriaText() {
        
        Lead objLead = new Lead();
        
        List<CCPM_RERecord__c> lstCreateRERecord = new List<CCPM_RERecord__c>();
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('Existing Record'));
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('New Record'));
        
        insert lstCreateRERecord;
        
        List<CCPM_Rule__c> lstRules = new List<CCPM_Rule__c>();
        lstRules.add(CCPM_REMergeTestDataFactory.createRules(lstCreateRERecord[0].id,lstCreateRERecord[1].id,'strUnique','New Record','Rule123'));
        insert lstRules;
		
        List<CCPM_Criteria__c> lstCriteriaText = new List<CCPM_Criteria__c>();
        lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Equals',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Not Equal To',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Contains',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Does Not Contain',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Starts With',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Ends with',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Greater Than',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Greater Or Equal',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Less Than',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaText.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Text','Less Or Equal',lstCreateRERecord[0].id,lstRules[0].id));
        
        insert lstCriteriaText;
        
        //CCPM_Criteria__c objCriteria = new CCPM_Criteria__c();
        //objCriteria = CCPM_REMergeTestDataFactory.createRuleCriteria('Double','Equals',lstCreateRERecord[0].id,lstRules[0].id);
        //insert objCriteria;
        
        for( CCPM_Criteria__c objCriteria: lstCriteriaText) {
            CCPM_REMergeHandler.evaluateCriteria(objLead,objCriteria);
        }
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
	*/ 
    static testMethod void testEvaluateCriteriaDate() {
        
        Lead objLead = new Lead();
        
        List<CCPM_RERecord__c> lstCreateRERecord = new List<CCPM_RERecord__c>();
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('Existing Record'));
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('New Record'));
        
        insert lstCreateRERecord;
        
        List<CCPM_Rule__c> lstRules = new List<CCPM_Rule__c>();
        lstRules.add(CCPM_REMergeTestDataFactory.createRules(lstCreateRERecord[0].id,lstCreateRERecord[1].id,'strUnique','New Record','Rule123'));
        insert lstRules;
		
        List<CCPM_Criteria__c> lstCriteriaDate = new List<CCPM_Criteria__c>();
        lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Equals',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Not Equal To',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Contains',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Does Not Contain',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Starts With',lstCreateRERecord[0].id,lstRules[0].id));
        //lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Ends with',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Greater Than',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Greater Or Equal',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Less Than',lstCreateRERecord[0].id,lstRules[0].id));
        lstCriteriaDate.add(CCPM_REMergeTestDataFactory.createRuleCriteria('Date','Less Or Equal',lstCreateRERecord[0].id,lstRules[0].id));
        
        insert lstCriteriaDate;
        
        for( CCPM_Criteria__c objCriteria: lstCriteriaDate) {
            CCPM_REMergeHandler.evaluateCriteria(objLead,objCriteria);
        }
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
	*/ 
    static testMethod void testREMergeMethod() {
        List<Lead> lstLead = CCPM_testDataUtil.createLeadWithMTN(2,'01241000000jxif',false,'Customer Abandoned Visit','19999999999');
        lstLead[0].status = 'New';
        lstLead[1].status = 'New';
        insert lstLead;
        
        List<Lead> lstLeadTwo = CCPM_testDataUtil.createLeadWithMTN(2,'01241000000jxif',false,'Customer Abandoned Visit','19999999999');
        lstLeadTwo[0].status = 'New';
        lstLeadTwo[0].ccpm_isManualLead__c = true;
        lstLeadTwo[0].CCPM_mfToBeMerged__c = false;
        insert lstLeadTwo;
        
        System.debug('*******lstLead********'+lstLead);
        CCPM_REMergeHandler.REMergeRecords(lstLeadTwo,'SOSL');
        
    }
    
}