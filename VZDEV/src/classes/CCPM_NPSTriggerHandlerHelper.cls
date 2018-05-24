/**
*@name          CCPM_NPSTriggerHandlerHelper
*@author        Anupreeta Chakraborty (Deloitte)
*@date          02/11/2018
*@description   This is a helpper class for CCPM_NPSTriggerHandler
*@Class         CCPM_NPSTriggerHandlerHelper
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Anupreeta Chakraborty (Deloitte)    02/11/2018   US -2359 Initial Implementation.

*/
public with sharing class CCPM_NPSTriggerHandlerHelper  {
    
    /**
@author        Anupreeta Chakraborty(Deloitte)
@description   Method updates NPS fields of related Account from the values of recent NPS record.
@param         sObject
@return        Account

*/
    public static Account populateNPSAccountfields(CCPM_NPS__c objNPS) {
        Account objAccnt;
        objAccnt = new Account(id = objNPS.CCPM_AccountHolderName__c);
        //Update Account fields with NPS data.
        objAccnt.CCPM_NPSCategory__c = objNPS.CCPM_Category__c;
        objAccnt.CCPM_NPSComments__c = objNPS.CCPM_NPSComments__c;
        objAccnt.CCPM_NPSScore__c = objNPS.CCPM_NPSScore__c;
        objAccnt.CCPM_NPSmobileNumber__c = objNPS.CCPM_surveyMobileNumber__c;
        objAccnt.CCPM_NPSDateSurveyCompleted__c = objNPS.CCPM_dateSurveyCompleted__c;
        return objAccnt;
        
    }    
   
}