/**
*@name          CCPM_webserviceManualLeadsv1
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          03/07/2018
@description    The Class is exposes a REST Endpoint for POS to create Manual Leads
@testClass      
@Endpoint       {Salesforce Base URL}/services/apexrest/api/v1/manualleadcreate/
Modification    Log:
------------------------------------------------------------------------------------
Developer               					Date                   Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)          01/08/2018              Original Version
*/

//Defining the REST resource by providing URLMapping
@RestResource(urlMapping='/api/v1/manualleadcreate/*') 
global class CCPM_webserviceManualLeadsv1 {
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method parses Heroku Request 
@param         None
@return        Response Wrapper object
*/ 
    //HttpPost annotation exposes the method as a REST resource and called when an HTTP POST request is sent
    @HttpPost 
    global static responseWrapper createManualLead() {
        //the RestRequest for the Apex REST method
        RestRequest req = RestContext.request; 
        //responseWrapper object for API response
        responseWrapper responseJSON = new responseWrapper(); 
        //List of Metadata type initialized
        List<CCPM_manualLeadWebservice__mdt> lstWebServicemanualLeadMDT = new List<CCPM_manualLeadWebservice__mdt>();
        List<CCPM_manualLeadWebservice__mdt> lstWebServiceAccountMDT = new List<CCPM_manualLeadWebservice__mdt>();
        
        String strAccountUniqueIDValue = null;
        //placeholder for the JSON Body of the request
        Map<String, Object> mapJSONRequestBody = new Map<String, Object>(); 
        Map<String, Object> mapManualLeadDetails = new Map<String, Object>(); 
        Map<String, Object> mapAccountDetails = new Map<String, Object>(); 
        
        //List of Sobject initialization to perform Database commands
        list<Lead> lstLead = new list<Lead>();
        list<Account> lstAccount = new list<Account>();
        //Boolean Variable to determine if the next Update/insert is required to be performed
        Boolean checkErrorDuringDatabase = false;
        //Database Object Initialization to save results after Insert/update
        
        
        //Save the Request body from Heroku
        String strJSONBody = req.requestBody.toString(); //the body of the request
        System.debug('strJSONBody->'+strJSONBody);
        //Validate if Request body is not bull
        if (!String.isBlank(strJSONBody)) { 
            //Store Heroku Request after Deserialization
            mapJSONRequestBody = (Map<String, Object>)JSON.deserializeUntyped(strJSONBody); //deserializes the JSON string into collections of primitive data types
            if (mapJSONRequestBody.containsKey('Account')) {
                //Store the JSON request assocaited with Lead in a Map Structure
                mapAccountDetails=(Map<String, Object>)mapJSONRequestBody.get('Account');
                if(mapAccountDetails.containsKey('AccountNumber') && mapAccountDetails.get('AccountNumber')!=null)
                {
                    string strAccountNumber = (String)mapAccountDetails.get('AccountNumber');
                    strAccountUniqueIDValue =  findAccounts(strAccountNumber);
                    if(strAccountUniqueIDValue==null || strAccountUniqueIDValue=='') 
                    {	
                        makemetadataqueryWrapper objWrapperAccount = new makemetadataqueryWrapper();
                        
                        objWrapperAccount = makeMetadataQuery(mapAccountDetails,'Account');
                        if(objWrapperAccount.strMissingField!=null && objWrapperAccount.strMissingField!='')
                        {
                            responseJSON = constructJSONResp('417','Missing Required Field on Account '+objWrapperAccount.strMissingField); 
                        }
                        else
                        {
                            lstAccount = objWrapperAccount.lstGenericObject;
                        }
                        
                        if(lstAccount!=null && lstAccount.size()>0)
                        {	
                            lstAccount[0].CCPM_accountUniqueID__c = CCPM_EncryptKey.CCPM_EncryptKey((String)mapAccountDetails.get('AccountNumber') + (String)mapAccountDetails.get('MTN'));
                            strAccountUniqueIDValue =  lstAccount[0].CCPM_accountUniqueID__c;
                        }
                    }
                    //Validate if the Request body contains the details for sObject lead
                    if (mapJSONRequestBody.containsKey('Lead') && mapJSONRequestBody.get('Lead')!=null && strAccountUniqueIDValue!=null && strAccountUniqueIDValue!='') {
                        //Store the JSON request assocaited with Lead in a Map Structure
                        mapManualLeadDetails=(Map<String, Object>)mapJSONRequestBody.get('Lead');
                        System.debug('Making call to makeMetadataQuery Lead');
                        makemetadataqueryWrapper objWrapperLead = new makemetadataqueryWrapper();
                        objWrapperLead = makeMetadataQuery(mapManualLeadDetails,'Lead');
                       // system.debug('@@@objWrapperLead : ' + objWrapperLead);
                        if(objWrapperLead.strMissingField!=null && objWrapperLead.strMissingField!='')
                        {
                            responseJSON = constructJSONResp('417','Missing Required Field on Lead '+objWrapperLead.strMissingField); 
                        }
                        else
                        {
                            lstLead = objWrapperLead.lstGenericObject;
                        }
                        //lstLead = makeMetadataQuery(mapManualLeadDetails,'Lead');
                        if(lstLead!=null && lstLead.size()>0)
                        {
                            lstLead[0].CCPM_cartUniqueID__c = CCPM_EncryptKey.CCPM_EncryptKey(string.valueOf(system.now()) + lstLead[0].CCPM_mobileNumber__c);
                            lstLead[0].CCPM_accountUniqueID__c=strAccountUniqueIDValue;
                            lstlead[0].CCPM_isManualLead__c=true;
                            lstlead[0].Company='1';
                        }
                    }
                    else
                    {
                        System.debug('No Request Body->');
                        responseJSON = constructJSONResp('417','Empty Lead Body');
                    }
                }
                else
                {
                    System.debug('No Request Body->');
                    responseJSON = constructJSONResp('417','Account Number not found in Request');
                }
            }
            else{
                System.debug('No Request Body->');
                responseJSON = constructJSONResp('417','Empty Account Body');
            }
            
        }
        else{
            System.debug('No Request Body->');
            responseJSON = constructJSONResp('417','Empty Request Body');
        }
        //Saving the current state of the Database in case of rollback due to an error
        Savepoint sp = Database.setSavepoint();
        if(lstLead!=null && lstLead.size()>0)
        {
            responseJSON = doFinalDML(lstAccount,lstLead,mapManualLeadDetails);
        }
        
        
        //Validate if there was no error and no code was already set on the Response Wrapper class
        if(responseJSON.StatusCode!='200')
        {	
            database.rollback(sp);   
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
    
    public static responseWrapper doFinalDML(list<Account> lstAccount,list<Lead> lstLead,Map<String, Object> mapManualLeadDetails)
    {	
        responseWrapper returnResponseFinal = new responseWrapper();
        list<Database.SaveResult> lstInsertLead = new list<Database.SaveResult>();
        list<Database.SaveResult> lstInsertAccount = new list<Database.SaveResult>();
        list<Database.SaveResult> lstInsertNotes = new list<Database.SaveResult>();
        List<LOG_LogMessage__c> lstBatchLogMsg = new List<LOG_LogMessage__c>();
        Boolean isError = false;
        
        
        if(lstAccount!=null && lstAccount.size()>0)
        {
            lstInsertAccount= Database.insert(lstAccount,false);
            if(checkDMLErrors(lstInsertAccount)!=null && checkDMLErrors(lstInsertAccount).size()>0)
            {
                lstBatchLogMsg.addAll(checkDMLErrors(lstInsertAccount));
                isError=true;  
            }
        }
        if(lstLead!=null && lstLead.size()>0 && !isError)
        {
            lstInsertLead= Database.insert(lstLead,false);
            if(checkDMLErrors(lstInsertLead)!=null && checkDMLErrors(lstInsertLead).size()>0)
            {
                lstBatchLogMsg.addAll(checkDMLErrors(lstInsertLead));
                isError=true;  
            }
            
        }
       /* if(lstLead!=null && lstLead.size()>0 && mapManualLeadDetails.containskey('Notes') && mapManualLeadDetails.get('Notes')!=null && !isError)
        {
            Note objNote = new Note();
            objNote.Body = (String)mapManualLeadDetails.get('Notes');
            objNote.ParentId=lstLead[0].id;
            objNote.Title='POS Notes';
            objNote.IsPrivate=False;
            list<Note> lstNotes= new list<Note>();
            lstNotes.add(objNote);
            lstInsertNotes= Database.insert(lstNotes,false);
            if(checkDMLErrors(lstInsertNotes)!=null && checkDMLErrors(lstInsertNotes).size()>0)
            {
                lstBatchLogMsg.addAll(checkDMLErrors(lstInsertNotes));
            }
            
        }*/
        
        if(lstBatchLogMsg!=null && lstBatchLogMsg.size()>0)
        {	
            returnResponseFinal = constructJSONResp('500',lstBatchLogMsg[0].CCPM_message__c);
            insert lstBatchLogMsg;
            System.debug('lstBatchLogMsg->');
        }
        else
        {
            returnResponseFinal = constructJSONResp('200','OK');
        }
        return returnResponseFinal;
        
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method queries metadata, returns appropriate SObject List
@param         Member Variables of class responseWrapper
@return        Object of class responseWrapper
*/ 
    
    public static  List<LOG_LogMessage__c> checkDMLErrors(list<Database.SaveResult> lstDMLErrors)
    {
        List<LOG_LogMessage__c> lstLog = new List<LOG_LogMessage__c>();
        for (Database.SaveResult DS : lstDMLErrors)
        {	//Validate if there was a failure and also if there was any previous failure already recorded
            if(!DS.isSuccess()){
                List<Database.Error> errors = DS.getErrors();
                //Set the flag to true to indicate there was one database Error
                lstLog.add(CCPM_utility.logMessage('Error','CCPM_webservicemanualLeadsv1','Inserting Leads and Account',errors[0].getMessage(),''));
                // responseJSON = constructJSONResp('03','Error','Task',null,errors[0].getMessage());
                
            }
        }
        
        return lstLog;
        
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method queries metadata, returns appropriate SObject List
@param         Member Variables of class responseWrapper
@return        Object of class responseWrapper
*/ 
    
    public static makemetadataqueryWrapper makeMetadataQuery(Map<String, Object> mapGenericRequestBody,String strSobject)
    {	
        makemetadataqueryWrapper objWrapper = new makemetadataqueryWrapper();
        System.debug('Inside makeMetadataQuery'+strSobject+'->'+mapGenericRequestBody);
        list<sObject> lstgenericsObject = new list<sObject>();
        sObject objGenericObj = Schema.getGlobalDescribe().get(strSobject).newSObject();
        List<CCPM_manualLeadWebservice__mdt> lstWebServiceMDT = new List<CCPM_manualLeadWebservice__mdt>();
        
        Map<String, Schema.sObjectField> mapTargetFields = new Map<String, Schema.sObjectField>();
        mapTargetFields = Schema.getGlobalDescribe().get(strSobject).getDescribe().fields.getMap();
        
        for(CCPM_manualLeadWebservice__mdt objMDT : [Select developername,CCPM_isActive__c,CCPM_fieldtobeUpdated__c,CCPM_object__c,CCPM_isRequired__c,CCPM_fieldPOS__c  
                                                     from CCPM_manualLeadWebservice__mdt 
                                                     where CCPM_isActive__c=true and CCPM_object__c= :strSobject])
        {	
            
            if((!mapGenericRequestBody.containsKey(objMDT.CCPM_fieldPOS__c) || mapGenericRequestBody.get(objMDT.CCPM_fieldPOS__c)==null) && objMDT.CCPM_isRequired__c)
            {
                objWrapper.strMissingField = objMDT.CCPM_fieldPOS__c;
                break;
            }
            else if(mapGenericRequestBody.containsKey(objMDT.CCPM_fieldPOS__c) && mapGenericRequestBody.get(objMDT.CCPM_fieldPOS__c)!=null)
            {	
                
                Schema.DisplayType ftype = mapTargetFields.get(objMDT.CCPM_fieldtobeUpdated__c).getDescribe().getType();
                if(ftype == Schema.DisplayType.String || ftype == Schema.DisplayType.Picklist || ftype == Schema.DisplayType.Combobox || ftype == Schema.DisplayType.TextArea || ftype == Schema.DisplayType.PHONE || ftype == Schema.DisplayType.EMAIL)
                {
                    objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,(String)mapGenericRequestBody.get(objMDT.CCPM_fieldPOS__c));
                }
                else if(ftype == Schema.DisplayType.DateTime)
                {	
                    DateTime objDateTimeUserContext = Datetime.valueOf((String)mapGenericRequestBody.get(objMDT.CCPM_fieldPOS__c));
                    objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,DateTime.valueOf(objDateTimeUserContext.format('yyyy-MM-dd HH:mm:ss', userinfo.getTimeZone().toString()))); 
                	//system.debug('@@@objDateTimeUserContext : ' + objDateTimeUserContext);
                }
                else if(ftype == Schema.DisplayType.Boolean)
                {	
                    string strtemp = (String)mapGenericRequestBody.get(objMDT.CCPM_fieldPOS__c);
                    objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,Boolean.valueOf(strTemp)); 
                }
                else if(ftype == Schema.DisplayType.Date)
                {
                    objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,(Date)mapGenericRequestBody.get(objMDT.CCPM_fieldPOS__c));
                }
                else if(ftype == Schema.DisplayType.Reference || ftype == Schema.DisplayType.ID )
                {
                    objGenericObj.put(objMDT.CCPM_fieldtobeUpdated__c,(Id)mapGenericRequestBody.get(objMDT.CCPM_fieldPOS__c));
                }
            }
        }
        if(objWrapper.strMissingField!=null && objWrapper.strMissingField!='')
        {
            objWrapper.lstGenericObject = null;
        }
        else{
            lstgenericsObject.add(objGenericObj);
            objWrapper.lstGenericObject=lstgenericsObject;
        }
        //lstgenericsObject.add(objGenericObj);
        return objWrapper;
        
    }
    
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method queries to find any existing account in salesforce
@param         String Account Number
@return        Boolean variable denoting if Account exists in salesforce
*/ 
    public static String findAccounts(String strAccountNumber)
    {	
        string strAccountUniqueID=null;
        String strBuildSOSLQuery = 'FIND \''+strAccountNumber+'\' IN ALL FIELDS RETURNING Account (id,CCPM_accountNumber__c,CCPM_accountUniqueID__c)';
        System.debug('strBuildSOSLQuery->'+strBuildSOSLQuery);
        List<List<sObject>> lstAccount = Search.query(strBuildSOSLQuery);
        system.debug(lstAccount);
        if(lstAccount!=null && lstAccount.size()>0)
        {
            list<Account> lstAccountReturned = new list<Account>((List<Account>)lstAccount[0]);
            for(Account objAccount: lstAccountReturned)
            {	
                if(objAccount.CCPM_accountNumber__c==strAccountNumber)
                {	
                    strAccountUniqueID=objAccount.CCPM_accountUniqueID__c;
                    break;
                }
            }
        }
        return strAccountUniqueID;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method constructs the JSONRepsonse to Heroku
@param         Member Variables of class responseWrapper
@return        Object of class responseWrapper
*/ 
    public static responseWrapper constructJSONResp(String strHTTPstatusCode,String strErrorMessage)
    {
        responseWrapper objresponseWrapper = new responseWrapper();
        objresponseWrapper.Message = strErrorMessage;
        objresponseWrapper.StatusCode = strHTTPstatusCode;
        return objresponseWrapper;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   Wrapper/Inner Class for constructing Response structure
*/   
    
    //wrapper class for the response to an API request
    global class makemetadataqueryWrapper {
        
        global list<sObject> lstGenericObject {get;set;} 
        global String strMissingField {get;set;} 
        
        
        /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is a constructor for the wrapper class that sets default values to all its member variables
@param         None
@return        None
*/   
        global makemetadataqueryWrapper() {
            //default all values
            this.lstGenericObject = null;
            this.strMissingField = '';
        }
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   Wrapper/Inner Class for constructing Response structure
*/   
    
    //wrapper class for the response to an API request
    global class responseWrapper {
        
        global String Message {get;set;} 
        global String StatusCode {get;set;} 
        
        
        /**
@author        Brigadesh Chandrasekar (Deloitte)
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