/**
*@name          CCPM_viewReportLightningControllerTest
*@author        Aneesha Ragireddy (Deloitte)
*@date          05/19/2017
@description    To Test the CCPM_viewReportLinkLightningController


@testClass:     CCPM_viewReportLightningControllerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Aneesha(Deloitte)      05/19/2017                         Original Version
*/
@isTest(SeeAllData='true')
public class CCPM_viewReportLightningControllerTest 
{
    static testMethod void testViewReportLinkMethod()
    {
       
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where
        DeveloperName = 'CCPM_leadsByStatus'];
        String reportId = (String)reportList.get(0).get('Id');
        Test.startTest();
        CCPM_viewReportLinkLightningController.getLeadReportId('Leads by Status');     
        Test.stopTest();
      
    }
}