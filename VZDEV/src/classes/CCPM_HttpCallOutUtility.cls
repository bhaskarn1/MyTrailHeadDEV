/**
*@name          CCPM_HttpCallOutUtility
*@author        Brigadesh Chandrasekar (Deloitte)
*@date          05/07/2017
@description    Class to make http callout to HeyWire end point
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date                                Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)    05/07/2017                          Original Version
*/
public class CCPM_HttpCallOutUtility {
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method makes the callout for each record obtained from the batch.
*@Parameter		SMS body and associated To Phone Number
*@return        HttpResponse
*/ 
    public static HttpResponse createHeyWireHttpRequest(string strSMSBody,string strMTN,string strLivetextPhoneNumber)
    {
        //Composing the required Request
        HttpRequest req=new HttpRequest();
        req.setHeader('AdminAccountId',CCPM_staticConstants.strAccountID);
        req.setHeader('AdminPassword',CCPM_staticConstants.strAdminPassword);
        req.setHeader('Content-Length', '0');
        req.setMethod('POST');
        //Setting the Endpoint URL obtained from Custom Settings
        //strMTN = strMTN.re
        string strliveTextNumber= strLivetextPhoneNumber.right(10);
        list<String> lstEndPointUrl=CCPM_staticConstants.strEndPointURL.split('-'); 
        System.debug(lstEndPointUrl);
        string strEndPointUrl = lstEndPointUrl[0]+strliveTextNumber+lstEndPointUrl[2]+strMTN+lstEndPointUrl[4]+strSMSBody;
        //string strEndPointUrl = lstEndPointUrl[0]+strMTN+lstEndPointUrl[2]+strSMSBody;
        System.debug('#EndPoint URL-> '+strEndPointUrl);
        req.setEndpoint(strEndPointUrl);
        
        //Creating a new HTTP instance
        Http http=new Http();
        try {
            //Making the callout to Heywire API
            system.debug('# Request posted-> '+req);
            //Obtaining the Response by making a callout to the API
            HTTPResponse res = http.send(req);            
            return res;
            
            
        } catch(System.CalloutException e) {  
            //Error Handling for Response
            system.debug('the end'+e);
            CCPM_LogMessageUtility.logMessage(e,'CCPM_heywireCallOut','Call out to Heywire API','Exception thrown because of Callout Exception',true);
            return null;
        } 
        
   }
    
      
}