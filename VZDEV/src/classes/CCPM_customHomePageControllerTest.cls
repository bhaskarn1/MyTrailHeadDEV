/**
*@name          CCPM_customHomePageControllerTest
*@author        Paras Shah (Deloitte)
*@date          04/04/2017
@description    To Test the class CCPM_customHomePageController
@testClass:     CCPM_SMSInteractionHistoryControllerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)    04/04/2017                         Original Version
*/

@istest(SeeAllData=False)
public class CCPM_customHomePageControllerTest {    
/**
*@author        Paras Shah (Deloitte)
*@description   This method is targeted to test the CCPM_customHomePageController class
*@param :       None
*/
    @istest(SeeAllData=False) public static void testLeadCreation()
    {   
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        User integrationUser=CCPM_testDataFactory.CreateUser('CCPM Integration User','integrationUser');
        User sysadminUser =CCPM_testDataFactory.CreateUser('System Administrator','sysadmin');
        System.runAs(integrationUser){
            CCPM_customHomePageController chpc = new CCPM_customHomePageController();
            CCPM_customHomePageController.getLeadsThatResponded();
        }
        System.runAs(sysadminUser){
            CCPM_customHomePageController chpc = new CCPM_customHomePageController();
            CCPM_customHomePageController.getLeadsThatResponded();
        }
        
        test.stopTest();
    }
}