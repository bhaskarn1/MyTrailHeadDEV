/**
*@name          CCPM_sendPreDefinedSmsTest 
*@author        Manjunath Keshava (Deloitte)
*@date          06/09/2017
@description    This is the Unit Test Class for the sendPreDefinedSms Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    06/09/2017               			 Original Version
Manjunath Keshava (Deloitte)    07/09/2017               			 Modified Version
*/

@istest(SeeAllData=False)
public class CCPM_sendPreDefinedSMSTest 
{
/**
 *  *@author        Manjunath Keshava (Deloitte)
*@description   This method is targeted to test the CCPM_sendPreDefinedSms class
*/
    @testsetup
    public static void leadCreation()
    {
      CCPM_testDataFactory.createCustomSetting();
        ccpm_staticConstants.strColon='';
        lead objNewLead = new lead(LastName = 'Mike', CCPM_mobileNumber__c='3473483204', CCPM_email__c='keshavamanjuth@gmail.com',phone ='1234567890',email='mk@gmail.com' ,Company='1',CCPM_SMSLegalOptIn__c=true, CCPM_LeadType__c = 'Customer Abandoned Cart Digital');
        if(objNewLead!=null)
        insert objNewLead;
        system.assertEquals('3473483204',objNewLead.CCPM_mobileNumber__c );
     }
     public static  testmethod void  getLeadPhone_Test()
    {
        CCPM_testDataFactory.createStore(2);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        lead testLead = [Select Id, Name,email,Store__c from lead where phone= '1234567890'];
        //testLead.Store__c=lststore[0].id;
        CCPM_sendPreDefinedSMS.getLeadPhone (testLead.Id); 
        // lead NewtestLead = [SELECT Id,CCPM_ownerEcode__c,RecordTypeId,CCPM_promoFirstSent__c,CCPM_promoSecondSent__c,CCPM_lastPromoSent__c,CCPM_isMerged__c,CCPM_isInformaticaMerge__c,CCPM_isMergedUIFlag__c, recordtype.name,CCPM_mobileNumber__c, Store__r.name, Store__r.CCPM_street__c, Store__r.CCPM_city__c, Store__r.CCPM_phone__c,Store__r.CCPM_zipcode__c, Status,CCPM_leadSubStatus__c,CCPM_firstPredefinedSMSFlag__c,CCPM_finalPreDefinedSMSFlag__c FROM  lead where Id=:testLead.Id];
        //CCPM_sendPreDefinedSMS.getLeadPhone ( NewtestLead.Id);   
    }
      
    @istest(SeeAllData=False)
    public static  void SendPreDefinedSMSCustomer_Test()
    {
         Test.startTest();
         // Set mock callout class
	     Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        List<CCPM_promoMessage__mdt> listPromoSMSSetting = [Select MasterLabel,CCPM_finalPreDefinedResponse__c,CCPM_firstPreDefinedResponse__c,CCPM_MessageContentForLeads__c,CCPM_messageContentForProspects__c From CCPM_promoMessage__mdt ];
        List<CCPM_promoMessage__mdt> listNewPromoSMSSetting=( List<CCPM_promoMessage__mdt>)Json.deserialize('[{"MasterLabel":"Promo iPhone-8","CCPM_finalPreDefinedResponse__c":"false","CCPM_MessageContentForLeads__c":"Testmessage for Leads","CCPM_messageContentForProspects__c":"TestMessage for Prospects"}]',list<CCPM_promoMessage__mdt>.class);
		 lead newtestLead = [Select Id,RecordTypeId,CCPM_storeEcode__c, Name,CCPM_ownerEcode__c,email from lead where phone= '1234567890'];
         CCPM_sendPreDefinedSMS.sendPreDefinedSMSToCustomer (newtestLead.id,' message','Promo iPhone-8', true, 'In Discussion',newtestLead.RecordTypeId, newtestLead.CCPM_ownerEcode__c,'iPhone X','iPhone 8','iPhone 8',newtestLead.CCPM_storeEcode__c);
         test.stopTest();
    }
    @isTest
    public static  void SendPreDefinedSMSCustomer_Test2()
    {
        Test.startTest();
	     Test.setMock(HttpCalloutMock.class, new CCPM_PreMockHttpResponseGenerator());
		 lead newtestLead = [Select Id,RecordTypeId,CCPM_ownerEcode__c, Name,email from lead where phone= '1234567890'];
        System.debug('CCPM_staticconstants.strProspectAbandonedCartRecordTypeID ' + newtestLead.RecordTypeId );
        newtestLead.recordTypeId = CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
        List<CCPM_promoMessage__mdt> listPromoSMSSetting = [Select MasterLabel,CCPM_finalPreDefinedResponse__c,CCPM_firstPreDefinedResponse__c,CCPM_MessageContentForLeads__c,CCPM_messageContentForProspects__c From CCPM_promoMessage__mdt ];
        List<CCPM_promoMessage__mdt> listNewPromoSMSSetting=( List<CCPM_promoMessage__mdt>)Json.deserialize('[{"MasterLabel":"Promo iPhone-8","CCPM_finalPreDefinedResponse__c":"false","CCPM_MessageContentForLeads__c":"Testmessage for Leads","CCPM_messageContentForProspects__c":"TestMessage for Prospects"}]',list<CCPM_promoMessage__mdt>.class);
         CCPM_sendPreDefinedSMS.sendPreDefinedSMSToCustomer (newtestLead.id,' message','Yes! Our Store Address Is:the--true response--the end result is unknown and the error is yet to be found and then it must be resolved and end result is unknown and the error is yet to be found and then it must be resolved ', false, 'In Discussion',newtestLead.RecordTypeId,null,null,'iPhone 8','iPhone 8',newtestLead.CCPM_storeEcode__c);
        test.stopTest();
    }
    
    @isTest
    public static void  getLeadSubStatus()
    {
         CCPM_sendPreDefinedSms.getLeadSubStatus();
    }
     @isTest 
    public static void getFirstpreDefinedSMSReponse_Test()  
       {
                   CCPM_staticConstants.strRecordTypesWithFreeVzMsg='manjunath:keshava';
           lead testLead = [Select Id, Name,email,Store__c from lead where phone= '1234567890'];
        //testLead.Store__c=lststore[0].id;
        CCPM_sendPreDefinedSMS.getLeadPhone (testLead.Id); 
           CCPM_sendPreDefinedSms.getFirstpreDefinedSMSReponse();
           
       }
     @isTest 
    public static void getFinalpreDefinedSMSReponse_Test()
    {
        CCPM_sendPreDefinedSms.getFinalPreDefinedSMSReponse();
    }
    @isTest
    public static void determineFreeVzMsgSuffi_Test()
      {
        CCPM_staticConstants.strRecordTypesWithFreeVzMsg='manjunath:keshava';		
    	CCPM_sendPreDefinedSms.determineFreeVzMsgSuffix();
      }    
   
}