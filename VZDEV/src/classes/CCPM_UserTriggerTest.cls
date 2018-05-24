/**
*@name          ccpm_userTriggerHandler 
*@author        Sriraman Sridharan (Deloitte)
*@date          10/16/2017
*@description   This is a Handler for user tirgger. 
*@Class         ccpm_userTriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Sriraman Sridharan (Deloitte)    03/12/2017   Initial Implementation.
*/
@isTest
public class CCPM_UserTriggerTest {

    public static testMethod void testGETMethod(){
        test.startTest();
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 1);
        insert lstUser;
        
        list<user> lstUserInserted = new list<user>([Select id, CCPM_employeeID__c from user where id=:lstUser[0].id]);
        system.debug('@@@ : ' + lstUserInserted);
        lstUserInserted[0].CCPM_employeeID__c = '123445';
        update lstUserInserted;
        CCPM_userTriggerHandler objTest = new CCPM_userTriggerHandler();
        objTest.AfterDelete(null);
        objTest.AfterDelete(null);
        objTest.AfterUndelete(null);
        objTest.BeforeDelete(null);
        test.stopTest();
    }
    
}