/**
*@name          CCPM_clickToCallWebServiceTest
*@author        Sriraman Sridharan(Deloitte)
*@date          04/03/2018
@description    The Class is exposes a REST Endpoint Stub for POS to test their lead creation
@testClass      
@Endpoint       {Salesforce Base URL}/services/apexrest/api/v1/callDetailsCreation/
Modification    Log:
------------------------------------------------------------------------------------
Developer               					Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          04/19/2018              Original Version
*/
@isTest
public class CCPM_clickToCallWebServiceTest {
    public static testMethod void testPostMethod()
    {   
        Test.startTest();
        RestRequest request = new RestRequest();
        createCallDetailsRec();
        CCPM_clickToCallWebService.responseWrapper resWrapper = new CCPM_clickToCallWebService.responseWrapper();
       	List<responseWrapperLocal> lstresponseWrapper = new List<responseWrapperLocal>();
        String strIVR200 = 'sdf23r2';
        JSONGenerator JSONgen = createGenerateJSONRequest(strIVR200,true);
        String myString = JSONgen.getAsString();
        Blob myBlob = Blob.valueOf(myString);
        request.requestBody = myBlob;
        request.requestUri ='/services/apexrest/api/v1/callDetailsCreation/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        resWrapper = CCPM_clickToCallWebService.callDetailsCreation();
        System.debug('Response->'+CCPM_clickToCallWebService.callDetailsCreation()+resWrapper.StatusCode);
        System.assertEquals('200', resWrapper.StatusCode);
        //Failure case
        RestRequest requestFail = new RestRequest();
        String strIVR417 = 'sdasdaf23r2';
        JSONGenerator JSONgenFail = createGenerateJSONRequest(strIVR417,true);
        String myStringFail = JSONgenFail.getAsString();
        Blob myBlobFail = Blob.valueOf(myStringFail);
        requestFail.requestBody = myBlobFail;
        requestFail.requestUri ='/services/apexrest/api/v1/callDetailsCreation/';
        requestFail.httpMethod = 'POST';
        RestContext.request = requestFail;
        resWrapper = CCPM_clickToCallWebService.callDetailsCreation();
        System.debug('Response->'+CCPM_clickToCallWebService.callDetailsCreation()+resWrapper.StatusCode);
        System.assertEquals('417', resWrapper.StatusCode);
        //Failure case II
        RestRequest requestEmpty = new RestRequest();
        String strIVR4172 = 'sdasdaf23r2';
        JSONGenerator JSONgenEmpty = createGenerateJSONRequest(strIVR4172,false);
        String myStringEmpty = JSONgenEmpty.getAsString();
        Blob myBlobEmpty = Blob.valueOf(myStringEmpty);
        requestEmpty.requestBody = myBlobEmpty;
        requestEmpty.requestUri ='/services/apexrest/api/v1/callDetailsCreation/';
        requestEmpty.httpMethod = 'POST';
        RestContext.request = requestEmpty;
        resWrapper = CCPM_clickToCallWebService.callDetailsCreation();
        System.debug('Response->'+CCPM_clickToCallWebService.callDetailsCreation()+resWrapper.StatusCode);
        System.assertEquals('417', resWrapper.StatusCode);
        Test.stopTest();
    }
    public static void createCallDetailsRec(){
        CCPM_callDetails__c objCallDetails = new CCPM_callDetails__c();
        objCallDetails.CCPM_IVRID__c = 'sdf23r2';
        
        insert objCallDetails;
    }
    public static JSONGenerator createGenerateJSONRequest(String strIVR, Boolean IVRToBeAdded){
        JSONGenerator JSONgen = JSON.createGenerator(true);
        if(!IVRToBeAdded){
            JSONgen.writeStartObject();
            JSONgen.writeStringField('callEndTime', '2018-02-22 15:06:46');
            JSONgen.writeStringField('callLog', 'BUSY');
            JSONgen.writeStringField('callStartTime', '2018-02-22 15:06:25');
            JSONgen.writeStringField('correlationID', '4234234234');
            JSONgen.writeEndObject();
        }
        else{
            JSONgen.writeStartObject();
            JSONgen.writeStringField('callEndTime', '2018-02-22 15:06:46');
            JSONgen.writeStringField('callLog', 'BUSY');
            JSONgen.writeStringField('callStartTime', '2018-02-22 15:06:25');
            JSONgen.writeStringField('correlationID', '4234234234');
            JSONgen.writeStringField('IVRID', strIVR);
            JSONgen.writeEndObject();
        }
        
        return JSONgen;
    }
           /**
@author        Sriraman Sridharan (Deloitte)
@description   Wrapper/Inner Class for constructing Response structure
*/   
    
    //wrapper class for the response to an API request
    public class responseWrapperLocal {
        
        public String label {get;set;} 
        public String value {get;set;} 
        
        
        /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is a constructor for the wrapper class that sets default values to all its member variables
@param         None
@return        None
*/   
        public responseWrapperLocal() {
            //default all values
            this.label = '';
            this.value = '';
            }
    }
}