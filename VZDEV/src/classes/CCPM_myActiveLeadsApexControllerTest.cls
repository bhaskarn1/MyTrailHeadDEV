@isTest
public class CCPM_myActiveLeadsApexControllerTest {
    @isTest
    public static void loadComponentWithRecordsTest(){
        CCPM_testDataFactory.createCustomSetting();
        List<Lead> lstLead = new List<Lead>();
        lstLead = CCPM_testDataFactory.createmyActiveLeadsTest(5, 'Confirming with Family First','Customer Abandoned Cart Digital');
        insert lstLead;
        CCPM_myActiveLeadsApexController.loadComponentWithRecords('Name', 'ASC', '20', '10');
        CCPM_myActiveLeadsApexController.loadComponentWithRecords('Name', 'ASC', null, '10');
    }

}