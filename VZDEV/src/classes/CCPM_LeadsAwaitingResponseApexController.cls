/**
*@name          CCPM_myActiveLeadsApexController
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          12/07/2017
*@description   For "My Active Leads" Component in UI
Modification    Log:
------------------------------------------------------------------------------------
Developer                      				  Date               Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)             12/07/2017         Original Version       
*/
public with sharing class CCPM_LeadsAwaitingResponseApexController {
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Method that queries and Loads data for Lead
*@return        wrapperClass
*/ 
    @AuraEnabled
    public static CCPM_leadsAwaitingResponseWrapper loadComponentWithRecords(string strSortBy,string strOrderby,string strLimit,string strOffSet){
        CCPM_leadsAwaitingResponseWrapper objwrapperClass = new CCPM_leadsAwaitingResponseWrapper();
        list<Lead> lstlead = new list<Lead>();
        List<CCPM_leadWrapper> lstLeadAndSMSOptns = new List<CCPM_leadWrapper>();
        CCPM_UIComponentSetting__mdt mdtUIComponentSetting=new CCPM_UIComponentSetting__mdt();
        System.debug('Values in Sort->'+strSortBy+strOrderby+strLimit+strOffSet);
        if(String.isBlank(strSortBy) || String.isBlank(strOrderby) || String.isBlank(strLimit))
        {
            mdtUIComponentSetting= CCPM_LeadsAwaitingResponseApexController.setQueryParam();
            strSortBy=mdtUIComponentSetting.CCPM_orderByField__c;
            strOrderby=mdtUIComponentSetting.CCPM_order__c;
            strLimit=mdtUIComponentSetting.CCPM_recordLimit__c;
        }
        
        integer intMaxSize= database.countQuery('select count() from Lead where Status=\''+CCPM_staticConstants.strLeadStatusResponded+'\' and CCPM_leadSubStatus__c=\''+CCPM_staticConstants.strLeadSubStatusActionRequired+'\'');
        objwrapperClass.intMaxSize=intMaxSize;
        string queryInitialString ='SELECT Id,CCPM_ownerEcode__c,CCPM_storeEcode__c,RecordTypeId,CCPM_firstPredefinedSMSFlag__c,CCPM_finalPreDefinedSMSFlag__c,Name,CCPM_mobileNumber__c,CCPM_SMSResponseReceivedDateTime__c,owner.name,CCPM_Type__c,CCPM_SMSFollowUpDate__c,CCPM_leadSubStatus__c,Status,CCPM_eventType__c, (select Id,Description,CreatedDate,CCPM_communicationDirection__c from tasks order by createddate desc) from lead where Status=\''+CCPM_staticConstants.strLeadStatusResponded+'\' and CCPM_leadSubStatus__c=\''+CCPM_staticConstants.strLeadSubStatusActionRequired+'\''+' ORDER BY '+strSortBy+' '+strOrderby+' NULLS LAST LIMIT '+strLimit+ ' OFFSET '+strOffSet;
        //where CCPM_communicationDirection__c=\''+ CCPM_staticConstants.strTaskCommunicationDirection+'\'
        System.debug('queryInitialString->+'+queryInitialString);
        for(Lead objLead : Database.query(queryInitialString)){
            boolean boolNeedsAttention = false;
            if(objLead.CCPM_SMSResponseReceivedDateTime__c!=null && objLead.CCPM_SMSResponseReceivedDateTime__c.addHours(6)<System.now())
            {
                boolNeedsAttention=true;
            }
            lstLeadAndSMSOptns.add(new CCPM_leadWrapper(objLead,boolNeedsAttention));
            system.debug('SMSResponse Received->'+objLead.CCPM_SMSResponseReceivedDateTime__c);
        }
        System.debug('lstLeadAndSMSOptns->'+lstLeadAndSMSOptns);
        if(lstLeadAndSMSOptns.size() > 0)
        {
            objwrapperClass.lstLeadWrapper=lstLeadAndSMSOptns;
        }
        if(mdtUIComponentSetting!=null)
        {
            objwrapperClass.metadataSettings=mdtUIComponentSetting;
        }
        
        return objwrapperClass;    
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Method that queries for Metadata settings to get the Limit in the query being used,Order By Field,Order
*@return        Metadata
*/ 
    @AuraEnabled
    public static CCPM_UIComponentSetting__mdt setQueryParam(){
        CCPM_UIComponentSetting__mdt mdtActiveLeadSettings = new CCPM_UIComponentSetting__mdt();
        mdtActiveLeadSettings = [select CCPM_orderByField__c,CCPM_order__c,CCPM_recordLimit__c from CCPM_UIComponentSetting__mdt where DeveloperName =:Label.CCPM_UIHomePageLARLabel];
        System.debug('Metadata Values returned from query->'+mdtActiveLeadSettings);
        return mdtActiveLeadSettings;
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Wrapper class to provision a datastructure containing collection of Objects
*@return        None
*/ 
    public class CCPM_leadsAwaitingResponseWrapper{
        @AuraEnabled public List<CCPM_leadWrapper> lstLeadWrapper{get;set;}
        @AuraEnabled public CCPM_UIComponentSetting__mdt metadataSettings{get;set;}
        @AuraEnabled public Integer intMaxSize{get;set;}
        
        // @AuraEnabled public Map<String,String> mapQualifiedSubStatus{get;set;}
        
        /*public CCPM_leadsAwaitingResponseWrapper()
{
mapQualifiedSubStatus = new Map<String,String>();
string strSubStatus = Label.CCPM_qualifiedSubStatus;
list<String> lstSubStatus = new list<String>();
lstSubStatus = strSubStatus.split(',');

for(String strOptions : lstSubStatus)
{
mapQualifiedSubStatus.put(strOptions,strOptions);
}
}*/
        
        
    }  
    
    /**
*@author        Bharath Ammanamanchi (Deloitte)
*@description   Wrapper class to provision a datastructure containing collection of Objects
*@return        None
*/ 
    public class CCPM_leadWrapper{
        @AuraEnabled public Lead objLead{get;set;}
        @AuraEnabled public Map<String, String> mapSmsMessage{get;set;}
        @AuraEnabled public boolean booldoesNeedAttention{get;set;}
        @AuraEnabled public boolean boolShowPopUp{get;set;}
        
        
        public CCPM_leadWrapper(Lead objLeadIn, boolean booldoesNeedAttentionIn){
            objLead = new Lead();
            objLead = objLeadIn;
            booldoesNeedAttention=booldoesNeedAttentionIn;
            boolShowPopUp=false;
            mapSmsMessage = new Map<String, String>();
            if(Label.CCPM_none!=null)
            {
                mapSmsMessage.put(Label.CCPM_none, Label.CCPM_none);
                
                
            }
            if(CCPM_Collection.isNotNullEmpty(CCPM_utility.lstPreDefinedSMSRecords) && !objLeadIn.CCPM_finalPreDefinedSMSFlag__c){
                for(CCPM_promoMessage__mdt mdtPM : CCPM_utility.lstPreDefinedSMSRecords){
                    if(mdtPM.MasterLabel != 'Custom Reply'){
                        String strMsg = '';
                        if(objLeadIn.CCPM_firstPredefinedSMSFlag__c){
                            if(mdtPM.CCPM_finalPreDefinedResponse__c){
                                strMsg = getSMSPickListDisplayValue(objLead, mdtPM);
                            }
                        }
                        else {
                            if(mdtPM.CCPM_firstPreDefinedResponse__c){
                                strMsg = getSMSPickListDisplayValue(objLead, mdtPM);
                            }
                        }
                        if(String.isNotBlank(strMsg)){
                            mapSmsMessage.put(mdtPM.DeveloperName, strMsg);
                        }
                    }
                }            
            }	
            System.debug('MapSMSMessage->'+mapSmsMessage);
        }
        
        public String getSMSPickListDisplayValue(Lead objLead, CCPM_promoMessage__mdt mdtPM){
            String strLeadCustomerCartRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
            String strLeadCustomerAbandonedVisit = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerAbandonedVisitlead).getRecordTypeId();
            String strLeadCustomerQuoteRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_CustomerQuotesRT).getRecordTypeId();
            Set<String> setCustomerRecordTypeids = new Set<String>{strLeadCustomerCartRT,strLeadCustomerAbandonedVisit,strLeadCustomerQuoteRT};
            String strMsg = mdtPM.MasterLabel;
            if(mdtPM.CCPM_dispalyOrignialMessage__c){
                if(objLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId()){
                    strMsg = CCPM_utility.checkForDynamicContentInMsg('', mdtPM.CCPM_messageContentForProspects__c);    
                }
                else if(setCustomerRecordTypeids.contains(objLead.RecordTypeId)){
                    strMsg = CCPM_utility.checkForDynamicContentInMsg('(FreeVzMsg)', mdtPM.CCPM_MessageContentForLeads__c);
                }    
            }
            return strMsg;
        }
    }
    
    @AuraEnabled
    public static Boolean getUserRole() {
        
        Boolean result = false;
        String roleId = userinfo.getUserRoleId();       
        if (String.isNotBlank(roleId)) {
            userRole objRole = [Select id, name 
                                From UserRole 
                                where id=:UserInfo.getUserRoleId()];
            
            if (objRole != null && (objRole.name.tolowercase().contains('solutions') 
                                    || objRole.name.tolowercase().contains('solutions'))) {
                                        result = true;
                                    }
        }
        return result;
    }
    
}