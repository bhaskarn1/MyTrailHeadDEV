/**
*@name          CCPM_lead
*@author        Sriraman Sridharan (Deloitte)
*@date          12/07/2016
@description    US-0074: Associates the cart with the correct customer using Account Number
US-0024: Associates the preferred Store on the customer record on the correct Cart.
@testClass      CCPM_leadTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          12/07/2016              Original Version
Brigadesh Chandrasekar(Deloitte)      01/17/2017              Modified Version
Deepak Mazumdar                       03/02/2017              added comments to method
Sudhakara Reddy Nallamilli(Deloitte)  05/18/2017              added Prospect Cart Merge Method 
Sudhakara Reddy Nallamilli(Deloitte)  07/12/2017              added New Method to Capture Invalid Account Unique Ids  
Manjunath Keshava(Deloitte)           07/14/2017              Collapsed multiple IF (US-1617)
Brigadesh Chandrasekar(Deloitte)      08/07/2017              Made changes for sending Initial SMS and Prospect 1st SMS based on Queued Owner   : US 1694
Brigadesh Chandrasekar(Deloitte)      08/09/2017              Added call to method setTimeSTampForConvertedLeads in before update : US 1678
Brigadesh Chandrasekar(Deloitte)      08/20/2017              Method Added : updateLeadOwneronSMSMessage for US 1752
Brigadesh Chandrasekar(Deloitte)      08/20/2017              Method Added : cancelScheduledSMSWhenQueued for US 1717
Brigadesh Chandrasekar(Deloitte)      09/14/2017              Method edited : insertRecordsInSmsmessageObjectForLeadAndProspects for US 1717
keshava Manjunath (Deloitte)          09/15/2017              Method edited :assignProspectLeadOwner for US 1713
keshava Manjunath (Deloitte)          09/15/2017              Method Added : updateCampaignFieldResponded for US 1824
Brigadesh Chandrasekar(Deloitte)      09/21/2017              Method Modified : populateInitialSMSMessagesToBeSent,insertRecordsInSmsmessageObjectForLeadAndProspects US 1866
keshava Manjunath (Deloitte)          09/15/2017              Method Added updateNewLeadFieldsOnLeadUpdate (DISTSCE-1607)
*/
trigger CCPM_lead on Lead (before insert, before update,after insert, after update) {
    Map<String,Group> mapDistrictAndGroup = CCPM_leadHandlerAssignOwnership.getMapOfStoreDistrictAndGroup();
    List<BusinessHours> oBusinessHours = CCPM_utility.getBusinessHours();
    public static BusinessHours objDefaultBusinessHour = CCPM_utility.objDefaultBusinessHour;
    // Condition to call the handler method before update/after insert
    CCPM_leadTriggerHandler clsTriggerHandler = new CCPM_leadTriggerHandler();
    // Condition to call the handler method before update/after insert
    if(clsTriggerHandler.IsDisabled())
    {
        
        if(Trigger.isbefore){
            //List<BusinessHours> oBusinessHours = CCPM_LeadHandler.getBusinessHours();
            //Condition to call the handler method before insert
            if(Trigger.isInsert){
                // As recommended by Salesforce, Removed the runOnce Check for the Before Insert  
                //This method is to set the Status to Eligible and Previousl Lead Status to New before Insert
                list<Lead> lstlstNewLeadsupdateLeadStatusToEligible = new List<Lead>();
                lstlstNewLeadsupdateLeadStatusToEligible = CCPM_LeadHandler.updateLeadStatusToEligible(Trigger.new);
                
                list<Lead> lstNewLeadsupdateMTNAvailablefield = new list<Lead>();
                //This method is to set the Store Manager, Store ID, Store and Lead owner for Prospect Record type
                lstNewLeadsupdateMTNAvailablefield=CCPM_leadHandler.updateMTNAvailablefield(lstlstNewLeadsupdateLeadStatusToEligible);
                System.debug('# List lstNewLeadsupdateMTNAvailablefield-> '+lstNewLeadsupdateMTNAvailablefield);
                
                //This meethod is to assign Lead owner to Prospect before insertion
                list<Lead> lstNewLeadsassignProspectLeadOwner = new list<Lead>();
                lstNewLeadsassignProspectLeadOwner=CCPM_leadHandler.assignProspectLeadOwner(lstNewLeadsupdateMTNAvailablefield,mapDistrictAndGroup);
                System.debug('# List lstNewLeadsassignProspectLeadOwner-> '+lstNewLeadsassignProspectLeadOwner);
                
                list<Lead> lstNewLeadsassignProspectSMSDateTimeBeforeInsert = new list<Lead>();
                //This method is to populate trigger Prospect 1st SMS date/time
                lstNewLeadsassignProspectSMSDateTimeBeforeInsert=CCPM_leadHandler.assignProspectSMSDateTimeBeforeInsert(lstNewLeadsassignProspectLeadOwner,oBusinessHours);
                System.debug('# List lstNewLeadsassignProspectSMSDateTimeBeforeInsert-> '+lstNewLeadsassignProspectSMSDateTimeBeforeInsert);
                
                // This method is targeted to verify CartLastHandledBy field With StoreEmployee Object 
                // and update the ownership of lead
                list<Lead> lstNewLeadsassignLeadOwnershipOnCreate = new list<Lead>();
                //lstNewLeadsassignLeadOwnershipOnCreate=CCPM_leadHandler.assignLeadOwnershipOnCreate(lstNewLeadsassignProspectSMSDateTimeBeforeInsert, oBusinessHours);
                
                lstNewLeadsassignLeadOwnershipOnCreate = CCPM_leadHandlerAssignOwnership.assignLeadOwnershipOnCreate(lstNewLeadsassignProspectSMSDateTimeBeforeInsert, oBusinessHours,mapDistrictAndGroup);
                
                //lstNewLeadsassignLeadOwnershipOnCreate = CCPM_leadHandlerAssignOwnership.assignLeadOwnershipOnCreate(Trigger.new);
                system.debug('@@@lstNewLeadsassignLeadOwnershipOnCreate: ' + lstNewLeadsassignLeadOwnershipOnCreate);
                
                list<Lead> lstNewLeadsAfterpopulatingTime = new List<Lead>(); 
                lstNewLeadsAfterpopulatingTime = CCPM_leadHandlerAssignOwnership.assignTriggerSMSTimeOnInsert(lstNewLeadsassignLeadOwnershipOnCreate, oBusinessHours, null);
                system.debug('@@@lstNewLeadsAfterpopulatingTime: ' + lstNewLeadsAfterpopulatingTime);
                
                // This method is targeted to handle the operations on updating the Unique field on Cart 
                // based on status changes so that status of cart id lremains unique. This ensures that
                // there can only be 1 open cart for Mobile No. and Account No. combination
                /*  list<Lead> lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnInsert = new list<Lead>();
lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnInsert=CCPM_leadHandler.updateUniqueIdOnLeadStatusChangeOnInsert(lstNewLeadsAfterpopulatingTime);
//lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnInsert=CCPM_leadHandler.updateUniqueIdOnLeadStatusChangeOnInsert(lstNewLeadsassignLeadOwnershipOnCreate);
System.debug('# List lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnInsert-> '+lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnInsert);*/
                
                // Call the method which will process the prospect carts and flags for the Merge
                list<Lead> lstupdateProspectCartMergeFlag = new list<Lead>();
                lstupdateProspectCartMergeFlag = CCPM_leadHandler.updateProspectCartMergeFlag(lstNewLeadsAfterpopulatingTime);  
                // CCPM_leadHandler.updateProspectCartMergeFlag(trigger.new);     
                //CCPM_leadhandler.iphoneXCalcSMSEventDate(Trigger.new, null);
            }
            
            // Condition to call the handler method before update
            if(Trigger.isUpdate )//&& CCPM_leadHandler.runOnce()
            {   
                System.debug('@@@FiredBeforeUpdateTrigger');
                list<Lead> lstNewLeadssetTimeSTampForConvertedLeads = new list<Lead>();
                //This method is targetted to set the date/time fields for a lead whose status is converted
                lstNewLeadssetTimeSTampForConvertedLeads = CCPM_leadHandler.setTimeSTampForConvertedQualifiedLeads(Trigger.new, Trigger.oldMap);
                //This method is targetted to set the Trigger Follow Up SMS DateTime
                list<Lead> lstNewLeadssetTriggerFollowUpSMSDateTime = new list<Lead>();
                lstNewLeadssetTriggerFollowUpSMSDateTime=CCPM_leadHandler.setTriggerFollowUpSMSDateTime(lstNewLeadssetTimeSTampForConvertedLeads,Trigger.oldMap, oBusinessHours);
                System.debug('# List lstNewLeadssetTriggerFollowUpSMSDateTime-> '+lstNewLeadssetTriggerFollowUpSMSDateTime);
                
                //This Method is targeted to update the schedule time in SMSMessageObject and the Trigger Prospect 1st SMS Date/Time on Lead
                list<Lead> lstNewLeadsassignProspectSMSDateTimeBeforeUpdateForEventChange = new list<Lead>();
                lstNewLeadsassignProspectSMSDateTimeBeforeUpdateForEventChange = CCPM_leadHandler.assignProspectSMSDateTimeBeforeUpdateForEventChange(lstNewLeadssetTriggerFollowUpSMSDateTime,Trigger.oldMap, oBusinessHours);
                System.debug('# List lstNewLeadsassignProspectSMSDateTimeBeforeUpdateForEventChange-> '+lstNewLeadsassignProspectSMSDateTimeBeforeUpdateForEventChange);
                
                // This method is targeted to handle the operations on updating the Unique field on Cart 
                // based on status changes so that status of cart id lremains unique. This ensures that
                // there can only be 1 open cart for Mobile No. and Account No. combination
                /*list<Lead> lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnUpdate = new list<Lead>();
lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnUpdate=CCPM_leadHandler.updateUniqueIdOnLeadStatusChangeOnUpdate(lstNewLeadsassignProspectSMSDateTimeBeforeUpdateForEventChange,Trigger.oldMap);
System.debug('# List lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnUpdate-> '+lstNewLeadsupdateUniqueIdOnLeadStatusChangeOnUpdate);*/
                
                // This method is targeted to handle the operations on updating the Unique field on Cart 
                // based on status changes so that status of cart id lremains unique. This ensures that
                // there can only be 1 open cart for Mobile No. and Account No. combination
                //list<Lead> lstResetSubStatusToBlankForClosedStatusLeads = new list<Lead>();
                //lstResetSubStatusToBlankForClosedStatusLeads=CCPM_leadHandler.updateLeadSubStatusToBlankForClosedLeads(Trigger.new);
                //System.debug('# List lstResetSubStatusToBlankForClosedStatusLeads-> '+lstResetSubStatusToBlankForClosedStatusLeads);
                
                //Update previous Status value
                list<Lead> lstNewLeadsupdatePriorStatus = new list<Lead>();
                lstNewLeadsupdatePriorStatus=CCPM_leadHandler.updatePriorStatus(lstNewLeadsassignProspectSMSDateTimeBeforeUpdateForEventChange,Trigger.oldMap);
                System.debug('# List lstNewLeadsupdatePriorStatus-> '+lstNewLeadsupdatePriorStatus);
                //Update the TimeStamp for lead status change
                //CCPM_leadHandler.updateLeadStatusTimeStamp(Trigger.new,Trigger.old);
                //CCPM_leadHandler.updateLeadSubStatusTimeStamp(Trigger.new,Trigger.old);
                // This method is targeted to verify CartLastHandledBy field With StoreEmployee Object 
                // and update the ownership of lead
                list<Lead> lstNewLeadsassingLeadOwnershipOnUpdate = new list<Lead>();
                
                //lstNewLeadsassingLeadOwnershipOnUpdate=CCPM_leadHandler.assingLeadOwnershipOnUpdate(lstNewLeadsupdatePriorStatus,Trigger.old,mapDistrictAndGroup);
                
                //lstNewLeadsassingLeadOwnershipOnUpdate=CCPM_leadHandler.assingLeadOwnershipOnUpdate(lstNewLeadsupdatePriorStatus,Trigger.old,mapDistrictAndGroup);
                //lstNewLeadsassingLeadOwnershipOnUpdate=CCPM_leadHandler.assingLeadOwnershipOnUpdate(lstNewLeadsupdatePriorStatus,Trigger.old,mapDistrictAndGroup);
                //lstNewLeadsassingLeadOwnershipOnUpdate=CCPM_leadHandler.assingLeadOwnershipOnUpdate(lstNewLeadsupdatePriorStatus,Trigger.old,mapDistrictAndGroup);
                lstNewLeadsassingLeadOwnershipOnUpdate=CCPM_leadHandlerAssignOwnership.assignLeadOwnershipOnUpdate(lstNewLeadsupdatePriorStatus,Trigger.old, oBusinessHours,mapDistrictAndGroup);
                System.debug('# List lstNewLeadsassingLeadOwnershipOnUpdate-> '+lstNewLeadsassingLeadOwnershipOnUpdate);
                CCPM_leadHandler.updateNewLeadFieldsOnLeadUpdate(Trigger.new,Trigger.oldMap,oBusinessHours);
                //CCPM_leadhandler.iphoneXCalcSMSEventDate(Trigger.new, Trigger.oldMap);
                
            }
        }
        
        // Condition to call the handler method after update/after insert
        else if(Trigger.isafter){
            
            if(Trigger.isInsert){
                //Call the method which inserts records in the sms message custom object to send initial messages for leads or prospects
                //CCPM_leadHandler.populateInitialSMSMessagesToBeSent(trigger.new,mapDistrictAndGroup,null);
                CCPM_leadHandler.shareLeadsWithAssistanManagers(Trigger.new);
                //Call to Capture Invalid Account Unique IDs in the Custom Error Object
                CCPM_leadHandler.logErrorMessagesforInvalidAccountUniqueIds(Trigger.new);
                //CCPM_leadHandler.leadInsUpdIphoneXSMS(trigger.new,null); 
            }
            if(Trigger.isUpdate){
                //Send Initial / Prospect 1st SMS on an update of lead owner from queue to a valid owner
                //CCPM_LeadHandler.populateInitialProspectSMSForValidLeadOwnerChange(Trigger.new,Trigger.oldMap,mapDistrictAndGroup);
                //Send SMS to Lead owners when task is created or Lead ownership is changed while on particular status
                CCPM_leadHandler.populateSMSMessageToBeSentForLeadOwnerChange(trigger.new,Trigger.oldMap);
                // This method is targeted to delete all the ITR Messages Leads that has been expired / converted / rejected
                CCPM_leadHandler.deleteITRMessagesForExpiredAndConvertedLeads(trigger.new,Trigger.oldMap);
                
                // calling this method for sending sms after record is being updated
                CCPM_leadHandler.insertRecordsInSmsmessageObjectForLeadAndProspects(Trigger.new,Trigger.oldMap,mapDistrictAndGroup);
                // This method is targeted to delete the Scheduled messages associated with a cart when the status is Expired/Rejected/COmpleted/Qualified
                CCPM_leadHandler.updateSMSMessagesonClosedStatus(trigger.new,Trigger.old);
                //Provide Lead shares after update
                CCPM_leadHandler.shareLeadsWithAssistanManagers(Trigger.new,Trigger.oldMap);
                //Updating SMS Records on a valid lead owner change
                CCPM_LeadHandler.updateLeadOwneronSMSMessage(Trigger.new,Trigger.oldMap,mapDistrictAndGroup);
                //Updating the status of SMS message records to removed when the current owner is queued
                CCPM_LeadHandler.cancelScheduledSMSWhenQueued(Trigger.new,Trigger.oldMap,mapDistrictAndGroup);
                CCPM_leadHandler.updateCampaignFieldResponded(Trigger.new,Trigger.oldMap);
                //Removing SMS Message records associated to Prospect when Event Type is updated to Iphone X
                CCPM_leadHandler.cancelSMSEventTypeIphoneX(Trigger.new,Trigger.oldMap);
                
                //CCPM_leadHandler.leadInsUpdIphoneXSMS(trigger.new,Trigger.oldMap); 
                CCPM_leadHandler.CancelAndCreateNewSmsSchedulesWhileMerge(Trigger.new,Trigger.old,mapDistrictAndGroup);
            } 
        }
    }
    CCPM_TriggerDispatcher.Run(new CCPM_leadTriggerHandler());
    
    
}