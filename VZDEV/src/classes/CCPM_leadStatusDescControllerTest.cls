/**
*@name          CCPM_leadStatusDescControllerTest
*@author        Ritwik Koneru (Deloitte)
*@date          03/09/2018
*@description   Test class for CCPM_leadStatusDescController
*@Class         CCPM_leadStatusDescControllerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Ritwik Koneru (Deloitte)    	03/21/2018   Initial Implementation.
*/
@isTest
public class CCPM_leadStatusDescControllerTest {
    
    static String prospect = schema.SObjectType.lead.getrecordtypeInfosbyName().get('Prospect').getRecordTypeId();
    /**
	@author        Ritwik Koneru(Deloitte)
	@description   Test method for getStatusDetails
	*/
    public static testMethod void testgetStatusDetails () {
        
        list<lead> lstLead = ccpm_testdatautil.createLead(1, Prospect, false, 'Prospect SFDC Manual');
        lstLead[0].ccpm_createdchannel__c = 'Telesales';
        insert lstLead;
        ccpm_leadstatusDescController.statusdescWrapper retWrap = new ccpm_leadstatusDescController.statusdescWrapper();
        retWrap = CCPM_leadStatusDescController.getStatusDetails(lstlead[0].id);
        system.assertequals('This lead will be contacted from Salesforce.',retWrap.description);
    }
}