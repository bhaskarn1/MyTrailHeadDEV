/**
*@name          CCPM_utilityTest 
*@author        Manjunath Keshava (Deloitte)
*@date          06/13/2017
@description    This is the Unit Test Class for the CCPM_utility Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    10/25/2017               			 Original Version
*/
@isTest
public class CCPM_utilityTest {
    
    static String eventTypeRec = schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event Type').getRecordTypeId();

    @isTest
    public static void BusinessHoursTest()
    {
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        CCPM_utility.getBusinessHours();
        CCPM_utility.mapGetBusinessHours();
        CCPM_utility.calculateTimeWithInBusinessHours(bhs[0], datetime.now());
    }
    
    @isTest
    public static  void calculateTimeWithInBusinessHoursTest()
    {
         CCPM_testDataFactory.createCustomSetting();
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        CCPM_utility.calculateTimeWithInBusinessHours(bhs[0], datetime.now().adddays(-4));
             CCPM_dataDictionary__c objDataDictionary = new CCPM_dataDictionary__c();
        objDataDictionary.CCPM_StringForexclusion__c='test';
        objDataDictionary.CCPM_IsActive__c=true;
        insert objDataDictionary;
        CCPM_utility.getStringFromDataDictionary();
         List<CCPM_EventSMSSetting__mdt> lstEventSMSSetting= [Select CCPM_JourneyMessageName__c,CCPM_LeadEventType__c, CCPM_LeadRecordType__c, 
                                                               CCPM_SmsFollowUpEndDate__c,CCPM_SmsFollowUpStartDate__c, CCPM_StartDate__c,
                                                               CCPM_EndDate__c,CCPM_CalculateSMSFollowup__c
                                                               From   CCPM_EventSMSSetting__mdt ];
        List<CCPM_EventSMSSetting__mdt> lstNewEventSMSSetting=( List<CCPM_EventSMSSetting__mdt>)Json.deserialize('[{"CCPM_JourneyMessageName__c":"Pixel - future device","CCPM_LeadEventType__c":"Pixel - future device","CCPM_LeadRecordType__c":"Prospect","CCPM_SmsFollowUpStartDate__c":"2017-10-26 18:30:00","CCPM_SmsFollowUpEndDate__c":"2017-10-26 23:59:59"}]', list<CCPM_EventSMSSetting__mdt>.class);        
  			//CCPM_utility.mapGetEventSMSSetting();
        //commented for 10/30 deployment
       // CCPM_utility.getSetFromLabel('strCustom,Label', ',');
    }
    
    @isTest
    public static void TelesaleTest()
    {
        group objgroup = new group();
        objgroup.DeveloperName='teleSalesTtestGroup';
        objgroup.name='teleSalesTtestGroup';
        insert objgroup;
        Group objTeleSale= [Select id from Group where DeveloperName ='teleSalesTtestGroup'];
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='CCPM Sales Rep' Limit 1]; 
        User u = new User(Alias = 'tstusr1', Email='standardtestuser1412@testorgUAT.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',firstname='a', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsActive = True,
                          TimeZoneSidKey='America/Los_Angeles', UserName= 'makeUnique'+'stest@testorg.com',mobilephone='3214249106');             
            insert u;
        GroupMember gm = new GroupMember();
          gm.GroupId = objTeleSale.id;
          gm.UserOrGroupId = u.id;
        insert gm;
        system.runAs(u)
        {
                    //commented for 10/30 deployment
        //ccpm_utility.isCurrentUserTelesalesUser();
        }
        ccpm_utility.populateQueueIds();  
    }
    
    @isTest
    public static void createRecordsForSmsMessageObjectTest()
    {
          CCPM_testdataFactory.createCustomSetting();
        list<CCPM_Store__c> lststore= CCPM_testDataFactory.createStore(1);
        Lead objCart=new Lead();
            objCart.LastName='testsample';
            objCart.FirstName='Inactive test';
            objCart.Status='New';
            objCart.Company = '1';  
        objcart.CCPM_accountUniqueID__c='23467';
        		objcart.Store__c=lststore[0].id;
               // objCart.CCPM_eventType__c = 'SMB';
                objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
            objCart.CCPM_mobileNumber__c = '3213187287';
            objCart.CCPM_email__c ='test@gmail.com';
            objCart.CCPM_confirmEmail__c='test@gmail.com';
            datetime date1=Datetime.now();
            objCart.CCPM_createdDate__c=date1.addHours(-5);
            objCart.CCPM_SMSLegalOptIn__c =true;
            objCart.CCPM_confirmMTN__c= '3213187287';
            objCart.RecordTypeId = CCPM_staticConstants.strProspectAbandonedCartRecordTypeID;
        	objCart.ccpm_leadtype__c = 'Prospect Abandoned Cart Retail';
        	insert objCart;
        system.debug(objcart.Store__c);
       lead newobjlead= [select id,name,store__c,CCPM_storeTerritory__c,CCPM_storeDistrict__c,CCPM_storeMarket__c from lead where id=:objCart.id];
        system.debug(newobjlead.store__c);
        CCPM_suppressOutboundSMS__c objsuppress = new CCPM_suppressOutboundSMS__c();
        objsuppress.Name='test';
        objsuppress.IsActive__c=true;
        objsuppress.Territory__c='testTerritory';
        objsuppress.District__c='testDistrict';
        insert objsuppress;
        map<string,CCPM_suppressOutboundSMS__c> mapsupress = new map<string,CCPM_suppressOutboundSMS__c>();
        mapsupress.put('test', objsuppress);
        CCPM_staticConstants.mapSuppressOutboundMessage=mapsupress;
        CCPM_utility.createRecordsForSmsMessageObject(objCart,'hi','3473483204','NewProspectSMS','outbound',datetime.now(),'+17206864418');
        list<Account> lstAcc = CCPM_testDataFactory.createCustomer(1, 'appendUnique');
        lstAcc[0].CCPM_accountUniqueID__c='23467';
        update lstAcc;
        map<string,Account> mapAcc = new  map<string,Account>();
        mapAcc.put(objCart.CCPM_accountUniqueID__c, lstAcc[0]);
        businesshours objHrs = ccpm_utility.getBusinessHrForLead(objCart);

    }
    
    static testmethod void testgetMapLeadTypeMapEvntLstSmsTemp() {
        
        list<user> lstUser = ccpm_testdatautil.createTestUsers('CCPM Sales Rep', 1);
        insert lstUser;
        
        list<ccpm_Store__c> lstStore = ccpm_testDataUtil.createStore(1);
        lststore[0].ccpm_market__c = 'Great Lakes';
        lstStore[0].CCPM_territory__c = 'Southern California';
        lstStore[0].ccpm_district__c = 'DS04-Scottsdale';
        insert lstStore;
        
        list<ccpm_storeEmployee__c> lstStEmp = ccpm_testDataUtil.createStoreEmployee(1, lstStore[0].id, lstUser[0].id, 'Store Manager');
        insert lstStEmp;
        
        campaign objCmp = new campaign();
        objCmp.recordTypeId = eventTypeRec;
        objCmp.CCPM_uniqueName__c = 'SMB';
        objCmp.CCPM_eventStartDate__c = '2016-02-02 00:00:00';
        objCmp.CCPM_eventEndDate__c = '2099-12-12 00:00:00';
        objCmp.CCPM_eventSMSFollowUpEndDate__c = '2099-12-12 00:00:00';
        objCmp.CCPM_eventSMSFollowUpStartDate__c = '2016-02-02 00:00:00';
        objCmp.IsActive = true;
        objCmp.Name = 'SMB';
        objCmp.CCPM_eventLabel__c = 'SMB';
        objCmp.CCPM_eventOrder__c = 1;
        objCmp.CCPM_leadCustomerType__c = 'Customer;Prospect';
        insert objCmp;
        
        ccpm_segmentation__c objSeg = new ccpm_segmentation__c();
        objSeg.CCPM_campaign__c = objCmp.Id;
        objSeg.CCPM_channels__c = 'Retail;Telesales';
        objSeg.CCPM_isActive__c = true;
        objSeg.CCPM_markets__c = 'Great Lakes;North Central;North East;Pacific;South Central;South East';
        objSeg.CCPM_territories__c = Label.ccpm_territories;
        objSeg.CCPM_districts1__c = Label.ccpm_districts1;
        objSeg.CCPM_districts2__c = Label.ccpm_districts2;
        objSeg.CCPM_districts3__c = Label.ccpm_districts3;
        insert objSeg;
        
        ccpm_smsTemplate__c objTemp = new ccpm_smsTemplate__c();
        objTemp.CCPM_isActive__c = true;
        objTemp.CCPM_segmentation__c = objSeg.Id;
        objTemp.CCPM_messageType__c = 'NewProspectSMS1';
        objTemp.CCPM_eventMessageStartDate__c='2016-02-02 00:00:00';
        objTemp.CCPM_eventMessageEndDate__c = '2099-12-12 00:00:00';
        objTemp.CCPM_customerMessage__c = 'Hello';
        objTemp.CCPM_prospectMessage__c = 'Hello';
        insert objTemp;
        test.starttest();
        map<String,map<String,list<CCPM_segmentation__c>>> retMap = ccpm_utility.getMapLeadTypeMapEvntLstSmsTemp();
        system.assert(retMap != null);
        test.stopTest();
    }
    
    static testMethod void testTimeZone() {
        test.startTest();
        datetime retDate = ccpm_utility.getDtTimeForTimeZone('2018-03-26 00:00:00','EST');
        system.assert(retDate != null);
        datetime retdT1 = ccpm_utility.getNowInTimeZone('EST');
        system.assert(retdT1 != null);
        test.stoptest();
    }
    
    static testMethod void testCheckField(){
        test.startTest();
        Boolean retBool = ccpm_utility.checkField('test','test');
        set<String> setStr = ccpm_utility.setGetSMSStatusTOExclude();
        system.assertequals(true,retBool);
        list<String> lstStr = ccpm_utility.getListFromString('test', 'test');
        system.assert(lststr!=null);
        test.stopTest();
    }
    
}