/********************************************************************************************************
* @author       Deloitte
* @description  This is the test class of the LOG_DeleteMessagesScheduler and LOG_DeleteLogMessagesBatch classes
* @date         2015-06-29
* @group        Message Logs - Test Classes
*********************************************************************************************************/
@isTest 
public class CCPM_deleteLogMessagesSchedulerTest
{
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This test method is testing the execution of the batch apex via the delete log messages scheduler class
    * @return       void
    *********************************************************************************************************/
    public static testmethod void CCPM_DeleteLogMessagesSchedulerTest()
    {
        // Initialize the LOG_MessageSettings
        CCPM_TestDataUtility.generateErrorMgtCustomSetting(true,true,true,true,-1);      

        // Create a LOG_LogMessage__c
        CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Info,'Source','Source Function','Message',True);
        CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Info,'Source','Source Function','Message',True);
   
        Test.StartTest();
        
        // Schedule a batch
        CCPM_DeleteLogMessagesScheduler logScheduler = new CCPM_DeleteLogMessagesScheduler();         
        logScheduler.execute(null);
        
        Test.stopTest();
        
        //Confirm that the Logs have been deleted
        List<LOG_LogMessage__c> remainingLogs = [SELECT Id FROM LOG_LogMessage__c LIMIT 10];
        System.assertEquals(1, remainingLogs.size()); //Actual result must be of size 1 since a new log is generated after the batch execution  
    }
}