/**
*@name          CCPM_viewReportLinkLightningController
*@author        Paras Shah (Deloitte)
*@date          04/21/2017
*@description   For SMS Interaction history
*@testClass     CCPM_viewReportLinkLightningControllerTest

Modification    Log:
------------------------------------------------------------------------------------
Developer                        Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)             04/21/2017                          Original Version
*/

public class CCPM_viewReportLinkLightningController {
    
    @AuraEnabled
    public static String getLeadReportId(String strReportName) {
        
        // To pull out the ID of the reports based on name of the Report
        List<Report> lstReportId = [Select Id from Report where Name = :strReportName limit 1];

        return string.valueOf(lstReportId[0].Id);
        
    }
}