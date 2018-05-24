/********************************************************************************************************
* @author       Deloitte
* @description  This test class is the framework used to generate test data to be used by the other test classes
* @date         2015-06-29
* @group        Message Logs - Test Classes
*********************************************************************************************************/
@isTest
public class CCPM_testDataUtility {
   
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method generates a Log Message Custom setting with the parameters provided as input
    * @param        error (Boolean): indicates if the error logs must be logged
    * @param        warning (Boolean): indicates if the warning logs must be logged
    * @param        info (Boolean): indicates if the info logs must be logged
    * @param        debug (Boolean): indicates if the debug logs must be logged
    * @param        logPurge (Boolean): the number of day before the log messages must be deleted
    * @return       void
    *********************************************************************************************************/
    public static CCPM_logLevelSetting__c generateErrorMgtCustomSetting(Boolean error, Boolean warning , Boolean info, Boolean debug, Integer logPurge)    
    {
       //insert custom setting
       CCPM_logLevelSetting__c setg = new CCPM_logLevelSetting__c();
       setg.Name = 'Default';
       setg.CCPM_IsDebugLogged__c = debug;
       setg.CCPM_isErrorLogged__c = error;
       setg.CCPM_isInfoLogged__c = info;
       setg.CCPM_isWarnLogged__c = warning;
       setg.CCPM_purgeLogAfter__c = logPurge;
       insert setg;
        
       return setg;
    }
 
    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method generates a list of test accounts
    * @param        nrOfAccounts (integer): the number of accounts to be created
    * @param        nameRoot (String): the rootname of the accounts being generated
    * @param        executeInsert (Boolean): True of the DML insert must be executed or not, False otherwise
    * @return       List<Account>: the list of generated accounts
    *********************************************************************************************************/
    public static List<Account> generateAccounts(integer nrOfAccounts, String nameRoot, Boolean executeInsert)
    {
        List<Account> accList = new List<Account>();
        for (integer i=1; i<= nrOfAccounts; i++)
        {
            Account acc = new Account();
            acc.Name = nameRoot + ' - ' + String.valueOf(i);
            acc.CCPM_accountNumber__c=''+i;
            accList.add(acc);
        }
        if (executeInsert)
            insert accList;
        
        return accList;
    }

    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method generates a list of test contacts
    * @param        nrOfContacts (integer): the number of contacts to be created
    * @param        nameRoot (String): the rootname of the contacts being generated
    * @param        linkToAccount (Account): the account to which the contact must be linked to
    * @param        executeInsert (Boolean): True of the DML insert must be executed or not, False otherwise
    * @return       List<Contact>: the list of generated contacts
    *********************************************************************************************************/
    public static List<Contact> generateContacts(integer nrOfContacts, String nameRoot, Account linkToAccount, Boolean executeInsert)
    {
        List<Contact> ctcList = new List<Contact>();
        
            Contact ctc = new Contact();
            ctc.AccountId = linkToAccount.Id;
            ctc.LastName = nameRoot;
            Contact ctc2 = new Contact();
            ctc2.AccountId = linkToAccount.Id;
            ctc2.LastName = nameRoot + 'b';
            
            ctcList.add(ctc);
         	ctcList.add(ctc2);
 
        
        if (executeInsert)
            insert ctcList;
        
        return ctcList;
    }

    /********************************************************************************************************
    * @author       Karolinski Stephane
    * @date         2015-08-17
    * @description  This method retireves the logMessage specified by the provided SFDC Id
    * @param        logId (Id): the SFDC Id of the Log message to be retrieved
    * @return       LOG_LogMessage__c: the Queried Log Message
    *********************************************************************************************************/ 
    public static LOG_LogMessage__c getInsertedLog(Id logId){
       LOG_LogMessage__c insertedMsg = [SELECT  CCPM_age__c,CCPM_debugLevel__c, Id, CCPM_logCode__c, CCPM_message__c, Name, CCPM_referenceId__c, CCPM_referenceInfo__c, CCPM_source__c, CCPM_sourceFunction__c, CCPM_stackTrace__c, CCPM_timer__c, CreatedDate, CCPM_integrationPayload__c   
                                        FROM LOG_LogMessage__c
                                        WHERE Id = :logId
                                       LIMIT 1];
        return insertedMsg;
    }
     
}