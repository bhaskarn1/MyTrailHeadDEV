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
Sriraman Sridharan(Deloitte)          04/04/2018              Original Version
*/
//Defining the REST resource by providing URLMapping
@RestResource(urlMapping='/api/v1/getEventTypes/*') 
global class CCPM_POSReturnEventTypesWebService {
/**
@author        Sriraman Sridharan (Deloitte)  
@description   This method returns a success response code 
@param         None
@return        Response Wrapper object
*/ 
    //HttpGET annotation exposes the method as a REST resource and called when an HTTP POST request is sent
    @HttpGET
    global static map<string,List<responseWrapper>> getEventTypes() {
        //the RestRequest for the Apex REST method
        RestRequest req = RestContext.request; 
        map<string,List<responseWrapper>> mapToReturn = new map<string,List<responseWrapper>>();
        List<responseWrapper> lstresponseWrapper = new List<responseWrapper>();
        String strRepID = UserInfo.getUserId();
        String strLeadType = req.params.get('Leadtype');
        String strLeadTpyeMapping;
        if(strLeadType == Label.CCPM_leadTypeManualLead){
            strLeadTpyeMapping = 'Customer';
        }
        else if(strLeadType == Label.CCPM_leadProspectRT){
            strLeadTpyeMapping = Label.CCPM_leadProspectRT;
        }
        Map<String, Map<String, List<CCPM_smsTemplate__c>>> mapLeadTypeEvntTypeLstSmsTempMap = null;
        if(String.isNotBlank(strRepID)){
            mapLeadTypeEvntTypeLstSmsTempMap = CCPM_eventSMSUtil.getMapLeadTypeMapEvntLstSmsTemp(strRepID);
        }
        If(mapLeadTypeEvntTypeLstSmsTempMap != null && String.isNotBlank(strLeadTpyeMapping) && mapLeadTypeEvntTypeLstSmsTempMap.containsKey(strLeadTpyeMapping) 
           && mapLeadTypeEvntTypeLstSmsTempMap.get(strLeadTpyeMapping) != null && CCPM_Collection.isNotNullEmpty(mapLeadTypeEvntTypeLstSmsTempMap.get(strLeadTpyeMapping).KeySet())){
               for(String strEventName : mapLeadTypeEvntTypeLstSmsTempMap.get(strLeadTpyeMapping).KeySet()){
                   List<String> lstString = strEventName.split('_',2);
                   if(CCPM_Collection.isNotNullEmpty(lstString)){
                       responseWrapper objresponseWrapper = new responseWrapper();
                       if(String.isNotBlank(lstString[0])){objresponseWrapper.label = lstString[0];}
                       if(String.isNotBlank(lstString[1])){objresponseWrapper.value = lstString[1];}
                       
                       lstresponseWrapper.add(objresponseWrapper);
                   }
               }
           }

        mapToReturn.put('Events',lstresponseWrapper );
        return mapToReturn;
    }
  
       /**
@author        Sriraman Sridharan (Deloitte)
@description   Wrapper/Inner Class for constructing Response structure
*/   
    
    //wrapper class for the response to an API request
    global class responseWrapper {
        
        global String label {get;set;} 
        global String value {get;set;} 
        
        
        /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is a constructor for the wrapper class that sets default values to all its member variables
@param         None
@return        None
*/   
        global responseWrapper() {
            //default all values
            this.label = '';
            this.value = '';
            }
    }
}