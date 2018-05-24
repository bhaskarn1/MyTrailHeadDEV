/**
*@name          CCPM_updateLeadType
*@author        Paras Shah (Deloitte)
*@date          3/20/2018
@description    Handler class to Process Converted Leads
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  	Date       			Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)        			3/20/2018    		Original Version					
*/
global class CCPM_updateLeadType implements Database.Batchable<sObject> {
    //global final string strQuery;
    global String strQuery = '';
    global String strLeadTypeProcessing = '';
    
    /**
*@author        Paras Shah (Deloitte)
*@description   This Constructor builds up the query to fetch the custom records that .
*@return        Void(None) 
*/ 
    global CCPM_updateLeadType(String strOpenClosedLeads){
        this.strLeadTypeProcessing = strOpenClosedLeads;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<String> setOpenLeadStatuses = CCPM_utility.setOpenLeadStatus;
        Set<String> setleadClosedStatus = CCPM_utility.setleadClosedStatus;
        
        if (strLeadTypeProcessing == 'OpenLeads') {
            this.strQuery = Label.CCPM_updateLeadTypeOneTimeRun;
            //this.strQuery = 'Select id,CCPM_type__c,CCPM_createdChannel__c,recordtype.name,CCPM_leadType__c from Lead where status in :setOpenLeadStatuses';
        } else if (strLeadTypeProcessing == 'ClosedLeads') {
            this.strQuery = Label.CCPM_updateLeadTypeOneTimeRun;
            //this.strQuery = 'Select id,CCPM_type__c,CCPM_createdChannel__c,recordtype.name,CCPM_leadType__c,CCPM_mobileNumber__c from Lead where status in :setleadClosedStatus';
        }
        return Database.getQueryLocator(strQuery);
    }
    
    /**
*@author        Paras Shah (Deloitte)
*@description   Execute method in batchable context to make a callout to the handler
*@return        Void(None)
*/    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        
        //Check if the parameter is not null and process it
        //List<Lead> lstUpdateLeadType = new List<Lead>();
        List<Lead> lstUpdateLeadType = new List<Lead>();
        Set<String> setMTN = new Set<String>();
        Map<String, Lead> mapOpenLeads = new Map<String, Lead>();
        
        for (Lead objLead: scope) {
            if (strLeadTypeProcessing == 'ClosedLeads') {
                if(objLead.CCPM_mobileNumber__c != null){
                    setMTN.add(objLead.CCPM_mobileNumber__c);	
                } 
            }
            
            if (objLead.CCPM_type__c == 'Manual Lead' && objLead.RecordType.Name == 'Customer Cart') {
                if (objLead.CCPM_createdChannel__c == 'Telesales') {
                    objLead.CCPM_leadType__c = 'Customer Telesales SFDC Manual';
                } else {
                    objLead.CCPM_leadType__c = 'Customer SFDC Manual';
                }
                
            } else if (objLead.CCPM_type__c == 'Prospect' && objLead.RecordType.Name == 'Prospect') {
                if (objLead.CCPM_createdChannel__c == 'Telesales') {
                    objLead.CCPM_leadType__c = 'Prospect Telesales SFDC Manual';
                } else {
                    objLead.CCPM_leadType__c = 'Prospect SFDC Manual';
                }
                
            } else if (objLead.CCPM_type__c == 'Prospect' && objLead.RecordType.Name == 'Prospect Cart') {
                if (objLead.CCPM_createdChannel__c == 'Digital') {
                    objLead.CCPM_leadType__c = 'Prospect Abandoned Cart Digital';
                } else if (objLead.CCPM_createdChannel__c == 'Retail') {
                    objLead.CCPM_leadType__c = 'Prospect Abandoned Cart Retail';
                }
                
            } else if (objLead.CCPM_type__c == 'Campaign Lead') {
                objLead.CCPM_leadType__c = 'Customer Campaign';
                
            } else if (objLead.CCPM_type__c == 'Quote Lead') {
                objLead.CCPM_leadType__c = 'Customer Quotes';
                
            } else if (objLead.CCPM_type__c == 'Abandoned Visit Lead') {
                objLead.CCPM_leadType__c = 'Customer Abandoned Visit';
                
            } else if (objLead.RecordType.Name == 'Customer Cart') {
                if (objLead.CCPM_createdChannel__c == 'Digital') {
                    objLead.CCPM_leadType__c = 'Customer Abandoned Cart Digital';
                } else if (objLead.CCPM_createdChannel__c == 'Retail') {
                    objLead.CCPM_leadType__c = 'Customer Abandoned Cart Retail';
                }
            } 
            lstUpdateLeadType.add(objLead);
        }
        
        if(lstUpdateLeadType.size()>0) {
            try {
                //Bulkified Update
                update lstUpdateLeadType;
            }
            Catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'One Time Run','Update Lead Type for Open Leads','Exception thrown while updating Lead Type',true);
            }
        }
        
        if (strLeadTypeProcessing == 'ClosedLeads') {
            //Code to update the existing open leads
            if(CCPM_Collection.isNotNullEmpty(setMTN)){
                Set<String> setOpenLeadStatus = CCPM_utility.setleadOpenStatus;
                List<String> lstNewMTN = new List<String>();
                lstNewMTN.addAll(setMTN);
                String strBuildSOSLQuery = 'FIND \''+String.join(lstNewMTN, ' OR ')+'\' IN PHONE FIELDS RETURNING LEAD (id,CCPM_mobileNumber__c WHERE Status IN :setOpenLeadStatus Order By CreatedDate ASC)';
                List<List<sObject>> lstSearchLead = Search.query(strBuildSOSLQuery);
                Map<Id, Lead> mapLead = new Map<Id, Lead>((List<Lead>)lstSearchLead[0]);
                for(Lead objLead : mapLead.values()){
                    if(!mapOpenLeads.containsKey(objLead.CCPM_mobileNumber__c)){
                        mapOpenLeads.put(objLead.CCPM_mobileNumber__c, new Lead(id=objLead.id));
                    }
                }
            } 
            //******to get a difference in time between converted leads and Open leads			
            Datetime timeToUpdate = System.now().addSeconds(Integer.valueOf(Label.CCPM_openLeadsUpdateGap));
            while(System.now() < timeToUpdate){
            } 
            
            //******end
            List<LOG_LogMessage__c> lstBatchLogMsg = new List<LOG_LogMessage__c>();
            try{
                if(CCPM_Collection.isNotNullEmpty(mapOpenLeads.values())){
                    update mapOpenLeads.values();
                }
            }
            catch(Exception e)
            {
                //boolContinue = false;
                lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while updating the Open Lead records',''));
            }
        }
        
    }
    
    /**
*@author        Paras Shah (Deloitte)
*@description   This method schedules the Batch class for every 5 min(Need to confirm)
*@return        Void(None)
*/     
    global void finish(Database.BatchableContext BC){
        
    }
}