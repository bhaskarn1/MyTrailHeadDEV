/********************************************************************************************************
* @author       Deloitte
* @description  This class is the implementation of the batchable interface and allows to run a batch apex
*               allowing to delete old messages. The Database.Stateful insterface is also implemented in order
*               to ensure instance variable are not resetted between batch jobs
* @date         2015-06-26
* @group        Message Logs
*********************************************************************************************************/
global class CCPM_deleteLogMessagesBatch implements database.batchable<sObject>, Database.Stateful

{
    //***************************************** PRIVATE PROPERTIES***************************************** 
    
    // Store the number of logs that will be deleted
    private Integer totalBatchSize;
    
    // String used to query the records that need to be deleted
    private String queryString;
    
    //***************************************** PUBLIC METHODS***************************************** 
    
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This is the constructor of the Batch Apex class provding as input the query to be performed to 
    *               identify the records to be deleted.
    * @param        st (String): the SOQL query to be executed. All the records returned by this query will be deleted
    * @return       void
    *********************************************************************************************************/
    public CCPM_DeleteLogMessagesBatch(String st)
    {
        queryString = st;
    }

    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This is the implementation of th start method of the batchable interface which initializes the batch
    *               and returns the querylocator of the SOQL query provided as input of the class constructor
    * @param        bc (database.batchableContext): the context of the batch
    * @return       database.querylocator: the query locator of the SOQL query provided as input of the class constructor
    *********************************************************************************************************/    
    global database.querylocator start(database.batchableContext bc)
    {        
        totalBatchSize = 0;
        return database.getquerylocator(queryString);        
    }
    
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This is the implementation of the execute method of the batchable interface which performs the deletion
    *               of the old records
    * @param        bc (database.batchableContext): the context of the batch
    * @param        lmsg (List<LOG_LogMessage__c>): the messages to be deleted part of the batch
    * @return       void
    *********************************************************************************************************/    
    global void execute(database.batchablecontext bc, List<LOG_LogMessage__c> lmsg)
    {        
        try
        { 
            delete lmsg;
            totalBatchSize += lmsg.size();
            
        } 
        catch(Exception e) 
        {
            CCPM_LogMessageUtility.logMessage(e,'Apex Batch - Delete Old Log Messages','LOG_DeleteLogMessagesBatch.execute','Unexpected exception while deleting Error Logs',True);        
        }
    }
    
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This is the implementation of the finish method of the batchable interface which is logging the outcome of the batch 
    * @param        bc (database.batchableContext): the context of the batch
    * @return       void
    *********************************************************************************************************/    
    public void finish(database.batchableContext bc)
    {
        CCPM_LogMessageUtility.logMessage(CCPM_LogMessageUtility.LOG_LogLevel.Info,'Apex Batch - Delete Old Log Messages','LOG_DeleteLogMessagesBatch.finish','Batch "Delete Old Log Messages" executed. Total number of logs deleted: ' + totalBatchSize,True);
    }

}