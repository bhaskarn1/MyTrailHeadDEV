/**
*@name          CCPM_expireInActiveLeadsBatch
*@author        Paras Shah (Deloitte)
*@date          05/23/2017
*@description   For Expiring Leads
*@testClass     CCPM_expireInActiveLeadsTest

Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                    Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)            05/23/2017              Original Version
Paras Shah(Deloitte)            12/14/2017              Changed the logic for DISTSCE-1721 to take SMS Followup Date into account 
                                                        for Prospects and Manual Leads
*/

global class CCPM_expireInActiveLeadsBatch implements Database.Batchable <sObject>  {
    
    public static Boolean executed = false;

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Days of Lead Expiry
        Integer intDaysOfLeadExpiry = 0;
        Set<String> setOpenLeadStatuses = CCPM_utility.setOpenLeadStatus;
        Set<String> setCartRectTypes = CCPM_utility.setRectTypestoExpire;
        
        if(Label.CCPM_daysOfLeadExpiry != null) {
            intDaysOfLeadExpiry = Integer.valueOf(Label.CCPM_daysOfLeadExpiry);
            
            //Check for date of today - the expiry days
            Date dtLeadExpirationDate = Date.today().addDays(intDaysOfLeadExpiry);
        }        
        
        String query= 'SELECT Id,Recordtype.Name,CCPM_isManualLead__c,CCPM_SMSFollowUpDate__c, CCPM_mobileNumber__c, CCPM_leadChannel__c, CCPM_Type__c,' +
            			'LeadSource, Status, CCPM_isMerged__c, CCPM_Account__c, CCPM_isInitialSMSSent__c, CCPM_isFollowUpSMSSent__c,' + 
            			'CCPM_isProspectSMSsent__c, CCPM_DoubleOptOutSent__c, CCPM_SMSOptOut__c, CCPM_CreatedDate__c from Lead WHERE '+
                      '((( CCPM_lastInteraction__c < :dtLeadExpirationDate OR ( CCPM_createdDate__c < :dtLeadExpirationDate ' +
                      'AND CCPM_lastInteraction__c = Null)) AND  (Recordtype.Name IN : setCartRectTypes) AND CCPM_isManualLead__c = false) '+
                      'OR  ( CCPM_isManualLead__c = true AND CCPM_lastInteraction__c < :dtLeadExpirationDate AND CCPM_SMSFollowUpDate__c < TODAY) '+
                      'OR  ( CCPM_isManualLead__c = true AND CCPM_lastInteraction__c = Null AND CCPM_SMSFollowUpDate__c < :dtLeadExpirationDate AND CCPM_SMSFollowUpDate__c < TODAY) '+
                      'OR  ( Recordtype.Name = \'Prospect\' AND CCPM_lastInteraction__c = Null AND CCPM_SMSFollowUpDate__c < :dtLeadExpirationDate AND CCPM_SMSFollowUpDate__c < TODAY) '+
                      'OR  ( Recordtype.Name = \'Prospect\' AND CCPM_lastInteraction__c  < :dtLeadExpirationDate AND CCPM_SMSFollowUpDate__c < TODAY) '+
                      'OR  ( Recordtype.Name = \'Customer Abandoned Visit\' AND CCPM_lastInteraction__c = Null AND CCPM_SMSFollowUpDate__c < :dtLeadExpirationDate AND CCPM_SMSFollowUpDate__c < TODAY) '+
                      'OR  ( Recordtype.Name = \'Customer Abandoned Visit\' AND CCPM_lastInteraction__c  < :dtLeadExpirationDate AND CCPM_SMSFollowUpDate__c < TODAY)) '+
                      'AND ( Status in :setOpenLeadStatuses)';
        
        return Database.getQueryLocator(query);
    }

 /**
*@author        Paras Shah (Deloitte)
*@description   Execute Method
*@return        Void(None)
*/ 
    
    global void execute(Database.BatchableContext BC, List<Lead> scope)
    {   
      List<Lead> lstLeadUpdate = new List<Lead>();
      List<CCPM_journey__c> lstJourney = new List<CCPM_journey__c>();

        //Add Leads that need to be expired in a list
        for(LEAD objLead: scope)
        {
            system.debug('objLead'+objLead);
                objLead.Status = Label.CCPM_expiredLeadStatus;
                lstLeadUpdate.add(objLead);
            	CCPM_journey__c objJourney = CCPM_utility.createJourneyForCLosedLead(objLead);
            	lstJourney.add(objJourney);
        }
        system.debug('objJourney');
        
        if(lstLeadUpdate.size()>0) {
            try {
                //Bulkified Update
                update lstLeadUpdate;
            }
            Catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_expireInActiveLeads','expireInActiveLeads','Exception thrown while Expiring the Leads',true);
            }
        }
        if(CCPM_Collection.isNotNullEmpty(lstJourney)){
            try{
                insert lstJourney;
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_expireInActiveLeads','expireInActiveLeads','Exception thrown while inserting Journey',true);
            }
        }
    }

    
    global void finish(Database.BatchableContext BC) { }

}