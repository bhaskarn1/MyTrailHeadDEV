/**
*@name          CCPM_myActiveLeadsApexController
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          12/07/2017
*@description   For "My Active Leads" Component in UI
Modification    Log:
------------------------------------------------------------------------------------
Developer                                     Date               Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)             12/07/2017         Original Version       
*/
public with sharing class CCPM_myActiveLeadsApexController {
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Method that queries and Loads data for Lead
*@return        wrapperClass
*/ 
    @AuraEnabled
    public static myActiveLeadswrapper loadComponentWithRecords(string strSortBy,string strOrderby,string strLimit,string strOffSet){
        //Instantiate Wrapper Class
        myActiveLeadswrapper objwrapperClass = new myActiveLeadswrapper();
        //Instantiate a list of Leads
        list<Lead> lstlead = new list<Lead>();
        //Instantiate Metadata settings
        CCPM_UIComponentSetting__mdt mdtUIComponentSetting=new CCPM_UIComponentSetting__mdt();
        //Check if the values from attributes are null for the initial Load and obtain settings from metadata
        if(String.isBlank(strSortBy) || String.isBlank(strOrderby) || String.isBlank(strLimit))
        {
            mdtUIComponentSetting= CCPM_myActiveLeadsApexController.setQueryParam();
            strSortBy=mdtUIComponentSetting.CCPM_orderByField__c;
            strOrderby=mdtUIComponentSetting.CCPM_order__c;
            strLimit=mdtUIComponentSetting.CCPM_recordLimit__c;
        }
        //Get the total number of records in the expected Status in order to calculate offset for Pagination
        integer intMaxSize= database.countQuery('select count() from Lead where Status =\''+CCPM_staticConstants.strLeadStatusContacted +'\' or Status=\''+CCPM_staticConstants.strLeadStatusEligible+'\' or (Status=\''+CCPM_staticConstants.strLeadStatusQualified+'\' and (CCPM_leadSubStatus__c=\''+CCPM_staticConstants.strLeadSubStatusInDiscussion+'\' or CCPM_leadSubStatus__c=\'' +CCPM_staticConstants.strLeadSubStatusAppointmentScheduled+'\'))');
        objwrapperClass.intMaxSize=intMaxSize;
        //Build the Query String
        string queryInitialString ='SELECT Id,Name,Status,CCPM_mobileNumber__c,Owner.Name ,CCPM_Type__c,CCPM_SMSFollowUpDate__c,CCPM_leadSubStatus__c ,CCPM_eventType__c, (select Campaign.name from CampaignMembers order by createddate asc limit 1) from lead where Status =\''+CCPM_staticConstants.strLeadStatusContacted +'\' or Status=\''+CCPM_staticConstants.strLeadStatusEligible+'\' or (Status=\''+CCPM_staticConstants.strLeadStatusQualified+'\' and (CCPM_leadSubStatus__c=\''+CCPM_staticConstants.strLeadSubStatusInDiscussion+'\' or CCPM_leadSubStatus__c=\'' +CCPM_staticConstants.strLeadSubStatusAppointmentScheduled+'\'))'+' ORDER BY '+strSortBy+' '+strOrderby+' NULLS LAST LIMIT '+strLimit+ ' OFFSET '+strOffSet;
    	System.debug('queryInitialString'+queryInitialString);
        //Obtain results from the query into the List of Leads   
        lstlead=Database.query(queryInitialString);
        if(lstlead.size()>0)
        {
            objwrapperClass.lstLead=lstlead;
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
        //Obtain the metadata settings to set the initial Attributes
        mdtActiveLeadSettings = [select CCPM_orderByField__c,CCPM_order__c,CCPM_recordLimit__c from CCPM_UIComponentSetting__mdt where DeveloperName =:Label.CCPM_UIHomePageMyActiveLeadsLabel];
        System.debug('Metadata Values returned from query->'+mdtActiveLeadSettings);
        return mdtActiveLeadSettings;
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Wrapper class to provision a datastructure containing collection of Objects
*@return        None
*/ 
    public class myActiveLeadswrapper{
        @AuraEnabled public List<Lead> lstLead{get;set;}
        @AuraEnabled public CCPM_UIComponentSetting__mdt metadataSettings{get;set;}
        @AuraEnabled public Integer intMaxSize{get;set;}
        
    }  
    
    
}