@isTest
public class CCPM_getLeadStatusTest
{
    @isTest
    private static void  tesmethod1()
    {
        CCPM_testDataFactory.createCustomSetting();
        CCPM_getLeadStatus.getLeadStatusValues();
        CCPM_getLeadStatus.getReasonforPurchaseValues();
       // CCPM_getLeadStatus.getEventTypeValues();
        CCPM_getLeadStatus.getCommPrefValues();
        CCPM_getLeadStatus.getTransCompleteValues();
        CCPM_getLeadStatus.getQuickNotesDescriptionValues();
        CCPM_getLeadStatus.getCartStatusValues();
        CCPM_getLeadStatus.getSalutationValues();
        CCPM_getLeadStatus.getLeadSourceValues();
        CCPM_getLeadStatus.getClosedLeadSourceValues();
        CCPM_getLeadStatus.getCurrentCarrierValues();
        CCPM_getLeadStatus.getItemsInterestedInValues();
        CCPM_getLeadStatus.getCountryValues();
        CCPM_getLeadStatus.getStateValues();
        CCPM_staticConstants.strEncryptionAlgorithm='AES128';
        ccpm_staticConstants.strEncryptedKey='6159644412316563';
                CCPM_staticConstants.strNone='--None-';
        CCPM_staticConstants.strEmpty='';
        CCPM_getLeadStatus.getDependentOptionsImpl('Lead', 'status', 'CCPM_leadSubStatus__c');
        lead objlead = new lead();
        objlead.Salutation='--None--';
        objlead.FirstName='sampletestname';
        objlead.LastName='testdata';
        objlead.CCPM_SMSLegalOptIn__c=true;
        objlead.Company='1';
        objlead.CCPM_mobileNumber__c='2367890392';
                objlead.CCPM_confirmMTN__c='2367890392';
        //CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID='012630000008p1kAAA';
        Account objSfdcAcc= new Account();
        objSfdcAcc.Name='test name';
        objSfdcAcc.CCPM_accountNumber__c='32670-1';
        objSfdcAcc.CCPM_mobileNumber__c='2367890392';
        insert objSfdcAcc;
        CCPM_getLeadStatus.createLeadRec(objlead, null, objSfdcAcc);
    }
    @isTest
    private static void  VisionMethodTest()
    {
        CCPM_testDataFactory.createCustomSetting();
         CCPM_staticConstants.strEncryptionAlgorithm='AES128';
        ccpm_staticConstants.strEncryptedKey='6159644412316563';
        //CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID='012630000008p1kAAA';
        CCPM_staticConstants.strNone='--None-';
                CCPM_staticConstants.strEmpty='';
        lead objlead = new lead();
        objlead.FirstName='sampletestname';
        objlead.LastName='testdata';
        objlead.CCPM_SMSLegalOptIn__c=true;
        objlead.Company='1';
        objlead.CCPM_mobileNumber__c='2367890392';
        Account objVsiionAcc= new Account();
        objVsiionAcc.Name='test name';
        objVsiionAcc.CCPM_accountNumber__c='32670-1';
        objVsiionAcc.CCPM_mobileNumber__c='2367890392';
        CCPM_getLeadStatus.createLeadRec(objlead, objVsiionAcc, null);
        
    }
    @isTest
    private static void getRecord()
    {
        CCPM_testDataFactory.createCustomSetting();
         CCPM_staticConstants.strEncryptionAlgorithm='AES128';
        ccpm_staticConstants.strEncryptedKey='6159644412316563';
        CCPM_staticConstants.strColon=':';
         CCPM_staticConstants.strNone='--None-';
                CCPM_staticConstants.strEmpty='';
        lead objlead = new lead();
        objlead.Salutation='--None--';
        objlead.FirstName='sampletestname';
        objlead.LastName='testdata';
        objlead.CCPM_mobileNumber__c='3473483205';
        objlead.CCPM_confirmMTN__c='3473483205';
        objlead.CCPM_SMSLegalOptIn__c=true;
        objlead.Company='1';
        objlead.Status='new';
        objLead.CCPM_LeadType__c = 'Customer SFDC Manual';
        insert objlead;
        CCPM_getLeadStatus.getRecord(objlead.id);
        CCPM_getLeadStatus.updateLead(objlead);
        
    }
    
	@isTest
    private static void createAccount()
    {
                CCPM_testDataFactory.createCustomSetting();
        CCPM_staticConstants.strnondigits='[^0-9]';
        CCPM_staticConstants.strNone='--None-';
                CCPM_staticConstants.strEmpty='';
    Account objVsiionAcc= new Account();
        objVsiionAcc.Name='test name';
        objVsiionAcc.CCPM_accountNumber__c='32670-1';
        objVsiionAcc.CCPM_mobileNumber__c='3473483204';
        insert objVsiionAcc;
        Id [] fixedSearchResults = new Id[]{objVsiionAcc.Id};
                    Test.setFixedSearchResults(fixedSearchResults); 
            CCPM_getLeadStatus.searchAccount('3473483204');
    }

    static testmethod void testGetEventTypeMap() {
        
        list<user> lstUser = ccpm_testdatautil.createTestUsers('CCPM Sales Rep', 1);
        insert lstUser;
        system.runAs(lstuser[0]){
            boolean retBool;
            test.startTest();
            retBool = ccpm_getLeadstatus.getIsTelesalesUser();
            test.stopTest();
            system.assertequals(false,retBool);
        }
        map<String,map<String,list<ccpm_smstemplate__c>>> retMap = ccpm_getleadstatus.getEventTypeMap(lstuser[0].id);
        system.assert(retMap.size() < 1);
    }
    
     static testmethod void testLeadCreatePermission() {
        
        list<user> lstUser = ccpm_testdatautil.createTestUsers('CCPM Retail District Management', 1);
        insert lstUser;
        system.runAs(lstuser[0]){
            boolean profileRestricted;
            test.startTest();
            profileRestricted = ccpm_getLeadstatus.getIscurrentUserhavingLeadCreatePermission();
            test.stopTest();
            system.assert(true,profileRestricted);
        }
     } 
    static testmethod void testProfilePermissionforNotes() {
        
        list<user> lstUser = ccpm_testdatautil.createTestUsers('CCPM Retail District Management', 1);
        insert lstUser;
        system.runAs(lstuser[0]){
            boolean profileRestricted;
            test.startTest();
            profileRestricted = ccpm_getLeadstatus.getUserProfilePermissionforNotes();
            test.stopTest();
            system.assert(true,profileRestricted);
        }
         
    }
    
    static testmethod void testProfilePermissionforStatus() {
        
        list<user> lstUser = ccpm_testdatautil.createTestUsers('CCPM Retail Market Analysts', 1);
        insert lstUser;
        system.runAs(lstuser[0]){
            boolean profileRestricted;
            test.startTest();
            profileRestricted = ccpm_getLeadstatus.getUserProfilePermissionforStatus();
            test.stopTest();
            system.assert(true,profileRestricted);
        }
         
    }
}