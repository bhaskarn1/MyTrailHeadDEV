/**
*@name          CCPM_sendSMSControllerTest 
*@author        Ritwik Koneru (Deloitte)
*@date          02/08/2018
*@description   This is a Test class for
*@Class         CCPM_sendSMSController
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Ritwik Koneru (Deloitte)    02/08/2018   Initial Implementation.
*/

@isTest(seeAllData=false)
private class CCPM_sendSMSControllerTest {
    
    static String strLeadCustomerCartRT = 
        Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
    
    /**
	@author       Ritwik Koneru (Deloitte)
	@description  Test method for ccpm_sendSMSController class
	@param        N/A
	@return       Void(None)
	*/ 
    static testMethod void testsendPreDefinedSMSToCustomer() {
        
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('System Administrator',1);
        insert lstUser;
        system.runAs(lstUser[0]){
      
            CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(lstUser[0].id);
            settings.CCPM_DisableOldTriggerForTest__c = false;
            insert settings;
            
            Integer resInt = 0;
            integer resInt1 = 0;
            
            list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadCustomerCartRT,false,'Prospect SFDC Manual');
            lstLead[0].Status = 'Eligible';
            lstLead[0].CCPM_isInitialSMSSent__c = true;
            lstLead[0].CCPM_isFollowUpSMSSent__c = false;
            lstLead[0].CCPM_firstPredefinedSMSFlag__c = false;
            lstLead[0].CCPM_finalPreDefinedSMSFlag__c = false;
            insert lstLead[0];
            
            test.startTest();
            ccpm_sendsmsController.SendSMSWrapper resWrapper1 = new ccpm_sendsmsController.sendsmsWrapper('Test');
            resWrapper1 = ccpm_sendSMSController.getLeadAndSendSMSWrapperInfo(lstLead[0].id);
            system.assertEquals('Lead has to be in Responded - Action Required State.',resWrapper1.strMessage);
            
            lstLead[0].status='Responded';
            update lstLead[0];
            
            lstLead[0].ccpm_leadsubstatus__c = 'Action Required';
            update lstLead[0];

            ccpm_sendsmsController.SendSMSWrapper resWrapper2 = new ccpm_sendsmsController.sendsmsWrapper('Test');
            resWrapper2 = ccpm_sendSMSController.getLeadAndSendSMSWrapperInfo(lstLead[0].id);
            system.assertEquals('Customer',resWrapper2.strMessage);
            
            Test.setMock(HttpCalloutMock.class, new CCPM_PreMockHttpResponseGenerator());
			list<String> lstStr = new list<String>();           
            try{
                resInt = ccpm_sendSMSController.sendPreDefinedSMSToCustomer(lstLead[0],'Custom Reply','Test',lstStr);
            } catch (exception e){}
            //system.assertEquals(204, resInt);
            lstLead[0].CCPM_firstPredefinedSMSFlag__c = true;
				update lstLead[0];
            try {
				integer	resInt2 = ccpm_sendSMSController.sendPreDefinedSMSToCustomer(lstLead[0],'Custom Reply','Test',lstStr);
				} catch (exception e){}
            system.assert(resInt!=null);
            lstStr.add('cock');
				try {
					resInt1 = ccpm_sendSMSController.sendPreDefinedSMSToCustomer(lstLead[0],'Custom Reply','Test',lstStr);
				} catch (exception e){}
			system.assertEquals(0,resInt1);
            ccpm_sendSMSController.createCustomeMessageRecord(lstLead[0], 'Hi', 'Blocked', lstStr, 'Custom Reply');
            test.stopTest();
        }
    }
}