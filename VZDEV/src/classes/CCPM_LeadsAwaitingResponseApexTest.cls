/**
*@name          CCPM_LeadsAwaitingResponseApexTest
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
public class CCPM_LeadsAwaitingResponseApexTest {
    @isTest
    public static void loadComponentWithRecordsTest(){
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        List<Lead> lstLead = new List<Lead>();
        lstLead = CCPM_testDataFactory.createmyActiveLeadsTest(5, 'Confirming with Family First', 'Prospect SFDC Manual');
        insert lstLead;
        lstLead[0].status='Responded';
        lstLead[0].CCPM_Leadsubstatus__c='Action Required';
        lstLead[0].CCPM_SMSResponseReceivedDateTime__c=System.now().addHours(-7);
        update lstLead[0];
        System.assert(CCPM_LeadsAwaitingResponseApexController.loadComponentWithRecords(null,null,null,'0')!=null);
        lstLead[0].CCPM_firstPredefinedSMSFlag__c=true;
        update lstLead;
        System.assert(CCPM_LeadsAwaitingResponseApexController.loadComponentWithRecords(null,null,null,'0')!=null);
        lstLead[0].RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
        lstLead[0].CCPM_firstPredefinedSMSFlag__c=false;
        update lstLead[0];
        System.assert(CCPM_LeadsAwaitingResponseApexController.loadComponentWithRecords(null,null,null,'0')!=null);
        test.stopTest();
    }
    
}