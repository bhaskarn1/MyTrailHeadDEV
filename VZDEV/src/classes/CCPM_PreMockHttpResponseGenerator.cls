/**
*@name          CCPM_PreMockHttpResponseGenerator 
*@author        Manjunath Keshava (Deloitte)
*@date          06/09/2017
@description    This is the Unit Test Class for the SendPreDefinedSmsTest  Class 
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                         Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    06/09/2017                            Original Version
*/

global class CCPM_PreMockHttpResponseGenerator implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req)
    {
        // System.assertEquals('GET', req.getMethod());
        // Create a fake response
        HttpResponse objHttpRes = new HttpResponse();
        objHttpRes.setHeader('Content-Type', 'application/json');
        objHttpRes.setBody('{"foo":"bar"}');
        objHttpRes.setStatusCode(204);
        return objHttpRes;
    }

}