/**
*@name          CCPM_RERuleControllerTest 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          03/21/2018
*@description   This is a Test class for CCPM_RERuleController
*@Class         CCPM_RERuleControllerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    03/21/2018   Initial Implementation.
*/

@isTest
private class CCPM_RERuleControllerTest {
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
	*/ 
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        CCPM_RERuleController objRERuleController = new CCPM_RERuleController();
        objRERuleController.save();
        objRERuleController.getFieldTypes();
        objRERuleController.setFieldType();
        objRERuleController.removeCriteriaRow();
        objRERuleController.removeRuleActionRow();
        objRERuleController.edit();
        objRERuleController.cloneRulePackage();
        
        CCPM_Rule__c objRule = new CCPM_Rule__c();
        List<CCPM_Criteria__c> lstcriteria = new List<CCPM_Criteria__c>();
        List<CCPM_RuleAction__c> lstRuleAction = new List<CCPM_RuleAction__c>();
        
        CCPM_RERuleController.RERulePackage objRERulePackage = new CCPM_RERuleController.RERulePackage(objRule,lstcriteria,lstRuleAction);
        objRERulePackage.addCriteriaRow();
            objRERulePackage.addRuleActionRow();
    }
}