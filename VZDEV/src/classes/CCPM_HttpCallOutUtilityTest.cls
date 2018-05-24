/**
*@name          CCPM_HttpCallOutUtilityTest 
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
private class CCPM_HttpCallOutUtilityTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());

        CCPM_testDataFactory.createCustomSetting();
        String strSMSBody = 'Test Message Body from Mock Test Class';
        String strMTN = '9999999999';
        String strLiveTextNumber=CCPM_staticConstants.strLivetextPhoneNumber;
        
        HttpResponse objHttpRes = CCPM_HttpCallOutUtility.createHeyWireHttpRequest(strSMSBody,strMTN,strLiveTextNumber);
        // Verify response received contains fake values
        if(objHttpRes != null){
            String strContentType = objHttpRes.getHeader('Content-Type');
            System.assert(strContentType == 'application/json');
            String strActualValue = objHttpRes.getBody();
            String strExpectedValue = '{"foo":"bar"}';
            System.assertEquals(strActualValue, strExpectedValue);
            System.assertEquals(200, objHttpRes.getStatusCode());    
        }
    }
}