/**
*@name          CCPM_updateLeadTypeTest 
*@author        Paras Shah (Deloitte)
*@date          03/29/2018
*@description   This is a Test class for CCPM_updateLeadType
*@Class         CCPM_updateLeadTypeTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                     	Date         Description
------------------------------------------------------------------------------------
Paras Shah (Deloitte)    		03/29/2018   Initial Implementation.
*/

@isTest
public class CCPM_updateLeadTypeTest {
    static testMethod void myUnitTest() {
        
        List<Lead> lstLead = CCPM_testDataUtil.createLead(1,'01241000000jxif',false,'Customer Abandoned Visit');
        //lstLead.add(CCPM_testDataUtil.createLead(123,'0121b0000000CQF',false,'Customer Abandoned Cart'));
        //lstLead[0].status = 'Qualified';
        //lstLead[0].CCPM_qualifiedSubStatusForPreDefinedSMS__c = 'Disinterested';
            
        insert lstLead;
        
        CCPM_updateLeadType objLeadType = new CCPM_updateLeadType('OpenLeads');
        //objLeadType.start();
        
        //CCPM_processQueueBatch RemoveSms =new CCPM_processQueueBatch();
        database.executebatch(objLeadType,200);
    }
    
    static testMethod void testClosedLeads() {
        
        List<Lead> lstLead = CCPM_testDataUtil.createLead(1,'01241000000jxif',false,'Customer Abandoned Visit');
        //lstLead.add(CCPM_testDataUtil.createLead(123,'0121b0000000CQF',false,'Customer Abandoned Cart'));
        lstLead[0].status = 'Converted';
        //lstLead[0].CCPM_qualifiedSubStatusForPreDefinedSMS__c = 'Disinterested';
            
        insert lstLead;
        
        CCPM_updateLeadType objLeadType = new CCPM_updateLeadType('ClosedLeads');
        //objLeadType.start();
        
        //CCPM_processQueueBatch RemoveSms =new CCPM_processQueueBatch();
        database.executebatch(objLeadType,200);
    }
    
}