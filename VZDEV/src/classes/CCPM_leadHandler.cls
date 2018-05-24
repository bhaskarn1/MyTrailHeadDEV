/**
*@name          CCPM_leadHandler
*@author        Sriraman Sridharan (Deloitte)
*@date          07/12/2016
@description    US-0074: Associates the cart with the correct customer using Account Number
US-0024: Associates the preferred Store on the customer record on the correct Cart
US-0040: Expired leads after 30 days of no interaction with the lead/cart
@testClass      CCPM_leadTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        07/12/2016              Original Version
Brigadesh Chandrasekar(Deloitte)    15/12/2016              Modified Version
Paras Shah(Deloitte)                01/13/2017              Added Method deleteITRMessagesForExpiredAndConvertedLeads
Deepak Mazumdar(Deloitte)           16/01/2017              Modified deleteITRMessagesForExpiredAndConvertedLeads
Brigadesh Chandrasekar(Deloitte)    25/01/2017              Modified deleteITRMessagesForExpiredAndConvertedLeads
(Added condition to delete when Status is Rejected and 
when there is a change in MTN)
Brigadesh Chandrasekar(Deloitte)    02/03/2017              Fix for TKT-000108 - HeyWire unable to send SMS in bulk
Paras Shah(Deloitte)                03/14/2017              Changes for Updating the pending outgoing SMS with new Lead Owner
Brigadesh Chandrasekar(Deloitte)    04/18/2017              Added Method updatePriorStatus
Brigadesh Chandrasekar(Deloitte)    04/27/2017              Added Method assignProspectLeadOwner
Sudhakara Reddy Nallamilli(Deloitte) 05/04/2017             Corrected Naming Conventions for the list variables 'lstStoreEmployee'
and lstStoreManager
Brigadesh Chandrasekar(Deloitte)    05/04/2017              Updated Method assignProspectLeadOwner & calculateTimeToTriggerSMSWithInBusinessHours
Brigadesh / Sriraman (Deloitte)     05/17/2017              Updated class for short term platform optimization
Sudhakara Reddy Nallamilli (Deloitte) 05/18/2017            Added method prospectCartMergeFlag
Sudhakara Reddy Nallamilli (Deloitte) 05/31/2017            US-448 changed the methods assignProspectSMSDateTimeBeforeInsert , assignProspectSMSDateTimeBeforeUpdateForEventChange
to remove the Event Type and populate the 1st SMS Followup based on the Event Date
Sudhakara Reddy Nallamilli (Deloitte) 06/05/2017            changed the method assingLeadOwnershipOnUpdate to populate the fields CCPM_isOwnershipChanged__c and
CCPM_ownershipChangedDateTime__c whenever there is a change in lead ownership
Brigadesh Chandrasekar(Deloitte)    06/21/2017              Created/Revamped method insertRecordsInSmsmessageObjectForLeadAndProspects
Sudhakara Reddy Nallamilli (Deloitte) 06/26/2017            TKT-000305
Changed the methods 'updatePriorStatus' and 'updateLeadStatusToEligible' to remove non digits from the Confirm MTN
Paras Shah(Deloitte)                06/29/2017              US 516 To set the Prospect Consent agreed date field
Sudhakara Reddy Nallamilli (Deloitte) 07/12/2017            TKT-000349 - Lead data coming in without valid Account
Added New Method 'logErrorMessagesforInvalidAccountUniqueIds' to Capture the Invalid Account Ids
Manjunath Keshava(Deloitte)           07/14/2017            Added Null checks (US-1618)
Brigadesh Chandrasekar(Deloitte)      07/31/2017            Made changes for sending Event SMS to Manual Leads  
Brigadesh Chandrasekar(Deloitte)      08/07/2017            Made changes for sending Initial SMS and Prospect 1st SMS based on Queued Owner : US 1694
Brigadesh Chandrasekar(Deloitte)      08/09/2017            Check for MTN null values: TCKT-434
Brigadesh Chandrasekar(Deloitte)      08/09/2017            Custom error logging change: TCKT - 438
Brigadesh Chandrasekar(Deloitte)      08/10/2017            Developed method setTimeSTampForConvertedLeads : US 1678
Dheeraj R Shetty(Deloitte)            08/15/2017            US-1625: Made changes for sending notifications to lead owner reassignment during business hours
Brigadesh Chandrasekar(Deloitte)      08/20/2017            Method Added : updateLeadOwneronSMSMessage for US 1752
Brigadesh Chandrasekar(Deloitte)      08/20/2017            Method Added : cancelScheduledSMSWhenQueued for US 1717
Paras Shah(Deloitte)                  09/05/2017            Added a condition to check for Campaign and change the SMS body based on the type field
Changes are tagged with US1770
Soumya Panguluri(Deloitte)            09/08/2017            TKT-524 - Modified Method : createRecordsForSmsMessageObject
Sriraman Sridharan(Deloitte)          09/14/2017            Updated Version - 1716
Brigadesh Chandrasekar(Deloitte)      09/14/2017            Method edited : insertRecordsInSmsmessageObjectForLeadAndProspects for US 1717
keshava Manjunath(Deloitte)           09/14/2017            Added method assignProspectOrManualLeadOwner for US 1713/ modified assignProspectLeadOwner
keshava Manjunath(Deloitte)           09/18/2017            Added method updateCampaignFieldResponded for US 1824 
Sudhakara Reddy Nallamilli (Deloitte) 09/21/2017            TKT-000586 - Modified the methods - populateInitialSMSMessagesToBeSent 
updateLeadStatusToEligible
insertRecordsInSmsmessageObjectForLeadAndProspects
To avoid the SMS Opt Out check for the Manual Leads
Brigadesh Chandrasekar(Deloitte)      09/21/2017              Method Modified : populateInitialSMSMessagesToBeSent,insertRecordsInSmsmessageObjectForLeadAndProspects US 1866
Method Removed :  queryForSMSJourneyRecords 
keshava Manjunath (Deloitte)          09/15/2017              Method Added updateNewLeadFieldsOnLeadUpdate (DISTSCE-1607)
Sudhakara Reddy Nallamilli (Deloitte) 10/11/2017            DISTSCE-1719 - changed the method updateLeadStatusToEligible
Sudhakara Reddy Nallamilli (Deloitte) 11/06/2017            TKT-000707 - changed the method updateLeadStatusToEligible
Sudhakara Reddy Nallamilli (Deloitte) 11/09/2017            TKT-000702 - Merge Prod Defect for Cart to Cart Scenarios action b online
updateNewLeadFieldsOnLeadUpdate and CancelAndCreateNewSmsSchedulesWhileMerge
*/
public class CCPM_leadHandler {
    /**
@author        Paras Shah (Deloitte)
@description   This method is to dynamically change the owner in the SMS if SMS is not sent to customers
@param         list of new leads
@return        Void(None)
*/    
    /*  public static void dynamicLeadOwnerUpdatesInPendingOutgoingSMSMessages(list<Lead> lstNewLeads, Map<id,Lead> mapOldLeads)
{

//Flag to check if the Lead Owner has changed 
Boolean boolFlagToCheckForLeadOwnerChange=False;

// Set of Lead Ids for which the Lead Owner has changed 
Set<Id> setLeadOwnerChangedIds                          = new Set<Id>();

// Instance of the SMS Schedule Object
List<LiveText__SMS_Schedule__c> lstUpdateLeadOwnerInSMS = new List<LiveText__SMS_Schedule__c>();

for(Lead oNewLead : lstNewLeads) {
Lead oldLead                      = mapOldLeads.get(oNewLead.id);
//Check if the Lead Owner has changed
boolFlagToCheckForLeadOwnerChange = oNewLead.CCPM_leadOwner__c.equals(oldLead.CCPM_leadOwner__c);

//Add to the set if the Lead owner has changed 
if (!boolFlagToCheckForLeadOwnerChange) {
setLeadOwnerChangedIds.add(oNewLead.Id);
}
}

//Retrieve the list of SMS schedules for which the Lead Owner has been changed
lstUpdateLeadOwnerInSMS  =   [SELECT id,LiveText__Lead__r.CCPM_initialOwnershipAssignmentMsgBody__c, LiveText__Lead__r.CCPM_followupMessageBody__c, 
LiveText__Message__c, LiveText__Reference_Id__c, LiveText__Lead__r.CCPM_initialMessageBodyPartI__c 
FROM   LiveText__SMS_Schedule__c 
WHERE   LiveText__Lead__c           IN :setLeadOwnerChangedIds 
AND
(   LiveText__Reference_Id__c LIKE 'VzWInitialSMS%' 
OR   LiveText__Reference_Id__c LIKE 'VzWFollowUpSMS%' ) ];

for(LiveText__SMS_Schedule__c oSMSSchedule: lstUpdateLeadOwnerInSMS  ) { 
Lead oldLead               = mapOldLeads.get(oSMSSchedule.LiveText__Lead__c);

//Check for the reference to determine Initial SMS/Follow SMS/Lead Owner assignment SMS
if(oSMSSchedule.LiveText__Reference_Id__c.startsWith('VzWInitialSMS')) {
//Update the Initial SMS part I in the SMS schedule table. This will have the new Lead owner name in the message body.
oSMSSchedule.LiveText__Message__c = oSMSSchedule.LiveText__Lead__r.CCPM_initialMessageBodyPartI__c;

} else if(oSMSSchedule.LiveText__Reference_Id__c.startsWith('VzWFollowUpSMS')) {
//Update the Follow Up SMS in the SMS schedule table. This will have the new Lead owner name in the message body.
oSMSSchedule.LiveText__Message__c = oSMSSchedule.LiveText__Lead__r.CCPM_followupMessageBody__c; 
} 
}
try{
//Bulkified update
update lstUpdateLeadOwnerInSMS;
}   
catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','dynamicLeadOwnerUpdatesInPendingOutgoingSMSMessages','Exception thrown while updating the Lead owner in pending outgoing SMS Message',true); 
}
} */
    public static Set<String> statusToExclude = new Set<String>{CCPM_staticConstants.strLeadStatusConverted, 
        CCPM_staticConstants.strLeadStatusExpired,  
        CCPM_staticConstants.strLeadStatusResponded, 
        CCPM_staticConstants.strLeadStatusQualified};
            
            /**
@author         Paras Shah (Deloitte)
@description    This method is targeted to delete all the ITR Messages Leads that has been expired / converted / rejected
Fix for TKT-000107 - Initial SMS Part 1 sent to customer even though the cart status is set to 'Complete'
@param          list of new leads
@return         Void(None)
*/    
            public static void deleteITRMessagesForExpiredAndConvertedLeads(list<Lead> lstNewLeads, Map<id,Lead> mapOldLeads)
        {
            //Getting all the values of status referring to closed status
            String[] strCartClosedStatus=CCPM_staticConstants.strCartClosedStatus.split(':');
            //Flag to check if New lead status is one of the closed status
            Boolean boolFlagToCheckForClosedStatus=false;
            // set of expired lead ids
            Set<Id> setExpiredLeadIds                           = new Set<Id>();
            // instance of ITR Message object
            List<LiveText__ITR_Message__c> lstDeleteITRMessages = new List<LiveText__ITR_Message__c>();
            
            for(Lead oNewLead : lstNewLeads) 
            {
                
                Lead oldLead               = mapOldLeads.get(oNewLead.id);
                // check if lead status has changed
                boolean boolLeadStatusSame = oNewLead.Status.equals(oldLead.Status);
                
                // check if MTN # has changed
                boolean boolMTNchanged      = false;
                if( oNewLead.CCPM_mobileNumber__c != null) {
                    oNewLead.CCPM_mobileNumber__c.equals(oldLead.CCPM_mobileNumber__c);
                }
                
                // check that lead status has chaneged and the status of new lead is either expired or converted or rejected 
                // mobile number has changed, then delete any ITR Message records so that response can be linked to correct lead
                if (!boolLeadStatusSame || ! boolMTNchanged) {
                    for(Integer i=0;i<strCartClosedStatus.size();i++)
                    {
                        if(oNewLead.Status==strCartClosedStatus[i])
                        {
                            boolFlagToCheckForClosedStatus=true;
                            break;
                        }
                    }
                    
                    if (boolFlagToCheckForClosedStatus) {
                        setExpiredLeadIds.add(oNewLead.Id);
                    }
                }
            }
            
            
            // retrieve list of ITR Messages to delete so that if we receive response for the same mobile no. for a different cart
            // response can be processed
            
            lstDeleteITRMessages=[select id,LiveText__Lead__c from LiveText__ITR_Message__c where LiveText__Lead__c IN :setExpiredLeadIds];
            try{
                //Bulkified Delete
                delete lstDeleteITRMessages;
            }   
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','deleteITRMessagesForExpiredLeads','Exception thrown while deleting ITR Messages',true); 
            }
            
        }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte) 
@description   This method is targeted to handle the operations on lead records after Inserting to Set Sharing Rules
@param         list of new leads
@return        Void(None)
*/    
    public static void shareLeadsWithAssistanManagers(List<Lead> lstNewLeads)
    {   
        //Instantiate set to store store id's that are not null
        set<id> setStoreID = new set<id>();
        integer intCountOfErrors = 0;
        string strLogcode;
        string strErrorMessage;
        //for every Lead in list of new leads
        
        for(Lead objLead : lstNewLeads) 
        {   //Check if store associated is not null
            if(objLead.Store__c!=null)
            {   //Store the store ID in a set for further processing
                setStoreID.add(objLead.Store__c);
            }
            else if(objLead.Store__c == null)
            {
                strErrorMessage = 'Store Not populated for the Lead on Insert';
                intCountOfErrors = intCountOfErrors+1;
                strLogcode = 'LeadId: '+ objLead.id;
                
            }
        }
        if(intCountOfErrors>0)
        {
            try
            {   
                CCPM_LogMessageUtility.logMessage(CCPM_logMessageUtility.LOG_LogLevel.Error,'CCPM_leadHandler.shareLeadsWithAssistanManagers','Store Not populated for->'+intCountOfErrors,strErrorMessage,strLogcode,true);
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler.shareLeadsWithAssistanManagers',
                                                  'Store Id not Captured Error',
                                                  'Exception thrown while Capturing leads with no store populated',true);
                
            } 
            
        }
        
        //Check if the set of store id is not null/empty
        if(setStoreID!=null && setStoreID.size()>0)
        {   //Callout to the method to insert Lead shares
            insertLeadShareSettings(setStoreID,lstNewLeads);
        }
        
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is targeted to handle the operations on lead records after updating/Inserting to Set Sharing Rules
@param         set of Stor ID's , list of new leads
@return        Void(None)
*/ 
    
    public static void insertLeadShareSettings(set<id> setStoreID, List<Lead> lstNewLeads)
    {   
        //Instantiate list to store leadshares to be inserted
        List<leadShare> lstApplySharing    = new List<leadShare>();
        //List of Assistant managers that needs lead share
        list<CCPM_storeEmployee__c> lstAssistantManager = new list<CCPM_storeEmployee__c>();
        //Map of Assistant manager associated to a particular store
        map<id,set<id>> mapStoreAssistantManager = new map<id, set<id>>();
        try{
            //Check if Store id in the set is not null
            if(setStoreID!=null && setStoreID.size()>0)
            {   //Query for all AM associated with the store
                lstAssistantManager=[select CCPM_Store__c,CCPM_employee__c from CCPM_storeEmployee__c where CCPM_role__c='Assistant Manager' and CCPM_Store__c in :setStoreID and CCPM_IsActive__c=true and ccpm_employee__r.isactive=true and ccpm_store__r.CCPM_IsActive__c=true]; 
            }
            
        }
        catch(Exception e)
        {   //Catch exception incase of error
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','shareLeadsWithAssistanManagers','Exception thrown while querying Assistant Managers in insert/Update',true);
        }
        
        
        //For every Assistant Manager
        for (CCPM_storeEmployee__c objStoreEmployee : lstAssistantManager)
        {   //Instantiate set to store emplyee id
            set<id> setStoreEmployeeExist = new set<id> ();
            //Check for map not being null
            if(mapStoreAssistantManager!= null)
            {
                //Check if the store associated with the employee is not null, check if map contains Store as the key, check if map returns a valid list
                if(objStoreEmployee.CCPM_Store__c!= null 
                   && mapStoreAssistantManager.containsKey(objStoreEmployee.CCPM_Store__c) 
                   && mapStoreAssistantManager.get(objStoreEmployee.CCPM_Store__c)!=null)
                {   //Get the set of id's related to a store
                    setStoreEmployeeExist = mapStoreAssistantManager.get(objStoreEmployee.CCPM_Store__c);
                    //Add the new employee into the set
                    setStoreEmployeeExist.add(objStoreEmployee.CCPM_employee__c);
                    //Replace the existing map with the updated list
                    mapStoreAssistantManager.put(objStoreEmployee.CCPM_Store__c,setStoreEmployeeExist);
                    
                }
                else
                {   //Create a new entry to the map
                    if(objStoreEmployee.CCPM_employee__c!=null && objStoreEmployee.CCPM_Store__c!=null)
                    {   //Add the employee id to the set
                        setStoreEmployeeExist.add(objStoreEmployee.CCPM_employee__c);
                        //Add the entry to the map
                        mapStoreAssistantManager.put(objStoreEmployee.CCPM_Store__c,setStoreEmployeeExist);
                    }
                    
                }
            }
            
        }
        
        
        
        
        for(Lead objLead : lstNewLeads)
        {   //Check if lead has a valid store
            //if(objLead.Store__c!=null)
            //Check if the map contains the store as a key
            if(objLead.Store__c!=null && mapStoreAssistantManager.containsKey(objLead.Store__c) && mapStoreAssistantManager.get(objLead.Store__c)!=null)
            {   //Extract individual Assistant managers associated to a store
                //Add it to the list to bulk apply sharing permissions
                set<id> setIndividualAssistantManagers = new set<id>();
                setIndividualAssistantManagers= mapStoreAssistantManager.get(objLead.Store__c);
                if(setIndividualAssistantManagers.size()>0)
                {
                    for (id idAssistantManagers : setIndividualAssistantManagers)
                    {
                        if(idAssistantManagers != objLead.OwnerId)
                        {
                            lstApplySharing.add(CCPM_globalUtility.apexShareReadAccess(objLead.id,idAssistantManagers));
                        }   
                    }   
                }   
            }
        }
        
        
        if(lstApplySharing.size()>0)
        {   
            try{
                //Setting the Sharing settings required for the Manager & Assistant Manager to view the records associated with their Store
                insert lstApplySharing;
            }
            Catch(DMLException e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','provideLeadShareSettings','Exception thrown while apllying Sharing',true);
            }
        }
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is targeted to handle the operations on lead records after updating to Set Sharing Rules
@param         list of new leads, Map of Old Leads
@return        Void(None)
*/    
    public static void shareLeadsWithAssistanManagers(List<Lead> lstNewLeads, map<id,Lead> mapOldLeads)
    {
        //Instantiating List to hold leads that require deleting of existing lead shares
        List<leadShare> lstdeleteLeadSharingrecords = new List<leadShare>();
        //Instantiating list to hold leads that requires new apex shares
        List<Lead> lstLeadsToCreateSharingPermissions = new list<Lead>();
        //List of assistant Manager to hold all AM's that require Apex lead share
        list<CCPM_storeEmployee__c> lstAssistantManager = new list<CCPM_storeEmployee__c>();
        //Lead id's that require Lead shares to be removed
        set<id> setLeadToRemoveShare = new set<id>();
        //Set to store the store ID's to extract associated AM
        set<id> setStoreID = new set<id>();
        for(Lead objLead : lstNewLeads)
        {   //Check if store is null previously, and if there is a change in store
            if(objLead.Store__c!=null && ((mapOldLeads.get(objLead.id).Store__c!= null && objLead.Store__c!=mapOldLeads.get(objLead.id).Store__c)|| (mapOldLeads.get(objLead.id).ownerid!= null && objLead.ownerid!=mapOldLeads.get(objLead.id).ownerid) ))
            {
                setStoreID.add(objLead.Store__c);
                setLeadToRemoveShare.add(objLead.Id);
                lstLeadsToCreateSharingPermissions.add(objLead);
            }
        }
        
        
        try{
            if(setLeadToRemoveShare!=null && setLeadToRemoveShare.size()>0)
            {
                //Extract Leads for which previous Lead shares needs to be removed
                lstdeleteLeadSharingrecords=[select id, leadid,leadaccesslevel from leadshare where leadaccesslevel ='Edit' and leadid in :setLeadToRemoveShare];
            }
            
        }
        Catch(Exception e)
        {   //Catch exception incase of error
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','provideLeadShareSettings','Exception thrown while Querying existing leadshares after update',true);
        } 
        
        if(lstdeleteLeadSharingrecords!=null && lstdeleteLeadSharingrecords.size()>0)
        {
            try{
                //Delete Lead Shares
                delete(lstdeleteLeadSharingrecords);
            }
            catch(DMLException e)
            {   //Catch exception incase of error
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','provideLeadShareSettings','Exception thrown while deleting Lead Shares for store change',true);
            }
        }
        
        if(setStoreID!=null && setStoreID.isEmpty()==false && lstLeadsToCreateSharingPermissions!=null && lstLeadsToCreateSharingPermissions.size()>0)
        {   //Make a callout to method to provide lead shares where set of store id's are not null and list of leads associated with the stores are not null 
            insertLeadShareSettings(setStoreID,lstLeadsToCreateSharingPermissions);
        }
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is targeted to handle the operations on updating the Unique field on Cart based on Status Change
@param         list of new leads, list of old leads
@return        Void(None)
*/ 
    /*public static list<Lead> updateUniqueIdOnLeadStatusChangeOnUpdate(list<Lead> lstNewLeads, map<id,Lead> mapOldLeads)   
{   
//Set to contain all the closed status from custom settings 
set<string> setCartClosedStatus = new set<string>();
setCartClosedStatus.addAll(CCPM_staticConstants.strCartClosedStatus.split(CCPM_staticConstants.strColon));
//Checking for all the new leads that are updated
//Changing the Cart Unique ID for all the updated leads
for(integer i=0;i < lstNewLeads.size();i++)
{   
//Checking if there exists a Cart Unique ID for carts before update
if(mapOldLeads.get(lstNewLeads[i].id).CCPM_cartUniqueID__c != null && mapOldLeads.get(lstNewLeads[i].id).CCPM_cartID__c != null && setCartClosedStatus!=null && setCartClosedStatus.isEmpty()==false)
{    //Checking if the status of the cart has been modified.
if(mapOldLeads.get(lstNewLeads[i].id).status != lstNewLeads[i].status) 
{   
//Extracting only the Cart Unique ID without the status, if already appended.
String[] strUpdatedCartId=mapOldLeads.get(lstNewLeads[i].id).CCPM_cartUniqueID__c.split('-');

if(setCartClosedStatus.contains(lstNewLeads[i].status))
{
lstNewLeads[i].CCPM_cartUniqueID__c = strUpdatedCartId[0] + '-S:' + lstNewLeads[i].Status +'-Id:' + lstNewLeads[i].CCPM_cartID__c;
}
else
{
lstNewLeads[i].CCPM_cartUniqueID__c = strUpdatedCartId[0];
}
}
}

}

return lstNewLeads;
}*/
    
    
    /**
@author        Paras Shah (Deloitte)
@description   This method is used to update the Lead Status to blank for Closed Lead Statuses
@param         list of new leads, list of old leads
@return        Void(None)
*/ 
    public static list<Lead> updateLeadSubStatusToBlankForClosedLeads(list<Lead> lstNewLeads)   
    {   
        set<String> setClosedStatus = new set<String>();
        
        if(CCPM_staticConstants.strCartClosedStatus != null) {
            //Getting all the values of status referring to closed status
            String[] strCartClosedStatus=CCPM_staticConstants.strCartClosedStatus.split(':');
            
            for(integer j=0;j<strCartClosedStatus.size();j++) {
                setClosedStatus.add(strCartClosedStatus[j]);
            } 
        }
        
        if(lstNewLeads!=null && lstNewLeads.size()>0)
        {
            for (integer i=0;i<lstNewLeads.size();i++) 
            {
                if(setClosedStatus.contains(lstNewLeads[i].Status))
                    //IF substatus change flag is true then blank out the sub status field
                    lstNewLeads[i].CCPM_leadSubStatus__c = '';
            }
        }
        
        
        return lstNewLeads;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is targeted to handle the operations on updating the Unique field on Cart based on Status Change
@param         list of new leads, list of old leads
@return        Void(None)
*/ 
    /*   public static list<Lead> updateUniqueIdOnLeadStatusChangeOnInsert(list<Lead> lstNewLeads)   
{   
set<string> setCartClosedStatus = new set<string>();
//Getting all the values of status referring to closed status
setCartClosedStatus.addAll(CCPM_staticConstants.strCartClosedStatus.split(CCPM_staticConstants.strColon)); 
//Checking for all the new leads that are updated
//Changing the Cart Unique ID for all the updated leads
for(integer i=0;i < lstNewLeads.size();i++)
{   
//Checking if there exists a Cart Unique ID and Cart Id for carts before update
if(lstNewLeads[i].CCPM_cartUniqueID__c != null && lstNewLeads[i].CCPM_cartID__c != null && setCartClosedStatus!=null && setCartClosedStatus.isEmpty() == false)
{   //Checking if we have to append the status to Unique Cart ID based on the status value inserted.
if(setCartClosedStatus.contains(lstNewLeads[i].status))
{
lstNewLeads[i].CCPM_cartUniqueID__c = lstNewLeads[i].CCPM_cartUniqueID__c + '-S:' + lstNewLeads[i].Status +'-Id:' + lstNewLeads[i].CCPM_cartID__c;
}
}   
}
return lstNewLeads;
}*/
    
    /**
@author         Sriraman Sridharan
@description    This method retrieves the business hours by retrirving the business hours defined
at the org level
@param          list of new leads
@return         Void(None)
*/  
    public static DateTime calculateTimeToTriggerSMSWithInBusinessHours(BusinessHours bh, Datetime inputDatetime) {
        // retrieves list of business hours which are active
        // if date/time is within the business hours, if yes then no change 
        //system.debug('@@@bh ' + bh);
        if(BusinessHours.isWithin(bh.id,inputDatetime)){
            //System.debug('@@@ inputDatetime : ' + inputDatetime);
            return inputDatetime;
        }
        // if date/time is outside the business hours, then get the next date/time
        else{
            Datetime nextstart;
            nextStart = BusinessHours.nextStartDate(bh.id, inputDatetime); 
            //System.debug('@@@ NextStart : ' + nextStart);
            return nextStart;
        }
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to verify CartLastHandledBy Field With StoreEmployee Object and update the lead
@param         list of new leads
@return        Void
*/ 
    /*  public static List<Lead> assignLeadOwnershipOnCreate(list<Lead> lstNewLeads,List<BusinessHours> oBusinessHours){
Set<String> lstCartLastHandledBy    = new Set<String>();    //set of cartLastHandledBy Values
List<User> lstOwner;                                        //List of users queried from User object based on cartLastHandledByValues from list of leads
List<ID> lstOwnerID                 = new List<ID>();       //List of Owner ID's from User object
Set<String> lstCustomerAccountNumber= new Set<String>();    //Set of Customer Account Numbers from the leads
List<Account> lstCustomerAccountFields = new List<Account>();                     //List of Customer Account Fields from Account Object using Account Numbers
Set<String> stStoreId               = new Set<String>();    // set of store Id's from the lead object
Boolean ownerAssigned               = false;                //Boolean value to check if the owner is assigned to a sales rep
List<lead> lstSubSetNewLead         = new List<lead>();
CCPM_globalSetting__c gs            = CCPM_globalSetting__c.getInstance();
list<LiveText__SMS_Schedule__c> lstMaxTimeScheduledToday= new list<LiveText__SMS_Schedule__c>(); 

//Check if the list of leads is empty and conditionally make the changes to the fields
//Get the business hours from the org
//List<BusinessHours> oBusinessHours; //Object for Business hours

for(Lead l: lstNewLeads)
{
if(l.CCPM_cartlastHandledBy__c != null){
//add last cart handled by field to the list from all the leads
lstCartLastHandledBy.add(l.CCPM_cartlastHandledBy__c);
}

if(l.CCPM_accountUniqueID__c != null){
//add account number field to the list from all the leads
lstCustomerAccountNumber.add(l.CCPM_accountUniqueID__c);
}

if(l.CCPM_storeID__c != null){
//add store ID field to the list from all the leads
stStoreId.add(l.CCPM_storeID__c);
}
}

//retreive the customer fields using the customer number and store it in a local list
if(lstCustomerAccountNumber!=null && lstCustomerAccountNumber.size()>0)
{
lstCustomerAccountFields = retreiveAccountHolderBasedonAccountNumbers(lstCustomerAccountNumber);
}


//assign account holder to the lead records using account number
if( lstCustomerAccountFields!=null && lstCustomerAccountNumber.size()>0)
{
setLeadAccountHolderBasedOnAccountNumber(lstCustomerAccountFields,lstCustomerAccountNumber,lstNewLeads);
}


//check if the last cart handled by field is empty
if( lstCartLastHandledBy != null && lstCartLastHandledBy.size()>0 ){
try{
//Query for the list of active users using cart last handled by field
lstOwner = [Select id,CCPM_commissionableRepID__c from User Where IsActive = True and CCPM_commissionableRepID__c IN : lstCartLastHandledBy];
}
catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignLeadWhileInsertion','Exception thrown while querying Valid Users',true);
}

//retreive the list of user id from the list of owner fields
for(User LO : lstOwner){
lstOwnerID.add(LO.id);
}

//Check if the assigned owner is a valid store employee or a system admin and set the boolean value to false if he is'nt
List<lead> lstRtnSubSetNewLead  = new List<lead>();
lstRtnSubSetNewLead             = assignLeadOwnershipBasedOnEmployeeId(lstNewLeads,lstOwnerId,stStoreId,True);
List<Integer> lstIndexValue     = new List<Integer>();

for(integer i=0;i<lstNewLeads.size();i++){
for(integer j=0;j<lstRtnSubSetNewLead.size();j++){
if(lstNewLeads[i].CCPM_cartUniqueID__c == lstRtnSubSetNewLead[j].CCPM_cartUniqueID__c){
lstIndexValue.add(i);
}
}
}

lstIndexValue.sort();
Map<Integer,Lead> mpLeads = new Map<Integer,Lead>();
for(Integer i=0; i<lstNewLeads.size();i++){
if(!mpLeads.containsKey(i)){
mpLeads.put(i, lstNewLeads.get(i));
}
}

for(Integer i=0; i<lstIndexValue.size();i++){
if(mpLeads.containsKey(lstIndexValue.get(i))){
mpLeads.remove(lstIndexValue.get(i));
}
}

for(Integer k: mpLeads.keySet()){
lstSubSetNewLead.add(mpLeads.get(k));
}

if(lstSubSetNewLead != null){
//assign owner based on Store ID for the leads which did not get an owner assigned
assignOwnershipUsingStoreIDAndCustomerNearestStoreValues(stStoreId, lstSubSetNewLead, lstCustomerAccountNumber, lstCustomerAccountFields);
}
}

//if the cart last handled by field is not provided for none of the leads
else
{   
if(lstCustomerAccountFields!=null && lstCustomerAccountNumber.size()>0 )
{
assignOwnershipUsingStoreIDAndCustomerNearestStoreValues(stStoreId, lstNewLeads, lstCustomerAccountNumber, lstCustomerAccountFields);
}
}

//Update CCPM_TriggerInitialSMSDateTime__c field to all leads
try{ */ 
    /* BusinessHours oBusinessHours  = [Select Id
From BusinessHours 
Where IsActive = true AND IsDefault = true Limit 1];
*/
    /*
BusinessHours oDefaultBusinessHour;
for(Integer i=0; i<oBusinessHours.size();i++){
if(oBusinessHours[i].IsDefault){
oDefaultBusinessHour = oBusinessHours[i];
break;
}
}
Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
//Querying for active business hours from the org
//system.debug('@@@oBusinessHoursbefore' + oBusinessHours);
mapLeadAndBusinessHours = getCartIdORStoreIDAndBusinessHourMap(lstNewLeads,oDefaultBusinessHour,oBusinessHours);
//system.debug('@@@oBusinessHours' + oBusinessHours);
if(lstNewLeads!=null && lstNewLeads.size()>0)
{
for(Lead l: lstNewLeads){       
if(CCPM_staticConstants.strInitialSMSInterval != null && CCPM_staticConstants.strFollowUpSMSInterval != null && l.RecordTypeId!=CCPM_staticConstants.strProspectRecordTypeID && l.CCPM_Type__c!=CCPM_staticConstants.strLeadTypeManualLead)
{
if(!mapLeadAndBusinessHours.isEmpty() && mapLeadAndBusinessHours.get(l.CCPM_cartID__c)!= null ){
//system.debug('@@@insideIf');
l.CCPM_TriggerInitialSMSDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours((mapLeadAndBusinessHours.get(l.CCPM_cartID__c)), System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
//System.debug('@@@l.CCPM_TriggerInitialSMSDateTime__c '+l.CCPM_TriggerInitialSMSDateTime__c + '@@@BHB '+mapLeadAndBusinessHours.get(l.CCPM_cartID__c));
}
else{
// system.debug('@@@insideElse');
l.CCPM_TriggerInitialSMSDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours(oDefaultBusinessHour, System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
}
}
}
}
}
catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignLeadOwnershipOnCreate','Exception thrown while querying Customer Account Fields',true);

}
return lstNewLeads;
}
*/
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to verify Owner Field With User Object and update the lead
@param         list of new leads
@return        Void
*/ 
    /*  public static List<Lead> assingLeadOwnershipOnUpdate(list<Lead> lstNewLeads, List<Lead> lstOldLeads,Map<String,Group> mapDistrictAndGroup){
List<ID> lstOwnerId                 = new List<ID>();   //list of Owner ID's from User object
Set<String> lstCartLastHandledBy    = new Set<String>();//set of cartLastHandledBy Values
List<User> lstOwner;                                    //list of users queried from User object based on cartLastHandledByValues from list of leads
List<ID> lstStore                   = new List<ID>();   //list of Store ID references initially from Leads
Set<String> stStoreId               = new Set<String>();//set of store Id's from the lead object
Set<String> lstCustomerAccountNumber= new Set<String>();//Set of Customer Account Numbers from the leads
List<Account> lstCustomerAccountFields = new List<Account>();                 //list of Customer Account Fields from Account Object using Account Numbers
Boolean ownerAssigned               = False;            //boolean value to check if the owner is assigned to a sales rep
List<lead> lstSubSetNewLead         = new List<lead>();
set<id> setQueueID = new set<id>();
if(mapDistrictAndGroup!=null && !mapDistrictAndGroup.isEmpty())
{
setQueueID.addAll(getSetOfQueueID(mapDistrictAndGroup));         
}
if(lstNewLeads!=null && lstNewLeads.size()>0)
{
for(integer i=0;i<lstNewLeads.size();i++){
//checking if the lead owner has changed and adding to the list only if there is a change
//&& lstNewLeads[i].OwnerId!=lstOldLeads[i].OwnerId
if(lstNewLeads[i].OwnerId!=null && lstNewLeads[i].OwnerId!=lstOldLeads[i].OwnerId 
&& setQueueID!=null && !setQueueID.isEmpty() && !setQueueID.contains(lstNewLeads[i].OwnerId)){
// Update the OwnerShip Change flag and Date / Time fields for tracking purpose
lstNewLeads[i].CCPM_isOwnershipChanged__c = true;
lstNewLeads[i].CCPM_ownershipChangedDateTime__c = system.now();
//add Owner ID field to the list from all the leads
lstOwnerId.add(lstNewLeads[i].OwnerId);
}

if(lstNewLeads[i].CCPM_cartlastHandledBy__c!=null && lstNewLeads[i].CCPM_cartlastHandledBy__c!=lstOldLeads[i].CCPM_cartlastHandledBy__c){
//add last cart handled by field to the list from all the leads
lstCartLastHandledBy.add(lstNewLeads[i].CCPM_cartlastHandledBy__c);

}
if(lstNewLeads[i].CCPM_accountUniqueID__c!=null && lstNewLeads[i].CCPM_accountUniqueID__c!=lstOldLeads[i].CCPM_accountUniqueID__c){
//add account number field to the list from all the leads
lstCustomerAccountNumber.add(lstNewLeads[i].CCPM_accountUniqueID__c);

}
if(lstNewLeads[i].CCPM_storeID__c!=null && lstNewLeads[i].CCPM_storeID__c!=lstOldLeads[i].CCPM_storeID__c){
//add store ID field to the list from all the leads
stStoreId.add(lstNewLeads[i].CCPM_storeID__c);

}
}
system.debug('@@@stStoreId' + stStoreId);
}
//Retreive the customer fields using the customer number and store it in a local list
if(lstCustomerAccountNumber.size()>0)
{
lstCustomerAccountFields = retreiveAccountHolderBasedonAccountNumbers(lstCustomerAccountNumber); 

}

//Assign account holder to the lead records using account number
//&& !lstCustomerAccountNumber.isEmpty()
If(lstCustomerAccountFields!=null && lstCustomerAccountFields.size()>0 )
{
setLeadAccountHolderBasedOnAccountNumber(lstCustomerAccountFields,lstCustomerAccountNumber,lstNewLeads);

}

//check if the list of eligible owners is emplty
//&& !lstCustomerAccountNumber.isEmpty()
if(lstOwnerId!=null && lstOwnerId.size()>0  ){
system.debug('@@@lstOwnerId '+lstOwnerId);
List<lead> lstRtnSubSetNewLead = new List<lead>();
lstRtnSubSetNewLead = assignLeadOwnershipBasedOnEmployeeId(lstNewLeads,lstOwnerId,stStoreId,False);
List<Integer> lstIndexValue = new List<Integer>();
for(integer i=0;i<lstNewLeads.size();i++){
for(integer j=0;j<lstRtnSubSetNewLead.size();j++){
if(lstNewLeads[i].CCPM_cartUniqueID__c == lstRtnSubSetNewLead[j].CCPM_cartUniqueID__c){
lstIndexValue.add(i);
}
}
}
lstIndexValue.sort();
Map<Integer,Lead> mpLeads = new Map<Integer,Lead>();
for(Integer i=0; i<lstNewLeads.size();i++){
if(!mpLeads.containsKey(i)){
mpLeads.put(i, lstNewLeads.get(i));
}
}
for(Integer i=0; i<lstIndexValue.size();i++){
if(mpLeads.containsKey(lstIndexValue.get(i))){
mpLeads.remove(lstIndexValue.get(i));
}
}
for(Integer k: mpLeads.keySet()){
lstSubSetNewLead.add(mpLeads.get(k));
}

if(lstSubSetNewLead!=null)
{
//assign owner based on Store ID for the leads which did not get an owner assigned
//System.debug('Lead Status'+ lstSubSetNewLead);
assignOwnershipUsingStoreIDAndCustomerNearestStoreValues(stStoreId, lstSubSetNewLead, lstCustomerAccountNumber, lstCustomerAccountFields);
//System.debug('assign owner nearest store and store manager - 1'+ stStoreId );
//System.debug('assign owner nearest store and store manager - 2'+ lstSubSetNewLead );
//System.debug('assign owner nearest store and store manager - 3'+ lstCustomerAccountNumber );
//System.debug('assign owner nearest store and store manager - 4'+ lstCustomerAccountFields );


}

}
//if the cart last handled by field is not provided for none of the leads
else
{
If((lstCustomerAccountFields!=null && lstCustomerAccountNumber.size()>0) || (stStoreId != null && stStoreId.size()>0 ))
{
system.debug('@@@I am here');
assignOwnershipUsingStoreIDAndCustomerNearestStoreValues(stStoreId, lstNewLeads, lstCustomerAccountNumber, lstCustomerAccountFields);     
}

}

return lstNewLeads;
}   
*/   
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method retrieves the Customer Fields Using Account Numbers
at the org level
@param         list of new leads
@return        Void(None)
*/     
    /*   @TestVisible
private static List<Account> retreiveAccountHolderBasedonAccountNumbers(Set<String> lstCustomerAccountNumber)
{
List<Account> lstCustomerAccount; // List of Customer Account Fields from Account Object using Account Numbers
try{

lstCustomerAccount = [Select Id,CCPM_store__c,CCPM_accountNumber__c, CCPM_accountUniqueID__c from Account where Account.CCPM_accountUniqueID__c IN : lstCustomerAccountNumber];
}
catch(Exception e)
{
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','getCustomerFieldsUsingAccountNumbers','Exception thrown while querying Customer Account Fields',true);
}

return lstCustomerAccount;

}
*/
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method assigns the lead owner ID using at the org level
@param         list of new leads
@return        Void(None)
*/  
    @TestVisible
    private static void setStoreManagerAndAssignLeadOwnershipBasedOnStoreId(list<Lead> lstNewLeads, List<ID> lstStore){
        List<CCPM_storeEmployee__c> lstStoreEmployee = retreiveStoreManagersBasedOnStoreIds(lstStore); //List of store managers from the store employee object
        
        for(integer i=0; i<lstNewLeads.size();i++){
            if(lstStoreEmployee!= null && lstStoreEmployee.size()>0 )
            {
                for(integer j=0; j<lstStoreEmployee.size();j++){
                    //Assign Lead Owner and Store Manager for 
                    if(lstNewLeads[i].Store__c == lstStoreEmployee[j].CCPM_Store__c){
                        lstNewLeads[i].ownerid=lstStoreEmployee[j].CCPM_employee__c;
                        lstNewLeads[i].CCPM_storeManager__c = lstStoreEmployee[j].CCPM_employee__c;
                    }
                }
            }
            else{
                //Assign Lead Owner and Store Manager fields
                lstNewLeads[i].ownerid = UserInfo.getUserId();
                lstNewLeads[i].CCPM_storeManager__c = null;
            }
        }
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method assigns lead using nearest store from the related customer record at the org level
@param         list of new leads, list of customeraccountnumbers and list of customer account fields
@return        Void
*/  
    /*   @TestVisible
private static void assignLeadOwnershipBasedOnAccountHoldersNearestStore(Set<String> lstCustomerAccountNumber,List<Account> lstCustomerAccountFields,List<Lead> lstNewLeads){
List<ID> lstNearestStore = new List<ID>(); //List of Nearest Stores of the Account Holders from the Leads

//Nearest Store code                   
for(integer i=0; i<lstCustomerAccountFields.size();i++){
if(lstCustomerAccountFields[i].CCPM_store__c != null){
//add the nearest store references to the list of nearest store ID's
lstNearestStore.add(lstCustomerAccountFields[i].CCPM_store__c);

}
}
if(lstCustomerAccountFields!=null && lstCustomerAccountFields.size()>0)
{
for(integer i=0;i<lstNewLeads.size();i++){
for(integer j=0;j<lstCustomerAccountFields.size();j++){
//Assign Store Value for the lead records
if(lstNewLeads[i].CCPM_accountUniqueID__c == lstCustomerAccountFields[j].CCPM_accountUniqueID__c){
if( lstCustomerAccountFields[j].CCPM_store__c!=null){
lstNewLeads[i].Store__c = lstCustomerAccountFields[j].CCPM_store__c;
}
}
}
}
setStoreManagerAndAssignLeadOwnershipBasedOnStoreId(lstNewLeads,lstNearestStore);
}

}
*/ 
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method retrieves the Manager Field from storeEmployee object Using StoreIds at the org level
@param         list of new leads
@return        List<CCPM_storeEmployee__c>
*/  @TestVisible   
    private static List<CCPM_storeEmployee__c> retreiveStoreManagersBasedOnStoreIds(List<ID> lstStore)
    {
        List<CCPM_storeEmployee__c> lstStoreEmployeeFields; //List of Store Employee records who are store managers for a given list of stores
        lstStoreEmployeeFields = [select CCPM_employee__c,CCPM_Store__c,CCPM_employee__r.CCPM_commissionableRepID__c,CCPM_role__c from CCPM_storeEmployee__c where (CCPM_role__c='Store Manager' OR CCPM_role__c = 'Assistant Manager') AND CCPM_IsActive__c = true and CCPM_Store__c IN :lstStore];
        return lstStoreEmployeeFields;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method assigns account holder using account number at the org level
@param         list of new leads
@return        Void
*/  
    /*private static void setLeadAccountHolderBasedOnAccountNumber(List<Account> lstCustomerAccountFields, Set<String> lstCustomerAccountNumber, List<Lead> lstNewLeads){
//List<Account> lstCustomerAccountFields = retreiveAccountHolderBasedonAccountNumbers(lstCustomerAccountNumber);

//List<Account> lstCustomerAccountFields; // List of Customer Account Fields from Account Object using Account Numbers
/*try{
lstCustomerAccountFields = [Select Id,CCPM_store__c,CCPM_accountNumber__c,CCPM_accountUniqueID__c from Account where CCPM_accountUniqueID__c IN : lstCustomerAccountNumber];
}
catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','getCustomerFieldsUsingAccountNumbers','Exception thrown while querying Customer Account Fields',true);
}
//List of Customer Account Fields using customer accounts

if(lstNewLeads!=null && lstNewLeads.size()>0)
{
for(integer i=0; i<lstNewLeads.size();i++)
{
for(integer j=0; j<lstCustomerAccountFields.size();j++){
//Assign Account holder Value for the lead records
if(lstCustomerAccountFields[j].CCPM_accountUniqueID__c == lstNewLeads[i].CCPM_accountUniqueID__c){
lstNewLeads[i].CCPM_Account__c       = lstCustomerAccountFields[j].id;
lstNewLeads[i].CCPM_accountNumber__c= lstCustomerAccountFields[j].CCPM_accountNumber__c;
}  
}
}
}

}*/
    
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method assigns the lead fields using cartlasthandledby value and returns a boolean value
at the org level
@param         list of new leads, set of cartLastHandledBy fields
@return        Boolean
*/     
    /*  @TestVisible
private static List<lead> assignLeadOwnershipBasedOnEmployeeId(list<Lead> lstNewLeads,List<ID> OwnerValue,Set<String> stStoreId, Boolean IUFlag){
List<ID> lstStore           = new List<ID>(); //List of Store ID references initially from Leads
Set<ID> stOwners            = new Set<ID>(); //List of eligible Store Owner Id's Using Owner value from the leads
List<CCPM_storeEmployee__c>  lstValidStoreEmployees; //List of valid store employees from the store employee object using user id
stOwners                    = validateThatLeadOwnerShouldBeStoreEmployee(OwnerValue);
//system.debug('@@@OwnerValue'+OwnerValue);
system.debug('@@@stOwners'+stOwners);
List<lead> lstSubSetNewLead = new List<lead>();

if(stOwners.size()>0 && stOwners != null){ 
try{
lstValidStoreEmployees  = [Select id,CCPM_Store__c, CCPM_employee__c,CCPM_employee__r.Id,CCPM_employee__r.CCPM_EmployeeId__c ,CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where CCPM_employee__r.id IN : stOwners AND CCPM_IsActive__c = true];
}
catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignLeadFieldsUsingEmployeeID','Exception thrown while querying Valid Store Employees',true);
}
system.debug('@@@lstValidStoreEmployees '+lstValidStoreEmployees);
if( lstValidStoreEmployees.size()>0 && lstValidStoreEmployees != null ){
//system.debug('Test whether validateThatLeadOwnerShouldBeStoreEmployee is being used - 2' +lstValidStoreEmployees);
for(integer i=0; i<lstValidStoreEmployees.size(); i++){
lstStore.add(lstValidStoreEmployees[i].CCPM_store__c);
}  
//List of all store managers
List<CCPM_storeEmployee__c> lstStoreManagers = retreiveStoreManagersBasedOnStoreIds(lstStore);

for(integer i=0; i<lstNewLeads.size(); i++){
for(integer j=0; j<lstValidStoreEmployees.size(); j++){
//Assign Owner and Store Reference for the lead records
if((lstNewLeads[i].CCPM_cartlastHandledBy__c == lstValidStoreEmployees[j].CCPM_employee__r.CCPM_commissionableRepID__c && IUFlag)|| (!IUFlag) ){
if(lstNewLeads[i].ownerid == lstValidStoreEmployees[j].CCPM_employee__r.Id || IUFlag){
lstNewLeads[i].ownerid = lstValidStoreEmployees[j].CCPM_employee__r.Id;
lstNewLeads[i].Store__c = lstValidStoreEmployees[j].CCPM_Store__c;
lstSubSetNewLead.add(lstNewLeads[i]);
}
}
}
//Code to assign store manager
if(lstStoreManagers != null && lstStoreManagers.size()>0 ){
system.debug('@@@lstStoreManagers ' + lstStoreManagers);
for(integer j=0; j<lstStoreManagers.size();j++){
//Assign Store Manager Reference for the lead records
if(lstNewLeads[i].Store__c == lstStoreManagers[j].CCPM_Store__c && (lstStoreManagers[j].CCPM_role__c == CCPM_staticConstants.strStoreManager || lstStoreManagers[j].CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager) ){
system.debug('@@@InsideManagerAssignment');
lstNewLeads[i].CCPM_storeManager__c = lstStoreManagers[j].CCPM_employee__c;
}
}
}
else{
lstNewLeads[i].CCPM_storeManager__c = null;
}
}
}
else{
for(Lead l: lstNewLeads){
//Display error if the employee is not affiliated to any store
l.addError('Please ensure the Lead Owner is a store employee.');
}                
}
}
return lstSubSetNewLead;
}
*/   
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method returns the Id's of the owners if they belong sales rep profile and are active.
@param         list of owner ID's
@return        Set<ID>
*/      
    /*   @TestVisible
private static Set<ID> validateThatLeadOwnerShouldBeStoreEmployee(List<ID> OwnerValue){
Set<ID> stOwners = new Set<ID>(); //Set of owners if they are salesrep users
List<User> lstValidUsers; //List of all sales rep users from the list of Owners
try{
lstValidUsers = [Select id,Profile.Name from User where id IN :OwnerValue AND IsActive = true And (Profile.Name = 'CCPM Sales Rep' OR Profile.Name ='CCPM Integration User')];
//system.debug('Test');
}
catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignLeadFieldsUsingEmployeeID','Exception thrown while querying SystemAdmin And DataIntegration Users',true);
}

for(Integer i=0;i<OwnerValue.size();i++){
for(Integer j=0;j<lstValidUsers.size();j++){
if(OwnerValue.get(i) == lstValidUsers[j].id){
//add list of valid users to the list of owner Id's that will be returned
stOwners.add(lstValidUsers[j].id);
}
}
}
return stOwners;
}
*/
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method returns the store records of the stores using the Store ID field values from the lead.
@param         list of owner ID's
@return        List<CCPM_Store__C>
*/        
    /*  @TestVisible
private static List<CCPM_Store__c> retreiveStoreReferenceIdsBasedOnStoreIds(Set<String> stStoreId){
List<CCPM_Store__c> lstStoreRecords; //List of records from store object using Store ID values
List<ID> lstStore = new List<ID>(); // List of store reference Id's from the store object
try{

lstStoreRecords = [Select Id,Name, CCPM_storeID__c,CCPM_TimeZone__c,CCPM_IsActive__c from CCPM_Store__c where CCPM_storeID__c IN:stStoreId AND CCPM_IsActive__c = true];
}
catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','retreiveStoreReferenceIdsBasedOnStoreIds','Exception thrown while querying for store records',true);
}

return lstStoreRecords;
}
*/
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method is to avoid recurrsion
@param         none
@return        boolean value
*/ 
    Public static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method assigns ownership based on store ID or Customer Nearest Store Values
@param         Set of Store Id's, list of New Leads, Set of Customer Account Number,List of Customer Account records
@return        none
*/  
    /*  public static void assignOwnershipUsingStoreIDAndCustomerNearestStoreValues(Set<String> stStoreId, list<Lead> lstNewLeads, Set<String> lstCustomerAccountNumber,List<Account> lstCustomerAccountFields){
//if the store is not assigned but there is a store ID available
if(stStoreId !=null && stStoreId.size()>0)
{
system.debug('@@@InsideassignOwnershipUsingStoreIDAndCustomerNearestStoreValues ' + stStoreId);
List<lead> lstSubSetNewLeadWithNoStore = new List<lead>();
List<ID> lstStore = new List<ID>(); //List of Store ID references initially from Leads
List<CCPM_Store__c> lstStoreRecords;
lstStoreRecords = retreiveStoreReferenceIdsBasedOnStoreIds(stStoreId);
if(lstStoreRecords !=null && lstStoreRecords.size()>0)
{
for(CCPM_Store__c Store : lstStoreRecords){
//add the store id values to the list of store Id's that will be returned
lstStore.add(Store.id);
}
for(integer i=0;i<lstNewLeads.size();i++){
for(integer j=0;j<lstStoreRecords.size();j++){
if(lstNewLeads[i].CCPM_storeID__c == lstStoreRecords[j].CCPM_storeID__c){
lstNewLeads[i].Store__c = lstStoreRecords[j].id;
}
}
}
setStoreManagerAndAssignLeadOwnershipBasedOnStoreId(lstNewLeads,lstStore);
for(integer i=0;i<lstNewLeads.size();i++){
if(lstNewLeads[i].Store__c == null){
lstSubSetNewLeadWithNoStore.add(lstNewLeads[i]);
system.debug('test - 203');
}
}
if(lstSubSetNewLeadWithNoStore !=null && lstSubSetNewLeadWithNoStore.size()>0 && lstCustomerAccountFields != null && lstCustomerAccountFields.size()>0){
assignLeadOwnershipBasedOnAccountHoldersNearestStore(lstCustomerAccountNumber,lstCustomerAccountFields,lstSubSetNewLeadWithNoStore);
}
}
else{
assignLeadOwnershipBasedOnAccountHoldersNearestStore(lstCustomerAccountNumber,lstCustomerAccountFields,lstNewLeads);
}
}
//If there is no store reference or a store ID
else{
assignLeadOwnershipBasedOnAccountHoldersNearestStore(lstCustomerAccountNumber,lstCustomerAccountFields,lstNewLeads);
}
}
*/  
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is targeted to update the SMS messages associated with a cart when the status is Expired/Rejected/COmpleted
Fix for TKT-000107 - Initial SMS Part 1 sent to customer even though the cart status is set to 'Complete'
@param         list of new leads
@return        Void(None)
*/    
    public static void updateSMSMessagesonClosedStatus(List<Lead> lstNewLeads, List<Lead> lstOldLeads)
    {
        // variable to store lead id's which needs to be deleted from live text scheduled message
        set<id> setUpdateSMSMessageLeadIds             = new set<id>();
        //setDeleteScheduleMessageLeadIds
        // new instance of LiveText__SMS_Schedule__c list view 
        list<CCPM_SMSMessage__c> lstSMSMessages= new list<CCPM_SMSMessage__c>();
        //lstScheduledMessages
        //Getting all the values of status referring to closed status
        String[] strCartClosedStatus=CCPM_staticConstants.strCartClosedStatus.split(':');
        //Flag to check if lead status is one of the closed status
        Boolean boolFlagToCheckForClosedStatus=False;
        
        //Iterate through all the new leads that have been updated
        for(Integer j=0;j<lstNewLeads.size();j++)
        {   
            //Only make a change if the status updated has changed from the existing status of the lead.
            if(lstNewLeads[j].status!=lstOldLeads[j].status)
            {   //Iterate through all the closed status stores in the custom setting
                for(integer i=0;i<strCartClosedStatus.size();i++)
                {
                    if (lstNewLeads[j].status==strCartClosedStatus[i])
                    {
                        boolFlagToCheckForClosedStatus=true;
                        break;
                    }   
                }
                //Adding the List of leads whose status is either Expired/Completed/Rejected/Responded
                if(boolFlagToCheckForClosedStatus || lstNewLeads[j].status==CCPM_staticConstants.strLeadStatusResponded || lstNewLeads[j].status==CCPM_staticConstants.strLeadStatusQualified) 
                {
                    setUpdateSMSMessageLeadIds.add(lstNewLeads[j].Id);
                }  
            }
        }
        
        try{
            // check that there are lead records whose status is changed to Completed / Expired / Rejected/ Responded
            // but there are SMS messages scheculed to be sent, these records needs to be updated
            if( setUpdateSMSMessageLeadIds!=NULL && setUpdateSMSMessageLeadIds.size()>0 )
            {
                //Obtaining the SMS Messages for leads whose status is Expired/Completed/Rejected and status of Message is Queued.
                lstSMSMessages    = [Select   id,CCPM_MessageStatus__c from CCPM_SMSMessage__c 
                                     where    CCPM_leadRecord__c IN :setUpdateSMSMessageLeadIds and CCPM_MessageStatus__c= :CCPM_staticConstants.strMessageStatusQueued and CCPM_messageType__c!=:CCPM_staticConstants.strMessageTypeManagers and CCPM_messageType__c!=:CCPM_staticConstants.strMessageTypeAssistantManagers and CCPM_messageType__c!=:CCPM_staticConstants.strLeadOwnerSMSOnCustomerResponse and CCPM_messageType__c!=:CCPM_staticConstants.strLeadOwnerChangeSMS];
                if( lstSMSMessages != null && lstSMSMessages.size()>0 )
                {
                    for(CCPM_SMSMessage__c SMS : lstSMSMessages)
                    {
                        SMS.CCPM_MessageStatus__c=CCPM_staticConstants.strMessageStatusRemoved;
                    }
                    //Bulk Update Scheduled Messages
                    update lstSMSMessages;
                }
            }
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','deleteScheduleMessagesOnLeadStatusChange','Exception thrown while querying Scheduled Messages and deleting them',true);
        }
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   Updates Trigger FollowUp SMS Date/Time for Leads after Initial SMS has been sent
@param         list of new leads
@return        Void(None)
*/    
    public static list<Lead> setTriggerFollowUpSMSDateTime(List<Lead> lstNewLeads, Map<id,Lead> mapOldLeads,List<BusinessHours> oBusinessHours)
    {  
        try{
            //System.debug('@@@ Inside setTriggerFollowUpSMSDateTime');
            CCPM_globalSetting__c gs    = CCPM_globalSetting__c.getInstance();
            /* BusinessHours oBusinessHours  = [Select Id
From BusinessHours 
Where IsActive = true AND IsDefault = true Limit 1];
*/
            BusinessHours oDefaultBusinessHour;
            for(Integer i=0; i<oBusinessHours.size();i++){
                if(oBusinessHours[i].IsDefault){
                    oDefaultBusinessHour = oBusinessHours[i];
                    break;
                }
            }
            Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
            //Querying for active business hours from the org
            mapLeadAndBusinessHours = getCartIdORStoreIDAndBusinessHourMap(lstNewLeads,oDefaultBusinessHour,oBusinessHours); 
            // loop each lead record which has been updated
            for(Integer i=0; i<lstNewLeads.size(); i++)
            {   
                //System.debug('@@@ Check GlobalSetting FollowUp SMS Interval : ' + gs.CCPM_followUpSMSInterval__c);  
                Lead oOldLead   = mapOldLeads.get(lstNewLeads[i].id);
                Lead oNewLead   = lstNewLeads[i];
                
                //US516
                //system.debug('@@@US516 Trigger Update - Before IF condition ');
                
                String strProfileId=UserInfo.getProfileId();
                if(oNewLead.CCPM_SMSLegalOptIn__c == true && oOldLead.CCPM_SMSLegalOptIn__c == false && strProfileId!=CCPM_staticConstants.strIntegrationUserProfileId)  
                {
                    oNewLead.CCPM_dateAndTimeConsentAgreed__c = system.now();
                    oNewLead.CCPM_consentChannelSigned__c     = CCPM_staticConstants.strLeadRetail;
                }
                //System.debug('@@@ Old Leads Initial SMS Sent : ' + oOldLead.CCPM_isInitialSMSSent__c);
                //System.debug('@@@ New Leads InitialSMSSent : ' + oNewLead.CCPM_isInitialSMSSent__c);
                
                // check that Intial SMS Sent flag has changed & intially it was false and then set to TRUE
                if(oOldLead.CCPM_isInitialSMSSent__c != oNewLead.CCPM_isInitialSMSSent__c  && oNewLead.CCPM_isInitialSMSSent__c)
                {   
                    //System.debug('@@@ Inside For Loop After Check That Initial SMS Sent Flag Has Changed');
                    //Update Trigger Follow-Up SMS Date/Time
                    if(!mapLeadAndBusinessHours.isEmpty() && mapLeadAndBusinessHours.get(lstNewLeads[i].CCPM_cartID__c) != null ){
                        
                        lstNewLeads[i].CCPM_triggerFollowupSMSDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours(mapLeadAndBusinessHours.get(lstNewLeads[i].CCPM_cartID__c), lstNewLeads[i].CCPM_TriggerInitialSMSDateTime__c.addminutes(integer.valueof(gs.CCPM_followUpSMSInterval__c)));
                        //System.debug('@@@lstNewLeads[i].CCPM_triggerFollowupSMSDateTime__c '+lstNewLeads[i].CCPM_triggerFollowupSMSDateTime__c);
                    }
                    else{
                        lstNewLeads[i].CCPM_triggerFollowupSMSDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours(oDefaultBusinessHour, lstNewLeads[i].CCPM_TriggerInitialSMSDateTime__c.addminutes(integer.valueof(gs.CCPM_followUpSMSInterval__c)));
                    }
                }
            } 
            
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','setTriggerFollowUpSMSDateTime','Exception thrown while querying for store records',true);
            
        }
        return lstNewLeads;
    }
    
    /**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is to Update the previous lead status field 
@param          List of new leads and map of old leads
@return         void
*/ 
    public static list<Lead> updatePriorStatus(List<Lead> lstNewLeads, Map<id,Lead> mapOldLeads){
        
        //Check for every new Lead Update
        
        for(lead l : lstNewLeads )
        {
            //Check if status has changed
            if(l.Status!=mapOldLeads.get(l.Id).Status)
            {   
                //Check if prior Substatus is not null/blank
                if(mapOldLeads.get(l.Id).CCPM_leadSubStatus__c!='' && mapOldLeads.get(l.Id).CCPM_leadSubStatus__c!=null)
                {
                    l.CCPM_previousLeadStatus__c=mapOldLeads.get(l.Id).Status+CCPM_staticConstants.strHyphen+mapOldLeads.get(l.Id).CCPM_leadSubStatus__c;
                }
                else
                {   //If prior substatus is null/blank
                    if(l.CCPM_createdChannel__c != Label.CCPM_telesalesChannelName && (l.Status== CCPM_staticConstants.strLeadStatusResponded || l.Status== CCPM_staticConstants.strLeadStatusQualified) && mapOldLeads.get(l.Id).Status ==CCPM_staticConstants.strLeadStatusEligible){
                        l.CCPM_previousLeadStatus__c=CCPM_staticConstants.strLeadStatusContacted;
                    }
                    else{
                        l.CCPM_previousLeadStatus__c=mapOldLeads.get(l.Id).Status;
                    }
                }
            }
            //Check if status is same but substatus has changed
            if(l.Status==mapOldLeads.get(l.Id).Status && l.CCPM_leadSubStatus__c!=mapOldLeads.get(l.Id).CCPM_leadSubStatus__c)
            {   
                //Check if Prior Substatus is not null/Blank
                if(mapOldLeads.get(l.Id).CCPM_leadSubStatus__c!=CCPM_staticConstants.strEmpty && mapOldLeads.get(l.Id).CCPM_leadSubStatus__c!=null)
                {
                    l.CCPM_previousLeadStatus__c=mapOldLeads.get(l.Id).Status+CCPM_staticConstants.strHyphen+mapOldLeads.get(l.Id).CCPM_leadSubStatus__c;   
                }
                else 
                {
                    //If Prior Substatus is null/blank
                    l.CCPM_previousLeadStatus__c=mapOldLeads.get(l.Id).Status;   
                }  
            }
            // Formating the MTN by removing the non digits
            if( l.CCPM_mobileNumber__c != NULL && l.CCPM_mobileNumber__c != mapOldLeads.get(l.Id).CCPM_mobileNumber__c )
            {
                l.CCPM_mobileNumber__c = l.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
                if( l.CCPM_confirmMTN__c != NULL)
                {
                    l.CCPM_confirmMTN__c = l.CCPM_confirmMTN__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
                }            
            }
        }
        
        return lstNewLeads;
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method populates Is MTN Available field
@param         list of new leads
@return        Void(None)
*/ 
    public static list<Lead> updateMTNAvailablefield(list<Lead> lstNewLeads)   
    { 
        //for every lead in lstNewLeads 
        for(Lead l : lstNewLeads)
        {   //Check for MTN field is null 
            if(l.CCPM_mobileNumber__c!=null)
            {   //Update is MTN Available
                l.CCPM_isMTNAvailable__c=true;
            }
        }
        
        return lstNewLeads;
    }
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method populates Trigger Prospect 1st SMS Date/Time field
@param         list of new leads
@return        Void(None)
*/ 
    public static List<Lead> assignProspectSMSDateTimeBeforeInsert(list<Lead> lstNewLeads,List<BusinessHours> oBusinessHours)   
    {  
        //system.debug('@@@assignProspectSMSDateTimeBeforeInsert');
        try{
            /* BusinessHours oBusinessHours  = [Select Id
From BusinessHours 
Where IsActive = true AND IsDefault = true Limit 1];
*/
            BusinessHours oDefaultBusinessHour;
            for(Integer i=0; i<oBusinessHours.size();i++){
                if(oBusinessHours[i].IsDefault){
                    oDefaultBusinessHour = oBusinessHours[i];
                    break;
                }
            }
            Map<String,BusinessHours> mapStoreAndBusinessHours = new map<String,BusinessHours>();
            //Querying for active business hours from the org
            mapStoreAndBusinessHours = getCartIdORStoreIDAndBusinessHourMap(lstNewLeads,oDefaultBusinessHour,oBusinessHours);
            //For each lead in list new leads
            for(Lead l : lstNewLeads)
            { 
                if(l.RecordTypeId==CCPM_staticConstants.strProspectRecordTypeID || (l.RecordTypeId==CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && l.CCPM_Type__c == ccpm_staticConstants.strLeadTypeManualLead))
                {   
                    //Check for Event Date being null
                    if(l.CCPM_SMSFollowUpDate__c!=null)
                    {
                        String strCurrentUser = UserInfo.getUserId();
                        Datetime datTEvendate = l.CCPM_SMSFollowUpDate__c;
                        system.debug('@@@ datTEvendate '+ datTEvendate);
                        system.debug('@@@ l.Store__c '+ l.Store__c);
                        system.debug('@@@ mapStoreAndBusinessHours '+ mapStoreAndBusinessHours);
                        //system.debug('@@@ mapStoreAndBusinessHours.get(l.Store__c) '+ mapStoreAndBusinessHours.get(l.Store__c)); 
                        //Check for different Even status Chosen by the Sales Rep for a prospect
                        //Add hours
                        //system.debug('**********mapStoreAndBusinessHours************'+mapStoreAndBusinessHours);
                        if(mapStoreAndBusinessHours.get(l.Store__c) != null &&  mapStoreAndBusinessHours.size()>0)
                        {
                            //system.debug('@@@ Call calculateTimeToTriggerSMSWithInBusinessHours with storeID');
                            l.CCPM_triggerProspectSMSPart1__c= calculateTimeToTriggerSMSWithInBusinessHours(mapStoreAndBusinessHours.get(l.Store__c), datTEvendate);
                        }
                        else
                        {
                            //system.debug('@@@ Call calculateTimeToTriggerSMSWithInBusinessHours with Default');
                            l.CCPM_triggerProspectSMSPart1__c= calculateTimeToTriggerSMSWithInBusinessHours(oDefaultBusinessHour, datTEvendate);
                        }
                    }
                    
                }
                
            }
            
            return lstNewLeads;
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignProspectSMSDateTimeBeforeInsert','Exception thrown while querying for store records',true);
            return lstNewLeads;
        }
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method assigns the Lead Owner, Lead Store, Lead Store Manager and Lead StoreID based on current users for Prospects.
@param         list of new leads
@return        Void(None)
*/ 
    public static List<Lead> assignProspectLeadOwner(list<Lead> lstNewLeads,map<string,group> mapDistrictAndGroup)   
    {   
        //Getting the ID of the current User
        Id iDCurrentStoreEmployee = UserInfo.getUserId();
        //System.debug('# Current Store Employee ID-> '+ iDCurrentStoreEmployee);
        list<CCPM_storeEmployee__c> lstStoreEmployee= new list<CCPM_storeEmployee__c>();
        list<lead> lstnewManualList = new list<lead>();
        
        //Get the Store Id associated with the current user
        try
        {
            for(lead objlead:lstNewLeads)
            {
                if(objlead.RecordTypeId==CCPM_staticConstants.strProspectRecordTypeID || objlead.CCPM_isManualLead__c==true)
                {
                    lstnewManualList.add(objlead);
                }
            }
            if(iDCurrentStoreEmployee!=null  && !string.isBlank(iDCurrentStoreEmployee) && lstnewManualList!=null )
            {
                lstStoreEmployee= [Select CCPM_Store__c,CCPM_Store__r.CCPM_storeID__c,CCPM_store__r.CCPM_TimeZone__c,CCPM_Store__r.CCPM_IsActive__c,CCPM_employee__c,CCPM_Store__r.CCPM_market__c,CCPM_IsActive__c from CCPM_storeEmployee__c where CCPM_employee__c= :iDCurrentStoreEmployee AND CCPM_IsActive__c = true and CCPM_employee__r.isActive = true limit 1];
            }
            
        }
        catch(Exception e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignProspectLeadOwner','Exception thrown while retrieving store employees',true); 
        }
        List<Lead> lstLeadsWithOwners = new List<Lead>();
        //System.debug('Store Employee List-> '+lstStoreEmployee);
        //Get the Store Manager ID and the Store ID associated with the store and the current user
        if(lstnewManualList!=null)
        {
            lstLeadsWithOwners = assignProspectOrManualLeadOwner(lstnewManualList,lstStoreEmployee,mapDistrictAndGroup,iDCurrentStoreEmployee);
        }
        
        return lstNewLeads;
    } 
    
    /**
@author         Manjunath Keshava (Deloitte)
@description    This method is to assign lead owners for prospects or manual leads. 
@param          List of new leads
@return         void
*/ 
    //will run only for Manual Leads/ Manual Prospect Records created at the store
    public static List<Lead>  assignProspectOrManualLeadOwner(list<Lead> lstnewManualList,list<CCPM_storeEmployee__c> lstStoreEmployee,map<string,group> mapDistrictAndGroup,Id iDCurrentStoreEmployee)
    {
        list<CCPM_storeEmployee__c> lstStoreManager= new list<CCPM_storeEmployee__c>();
        if(lstStoreEmployee!=null && !lstStoreEmployee.isEmpty() &&  lstStoreEmployee[0].CCPM_Store__c !=null )
        {
            try
            {
                //For each new lead inserted
                lstStoreManager = [Select CCPM_employee__c,CCPM_store__r.CCPM_storeID__c,CCPM_store__r.CCPM_TimeZone__c from CCPM_storeEmployee__c where CCPM_Store__c= :lstStoreEmployee[0].CCPM_Store__c and CCPM_IsActive__c = true and CCPM_employee__r.isActive = true and CCPM_role__c = :CCPM_staticConstants.strStoreManager limit 1];
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignProspectOrManualLeadOwner','Exception thrown while retrieving store Manager',true); 
            }
            for(lead objlead : lstnewManualList)
            { 
                if( lstStoreEmployee[0].CCPM_Store__c!=null )
                {
                    //Check for the account Unique ID field if its null/''
                    if(lstStoreEmployee[0].CCPM_Store__r.CCPM_IsActive__c == true )
                    {   
                        //System.debug('INside loop');
                        //Setting Owner Id, Store Id, Store Manager and Store for Prospect lead record type
                        objlead.OwnerId= iDCurrentStoreEmployee;
                        if(lstStoreEmployee[0].CCPM_Store__r.CCPM_storeID__c!=null && lstStoreEmployee[0].CCPM_Store__r.CCPM_IsActive__c==true)
                        {
                            objlead.CCPM_storeID__c= lstStoreEmployee[0].CCPM_Store__r.CCPM_storeID__c;
                        }
                        
                        if(lstStoreManager!=null && lstStoreManager.isEmpty()==false && lstStoreManager.size()>0  )
                        {
                            objlead.CCPM_storeManager__c=lstStoreManager[0].CCPM_employee__c;
                        }
                        
                        objlead.Store__c=lstStoreEmployee[0].CCPM_Store__c;
                        objlead.CCPm_StoreTimeZone__c = lstStoreEmployee[0].CCPM_store__r.CCPM_TimeZone__c;
                    }
                    //if the store is not active we assign the lead to the market queue
                    else 
                    {
                        //Assign to telesales queue
                        if(objlead.CCPM_createdChannel__c != null && objlead.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName){
                            objlead.OwnerId= CCPM_staticConstants.strTeleSalesQueue;
                        }
                        if( mapDistrictAndGroup != null && mapDistrictAndGroup.containsKey(lstStoreEmployee[0].CCPM_Store__r.CCPM_market__c) &&  mapDistrictAndGroup.get(lstStoreEmployee[0].CCPM_Store__r.CCPM_market__c) != null)
                        {
                            objlead.OwnerId= mapDistrictAndGroup.get(lstStoreEmployee[0].CCPM_Store__r.CCPM_market__c).id;
                        }
                        
                    }
                    //Call here
                }
            }
        }
        //check if the user is inactive 
        else if(lstStoreEmployee.isEmpty())
        {
            // map<String,string> mapLeadAndCustomerAccountNumber= new map<String,string>();    //Set of Customer Account Numbers from the leads
            list<Account> lstCustomerAccount = new list<account>();
            set<String> setLeadAndCustomerAccountNumber = new set<String>();
            map<string,Account> mapAccount = new map<string,account>();
            set<string> setStoreId = new set<String>();
            map<string,CCPM_storeEmployee__c> mapAssignManager = new map<string,CCPM_storeEmployee__c>();
            map<string,CCPM_storeEmployee__c> mapAssignAssManagager= new map<string,CCPM_storeEmployee__c>();
            for(lead objlead : lstnewManualList)
            {  
                if(  objlead.CCPM_accountUniqueID__c!=null)
                {
                    setLeadAndCustomerAccountNumber.add(objlead.CCPM_accountUniqueID__c);
                }
                
            }
            try
            {
                //query for accounts with the account related to the lead object using account unique id as filter
                if(setLeadAndCustomerAccountNumber!=null && setLeadAndCustomerAccountNumber.isEmpty()==false)
                {
                    lstCustomerAccount = [Select Id,CCPM_store__c,CCPM_store__r.id,CCPM_store__r.CCPM_storeID__c,CCPM_store__r.CCPM_IsActive__c,CCPM_store__r.CCPM_TimeZone__c, CCPM_accountNumber__c,CCPM_storeID__c, CCPM_accountUniqueID__c from Account where CCPM_store__c !=null AND CCPM_storeID__c!=null AND CCPM_store__r.CCPM_IsActive__c = true AND  Account.CCPM_accountUniqueID__c IN : setLeadAndCustomerAccountNumber];
                }
                
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignProspectOrManualLeadOwner','Exception thrown while retrieving customer accounts',true); 
            }
            
            if(lstCustomerAccount.isEmpty()==false)
            {
                for(Account objAcc : lstCustomerAccount)
                {
                    if(objAcc != null)
                    {
                        mapAccount.put(objAcc.CCPM_accountUniqueID__c,objAcc);
                        if(objAcc.CCPM_store__c!=null)
                        {
                            setStoreId.add(objAcc.CCPM_store__c);
                        }
                    }
                }
            }
            
            list<CCPM_storeEmployee__c> lstStoreEmployees= new list<CCPM_storeEmployee__c>();
            try
            {
                if(setStoreId != null && setStoreId.isEmpty()==false) 
                    lstStoreEmployees = [Select id, CCPM_Store__c,CCPM_Store__r.CCPM_storeID__c,CCPM_Store__r.CCPM_IsActive__c,CCPM_role__c,CCPM_employee__c,CCPM_Store__r.CCPM_market__c,CCPM_IsActive__c from CCPM_storeEmployee__c where CCPM_Store__c =:setStoreId AND CCPM_IsActive__c = true and CCPM_employee__r.isActive = true ];
                //system.debug('it has entered the block'+lstStoreEmployees);
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignProspectOrManualLeadOwner','Exception thrown while retrieving store employees',true); 
            }
            for(CCPM_storeEmployee__c objEmploye : lstStoreEmployees)
            {
                if(objEmploye.CCPM_role__c!= null && objEmploye.CCPM_role__c == CCPM_staticConstants.strStoreManager)
                {
                    mapAssignManager.put(objEmploye.CCPM_Store__c,objEmploye);
                }
                else if(objEmploye.CCPM_role__c!=null && objEmploye.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager)
                {
                    mapAssignAssManagager.put(objEmploye.CCPM_Store__c,objEmploye);
                }
            }
            
            if(!lstCustomerAccount.isEmpty())
            {
                for(lead objlead : lstnewManualList)
                {
                    
                    //assign store and store id to lead based on the account Near store ID and assign active managers or assistant managers as owners 
                    if(mapAccount != null && mapAccount.containsKey(objlead.CCPM_accountUniqueID__c))
                    {          
                        objlead.Store__c = mapAccount.get(objlead.CCPM_accountUniqueID__c).CCPM_store__c;
                        objlead.CCPm_StoreTimeZone__c = mapAccount.get(objlead.CCPM_accountUniqueID__c).CCPM_store__r.CCPM_TimeZone__c;
                        objlead.CCPM_storeID__c= mapAccount.get(objlead.CCPM_accountUniqueID__c).CCPM_store__r.CCPM_storeID__c;
                    } 
                    if(  mapAssignManager != null && mapAssignManager.containsKey(objlead.Store__c))
                    {
                        objlead.CCPM_storeManager__c = mapAssignManager.get(objlead.Store__c).CCPM_employee__c;
                        objlead.OwnerId = mapAssignManager.get(objlead.Store__c).CCPM_employee__c;     
                    } 
                    else if(mapAssignAssManagager != null && mapAssignAssManagager.containsKey(objlead.Store__c))
                    {
                        objlead.CCPM_storeManager__c = mapAssignAssManagager.get(objlead.Store__c).CCPM_employee__c;
                        objlead.OwnerId = mapAssignAssManagager.get(objlead.Store__c).CCPM_employee__c;          
                    }
                    else
                    {
                        //if managers and assistant managers are inactive assign to the market queue
                        //Assign to telesales queue
                        if(objlead.CCPM_createdChannel__c != null && objlead.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName){
                            objlead.OwnerId= CCPM_staticConstants.strTeleSalesQueue;
                        }
                        else if(mapDistrictAndGroup != null && mapDistrictAndGroup.containsKey(lstStoreEmployees[0].CCPM_Store__r.CCPM_market__c)){
                            objlead.OwnerId= mapDistrictAndGroup.get(lstStoreEmployees[0].CCPM_Store__r.CCPM_market__c).id; 
                        }  
                    }
                    
                }
                
            }
            //if its Manual Lead with an  account  that doesnt have near store ID or if its manual prospect without account its assigned to the headquarters
            else{
                
                try{
                    
                    lstStoreEmployees = [Select id, CCPM_Store__c,CCPM_Store__r.CCPM_storeID__c,CCPM_Store__r.CCPM_IsActive__c,CCPM_employee__c,CCPM_Store__r.CCPM_market__c,CCPM_IsActive__c from CCPM_storeEmployee__c where CCPM_employee__c=: iDCurrentStoreEmployee and CCPM_IsActive__c= false ];
                    system.debug('the employee is'+lstStoreEmployees);
                    
                }
                catch(Exception e)
                {
                    CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignProspectOrManualLeadOwner','Exception thrown while retrieving store employees',true); 
                }
                if(lstStoreEmployees!=null && !lstStoreEmployees.isEmpty())
                {
                    for(lead objlead : lstnewManualList)
                    {
                        //Assign to telesales queue
                        if(objlead.CCPM_createdChannel__c != null && objlead.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName){
                            objlead.OwnerId= CCPM_staticConstants.strTeleSalesQueue;
                        }
                        else{
                            objlead.OwnerId = CCPM_staticConstants.strDataIntegrationUserQueue;
                        }
                    }
                }
            }
        } 
        return lstnewManualList;
    }
    
    
    
    
    /**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is to schedule Follow-Up SMS for Leads on Update. 
@param          List of new leads, Map of Old Leads
@return         void
*/ 
    
    public static void insertRecordsInSmsmessageObjectForLeadAndProspects(List<Lead> lstNewLeads, map<id,lead> mapoldLead,Map<String,Group> mapDistrictAndGroup){
        //System.debug('Listoflead'+lstNewLeads );
        set<id> setQueueIDs = new set<id>();
        if(mapDistrictAndGroup!=null && mapDistrictAndGroup.isEmpty()==false)
        {
            setQueueIDs.addAll(getSetOfQueueID(mapDistrictAndGroup));         
        }
        // looping through and insert the list of id in setLstID
        set<String> setUniqueID = new set<String>();
        //List of Account map with associated lead id
        map<String,Account> mapAccountAndLeadid = new map<String,Account>();
        //List of Leads for which SMS needs to be scheduled
        list<lead> lstLeadtoSendFollowUpSMS = new list<lead>();
        //add the unique ID's and the salesforce ID's of the leads to local variables
        for(Lead objLead: lstnewLeads)
        {   
            if(objLead.CCPM_isInitialSMSSent__c ==true && objLead.CCPM_isFollowUpSMSSent__c == false && objLead.ownerid!=null 
               && setQueueIDs!=null && setQueueIDs.isEmpty()==false && setQueueIDs.contains(objLead.OwnerId)==false && 
               (objLead.CCPM_isInitialSMSSent__c!=mapoldLead.get(objLead.id).CCPM_isInitialSMSSent__c  || (setQueueIDs.contains(mapoldLead.get(objLead.id).ownerid))))
            {   
                if(objLead.CCPM_accountUniqueID__c!=null)
                {
                    setUniqueID.add(objLead.CCPM_accountUniqueID__c);
                }
                
                lstLeadtoSendFollowUpSMS.add(objLead);
            }
        }
        
        //System.debug('setUniqueID->'+setUniqueID);
        //System.debug('setUniqueIDSize->'+setUniqueID.size());
        if( setUniqueID != null && setUniqueID.size()>0 )
        {
            list<Account> lstAccountLeadId = new list<Account>([SELECT CCPM_accountUniqueID__c,CCPM_SMSOptOut__c FROM Account WHERE CCPM_accountUniqueID__c IN :setUniqueID]);
            
            //Create a map for Account and the respective lead id
            if(lstAccountLeadId!=null && lstAccountLeadId.size()>0)
            {
                for(Account objAccount : lstAccountLeadId )
                {
                    mapAccountAndLeadid.put(objAccount.CCPM_accountUniqueID__c,objAccount);
                }                
            }
        }
        
        //Create the list instance for CCPM_SMSMessage__c
        List<CCPM_SMSMessage__c> lstSmsMessage = new List<CCPM_SMSMessage__c>();
        //Check for every new Lead and Update SMS message based on if CCPM_isFollowupSMSsent and CCPM_InititalSMSsent are not sent
        if(lstLeadtoSendFollowUpSMS.size()>0)
        {
            for(lead objLead : lstLeadtoSendFollowUpSMS )
            {
                if(((objLead.recordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID ) || (objLead.recordTypeId == CCPM_staticConstants.strProspectRecordTypeID)  || (objLead.recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && (objLead.CCPM_accountUniqueID__c!=null) && mapAccountAndLeadid.containsKey(objLead.CCPM_accountUniqueID__c) && ( !(mapAccountAndLeadid.get(objLead.CCPM_accountUniqueID__c).CCPM_SMSOptOut__c) || ( objLead.CCPM_isManualLead__c!= NULL && objLead.CCPM_isManualLead__c == true ) ) ) )
                   &&(objLead.status!=CCPM_staticConstants.strLeadStatusConverted && objLead.status!=CCPM_staticConstants.strLeadStatusExpired 
                      && objLead.status!=CCPM_staticConstants.strLeadStatusResponded && objLead.status!=CCPM_staticConstants.strLeadStatusQualified)){
                          CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
                          if(objLead.CCPM_isFollowUpSMSSent__c == false && objLead.CCPM_isInitialSMSSent__c == true && objLead.CCPM_mobileNumber__c != null ){
                              //create sms messages object record
                              String strToPhone = objLead.CCPM_mobileNumber__c;
                              if(objLead.recordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID || objLead.recordTypeId == CCPM_staticConstants.strProspectRecordTypeID)
                              {
                                  String strMessage = objLead.CCPM_ProspectFollowUpSMSBody__c;
                                  objSmsMessage = createRecordsForSmsMessageObject(objLead,strMessage,strToPhone,CCPM_staticConstants.strMessageTypeFollowUpSMS,CCPM_StaticConstants.strTaskCommunicationOutbound,objLead.CCPM_triggerFollowupSMSDateTime__c,CCPM_staticConstants.strLivetextPhoneNumberNonVerizon);
                              }
                              else if(objLead.recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && objLead.CCPM_Type__c != ccpm_staticConstants.strLeadTypeCampaignLead)
                              {
                                  String strMessage = objLead.CCPM_followupMessageBody__c;
                                  objSmsMessage = createRecordsForSmsMessageObject(objLead,strMessage,strToPhone,CCPM_staticConstants.strMessageTypeFollowUpSMS,CCPM_StaticConstants.strTaskCommunicationOutbound,objLead.CCPM_triggerFollowupSMSDateTime__c,CCPM_staticConstants.strLivetextPhoneNumber);
                              }
                              else if(objLead.recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && objLead.CCPM_Type__c != null && objLead.CCPM_Type__c == ccpm_staticConstants.strLeadTypeCampaignLead)
                              { //Insert follow up for campaign leads
                                  String strMessage = objLead.CCPM_CampingFollowUpMessageTemplate__c ;
                                  
                                  //System.debug('@@@InsideCampaignFollowup' + strMessage);
                                  if(strMessage != null && !String.isBlank(strMessage)){
                                      objSmsMessage = createRecordsForSmsMessageObject(objLead,strMessage,strToPhone,CCPM_staticConstants.strMessageTypeCampaignFollowUpSMS,CCPM_StaticConstants.strTaskCommunicationOutbound,objLead.CCPM_triggerFollowupSMSDateTime__c,CCPM_staticConstants.strLivetextPhoneNumber);
                                      if(objSmsMessage != null && !objLead.CCPM_SMSOptOut__c){
                                          objSmsMessage.CCPM_dynamicLeadOwnerName__c = objLead.CCPM_ownerFirstName__c;
                                          objSmsMessage.CCPM_dynamicStoreName__c = objLead.CCPM_storeName__c;
                                          objSmsMessage.CCPM_dynamicStoreRecommendedHrs__c = objLead.CCPM_storeRecommendedHours__c;
                                      }
                                  } 
                              }
                              if(objSmsMessage!= null && objLead.CCPM_mobileNumber__c != null && objSmsMessage.CCPM_leadRecord__c!=null && objLead.CCPM_mobileNumber__c != CCPM_staticConstants.strSpace && (!objLead.CCPM_SMSOptOut__c || ( objLead.CCPM_isManualLead__c!= NULL && objLead.CCPM_isManualLead__c == true ))){
                                  //add smsmessages object to the list
                                  lstSmsMessage.add(objSmsMessage); 
                              }
                          }  
                      } 
            }
        }
        if( lstSmsMessage != null && lstSmsMessage.size()>0 ){
            try
            {
                //Insert the list of sms messages records
                insert lstSmsMessage;
            }
            
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','insertRecordsInSmsmessageObjectForLeadAndProspects','Exception thrown while inserting SMSMessages for the Lead owner',true); 
            }
        }
    }
    
    
    
    /**
@author        Sriraman Sridharan (Deloitte)
Brigadesh Chandrasekar(Deloitte) - modified to account for Owner Queues
@description   This method inserts records in the sms messages object when a lead/prospect record is created.
@param         list of new leads
@return        Void(None)
*/ 
    public static void populateInitialSMSMessagesToBeSent(list<Lead> lstNewLeads,Map<String,Group> mapDistrictAndGroup, set<id> setQueueIDGeneric)   
    {   //System.debug('populateInitialSMSMessagesToBeSent->');
        //Instantiate the Set to contain set queue id's
        set<id> setQueueIDs = new set<id>();
        //Check if the parameter value is null to differentiate between update and insert Trigger
        if(setQueueIDGeneric!=null && setQueueIDGeneric.size()>0)
        {
            setQueueIDs.addAll(setQueueIDGeneric);
        }
        else if(mapDistrictAndGroup!=null && mapDistrictAndGroup.isEmpty()==false)
        {
            setQueueIDs.addAll(getSetOfQueueID(mapDistrictAndGroup));         
        }
        
        //Create instance(List) for CCPM_SMSMessage__c
        List<CCPM_SMSMessage__c> lstSmsMessage = new List<CCPM_SMSMessage__c>();
        //Insert in CCPM_SMSMessage__c
        set<String> setLstUniqueID = new set<String>();
        // looping through and insert the list of id in setLstID
        
        for(Lead l: lstnewLeads)
        {
            if(l.CCPM_accountUniqueID__c!=null && l.ownerid!=null && setQueueIDs!=null && setQueueIDs.isEmpty()==false && setQueueIDs.contains(l.OwnerId)==false)
            {
                setLstUniqueID.add(l.CCPM_accountUniqueID__c);
            }
        }
        //List of Account map with associated lead id
        map<String,Account> mapAccountAndLeadid = new map<String,Account>();
        //List of accounts queried from account object
        try{
            if( setLstUniqueID != null && setLstUniqueID.size()>0){
                list<Account> lstAccountLeadId = new list<Account>([SELECT CCPM_accountUniqueID__c,CCPM_SMSOptOut__c FROM Account WHERE CCPM_accountUniqueID__c IN :setLstUniqueID]);
                for(Account a : lstAccountLeadId )
                {
                    mapAccountAndLeadid.put(a.CCPM_accountUniqueID__c,a);
                }
                //System.debug('@@@Lstinitial->'+setLstUniqueID+'@@@Lst' + lstAccountLeadId + '@@@map' + mapAccountAndLeadid); 
            }
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','populateInitialSMSMessagesToBeSent','Exception thrown while inserting SMSMessages for the Lead owner',true); 
        }
        Set<String> setleadEventToExclude = new Set<String>();
        for(String strEventType : Label.CCPM_LeadEventToExclude.split(',')){
            setleadEventToExclude.add(strEventType.trim());
        }
        //Send initial messages for all the leads/Prospects by inserting records into sms messages object
        for(integer i=0;i<lstNewLeads.size();i++) {
            if(lstNewLeads[i].ownerid!=null && setQueueIDs!=null && setQueueIDs.isEmpty()==false && setQueueIDs.contains(lstNewLeads[i].ownerid)==false)
            {
                //SMS initial Messages
                CCPM_SMSMessage__c objSmsMessage1 = new CCPM_SMSMessage__c();
                CCPM_SMSMessage__c objSmsMessage2 = new CCPM_SMSMessage__c();
                if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectRecordTypeID && lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusConverted && lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusExpired 
                   && lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusResponded && lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusQualified && !setleadEventToExclude.contains(lstNewLeads[i].CCPM_eventType__c))
                {
                    system.debug('********'+setleadEventToExclude);
                    system.debug('$$$$$$$$$$$$'+lstNewLeads[i].CCPM_eventType__c);
                    //Prospect 1st SMS
                    //Is MTN Available?
                    if(lstNewLeads[i].CCPM_mobileNumber__c != null && lstNewLeads[i].CCPM_mobileNumber__c != CCPM_staticConstants.strSpace){
                        String MTN = lstNewLeads[i].CCPM_mobileNumber__c;
                        String strMessage1 = lstNewLeads[i].CCPM_prospectSMSBody__c;
                        String strToPhone1 = MTN;
                        
                        objSmsMessage1 = createRecordsForSmsMessageObject(lstNewLeads[i],strMessage1,strToPhone1,CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1,CCPM_StaticConstants.strTaskCommunicationOutbound,lstNewLeads[i].CCPM_triggerProspectSMSPart1__c,CCPM_staticConstants.strLivetextPhoneNumberNonVerizon);
                        // System.debug('objSmsMessage1->'+objSmsMessage1);
                        //Prospect 2nd SMS
                        //add the message objects to the list
                        if(objSmsMessage1 != null && !lstNewLeads[i].CCPM_SMSOptOut__c){
                            lstSmsMessage.add(objSmsMessage1);
                        }
                    }
                }
                //&& !(mapAccountAndLeadid.get(lstNewLeads[i].id).CCPM_SMSOptOut__c)
                else if(((lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID) || ((lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID  || ( lstNewLeads[i].CCPM_isManualLead__c!= NULL && lstNewLeads[i].CCPM_isManualLead__c == true )) && lstNewLeads[i].CCPM_accountUniqueID__c!=null && mapAccountAndLeadid.containsKey(lstNewLeads[i].CCPM_accountUniqueID__c) && ( !(mapAccountAndLeadid.get(lstNewLeads[i].CCPM_accountUniqueID__c).CCPM_SMSOptOut__c) ))) 
                        &&(lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusConverted && lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusExpired 
                           && lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusResponded && lstNewLeads[i].status!=CCPM_staticConstants.strLeadStatusQualified ))
                {
                    //Lead 1st SMS
                    //System.debug('@@@SMSOptOut' +lstNewLeads[i].CCPM_Account__r.CCPM_SMSOptOut__c + '@@@Name' + lstNewLeads[i].name + '@@@CUName' + lstNewLeads[i].CCPM_Account__r.name);
                    //Is MTN Available?
                    if(lstNewLeads[i].CCPM_mobileNumber__c != null && lstNewLeads[i].CCPM_mobileNumber__c != ' ')
                    {
                        String MTN = lstNewLeads[i].CCPM_mobileNumber__c;
                        // String strMessage1 = lstNewLeads[i].CCPM_initialSMSBody__c;
                        String strToPhone1 = MTN;
                        if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID)
                        {
                            String strMessage1 = lstNewLeads[i].CCPM_prospectInitialSMSBody__c;
                            objSmsMessage1 = createRecordsForSmsMessageObject(lstNewLeads[i],strMessage1,strToPhone1,CCPM_staticConstants.strMessageTypeInitialSMSPart1,CCPM_StaticConstants.strTaskCommunicationOutbound,lstNewLeads[i].CCPM_triggerInitialSMSDateTime__c,ccpm_staticConstants.strLivetextPhoneNumberNonVerizon);
                        }
                        else if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_Type__c != ccpm_staticConstants.strLeadTypeManualLead && lstNewLeads[i].CCPM_Type__c != ccpm_staticConstants.strLeadTypeCampaignLead)
                        {
                            String strMessage1 = lstNewLeads[i].CCPM_initialSMSBody__c;
                            objSmsMessage1 = createRecordsForSmsMessageObject(lstNewLeads[i],strMessage1,strToPhone1,CCPM_staticConstants.strMessageTypeInitialSMSPart1,CCPM_StaticConstants.strTaskCommunicationOutbound,lstNewLeads[i].CCPM_triggerInitialSMSDateTime__c,ccpm_staticConstants.strLivetextPhoneNumber);
                        }
                        else if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_Type__c == ccpm_staticConstants.strLeadTypeManualLead  && lstNewLeads[i].CCPM_SMSFollowUpDate__c != null && lstNewLeads[i].CCPM_eventType__c != null &&  !setleadEventToExclude.contains(lstNewLeads[i].CCPM_eventType__c))
                        {
                            String strMessage1 = lstNewLeads[i].CCPM_manualLeadSMSBody__c;
                            objSmsMessage1 = createRecordsForSmsMessageObject(lstNewLeads[i],strMessage1,strToPhone1,CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1,CCPM_StaticConstants.strTaskCommunicationOutbound,lstNewLeads[i].CCPM_triggerProspectSMSPart1__c,CCPM_staticConstants.strLivetextPhoneNumber);
                        }
                        //Check for SMS Opt Out at Lead Level
                        //add the message objects to the list
                        if(objSmsMessage1 != null && objSmsMessage1.CCPM_leadRecord__c!=null && ( !lstNewLeads[i].CCPM_SMSOptOut__c || ( lstNewLeads[i].CCPM_isManualLead__c!= NULL && lstNewLeads[i].CCPM_isManualLead__c == true ) ) ){
                            lstSmsMessage.add(objSmsMessage1);
                        }
                    }
                }
            }
            
            
        }
        if( lstSmsMessage != null && lstSmsMessage.size()>0)
        {
            //insert the list of sms messages records
            insert lstSmsMessage;
        }
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method inserts records in the sms messages object to send Initial SMS and Prospect 1st SMS on Update of an Owner queue to a valid Owner
@param         list of new leads, map of Old Leads, map og Group names and Ids
@return        Void(None)
*/ 
    
    public static void populateInitialProspectSMSForValidLeadOwnerChange(List<Lead> lstNewLeads,map<id,Lead> mapOldLeads,Map<String,Group> mapDistrictAndGroup)
    {   
        //Instantiate a set of Queue IDs
        set<id> setQueueID = new set<id>();
        //INstantiate a list of Lead
        List<Lead> lstInsertSMSForLead = new list<Lead>();
        //Check if the map parameter received is null/Empty
        
        if(mapDistrictAndGroup!=null && mapDistrictAndGroup.isEmpty()==false)
        {
            setQueueID.addAll(getSetOfQueueID(mapDistrictAndGroup));            
        }
        //Check if the set returned by the method call out is not empty
        if(setQueueID!=null && setQueueID.isEmpty()==false)
        {   
            //For every lead in the list of new leads
            for(Lead l : lstNewLeads)
            {   //Check if owner id has changed, if the old owner id was a queue, if the status is eligible
                if(l.OwnerId != mapOldLeads.get(l.id).ownerid && setQueueID.contains(mapOldLeads.get(l.id).ownerid) == true && l.Status == CCPM_staticConstants.strLeadStatusEligible && l.Status==mapOldLeads.get(l.id).status)
                {   //Insert the lead into the list instantiated
                    lstInsertSMSForLead.add(l);
                }
            }
        }
        //Check if the Lead list is empty and make a callout to insert SMS message records
        if(lstInsertSMSForLead!=null && lstInsertSMSForLead.size()>0)
        {
            populateInitialSMSMessagesToBeSent(lstInsertSMSForLead,mapDistrictAndGroup,setQueueID);
        }
    }
    
    /**
@author         Brigadesh Chandrasekar (Deloitte)
Dheeraj(Modified Business Hours)
Brigadesh (Fixed Business Hours Defect 08/29/2017)
Sriraman (Included messages for manual lead owner change and lead owner change due to store employee mass update)
@description   This method inserts records in the sms messages object to send SMS to Lead Owner.
@param         list of new leads, map of Old Leads
@return        Void(None)
*/ 
    public static void populateSMSMessageToBeSentForLeadOwnerChange(list<Lead> lstNewLeads, Map<id,Lead> mapOldLeads)
    {
        List<CCPM_SMSMessage__c> lstSMSMessage = new List<CCPM_SMSMessage__c>();
        set<id> setLeadOwnerID = new set<id>();
        DateTime datTBusinessTime;
        List<BusinessHours> objBusinessHours = getBusinessHours();
        BusinessHours objBusinessHoursStore = new BusinessHours();
        Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
        List<Lead> lstleadsforBusinessHour          = new List<Lead>();
        
        for(Lead l : lstNewLeads)
        {
            if(l.OwnerId != null){
                setLeadOwnerID.add(l.OwnerId);
            }
        }
        //system.debug('@@@@ objBusinessHours : '+ objBusinessHours );
        BusinessHours objDefaultBusinessHour =new BusinessHours();
        for(Integer i=0; i<objBusinessHours.size();i++)
        {
            if(objBusinessHours[i].IsDefault)
            {
                objDefaultBusinessHour = objBusinessHours[i];
                break;
            }
        }
        //system.debug(' @@@@ objDefaultBusinessHour ' + objDefaultBusinessHour);
        
        map<id,User> mapLeadOwners = new map<id,User>();
        List<lead> lstLeadsToBeUpdated = new List<Lead>();
        Set<String> setStoreID = new Set<String>();
        List<CCPM_storeEmployee__c> lstStoreEmployees = new List<CCPM_storeEmployee__c>();
        List<CCPM_storeEmployee__c> lstmanagersAndAsstManagers = new List<CCPM_storeEmployee__c>();
        try{
            mapLeadOwners = new map<id,User>([select id,MobilePhone,firstname from user where id in :setLeadOwnerID and mobilephone!=null and isactive=true]);
        }Catch(Exception e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','insertSMSMessageObjectForLeadOwner','Exception thrown while preparing to insert SMS Messages',true); 
        }
        mapLeadAndBusinessHours = getCartIdORStoreIDAndBusinessHourMap(lstNewLeads,objDefaultBusinessHour,objBusinessHours);
        for(Lead l : lstNewLeads)
        {   // system.debug(' @@@@ objBusinessHoursStore '+ objBusinessHoursStore);
            //system.debug(' @@@@ datTBusinessTime '+ datTBusinessTime);
            //Check for Status change, owner change and Status Criterias
            system.debug('111111---->'+(l.CCPM_isStoreEmployeeUpdated__c == mapOldLeads.get(l.id).CCPM_isStoreEmployeeUpdated__c));
            system.debug('111111---->'+(l.Status==CCPM_staticConstants.strLeadStatusQualified ));
            system.debug('111111---->'+(l.CCPM_leadSubStatus__c));
            if(l.CCPM_isStoreEmployeeUpdated__c == mapOldLeads.get(l.id).CCPM_isStoreEmployeeUpdated__c 
               && l.OwnerId!=mapOldLeads.get(l.id).ownerid && ((l.Status==CCPM_staticConstants.strLeadStatusQualified 
                                                                && 
                                                                (l.CCPM_leadSubStatus__c==CCPM_staticConstants.strLeadSubStatusInDiscussion || l.CCPM_leadSubStatus__c==CCPM_staticConstants.strLeadSubStatusAppointmentScheduled || l.CCPM_leadSubStatus__c==CCPM_staticConstants.strLeadSubStatusNeedsStoreReassignment
                                                                 || l.CCPM_leadSubStatus__c==CCPM_staticConstants.strLeadSubStatusServiceIssue)) || (l.Status==CCPM_staticConstants.strLeadStatusResponded && l.CCPM_leadSubStatus__c==CCPM_staticConstants.strLeadSubStatusActionRequired) )  )
            {   
                /*
lstLeadsToBeUpdated.add(l);
if(l.Store__c != null){
setStoreID.add(l.Store__c);
} */
                if(l.OwnerId!= null && mapLeadOwners.ContainsKey(l.OwnerId) && mapLeadOwners.get(l.OwnerId).mobilephone!=null)
                {   
                    System.debug('@@@@@');
                    if(l.Store__c != null && mapLeadAndBusinessHours != null && mapLeadAndBusinessHours.containsKey(l.store__c) && mapLeadAndBusinessHours.get(l.store__c)!=null)
                    {
                        //system.debug(' @@@@ '+mapLeadAndBusinessHours.get(l.store__c));
                        objBusinessHoursStore = mapLeadAndBusinessHours.get(l.store__c);
                    }
                    else if(mapLeadAndBusinessHours != null && l.CCPM_cartID__c !=null && mapLeadAndBusinessHours.containsKey(l.CCPM_cartID__c) && mapLeadAndBusinessHours.get(l.CCPM_cartID__c)!=null)
                    {
                        objBusinessHoursStore = mapLeadAndBusinessHours.get(l.CCPM_cartID__c);
                    }
                    else
                    {
                        objBusinessHoursStore = objDefaultBusinessHour;
                    }
                    datTBusinessTime = calculateTimeToTriggerSMSWithInBusinessHours(objBusinessHoursStore, System.now());
                    
                    //Populating fields for creating SMSMessage Record to send SMS to Lead owner on change of ownership
                    CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
                    
                    String strMessage = l.CCPM_ManuallyChangeOwnershipMessage__c;
                    
                    String strToPhone = mapLeadOwners.get(l.OwnerId).mobilephone;
                    
                    objSmsMessage = createRecordsForSmsMessageObject(l,strMessage,strToPhone,CCPM_staticConstants.strLeadOwnerChangeSMS,CCPM_StaticConstants.strTaskCommunicationOutbound,datTBusinessTime,CCPM_staticConstants.strLivetextPhoneNumber);
                    
                    objSmsMessage.CCPM_internalCommunication__c=True;
                    objSmsMessage.CCPM_sentTo__c=l.OwnerId;
                    lstSMSMessage.add(objSmsMessage);
                }
            }
            //Check for Customer Response
            else if(l.Status==CCPM_staticConstants.strLeadStatusResponded && l.CCPM_leadSubStatus__c==CCPM_staticConstants.strLeadSubStatusActionRequired && l.CCPM_lastInteraction__c!=mapOldLeads.get(l.id).CCPM_lastInteraction__c)
            {   //Check for a valid phone Number    
                if(l.OwnerId != null && mapLeadOwners.containsKey(l.OwnerId) && mapLeadOwners.get(l.OwnerId).mobilephone!=null)
                {  
                    if(l.Store__c != null && mapLeadAndBusinessHours != null && mapLeadAndBusinessHours.containsKey(l.store__c) && mapLeadAndBusinessHours.get(l.store__c)!=null)
                    {
                        //system.debug(' @@@@ '+mapLeadAndBusinessHours.get(l.store__c));
                        objBusinessHoursStore = mapLeadAndBusinessHours.get(l.store__c);
                    }
                    else if(mapLeadAndBusinessHours != null && l.CCPM_cartID__c !=null && mapLeadAndBusinessHours.containsKey(l.CCPM_cartID__c) && mapLeadAndBusinessHours.get(l.CCPM_cartID__c)!=null)
                    {
                        objBusinessHoursStore = mapLeadAndBusinessHours.get(l.CCPM_cartID__c);
                    }
                    else 
                    {
                        objBusinessHoursStore = objDefaultBusinessHour;
                    }
                    datTBusinessTime = calculateTimeToTriggerSMSWithInBusinessHours(objBusinessHoursStore, System.now());
                    //Populating fields for creating SMSMessage Record to send SMS to Lead owner for Customer Response
                    CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
                    
                    //US1770
                    String strMessage = '';
                    
                    if(l.CCPM_Type__c == CCPM_staticConstants.strLeadTypeCampaignLead) {
                        strMessage = 'Hi '+ mapLeadOwners.get(l.OwnerId).firstname + ', a lead contacted for a campaign, '+l.LastName+' has responded. Please view \'Leads Requiring Action\' in Salesforce to take action.';
                    } else {
                        strMessage = 'Hi '+ mapLeadOwners.get(l.OwnerId).firstname + ', '+l.LastName+' has responded. Please review \'Leads Requiring Action\' in Salesforce and take appropriate action.';
                    }
                    
                    String strToPhone = mapLeadOwners.get(l.OwnerId).mobilephone;                    
                    
                    objSmsMessage = createRecordsForSmsMessageObject(l,strMessage,strToPhone,CCPM_staticConstants.strLeadOwnerSMSOnCustomerResponse,CCPM_StaticConstants.strTaskCommunicationOutbound,datTBusinessTime,CCPM_staticConstants.strLivetextPhoneNumber);
                    objSmsMessage.CCPM_internalCommunication__c=True;
                    objSmsMessage.CCPM_sentTo__c=l.OwnerId;     
                    lstSMSMessage.add(objSmsMessage);
                }
            }
        }
        //System.debug('@@@setStoreID ' + setStoreID);
        /*
List<CCPM_SMSMessage__c> lstSMSMessageForManagers = new List<CCPM_SMSMessage__c>();
try{
lstStoreEmployees  = [Select id,CCPM_Store__c,CCPM_Store__r.id,CCPM_Store__r.CCPM_StoreID__c,CCPM_role__c,CCPM_IsActive__c, CCPM_employee__c,CCPM_employee__r.name,CCPM_employee__r.Id,CCPM_employee__r.CCPM_EmployeeId__c, CCPM_employee__r.IsActive,CCPM_employee__r.mobilephone ,CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where CCPM_Store__c IN :setStoreID AND CCPM_IsActive__c = true AND CCPM_employee__r.IsActive = true];
}
Catch(Exception e){
CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','UpdateLeadsWithNewOwners','Exception thrown while querying for leads',true); 
}

for(CCPM_storeEmployee__c objStoreEmp : lstStoreEmployees){
if(objStoreEmp.CCPM_role__c == CCPM_staticConstants.strStoreManager || objStoreEmp.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager){
lstmanagersAndAsstManagers.add(objStoreEmp);
}
}
system.debug('@@@@lstLeadsToBeUpdated ' + lstLeadsToBeUpdated);
if(lstLeadsToBeUpdated != null && lstLeadsToBeUpdated.size() >0 && lstmanagersAndAsstManagers != null && lstmanagersAndAsstManagers.size()>0){
lstSMSMessageForManagers = CCPM_storeEmployeeHandler.insertSMSRecordsToManagersAndAssistantManagers(lstLeadsToBeUpdated,lstmanagersAndAsstManagers,objBusinessHours,CCPM_staticConstants.strMessageForManualLeadOwnerChange);
//system.debug('@@@lstSMSMessageForManagers '+lstSMSMessageForManagers);
}

if(lstSMSMessageForManagers != null && lstSMSMessageForManagers.size() > 0){
lstSMSMessage.addAll(lstSMSMessageForManagers);
}
*/
        try{
            //Bulkified Insert of SMSMessage Records
            if(lstSMSMessage!=null && lstSMSMessage.size()>0)
            {
                insert lstSMSMessage;
            }
        }   
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','insertSMSMessageObjectForLeadOwner','Exception thrown while inserting SMSMessages for the Lead owner',true); 
        }
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method populates Status to Eligible and Previous Status on Before insert Trigger
@param         list of new leads
@return        Void(None)
*/ 
    public static list<Lead> updateLeadStatusToEligible(list<Lead> lstNewLeads)   
    { 
        set<String> setLstUniqueID = new set<String>();
        
        // looping through and insert the list of id in setLstID
        for(Lead l: lstnewLeads)
        {
            // if(l.CCPM_accountUniqueID__c!=null)
            
            if(l.CCPM_accountUniqueID__c != null){
                setLstUniqueID.add(l.CCPM_accountUniqueID__c);
            }
            
            
            //US516
            //system.debug('@@@US516 Trigger Insert');
            String strProfileId=UserInfo.getProfileId();
            if(strProfileId != CCPM_staticConstants.strIntegrationUserProfileId) {
                l.CCPM_dateAndTimeConsentAgreed__c = system.now();       
                l.CCPM_consentChannelSigned__c = CCPM_staticConstants.strLeadRetail;
            }
            
            // Formating the MTN by removing the non digits
            if(l.CCPM_mobileNumber__c!= NULL)
            {
                l.CCPM_mobileNumber__c = l.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits, CCPM_staticConstants.strEmpty );
                if( l.CCPM_confirmMTN__c != NULL)
                {
                    l.CCPM_confirmMTN__c = l.CCPM_confirmMTN__c.replaceAll(CCPM_staticConstants.strnondigits, CCPM_staticConstants.strEmpty);
                }  
            }   
            
        }
        //List of Account map with associated lead id
        map<String,Account> mapAccountAndLeadid = new map<String,Account>();
        if(setLstUniqueID!=null && setLstUniqueID.isEmpty()==false)
        {
            list<Account> lstAccountLeadId = new list<Account>([SELECT CCPM_accountUniqueID__c,CCPM_SMSOptOut__c FROM Account WHERE CCPM_accountUniqueID__c IN :setLstUniqueID]);
            if(lstAccountLeadId!=null && lstAccountLeadId.size()>0)
            {
                for(Account a : lstAccountLeadId )
                {
                    mapAccountAndLeadid.put(a.CCPM_accountUniqueID__c,a);
                }
            }
        }
        
        
        
        //System.debug('@@@Lstinitial->'+setLstUniqueID+'@@@Lst' + lstAccountLeadId + '@@@map' + mapAccountAndLeadid);
        //for every lead in lstNewLeads
        for(Lead l : lstNewLeads)
        {   //System.debug('@@@RecordTypeID->'+l.RecordTypeId);
            if((l.RecordTypeId==CCPM_staticConstants.strProspectRecordTypeID || l.RecordTypeId==CCPM_staticConstants.strProspectAbandonedCartRecordTypeID) && l.Status==CCPM_staticConstants.strLeadStatusNew && l.CCPM_mobileNumber__c!=null)
            {
                l.Status=CCPM_staticConstants.strLeadStatusEligible;
                l.CCPM_previousLeadStatus__c=CCPM_staticConstants.strLeadStatusNew;    
            }
            else if(l.RecordTypeId==CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && l.CCPM_accountUniqueID__c != null && !mapAccountAndLeadid.isEmpty() && mapAccountAndLeadid.containsKey(l.CCPM_accountUniqueID__c) && l.status != null && CCPM_staticConstants.setOpenLeadStatus.contains(l.status) && ( !mapAccountAndLeadid.get(l.CCPM_accountUniqueID__c).CCPM_SMSOptOut__c || (l.CCPM_isManualLead__c != NULL && l.CCPM_isManualLead__c == true)))
            {
                l.Status=CCPM_staticConstants.strLeadStatusEligible;
                l.CCPM_previousLeadStatus__c=CCPM_staticConstants.strLeadStatusNew;    
            }
            
        }
        return lstNewLeads;
    }
    
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method populates Trigger Prospect 1st SMS Date/Time field based on Update
@param         list of new leads, Map of Old Leads
@return        Void(None)
*/ 
    public static List<Lead> assignProspectSMSDateTimeBeforeUpdateForEventChange(list<Lead> lstNewLeads, Map<id,Lead> mapOldLeads,List<BusinessHours> oBusinessHours)   
    {  
        List<Lead> lstLeadUpdateTriggerEventDateTime = new List<Lead>();
        List<Lead> lstUpdatedEventDatetime = new List<Lead>();
        List<CCPM_SMSMessage__c> lstSMSMessages = new List<CCPM_SMSMessage__c>();
        map<id,Lead> mapLead = new map<id,Lead>();
        set<id> changeScheduleDateTimeSMSMessages = new set<id>();
        for(Lead l:lstNewLeads)
        {
            if(l.CCPM_SMSFollowUpDate__c!=mapOldLeads.get(l.Id).CCPM_SMSFollowUpDate__c)
            {
                lstLeadUpdateTriggerEventDateTime.add(l);
            }
            //system.debug('the method update is being called');
            //calling this method to update sms follow update for iphoneX method
            //iphoneXCalcSMSEventDate(l,mapOldLeads.get(l.id));
        }
        if( lstLeadUpdateTriggerEventDateTime!=null && lstLeadUpdateTriggerEventDateTime.size()>0)
        {
            lstUpdatedEventDatetime = assignProspectSMSDateTimeBeforeInsert(lstLeadUpdateTriggerEventDateTime, oBusinessHours); 
            
            //System.debug('#lstNewLeads Populated->'+lstUpdatedEventDatetime);
            if(lstUpdatedEventDatetime!=null && lstUpdatedEventDatetime.size()>0)
            {
                for(Lead l : lstUpdatedEventDatetime)
                {
                    changeScheduleDateTimeSMSMessages.add(l.Id);
                    mapLead.put(l.id,l);
                    for(Lead leads : lstNewLeads)
                    {
                        if(leads.id ==l.Id)
                        {
                            leads.CCPM_triggerProspectSMSPart1__c=l.CCPM_triggerProspectSMSPart1__c;
                        }
                    }
                }
            }
        }
        
        try{
            if( changeScheduleDateTimeSMSMessages!=NULL && changeScheduleDateTimeSMSMessages.size()>0 )
            {
                //Obtaining the SMS Messages for leads whose status is Expired/Completed/Rejected and status of Message is Queued.
                lstSMSMessages    = [Select   id, CCPM_leadRecord__c,CCPM_ScheduleDateTime__c from CCPM_SMSMessage__c 
                                     where    CCPM_leadRecord__c IN :changeScheduleDateTimeSMSMessages and CCPM_MessageStatus__c= :CCPM_staticConstants.strMessageStatusQueued];
                if( lstSMSMessages != null && lstSMSMessages.size()>0 )
                {
                    for(CCPM_SMSMessage__c SMS : lstSMSMessages)
                    {
                        SMS.CCPM_ScheduleDateTime__c= mapLead.get(SMS.CCPM_leadRecord__c).CCPM_triggerProspectSMSPart1__c;
                    }
                    //Bulk Update Scheduled Messages
                    update lstSMSMessages;
                }
            }
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','assignProspectSMSDateTimeBeforeUpdateForEventChange','Exception thrown while updating SMSMessages',true);
        } 
        return lstNewLeads;
    }
    
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method inserts records in the sms messages object when a lead/prospect record is created.
@param         list of new leads
@return        Void(None)
*/ 
    public static Map<String,BusinessHours> getCartIdORStoreIDAndBusinessHourMap(list<Lead> lstNewLeads,BusinessHours oDefaultBusinessHour,List<BusinessHours> oBusinessHours)   
    {
        //List<BusinessHours> oBusinessHours; //Object for Business hours
        map<String,String> mapStoreAndLeadid = new map<String,String>();
        map<String,BusinessHours> mapTimeZoneAndBusinessHours = new map<String,BusinessHours>();
        Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
        //Querying for active business hours from the org
        try{
            //Querying for active business hours from the org
            Set<ID> stStoreForBusinessHours = new Set<ID>();
            for(Lead l: lstNewLeads)
            {
                if(l.Store__c != null){
                    stStoreForBusinessHours.add(l.Store__c);
                }
            }
            Set<String> stTimeZones = new Set<String>();
            if(stStoreForBusinessHours != null && stStoreForBusinessHours.size()>0){
                system.debug('@@@stStoreForBusinessHours'+stStoreForBusinessHours);
                List<CCPM_Store__c> lstStoreRecords = [Select Id,name,CCPM_storeID__c,CCPM_TimeZone__c From CCPM_Store__c Where id IN :stStoreForBusinessHours];
                for(Integer i=0;i<lstNewLeads.size();i++){
                    for(Integer j=0;j<lstStoreRecords.size();j++){
                        if(lstNewLeads[i].Store__c == lstStoreRecords[j].id ){
                            system.debug('@@@lstNewLeads[i].Store__c'+lstNewLeads[i].Store__c + '@@@lstStoreRecords[j].id' +lstStoreRecords[j].id + '@@@lstNewLeads[i].CCPM_isManualLead__c : ' + lstNewLeads[i].CCPM_isManualLead__c );
                            system.debug('@@@lstNewLeads[i].recordTypeId : ' + lstNewLeads[i].recordTypeId + '@@@Label.CCPM_leadCustomerCartRT : ' + Label.CCPM_leadCustomerCartRT);
                            system.debug('@@@ManualLead 0');
                            if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectRecordTypeID ||(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_isManualLead__c))
                            {
                                system.debug('@@@ManualLead 1');
                                mapStoreAndLeadid.put(lstNewLeads[i].Store__c, lstStoreRecords[j].CCPM_TimeZone__c);
                            }
                            else{
                                mapStoreAndLeadid.put(lstNewLeads[i].CCPM_cartID__c, lstStoreRecords[j].CCPM_TimeZone__c);
                            }
                        }
                        else{
                            system.debug('@@@Negative');
                        }
                    }
                }
                System.debug('@@@mapStoreAndLeadid ' +mapStoreAndLeadid);
                //List of business hours objects
                //oBusinessHours  = [Select Id,name From BusinessHours Where IsActive = true];
                //Store Unique Time zones
                
                for(CCPM_Store__c l: lstStoreRecords){
                    stTimeZones.add(l.CCPM_TimeZone__c);
                }
            }
            else{
                //system.debug('@@@InsideElseOfgetCartIdORStoreIDAndBusinessHourMap');
                //oBusinessHours  = [Select Id,name From BusinessHours Where IsActive = true and IsDefault = true];
                //default TimeZone
                stTimeZones.add('EST');
            }
            //List of unique timezones
            List<String> lstTimeZones = new List<String>();
            lstTimeZones.addAll(stTimeZones);
            //system.debug('@@@lstTimeZones'+lstTimeZones);
            for(Integer i=0;i<lstTimeZones.size();i++){
                for(Integer j=0;j<oBusinessHours.size();j++){
                    //Check if the name of the Business hour consists of the name of time zone and add it to a map
                    //system.debug('@@@oBusinessHours[j].name'+oBusinessHours[j].name + '@@@lstTimeZones.get(i)' +lstTimeZones.get(i));
                    if(oBusinessHours[j].name.contains(lstTimeZones.get(i))){
                        mapTimeZoneAndBusinessHours.put(lstTimeZones.get(i), oBusinessHours[j]);
                    }
                }
            }
            System.debug('@@@mapTimeZoneAndBusinessHours' +mapTimeZoneAndBusinessHours);
            
            for(Integer i=0;i<lstNewLeads.size();i++){
                if(!mapStoreAndLeadid.isEmpty() || mapStoreAndLeadid.get(lstNewLeads[i].CCPM_cartID__c) != null){
                    system.debug('@@@ManualLead 2');
                    if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectRecordTypeID || (lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_isManualLead__c))
                    {
                        system.debug('@@@ManualLead 3');
                        mapLeadAndBusinessHours.put(lstNewLeads[i].Store__c, mapTimeZoneAndBusinessHours.get(mapStoreAndLeadid.get(lstNewLeads[i].Store__c)));
                    }
                    else{
                        mapLeadAndBusinessHours.put(lstNewLeads[i].CCPM_cartID__c, mapTimeZoneAndBusinessHours.get(mapStoreAndLeadid.get(lstNewLeads[i].CCPM_cartID__c)));
                    }
                }
                else{
                    if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectRecordTypeID ||(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_isManualLead__c))
                    {
                        mapLeadAndBusinessHours.put(lstNewLeads[i].Store__c,oDefaultBusinessHour);
                    }
                    else{
                        mapLeadAndBusinessHours.put(lstNewLeads[i].CCPM_cartID__c,oDefaultBusinessHour);
                    }
                }
            }
            system.debug('@@@mapLeadAndBusinessHours : ' + mapLeadAndBusinessHours);
            return mapLeadAndBusinessHours;
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','setTriggerFollowUpSMSDateTime','Exception thrown while querying business hours',true);
            return null;
        }
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method creates records for sms messages object when a lead/prospect record is created.
@param         list of new leads
@return        Void(None)
*/ 
    public static CCPM_SMSMessage__c createRecordsForSmsMessageObject(Lead objl, String strMessage, String strToPhone, String strMessageType, String strCommunicationDirection,datetime datTScheduleTime, String strLiveTextPhoneNumber)   
    {
        // System.debug('Inside createRecordsForSmsMessageObject');
        CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
        objSmsMessage.CCPM_leadRecord__c = objl.Id;
        objSmsMessage.CCPM_LiveTextNumber__c = strLivetextPhoneNumber;
        objSmsMessage.CCPM_message__c = strMessage;
        System.debug('@@objl.Store__r.CCPM_market__c->'+objl.Store__r.CCPM_market__c+' '+objl.Store__r.CCPM_territory__c+' '+objl.Store__r.CCPM_district__c);
        
        Map<String, CCPM_suppressOutboundSMS__c> mapSuppressOutboundMessage = CCPM_staticConstants.mapSuppressOutboundMessage;
        /*
set<string> setMarket; 
set<string> setDistrict;
set<string> setTerritory;
if(CCPM_staticConstants.setMarkets != null && !string.isBlank(CCPM_staticConstants.setMarkets)){
setMarket = new set<String>(CCPM_staticConstants.setMarkets.Split(CCPM_staticConstants.strColon));
}
if(CCPM_staticConstants.setDistricts != null && !string.isBlank(CCPM_staticConstants.setDistricts)){
setDistrict = new set<String>(CCPM_staticConstants.setDistricts.Split(CCPM_staticConstants.strColon));
}
if(CCPM_staticConstants.setTerritorys != null && !string.isBlank(CCPM_staticConstants.setTerritorys)){
setTerritory = new set<String>(CCPM_staticConstants.setTerritorys.Split(CCPM_staticConstants.strColon));
}

System.debug('@@@setMarket->'+setMarket);
System.debug('@@@setDistrict->'+setDistrict);
System.debug('@@@setTerritory->'+setTerritory); 

&& objl.CCPM_storeMarket__c != null && objl.CCPM_storeTerritory__c!= null && objl.CCPM_storeDistrict__c!= null 
&& setMarket.isempty() == false && setDistrict.isempty() == false && setTerritory.isempty() == false && setMarket.contains(objl.CCPM_storeMarket__c) 
&& setTerritory.contains(objl.CCPM_storeTerritory__c) && setDistrict.contains(objl.CCPM_storeDistrict__c)

*/
        if(mapSuppressOutboundMessage != null && !mapSuppressOutboundMessage.isEmpty()){
            For(string strkey : mapSuppressOutboundMessage.keySet()){
                CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = new CCPM_suppressOutboundSMS__c();
                objSuppressOutboundMessage = mapSuppressOutboundMessage.get(strkey);
                //Check for Market/Territory/District
                if(objSuppressOutboundMessage.IsActive__c && objl.CCPM_storeDistrict__c!= null && objSuppressOutboundMessage.District__c != null && objSuppressOutboundMessage.District__c == objl.CCPM_storeDistrict__c){
                    if(objl.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objl.CCPM_storeTerritory__c
                       && objl.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objl.CCPM_storeMarket__c){
                           objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                           objSmsMessage.CCPM_removedByLocationSetting__c = True;
                           // system.debug('@@@Inside District');
                       }
                }
                else if(objSuppressOutboundMessage.IsActive__c && objSuppressOutboundMessage.District__c == null){
                    if(objl.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objl.CCPM_storeTerritory__c){
                        if(objl.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objl.CCPM_storeMarket__c){
                            objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                            objSmsMessage.CCPM_removedByLocationSetting__c = True;
                            // system.debug('@@@Inside Territory');
                        }
                    }
                    else if(objSuppressOutboundMessage.Territory__c == null){
                        if(objl.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objl.CCPM_storeMarket__c){
                            objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                            objSmsMessage.CCPM_removedByLocationSetting__c = True;
                            //system.debug('@@@Inside Market');
                        }
                    }
                }
            }
        }
        if(objSmsMessage.CCPM_MessageStatus__c != CCPM_staticConstants.strMessageStatusRemoved){
            objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusQueued;
        }
        objSmsMessage.CCPM_messageType__c = strMessageType;
        objSmsMessage.CCPM_referenceId__c = strMessageType +objl.id;
        objSmsMessage.CCPM_ScheduleDateTime__c = datTScheduleTime;
        objSmsMessage.CCPM_toPhoneNumber__c = strToPhone;
        objSmsMessage.CCPM_SMSFailCounter__c = '0';
        objSmsMessage.CCPM_communicationDirection__c= strCommunicationDirection;
        return objSmsMessage;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method fetches the default business hours record.
@param         list of new leads
@return        List<BusinessHours>
*/ 
    public static List<BusinessHours> getBusinessHours(){
        /*BusinessHours oDefaultBusinessHour = [Select Id
From BusinessHours 
Where IsActive = true AND IsDefault = true Limit 1];*/
        List<BusinessHours> oBusinessHours = [Select Id,name,IsDefault From BusinessHours Where IsActive = true];
        return oBusinessHours;
    }
    
    
    /**
@author        Sudhakara Reddy Nallamilli (Deloitte)
@description   To Flag the Prospect Carts for the Merging Batch Job 
@param         list of new leads
@return        Void(None)    
*/
    
    
    public static list<lead> updateProspectCartMergeFlag (list<lead> lstLeadProsCartTriggerNew)
    {
        return CCPM_mergeProspectCartwithProspectUtil.flagMergeProspectCartwithProspect(lstLeadProsCartTriggerNew);
    } 
    
    
    
    /**
@author        Sudhakara Reddy Nallamilli (Deloitte)
@description   To Logg Error Messages for the Customer Carts with an Invalid Account Unique Ids
@param         list of new leads
@return        Void(None)    
*/  
    public static void logErrorMessagesforInvalidAccountUniqueIds (list<lead> lstLeadCustomerCartTriggerNew)
    {
        integer intFlag = 0;    
        string strErrorMessage;
        string strFirstLeadId;
        string strFirstAcountUniqueId;
        string strLogcode;
        for(lead objLead: lstLeadCustomerCartTriggerNew)
        {
            if( objLead.RecordTypeId==CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && objLead.id != null && objLead.CCPM_Account__c == null) 
            {
                intFlag = intFlag + 1;         
                if(intFlag == 1) 
                {
                    strFirstLeadId = objLead.id;
                    if(objLead.CCPM_accountUniqueID__c!= null)
                        strFirstAcountUniqueId = objLead.CCPM_accountUniqueID__c;
                    else strFirstAcountUniqueId = 'Null';
                }
            }
        }
        if(intFlag > 0)
        {
            strErrorMessage = 'First Lead Id: '+ strFirstLeadId + ' Total Leads Count: ' + intFlag;
            strLogcode = 'First Account Unique ID: '+ strFirstAcountUniqueId;
            try
            {
                CCPM_LogMessageUtility.logMessage(CCPM_logMessageUtility.LOG_LogLevel.Error,'CCPM_leadHandler.logErrorMessagesforInvalidAccountUniqueIds','Invalid Account Unique ID',strErrorMessage,strLogcode,true);
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler.logErrorMessagesforInvalidAccountUniqueIds',
                                                  'Too Many Invalid Account Unique Ids',
                                                  'Exception thrown while Capturing the Invalid Account Unique Ids',true);
                
            }
            
            
        } 
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   To obtain the set of Queue ID's
@param         Map of Distric and group
@return        set<ids>    
*/  
    
    public static set<id> getSetOfQueueID(Map<String,Group> mapDistrictAndGroup)
    {   
        //Instantiate the set for set Queue Id's
        set<id> setQueueID = new set<id>();
        //Check if the parameter map value is not empty/null
        if(mapDistrictAndGroup!=null && mapDistrictAndGroup.isEmpty()==false)
        {   //Create a list of group to store the map values
            list<Group> lstGroup =  mapDistrictAndGroup.values();
            //Check if the list returned is not null/empty
            if(lstGroup!=null && lstGroup.size()>0)
            {   //For every group returned
                for(Group objGroup : lstGroup )
                {
                    setqueueID.add(objGroup.Id);
                }
            }
        }
        //Check if the set of Id's obtained is not empty
        if(setQueueID!=null && setQueueID.size()>0)
        {   //Return the set back to the calling method
            return setQueueID;
        }
        else
        {   
            return null;
        }
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   To set the timestamp for converted Leads
@param         List of New Leads, Map of Old Leads
@return        set<ids>    
*/ 
    public static list<Lead> setTimeSTampForConvertedQualifiedLeads(List<Lead> lstNewLeads, map<id,Lead> mapOldLeads)
    {   //For every Lead in list of new Leads
        for(Lead objLead : lstNewLeads)
        {   //Check for Status to be converted and validate if the status has changed on update
            if(objLead.Status!=NULL && objLead.Status != mapOldLeads.get(objLead.id).status && objLead.Status == ccpm_staticConstants.strLeadStatusConverted)
            {   //Assign current date/time to the date/time field
                objLead.CCPM_convertedDateTime__c = System.now();
            }
            else if(objLead.Status!=NULL && objLead.Status != mapOldLeads.get(objLead.id).status && objLead.Status == ccpm_staticConstants.strLeadStatusQualified)
            {
                objLead.CCPM_qualifiedDateTime__c = System.now();
            }
        }
        return lstNewLeads;
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   To update the latest Lead Owner on SMS Messages
@param         List of New Leads, Map of Old Leads
@return        list<Lead>    
*/ 
    public static list<Lead> updateLeadOwneronSMSMessage(List<Lead> lstNewLeads, map<id,Lead> mapOldLeads,Map<String,Group> mapDistrictAndGroup)
    {   
        set<id> setLeadIds = new set<id>();
        set<id> setQueueID = new set<id>();
        list<CCPM_smsMessage__c> lstSMSMessage = new list<CCPM_smsmessage__c>();
        list<Lead> lstLeadRequiringUpdateOnSMS = new list<Lead>();
        map<id,User> mapOwnerFirstname =new map<id,User>();
        map<id,list<ccpm_smsmessage__c>> mapLeadAssociatedSMS = new map<id,list<ccpm_smsmessage__c>>();
        
        //Get the list of Queue Id's
        if(mapDistrictAndGroup!=null && mapDistrictAndGroup.isEmpty()==false)
        {
            setQueueID.addAll(getSetOfQueueID(mapDistrictAndGroup));            
        }
        
        //For every Lead in list of new Leads
        for(Lead objLead : lstNewLeads)
        {   //Checking if Owner has changes to a valid Lead owner
            system.debug('objLead.OwnerId != mapOldLeads.get(objLead.id).OwnerId------>'+(objLead.OwnerId != mapOldLeads.get(objLead.id).OwnerId));
            system.debug('setQueueID.contains(objLead.OwnerId)------->'+setQueueID.contains(objLead.OwnerId));
            if(objLead.OwnerId != mapOldLeads.get(objLead.id).OwnerId && setQueueID!=null && setQueueID.isEmpty()==false && setQueueID.contains(objLead.OwnerId)== false)
            {
                setLeadIds.add(objLead.id);
                lstLeadRequiringUpdateOnSMS.add(objLead);
            }
        }
        //Checking if the set has any values
        if(setLeadIds!=null && setLeadIds.isEmpty()==false)
        {
            try{
                //Querying for all SMS Records associated with modified Lead owners
                lstSMSMessage = [select id,CCPM_leadRecord__c,CCPM_message__c,CCPM_messageType__c,CCPM_MessageStatus__c from ccpm_smsmessage__c 
                                 where CCPM_MessageStatus__c=:CCPM_staticConstants.strMessageStatusQueued and CCPM_leadRecord__c in :setLeadIds 
                                 and (CCPM_messageType__c=:CCPM_staticConstants.strMessageTypeManagersActionRequired or CCPM_messageType__c=:CCPM_staticConstants.strMessageTypeAssistantManagersActionRequired or CCPM_messageType__c=:CCPM_staticConstants.strMessageTypeInitialSMSPart1 
                                      or CCPM_messageType__c=:CCPM_staticConstants.strMessageTypeFollowUpSMS or CCPM_messageType__c=:CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1)];
            }
            catch(Exception e)
            {
                //Catch statement in case the query throws an error
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','Querting for associated SMS Messages with Lead for updating Body with Owner change','Exception thrown while querying related SMS records with a Lead id',true);
                
            }
            
        }
        //Checking on the no of Lead records that requires change in SMS Message body
        if(lstLeadRequiringUpdateOnSMS!=null && lstLeadRequiringUpdateOnSMS.isEmpty()==false)
        {
            mapOwnerFirstname = CCPM_SmsMessageHandler.CCPM_createMapofLeadsandOwners(lstLeadRequiringUpdateOnSMS);
        }
        system.debug('lstSMSMessage--------->'+lstSMSMessage);
        system.debug('mapOwnerFirstname--------->'+mapOwnerFirstname);
        //Checking for if there are any SMS messages accumulated in the list for a change in body
        if(lstSMSMessage!=null && lstSMSMessage.size()>0 && mapOwnerFirstname!=null && mapOwnerFirstname.isEmpty()==false )
        {
            List<ccpm_smsmessage__c> lstSMSMessageTemp = new list<ccpm_smsmessage__c>();
            For(ccpm_smsmessage__c objSMS : lstSMSMessage)
            {   
                lstSMSMessageTemp.clear();
                if(mapLeadAssociatedSMS!=null)
                {
                    if(mapLeadAssociatedSMS.containsKey(objSMS.CCPM_leadRecord__c))
                    {
                        lstSMSMessageTemp = mapLeadAssociatedSMS.get(objSMS.CCPM_leadRecord__c);
                        lstSMSMessageTemp.add(objSMS);
                        mapLeadAssociatedSMS.put(objSMS.CCPM_leadRecord__c,lstSMSMessageTemp);
                    }
                    else
                    {   
                        lstSMSMessageTemp.add(objSMS);
                        mapLeadAssociatedSMS.put(objSMS.CCPM_leadRecord__c,lstSMSMessageTemp);
                    }
                }
                
            }
            system.debug('lstLeadRequiringUpdateOnSMS--------->'+lstLeadRequiringUpdateOnSMS);
            //For every Lead in the new list that requires a change
            for(Lead objLead : lstLeadRequiringUpdateOnSMS)
            {
                List<ccpm_smsmessage__c> lstTempSMSMessage = new List<ccpm_smsmessage__c>();
                //For every SMS associated with a specific lead
                if(mapLeadAssociatedSMS.containsKey(objLead.id) && mapLeadAssociatedSMS.get(objLead.id).isEmpty()==false)
                {
                    for(ccpm_smsmessage__c objSMS : mapLeadAssociatedSMS.get(objLead.id))
                    {
                        
                        //Checking if the SMS message typ is Managers action required SMS or AM action required SMS for inactivity 3 hours
                        if(objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeManagersActionRequired || objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeAssistantManagersActionRequired)
                        {   //Temp Variables
                            string strLeadType;
                            string strOwnerName;
                            
                            if( objLead.RecordTypeId == CCPM_staticConstants.strProspectRecordTypeID || objLead.RecordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID )
                            {
                                strLeadType = CCPM_staticConstants.strLeadRecordTypeProspect;
                            }
                            else strLeadType = CCPM_staticConstants.strLeadRecordTypeLead;
                            //Changing the SMS records with the new SMS
                            if(mapOwnerFirstname.containsKey(objLead.ownerid))
                            {
                                if(mapOwnerFirstname.get(objLead.ownerid).firstname!= null)
                                    strOwnerName = mapOwnerFirstname.get(objLead.ownerid).firstname;
                                else
                                    strOwnerName = mapOwnerFirstname.get(objLead.ownerid).lastname;
                                
                                objSMS.CCPM_message__c = 'Action Required: A '+strLeadType+' has responded to your store and '+ strOwnerName +
                                    ' has not followed up in 3 hours. Please login to Salesforce and view \'Leads Requiring Action\'.';
                            }
                            
                        }
                        //Checking if the type of SMS is Initial SMS
                        else if(objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeInitialSMSPart1)
                        {   
                            //Looking for recordtype to set appropriate SMS
                            if(objLead.RecordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID)
                            {
                                objSMS.CCPM_message__c= objLead.CCPM_initialSMSBody__c;
                            }
                            else
                            {
                                objSMS.CCPM_message__c= objLead.CCPM_prospectInitialSMSBody__c;
                            }
                            
                        }
                        //Checking if the SMS is Follow Up
                        else if(objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeFollowUpSMS)
                        {   
                            //Looking for recordtype to set appropriate SMS
                            if(objLead.RecordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID)
                            {
                                objSMS.CCPM_message__c= objLead.CCPM_followupMessageBody__c;
                            }
                            else
                            {
                                objSMS.CCPM_message__c= objLead.CCPM_ProspectFollowUpSMSBody__c;
                            }
                            
                        }
                        //Checking if the SMS is Prospect 1st SMS
                        else if(objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1)
                        { 
                            Set<String> setleadEventToExclude = new Set<String>();
                            for(String strEventType : Label.CCPM_LeadEventToExclude.split(',')){
                                setleadEventToExclude.add(strEventType.trim());
                            }
                            //Looking for recordtype to set appropriate SMS
                            if(objLead.RecordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID)
                            {
                                objSMS.CCPM_message__c= objLead.CCPM_manualLeadSMSBody__c;
                            }
                            else if(!setleadEventToExclude.contains(objLead.CCPM_eventType__c))
                            {
                                objSMS.CCPM_message__c= objLead.CCPM_prospectSMSBody__c;
                            }
                            else if(setleadEventToExclude.contains(objLead.CCPM_eventType__c) && objLead.Status==CCPM_staticConstants.strLeadStatusEligible)
                            {
                                objSMS.CCPM_MessageStatus__c=CCPM_staticConstants.strMessageStatusRemoved;
                                
                            }
                        }
                    }
                }
            }
            
            try{
                //Updating the SMS message records
                update lstSMSMessage;
            }
            catch(Exception e)
            {
                //Catch statement in case of failure in DML Statements
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','updateLeadOwneronSMSMessage','Exception thrown while Updating SMS Message Records',true);
            }
        }
        
        //Returning the set of Leads that got into the current context
        return lstNewLeads;
    }   
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   To update the latest Lead Owner on SMS Messages
@param         List of New Leads, Map of Old Leads
@return        list<Lead>    
*/
    
    public static void cancelScheduledSMSWhenQueued(list<Lead> lstNewLeads, map<id,Lead> mapOldLeads,Map<String,Group> mapDistrictAndGroup)
    {
        set<id> setQueueID = new set<id>();
        set<id> setLeadID = new set<id>();
        list<CCPM_smsMessage__c> lstSMSMessagesToBeRemoved = new list<ccpm_smsmessage__c>();
        //Get the list of Queue Id's
        if(mapDistrictAndGroup!=null && mapDistrictAndGroup.isEmpty()==false)
        {
            setQueueID.addAll(getSetOfQueueID(mapDistrictAndGroup));            
        }
        //For every Lead in the trigger context
        for(lead objLead : lstNewLeads)
        {   
            //Check if the Lead owner has changed and the current owner is queued
            if(objlead.OwnerId!=mapOldLeads.get(objlead.id).OwnerId && setQueueID!=null && setQueueID.isEmpty()==false && setQueueID.contains(objlead.OwnerId)==true)
            {
                setLeadID.add(objLead.id); 
            }
        }
        //Validate if there are any such leads
        if(setLeadID!=null && setLeadID.isEmpty()==false)
        {
            try{
                //Query for all SMS records related to the Lead that has owner queued
                lstSMSMessagesToBeRemoved = [Select id,ccpm_messagestatus__c from ccpm_smsmessage__c where ccpm_leadrecord__c in :setLeadID and ccpm_messagestatus__c=:CCPM_staticconstants.strMessageStatusQueued];
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','cancelScheduledSMSWhenQueued','Exception thrown while Querying SMS Message Records',true);
            }
        }
        //Check if there are any such messages queued to be removed
        if(lstSMSMessagesToBeRemoved!=null && lstSMSMessagesToBeRemoved.isEmpty()==false)
        {
            for(ccpm_smsmessage__c objSMS : lstSMSMessagesToBeRemoved)
            {
                objSMS.CCPM_MessageStatus__c = CCPM_staticconstants.strMessageStatusRemoved;
            }
            
            try{
                Update lstSMSMessagesToBeRemoved;
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','cancelScheduledSMSWhenQueued','Exception thrown while Updating SMS Message Records',true);
            }
        }
        
        
    }
    
    /**
@author        Manjunath Keshava (Deloitte)
@description   Updating the Responded field on Campaign member object after receiving Sms Response 
@param         None
@return          
*/ 
    public static void updateCampaignFieldResponded(list<Lead> lstNewLeads,Map<id,Lead> mapOldLeads)  
    {
        set<id> setid= new set<id>();
        for(lead objlead:lstNewLeads)  
        {    
            
            system.debug('objlead------->'+objlead);
            system.debug('mapOldLeads.containsKey(objlead.id) ------->'+mapOldLeads.containsKey(objlead.id) );
            system.debug('objlead.CCPM_isSMSResponseReceived__c!=mapOldLeads.get(objlead.id).CCPM_isSMSResponseReceived__c------->'+(objlead.CCPM_isSMSResponseReceived__c!=mapOldLeads.get(objlead.id).CCPM_isSMSResponseReceived__c));
            if( objlead.RecordTypeId==CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && objlead.CCPM_Type__c == ccpm_staticConstants.strLeadTypeCampaignLead &&  objlead.CCPM_isSMSResponseReceived__c!=null &&  objlead.CCPM_isSMSResponseReceived__c==true && mapOldLeads!=null && !mapOldLeads.isEmpty() && mapOldLeads.containsKey(objlead.id) && objlead.CCPM_isSMSResponseReceived__c!=mapOldLeads.get(objlead.id).CCPM_isSMSResponseReceived__c )
            {
                setid.add(objlead.id);
            }
            
        }
        
        if(setid!=null && !setid.isempty())
        {
            
            list<CampaignMember> lstCampaignMember=[select leadId,HasResponded,status from CampaignMember where leadId IN: setid];
            for(CampaignMember objCampaignMember: lstCampaignMember)
            {
                objCampaignMember.status=CCPM_staticConstants.strLeadStatusResponded;
            }
            try
            {
                if( lstCampaignMember!=null &&  !lstCampaignMember.isempty())
                {
                    update  lstCampaignMember;
                }
            }
            catch(Exception e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','cancelScheduledSMSWhenQueued','Exception thrown while Querying SMS Message Records',true);
            }
        } 
        
    }
    /**
@author        Manjunath Keshava (Deloitte)
Sriraman Sridharan(Merge Messages)
@description    populating the Originating Lead Owner and the Originating Store on the Lead Record, when the Lead Owner and store are Updated 
@param         None
@return          
*/ 
    public static void updateNewLeadFieldsOnLeadUpdate(list<Lead> lstNewLeads,Map<id,Lead> mapOldLeads,List<BusinessHours> lstBusinessHours)  
    {
        set<String> setQueueID = CCPM_utility.populateQueueIds();
        list<lead> lstRequiredLeads = new List<lead>();
        for(lead objlead:lstNewLeads)  
        {
            if(objlead.Ownerid!=null && mapOldLeads!=null && !mapOldLeads.isEmpty() && setQueueID!=null && setQueueID.isEmpty()==false && setQueueID.contains(mapOldLeads.get(objlead.id).ownerid)==false && mapOldLeads.containsKey(objlead.id) && mapOldLeads.get(objlead.id).ownerid!=null &&  objlead.Status==CCPM_staticConstants.strLeadStatusConverted && objlead.Status!=mapOldLeads.get(objlead.id).Status)
            {
                objlead.CCPM_originatingRep__c = mapOldLeads.get(objlead.id).ownerid; 
            }
            if(objlead.Store__c!=null && mapOldLeads!=null && !mapOldLeads.isEmpty() && mapOldLeads.containsKey(objlead.id) && mapOldLeads.get(objlead.id).Store__c!=null && objlead.Status==CCPM_staticConstants.strLeadStatusConverted && objlead.Status!=mapOldLeads.get(objlead.id).Status )
            {
                objlead.CCPM_originatingStore__c = mapOldLeads.get(objlead.id).Store__c; 
            }
            
            //Update merge related fields onleads with open status
            if(objlead.Status != null && (objlead.Status == CCPM_staticConstants.strLeadStatusEligible ||
                                          objlead.Status == CCPM_staticConstants.strLeadStatusContacted || 
                                          objlead.Status == CCPM_staticConstants.strLeadStatusResponded ||
                                          objlead.Status == CCPM_staticConstants.strLeadStatusQualified) && objlead.CCPM_isInformaticaMerge__c == true && objlead.CCPM_mobileNumber__c != null &&
               objlead.Ownerid!=null && mapOldLeads!=null && !mapOldLeads.isEmpty() && setQueueID!=null && !setQueueID.isEmpty() && 
               !setQueueID.contains(objlead.ownerid) && mapOldLeads.containsKey(objlead.id) && mapOldLeads.get(objlead.id).CCPM_isInformaticaMerge__c == false &&
               objLead.CCPM_Type__c != null && objLead.CCPM_Type__c != ccpm_staticConstants.strLeadTypeCampaignLead)
            {
                if((objlead.LeadSource != null && objlead.LeadSource == ccpm_staticConstants.strLeadNetace)|| (objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || objlead.CCPM_isManualLead__c))
                {
                    //Customer carts
                    if((objlead.RecordTypeId == ccpm_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && !objlead.CCPM_smsOptOutAccount__c) || 
                       (objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || objlead.RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID)){
                           if(objlead.CCPM_SMSOptOut__c){
                               objlead.CCPM_SMSOptOut__c = false;
                           }
                           objlead.CCPM_leadSubStatus__c = null;
                           objlead.CCPM_isInitialSMSSent__c = false;
                           objlead.CCPM_isFollowUpSMSSent__c = false;
                           objlead.CCPM_isSMSResponseReceived__c = false;
                           objlead.CCPM_DoubleOptOutSent__c = false;
                           objlead.CCPM_AutoResponseForDoubleOptOutSmsSent__c = false;
                           objlead.CCPM_initialSMSSentDateTime__c = null;
                           objlead.CCPM_followUpSMSDate__c = null;
                           objlead.CCPM_SMSResponseReceivedDateTime__c = null;
                           objLead.CCPM_isProspectSMSsent__c = false;
                           objLead.CCPM_prospectSMSSentDate__c = null;
                           objLead.CCPM_triggerProspectSMSPart1__c = null;
                           objlead.Status = CCPM_staticConstants.strLeadStatusEligible; //Set lead status to eligible
                           
                           lstRequiredLeads.add(objlead);
                       }
                }
                else if (objLead.CCPM_createdChannel__c != null && objLead.CCPM_createdChannel__c != Label.CCPM_telesalesChannelName && objlead.LeadSource != null && objlead.LeadSource != ccpm_staticConstants.strLeadNetace && 
                         (objlead.RecordTypeId == ccpm_staticConstants.strLeadCustomerAbandonedCartRecordTypeID || objlead.RecordTypeId == ccpm_staticConstants.strProspectAbandonedCartRecordTypeID))
                {
                    if(objlead.Status == CCPM_staticConstants.strLeadStatusResponded && objlead.CCPM_leadSubStatus__c!= null && objlead.CCPM_leadSubStatus__c == Label.CCPM_LeadCartDisinterested)
                    {
                        objlead.CCPM_SMSOptOut__c = false;
                        objlead.CCPM_leadSubStatus__c = null;
                        objlead.CCPM_isInitialSMSSent__c = false;
                        objlead.CCPM_isFollowUpSMSSent__c = false;
                        objlead.CCPM_isSMSResponseReceived__c = false;
                        objlead.CCPM_DoubleOptOutSent__c = false;
                        objlead.CCPM_AutoResponseForDoubleOptOutSmsSent__c = false;
                        objlead.CCPM_initialSMSSentDateTime__c = null;
                        objlead.CCPM_followUpSMSDate__c = null;
                        objlead.CCPM_SMSResponseReceivedDateTime__c = null;
                        objlead.Status = CCPM_staticConstants.strLeadStatusEligible;
                        objLead.CCPM_isProspectSMSsent__c = false;
                        objLead.CCPM_prospectSMSSentDate__c = null;
                        objLead.CCPM_triggerProspectSMSPart1__c = null;
                    }
                }
            }
        }  
        system.debug('@@@lstRequiredLeads : ' + lstRequiredLeads);
        if(lstRequiredLeads != null && !lstRequiredLeads.isEmpty()){
            CCPM_leadHandlerAssignOwnership.populateTriggerSmsValues(lstRequiredLeads,lstBusinessHours);
        }
    }
    /**
@author        Sriraman Sridharan/ Sudhakara (Deloitte)
@description    Cancel And Create New SmsSchedules for Merge scenarios 
@param         None
@return          
*/ 
    public static void CancelAndCreateNewSmsSchedulesWhileMerge(list<Lead> lstNewLeads,list<Lead> lstOldLeads,Map<String,Group> mapDistrictAndGroup)  
    {
        set<String> setQueueID = CCPM_utility.populateQueueIds();
        Set<ID> setLeadIDsToFetchSmsMap = new Set<ID>();
        map<String,Boolean> mapLead = new map<String,Boolean>();
        map<id,list<CCPM_SMSMessage__c>> mapLeadSMS = new map<id,list<CCPM_SMSMessage__c>>();
        list<CCPM_SMSMessage__c> lstSMSToUpdate = new list<CCPM_SMSMessage__c>();
        for(Integer i =0; i< lstNewLeads.size(); i++){
            if(lstNewLeads[i].Status != null && (lstNewLeads[i].Status == CCPM_staticConstants.strLeadStatusEligible ||
                                                 lstNewLeads[i].Status == CCPM_staticConstants.strLeadStatusContacted || 
                                                 lstNewLeads[i].Status == CCPM_staticConstants.strLeadStatusResponded ||
                                                 lstNewLeads[i].Status == CCPM_staticConstants.strLeadStatusQualified) && 
               lstNewLeads[i].CCPM_Type__c != null && lstNewLeads[i].CCPM_Type__c != ccpm_staticConstants.strLeadTypeCampaignLead && lstNewLeads[i].CCPM_mobileNumber__c != null 
               && ((lstNewLeads[i].RecordTypeId == ccpm_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && !lstNewLeads[i].CCPM_smsOptOutAccount__c) || 
                   (lstOldLeads[i].RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || lstOldLeads[i].RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID))){
                       if(lstOldLeads[i].CCPM_isInformaticaMerge__c == false && lstNewLeads[i].CCPM_isInformaticaMerge__c == true &&
                          lstNewLeads[i].Ownerid!=null && lstOldLeads!=null && !lstOldLeads.isEmpty() && setQueueID!=null && !setQueueID.isEmpty() && 
                          !setQueueID.contains(lstNewLeads[i].ownerid)){
                              //Insert selectively 
                              //All Scenarios : DISRSCE-1746, DISRSCE-1745,DISRSCE-1744
                              if(lstNewLeads[i].CCPM_createdChannel__c != null && lstNewLeads[i].CCPM_createdChannel__c != Label.CCPM_telesalesChannelName)
                              {
                                  if((lstNewLeads[i].LeadSource != null && (lstNewLeads[i].LeadSource == ccpm_staticConstants.strLeadNetace || (lstNewLeads[i].status!=null && lstNewLeads[i].status == CCPM_staticConstants.strLeadStatusEligible) ))|| (lstNewLeads[i].RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || lstNewLeads[i].CCPM_isManualLead__c))
                                  {
                                      system.debug('@@@CCPM_createdChannel__c' + lstNewLeads[i].CCPM_createdChannel__c + '@@@Label.CCPM_telesalesChannelName ' + Label.CCPM_telesalesChannelName);
                                      
                                      setLeadIDsToFetchSmsMap.add(lstNewLeads[i].id);
                                      CCPM_SMSMessage__c objSmsMessage = CCPM_leadHandlerAssignOwnership.populateInitialMessageForMergeCarts(lstNewLeads[i],setQueueID);
                                      lstSMSToUpdate.add(objSmsMessage);
                                      system.debug('@@@mapLead IF 2980: ' + mapLead); 
                                  }
                              }
                              //Messages for Telesales Merge
                              else if(lstNewLeads[i].CCPM_createdChannel__c != null && lstNewLeads[i].CCPM_createdChannel__c == Label.CCPM_telesalesChannelName &&
                                      (lstNewLeads[i].LeadSource != null && lstNewLeads[i].LeadSource == ccpm_staticConstants.strLeadNetace) ){
                                          setLeadIDsToFetchSmsMap.add(lstNewLeads[i].id);
                                          CCPM_SMSMessage__c objSmsMessage = CCPM_leadHandlerAssignOwnership.populateInitialMessageForMergeCarts(lstNewLeads[i],setQueueID);
                                          lstSMSToUpdate.add(objSmsMessage);
                                          mapLead.put(lstNewLeads[i].id, ccpm_staticConstants.boolSMSUnSuccessful);
                                          system.debug('@@@mapLead : ' + mapLead);
                                      }
                          } 
                   }
        }
        system.debug('@@@setLeadIDsToFetchSmsMap : ' + setLeadIDsToFetchSmsMap);
        //Removing Existing Schedules
        //get the map of lead and the list of scheduled sms messages
        if(setLeadIDsToFetchSmsMap != null && setLeadIDsToFetchSmsMap.size()>0){
            mapLeadSMS = CCPM_sendSMSMergeManual.createMapLeadSMSRelation(setLeadIDsToFetchSmsMap);
        }
        if(mapLead!= null && !mapLead.isEmpty()){
            system.debug('@@@mapLead2 : ' + mapLead);
            CCPM_sendSMSMergeManual.updateTaskRecords(mapLead);
        }
        
        for(ID objId : mapLeadSMS.keySet() ){
            list<CCPM_SMSMessage__c> lstSmsMessages = mapLeadSMS.get(objId);
            if(lstSmsMessages != null && !lstSmsMessages.isEmpty()){//If there are existing schedules
                for(CCPM_SMSMessage__c objSmsMsg : lstSmsMessages){
                    objSmsMsg.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                    lstSMSToUpdate.add(objSmsMsg);
                    // system.debug('@@@objSmsMsg :' + objSmsMsg);
                }
            }
        }
        //Check if the SMS to Update map is not empty
        try{
            if(lstSMSToUpdate!=null && lstSMSToUpdate.isEmpty() == false)
            {   //Make a callout to the method to Update the SMS records
                system.debug('@@@lstSMSToUpdate :' + lstSMSToUpdate);
                upsert lstSMSToUpdate;
            }
        }
        catch(Exception e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','CancelAndCreateNewSmsSchedulesWhileMerge','Exception thrown while updating SMS Message Records',true);            
        }
    }
    
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   To cancel SMS scheduled for event SMS
@param         list<Lead> lstNewLeads,map<id,Lead> mapOldLeads
@return        None    
*/ 
    public static void cancelSMSEventTypeIphoneX(list<Lead> lstNewLeads, map<id,Lead> mapOldLeads)
    { 
        list<CCPM_smsmessage__c> lstSMSMessage = new list<CCPM_smsmessage__c>();
        set<id> setLeadId = new set<id>();
        Set<String> setleadEventToExclude = new Set<String>();
        for(String strEventType : Label.CCPM_LeadEventToExclude.split(',')){
            setleadEventToExclude.add(strEventType.trim());
        }
        for(lead objLead : lstNewLeads)
        {
            if((objLead.RecordTypeId==CCPM_staticConstants.strProspectRecordTypeID || objlead.CCPM_isManualLead__c==true) && objLead.CCPM_eventType__c!=mapOldLeads.get(objLead.id).CCPM_eventType__c && setleadEventToExclude.contains(objLead.CCPM_eventType__c))
            {
                setLeadID.add(objLead.id);
            }   
        }
        try{
            if(setLeadID!=null && setLeadID.isEmpty()==false)
            {
                lstSMSMessage = [select id,CCPM_MessageStatus__c from CCPM_SMSMessage__c where CCPM_leadRecord__c in :setLeadID 
                                 and CCPM_messageType__c= :CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1 and (CCPM_MessageStatus__c = :CCPM_staticConstants.strMessageStatusQueued or CCPM_MessageStatus__c = :CCPM_staticConstants.strMessageStatusError)];
                
                if(lstSMSMessage!=null && lstSMSMessage.isEmpty()==false)
                {
                    for(CCPM_smsmessage__c objSMS : lstSMSMessage)
                    {
                        system.debug('this could be');
                        objSMS.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                    }
                    
                    update lstSMSMessage;
                }
                
            }
            
        }
        catch(Exception e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandler','cancelSMSEventTypeIphoneX','Exception thrown while querying/updating SMS message records',true); 
        }
        
    }
    
    
    /**
@author        Manjunath Keshava (Deloitte)
@description    insert the SMS follow up date  When lead is created with event type  IPhone X
@param         None
@return          
*/ 
    //ESMSFWK : Event SMS Framework
    public static Datetime dateESMSFWKSystemNow; 
    public static CCPM_testSettings__c ts    = CCPM_testSettings__c.getInstance();
    public static void ESMSFWKCalculateSMSFOllowupDate(list<Lead> lstNewLeads, map<id,Lead> mapOld,Map<String, BusinessHours> mapTZNameBusinessHours)
    { 
        dateESMSFWKSystemNow=ts.CCPM_sytemNow__c;
        system.debug('the start');
        if(dateESMSFWKSystemNow == null)
        {
            dateESMSFWKSystemNow = Datetime.now();  
        }
        
        //Map<String, BusinessHours> mapTZNameBusinessHours = CCPM_utility.mapGetBusinessHours();
        List<CCPM_EventSMSSetting__mdt> listEventSMSSetting = [Select CCPM_JourneyMessageName__c,CCPM_Type__c,CCPM_LeadEventType__c, CCPM_LeadRecordType__c, 
                                                               CCPM_SmsFollowUpEndDate__c,CCPM_SmsFollowUpStartDate__c, CCPM_StartDate__c,
                                                               CCPM_EndDate__c, CCPM_overrideEcode__c, CCPM_CalculateSMSFollowup__c
                                                               From CCPM_EventSMSSetting__mdt Where CCPM_Active__c =: true AND CCPM_CalculateSMSFollowup__c =: true];
        
        if(listEventSMSSetting != null && listEventSMSSetting.size() >0){
            system.debug('I came into listEventSMSSetting'+listEventSMSSetting);
            for(CCPM_EventSMSSetting__mdt eSMSSet : listEventSMSSetting){
                for(lead objlead:lstNewLeads){
                    system.debug('*********'+objlead.RecordTypeId+eSMSSet.CCPM_LeadRecordType__c);
                    system.debug(+objlead.CCPM_eventType__c+eSMSSet.CCPM_LeadEventType__c);
                    system.debug('******'+objlead.CCPM_Type__c+eSMSSet.CCPM_type__c);
                    system.debug('*****objlead.Status*********'+objlead.Status);
                    if(objlead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(eSMSSet.CCPM_LeadRecordType__c).getRecordTypeId() &&  objlead.CCPM_Type__c==eSMSSet.CCPM_type__c
                       && !(CCPM_utility.setleadStatusTOExclude.contains(objlead.Status)) && string.isNotBlank(objlead.CCPM_eventType__c) && 
                       objlead.CCPM_eventType__c== eSMSSet.CCPM_LeadEventType__c &&(mapOld == null || (mapOld != null && objLead.CCPM_eventType__c != mapOld.get(objlead.Id).CCPM_eventType__c))){
                           system.debug('the conditons are met');
                           Datetime dateStartDate;
                           Datetime dateEndDate;   
                           Datetime dateSMSFollowupStartDate;  
                           Datetime dateSMSFollowupEndDate; 
                           System.debug('******objlead.CCPM_StoreTimeZone__c*****'+objlead.CCPM_StoreTimeZone__c);
                           if(String.isNotBlank(objlead.CCPM_StoreTimeZone__c) && mapTzNameBusinessHours.containsKey(objlead.CCPM_StoreTimeZone__c) && mapTzNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey!=null ){
                               if(String.isNotBlank(eSMSSet.CCPM_StartDate__c)){
                                   dateStartDate =  CCPM_datetimeConversionClass.datetimeConversion(eSMSSet.CCPM_StartDate__c, mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey);      
                               }
                               if(String.isNotBlank(eSMSSet.CCPM_EndDate__c)){
                                   dateEndDate = CCPM_datetimeConversionClass.datetimeConversion(eSMSSet.CCPM_EndDate__c, mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey);       
                               }                               
                               if(String.isNotBlank(eSMSSet.CCPM_SmsFollowUpStartDate__c)){
                                   dateSMSFollowupStartDate = CCPM_datetimeConversionClass.datetimeConversion(eSMSSet.CCPM_SmsFollowUpStartDate__c,mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey) ;
                               }
                               if(String.isNotBlank(eSMSSet.CCPM_SmsFollowUpEndDate__c)){
                                   dateSMSFollowupEndDate = CCPM_datetimeConversionClass.datetimeConversion(eSMSSet.CCPM_SmsFollowUpEndDate__c,mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey) ;
                               }
                           }
                           
                           BusinessHours objBhrs = CCPM_utility.objDefaultBusinessHour;
                           
                           if(objlead.Store__c!=null && String.isNotBlank(objlead.CCPM_StoreTimeZone__c)){
                               objBhrs = mapTzNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c);
                           }
                           system.debug('comes here');
                           System.debug('*******dateStartDate********'+dateStartDate);
                           System.debug('*******dateESMSFWKSystemNow********'+dateESMSFWKSystemNow);
                           
                           if(dateStartDate != null && dateStartDate < dateESMSFWKSystemNow){
                               Datetime datTfollowup = null;
                               if(dateEndDate == null || (dateEndDate != null && dateESMSFWKSystemNow <= dateEndDate)){
                                   if(dateSMSFollowupStartDate != null && dateESMSFWKSystemNow <= dateSMSFollowupStartDate){
                                       objlead.CCPM_SMSFollowUpDate__c = dateSMSFollowupStartDate;
                                       datTfollowup = objlead.CCPM_SMSFollowUpDate__c;  
                                   }
                                   else if(objlead.CCPM_SMSFollowUpDate__c != null){
                                       if(dateSMSFollowupEndDate != null && objlead.CCPM_SMSFollowUpDate__c >= dateSMSFollowupEndDate){
                                           objlead.CCPM_SMSFollowUpDate__c = dateSMSFollowupEndDate;
                                           datTfollowup = objlead.CCPM_SMSFollowUpDate__c;  
                                       }
                                       else{
                                           datTfollowup = calculateTimeToTriggerSMSWithInBusinessHours(objBhrs, objlead.CCPM_SMSFollowUpDate__c);                                               
                                       }
                                   }
                                   if(datTfollowup != null){
                                       if(objlead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId()){
                                           objlead.CCPM_triggerProspectSMSPart1__c = datTfollowup;
                                       }
                                       if(objlead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId()){
                                           objlead.CCPM_triggerInitialSMSDateTime__c = datTfollowup;
                                       }
                                   }                                   
                               }                               
                           }
                       }
                }
            }
        }
    }
    
    /**
@author        Manjunath Keshava (Deloitte)
@description    create the SMS object record  When lead is inserted/update with event type  IPhone X
@param         None
@return           
*/  
    
    public static void ESMSFWKCreateSMS(List<Lead> lstNew, Map<id, Lead> mapOld,Map<String, BusinessHours> mapTZNameBusinessHours)
    {
        set<string> setQueueID = CCPM_utility.populateQueueIds();
        dateESMSFWKSystemNow=ts.CCPM_sytemNow__c;
        List<CCPM_EventSMSSetting__mdt> listEventSMSSetting = [Select CCPM_JourneyMessageName__c,CCPM_Type__c,CCPM_LeadEventType__c, CCPM_LeadRecordType__c, 
                                                               CCPM_SmsFollowUpEndDate__c,CCPM_SmsFollowUpStartDate__c, CCPM_StartDate__c,
                                                               CCPM_EndDate__c, CCPM_overrideEcode__c, CCPM_CalculateSMSFollowup__c
                                                               From CCPM_EventSMSSetting__mdt Where CCPM_Active__c =: true];
        Set<String> setJMName = new Set<String>();
        for(CCPM_EventSMSSetting__mdt mdtESMS : listEventSMSSetting){
            setJMName.add(mdtESMS.CCPM_JourneyMessageName__c);
        }
        
        map<string,string> mapjourneymessage = new map<string,string>();
        for(CCPM_journeyMessage__c  objjourney : [select id,CCPM_JourneyMessageName__c, CCPM_messageInitialSMS__c from CCPM_journeyMessage__c where CCPM_isActive__c = true])
        {
            mapjourneymessage.put(objjourney.CCPM_JourneyMessageName__c ,objjourney.CCPM_messageInitialSMS__c);
            system.debug('the journey map'+mapjourneymessage);
        }
        //Map<String, BusinessHours> mapTZNameBusinessHours = CCPM_utility.mapGetBusinessHours();
        List<CCPM_SMSMessage__c> lstSmsMessageNew = new List<CCPM_SMSMessage__c>();
        for(CCPM_EventSMSSetting__mdt mdtESMS : listEventSMSSetting){
            Datetime dateStartDate;  
            Datetime dateEndDate; 
            Datetime dateSMSFollowupStartDate;  
            Datetime dateSMSFollowupEndDate; 
            
            system.debug('the for starts now');
            for(Lead objlead : lstNew){
                if(objlead.RecordTypeId==Schema.SObjectType.Lead.getRecordTypeInfosByName().get(mdtESMS.CCPM_LeadRecordType__c).getRecordTypeId() &&  objlead.CCPM_Type__c==mdtESMS.CCPM_type__c
                   && !(CCPM_utility.setleadStatusTOExclude.contains(objlead.Status)) && string.isNotBlank(objlead.CCPM_eventType__c) && objlead.CCPM_eventType__c== mdtESMS.CCPM_LeadEventType__c
                   &&(mapOld == null || (mapOld != null && (objLead.CCPM_eventType__c != mapOld.get(objlead.Id).CCPM_eventType__c || (objLead.ownerid!=mapOld.get(objlead.Id).ownerid && setQueueID!=null 
                   && setQueueID.isEmpty()==false && !setQueueID.contains(objlead.ownerId) && objLead.Status==Label.CCPM_LeadEligibleStatus))))){
                       system.debug('if conditions are satisfied'+objlead.CCPM_StoreTimeZone__c);
                       
                       if(objlead.CCPM_StoreTimeZone__c!=null && mapTZNameBusinessHours.containsKey(objlead.CCPM_StoreTimeZone__c) &&mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey!=null ){
                           if(String.isNotBlank(mdtESMS.CCPM_StartDate__c)){
                               dateStartDate = CCPM_datetimeConversionClass.datetimeConversion(mdtESMS.CCPM_StartDate__c,mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey) ;
                           }
                           if(String.isNotBlank(mdtESMS.CCPM_EndDate__c)){
                               dateEndDate = CCPM_datetimeConversionClass.datetimeConversion(mdtESMS.CCPM_EndDate__c,mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey) ;
                           }
                           if(String.isNotBlank(mdtESMS.CCPM_SmsFollowUpStartDate__c)){
                               dateSMSFollowupStartDate = CCPM_datetimeConversionClass.datetimeConversion(mdtESMS.CCPM_SmsFollowUpStartDate__c,mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey) ;
                           }
                           if(String.isNotBlank(mdtESMS.CCPM_SmsFollowUpEndDate__c)){
                               dateSMSFollowupEndDate = CCPM_datetimeConversionClass.datetimeConversion(mdtESMS.CCPM_SmsFollowUpEndDate__c,mapTZNameBusinessHours.get(objlead.CCPM_StoreTimeZone__c).TimeZoneSidkey) ;
                           }
                           system.debug(dateStartDate);
                           system.debug('the time'+dateEndDate);
                           system.debug('followdate'+dateSMSFollowupStartDate);
                           system.debug('endate'+dateSMSFollowupEndDate);
                       }
                       Boolean boolcreateSMS = false;
                       String strjourneyMessage = '';
                       
                       if(dateESMSFWKSystemNow == null){
                           dateESMSFWKSystemNow = Datetime.now();
                       }
                       if(objlead.CCPM_mobileNumber__c != null ){
                           system.debug('mobile number');
                           system.debug(objlead.CCPM_SMSFollowUpDate__c < dateSMSFollowupEndDate);
                           if(dateStartDate < dateESMSFWKSystemNow && (dateEndDate == null || (dateEndDate != null && dateESMSFWKSystemNow <= dateEndDate))){
                               if(dateSMSFollowupStartDate < objlead.CCPM_SMSFollowUpDate__c && (dateSMSFollowupEndDate == null || (dateSMSFollowupEndDate != null && objlead.CCPM_SMSFollowUpDate__c <= dateSMSFollowupEndDate))){
                                   system.debug(dateSMSFollowupStartDate < objlead.CCPM_SMSFollowUpDate__c);
                                   strjourneyMessage = mapjourneymessage.get(mdtESMS.CCPM_JourneyMessageName__c);
                                   system.debug('Message populated here'+strjourneyMessage);
                                   boolcreateSMS = true;
                               }
                           }
                       }
                       if(boolcreateSMS == true){    
                           String MTN = objlead.CCPM_mobileNumber__c;
                           String strToPhone = MTN;
                           CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
                           string strLiveTextNumber='';
                           if(objlead.RecordTypeId==Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId())
                           {
                               strLiveTextNumber=CCPM_staticConstants.strLivetextPhoneNumberNonVerizon;
                           }
                           if(objlead.RecordTypeId==Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId() && objlead.CCPM_isManualLead__c==true)
                           {
                               strLiveTextNumber=CCPM_staticConstants.strLivetextPhoneNumber;
                           }
                           objSmsMessage = createRecordsForSmsMessageObject(objlead,strjourneyMessage,strToPhone,CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1,CCPM_StaticConstants.strTaskCommunicationOutbound,objlead.CCPM_SMSFollowUpDate__c,strLiveTextNumber);
                           if(String.isNotBlank(objlead.ownerId+''))
                           {
                               objSmsMessage.CCPM_dynamicLeadOwnerName__c=objlead.CCPM_ownerFirstName__c;
                               
                               if(String.isNotBlank(objlead.CCPM_ownerEcode__c)){
                                   objSmsMessage.CCPM_dynamicECODE__c=objlead.CCPM_ownerEcode__c;
                               }
                               else if(String.isNotBlank(objlead.CCPM_storeEcode__c) && mdtESMS.CCPM_overrideEcode__c==true){
                                   objSmsMessage.CCPM_dynamicECODE__c=objlead.CCPM_storeEcode__c;
                               }
                           }
                           if(String.isNotBlank(objlead.Store__c+'')){
                               if(String.isNotBlank(objlead.CCPM_storeName__c)){
                                   objSmsMessage.CCPM_dynamicStoreName__c=objlead.CCPM_storeName__c;
                               }
                               if(String.isNotBlank(objlead.CCPM_storeRecommendedHours__c)){
                                   objSmsMessage.CCPM_dynamicStoreRecommendedHrs__c=objlead.CCPM_storeRecommendedHours__c;
                               }
                           }
                           
                           if(objlead.RecordTypeId==Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId() && objlead.CCPM_triggerProspectSMSPart1__c!=null)
                           {
                               objSmsMessage.CCPM_ScheduleDateTime__c= objlead.CCPM_triggerProspectSMSPart1__c;
                               
                           }
                           if(objlead.RecordTypeId==Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId() && objlead.CCPM_TriggerInitialSMSDateTime__c!=null)
                           {
                               objSmsMessage.CCPM_ScheduleDateTime__c= objlead.CCPM_TriggerInitialSMSDateTime__c;
                           }   
                           
                           objSmsMessage.CCPM_priority__c='Immediate';
                           System.debug('**********objSmsMessage**********'+objSmsMessage);
                           
                           if(objSmsMessage != null && objlead.CCPM_SMSOptOut__c==false){
                               lstSmsMessageNew.add(objSmsMessage);
                           }
                       }
                   }     
            }
            if(lstSmsMessageNew!=null && !lstSmsMessageNew.isEmpty())
            {
                upsert lstSmsMessageNew;
            }
        }
    }
    
}