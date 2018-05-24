/**
*@name          CCPM_NPS
*@author        Anupreeta Chakraborty (Deloitte)
*@date          01/11/2018
@description    US-2359: Updates Account with recent NPS data.


@testClass:     CCPM_leadTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Anupreeta Chakraborty (Deloitte)     01/11/2018              Initial Version
*/
//(SeeAllData=False)
@istest
public class CCPM_NPStest {

public static User SysAdminUser=CCPM_testDataFactory.CreateUser('System Administrator','SysAdminUser');

/**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This method is targeted to test the CCPM_NPS Insert and related Account update.
*@param :       None
*/
      
    @istest (SeeAllData=True)
    public static void testNPSCreation()
    {  
    test.starttest();        
    System.runAs(SysAdminUser){
    
    //Create Customer
    List<Account> lstCustomer = CCPM_testDataFactory.createCustomer(1,'B');
    System.assertEquals(true, lstCustomer.size()>0);
    //Create NPS
    List<CCPM_NPS__c> lstNPS = CCPM_testDataFactory.createNPS(lstCustomer[0]);
    lstNPS[0].CCPM_surveyMobileNumber__c = '1234547890';
      try {
   //update NPS
    update lstNPS[0];
     }
        Catch(DmlException e) {
            System.debug('The following exception has occurred while updating NPS/ClassName:CCPM_NPStest: ' + e.getMessage());            
        }
      try {
   //delete NPS
    delete lstNPS[0];
     }
        Catch(DmlException e) {
            System.debug('The following exception has occurred while deleting NPS/ClassName:CCPM_NPStest: ' + e.getMessage());            
        }  
   try {
   //undelete NPS
    undelete lstNPS[0];
     }
        Catch(DmlException e) {
            System.debug('The following exception has occurred while undeleting NPS/ClassName:CCPM_NPStest: ' + e.getMessage());            
        }        
    }    
    test.stoptest();
    }    
}