/**
*@name          CCPM_POSReturnEventTypesWebService
*@author        Sriraman Sridharan(Deloitte)
*@date          04/04/2018
@description    The Class is exposes a REST Endpoint Stub for POS to test their lead creation
@testClass      
@Endpoint       {Salesforce Base URL}/services/apexrest/api/v1/getEventTypes
Modification    Log:
------------------------------------------------------------------------------------
Developer               					Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          04/19/2018              Original Version
*/
@isTest
public class CCPM_POSReturnEventTypesWebServiceTest { 
    static String eventTypeRec = schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event Type').getRecordTypeId();
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
        //objTemp.CCPM_messageType__c = 'NewProspectSMS1';
        objTemp.CCPM_eventMessageStartDate__c='2016-02-02 00:00:00';
        objTemp.CCPM_eventMessageEndDate__c = '2099-12-12 00:00:00';
        objTemp.CCPM_customerMessage__c = 'Hello';
        objTemp.CCPM_prospectMessage__c = 'Hello';
        insert objTemp; 
        test.starttest();
        map<String,map<String,list<ccpm_SMSTemplate__c>>> retMap = ccpm_eventSMSUtil.getMapLeadTypeMapEvntLstSmsTemp(lstuser[0].id);
        system.assert(retMap != null);
       	
        System.runAs(lstuser[0]){
               RestRequest req = new RestRequest(); 
               RestResponse res = new RestResponse();
               req.requestURI = '/services/apexrest/api/v1/getEventTypes'; 
               req.params.put('Leadtype', 'Prospect');
               req.httpMethod = 'GET';
               req.addHeader('Content-Type', 'application/json'); 
               RestContext.request = req;
               RestContext.response = res;
               System.debug(CCPM_POSReturnEventTypesWebService.getEventTypes());
           }
        System.runAs(lstuser[0]){
               RestRequest req = new RestRequest(); 
               RestResponse res = new RestResponse();
               req.requestURI = '/services/apexrest/api/v1/getEventTypes'; 
               req.params.put('Leadtype', 'Manual Lead');
               req.httpMethod = 'GET';
               req.addHeader('Content-Type', 'application/json'); 
               RestContext.request = req;
               RestContext.response = res;
               System.debug(CCPM_POSReturnEventTypesWebService.getEventTypes());
           }
   		Test.stopTest();   
    }
           /**
@author        Sriraman Sridharan (Deloitte)
@description   Wrapper/Inner Class for constructing Response structure
*/   
    
    //wrapper class for the response to an API request
    public class responseWrapper {
        
        public String label {get;set;} 
        public String value {get;set;} 
        
        
        /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is a constructor for the wrapper class that sets default values to all its member variables
@param         None
@return        None
*/   
        public responseWrapper() {
            //default all values
            this.label = '';
            this.value = '';
            }
    }
}