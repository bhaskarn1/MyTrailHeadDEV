@isTest
public class CCPM_clickToCallControllerTest {

    public static list<lead> lstLead;
    public static list<user> lstUser;
    public static String strLeadProspectRT = 
        Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId();
    
    static{
        lstUser = CCPM_testDataUtil.createTestUsers('System Administrator', 1);
        lstUser[0].mobilePhone = '0323298238';
        insert lstUser;
        lstLead = CCPM_testDataUtil.createLead(1,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        insert lstLead;
        lstLead[0].status = 'Qualified';
        lstLead[0].CCPM_leadSubStatus__c = 'In Discussion';
        update lstLead[0];
        
    }
    
    static testMethod void testGetResponse() {
        
        system.runAs(lstUser[0]){
            
            insert new CCPM_globalSetting__c(CCPM_cartClosedStatus__c = 'Expired:Converted:Dismissed',CCPM_leadOpenStatus__c = 'New:Eligible:Contacted:Responded:Qualified');

            test.startTest();
            CCPM_globalSetting__c objCustSettings = CCPM_globalSetting__c.getOrgDefaults();
            Test.setMock(WebServiceMock.class, new CCPM_clickToCallMock());
            ccpm_clicktoCallController.respWrapper retWrapper = CCPM_clicktoCallController.getResponse(lstLead[0].id,false);
            system.debug('re-- '+retwrapper);
            Test.stopTest();
        }
    }
}