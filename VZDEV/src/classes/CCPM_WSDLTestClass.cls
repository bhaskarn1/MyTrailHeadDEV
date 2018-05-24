/**
*@name          CCPM_WSDLTestClass
*@author        Sriraman Sridharan (Deloitte)
*@date          10/02/2017
@description    The Test Class is meant to unit test the wsdl2apex classes
Modification    Log:
------------------------------------------------------------------------------------
Developer               				Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          10/02/2017              Original Version
*/
@isTest
private with sharing class CCPM_WSDLTestClass {
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to cover types for sfdcproxyDvsVerizonwirelessCom class.
*/   
    @isTest
    static void coverTypesForsfdcproxyDvsVerizonwirelessCom(){
        CCPM_testDataFactory.createCustomSetting();
        Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        new sfdcproxyDvsVerizonwirelessCom.service_element();
        new sfdcproxyDvsVerizonwirelessCom.GetMtnDetail();
        new sfdcproxyDvsVerizonwirelessCom.GetMtnInfo();
        new sfdcproxyDvsVerizonwirelessCom.return_element();
        new sfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiry();
        new sfdcproxyDvsVerizonwirelessCom.VisionDvsPort();
        new sfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiryResponse();
        new sfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponse();
        new sfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponse();
        sfdcproxyDvsVerizonwirelessCom.VisionDvsPort objVisionDvsPort = new sfdcproxyDvsVerizonwirelessCom.VisionDvsPort();
        
        Test.startTest();
        psfDvsSchemaMtndetail.mtnDetail objmtnDetail = objVisionDvsPort.GetMtnDetail(null);
        //Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        psfDvs.mtnInfo objmtnInfo = objVisionDvsPort.GetMtnInfo(null);
        //Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        sfdcproxyDvsVerizonwirelessCom.return_element objreturn_element = objVisionDvsPort.DNSFlagsInquiry(null,null);
        Test.stopTest();
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to cover types for CCPM_PicklistEntryWrapper class.
*/  
    @isTest
    static void coverTypesForCCPM_PicklistEntryWrapper(){
        Test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        CCPM_PicklistEntryWrapper objCCPM_PicklistEntryWrapper = new CCPM_PicklistEntryWrapper();
        objCCPM_PicklistEntryWrapper.active = 'Test';
        objCCPM_PicklistEntryWrapper.defaultValue = 'Test';
        objCCPM_PicklistEntryWrapper.label = 'Test';
        objCCPM_PicklistEntryWrapper.validFor = 'Test';
        objCCPM_PicklistEntryWrapper.value = 'Test';
        Test.stopTest();
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to cover types for psfDvsSchemaAddressvalidate class.
*/
    @isTest
    static void coverTypesForpsfDvsSchemaAddressvalidate(){
        Test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        
        new psfDvsSchemaAddressvalidate.Address();
        new psfDvsSchemaAddressvalidate.AddressValidateResponse_element();
        new psfDvsSchemaAddressvalidate.specialDistrictInfoItem_element();
        new psfDvsSchemaAddressvalidate.AddressValidateRequest();
        new psfDvsSchemaAddressvalidate.AddressValidateService();
        new psfDvsSchemaAddressvalidate.AddressValidateHeader();
        new psfDvsSchemaAddressvalidate.AddressValidateBody();
        new psfDvsSchemaAddressvalidate.serviceResponse_element();
        new psfDvsSchemaAddressvalidate.specialDistrictInfoList_element();
        Test.stopTest();
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to cover types for psfDvsSchemaDnsflagsinquiry class.
*/    
    @isTest
    static void coverTypesForpsfDvsSchemaDnsflagsinquiry(){
        Test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        
        new psfDvsSchemaDnsflagsinquiry.serviceBody();
        new psfDvsSchemaDnsflagsinquiry.mtnDnsFlagsList_element();
        new psfDvsSchemaDnsflagsinquiry.multiChannelMarketingInfo();
        new psfDvsSchemaDnsflagsinquiry.specialOfferList();
        new psfDvsSchemaDnsflagsinquiry.serviceRequest();
        new psfDvsSchemaDnsflagsinquiry.serviceResponse();
        new psfDvsSchemaDnsflagsinquiry.DnsFlags();
        new psfDvsSchemaDnsflagsinquiry.ServiceHeader();
        new psfDvsSchemaDnsflagsinquiry.SpecialOfferItem();
        new psfDvsSchemaDnsflagsinquiry.mtnList();
        new psfDvsSchemaDnsflagsinquiry.mtnDnsFlagsItem();
        Test.stopTest();
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to cover types for psfDvsSchemaAutoremarkview class.
*/     
    @isTest
    static void coverTypesForpsfDvsSchemaAutoremarkview(){
        Test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        
        new psfDvsSchemaAutoremarkview.AutoRemarkViewBody();
        new psfDvsSchemaAutoremarkview.AutoRemarkViewService();
        new psfDvsSchemaAutoremarkview.AutoRemarkViewRequest();
        new psfDvsSchemaAutoremarkview.billAccountRemarkInfo();
        new psfDvsSchemaAutoremarkview.AutoRemarkViewResponse();
        new psfDvsSchemaAutoremarkview.keywordList_element();
        new psfDvsSchemaAutoremarkview.AutoRemarkViewHeader();
        Test.stopTest();
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to cover types for psfDvsSchemaUpdatedns class.
*/     
    @isTest
    static void coverTypesForpsfDvsSchemaUpdatedns(){
        Test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        
        new psfDvsSchemaUpdatedns.dnsFlagsList_element();
        new psfDvsSchemaUpdatedns.multiChannelMarketingInfo_element();
        new psfDvsSchemaUpdatedns.UpdateDnsResponse_element();
        new psfDvsSchemaUpdatedns.UpdateDnsRequest();
        new psfDvsSchemaUpdatedns.UpdateDnsService();
        new psfDvsSchemaUpdatedns.DnsFlags();
        new psfDvsSchemaUpdatedns.UpdateDnsHeader();
        new psfDvsSchemaUpdatedns.serviceResponse_element();
        new psfDvsSchemaUpdatedns.UpdateDnsBody();
        Test.stopTest();
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to cover types for AsyncSfdcproxyDvsVerizonwirelessCom class.
*/     
    @isTest
    Public static void coverTypesForAsyncSfdcproxyDvsVerizonwirelessCom(){
        Test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        /*
        AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponseFuture objGetMtnDetailResponseFuture = new AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponseFuture();
        AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponseFuture objGetMtnInfoResponseFuture = new AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponseFuture();
        AsyncSfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiryResponseFuture objDNSFlagsInquiryResponseFuture = new AsyncSfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiryResponseFuture();
        AsyncSfdcproxyDvsVerizonwirelessCom.AsyncVisionDvsPort objAsyncVisionDvsPort = new AsyncSfdcproxyDvsVerizonwirelessCom.AsyncVisionDvsPort();
        //new CCPM_PicklistEntryWrapper.active;
        
        psfDvsSchemaMtndetail.mtnDetail objmtnDetail = objGetMtnDetailResponseFuture.getValue();
        psfDvs.mtnInfo objmtnInfo = objGetMtnInfoResponseFuture.getValue();
        sfdcproxyDvsVerizonwirelessCom.return_element objreturn_element = objDNSFlagsInquiryResponseFuture.getValue();
        
        AsyncSfdcproxyDvsVerizonwirelessCom.AsyncVisionDvsPort objVisionDvsPort = new AsyncSfdcproxyDvsVerizonwirelessCom.AsyncVisionDvsPort();
        
        Test.startTest();
        
        AsyncSfdcproxyDvsVerizonwirelessCom.AsyncVisionDvsPort objVisionDvsPort = new AsyncSfdcproxyDvsVerizonwirelessCom.AsyncVisionDvsPort();
        //Test.setContinuationResponse(requestLabel, new sfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponse);
        AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponseFuture objGetMtnDetailResponseFuture = objVisionDvsPort.beginGetMtnDetail(null, null);
        //Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponseFuture objGetMtnInfoResponseFuture = objVisionDvsPort.beginGetMtnInfo(null, null);
        //Test.setMock(WebServiceMock.class, new CCPM_WSDLServiceMock());
        AsyncSfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiryResponseFuture objDNSFlagsInquiryResponseFuture = objVisionDvsPort.beginDNSFlagsInquiry(null,null,null);
        */
		Test.stopTest();
    }
    
}