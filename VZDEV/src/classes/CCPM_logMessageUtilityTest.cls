/********************************************************************************************************
* @author       Deloitte
* @description  This is the test class of the CCPM_LogMessageUtility class
* @date         2015-06-29
* @group        Message Logs - Test Classes
*********************************************************************************************************/
@isTest
public class CCPM_logMessageUtilityTest {  
    
  
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This test method tests the getLogSettings method
   * @return        void
   *********************************************************************************************************/
   @isTest
   public static void getLogSettingsTest() 
   {         
       CCPM_TestDataUtility.generateErrorMgtCustomSetting(true, false, false, true, 95);
       
       CCPM_logLevelSetting__c resultSetg = CCPM_LogMessageUtility.getLogSettings();
       System.assert(resultSetg != null); 
       System.assertEquals(true, resultSetg.CCPM_IsDebugLogged__c); 
       System.assertEquals(true, resultSetg.CCPM_isErrorLogged__c); 
       System.assertEquals(false, resultSetg.CCPM_isInfoLogged__c); 
       System.assertEquals(false, resultSetg.CCPM_isWarnLogged__c);
       System.assertEquals(95, resultSetg.CCPM_purgeLogAfter__c); 
   }
   
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This test method tests the automatic generation of the custom settings
   * @return        void
   *********************************************************************************************************/
   @isTest
   public static void insertLogSettingsTest() 
   {         
       CCPM_logLevelSetting__c setg = CCPM_LogMessageUtility.insertLogSettings();       
       CCPM_logLevelSetting__c resultSetg = CCPM_LogMessageUtility.getLogSettings();
       System.assert((setg != null) && (resultSetg != null)); 
        System.assertEquals(true, resultSetg.CCPM_IsDebugLogged__c); 
       System.assertEquals(true, resultSetg.CCPM_isErrorLogged__c); 
       System.assertEquals(false, resultSetg.CCPM_isInfoLogged__c); 
       System.assertEquals(false, resultSetg.CCPM_isWarnLogged__c);
       System.assertEquals(365,resultSetg.CCPM_purgeLogAfter__c);
   }


   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-08-17
   * @description   This test method tests the behaviour of the different logMessage methods overload 
   * @return        void
   *********************************************************************************************************/
    @isTest
   public static void logMessageTestSuccess()   
   {  
        //build test data: Account and Contacts
       Account acc = CCPM_TestDataUtility.generateAccounts(1, 'Test Account', true)[0];
       List<Contact> contactsToLog =  CCPM_TestDataUtility.generateContacts(1, 'Test Contact', acc, true);      
       
       Test.startTest();
       
       String logMessage = 'exception Message 123';
       CCPM_LogMessageUtility.LOG_LogLevel logLevel = CCPM_LogMessageUtility.LOG_LogLevel.Debug;
       String sourceComponent = 'sourceComponent 123';
       MyException exc = new MyException('This is an exception');
       CCPM_TestDataUtility.generateErrorMgtCustomSetting(true, true, true, true, 95);
           
       List<LOG_LogMessage__c> msgToInsert = CCPM_LogMessageUtility.logMessage(exc, sourceComponent, 'sourceFunction1', 'Log Message test 890', true); 
       System.assert((msgToInsert != null) && (msgToInsert.size() > 0));
       
       LOG_LogMessage__c insertedMsg = CCPM_TestDataUtility.getInsertedLog(msgToInsert[0].Id);
       System.assert(insertedMsg != null);
       System.assertEquals(msgToInsert[0].CCPM_source__c, insertedMsg.CCPM_source__c);
       System.assertEquals(msgToInsert[0].CCPM_sourceFunction__c, insertedMsg.CCPM_sourceFunction__c);
       System.assertEquals('sourceFunction1', insertedMsg.CCPM_sourceFunction__c);
       System.assertEquals(msgToInsert[0].CCPM_message__c, insertedMsg.CCPM_message__c);
       System.assert(insertedMsg.CCPM_message__c.contains('Message: Log Message test 890'));
       System.assert(insertedMsg.CCPM_message__c.contains(exc.getMessage()));
       System.assert(insertedMsg.CCPM_stackTrace__c != null);
       System.assertEquals(msgToInsert[0].CCPM_logCode__c, insertedMsg.CCPM_logCode__c);
       //System.assertEquals(0, insertedMsg.CCPM_age__c);
       System.assertEquals(null, insertedMsg.CCPM_referenceId__c);
       System.assertEquals(null, insertedMsg.CCPM_referenceInfo__c);
       System.assertEquals(msgToInsert[0].CCPM_debugLevel__c, insertedMsg.CCPM_debugLevel__c);
       System.assertEquals('Error', insertedMsg.CCPM_debugLevel__c);
             
       List<LOG_LogMessage__c> msgToInsert3 = CCPM_LogMessageUtility.logMessage(exc, sourceComponent, 'Function1()', 'test logMessage', '<xml>payLoad</xml>',  9999, true);
       System.assert((msgToInsert3 != null) && (msgToInsert3.size() > 0));
       LOG_LogMessage__c insertedMsg3 = CCPM_TestDataUtility.getInsertedLog(msgToInsert3[0].Id);
       System.assert(insertedMsg3 != null);     
       System.assertEquals('<xml>payLoad</xml>', insertedMsg3.CCPM_integrationPayload__c);  
       
       LOG_LogMessage__c msgToInsert2 = CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'source function()', 'logMessage', '<payLoad/>', '[stack trace]', 100, 'Ref Id 00001', '00001', 'logCode',true);  
       LOG_LogMessage__c insertedMsg2 = CCPM_TestDataUtility.getInsertedLog(msgToInsert2.Id);              
       System.assert(insertedMsg2 != null);
       System.assert(!String.isBlank(insertedMsg2.CCPM_message__c));
       System.assertEquals(100, insertedMsg2.CCPM_timer__c);       
       System.assert(insertedMsg2.CCPM_stackTrace__c != null);
       //System.assertEquals(0, insertedMsg2.CCPM_age__c);
       System.assertEquals('Ref Id 00001',insertedMsg2.CCPM_referenceId__c);
       System.assertEquals('00001', insertedMsg2.CCPM_referenceInfo__c);
       System.assertEquals('Debug', insertedMsg2.CCPM_debugLevel__c);
       
       msgToInsert[0].Id = null;
       CCPM_LogMessageUtility.logMessage(msgToInsert[0]);
       
       LOG_LogMessage__c msgToInsert5 = CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', false); 
       System.assert(msgToInsert5.Id == null);
       msgToInsert5 = CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', true); 
       System.assert(msgToInsert5.Id != null);
       LOG_LogMessage__c insertedMsg5 = CCPM_TestDataUtility.getInsertedLog(msgToInsert5.Id); 
       System.assert(insertedMsg5 != null);
       System.assertEquals('Debug', insertedMsg5.CCPM_debugLevel__c);
       
      
       List<LOG_LogMessage__c> msgToInsert6 = CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', contactsToLog, true); 
       System.assert(msgToInsert6 != null);
       System.assert(msgToInsert6.size() == 2);
       System.assert(msgToInsert6[0].CCPM_referenceInfo__c.contains('Contact'));
       LOG_LogMessage__c insertedMsg6 = CCPM_TestDataUtility.getInsertedLog(msgToInsert6[0].Id); 
       System.assert(insertedMsg6 != null);
       LOG_LogMessage__c insertedMsg7 = CCPM_TestDataUtility.getInsertedLog(msgToInsert6[1].Id); 
       System.assert(insertedMsg7 != null);
       System.assertEquals('logCode', insertedMsg7.CCPM_logCode__c);
       
       LOG_LogMessage__c msgToInsert8 = CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', acc, true); 
       System.assert((msgToInsert8 != null) && (CCPM_TestDataUtility.getInsertedLog(msgToInsert8.Id) != null));       
       System.assert(msgToInsert8.CCPM_referenceInfo__c.contains('Account'));
       
       LOG_LogMessage__c msgToInsert9 = CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', true); 
       System.assert((msgToInsert9 != null) && (CCPM_TestDataUtility.getInsertedLog(msgToInsert9.Id) != null));
       
       LOG_LogMessage__c msgToInsert10 = CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Debug, sourceComponent, 'sourceFunction', 'logMessage', 'logCode', '<xml>payLoad</xml>', true); 
       System.assert((msgToInsert10 != null) && (CCPM_TestDataUtility.getInsertedLog(msgToInsert10.Id) != null));
       
       //test DML exception logging
       try{
           insert new Lead();
       }
       catch(DmlException dmlExc)
       {
            List<LOG_LogMessage__c> msgToInsertDml = CCPM_LogMessageUtility.logMessage(dmlExc, sourceComponent, 'Function1()', 'test logMessage', '<xml>payLoad</xml>',  9999, true);
            System.assert((msgToInsertDml != null) && (msgToInsertDml.size() > 0));   
           
            LOG_LogMessage__c insertedMsgDml = CCPM_TestDataUtility.getInsertedLog(msgToInsertDml[0].Id);
            System.assert(insertedMsgDml != null);    
            System.assert(insertedMsgDml.CCPM_message__c.contains('System.DmlException'));
            //System.assert(insertedMsgDml.CCPM_logCode__c.startsWith('REQUIRED_FIELD_MISSING'));
            System.assertEquals(insertedMsgDml.CCPM_sourceFunction__c, msgToInsertDml[0].CCPM_sourceFunction__c);
            System.assert((insertedMsgDml.CCPM_timer__c == msgToInsertDml[0].CCPM_timer__c) && (insertedMsgDml.CCPM_timer__c == 9999));
            System.assert(insertedMsgDml.CCPM_stackTrace__c != null);
       }
       
       Test.stopTest();
       
   }
    
   /********************************************************************************************************
   * @author        Karolinski Stephane
   * @date          2015-09-25
   * @description   This test method tests the Log Queuing functionality 
   * @return        void
   *********************************************************************************************************/
    @isTest
   public static void queueLogMessageTest() 
   {
       //Queue Log Message
       CCPM_LogMessageUtility.queueDMLRequests = true;
       
       //Log 2 messages
       CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Error, 'Queue Message', 'queueLogMessageTest', 'Test Log 1', true); 
       CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Error, 'Queue Message', 'queueLogMessageTest', 'Test Log 1', true); 
       
       //Check that no message has been logged at that stage
       List<LOG_LogMessage__c> insertedLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 5];
       System.assertEquals(0, insertedLogs.size());
       
       CCPM_LogMessageUtility.commitQueuedLogsToDatabase();
       
       //Check that the 2 Logs have been inserted and that the Queue is now empty
       insertedLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 5];
       System.assertEquals(2, insertedLogs.size());
       System.assertEquals(0,CCPM_LogMessageUtility.pendingLogsForUpsert.size());
       
       CCPM_LogMessageUtility.queueDMLRequests = false;
   }
    
   
   /********************************************************************************************************
   * @author        Deloitte
   * @description   Defines a custom exception class used to simulate the exception logMessage method overload
   * @date          2015-06-29
   * @group         Message Logs - Test Classes
   *********************************************************************************************************/
   private class MyException extends Exception {}

}