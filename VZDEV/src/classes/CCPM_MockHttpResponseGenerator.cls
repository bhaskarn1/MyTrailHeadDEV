/**
*@name          CCPM_MockHttpResponseGenerator 
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/18/2017
@description    This is the Unit Test Class for the HttpCallOutUtility Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/18/2017          Original Version
*/

@isTest
global class CCPM_MockHttpResponseGenerator implements HttpCalloutMock
{
   global HTTPResponse respond(HTTPRequest req)
    {
        // System.assertEquals('GET', req.getMethod());
        // Create a fake response
        HttpResponse objHttpRes = new HttpResponse();
        objHttpRes.setHeader('Content-Type', 'application/json');
        objHttpRes.setBody('{"foo":"bar"}');
        objHttpRes.setStatusCode(200);
        return objHttpRes;
    }

}