/**
*@name          CCPM_RERecordControllerTest 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          03/21/2018
*@description   This is a Test class for CCPM_RERecordController
*@Class         CCPM_RERecordControllerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    03/21/2018   Initial Implementation.
*/

@isTest
private class CCPM_RERecordControllerTest {
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
        
        CCPM_RERecordController objRERecordController = new CCPM_RERecordController();
        objRERecordController.save();
        objRERecordController.getFieldTypes();
		objRERecordController.setFieldType();        
        objRERecordController.removeCriteriaRow();
        objRERecordController.edit();
        objRERecordController.cloneRecordPackage();
        
        CCPM_RERecord__c objRErecord = new CCPM_RERecord__c();
        
        List<CCPM_Criteria__c> lstCriteria = new List<CCPM_Criteria__c>();
        CCPM_RERecordController.RERecordPackage objRERecordPackage = new CCPM_RERecordController.RERecordPackage(new CCPM_RERecord__c(),lstCriteria);
        objRERecordPackage.addCriteriaRow();
        //objRERecordPackage.RERecordPackage(new CCPM_RERecord__c(),lstCriteria);
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
	*/ 
    static testMethod void testBlankParameter() {
        
        ApexPages.CurrentPage().getparameters().put('clone','1');
        ApexPages.CurrentPage().getparameters().put('recordid','');
        
        CCPM_RERecordController objRERecordControllerNew = new CCPM_RERecordController();
    }
    
}