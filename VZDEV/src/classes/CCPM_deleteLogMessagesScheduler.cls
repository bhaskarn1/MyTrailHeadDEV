/********************************************************************************************************
* @author         Deloitte
* @description    This class is the implementation of the Schedulable interface and allows to schedule a job in 
*                 order to delete old messages
* @date           2015-06-26
* @group          Message Logs
*********************************************************************************************************/
global class CCPM_deleteLogMessagesScheduler implements Schedulable 
{
    
    // Fetch the Log Message Custom Settings in order to retrieve the Log_Purge__c
    private CCPM_logLevelSetting__c lms = CCPM_LogMessageUtility.getLogSettings();
    
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method is the implementation of the Schedule interface and invokes a Batch apex in order
    *               to delete old messages
    * @param        sc (SchedulableContext): the context of the scheduled job
    * @return       void
    *********************************************************************************************************/
    global void execute(SchedulableContext sc)
    {
        String queryString = 'SELECT  id, CCPM_age__c from LOG_LogMessage__c WHERE CCPM_age__c > ' + lms.CCPM_purgeLogAfter__c;
        Database.executeBatch(new CCPM_DeleteLogMessagesBatch(queryString), 200);
    }
}