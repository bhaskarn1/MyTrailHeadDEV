/**
*@name          CCPM_HerokuWebsServicev1Test
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          01/15/2018
@Description    Test Class for CCPM_HerokuWebsServicev1 
@Endpoint       {Salesforce Base URL}/services/apexrest/api/v1/coresync/
Modification    Log:
------------------------------------------------------------------------------------
Developer                                   Date                   Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)          01/15/2018              Original Version
*/


@isTest
public class CCPM_HerokuWebsServicev1Test {
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This method is used to creatCart
*@return :      Lead 
*/   
    public static Lead createCustomerCart(String leadtype,String lastName, String Status, String MTN, String numberOfLinesInterestedIn,Id accountID, String storeID)
    {
        Lead objLead                    =   new Lead();      
        
        objLead.CCPM_mobileNumber__c    =   MTN;
        objLead.LastName                =   lastName;
        objLead.Company                 =   numberOfLinesInterestedIn;
        objLead.CCPM_SMSLegalOptIn__c = true;
        objLead.Status                  =   Status;
        objLead.CCPM_leadtype__c        =   leadtype;
        
     /*   if (!leadType.contains('Prospect'))   {
            objLead.CCPM_Account__c     =   accountID;
        }
        
        if (leadType == 'Customer Campaign')  {
            objLead.LeadSource              = 'CRM';
        }
        
        if (leadType.contains('Manual'))    {
            objLead.CCPM_isManualLead__c    = true;
        }
        
        if (leadType == 'Customer Campaign' || 
            ((leadType == 'Telesales'       || 
            leadType.contains('Manual'))&& leadType.contains('Customer')))   {
                
                objLead.RecordTypeId            =   Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer Cart').getRecordTypeId();
                
            } else {
                
                objLead.RecordTypeId            =   Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
            } */
        
        return objLead;   
    }
    
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This method makes the call the Rest Service
*@return :      None 
*/
    
    public static testMethod void testPostMethod()
    {   
        Test.startTest();
        RestRequest request = new RestRequest();
        CCPM_HerokuWebsServicev1.responseWrapper resWrapper = new CCPM_HerokuWebsServicev1.responseWrapper();
        Lead objLead = createCustomerCart('Customer Campaign','TestLastname','Eligible','3213187287','2',null,null);
        insert objLead;
        CCPM_smsmessage__c sms = new ccpm_smsmessage__c();
        insert sms;
        
        JSONGenerator JSONgen = createGenerateJSONRequest(objLead.id,sms.Id);
        String myString = JSONgen.getAsString();
        System.debug(myString);
        Blob myBlob = Blob.valueOf(myString);
        request.requestBody = myBlob;
        request.requestUri ='/services/apexrest/api/v1/coresync/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        resWrapper = CCPM_HerokuWebsServicev1.updateFieldsOnHerokuRequest();
        System.debug('Response->'+CCPM_HerokuWebsServicev1.updateFieldsOnHerokuRequest()+resWrapper.HTTPstatus);
        System.assertEquals('200', resWrapper.HTTPstatus);
        Test.stopTest();
    }
    
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This method creates the JSON Request
*@return :      JSONGenerator 
*/
    public static JSONGenerator createGenerateJSONRequest(id LeadID,id SMSID) {
        JSONGenerator JSONgen = JSON.createGenerator(true);
        JSONgen.writeStartObject();
        JSONgen.writeFieldName('lead');
        JSONgen.writeStartObject();
        JSONgen.writeStringField('Id',LeadID );
        JSONgen.writeBooleanField('CCPM_isInitialSMSSent__c', True);
        JSONgen.writeStringField('CCPM_initialSMSSentDateTime__c', '2018-01-01 00:00:00');
        JSONgen.writeStringField('CCPM_lastInteraction__c', '2018-01-01 00:00:00');
        JSONgen.writeStringField('CCPM_followUpSMSDate__c', '2018-01-01 00:00:00');
        JSONgen.writeStringField('CCPM_prospectSMSSentDate__c', '2018-01-01 00:00:00');
        JSONgen.writeStringField('CCPM_prospectSMSSentDate__c', '2018-01-01 00:00:00');
        JSONgen.writeBooleanField('CCPM_isInitialSMSSent__c', True);
        JSONgen.writeStringField('status', 'Contacted');
        JSONgen.writeEndObject();
        
        JSONgen.writeFieldName('sms message');
        JSONgen.writeStartObject();
        JSONgen.writeStringField('Id',SMSID );
        JSONgen.writeStringField('CCPM_messageType__c', 'TestType');
        JSONgen.writeStringField('CCPM_smssentactualtime__c', '2018-01-01 00:00:00');
        JSONgen.writeStringField('CCPM_message__c', 'Hello');
        JSONgen.writeStringField('CCPM_requestID__c', '213123^123123');
        JSONgen.writeStringField('CCPM_responseMessage__c', 'No Content');
        JSONgen.writeStringField('CCPM_prospectSMSSentDate__c', '2018-01-01 00:00:00');
        JSONgen.writeStringField('CCPM_responseCode__c', '204');
        JSONgen.writeStringField('CCPM_messagestatus__c', 'Queued');
        JSONgen.writeEndObject();
        
        JSONgen.writeFieldName('TaskPart1');
        JSONgen.writeStartObject();
        JSONgen.writeStringField('description','testDescription' );
        JSONgen.writeStringField('CCPM_communicationDirection__c', 'Inbound');
        JSONgen.writeStringField('CCPM_SMSMessageType__c', 'Test type');
        JSONgen.writeStringField('Priority', 'Normal');
        JSONgen.writeStringField('Status', 'Completed');
        JSONgen.writeStringField('Subject', 'TextMessageSent');
        JSONgen.writeStringField('Whoid',LeadID);
        JSONgen.writeEndObject();
        
        JSONgen.writeFieldName('TaskPart2');
        JSONgen.writeStartObject();
        JSONgen.writeStringField('description','testDescription' );
        JSONgen.writeStringField('CCPM_communicationDirection__c', 'Inbound');
        JSONgen.writeStringField('CCPM_SMSMessageType__c', 'Test type');
        JSONgen.writeStringField('Priority', 'Normal');
        JSONgen.writeStringField('Status', 'Completed');
        JSONgen.writeStringField('Subject', 'TextMessageSent');
        JSONgen.writeStringField('Whoid',LeadID);
        JSONgen.writeEndObject();
        
        JSONgen.writeEndObject();
        return JSONgen;
        
    }
    
    
    
    
}