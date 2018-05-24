/**
@author        Manjunath Keshava (Deloitte)
@description	Update the Cart unique ID for Prospects and Manual Leads
@param         None
@return          
*/ 
global with sharing class CCPM_ProspectManualLeadUpdateBatch implements Database.Batchable<sObject>,Database.Stateful  
{
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        // Set of Strings for the lead open status
        set<string> setOpenLeadStatus = CCPM_staticConstants.setOpenLeadStatus;
        string strProspectRecordType =Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId();
        //string strLeadRecordType=Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId();
        String strquery = label.CCPM_PropsectNullCartUniqueIdQuery;
        return Database.getQueryLocator(strquery);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope ) 
    {
            list<lead> lstUpdatedLead = new list<lead>();
        for(Lead objLead:scope)
        {
            string strTimeStamp = string.valueOf(system.now());
            string strMtn= objlead.CCPM_mobileNumber__c;
            string strcartUniqueID= strTimeStamp + strMtn;
            objlead.CCPM_cartUniqueID__c=CCPM_EncryptKey.CCPM_EncryptKey(strcartUniqueID);
            lstUpdatedLead.add(objLead);
        }
        if(lstUpdatedLead!=null && lstUpdatedLead.isEmpty()==false)
        {
            //used to run the batch for all the records except the failed records
            Database.SaveResult[] updateLeadData = Database.update(lstUpdatedLead, false);  
            for (Database.SaveResult objresult : updateLeadData) {
                if (!objresult.isSuccess())
                {
                    for (Database.Error objerror : objresult.getErrors())
                    {
                        System.debug('Error: '+ objerror.getStatusCode() + ' ' + objerror.getMessage());
                    }
                }
            }
            
            
        }
    }
    
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    
}