/**
*@name          CCPM_leadsAwaitingChildStatusApexConTest
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          12/15/2017
*@description   Test Class
Modification    Log:
------------------------------------------------------------------------------------
Developer                                     Date               Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)             12/15/2017         Original Version       
*/
@isTest
public class CCPM_leadsAwaitingChildStatusApexConTest {
    @isTest
    public static void loadComponentWithRecordsTest(){
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        List<Lead> lstLead = new List<Lead>();
        lstLead = CCPM_testDataFactory.createmyActiveLeadsTest(5, 'Confirming with Family First','Customer Abandoned Cart Digital');
        insert lstLead;
        CCPM_leadsAwaitingChildStatusApexCon.createSubStatusMap();
        CCPM_leadsAwaitingChildStatusApexCon.saveLeadServer('In Discussion',lstlead[0]);
        system.assert(lstLead[0].Status=='Qualified');
        test.stopTest();
    }
    
}