/**
*@name          CCPM_customHomePageController
*@author        Paras Shah (Deloitte)
*@date          03/30/2017
*@description   For Dispalying the "Qualified" Leads on the Home Page
*@testClass     CCPM_pullDetailsToDisplayOnChartControllerTest

Modification    Log:
------------------------------------------------------------------------------------
Developer                        Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)             03/30/2017                          Original Version
*/

public with Sharing class CCPM_customHomePageController {

        @AuraEnabled
        public static String  strProfileName{get;set;}
        @AuraEnabled
        public static String  strUserRoleName {get;set;}
        @AuraEnabled
        public static String  strUserStoreRoleName {get;set;}
        @AuraEnabled
        public static boolean boolStrProfileSystemAdministrator {get;set;}
        @AuraEnabled       
        public static boolean boolStrUserStoreRoleName {get;set;}
        @AuraEnabled
        public static boolean boolStrUserRoleName {get;set;}
        @AuraEnabled
        public static Id      idCurrentUser {get; set;}
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This is a constructor method used to get the Role of the current user
    *@return        -
    */ 
    public CCPM_customHomePageController()  {
       
       
        Id idProfileOfCurrentUser        = UserInfo.getProfileId();
        List<Profile> lstProfileName     = [Select Name from Profile where Id = :idProfileOfCurrentUser limit 1];     
        
        if(lstProfileName.size() > 0) {
            strProfileName               = lstProfileName[0].Name;
            boolStrProfileSystemAdministrator = strProfileName.contains('System Administrator');
        }
        
        // Get User Role Name based on User Information
        idCurrentUser                 = UserInfo.getUserId();
        List<User> lstUserRoleName       = [Select UserRole.Name from User where Id = :idCurrentUser limit 1];   
        
        if (lstUserRoleName.size() > 0) {
            strUserRoleName              = lstUserRoleName[0].UserRole.Name;
            if (strUserRoleName != null) {
                boolStrUserRoleName      = strUserRoleName.contains('Manager');
            }
        }
        
        // Get User Store Role Name based on Store Employee record information
        List<CCPM_storeEmployee__c> lstUserStoreRoleName   = [Select CCPM_role__c from CCPM_storeEmployee__c where CCPM_employee__c = :idCurrentUser];
        if(lstUserStoreRoleName.size() > 0) {
            strUserStoreRoleName                               = lstUserStoreRoleName[0].CCPM_role__c;
            if (strUserStoreRoleName != null) {
                boolStrUserStoreRoleName                       = strUserStoreRoleName.contains('Manager');
            }
        }
        
    }    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method is used to get the list of Qualified leads to display on the homepage
    *@return        List of leads
    */ 
    @AuraEnabled
    public static List<Lead> getLeadsThatResponded()  {
        
         transient List<Lead> lstLeadsThatResponded = new List<Lead>();
        
        //Check if the user is a System Administrator
        //If the user is a system administrator then show all the leads that responsded
        //Otherwise only display the leads that is owned by the logged in user
        
        if (strProfileName == CCPM_staticConstants.strSystemAdministrator) {
            
            // Query to pull the Qualified Leads that recently responded
            lstLeadsThatResponded = [SELECT id,Name, createdDate,CCPM_leadOwner__c,CCPM_SMSResponseReceivedDateTime__c,
                                    (SELECT Description,createdDate
                                       FROM Tasks 
                                      WHERE CCPM_communicationDirection__c = :CCPM_staticConstants.strTaskCommunicationDirection 
                                   ORDER BY createdDate DESC LIMIT 1)  
                                       FROM Lead    
                                      WHERE Status                         = :CCPM_staticConstants.strLeadStatusResponded 
                                        AND CCPM_leadSubStatus__c          = :CCPM_staticConstants.strLeadSubStatusActionRequired
                                   ORDER BY CCPM_SMSResponseReceivedDateTime__c        DESC LIMIT 900];
        } else {
            
            // Query to pull the Qualified Leads that recently responded
            lstLeadsThatResponded = [SELECT id,Name, createdDate,CCPM_leadOwner__c,CCPM_SMSResponseReceivedDateTime__c,
                                    (SELECT Description,createdDate
                                       FROM Tasks 
                                      WHERE CCPM_communicationDirection__c = :CCPM_staticConstants.strTaskCommunicationDirection 
                                   ORDER BY createdDate DESC LIMIT 1)
                                       FROM Lead
                                      WHERE Status                         = :CCPM_staticConstants.strLeadStatusResponded 
                                        AND CCPM_leadSubStatus__c          = :CCPM_staticConstants.strLeadSubStatusActionRequired
                                   ORDER BY CCPM_SMSResponseReceivedDateTime__c        DESC LIMIT 900];
        }
        
        return lstLeadsThatResponded;
    }
}