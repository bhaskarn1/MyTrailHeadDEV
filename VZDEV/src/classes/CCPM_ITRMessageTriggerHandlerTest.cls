/**
*@name          CCPM_CampaignMemberHandler
*@author        Sriraman Sridharan (Deloitte)
*@date          12/12/2017
@description    Test class for ITR FrameWork
@testClass      CCPM_ITRMessageHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          12/12/2017              Original Version, All Methods.
*/

@isTest
public class CCPM_ITRMessageTriggerHandlerTest {

public static User SysAdminUser=CCPM_testDataFactory.CreateUser('System Administrator','SysAdminUser');

    public static void insertITRRecord(String strName, string strMessage,Lead objLead, ID strLiveTextID)
    {
        LiveText__ITR_Message__c ITR=new LiveText__ITR_Message__c();
        ITR.LiveText__LiveText_Number__c=strLiveTextID;
        ITR.Name=strName;
        ITR.LiveText__Originating_Number__c='+14074165813';
        ITR.LiveText__Message__c=strMessage;
        ITR.LiveText__Lead__c=objLead.id;
        system.debug('@@@ITR'+ITR);
        insert ITR;
       
    }
    
    public static void insertLead(string strName, string strAccountUniqueId,string strCartUniqueId, string strLeadType, string strStoreID, Id storeId, User owner){
        Lead objCart=new Lead();
       // objCart.ownerId = owner.id;
        objCart.LastName=strName;
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';  
        objcart.CCPM_accountUniqueID__c=strAccountUniqueId;
        objcart.CCPM_storeID__c = strStoreID;
        // objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';     
        objCart.CCPM_cartUniqueID__c = strCartUniqueId; 
        objCart.CCPM_LeadType__c = strLeadType;
        
        //objCart.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId(); 
        insert objCart;
        
        Lead objCartNew = [Select id, name,store__c,Owner.Name, store__r.CCPM_TimeZone__c, LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  From Lead Where ID =: objCart.Id];
        system.debug('@@@objCartNew.OwnerId : '+objCartNew.OwnerId + ' @@@objCartNew.Owner.Name : '+ objCartNew.Owner.Name);
        objCartNew.Status = 'Contacted';
        objCartNew.CCPM_isInitialSMSSent__c = true;
        update objCartNew;
    }   
 
    //Reply with e
    @isTest
    public static void testResponseScenarioOne(){
        test.startTest();
        System.runAs(SysAdminUser){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioOne';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_TimeZone__c,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MOne', 'rOne', 'commrepId','AmOne', lststore[0].id);
            insertLead('lastNameOne', strAcctUniqueId, 'cartUniqueOne', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        list<Lead> lstLead = [select id, name,store__c,store__r.CCPM_TimeZone__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameOne' limit 1];
        String strMessage = 'e';
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberOne';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        
        insertITRRecord('ITROne', strMessage,lstLead[0],LiveTextNumber1.Id);               
        test.stopTest();
        }
    }
    //Positive message
     @isTest
    public static void testResponseScenarioTwo(){
        test.startTest();
        System.runAs(SysAdminUser){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioTwo';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MTwo', 'rTwo', 'commrepId','AmTwo', lststore[0].id);
            insertLead('lastNameTwo', strAcctUniqueId, 'cartUniqueTwo', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        list<Lead> lstLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameTwo' limit 1];
        String strMessage = 'Hello';
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberTwo';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        insertITRRecord('ITRTwo', strMessage,lstLead[0],LiveTextNumber1.Id);
        }
        test.stopTest();
    }
    //e in Quotes
     @isTest
    public static void testResponseScenarioThree(){
        test.startTest();
        System.runAs(SysAdminUser){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioThree';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MThree', 'rThree', 'commrepId','AmThree', lststore[0].id);
            insertLead('lastNameThree', strAcctUniqueId, 'cartUniqueThree', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameThree' limit 1];
        
        String strMessage = '"e"';
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberThree';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        insertITRRecord('ITRThree', strMessage,objLead,LiveTextNumber1.Id);
        }
        test.stopTest();
    }
    //abusive words
     @isTest
    public static void testResponseScenarioFour(){
        test.startTest();
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioFour';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MFour', 'rFour', 'commrepId','AmFour', lststore[0].id);
            insertLead('lastNameFour', strAcctUniqueId, 'cartUniqueFour', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        CCPM_dataDictionary__c objDataDictionary = new CCPM_dataDictionary__c();
        objDataDictionary.CCPM_StringForexclusion__c = 'dog';
        objDataDictionary.CCPM_IsActive__c = true;
        insert objDataDictionary;
        
        list<Lead> lstLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameFour' limit 1];
        String strMessage = 'Yes, dogs for life';
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberFour';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        insertITRRecord('ITRFour', strMessage,lstLead[0],LiveTextNumber1.Id);
        test.stopTest();
    }
   
    //Double Opt out
    @isTest
    public static void testResponseScenarioFive(){
        
        list<string> lststoreID=new list<string>(); 
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioFive';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MFive', 'rFive', 'commrepId','AmFive', lststore[0].id);
            insertLead('lastNameFive', strAcctUniqueId, 'cartUniqueFive', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameFive' limit 1];
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberFive';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            objLead.CCPM_DoubleOptOutSent__c = true;
            objLead.CCPM_SMSOptOut__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameFive' limit 1];
        String strMessageOptOut = CCPM_staticConstants.strCustomerResponseForOptOut;
        insertITRRecord('ITRFive', strMessageOptOut,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    //Prospect negative
    @isTest
    public static void testResponseScenarioSix(){
        test.startTest();
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioSix';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MSix', 'rSix', 'commrepId','AmSix', lststore[0].id);
            insertLead('lastNameSix', strAcctUniqueId, 'cartUniqueSix', 'Prospect SFDC Manual', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        list<Lead> lstLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameSix' limit 1];
        String strMessage = 'e';
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberSix';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        insertITRRecord('ITRSix', strMessage,lstLead[0],LiveTextNumber1.Id);
        test.stopTest();
    }
    //Prospect Positive
    @isTest
    public static void testResponseScenarioSven(){
        test.startTest();
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioSven';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MSven', 'rSven', 'commrepId','AmSven', lststore[0].id);
            insertLead('lastNameSven', strAcctUniqueId, 'cartUniqueSven', 'Prospect SFDC Manual', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        list<Lead> lstLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameSven' limit 1];
        String strMessage = 'Hey';
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberSven';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        insertITRRecord('ITRSven', strMessage,lstLead[0],LiveTextNumber1.Id);
        test.stopTest();
    }
 
    //Predefined sms
    @isTest
    public static void testResponseScenarioEht(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioEht';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        system.debug('@@@lststore : ' + lststore);
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MEht', 'rEht', 'commrepId','AmEht', lststore[0].id);
           // system.debug('@@@lststore[0].CCPM_storeID__c : ' + lststore[0].CCPM_storeID__c);
            List<CCPM_storeEmployee__c> lstStoreEmployeeFromLakeShore = new List<CCPM_storeEmployee__c>([Select id,CCPM_employee__c,isactivetest__c,CCPM_role__c,CCPM_IsActive__c,CCPM_Store__c,CCPM_StoreID__c from CCPM_storeEmployee__c where CCPM_StoreID__c = :lststore[0].CCPM_storeID__c]);
            system.debug('@@@lstStoreEmployeeFromLakeShore : ' + lstStoreEmployeeFromLakeShore);
           // List<CCPM_StoreEmployee__c> lstStoreEmployee = [select id, CCPM_employee__c from CCPM_StoreEmployee__c where CCPM_role__c =: 'Store Manager' and CCPM_Store__c =: strStore];
           // lstStoreEmployee[0].CCPM_employee__c=SysAdminUser.id;
           // update lstStoreEmployee;
            insertLead('lastNameEht', strAcctUniqueId, 'cartUniqueEht', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,Owner.Name,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameEht' limit 1];
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberEht';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@objLead.OwnerId : '+objLead.OwnerId + ' @@@objLead.Owner.Name : '+ objLead.Owner.Name);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            objLead.CCPM_firstPredefinedSMSFlag__c = true;
            objLead.CCPM_finalPreDefinedSMSFlag__c = false;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,Owner.Name,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameEht' limit 1];
       // system.debug('@@@objLeadUpdated.OwnerId : '+objLeadUpdated.OwnerId + ' @@@objLeadUpdated.Owner.Name : '+ objLeadUpdated.Owner.Name);
        String strMessageOptOut = 'Okay';
        insertITRRecord('ITREht', strMessageOptOut,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    
   //CC second positive
    @isTest
    public static void testResponseScenarioNine(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioNine';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MNine', 'rNine', 'commrepId','AmNine', lststore[0].id);
            insertLead('lastNameNine', strAcctUniqueId, 'cartUniqueNine', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameNine' limit 1];
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberNine';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            objLead.CCPM_DoubleOptOutSent__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameNine' limit 1];

        String strMessageOptOut = 'Hey';
        insertITRRecord('ITRNine', strMessageOptOut,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    //CC second negative
    @isTest
    public static void testResponseScenarioTen(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioTen';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MTen', 'rTen', 'commrepId','AmTen', lststore[0].id);
            insertLead('lastNameTen', strAcctUniqueId, 'cartUniqueTen', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameTen' limit 1];
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberTen';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            objLead.CCPM_DoubleOptOutSent__c = false;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameTen' limit 1];

        String strMessageOptOut = 'e';
        insertITRRecord('ITRTen', strMessageOptOut,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
//Prospect second positive
    @isTest
    public static void testResponseScenarioElvn(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioElvn';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MElvn', 'rElvn', 'commrepId','AmElvn', lststore[0].id);
            insertLead('lastNameElvn', strAcctUniqueId, 'cartUniqueElvn', 'Prospect SFDC Manual', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameElvn' limit 1];
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberElvn';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameElvn' limit 1];

        String strMessageOptOut = 'Hey';
        insertITRRecord('ITRElvn', strMessageOptOut,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    //Prospect second negative
    @isTest
    public static void testResponseScenarioTlve(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioTlve';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MTlve', 'rTlve', 'commrepId','AmTlve', lststore[0].id);
            insertLead('lastNameTlve', strAcctUniqueId, 'cartUniqueTlve', 'Prospect SFDC Manual', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameTlve' limit 1];
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberTlve';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameTlve' limit 1];

        String strMessageOptOut = 'e';
        insertITRRecord('ITRTlve', strMessageOptOut,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    //abusive words second
     @isTest
    public static void testResponseScenariotten(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'Scenariotten';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('Mtten', 'rtten', 'commrepId','Amtten', lststore[0].id);
            insertLead('lastNametten', strAcctUniqueId, 'cartUniquetten', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        CCPM_dataDictionary__c objDataDictionary = new CCPM_dataDictionary__c();
        objDataDictionary.CCPM_StringForexclusion__c = 'dog';
        objDataDictionary.CCPM_IsActive__c = true;
        insert objDataDictionary;
        
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNametten' limit 1];
        
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumbertten';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNametten' limit 1];

        String strMessage = 'Yes, dogs for life';
        insertITRRecord('ITRtten', strMessage,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    //Removed By Location Setting
     @isTest
    public static void testResponseScenarioften(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'Scenarioften';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        Map<String, CCPM_suppressOutboundSMS__c> mapSuppressOutboundMessage = CCPM_staticConstants.mapSuppressOutboundMessage;
        Set<CCPM_suppressOutboundSMS__c> setSuppressOutboundMessage = new Set<CCPM_suppressOutboundSMS__c>();
        if(mapSuppressOutboundMessage != null && !mapSuppressOutboundMessage.isEmpty()){
            For(string strkey : mapSuppressOutboundMessage.keySet()){
                CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = new CCPM_suppressOutboundSMS__c();
                objSuppressOutboundMessage = mapSuppressOutboundMessage.get(strkey);
                //Check for Market/Territory/District
                if(objSuppressOutboundMessage.IsActive__c){
                    setSuppressOutboundMessage.add(objSuppressOutboundMessage);
                }
            }
        }
        List<CCPM_suppressOutboundSMS__c> lstSuppressOutboundMessage = new List<CCPM_suppressOutboundSMS__c>();
        lstSuppressOutboundMessage.addAll(setSuppressOutboundMessage);
        lststore[0].CCPM_market__c = lstSuppressOutboundMessage[0].Market__c;
        lststore[0].CCPM_territory__c = lstSuppressOutboundMessage[0].Territory__c;
        lststore[0].CCPM_district__c = lstSuppressOutboundMessage[0].District__c;
        update lststore;
        
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('Mften', 'rften', 'commrepId','Amften', lststore[0].id);
            insertLead('lastNameften', strAcctUniqueId, 'cartUniqueften', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameften' limit 1];
        
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberften';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameften' limit 1];

        String strMessage = 'Yes';
        insertITRRecord('ITRtten', strMessage,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    //Removed By Location Setting 2
     @isTest
    public static void testResponseScenarioSten(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioSten';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        Map<String, CCPM_suppressOutboundSMS__c> mapSuppressOutboundMessage = CCPM_staticConstants.mapSuppressOutboundMessage;
        Set<CCPM_suppressOutboundSMS__c> setSuppressOutboundMessage = new Set<CCPM_suppressOutboundSMS__c>();
        if(mapSuppressOutboundMessage != null && !mapSuppressOutboundMessage.isEmpty()){
            For(string strkey : mapSuppressOutboundMessage.keySet()){
                CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = new CCPM_suppressOutboundSMS__c();
                objSuppressOutboundMessage = mapSuppressOutboundMessage.get(strkey);
                //Check for Market/Territory/District
                if(objSuppressOutboundMessage.IsActive__c){
                    setSuppressOutboundMessage.add(objSuppressOutboundMessage);
                }
            }
        }
        List<CCPM_suppressOutboundSMS__c> lstSuppressOutboundMessage = new List<CCPM_suppressOutboundSMS__c>();
        lstSuppressOutboundMessage.addAll(setSuppressOutboundMessage);
        
        
        
        lststore[0].CCPM_market__c = lstSuppressOutboundMessage[0].Market__c;
        lststore[0].CCPM_territory__c = lstSuppressOutboundMessage[0].Territory__c;
        update lststore;
        lstSuppressOutboundMessage[0].District__c = null;
        update lstSuppressOutboundMessage;
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MSten', 'rSten', 'commrepId','AmSten', lststore[0].id);
            insertLead('lastNameSten', strAcctUniqueId, 'cartUniqueSten', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameSten' limit 1];
        
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberSten';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameSten' limit 1];

        String strMessage = 'Yes';
        insertITRRecord('ITRSten', strMessage,objLeadUpdated,LiveTextNumber1.Id);
        test.stopTest();
    }
    //Removed By Location Setting 3
     @isTest
    public static void testResponseScenarioEten(){
        list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioEten';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        Map<String, CCPM_suppressOutboundSMS__c> mapSuppressOutboundMessage = CCPM_staticConstants.mapSuppressOutboundMessage;
        Set<CCPM_suppressOutboundSMS__c> setSuppressOutboundMessage = new Set<CCPM_suppressOutboundSMS__c>();
        if(mapSuppressOutboundMessage != null && !mapSuppressOutboundMessage.isEmpty()){
            For(string strkey : mapSuppressOutboundMessage.keySet()){
                CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = new CCPM_suppressOutboundSMS__c();
                objSuppressOutboundMessage = mapSuppressOutboundMessage.get(strkey);
                //Check for Market/Territory/District
                if(objSuppressOutboundMessage.IsActive__c){
                    setSuppressOutboundMessage.add(objSuppressOutboundMessage);
                }
            }
        }
        List<CCPM_suppressOutboundSMS__c> lstSuppressOutboundMessage = new List<CCPM_suppressOutboundSMS__c>();
        lstSuppressOutboundMessage.addAll(setSuppressOutboundMessage);
        
        lststore[0].CCPM_market__c = lstSuppressOutboundMessage[0].Market__c;
        update lststore;
        lstSuppressOutboundMessage[0].District__c = null;
        lstSuppressOutboundMessage[0].Territory__c = null;
        update lstSuppressOutboundMessage;
        if(lststore!= null && lststore.size()>0 && lststore.isEmpty()==false){
            CCPM_testDataFactory.createStoreEmployee('MEten', 'rEten', 'commrepId','AmEten', lststore[0].id);
            insertLead('lastNameEten', strAcctUniqueId, 'cartUniqueEten', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        }
        lead objLead = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameEten' limit 1];
        
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='strLiveTextNumberEten';
        LiveTextNumber1.LiveText__Validated__c=true;//ccpm_staticConstants.boolSMSSent;
        system.debug('@@@@ check the boolean value'+LiveTextNumber1.LiveText__Validated__c);
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        test.startTest();
        if(objLead != null){
            objLead.CCPM_isSMSResponseReceived__c = true;
            update objLead;
        }
        lead objLeadUpdated = [select id, name,store__c,LastName,OwnerId,CCPM_isLeadOwnerActive__c,CCPM_CustomerResponseMsgBodyforProsp__c,CCPM_storeTerritory__c,CCPM_storeMarket__c,CCPM_storeDistrict__c,CCPM_lastInteraction__c,CCPM_SMSResponseBodyForProspect__c,CCPM_DoubleOptOutSmsBody__c,CCPM_CustomerResponseMessageBody__c,CCPM_SMSResponseBody__c,Status,CCPM_leadSubStatus__c,CCPM_isSMSResponseReceived__c,RecordTypeId,CCPM_isManualLead__c,CCPM_isFollowUpSMSSent__c,CCPM_finalPreDefinedSMSFlag__c,CCPM_firstPredefinedSMSFlag__c,CCPM_SMSOptOut__c,CCPM_DoubleOptOutSent__c,CCPM_AutoResponseForDoubleOptOutSmsSent__c,CCPM_Account__r.CCPM_SMSOptOut__c,CCPM_SMSResponseReceivedDateTime__c,CCPM_UpdateAccountOptOut__c,CCPM_cartID__c  from lead where ownerid!= NULL And LastName = 'lastNameEten' limit 1];

        String strMessage = 'Yes';
        insertITRRecord('ITREten', strMessage,objLeadUpdated,LiveTextNumber1.Id);
        deleteUndeleteITRRecord(objLeadUpdated, LiveTextNumber1.Id);
        test.stopTest();
     }
     
     @isTest
    public static void testResponseScenarioNinten(){
    list<string> lststoreID=new list<string>();
        CCPM_testDataFactory.createCustomSetting();
        String strAcctUniqueId = 'ScenarioNten';
        CCPM_testDataFactory.createCustomer(1, strAcctUniqueId);
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        CCPM_testDataFactory.createStoreEmployee('ScNMgr','ScNRep','testComRID','ScNAgr', lststore[0].id );
        insertLead('lastNameEten', strAcctUniqueId, 'cartUniqueNten', 'Customer Abandoned Cart Digital', lststore[0].CCPM_storeID__c, lststore[0].id, SysAdminUser);
        
    }

    public static void deleteUndeleteITRRecord(Lead objLead, ID strLiveTextID)
    {
        LiveText__ITR_Message__c ITR=new LiveText__ITR_Message__c();
        ITR.LiveText__LiveText_Number__c= strLiveTextID;
        ITR.Name= 'TestITRTest';
        ITR.LiveText__Originating_Number__c='+14094165813';
        ITR.LiveText__Message__c= 'TestMessage';
        ITR.LiveText__Lead__c=objLead.id;
        insert ITR;
        delete ITR;
        undelete ITR;
        ITR.Name = 'TestITRUpdated';
        update ITR;
    }
}