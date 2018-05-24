/**
*@name          CCPM_accountHandler
*@author        Deepak Mazumdar (Deloitte)
*@date          1/31/2017
@description    Handler class for CCPM_account trigger
@testClass      CCPM_accountHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Deepak Mazumdar(Deloitte)       1/31/2016                           Original Version
Sriraman Sridharan(Deloitte)    1/31/2016                           Original Version
Manjunath Keshava(Deloitte)     07/14/2017                          Added Null checks (US-1618)
Aneesha Ragireddy				7/13/2017							initial version insertRecordstoCustomObject
Sriraman Sridharan(Deloitte)    7/18/2017                           Updated Version insertRecordstoCustomObject
Paras Shah(Deloitte)			12/15/2017							Added a change to populate the Queue Type for Processing Queue object
*/
public class CCPM_accountHandler {
    public static List<LOG_LogMessage__c> lstleadhdlrLogMsg = new List<LOG_LogMessage__c>();
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method populates store reference based on store id
@param         list of new accounts and list of old accounts
@return        Void(None)
*/  
    public static void populateStoreBasedOnStoreId(list<Account> lstNewAccounts, list<Account> lstOldAccounts){
        // Contains the store records of the StoreID from the List of accounts
        List<CCPM_Store__c> lstStoreRecords=new  List<CCPM_Store__c>() ;
        // Contains the StoreId's from the list of accounts
        Set<String> storeIDs                    = new Set<String>();
        // Map of the StoreId's and the SFDC Id's from the store records
        Map<String, ID> storeIdToSFDCStoreID    = new Map<String, ID>();
        
        // This condition checks if its triggered is on Update
        if(lstOldAccounts != null && !lstOldAccounts.isEmpty())
        {
            for(Integer i=0;i<lstNewAccounts.size();i++){
                if(lstNewAccounts[i].CCPM_storeID__c!=lstOldAccounts[i].CCPM_storeID__c)
                {
                    if(lstNewAccounts[i].CCPM_storeID__c!=null)
                    {
                        storeIDs.add(lstNewAccounts[i].CCPM_storeID__c);
                    }
                    else{
                        lstNewAccounts[i].CCPM_store__c = null;
                    }
                } 
            }
        }
        // This condition checks if its triggered is on Insert
        else{
            if(lstNewAccounts!=null && !lstNewAccounts.isEmpty())
            {
                for(Account acc : lstNewAccounts)
                {
                    if( acc.CCPM_mobileNumber__c!= NULL )
                    {
                        acc.CCPM_mobileNumber__c = acc.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits,'');
                    } 
                    storeIDs.add(acc.CCPM_storeID__c);
                }
            }
        }
        
        // Query for the store records using the storeID's from the store object using the StoreId's from the list of accounts
        try{
            if(storeIDs!=null && !storeIDs.isEmpty())
                lstStoreRecords = [Select   Id, 
                                   Name, 
                                   CCPM_storeID__c 
                                   FROM     CCPM_Store__c 
                                   WHERE    CCPM_storeID__c IN: storeIDs];
        }
        catch(Exception e){
            
            CCPM_LogMessageUtility.logMessage(e,'CCPM_accountHandler','populateStoreBasedOnStoreId','Exception thrown while querying for store records',true);
        }
        
        
        // Iterate through the list of store records and populate the storeIdToSFDCStoreID map with StoreID's and the SFDC ID's of Stores
        if(lstStoreRecords!=null && !lstStoreRecords.isEmpty())
        {
            for(CCPM_Store__c Store : lstStoreRecords)
            {
                if(!storeIdToSFDCStoreID.containsKey(Store.CCPM_storeID__c)) 
                {
                    storeIdToSFDCStoreID.put(Store.CCPM_storeID__c, Store.Id );
                }
            } 
        }
        
        // Iterate through the list of accounts and update the store lookup field  using the storeIdToSFDCStoreID Map
        for(Account acc : lstNewAccounts)
        {
            if(storeIdToSFDCStoreID.containsKey(acc.CCPM_storeID__c) && storeIdToSFDCStoreID.get(acc.CCPM_storeID__c)!= null)
            {
                //if(storeIdToSFDCStoreID.get(acc.CCPM_storeID__c)!= null)
                acc.CCPM_store__c = storeIdToSFDCStoreID.get(acc.CCPM_storeID__c);
            }
        }
        
    }
    
    /**
@author        Sriraman Sridharan/Aneesha Ragireddy (Deloitte)
@description   This method inserts records in the custom object if the customer is opted out
@param         list of new accounts and list of old accounts
@return        Void(None)
*/  
    public static void insertRecordstoCustomObject(Map<Id,Account> mapNew, Map<Id,Account> mapOld)
    {
        List<CCPM_processingQueue__c> lstSMSSchedules = new List<CCPM_processingQueue__c>();
        set<string> setOpenStatus = ccpm_utility.setleadOpenStatus;
        if(CCPM_Collection.isNotNullEmpty(mapNew)){
            for(Account objAcc : [Select Id, (Select Id From Leads__r Where ccpm_type__c = 'Manual Lead' and Status in :setOpenStatus) From Account Where Id IN :mapNew.keySet()]){
                Account objAccNew = mapNew.get(objAcc.Id);
                Account objAccOld = mapOld.get(objAcc.Id);
                if((!CCPM_Collection.isNotNullEmpty(objAcc.Leads__r)) && objAccNew.CCPM_SMSOptOut__c != objAccOld.CCPM_SMSOptOut__c && objAccNew.CCPM_SMSOptOut__c == true){
                    lstSMSSchedules.add(new CCPM_processingQueue__c(CCPM_accountUniqueID__c = objAccNew.CCPM_accountUniqueID__c,
                                                                    CCPM_storeID__c = objAccNew.CCPM_storeID__c,
                                                                    CCPM_InsertedDateTime__c = system.now(),
                                                                    CCPM_Status__c = Label.CCPM_LeadNewStatus,
                                                                    CCPM_queueType__c    = Label.CCPM_SMSSchedulesToBeRemoved,
                                                                    CCPM_SObjectType__c = 'Account'));
                }
            }
        }
        
        try{
            if(CCPM_Collection.isNotNullEmpty(lstSMSSchedules)){
                insert lstSMSSchedules;
            }
            
        }catch(Exception e){
            LOG_LogMessage__c log = CCPM_utility.logMessage(e,'Error','CCPM_accountHandler','BeforeUpdate','Exception thrown while querying for Accounts','');
            lstleadhdlrLogMsg.add(log);
        }  
        
        if(CCPM_Collection.isNotNullEmpty(lstleadhdlrLogMsg)){
            upsert lstleadhdlrLogMsg;
        }
    }
}