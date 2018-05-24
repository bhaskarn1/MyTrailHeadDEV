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
public with sharing class CCPM_leadsAwaitingChildStatusApexCon {
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Method that queries for Metadata settings to get the Limit in the query being used,Order By Field,Order
*@return        Metadata
*/ 
    @AuraEnabled
    public static Map<String,String> createSubStatusMap(){
        Map<String,String> mapSubStatusSelectOption = new Map<String,String>();
        string strSubStatus = Label.CCPM_qualifiedSubStatus;
        list<String> lstSubStatus = new list<String>();
        lstSubStatus = strSubStatus.split(',');
        mapSubStatusSelectOption.put('--Select--','--Select--');
        for(String strOptions : lstSubStatus)
        {
            mapSubStatusSelectOption.put(strOptions,strOptions);
        }
        
        return mapSubStatusSelectOption;
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Method that saves the lead with appropriate Status And SubStatus
*@return        String
*/   
    @AuraEnabled
    public static String saveLeadServer(String strSubStatusToSave,Lead objLead){
        string strReturn='';
        try{
            objLead.Status=CCPM_staticConstants.strLeadStatusQualified;
            objLead.CCPM_leadSubStatus__c=strSubStatusToSave;
            update objLead;
            strReturn='Success';
            
        }
        catch (Exception e) {
            String strdmlMessage;
            DmlException objdmlExc = (DmlException) e;
            for (integer i= 0; i<objdmlExc.getNumDml(); i++)
            {
                strdmlMessage =    objdmlExc.getDmlMessage(i);
            }
            strReturn='Failed';
            throw new AuraHandledException(strdmlMessage);
        } 
        
        return strReturn;
    }
    
    /**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This Method checks if the current user is allowed to lead status update.
*@return        Boolean
*/  
    @AuraEnabled
    public static Boolean profileRestrictedfromLeadStatusUpdate() {
        list<String> lstRestrictedProfilesFromStatusUpdate = CCPM_utility.getListFromString(Label.CCPM_restrictedProfilesFromLeadStatusUpdate,',');
        Map<String, String> mapProfileIDName = CCPM_utility.getProfileIdNameMap(); 
        
        Boolean isProfileRestricted = lstRestrictedProfilesFromStatusUpdate.contains(mapProfileIDName.get(userinfo.getProfileId())) ? true : false;
        return isProfileRestricted;
    }   
}