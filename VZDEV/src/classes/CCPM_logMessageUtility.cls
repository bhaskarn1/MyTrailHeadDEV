/********************************************************************************************************
* @author         Deloitte
* @description    An utility class providing a set of static methods allowing to log messages into the LOG table
* @date           2015-07-10
* @group          Message Logs
*********************************************************************************************************/
public without sharing class CCPM_logMessageUtility 
{
    
  //***************************************** PUBLIC ENUMS***************************************** 
    
  //------------------------------------------------------------ 
  //Description:   Enumeration of supported log levels 
  //------------------------------------------------------------
  public enum LOG_LogLevel {Debug, Info, Error, Warning}
  
  //***************************************** PRIVATE VARIABLE***************************************** 
  @TestVisible
  private static List<LOG_LogMessage__c> pendingLogsForUpsert = new  List<LOG_LogMessage__c>();
  
  //***************************************** PUBLIC VARIABLE***************************************** 
  public static Boolean queueDMLRequests = false;
    
    
   //***************************************** PUBLIC METHODS***************************************** 
   
   public static void commitQueuedLogsToDatabase()
   {
       if (!pendingLogsForUpsert.isEmpty())
                insert pendingLogsForUpsert; 
       
       pendingLogsForUpsert.clear();
   }
   
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This method retrieves the log settings including the different log parameters (log level
   *                for which a message must be logged and age till the log must be kept)
   * @return        CCPM_logLevelSetting__c: the log setting to be retreived. If not existing a new log setting is created
   *********************************************************************************************************/
   public static CCPM_logLevelSetting__c getLogSettings() 
   {         
       List<CCPM_logLevelSetting__c> setgs = CCPM_logLevelSetting__c.getall().values();
       if((setgs == null) || (setgs.size() == 0)){
           return insertLogSettings();
       }
       else{
          return setgs[0];  
       }              
   }
    
    
    //***************************************** BASIC METHODS DEFINITION***************************************** 
   
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method logs a list of messages passed as input of the method. This is the main method 
    *               invoked by all the other method overload.
    * @param        appLogs (List<LOG_LogMessage__c>): the list of messages to log  
    * @return       void
    *********************************************************************************************************/
    public static void logMessage(List<LOG_LogMessage__c> appLogs)
    {
        List<LOG_LogMessage__c> appLogsToInsert = new List<LOG_LogMessage__c>();
        CCPM_logLevelSetting__c setgs = getLogSettings();
        
        for(LOG_LogMessage__c appLog : appLogs)
        {       
            //Check if the message must be inserted depending on the log level
            if ((appLog.CCPM_debugLevel__c == LOG_LogLevel.Debug.name() && setgs.CCPM_IsDebugLogged__c) || (appLog.CCPM_debugLevel__c == LOG_LogLevel.Error.name() && setgs.CCPM_isErrorLogged__c) ||
                (appLog.CCPM_debugLevel__c == LOG_LogLevel.Info.name() && setgs.CCPM_isInfoLogged__c)   || (appLog.CCPM_debugLevel__c == LOG_LogLevel.Warning.name() && setgs.CCPM_isWarnLogged__c))
            {
                //Truncate payload if too long
                appLog.CCPM_integrationPayload__c = appLog.CCPM_integrationPayload__c.abbreviate(131072);
                
                appLogsToInsert.add(appLog);
                system.debug('---CUSTOM LOG---: ' + JSON.serialize(appLog));
            }     
        }
        
        if (!appLogsToInsert.isEmpty())
        {
            if (!queueDMLRequests)
                insert appLogsToInsert;
            else
                pendingLogsForUpsert.addAll(appLogsToInsert);
        }        
    }
   
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This methods logs a message by providing as input an instance of the LOG_LogMessage__c sObject
    * @param        appLog (LOG_LogMessage__c): the message to log  
    * @return       void
    *********************************************************************************************************/
    public static void logMessage(LOG_LogMessage__c appLog)
    {
        List<LOG_LogMessage__c> appLogs = new List<LOG_LogMessage__c>();        
        appLogs.add( appLog );        
        logMessage( appLogs );
    }

    //*****************************************METHODS WITH DIFFERENT LOG PARAMETERS***************************************** 
    
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This methods logs a message by providing as input the list of all the possible parameters
    *               This methods provides the most extensive options
    * @param        logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param        source (String): the source of the message (Interface name, Functionality name, ...)
    * @param        sourceFunction (String): the calling method (ClassName.MethodName)  
    * @param        message (String): the message to log    
    * @param        payLoad (String): The detailed integrated message (xml, JSON)
    * @param        strackTrace (String): The stack trace of the exception  
    * @param        timeTaken (Long): the execution time of the interface or other processes (in milisecond)
    * @param        referenceId (String): the SFDC Id of the record related to the message to log or the Id of the Job being executed
    * @param        referenceInfo (String): additional information regarding the related record or job 
    * @param        logCode (String): the exception log code    
    * @param        executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
    * @return       LOG_LogMessage__c: the log message that has been created
    *********************************************************************************************************/
    public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String payLoad, String strackTrace, long timeTaken, String referenceId, String referenceInfo, String logCode, Boolean executeDML) 
    {
       LOG_LogMessage__c log = new LOG_LogMessage__c();
            
       log.CCPM_source__c = source;
       log.CCPM_sourceFunction__c = sourceFunction;
       log.CCPM_referenceId__c = referenceId;
       log.CCPM_referenceInfo__c = referenceInfo;       
       log.CCPM_integrationPayload__c = payload;
       log.CCPM_stackTrace__c = strackTrace;
       log.CCPM_message__c = message; 
       log.CCPM_debugLevel__c = logLevel.name();
       log.CCPM_logCode__c = logCode;
       log.CCPM_timer__c = timeTaken;
       
       if (executeDML)
           logMessage(log);
        
       return  log;     
    }
   
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This methods logs a message by providing as input a subset of the possible parameters
   * @param         logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
   * @param         source (String): the source of the message (Interface name, Functionality name, ...)
   * @param         sourceFunction (String): the calling method (ClassName.MethodName)  
   * @param         message (String): the message to log    
   * @param         payLoad (String): The detailed integrated message (xml, JSON)   
   * @param         logCode (String): the exception log code    
   * @param         executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
   * @return        LOG_LogMessage__c: the log message that has been created
   *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message,  String payLoad, String logCode, Boolean executeDML) 
   {
       return logMessage(logLevel, source, sourceFunction, message, payLoad, '', null, '', '', logCode, executeDML);   
   }
 
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This methods logs a message by providing as input a subset of the possible parameters
   * @param         logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
   * @param         source (String): the source of the message (Interface name, Functionality name, ...)
   * @param         sourceFunction (String): the calling method (ClassName.MethodName)  
   * @param         message (String): the message to log    
   * @param         logCode (String): the exception log code    
   * @param         executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
   * @return        LOG_LogMessage__c: the log message that has been created
   *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String logCode, Boolean executeDML) 
   {
       return logMessage(logLevel, source, sourceFunction, message, '', '', null, '', '', logCode, executeDML);     
   }
    
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This methods logs a message by providing as input a subset of the possible parameters
   * @param         logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
   * @param         source (String): the source of the message (Interface name, Functionality name, ...)
   * @param         sourceFunction (String): the calling method (ClassName.MethodName)  
   * @param         message (String): the message to log    
   * @param         executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
   * @return        LOG_LogMessage__c: the log message that has been created
   *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, Boolean executeDML) 
   {
       return logMessage(logLevel, source, sourceFunction, message, '', '', null, '', '', '', executeDML);    
   }
    
    
   //*****************************************METHODS TO LOG EXCEPTIONS*****************************************  
   
   /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This methods logs a message related to the specified Exception
    *               Depending of the exception type several logs might be created (e.g. DML Exception)
    * @param        exc (Exception): the Exception to log
    * @param        source (String): the source of the message (Interface name, Functionality name, ...)
    * @param        sourceFunction (String): the calling method (ClassName.MethodName)  
    * @param        additionalMessage (String): (optional) an additional message to log besides the exception message
    * @param        payLoad (String): The detailed integrated message (xml, JSON)
    * @param        timeTaken (Long): the execution time of the interface or other processes (in milisecond)
    * @param        executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
    * @return       List<LOG_LogMessage__c>: the log messages that have been created
    *********************************************************************************************************/
   public static List<LOG_LogMessage__c> logMessage(Exception exc, String source, String sourceFunction, String additionalMessage, String payLoad, long timeTaken, Boolean executeDML)
   {   
       String message = '';
       List<LOG_LogMessage__c> msgsToInsertDml = new List<LOG_LogMessage__c>();
       
       if (additionalMessage != null && additionalMessage != '')
            message = 'Message: ' + additionalMessage + '\n';

       message += 'Exception Type: ' + exc.getTypeName() + '\nException Line Nr: ' + exc.getLineNumber(); 

       if (exc instanceof DmlException)
       {
           //DML ERROR          
           
           DmlException dmlExc = (DmlException) exc;
           for (integer i= 0; i<dmlExc.getNumDml(); i++)
           {
               String dmlMessage = message + '\nException Message: ' + dmlExc.getDmlMessage(i);
               String dmlRecordInErrorInfo = 'Batch Row #: ' + dmlExc.getDmlIndex(i);
               String fieldsInError = '';
               for (String fieldName : dmlExc.getDmlFieldNames(i))
               {
                   if (fieldsInError == '')
                       fieldsInError = fieldName;
                   else
                       fieldsInError += ', ' + fieldName;
               }
               dmlRecordInErrorInfo = '\nFields In Error: ' + fieldsInError;               
               
               LOG_LogMessage__c msg = logMessage(LOG_LogLevel.Error, source, sourceFunction, dmlMessage, payLoad, exc.getStackTraceString(), timeTaken, dmlExc.getDmlId(i), dmlRecordInErrorInfo, dmlExc.getDmlType(i).name(), false);                  
               msgsToInsertDml.add(msg);
           }       
           //insert list of logs
           if(executeDML){
               logMessage(msgsToInsertDml);
           } 
       }
       else
       {
           //OTHER TYPE OF ERRORS
           
           message += '\nException Message: ' + exc.getMessage();
           LOG_LogMessage__c logMessageObj = logMessage(LOG_LogLevel.Error, source, sourceFunction, message, payLoad, exc.getStackTraceString(), timeTaken, '', '', exc.getTypeName(), executeDML);                  
           msgsToInsertDml.add(logMessageObj);
       }
       
       return msgsToInsertDml;
   }
    
   /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This methods logs a message related to the specified Exception
    *               Depending of the exception type several logs might be created (e.g. DML Exception)
    *               This is a simplified method overloaded regarding the log of exceptions 
    * @param        exc (Exception): the Exception to log
    * @param        source (String): the source of the message (Interface name, Functionality name, ...)
    * @param        sourceFunction (String): the calling method (ClassName.MethodName)  
    * @param        additionalMessage (String): (optional) an additional message to log besides the exception message
    * @param        executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
    * @return       List<LOG_LogMessage__c>: the log messages that have been created
    *********************************************************************************************************/
   public static List<LOG_LogMessage__c> logMessage(Exception exc, String source, String sourceFunction, String additionalMessage, Boolean executeDML)
   {
       //system.debug('@@@@@');
        return logMessage(exc, source, sourceFunction, additionalMessage, '', null, executeDML);
       
   }
    
   //*****************************************METHODS TO LOG SOBJECTS INFO*****************************************  
   
   /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This methods logs a message related to the specified sObject record
    * @param        logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param        source (String): the source of the message (Interface name, Functionality name, ...)
    * @param        sourceFunction (String): the calling method (ClassName.MethodName)  
    * @param        message (String): the message to log 
    * @param        logCode (String): (optional) the error log code
    * @param        sObjectInError (sObject): the instance of the sObject for which the message must be logged
    * @param        executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
    * @return       LOG_LogMessage__c: the log message that have been created
    *********************************************************************************************************/
   public static LOG_LogMessage__c logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String logCode, SObject sObjectInError, Boolean executeDML)
   {   
       List<SObject> listsObjectInError = new List<SObject>();
       listsObjectInError.add(sObjectInError);
       List<LOG_LogMessage__c> logs = logMessage(logLevel, source, sourceFunction, message, logCode, listsObjectInError, executeDML);
       return logs[0];
   }
   
   /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This methods logs a list of messages related to the specified sObject list of records
    * @param        logLevel (LOG_LogLevel): the log level of the message: Debug, Error, Info, Warning
    * @param        source (String): the source of the message (Interface name, Functionality name, ...)
    * @param        sourceFunction (String): the calling method (ClassName.MethodName)  
    * @param        message (String): the message to log 
    * @param        logCode (String): (optional) the error log code
    * @param        listsObjectInError (List<sObject>): the list of sObject records for which the messages must be logged
    * @param        executeDML (Boolean): True if the record must be directly inserted by the method, False if the DML must not be done 
    * @return       List<LOG_LogMessage__c>: the log messages that have been created
    *********************************************************************************************************/
   public static List<LOG_LogMessage__c> logMessage(LOG_LogLevel logLevel, String source, String sourceFunction, String message, String logCode, List<SObject> listsObjectInError, Boolean executeDML)
   {            
       List<LOG_LogMessage__c> logs = new List<LOG_LogMessage__c>();
              
       for(SObject objInErr : listsObjectInError)
       {
           String objType = objInErr.getSObjectType().getDescribe().getName();
           LOG_LogMessage__c log = logMessage(logLevel, source, sourceFunction, message, '', JSON.serializePretty(objInErr), null, objInErr.id, objType, logCode, false);
           logs.add(log);   
       } 
       
       if (executeDML)
       {
           logMessage(logs);
       }
       
       return logs; 
   }
   
   //***************************************** PRIVATE METHODS***************************************** 
   
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This method inserts a new log setting with default value: all the log level tracked and age kep 365 days
   * @return        CCPM_logLevelSetting__c: the log setting that has been inserted
   *********************************************************************************************************/
   @TestVisible
   private static CCPM_logLevelSetting__c insertLogSettings() 
   {         
       CCPM_logLevelSetting__c setg = new CCPM_logLevelSetting__c(Name = 'Default_AutoGenerated',   CCPM_IsDebugLogged__c = true,   CCPM_isErrorLogged__c= true,    CCPM_isInfoLogged__c = false, CCPM_isWarnLogged__c = false,     CCPM_purgeLogAfter__c = 365);
       insert setg;  
       return setg;
   }   
}