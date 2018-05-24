/**
*@name          CCPM_clickToCallWebService
*@author        Sriraman Sridharan(Deloitte)
*@date          04/03/2018
@description    The Class is exposes a REST Endpoint Stub for POS to test their lead creation
@testClass      
@Endpoint       {Salesforce Base URL}/services/apexrest/api/v1/callDetailsCreation/
Modification    Log:
------------------------------------------------------------------------------------
Developer               					Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          04/03/2018              Original Version
*/

//Defining the REST resource by providing URLMapping
@RestResource(urlMapping='/api/v1/callDetailsCreation/*') 
global class CCPM_clickToCallWebService {
    
    /**
@author        Sriraman Sridharan (Deloitte) 
@description   This method returns a success response code 
@param         None
@return        Response Wrapper object
*/ 
    //HttpPost annotation exposes the method as a REST resource and called when an HTTP POST request is sent
    @HttpPost 
    global static responseWrapper callDetailsCreation() {
        //the RestRequest for the Apex REST method
        RestRequest req = RestContext.request; 
        //responseWrapper object for API response
        responseWrapper responseJSON = new responseWrapper(); 
        //Declarations
        String strJSONBody;
        Boolean boolErrorCheck = False;
        Map<String, Object> mapJSONRequestBody = null;
        //Extract the request body
        if(req != null && req.requestBody != null){strJSONBody = req.requestBody.toString();} //the body of the request
        System.debug('@@@strJSONBody : ' + strJSONBody);
        if(String.isNotBlank(strJSONBody)){mapJSONRequestBody = (Map<String, Object>)JSON.deserializeUntyped(strJSONBody);}
        system.debug('@@@mapJSONRequestBody ' + mapJSONRequestBody);
        if(mapJSONRequestBody != null && mapJSONRequestBody.containsKey('IVRID')){
            String strIvrId = (String)mapJSONRequestBody.get('IVRID');
            if(String.isNotBlank(strIvrId)){
                try{
                    CCPM_callDetails__c objCallDetails = [Select CCPM_IVRID__c,CCPM_callEndTime__c,CCPM_callStartTime__c,CCPM_callDuration__c,CCPM_callLog__c,CCPM_correlationID__c,CCPM_callStatus__c from CCPM_callDetails__c where CCPM_IVRID__c =:strIvrId ];
                    system.debug('@@@objCallDetails : ' + objCallDetails);
                    if(objCallDetails != null){
                        if(mapJSONRequestBody.containsKey('IVRID')){objCallDetails.CCPM_IVRID__c = (String)mapJSONRequestBody.get('IVRID');}
                        if(mapJSONRequestBody.containsKey('bridgeStatus')){objCallDetails.CCPM_callLog__c = (String)mapJSONRequestBody.get('bridgeStatus');}
                        //  system.debug('@@@ : ' + (String)mapJSONRequestBody.get('callStartTime'));
                        //  system.debug('@@@ : ' + DateTime.valueOf((String)mapJSONRequestBody.get('callStartTime')));
                        // system.debug('@@@ : ' + DateTime.valueOf(DateTime.valueOf((String)mapJSONRequestBody.get('callStartTime')).format('yyyy-MM-dd HH:mm:ss')));   
                        if(mapJSONRequestBody.containsKey('callStartTime')){objCallDetails.CCPM_callStartTime__c = DateTime.valueOf(DateTime.valueOf((String)mapJSONRequestBody.get('callStartTime')).format('yyyy-MM-dd HH:mm:ss'));}
                        if(mapJSONRequestBody.containsKey('callEndTime')){objCallDetails.CCPM_callEndTime__c = DateTime.valueOf(DateTime.valueOf((String)mapJSONRequestBody.get('callEndTime')).format('yyyy-MM-dd HH:mm:ss'));}
                        if(mapJSONRequestBody.containsKey('correlationID')){objCallDetails.CCPM_correlationID__c = (String)mapJSONRequestBody.get('correlationID');}
                        if(mapJSONRequestBody.containsKey('callLog')){objCallDetails.CCPM_callLog__c = (String)mapJSONRequestBody.get('callLog');}
                        objCallDetails.CCPM_callStatus__c = 'Call Complete';
                        
                        //Update record
                        Update objCallDetails;
                    }
                }
                Catch(Exception e)
                {
                    boolErrorCheck = True;
                    LOG_LogMessage__c objLogError = CCPM_utility.logMessage(e,'Error','CCPM_clickToCallWebService','callDetailsCreation','Exception thrown while querying/ updating call details','');
                	insert objLogError;
                }
            }
        }
        else{
            boolErrorCheck = True;
        }
        //Validate if Request body and construct the responses
        if(boolErrorCheck){ responseJSON=constructJSONResp('Record Not Found in SFDC','417'); }
        else if(!String.isBlank(strJSONBody)) { responseJSON=constructJSONResp('SUCCESS','200'); }
        else{ responseJSON=constructJSONResp('FAIL','417'); }
        //Return the respective response
        return responseJSON;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method constructs the JSONRepsonse to Calling server
@param         Member Variables of class responseWrapper
@return        Object of class responseWrapper
*/ 
    public static responseWrapper constructJSONResp(String strMessage,String strStatusCode)
    {
        responseWrapper objresponseWrapper = new responseWrapper();
        objresponseWrapper.Message = strMessage;
        objresponseWrapper.StatusCode = strStatusCode;
        return objresponseWrapper;
    }
/**
@author        Sriraman Sridharan (Deloitte)
@description   Wrapper/Inner Class for constructing Response structure
*/   
    //wrapper class for the response to an API request
    global class responseWrapper {
       	global String Message {get;set;} 
        global String StatusCode {get;set;}   
/**
@author        Sriraman Sridharan (Deloitte)
@description   This method is a constructor for the wrapper class that sets default values to all its member variables
@param         None
@return        None
*/ 
        global responseWrapper() {
            //default all values
            this.Message = '';
            this.StatusCode = '';
        }
    }
    
}