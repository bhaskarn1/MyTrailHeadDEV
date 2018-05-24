/**
*@name          CCPM_processConvertedLeadsBatchHNDLRTest
*@author        Brigadesh Chandrasekar (Deloitte)
*@date          02/17/2018
@description    This is a test class for CCPM_processCCTBatchHandler
@testClass:     CCPM_processCCTBatchHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                              Date                                Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)     02/17/2018                          Original Version
*/

@istest(SeeAllData=False)
public class CCPM_processCCTBatchHandlerTestClass {    
    
    public static list<string> lstAccountUniqueID=new list<string>();
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This method is targeted to test the Batch Class for processConvertedCartTypes
*@param :       None
*/
    @istest(SeeAllData=False) public static void testLeadCreation()
    {   
        List<lead> lstLead = new List<lead>();
        Lead l1 = new Lead();
        
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        
        Id customerCartRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer Cart').getRecordTypeId();
        list<CCPM_Store__c> lstObjStore = CCPM_testDataFactory.createStore(CCPM_staticConstants.NoOfRecords);
        CCPM_testDataFactory.createCustomer(1, 'abc');
        
        l1.LastName = 'ABCActionRequiredOne';
        l1.FirstName = 'TestingOne';
        l1.Status = 'Converted';
        l1.CCPM_SMSLegalOptIn__c = true;
        l1.CCPM_convertedCartType__c = 'AAL,AAL,NEW,EUP-A1,Gibberish';
        l1.CCPM_accountUniqueID__c = 'abc0';
        l1.CCPM_cartTypeProcessed__c = false;
        l1.CCPM_lastInteraction__c = system.now().addHours(-800);
        l1.CCPM_mobileNumber__c = '9999999999';
        l1.Company = '1';
        l1.CCPM_closedLeadSource__c = 'ATG-ECOM-TDOT';
        l1.CCPM_sendLeadsRequiringActionSMS__c = false;
        l1.CCPM_storeID__c = lstObjStore[0].CCPM_storeid__c;
        l1.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
        
        lstLead.add(l1);
        insert lstLead;
        CCPM_ESNCodes__c ESN = new CCPM_ESNCodes__c();
        ESN.CCPM_isActive__c=true;
        ESN.Name='A1';
        insert ESN;
         Profile p = [SELECT Id FROM Profile WHERE Name='CCPM Sales Rep'];
        User u = new User(Alias = 'manager', Email='standardtestuser2UAT@testorgUAT.com',firstname='a', 
                          EmailEncodingKey='UTF-8', LastName='manager', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='manager'+'UAT@testorgUAT.com',mobilephone='3214249106');
        insert u;
        CCPM_testDataFactory.createStoreRep(u,lstObjStore[0]);
        System.debug('userid->'+u.id);
        lstLead[0].ownerid=u.id;
        update lstLead[0];
        System.debug('lstLead[0]->'+lstLead[0].ownerid);
        CCPM_processCommissionableCartType ProcessCommisionableBatch = new CCPM_processCommissionableCartType();
        
        
        Database.executeBatch(ProcessCommisionableBatch,200);
        test.stopTest();
        list<CCPM_CartType__c> lstCartTypesCommissionable = new list<CCPM_CartType__c>();
        lstCartTypesCommissionable = [Select id from CCPM_CartType__c where CCPM_CommissionEligible__c=true];
        System.debug('lstCartTypesCommissionable->'+lstCartTypesCommissionable);
        System.assert(lstCartTypesCommissionable.size()==4);
        list<CCPM_CartType__c> lstCartTypesNonCommissionable = new list<CCPM_CartType__c>();
        lstCartTypesNonCommissionable = [Select id from CCPM_CartType__c where CCPM_CommissionEligible__c=false];
        System.debug('lstCartTypesNonCommissionable->'+lstCartTypesNonCommissionable);
        System.assert(lstCartTypesNonCommissionable.size()==1);
        
        
        
    }      
}