/**
*@name          CCPM_sendMessagesToCustomerCentralRest
*@author        Paras Shah (Deloitte)
*@date          05/12/2017
*@description   For SMS Interaction history
*@testClass     CCPM_sendSMSToCustomerCentralRestTest

------------------------------------------------------------------------------------
Developer                        Date               Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)             05/12/2017         Original Version  
Tanweer Maredia(Deloitte)        05/17/2017         Create GetCustomerInteraction and wrapper class for resquest
*/

/*
* Webservice will be created to send customer contact central all interaction sent to customers and prospects on Verizon's behalf
*  By calling Rest API with GET Protocal that return all task and lead attribute in json format by using wrapper class 
*/
@RestResource(urlMapping='/getAllCustomerCommunication/*')
global with sharing class CCPM_sendMessagesToCustomerCentralRest {
    
    @HttpGet
    global static List<CCPM_sendSMSToCustomerCentralRestWrapper> getCustomerInteractions() {
        
        
        //Returns the RestRequest object for our Apex REST method.  
        RestRequest req = RestContext.request;
        //Returns the RestResponse object for our Apex REST method.  
        RestResponse res = RestContext.response;
        List<Task> lstTaskResult = new  List<Task>();
        String customerMTN ='';
        //Retrieve the parameter sent in the URL
        // Given Test only runs for test class becuase of MTN is encrpytion fields could not found by SOSL query 
        if(Test.isRunningTest()){
   			//Getting MTN number from static constants
            customerMTN=CCPM_staticConstants.strCustomerMTN;
        }else{
            customerMTN = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        }
        // Creating the initialized list of wrapper class to create response body
        List<CCPM_sendSMSToCustomerCentralRestWrapper> responsBodyOfCustomerCentralActivity = new   List<CCPM_sendSMSToCustomerCentralRestWrapper>();
        List<lead> leadsOfAssociateMTN= new List<lead>();
        CCPM_sendSMSToCustomerCentralRestWrapper taskMessagesFromLead = new CCPM_sendSMSToCustomerCentralRestWrapper();
        try{
            //Finding encrypting MTN and account field from SOSL queury by getting lead id  
            List<List<lead>> lstIDFromCustomerMTN= [FIND :customerMTN IN PHONE FIELDS RETURNING Lead(Id,CCPM_accountNumber__c, CCPM_mobileNumber__c )]; 
            //Given Statement only runs when unit testng is running because of SOSL encryption limitation that could not find encrypted fields
            if(Test.isRunningTest()){
                Lead testLead =[SELECT Id, CCPM_accountNumber__c, CCPM_mobileNumber__c FROM Lead WHERE Firstname = 'KimerTest'];
                lstIDFromCustomerMTN[0].add(testLead);
            }
            if(lstIDFromCustomerMTN.size() >0 && lstIDFromCustomerMTN[0].size()>0){
                //Getting a lead id and account number from SOSL query
                Lead leadidCustomerMTN = lstIDFromCustomerMTN[0].get(0);
                // Listing of all the leads which MTN is associated
                for(lead leadObject :lstIDFromCustomerMTN[0]){
                    leadsOfAssociateMTN.add(leadObject);
                }
                // Query all the activity where whoid equals to lead id 
                lstTaskResult =[SELECT id, Description,subject,Type,CCPM_communicationDirection__c,createdDate,LastModifiedDate, who.id,who.Name 
                                FROM Task where whoid in :leadsOfAssociateMTN Order By whoid ];
                //Calling wrapper class to create response body
                responsBodyOfCustomerCentralActivity = taskMessagesFromLead.setSMStoCustomerCentralResponse(lstTaskResult,leadidCustomerMTN);
            }
            
        }
        Catch(System.QueryException e)
        {
            //Add custom exception dynamically to the ErrorMap
            CCPM_LogMessageUtility.logMessage(e,'CCPM_sendSMSMessagesToCustomerCentral','getCustomerInteractions','Exception thrown while query was not found',true);  
            
        }
        
        return responsBodyOfCustomerCentralActivity;
        
    }
    
}