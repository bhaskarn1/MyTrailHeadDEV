/**
*@name          CCPM_REActionControllerTest 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          03/21/2018
*@description   This is a Test class for
*@Class         CCPM_REActionControllerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    03/21/2018   Initial Implementation.
*/

@isTest
private class CCPM_REActionControllerTest {
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
@return       Void(None)
*/ 
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        // 
        ApexPages.CurrentPage().getparameters().put('clone','1');
        ApexPages.CurrentPage().getparameters().put('recordid','sample');
        
        CCPM_REActionController objREActionController = new CCPM_REActionController();
        //objREActionController.getACFieldTypes();
        //objREActionController.getFieldTypes();
        objREActionController.removeVCRow();
        objREActionController.save();
        objREActionController.edit();
        objREActionController.cancel();
        objREActionController.clonevaluePackage();
        
        CCPM_Action__c objAction = new CCPM_Action__c();
        List<CCPM_ActionComponent__c> lstActComp = new List<CCPM_ActionComponent__c>();
        List<CCPM_RuleAction__c> lstRuleAct = new List<CCPM_RuleAction__c>();
        
        CCPM_REActionController.ActionPackage objActionPackage = new CCPM_REActionController.ActionPackage(objAction,lstActComp,lstRuleAct);
        objActionPackage.addRARow();
    }
    
    static testMethod void testRuleActions() {
        
        
        
        List<CCPM_RERecord__c> lstCreateRERecord = new List<CCPM_RERecord__c>();
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('Existing Record'));
        lstCreateRERecord.add(CCPM_REMergeTestDataFactory.createRecords('New Record'));
        
        insert lstCreateRERecord;
        
        List<CCPM_Rule__c> lstRules = new List<CCPM_Rule__c>();
        lstRules.add(CCPM_REMergeTestDataFactory.createRules(lstCreateRERecord[0].id,lstCreateRERecord[1].id,'strUnique','New Record','Rule123'));
        insert lstRules;
        
        List<CCPM_Action__c> lstAction = new List<CCPM_Action__c>();
        lstAction.add(CCPM_REMergeTestDataFactory.createAction('ACT123','Close And Attach To Winner'));
        
        insert lstAction;
        
        ApexPages.CurrentPage().getparameters().put('actionid',lstAction[0].id);
        
        List<CCPM_RuleAction__c> lstRuleAction = new List<CCPM_RuleAction__c>();
        lstRuleAction.add(CCPM_REMergeTestDataFactory.createRuleAction(lstAction[0].id,'RuleACT123',lstRules[0].id));
        
        List<CCPM_ActionComponent__c> lstActionComponent = new List<CCPM_ActionComponent__c>();
        lstActionComponent.add(CCPM_REMergeTestDataFactory.createActionComponent(lstAction[0].id,'SampleAPI__c','SampleACTCOMPID__c'));
        
        CCPM_REActionController objREActionController = new CCPM_REActionController();
        objREActionController.getACFieldTypes();
        objREActionController.getFieldTypes();

    }

}