/**
*@name          CCPM_expireInActiveLeadsJobTest
*@author        Paras Shah (Deloitte)
*@date          05/25/2017
@description    This is a test class for CCPM_expireInActiveLeadsJob


@testClass:     CCPM_expireInActiveLeadsJobTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)    05/25/2017                          Original Version
*/

@istest(SeeAllData=False)
public class CCPM_expireInActiveLeadsJobTest {    
    
    public static list<string> lstAccountUniqueID=new list<string>();
    
    /**
*@author        Paras Shah (Deloitte)
*@description   This method is targeted to test the CCPM_SMSInteractionHistoryController class
*@param :       None
*/
    @istest(SeeAllData=False) public static void testLeadCreation()
    {   
        test.startTest();
        
        insert new CCPM_globalSetting__c(CCPM_daysOfLeadExpiry__c = -2,CCPM_initialSMSInterval__c ='10', CCPM_followUpSMSInterval__c='10'); 
        
        CCPM_expireInActiveLeadsJob expireLeads = new CCPM_expireInActiveLeadsJob();
        String schedule = '0 0 * * * ?';
        system.schedule('Lead Expiration', schedule, expireLeads);

        test.stopTest();
    }        
  }