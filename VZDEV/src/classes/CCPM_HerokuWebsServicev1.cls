/**
*@name          CCPM_HerokuWebsServicev1
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          01/08/2018
@description    The Class is exposes a REST Endpoint for heroku to update Lead,SMS and create Tasks
@testClass      
@Endpoint       {Salesforce Base URL}/services/apexrest/api/v1/coresync/
Modification    Log:
------------------------------------------------------------------------------------
Developer               					Date                   Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)          01/08/2018              Original Version
*/

//Defining the REST resource by providing URLMapping
@RestResource(urlMapping='/api/v1/coresync/*') 
global class CCPM_HerokuWebsServicev1 {
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method parses Heroku Request 
@param         None
@return        Response Wrapper object
*/ 
    //HttpPost annotation exposes the method as a REST resource and called when an HTTP POST request is sent
    @HttpPost 
    global static responseWrapper updateFieldsOnHerokuRequest() {
        //the RestRequest for the Apex REST method
        RestRequest req = RestContext.request; 
        //responseWrapper object for API response
        responseWrapper responseJSON = new responseWrapper(); 
        //List of Metadata type initialized
        List<CCPM_webServiceField__mdt> lstWebServiceLeadMDT = new List<CCPM_webServiceField__mdt>();
        List<CCPM_webServiceField__mdt> lstWebServiceSMSMDT = new List<CCPM_webServiceField__mdt>();
        List<CCPM_webServiceField__mdt> lstWebServiceTaskMDT = new List<CCPM_webServiceField__mdt>();
        //String Variables initialization for constructing dynamic Query
        String strLeadFieldsToQuery;
        String strSMSFieldsToQuery;
        
        //placeholder for the JSON Body of the request
        Map<String, Object> herokuRequestBody = new Map<String, Object>(); 
        Map<String, Object> mapLeadDetails = new Map<String, Object>(); 
        Map<String, Object> mapSMSDetails = new Map<String, Object>(); 
        Map<String, Object> mapTaskPart1Details = new Map<String, Object>(); 
        Map<String, Object> mapTaskPart2Details = new Map<String, Object>();
        //List of Sobject initialization to perform Database commands
        list<Lead> lstLead = new list<Lead>();
        list<CCPM_smsmessage__c> lstSMS = new list<CCPM_smsmessage__c>();
        list<Task> lstTask = new list<Task>();
        //Initialization of Id's to make query from database
        String idLead;
        String idSMS;
        //Boolean Variable to determine if the next Update/insert is required to be performed
        Boolean checkErrorDuringDatabase = false;
        //Database Object Initialization to save results after Insert/update
        Database.SaveResult updateLead;
        Database.SaveResult updateSMSMessage;
        list<Database.SaveResult> insertTasks = new list<Database.SaveResult>();
        //Save the Request body from Heroku
        String strJSONBody = req.requestBody.toString(); //the body of the request
        System.debug('strJSONBody->'+strJSONBody);
        //Validate if Request body is not bull
        if (!String.isBlank(strJSONBody)) { 
            //Store Heroku Request after Deserialization
            herokuRequestBody = (Map<String, Object>)JSON.deserializeUntyped(strJSONBody); //deserializes the JSON string into collections of primitive data types
            //Validate if the Request body contains the details for sObject lead
            if (herokuRequestBody.containsKey(label.CCPM_herokuLeadHeader)) {
                //Store the JSON request assocaited with Lead in a Map Structure
                mapLeadDetails=(Map<String, Object>)herokuRequestBody.get(label.CCPM_herokuLeadHeader);
                System.debug('Making call to makeMetadataQuery Lead');
                lstLead = makeMetadataQuery(mapLeadDetails,'Lead',null);
                
            }
            //Validate if the Heroku request contains details of SMS message to be updated in JSON format
            if(herokuRequestBody.containsKey(label.CCPM_herokuSMSHeader)) {
                //Store the details of SMS message record in a map
                mapSMSDetails=(Map<String, Object>)herokuRequestBody.get(label.CCPM_herokuSMSHeader);
                System.debug('Making call to makeMetadataQuery SMS');
                lstSMS =  makeMetadataQuery(mapSMSDetails,'SMS',null);
            }
            //Validating if the Heroku Request contains Task details to be inserted for the SMS that was sent out in Heroku
            if(herokuRequestBody.containsKey(label.CCPM_herokuTaskPart1Header) && herokuRequestBody.get(label.CCPM_herokuTaskPart1Header)!=null) {
                //Store the details of the Task in a Map
                mapTaskPart1Details=(Map<String, Object>)herokuRequestBody.get(label.CCPM_herokuTaskPart1Header);
                System.debug('Inside Create TaskPart1->');
                if(makeMetadataQuery(mapTaskPart1Details,'Task','TaskPart1')!=null && !makeMetadataQuery(mapTaskPart1Details,'Task','TaskPart1').isEmpty())
                {
                    list<Task> lstTaskTemp = new list<Task>();
                    lstTaskTemp = makeMetadataQuery(mapTaskPart1Details,'Task','TaskPart1');
                    lstTask.add(lstTaskTemp[0]);
                }
                System.debug('Inside Create TaskPart1->'+lstTask);
            }
            //Validating if the Heroku Request contains second part of Task details to be inserted for the SMS that was sent out in Heroku
            if(herokuRequestBody.containsKey(label.CCPM_herokuTaskPart2Header) && herokuRequestBody.get(label.CCPM_herokuTaskPart2Header)!=null) {
                //Store the details of the Task in a Map
                mapTaskPart2Details=(Map<String, Object>)herokuRequestBody.get(label.CCPM_herokuTaskPart2Header);
                if(makeMetadataQuery(mapTaskPart2Details,'Task','TaskPart2')!=null && !makeMetadataQuery(mapTaskPart2Details,'Task','TaskPart2').isEmpty())
                {
                    list<Task> lstTaskTemp = new list<Task>();
                    lstTaskTemp = makeMetadataQuery(mapTaskPart2Details,'Task','TaskPart2');
                    lstTask.add(lstTaskTemp[0]);
                }
                System.debug('Inside Create TaskPart2->'+lstTask);
            }
            
        }
        //Saving the current state of the Database in case of rollback due to an error
        Savepoint sp = Database.setSavepoint();
        //Validate if there is a lead that needs to be updated
        if(!lstLead.isEmpty())
        {	//Using Database methods to save the result of the operation on Database
            updateLead = Database.update(lstLead[0],false);
            //Validate if the update on lead is successful and enter loop incase of failures
            if(!updateLead.isSuccess()){
                List<Database.Error> errors = updateLead.getErrors();
                //Set the flag to true to prevent any more Database operations
                checkErrorDuringDatabase=true;
                //Rollback the database to the previous savepoint
                Database.rollback(sp);
                //Construct the JSON response to be sent out to Heroku
                responseJSON = constructJSONResp('01','Error','Lead',lstLead[0].id,errors[0].getMessage());
            }
        }
        //Validate if there is a SMS that needs to be updated and also if there was an error trying to update lead
        if(!lstSMS.isEmpty() && !checkErrorDuringDatabase)
        {	//Database method to update SMS
            updateSMSMessage = Database.update(lstSMS[0],false);
            //Validate if the update on SMS was successful
            if(!updateSMSMessage.isSuccess()){
                List<Database.Error> errors = updateSMSMessage.getErrors();
                //Set the flag to true incase of error during the update on SMS message
                checkErrorDuringDatabase=true;
                //Rollback to a previous checkpoint incase of an error
                Database.rollback(sp);
                //Construct JSON response to be sent out to Heroku
                responseJSON = constructJSONResp('02','Error','SMS',lstSMS[0].id,errors[0].getMessage());
                
            }
            
        }
        //Validate if there is any task that needs to be inserted and also validate if the previous Update failed
        if(!lstTask.isEmpty() && !checkErrorDuringDatabase)
        {	
            System.debug('Inside if condition to insert Task ->lstTask'+lstTask+'->'+checkErrorDuringDatabase);
            //Database method to insert Task
            //insert lstTask;
            insertTasks = Database.insert(lstTask,false);
            //Validate if there was an error in any of the insert of Tasks for a specific lead
            for (Database.SaveResult DS : insertTasks)
            {	//Validate if there was a failure and also if there was any previous failure already recorded
                if(!DS.isSuccess() && !checkErrorDuringDatabase){
                    List<Database.Error> errors = DS.getErrors();
                    //Set the flag to true to indicate there was one database Error
                    checkErrorDuringDatabase=true;
                    //Rollback to the latest save point 
                    Database.rollback(sp);
                    //Construct a JSON response to send it out to Heroku
                    responseJSON = constructJSONResp('03','Error','Task',null,errors[0].getMessage());
                    
                }
            }
        }
        //Validate if there was no error and no code was already set on the Response Wrapper class
        if(responseJSON.HTTPstatus=='')
        {	//Set the JSON response status to 20o to mark successful processing of Heroku Request
            responseJSON=constructJSONResp('200','OK',null,null,null);
            
        }
        //Return Response
        return responseJSON;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method queries metadata, returns appropriate SObject List
@param         Member Variables of class responseWrapper
@return        Object of class responseWrapper
*/ 
    
    public static list<sObject> makeMetadataQuery(Map<String, Object> mapGenericRequestBody,String strSobject,String strTaskPart)
    {	System.debug('Inside makeMetadataQuery'+strSobject+'->'+mapGenericRequestBody);
     String idSObject;
     String strQueryStringGeneric;
     list<sObject> lstsObjectGeneric = new list<sObject>();
     List<CCPM_webServiceField__mdt> lstWebServiceMDT = new List<CCPM_webServiceField__mdt>();
     lstWebServiceMDT = [Select developername,CCPM_isActive__c,CCPM_fieldtobeUpdated__c,CCPM_object__c 
                         from CCPM_webServiceField__mdt 
                         where CCPM_isActive__c=true and CCPM_object__c= :strSobject];
     
     if(strSobject=='Lead' || strSobject=='SMS')
     {	
         if(mapGenericRequestBody.containsKey('Id') && mapGenericRequestBody.get('Id')!=null){
             idSObject= (String)mapGenericRequestBody.get('Id');
         }
         //Validate if Lead ID is not null to make a query to identify the lead in database
         if(idSObject!=null)
         {	
             
             if(!lstWebServiceMDT.isEmpty()){
                 //Construct the Dynamic query and save it in a string
                 if(strSobject=='SMS')
                 {
                     strQueryStringGeneric=constructQueryString(lstWebServiceMDT,'ccpm_smsmessage__c',idSObject);
                 }
                 else if(strSobject=='Lead')
                 {
                     strQueryStringGeneric=constructQueryString(lstWebServiceMDT,'Lead',idSObject);
                 }
                 
                 System.debug('Query String Lead->'+strQueryStringGeneric);
                 //Database Query made to retrieve the required Lead record in a List
                 lstsObjectGeneric = Database.query(strQueryStringGeneric);
                 if(!lstsObjectGeneric.isEmpty())
                 {	//If a valid associated Lead is returned, Construct the metadat for Lead for Update
                     lstsObjectGeneric = genericPopulationOfFieldsUsingMetadata(lstWebServiceMDT, lstsObjectGeneric,strSobject, mapGenericRequestBody);
                 }
             }
         }
         
     }
     else if(strSobject=='Task' && strTaskPart!=null)
     {
         if(!mapGenericRequestBody.isEmpty() && !lstWebServiceMDT.isEmpty() && createTask(mapGenericRequestBody,lstWebServiceMDT)!=null)
         {	
             lstsObjectGeneric.add(createTask(mapGenericRequestBody,lstWebServiceMDT));
         }
     }
     
     
     return lstsObjectGeneric;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method constructs the JSONRepsonse to Heroku
@param         Member Variables of class responseWrapper
@return        Object of class responseWrapper
*/ 
    public static responseWrapper constructJSONResp(String strHTTPstatus,String strHTTPbody,String strErrorObject,String strErrorObjectID,String strErrorMessage)
    {
        responseWrapper objresponseWrapper = new responseWrapper();
        objresponseWrapper.HTTPstatus = strHTTPstatus;
        objresponseWrapper.HTTPbody = strHTTPbody;
        objresponseWrapper.ErrorObject=strErrorObject;
        objresponseWrapper.ErrorObjectID=strErrorObjectID;
        objresponseWrapper.ErrorMessage=strErrorMessage; 
        
        return objresponseWrapper;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   The method constructs Query String
@param         Metadata associated with the Sobject, String sObject to be queried,String Id of the sObject to be updated
@return        String Query String
*/ 
    public static String constructQueryString(list<CCPM_webServiceField__mdt> lstWebServiceMDTQueryString, String strSobject,String strID)
    {
        String strQueryString='Select ';
        integer count=0;
        for(CCPM_webServiceField__mdt objMDTaddQueryString: lstWebServiceMDTQueryString)
        {
            count++;
            if(count == lstWebServiceMDTQueryString.size())
            {
                strQueryString = strQueryString+objMDTaddQueryString.CCPM_fieldtobeUpdated__c+' from '+strSobject+' where id='+'\''+strID+'\'';
            }
            else
            {
                strQueryString = strQueryString+objMDTaddQueryString.CCPM_fieldtobeUpdated__c+',';
            }
            
        }
        
        return strQueryString;
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This is a generic method to populate fields on appropriate Sobject based on the Heroku Request
@param         Metadata setting, List of sObjects, String Object type, Map of Heroku Request for the concerned sObject
@return        List<sObject>
*/     
    public static list<sObject> genericPopulationOfFieldsUsingMetadata(List<CCPM_webServiceField__mdt> lstWebServiceMDT, list<sObject> lstObj, String strObjType,Map<String, Object> mapGenericHerokuFieldDetails)
    {
        boolean boolCheckEmptyObject=false;
        if(mapGenericHerokuFieldDetails!=null && !mapGenericHerokuFieldDetails.isEmpty() && lstObj!=null && !lstObj.isEmpty())
        {
            Map<String, Schema.sObjectField> mapTargetFields = new Map<String, Schema.sObjectField>();
            if(strObjType=='SMS')
            {
                mapTargetFields = Schema.getGlobalDescribe().get('ccpm_smsmessage__c').getDescribe().fields.getMap();
            }
            else
            {
                mapTargetFields = Schema.getGlobalDescribe().get(strObjType).getDescribe().fields.getMap();
            }
            
            for(sObject objGenericObj : lstObj)
            {
                for(CCPM_webServiceField__mdt objMDT : lstWebServiceMDT)
                {
                    if(objMDT.CCPM_object__c == strObjType && mapGenericHerokuFieldDetails.containsKey(objMDT.CCPM_fieldtobeUpdated__c) && mapGenericHerokuFieldDetails.get(objMDT.CCPM_fieldtobeUpdated__c)!=null)
                    {	
                        boolCheckEmptyObject =true;
                        Schema.DisplayType ftype = mapTargetFields.get(objMDT.CCPM_fieldtobeUpdated__c).getDescribe().getType();
                        if(ftype == Schema.DisplayType.String || ftype == Schema.DisplayType.Picklist || ftype == Schema.DisplayType.Combobox || ftype == Schema.DisplayType.TextArea)
                        {
                            objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,(String)mapGenericHerokuFieldDetails.get(objMDT.CCPM_fieldtobeUpdated__c));
                        }
                        else if(ftype == Schema.DisplayType.DateTime)
                        {	
                            objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,Datetime.valueOf((String)mapGenericHerokuFieldDetails.get(objMDT.CCPM_fieldtobeUpdated__c))); 
                        }
                        else if(ftype == Schema.DisplayType.Boolean)
                        {
                            objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,(Boolean)mapGenericHerokuFieldDetails.get(objMDT.CCPM_fieldtobeUpdated__c)); 
                        }
                        else if(ftype == Schema.DisplayType.Date)
                        {
                            objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,(Date)mapGenericHerokuFieldDetails.get(objMDT.CCPM_fieldtobeUpdated__c));
                        }
                        else if(ftype == Schema.DisplayType.Reference || ftype == Schema.DisplayType.ID )
                        {
                            objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,(Id)mapGenericHerokuFieldDetails.get(objMDT.CCPM_fieldtobeUpdated__c));
                        }
                    }
                }
            }
        }
        if(boolCheckEmptyObject)
        {
            return lstObj;
        }
        else
        {
            return null;
        }
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is to create Tasks on Heroku request
@param         map of Heroku Request associated with the task
@return        Task 
*/   
    public static task createTask(map<String, Object> mapTaskDetails, list<CCPM_webServiceField__mdt> lstWebServiceTaskMDT)
    {
        System.debug('Inside CreateTask->');
        System.debug('mapTaskDetails->'+mapTaskDetails);
        System.debug('lstWebServiceTaskMDT->'+lstWebServiceTaskMDT);
        list<task> lstTaskTemp = new list<task>();
        Task objTaskTemp = new Task();
        lstTaskTemp.add(objTaskTemp);
        boolean boolCheckEmptyTask=false;
        lstTaskTemp = genericPopulationOfFieldsUsingMetadata(lstWebServiceTaskMDT,lstTaskTemp,'Task',mapTaskDetails);
        System.debug('lstTaskTemp->'+lstTaskTemp);
        if(lstTaskTemp!=null && !lstTaskTemp.isEmpty() && lstTaskTemp[0]!=null)
        {
            return lstTaskTemp[0]; 
        }
        else
        {
            return null;
        }
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   Wrapper/Inner Class for constructing Response structure
*/   
    
    //wrapper class for the response to an API request
    global class responseWrapper {
        
        global String HTTPstatus {get;set;} 
        global String HTTPbody {get;set;} 
        global String ErrorObject {get;set;}
        global String ErrorObjectID{get;set;}
        global String ErrorMessage{get;set;}
        
        /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is a constructor for the wrapper class that sets default values to all its member variables
@param         None
@return        None
*/   
        global responseWrapper() {
            //default all values
            this.HTTPstatus = '';
            this.HTTPbody = '';
            this.ErrorObject='';
            this.ErrorObjectID='';
            this.ErrorMessage='';
            
        }
    }
    
}