/**
*@name          CCPM_updateAccountUniqueIDBatchHandler
*@author        Sriraman Sridharan (Deloitte)
*@date          11/02/2017 
@description    Handler class to the Batch Job to update account unique ID's for 11/02/2017
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  Date       		Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        11/02/2017     		Original Version							
*/
 
public class CCPM_updateAccountUniqueIDBatchHandler {
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method processes Account records and updates the account unique ID's
*@Params		List<Account> 
*@return        Void(None)
*/ 
    
    Public static void processAccounts(List<Account> lstAccounts){
        
        For(Account objAccount : lstAccounts){
            if(objAccount.CCPM_accountUniqueID__c == null && String.isEmpty(objAccount.CCPM_accountUniqueID__c)){
                string strTimeStamp = string.valueOf(system.now());
                string strMtn= objAccount.CCPM_mobileNumber__c;
                string strAccountUniqueID= strTimeStamp + strMtn; 
                //system.debug('strAccountUniqueID :' + strAccountUniqueID);
                objAccount.CCPM_accountUniqueID__c = CCPM_EncryptKey.CCPM_EncryptKey(strAccountUniqueID); 
            }
        }
        try{
            if(lstAccounts!=null && lstAccounts.isEmpty()==false)
            {
            	update lstAccounts;
            }
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_updateAccountUniqueIDBatchHandler',
                                              'processAccounts',
                                              'Exception thrown while updating accounts',true);
        }
    }
}