/**
*@name          CCPM_WebServiceMockGeneratorTest 
*@author        Manjunath Keshava (Deloitte)
*@date          07/25/2017
@description    This is the Unit Test Class for the CCPM_getProspectAccountInformation Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    07/25/2017               			 Original Version
*/
@isTest
global class CCPM_WebServiceMockThree implements WebServiceMock
{
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
                       sfdcproxyDvsVerizonwirelessCom.VisionDvsPort objSfVd = new sfdcproxyDvsVerizonwirelessCom.VisionDvsPort();
              sfdcproxyDvsVerizonwirelessCom.GetMtnInfo objMtnInfo = new sfdcproxyDvsVerizonwirelessCom.GetMtnInfo();
        	sfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponse objRespElement = new sfdcproxyDvsVerizonwirelessCom.GetMtnInfoResponse();
                      psfDvs.mtnInfo objResMtn = new  psfDvs.mtnInfo();
               psfDvsSchemaMtndetail.mtnDetail objNewResMtn = new psfDvsSchemaMtndetail.mtnDetail();
               psfDvsSchemaDnsflagsinquiry.DnsFlags objDnsMtn = new psfDvsSchemaDnsflagsinquiry.DnsFlags();
               /*objresmtn.mtn='7036159022';
               objDnsMtn.teleMarketInd='N';
               objDnsMtn.txtMsgInd='Y';*/
               objResMtn.mtnDetail=objNewResMtn;
               objResMtn.dnsFlags=objDnsMtn;
                objRespElement.return_X=objResMtn;
               response.put('response_x',objRespElement);
       }
}