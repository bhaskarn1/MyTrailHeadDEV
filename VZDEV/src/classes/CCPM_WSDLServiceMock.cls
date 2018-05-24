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
global class CCPM_WSDLServiceMock implements WebServiceMock
{
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to send mock responses.
*/      
    global void doInvoke(
        Object stub, 
        Object request, 
        Map<String, Object> response,
        String endpoint, 
        String soapAction, 
        String requestName,
        String responseNS, 
        String responseName, 
        String responseType)
    {
        
        
        if(request instanceof sfdcproxyDvsVerizonwirelessCom.GetMtnDetail){
            sfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponse response_x = new sfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponse();
            response_x.return_x = new psfDvsSchemaMtndetail.mtnDetail();
            response.put('response_x', response_x);
            return;
        }
        else if(request instanceof sfdcproxyDvsVerizonwirelessCom.GetMtnInfo){
            sfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponse response_x = new sfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponse();
            response_x.return_x = new psfDvs.mtnInfo();
            response.put('response_x', response_x);
            return;
        }
        else if(request instanceof sfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiry){
            sfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiryResponse response_x = new sfdcproxyDvsVerizonwirelessCom.DNSFlagsInquiryResponse();
            response_x.return_x = new sfdcproxyDvsVerizonwirelessCom.return_element();
            response.put('response_x', response_x);
            return;
        }
        /*
        else if(request instanceof sfdcproxyDvsVerizonwirelessCom.GetMtnDetail){
            AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponseFuture response_x = new AsyncSfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponseFuture();
            response_x.return_x = new sfdcproxyDvsVerizonwirelessCom.GetMtnDetailResponse();
            response.put('response_x', response_x);
            return;
        }
*/
    }
}