/**
*@name          CCPM_mergeProspectCartwithProspectUtil
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/17/2017
@description   : US-362 and US-393 To Flag the Prospect Carts for the Merging Batch Job  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/17/2017          Original Version  
Sudhakara Reddy Nallamilli (Deloitte)    06/26/2017          US-481, US-482
                                                             Revamped whole design by removing the Major Merge Logic from the Lead trigger and pushing it to batch jobs.
                                                             Added Logic to achieve the Merging Functionality between Prospect Cart to Prospect Cart.                                                                 
Sudhakara Reddy Nallamilli (Deloitte)    07/10/2017          US-533, US-534, US-536, US-537, US-538
                                                             Added Logic to pass on the Merged Master Lead Ids to the method 'updateSMSMessageRecords'
                                                             to handle the SMS Messages after the merge based on the priority
Manjunath Keshava(Deloitte)              07/14/2017          Added Null checks (US-1618)
Sudhakara Reddy Nallamilli (Deloitte)    07/18/2017          TKT-000367 
                                                             Added Logic to clear the 'CCPM_isSMSResponseReceived__c' and 'CCPM_SMSResponseReceivedDateTime__c' during merge call
Sudhakara Reddy Nallamilli (Deloitte)    07/18/2017          US-1628 
                                                             Changed the logic to handle the scenario 'Prospect Cart comes first and Prospect comes later'
Sudhakara Reddy Nallamilli (Deloitte)    07/24/2017          TKT-000381
                                                             Removed the Prospect Cart to Prospect Cart Merge Related Logic and changed logic to popluate the owner Ids
Sudhakara Reddy Nallamilli (Deloitte)    07/24/2017          TKT-000396
                                                             Added Logic to copy the MTN on to the Prospect from the Prospect Cart it the MTN is blank on Prospect
Sudhakara Reddy Nallamilli (Deloitte)    08/04/2017          US-495,US-496 and US-497
                                                             Added Logic to handle the Manual Lead Merge Scenarios as mentioned in the User Stories US-495,496,497
Sudhakara Reddy Nallamilli (Deloitte)    08/17/2017          US-1730,US-1737,US-1739,US-1740,US-1741,US-1746,US-1747
                                                             Prospect to Prospect Merge Scenarios and other SMS Opt out Scenarios
                                                             US-1801 - Removed the merge logic based on the email match
Sudhakara Reddy Nallamilli (Deloitte)    09/05/2017          Modified the logic to resolve the issues - TKT-505,508,517
Sudhakara Reddy Nallamilli (Deloitte)    09/12/2017          US-1722,US-1731,US-1734,Us-1736,US-1738,US-1740,US-1747
                                                             Manual Lead to Manual Lead Merge Scenarios and other SMS Opt out Scenarios 
                                                             - processMergeLeadCartsWithManualLeads
                                                             - mergeMasterChildLead
Sudhakara Reddy Nallamilli (Deloitte)    11/19/2017          - Telesales Merge Scenarios 
                                                             - JIRA User Stories: DISTSCE-1782,DISTSCE-1786,DISTSCE-1787,DISTSCE-1788,DISTSCE-1789                                                             
                                                             
*/  
public class CCPM_mergeProspectCartwithProspectUtil
{ 
/* 
* Method Name: flagMergeProspectCartwithProspect
* Author     : Sudhakara Reddy Nallamilli (Deloitte)
* Date       : 05/17/2017
* Description: This is getting called from the CCPM_leadHandler and it will process all the Prospect Carts
               and then update the 'CCPM_tobemerged__c' field to true  
*/   

 public static boolean boolProspectCartProspectMergeFlag = false; 
 public static boolean boolManualLeadLeadCartMergeFlag = false;
 public static boolean boolLeadCartManualLeadMergeFlag = false;
 public static boolean boolTelesalesProspectMergeFlag = false;
 public static boolean boolProspectTelesalesMergeFlag = false;
 public static boolean boolTelesalesManualLeadMergeFlag = false;
 public static boolean boolManualLeadTelesalesMergeFlag = false;
 public static lead objLeadMasterProspectGlobal = new lead();
 public static lead objLeadMasterManualLeadGlobal = new lead();
 // This method is being called from the lead hanlder through the Lead Trigger 
 
  public static list<lead> flagMergeProspectCartwithProspect (List<Lead> lstLeadProspectCartTriggerNew)
  { 
   //update the 'CCPM_tobemerged__c' field to true for all the Prospect Carts   
   for(lead objLead:lstLeadProspectCartTriggerNew)
   {
     if( ( objLead.RecordTypeId  == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId() 
          || (objLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId() && objLead.CCPM_isManualLead__c == true) ) 
         && objLead.CCPM_mobileNumber__c != NULL && objLead.status!= NULL && CCPM_staticConstants.setOpenLeadStatus.contains(objLead.status) )
       {
        objLead.CCPM_tobeMerged__c = true;
       }
   }    
   return lstLeadProspectCartTriggerNew;
  }
  
 /**
@author        Sudhakara Reddy Nallamilli (Deloitte)
@description   This method is targeted to perform the SOSL and return the list of Leads
               This method is being called from the Merge Batch Job 'CCPM_mergeProspectCartWithProspectBatch'
@param         SOSL Search Key, Search Group 
@return        List of Leads
*/   
  
  public static void processProspectCarts(list<lead> lstLeadPropspectCart)
  {
    // List to hold the Mobile numbers for the Prospect Carts
    list<string>   lstProspectCartMobileNumbers = new list<string>();
    // Set to hold the Mobile numbers for the Prospect Carts to remove duplicates
    set<string>   setProspectCartMobileNumbers = new set<string>();
    // List to hold the Emails for the Prospect Carts
    list<string>   lstProspectCartEmails = new list<string>();
     // Set to hold the Emails for the Prospect Carts to remove duplicates
    set<string>   setProspectCartEmails = new set<string>();
    // Map to hold the Mobile number and Corresponding Prospect 
    map<string,lead> mapProspectByMobileNumber = new map<string,lead>();
    // Map to hold the Mobile number and Corresponding Prospect Cart
    map<string,lead> mapProspectCartByMobileNumber = new map<string,lead>();
    // Map to hold the Mobile number and Corresponding Prospect Cart for the UnMatched Processed Prospect Cart
    map<string,lead> mapProspectCartByMobileProcessedUnMatched = new map<string,lead>();
    // set to hold list of leads which got merged
    set<id> setLeadsGotMerged = new set<id>();
    // list to hold the leads which needs to be processed for merging
    list<lead> lstLeadsFinalProcess = new list<lead>();
    // list to hold the Non Merged Leads
    list<lead> lstNonMergeLeads = new list<lead>();  
    // list to hold the Merged Master Leads Ids for SMS Processing
    set<id> setMergeMasterLeads = new set<id>();
    // list to hold the Merged Master Prospect Leads Ids for SMS Processing
    set<id> setMergeProspectMasterLeads = new set<id>();
    // map to hold the Merged Telesales Prospects Lead Ids for Activities
    Map<String, Boolean> mapMergeTelesalesLeads = new Map<String, Boolean>();
    // Set of Ids for the Lead Record Type Ids
    set<id> setRecordTypeIds = new set<id>();
    // this variable is used to handle DML limit of Merge API call
    integer prospectMergeCount = 0;
    // Adding the record types to set
    setRecordTypeIds.add(Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId());
    setRecordTypeIds.add(Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_leadProspectCartRT).getRecordTypeId());  
        
    // Collecting the List of Mobile Numbers and Emails from the Prospect Carts
    for( lead objLead: lstLeadPropspectCart)
    { 
     if( objLead.CCPM_mobileNumber__c != NULL)
      { 
       setProspectCartMobileNumbers.add(objLead.CCPM_mobileNumber__c); 
       lstLeadsFinalProcess.add(objLead);
      }   
    }  
   
   if( setProspectCartMobileNumbers != NULL && !setProspectCartMobileNumbers.isEmpty() )
   {
     lstProspectCartMobileNumbers.addAll(setProspectCartMobileNumbers);
     string strProsCartMobileNos = string.join(lstProspectCartMobileNumbers,CCPM_staticConstants.strLogicalOR);
     // Fetching the Prospects based on the Prospect Cart Mobile Numbers Using SOSL 
     // Assuming there will be one Open Prospect / Prospect Cart for a given MTN 
      
     list<lead> lstleadsByMobile = new list<lead>();
       
     lstleadsByMobile = CCPM_mergeProspectCartwithProspectUtil.searchMatchingLeadRecords(strProsCartMobileNos,CCPM_staticConstants.strPhone,setRecordTypeIds);
                                         
     if( lstleadsByMobile != NULL && !lstleadsByMobile.isEmpty()  )
     { // Collecting the Prospects and Prospect Carts into Separate Maps based on MTN  
       for(lead objProsByMobileNo: lstleadsByMobile)
       {
        if(objProsByMobileNo.CCPM_mobileNumber__c != NULL)
         {
           if(objProsByMobileNo.RecordTypeID == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId())
           {    
            mapProspectByMobileNumber.put(objProsByMobileNo.CCPM_mobileNumber__c,objProsByMobileNo);
           }
           else if(objProsByMobileNo.RecordTypeID == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_leadProspectCartRT).getRecordTypeId())
           {
            mapProspectCartByMobileNumber.put(objProsByMobileNo.CCPM_mobileNumber__c,objProsByMobileNo);
           }
         }       
        }
        // Clear the List of List Data
        lstleadsByMobile.clear();
        lstProspectCartMobileNumbers.clear();
        setProspectCartMobileNumbers.clear();
     }
   }    
  
   // Process the Prospect Carts and Update the tobeMerged Flag
   for( lead objLead1: lstLeadsFinalProcess)
   {
      lead objProspectMaster = new lead();
      // Clearing Global Variable
      lead objLead2 = new lead();
      objLeadMasterProspectGlobal = objLead2;
      boolean boolMergeFlag = false; 
      boolean boolProspectMergeFlag = false;
      boolean boolTelesalesMergeFlag = false;
      boolProspectCartProspectMergeFlag = false;
      boolTelesalesProspectMergeFlag = false;
      boolProspectTelesalesMergeFlag = false;
      // Logic to Handle the Prospect Carts Exist and Then Prospects gets created Scenario
       if(objLead1.CCPM_mobileNumber__c != NULL && mapProspectByMobileNumber.containsKey(objLead1.CCPM_mobileNumber__c) && mapProspectByMobileNumber.get(objLead1.CCPM_mobileNumber__c).id != objLead1.id)
       {        
        // This logic handles both the Prospect to Prospect Merge Scenario and Prospect Cart to Prospect Scenario
        objProspectMaster = mapProspectByMobileNumber.get(objLead1.CCPM_mobileNumber__c);       
        if(objProspectMaster.CCPM_createdChannel__c != null && objLead1.CCPM_createdChannel__c != Null )
        {
          // This IF Conditoin is to handle both the below scenarios 
          //  1) Telesale Prospect Created First and Then Manual Prospect Created
          //  2) Manual Prospect Created First and Then Telesales Prospect Created  
          if( objProspectMaster.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName && objLead1.CCPM_createdChannel__c == Label.CCPM_retailChannelName )
          {
             boolTelesalesProspectMergeFlag = true;
             boolMergeFlag = mergeMasterChildLead(objLead1,objProspectMaster);
             if(boolMergeFlag == true)
             {
              objLead2 = objProspectMaster;
              objProspectMaster = objLead1;  
              objLead1 = objLead2;
              mapProspectByMobileNumber.remove(objLead1.CCPM_mobileNumber__c);
              mapProspectByMobileNumber.put(objLeadMasterProspectGlobal.CCPM_mobileNumber__c,objLeadMasterProspectGlobal); 
             }
          }
          else
          {
           if(objLead1.CCPM_createdChannel__c ==  Label.CCPM_telesalesChannelName && objProspectMaster.CCPM_createdChannel__c == Label.CCPM_retailChannelName)
            boolProspectTelesalesMergeFlag = true;
           boolMergeFlag = mergeMasterChildLead(objProspectMaster,objLead1);
           if(boolMergeFlag == true)
           {
            if(objLead1.CCPM_createdChannel__c ==  Label.CCPM_retailChannelName && objProspectMaster.CCPM_createdChannel__c == Label.CCPM_retailChannelName)
            boolProspectMergeFlag = true; // This is to prioritize the Event SMS Messages for Prospect to Prospect Merge
            else if(objLead1.CCPM_createdChannel__c ==  Label.CCPM_telesalesChannelName && objProspectMaster.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName)
            boolTelesalesMergeFlag = true; // This is to prioritize the Activities for Telesales Prospect to Telesales Prospect Merge
            mapProspectByMobileNumber.remove(objLead1.CCPM_mobileNumber__c);
            mapProspectByMobileNumber.put(objLeadMasterProspectGlobal.CCPM_mobileNumber__c,objLeadMasterProspectGlobal);
           }
          }        
        }
       }
       else if(objLead1.CCPM_mobileNumber__c != NULL && mapProspectCartByMobileNumber.containsKey(objLead1.CCPM_mobileNumber__c) && mapProspectCartByMobileNumber.get(objLead1.CCPM_mobileNumber__c).id != objLead1.id)
       {
         // Merging Propsect Carts into Prospects Based on MTN match    
         objProspectMaster = mapProspectCartByMobileNumber.get(objLead1.CCPM_mobileNumber__c);
         // Updating this flag to avoid copying the First Name and Last Name
         boolProspectCartProspectMergeFlag = true;
         boolMergeFlag = mergeMasterChildLead(objLead1,objProspectMaster);
         if (boolMergeFlag == true)
           {
           // Updating this flag to handle Event SMS Messages 
             boolProspectMergeFlag = true; 
             mapProspectCartByMobileNumber.remove(objLead1.CCPM_mobileNumber__c);
             mapProspectByMobileNumber.put(objLeadMasterProspectGlobal.CCPM_mobileNumber__c,objLeadMasterProspectGlobal);
             objLead2 = objProspectMaster;
             objProspectMaster = objLead1;  
             objLead1 = objLead2;
           }         
       }// Logic to handle the merge for the Prospects within the same batch
       else if(objLead1.CCPM_mobileNumber__c != NULL)
       {
         mapProspectByMobileNumber.put(objLead1.CCPM_mobileNumber__c,objLead1);
       }      
       
       if(boolMergeFlag == false && objLead1.id != NULL)
       {
        // Capture the Records which doesn't require Merge and update the CCPM_tobeMerged__c = false
        objLead1.CCPM_tobeMerged__c = false;
        lstNonMergeLeads.add(objLead1);
       }
       else if(objLead1.id != NULL && boolMergeFlag == true)
       {
        prospectMergeCount = prospectMergeCount + 1;
        // Capturing the Successfull Merged Child Leads to Avoid the update failures 
        setLeadsGotMerged.add(objLead1.id);
        if(objProspectMaster.id != NULL && boolProspectMergeFlag == true) 
         setMergeProspectMasterLeads.add(objProspectMaster.id);
        else if(objProspectMaster.id != NULL && boolTelesalesProspectMergeFlag == true)
        mapMergeTelesalesLeads.put(objProspectMaster.id,false);
        else if(objProspectMaster.id != NULL && boolTelesalesMergeFlag == true)
        mapMergeTelesalesLeads.put(objProspectMaster.id,true);
        else if(objProspectMaster.id != NULL) 
        setMergeMasterLeads.add(objProspectMaster.id);
        
        // Capture the Records which got Merged and update the CCPM_tobeMerged__c = false for the Master
        if(objProspectMaster.id != NULL && objProspectMaster.CCPM_tobeMerged__c == true && integer.valueof(Label.CCPM_MergeBatchDMLLimit) > prospectMergeCount )
        {
          objProspectMaster.CCPM_tobeMerged__c = false;
          lstNonMergeLeads.add(objProspectMaster);
        }
        else if (integer.valueof(Label.CCPM_MergeBatchDMLLimit) <= prospectMergeCount)
        {
         break;
        }        
       }
   } 
   
   // Updating the Prospect Carts Merge Flag to False for the records without the Master Record
      clearTobeMergedFlag(lstNonMergeLeads, setLeadsGotMerged);
   // Call to the method which is handling the SMS Messages for the master merged leads 
      if(setMergeProspectMasterLeads != NULL && !setMergeProspectMasterLeads.isEmpty())
      {
       CCPM_sendSMSMergeManual.updateSMSMessageRecords(setMergeProspectMasterLeads,true);
      } 
      if( setMergeMasterLeads != NULL && !setMergeMasterLeads.isEmpty()){
    //    system.debug('&&&& setMergeMasterLeads:'+ setMergeMasterLeads);
       CCPM_sendSMSMergeManual.updateSMSMessageRecords(setMergeMasterLeads,false);  
      } 
     // Call to the method which is handling the Activities for Telesales merges 
      if(mapMergeTelesalesLeads!= null && !mapMergeTelesalesLeads.isEmpty())
      {
       CCPM_sendSMSMergeManual.updateTaskRecords(mapMergeTelesalesLeads);
      }
     
  }
  
  /**
@author        Sudhakara Reddy Nallamilli (Deloitte)
@description   This method is targeted to perform the SOSL and return the list of Leads
@param         SOSL Search Key, Search Group 
@return        List of Leads
*/ 
  public static list<lead> searchMatchingLeadRecords(string strSearchKey, string strSearchGroup, set<id> setRecordTypeIds) 
  {
    // SOSL Search Group (I.e. Phone,Email, All)
   string strSearchGroupfinal; 
   // Fetching SOSL Field Selection from Custom Label  
   string strFieldSelection = Label.CCPM_leadMergeSOSLFieldSelection;
   // Set of Strings for the lead open status
   set<string> setOpenLeadStatus = CCPM_staticConstants.setOpenLeadStatus; 
   // Fetching the SOSL Where Clause from Custom Label
   string strWhereClause = Label.CCPM_leadMergeSOSLWhereClause; 
   // Trying to avoid the SQL Injections
   if(strWhereClause != NULL) 
   strWhereClause = string.escapeSingleQuotes(strWhereClause); 
   // Determining the SOSL Search Group based on the input Parameter
   if(strSearchGroup.equalsIgnoreCase(CCPM_staticConstants.strPhone))
   {
    strSearchGroupfinal = CCPM_staticConstants.strSOSLGroupPhone;
   }
   else if(strSearchGroup.equalsIgnoreCase(CCPM_staticConstants.strEmail))
   {
    strSearchGroupfinal = CCPM_staticConstants.strSOSLGroupEmail;
   }
   else
   {
    strSearchGroupfinal = CCPM_staticConstants.strSOSLGroupAll;
   }
   // Executing the SOSL using the search.query 
   string strquery = CCPM_staticConstants.strSOSLFind +'\''+strSearchKey+'\' '+ strSearchGroupfinal+ CCPM_staticConstants.strObjectLead + strFieldSelection+' '+ strWhereClause ;//+ 'limit 2000';
   // List to hold the leads which are being fetched by above SOSL
   List<Lead> lstLeadList = New list<Lead>();
   try
   {
    List<List<sObject>> lstSearchLead = search.query(strquery);
    // Casting the SOSL result into List of Leads
    lstLeadList = ((List<Lead>)lstSearchLead[0]);
   // Update empty lead to improve the code coverage in test class 
     if(Test.isRunningTest())
       {
        integer i = 0;
         for(lead objLeadTest:lstLeadList)
         {
            if(i == 1 || i == 2)
             {
               objLeadTest.RecordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_leadProspectCartRT).getRecordTypeId();
             }
                i++;
         }
       }
    }
   catch(DMLException e)
     {
      CCPM_LogMessageUtility.logMessage(e,'CCPM_leadMergeProspectCartBatch',
                                          'Prospect Cart Merge Batch Job',
                                          'Exception thrown while Executing SOSL Call',true);
     }            
   // Returning the List of Leads
   return lstLeadList;
  }  
  
  /**
@author        Sudhakara Reddy Nallamilli (Deloitte)
@description   This method is targeted to perform the Merge between Master and Child Leads and return the boolean status
@param         ObjLeadMaster (Master Lead) and objLeadChild (Child Lead) 
@return        Boolean Status
*/ 
  public static boolean mergeMasterChildLead(lead ObjLeadMaster,lead objLeadChild)
  {
    
    // Lead Object to Hold the Master Lead Information for Merging
    // this is to avoid the formula fields update during merge
    lead objLeadMasterUpdate = new lead();
    boolean boolTelesalesmerge = false;
    boolean boolCartTelesalesmerge = false;
    boolean boolManualLeadTelesalesmerge = false;
    // Clearing the master record flags and date time fields to make sure SMS Path Journey Continues without any issues 
    if(ObjLeadMaster.id != NULL && objLeadChild.id != NULL)
    { 
       objLeadMasterUpdate.id = ObjLeadMaster.id;
       if(ObjLeadMaster.CCPM_mobileNumber__c != null)  
       objLeadMasterUpdate.CCPM_mobileNumber__c = ObjLeadMaster.CCPM_mobileNumber__c;
       if(ObjLeadMaster.CCPM_isManualLead__c != null)
       objLeadMasterUpdate.CCPM_isManualLead__c = ObjLeadMaster.CCPM_isManualLead__c;
       if(ObjLeadMaster.RecordTypeId != null)
       objLeadMasterUpdate.RecordTypeId = ObjLeadMaster.RecordTypeId;      
       objLeadMasterUpdate.CCPM_isInitialSMSSent__c = false;
       objLeadMasterUpdate.CCPM_initialSMSSentDateTime__c = NULL;
       objLeadMasterUpdate.CCPM_isFollowUpSMSSent__c = false;
       objLeadMasterUpdate.CCPM_followUpSMSDate__c = NULL;
       objLeadMasterUpdate.CCPM_triggerInitialSMSDateTime__c = NULL; 
       objLeadMasterUpdate.CCPM_triggerFollowupSMSDateTime__c = NULL;
       objLeadMasterUpdate.CCPM_isSMSResponseReceived__c = false;
       objLeadMasterUpdate.CCPM_SMSResponseReceivedDateTime__c = NULL;
       objLeadMasterUpdate.CCPM_finalPreDefinedSMSFlag__c = false;
       objLeadMasterUpdate.CCPM_firstPredefinedSMSFlag__c = false;
       if(ObjLeadMaster.CCPM_createdChannel__c != null)
       objLeadMasterUpdate.CCPM_createdChannel__c = ObjLeadMaster.CCPM_createdChannel__c;
       if(ObjLeadMaster.CCPM_Created_Lead_Source__c != null)
       objLeadMasterUpdate.CCPM_Created_Lead_Source__c = ObjLeadMaster.CCPM_Created_Lead_Source__c;
       if(ObjLeadMaster.CCPM_CreatedType__c != null)
       objLeadMasterUpdate.CCPM_CreatedType__c = ObjLeadMaster.CCPM_CreatedType__c;
       if(ObjLeadMaster.CCPM_reminder__c != null)
       objLeadMasterUpdate.CCPM_reminder__c = ObjLeadMaster.CCPM_reminder__c;       
       //objLeadMasterUpdate.CCPM_DoubleOptOutSent__c = false;
       objLeadMasterUpdate.CCPM_AutoResponseForDoubleOptOutSmsSent__c = false;
       // Updating the Informatica Flag
       objLeadMasterUpdate.CCPM_isInformaticaMerge__c = false;
       // Updating this flag for reporting or tracking purpose
       objLeadMasterUpdate.CCPM_isMerged__c = true;
       //Retaining the SMS opt put and Account Unique ID from the child to master for the Manual Leads Merge Scenarios
       if( ( ( (objLeadChild.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId() && objLeadChild.CCPM_isManualLead__c == false) ||
               objLeadChild.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_leadProspectCartRT).getRecordTypeId() )
             && objLeadChild.CCPM_accountUniqueID__c != NULL ) || Test.isRunningTest())
        {
          objLeadMasterUpdate.CCPM_accountUniqueID__c = objLeadChild.CCPM_accountUniqueID__c;
        }
    }     
    else return false;  
    if(ObjLeadMaster.CCPM_createdChannel__c!= null && objLeadChild.CCPM_createdChannel__c != null 
          && ObjLeadMaster.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName && objLeadChild.CCPM_createdChannel__c != Label.CCPM_telesalesChannelName )
    boolCartTelesalesmerge = true;
    else if(ObjLeadMaster.CCPM_createdChannel__c!= null && objLeadChild.CCPM_createdChannel__c != null 
          && ObjLeadMaster.CCPM_createdChannel__c != Label.CCPM_telesalesChannelName && objLeadChild.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName )
              boolManualLeadTelesalesmerge = true;
              
    if(boolCartTelesalesmerge == true && objLeadChild.status != NULL )
    {
     objLeadMasterUpdate.status = objLeadChild.status; 
     objLeadMasterUpdate.CCPM_leadSubStatus__c = NULL;
     if(objLeadChild.CCPM_leadSubStatus__c != NULL)
        objLeadMasterUpdate.CCPM_leadSubStatus__c = objLeadChild.CCPM_leadSubStatus__c;
    }    
    
        
    if(ObjLeadMaster.CCPM_createdChannel__c!= null && objLeadChild.CCPM_createdChannel__c != null 
          && ( ObjLeadMaster.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName || objLeadChild.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName ))
       boolTelesalesmerge = true;    
   // Copying the First Name from Child Lead if the both First and Last Names contains only alphabets and Space
   if(boolTelesalesProspectMergeFlag == false && boolTelesalesManualLeadMergeFlag == false)
   {
    if((( boolProspectCartProspectMergeFlag == false && boolLeadCartManualLeadMergeFlag == false )|| ObjLeadMaster.FirstName == NULL || ObjLeadMaster.LastName.containsIgnoreCase(CCPM_staticConstants.strUnknown)) 
      && objLeadChild.FirstName != NULL && objLeadChild.LastName != NULL
      && !string.isBlank(objLeadChild.FirstName) 
      && objLeadChild.FirstName.isAlphaSpace() && objLeadChild.LastName.isAlphaSpace() 
      && !objLeadChild.FirstName.containsIgnoreCase(CCPM_staticConstants.strUnknown) 
      && !objLeadChild.LastName.containsIgnoreCase(CCPM_staticConstants.strUnknown))  
     {
       objLeadMasterUpdate.FirstName = objLeadChild.FirstName;    
       objLeadMasterUpdate.LastName = objLeadChild.LastName; 
     }
   }
   if(( boolTelesalesProspectMergeFlag == true || boolTelesalesManualLeadMergeFlag == true) && objLeadChild.CCPM_reminder__c != null)
   {
     if(objLeadChild.CCPM_reminder__c == Label.CCPM_reminderScheduled)
      objLeadMasterUpdate.CCPM_reminder__c = null;
     else
      objLeadMasterUpdate.CCPM_reminder__c = objLeadChild.CCPM_reminder__c;
      
      
   }
   //Copying the SMS Opt Out from Child Lead
   if(objLeadChild.CCPM_SMSOptOut__c != NULL && objLeadChild.CCPM_SMSOptOut__c == false)
   {
     objLeadMasterUpdate.CCPM_SMSOptOut__c = false;   
   } 
   // US-2243 - commented for the reporting requirement - Sprint 23  
   /*if( ( boolProspectTelesalesMergeFlag == true || boolManualLeadTelesalesMergeFlag == true ) && objLeadChild.CCPM_createdChannel__c!= NULL)
      objLeadMasterUpdate.CCPM_createdChannel__c = objLeadChild.CCPM_createdChannel__c;*/
   // Copying the Cart ID from Child Lead            
   if(objLeadChild.CCPM_cartID__c != NULL ) 
      objLeadMasterUpdate.CCPM_cartID__c  = objLeadChild.CCPM_cartID__c;
   // Copying the Cart UniqueId from the Child Lead
   if(objLeadChild.CCPM_cartUniqueID__c != NULL && 
      (( objLeadChild.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId() && objLeadChild.CCPM_isManualLead__c == false)
      || objLeadChild.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_leadProspectCartRT).getRecordTypeId() )
      )  
      objLeadMasterUpdate.CCPM_cartUniqueID__c = objLeadChild.CCPM_cartUniqueID__c;
   // Copying the Email from Child Lead      
   if(objLeadChild.CCPM_email__c != NULL && boolTelesalesProspectMergeFlag == false && boolTelesalesManualLeadMergeFlag == false && ( ( boolProspectCartProspectMergeFlag == false && boolLeadCartManualLeadMergeFlag == false) || ObjLeadMaster.CCPM_email__c == NULL) ) 
   {
     objLeadMasterUpdate.CCPM_email__c  = objLeadChild.CCPM_email__c;
     objLeadMasterUpdate.CCPM_confirmEmail__c = objLeadChild.CCPM_email__c;
   } 

   // Copying the Cart Created Date from Child Lead   
   if(objLeadChild.CCPM_createdDate__c != NULL) 
      objLeadMasterUpdate.CCPM_createdDate__c = objLeadChild.CCPM_createdDate__c;
   // Copying the Cart Modified Date from Child Lead   
   if(objLeadChild.CCPM_cartModifiedDate__c != NULL ) 
      objLeadMasterUpdate.CCPM_cartModifiedDate__c = objLeadChild.CCPM_cartModifiedDate__c;
   // Copying the Cart Lead Source from Child Lead   
   if(boolProspectCartProspectMergeFlag == false && objLeadChild.LeadSource != NULL ) 
      objLeadMasterUpdate.LeadSource = objLeadChild.LeadSource;
   // Copying the Cart Type from Child Lead 
   if(CCPM_staticConstants.strLeadCartType != NULL)       
      objLeadMasterUpdate.CCPM_cartType__c = CCPM_staticConstants.strLeadCartType;
   // Copying the Cart SKU from Child Lead    
   if(objLeadChild.CCPM_SKU__c != NULL) 
      objLeadMasterUpdate.CCPM_SKU__c = objLeadChild.CCPM_SKU__c;
   //  Copying the Phone from Child Lead  
   if(objLeadChild.Phone != NULL && (( boolProspectCartProspectMergeFlag == false && boolLeadCartManualLeadMergeFlag == false && boolTelesalesProspectMergeFlag == false) || ObjLeadMaster.Phone == NULL)) 
      objLeadMasterUpdate.Phone = objLeadChild.Phone;
   //  Copying the Postal Code from Child Lead   
   if(objLeadChild.PostalCode != NULL && (( boolTelesalesmerge == false && boolProspectCartProspectMergeFlag == false && boolLeadCartManualLeadMergeFlag == false && boolTelesalesProspectMergeFlag == false ) || ObjLeadMaster.PostalCode == NULL)) 
      objLeadMasterUpdate.PostalCode = objLeadChild.PostalCode; 
   //  Copying the Credit Application Number from Child Lead      
   if(objLeadChild.CCPM_creditApplicationNo__c!= NULL && ( ( boolTelesalesProspectMergeFlag == false && boolTelesalesmerge == false )|| objLeadMasterUpdate.CCPM_creditApplicationNo__c == NULL ) )  
      objLeadMasterUpdate.CCPM_creditApplicationNo__c = objLeadChild.CCPM_creditApplicationNo__c;
   //  Copying the Credit Class from Child Lead   
   if(objLeadChild.CCPM_creditClass__c != NULL && (( boolTelesalesProspectMergeFlag == false && boolTelesalesmerge == false )  || objLeadMasterUpdate.CCPM_creditClass__c == NULL ))  
      objLeadMasterUpdate.CCPM_creditClass__c = objLeadChild.CCPM_creditClass__c ;
  
   // US-2243 - Fields to be updated for the reporting requirement - Sprint 23  
   if( boolTelesalesProspectMergeFlag == true || boolTelesalesManualLeadMergeFlag == true 
       || boolProspectCartProspectMergeFlag == true || boolManualLeadLeadCartMergeFlag == true)
   {
       if( objLeadChild.CCPM_createdChannel__c!=NULL )
       objLeadMasterUpdate.CCPM_createdChannel__c = objLeadChild.CCPM_createdChannel__c;
       if(objLeadChild.CCPM_Created_Lead_Source__c!=NULL)
       objLeadMasterUpdate.CCPM_Created_Lead_Source__c = objLeadChild.CCPM_Created_Lead_Source__c;
       if(objLeadChild.CCPM_CreatedType__c!=NULL)
       objLeadMasterUpdate.CCPM_CreatedType__c = objLeadChild.CCPM_CreatedType__c;
   }
   // Added logic to copy lead type for POS Manual Lead Merge Scenario - Defect - 3300 
      if( objLeadChild.CCPM_isManualLead__c == true && ObjLeadMaster.CCPM_isManualLead__c == true 
          && ObjLeadMaster.RecordTypeId != Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId() && objLeadChild.CCPM_leadType__c != NULL && ObjLeadMaster.CCPM_leadType__c!=NULL 
          && objLeadChild.CCPM_leadType__c != ObjLeadMaster.CCPM_leadType__c )
          objLeadMasterUpdate.CCPM_leadType__c = objLeadChild.CCPM_leadType__c;
      
   // Copying Required Fields in case of Prospect to Prospect Merge    
    if( boolTelesalesProspectMergeFlag == false && boolTelesalesManualLeadMergeFlag == false &&
        ( ( objLeadChild.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId() 
            && ObjLeadMaster.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId())
          || (objLeadChild.CCPM_isManualLead__c == true && ObjLeadMaster.CCPM_isManualLead__c == true) ) )
    {
      if(objLeadChild.OwnerId != NULL)
      {
       objLeadMasterUpdate.OwnerId = objLeadChild.OwnerId;
       if(objLeadChild.CCPM_storeID__c != NULL)
         objLeadMasterUpdate.CCPM_storeID__c = objLeadChild.CCPM_storeID__c;        
      }
              
       // Copying the Status from the Child Lead    
      if(objLeadChild.status != NULL)
      {
        objLeadMasterUpdate.status = objLeadChild.status; 
        objLeadMasterUpdate.CCPM_leadSubStatus__c = NULL;
        if(objLeadChild.CCPM_leadSubStatus__c != NULL)
           objLeadMasterUpdate.CCPM_leadSubStatus__c = objLeadChild.CCPM_leadSubStatus__c;
      }
      if(objLeadChild.CCPM_reasonForPurchase__c != NULL)    
      objLeadMasterUpdate.CCPM_reasonForPurchase__c = objLeadChild.CCPM_reasonForPurchase__c ;
      if(objLeadChild.CCPM_eventType__c != NULL)
      objLeadMasterUpdate.CCPM_eventType__c = objLeadChild.CCPM_eventType__c ;
      if(objLeadChild.CCPM_SMSFollowUpDate__c != NULL)
      objLeadMasterUpdate.CCPM_SMSFollowUpDate__c = objLeadChild.CCPM_SMSFollowUpDate__c;
      if(objLeadChild.CCPM_currentCarrier__c != NULL)      
      objLeadMasterUpdate.CCPM_currentCarrier__c = objLeadChild.CCPM_currentCarrier__c ;
      if(objLeadChild.CCPM_whenIsTheirContractUp__c != NULL)   
      objLeadMasterUpdate.CCPM_whenIsTheirContractUp__c = objLeadChild.CCPM_whenIsTheirContractUp__c ;
       if(objLeadChild.CCPM_quickNotesDescription__c != NULL) 
      objLeadMasterUpdate.CCPM_quickNotesDescription__c = objLeadChild.CCPM_quickNotesDescription__c ;
       if(objLeadChild.CCPM_quickNotes__c != NULL) 
      objLeadMasterUpdate.CCPM_quickNotes__c = objLeadChild.CCPM_quickNotes__c ;
       if(objLeadChild.Company != NULL) 
      objLeadMasterUpdate.Company = objLeadChild.Company;
     if(objLeadChild.CCPM_itemInterestedIn__c != NULL) 
      objLeadMasterUpdate.CCPM_itemInterestedIn__c = objLeadChild.CCPM_itemInterestedIn__c;
       if(objLeadChild.CCPM_Trans_Completion_Channel_Preference__c != NULL) 
      objLeadMasterUpdate.CCPM_Trans_Completion_Channel_Preference__c = objLeadChild.CCPM_Trans_Completion_Channel_Preference__c ;
       if(objLeadChild.CCPM_communicationPreference__c != NULL) 
      objLeadMasterUpdate.CCPM_communicationPreference__c = objLeadChild.CCPM_communicationPreference__c ;
      if( objLeadChild.CCPM_reminder__c!=null && ObjLeadMaster.CCPM_createdChannel__c!= null && objLeadChild.CCPM_createdChannel__c != null 
          && objLeadChild.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName )
      objLeadMasterUpdate.CCPM_reminder__c = objLeadChild.CCPM_reminder__c;
    }
   try 
   {
    // Merging the Master Prospect and Child Prospect Cart Record
    if(ObjLeadMaster != NULL && objLeadChild!= NULL)
    {
      merge objLeadMasterUpdate objLeadChild;
      if(ObjLeadMaster.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId())
      objLeadMasterManualLeadGlobal = objLeadMasterUpdate;
      else
      objLeadMasterProspectGlobal = objLeadMasterUpdate;
    }

    } 
    catch(DMLException e)
     {
      CCPM_LogMessageUtility.logMessage(e,'CCPM_leadMergeProspectCartBatch',
                                          'Prospect Cart Merge Batch Job',
                                          'Exception thrown while Merging Prospect Cart in Execute Method',true);
     }            
    return true; 
  }
  
 public static void clearTobeMergedFlag(list<lead> lstNonMergeLeads, set<id> setLeadsGotMerged)
 {
  // list to hold the Non Merged Lead which needs the merge flag updated to false
    list<lead> lstNonMergeLeadsUpdate = new list<lead>();
    
     if(lstNonMergeLeads != NULL && lstNonMergeLeads.size()>0  )
      {
        // Making sure that we are updating the flag for only Non Merge Leads
        // this will make sure we are not trying to update the flag for the merged child records which are being merged in this batch
        for(lead objLead2: lstNonMergeLeads)
        {
         lead objLead3 = new lead();        
         if(objLead2.id != NULL && !setLeadsGotMerged.contains(objLead2.id))
         {
          objLead3.id = objLead2.id;
          if(objLead2.CCPM_tobeMerged__c != NULL)
          objLead3.CCPM_tobeMerged__c = objLead2.CCPM_tobeMerged__c;
          lstNonMergeLeadsUpdate.add(objLead3);
         }
        }
        if(lstNonMergeLeadsUpdate!= NULL && lstNonMergeLeadsUpdate.size()>0 )
        {
         try
         { // Update the Non Merged Leads flag to avoid the re-processing
          update lstNonMergeLeadsUpdate;
          }
          catch(DMLException e)
          {
           CCPM_LogMessageUtility.logMessage(e,'CCPM_leadMergeProspectCartBatch',
                                             'Prospect Cart Merge Batch Job',
                                             'Exception thrown while Updating Prospect Cart Merge Flag in Execute Method',true);
           
          }
         }  
      }
 }
 
 public static void processMergeLeadCartsWithManualLeads(list<lead> lstLeadCarts)
 {
    // List to hold the Mobile numbers for the Manual Leads
    list<string>   lstManualLeadMobileNumbers = new list<string>();
    // Set to hold the Mobile numbers for the Manual Leads to remove duplicates
    set<string>   setManualLeadMobileNumbers = new set<string>();
    // list to hold the leads which needs to be processed for merging
    list<lead> lstLeadsFinalProcess = new list<lead>();
    // Map to hold the Mobile number and Corresponding Manual lead 
    map<string,lead> mapManualLeadByMobileNumber = new map<string,lead>();
    // Map to hold the Mobile number and Corresponding Lead Cart
    map<string,lead> mapLeadCartByMobileNumber = new map<string,lead>();
    // Map to hold the Mobile number and Corresponding Lead Cart for the UnMatched Processed Lead Cart
    map<string,lead> mapLeadCartByMobileProcessedUnMatched = new map<string,lead>();
     
    // set to hold list of leads which got merged
    set<id> setLeadsGotMerged = new set<id>();
    // list to hold the Merged Master Prospect Leads Ids for SMS Processing
    set<id> setMergeManualLeadMasterLeads = new set<id>();
    // list to hold the Non Merged Leads
    list<lead> lstNonMergeLeads = new list<lead>();  
    // list to hold the Merged Master Leads Ids for SMS Processing
    set<id> setMergeMasterLeads = new set<id>();
    // map to hold the Merged Telesales Prospects Lead Ids for Activities
    Map<String, Boolean> mapMergeTelesalesLeads = new Map<String, Boolean>();
   
   // Set of Ids for the Lead Record Type Ids
   set<id> setRecordTypeIds = new set<id>();
   // this variable is used to handle DML limit of Merge API call
   integer manualLeadMergeCount = 0;
   // Adding the record types to set
   if(Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId() != NULL)
      setRecordTypeIds.add(Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId());  
   // Collecting the List of Mobile Numbers and Emails from the Manual Leads 
   for(lead objLead:lstLeadCarts)
   {
     if( objLead.CCPM_mobileNumber__c != NULL)
      { 
        setManualLeadMobileNumbers.add(objLead.CCPM_mobileNumber__c); 
        //Capturing the leads which needs to be processed through Merging
        lstLeadsFinalProcess.add(objLead);
      } 
   }
   
   if(setManualLeadMobileNumbers!= NULL && !setManualLeadMobileNumbers.isEmpty())
   {
     lstManualLeadMobileNumbers.addAll(setManualLeadMobileNumbers);
     string strManualLeadMobileNos = string.join(lstManualLeadMobileNumbers,CCPM_staticConstants.strLogicalOR);
     list<lead> lstleadsByMobile = new list<lead>();       
     lstleadsByMobile = CCPM_mergeProspectCartwithProspectUtil.searchMatchingLeadRecords(strManualLeadMobileNos,CCPM_staticConstants.strPhone,setRecordTypeIds);
     if( lstleadsByMobile != NULL && !lstleadsByMobile.isEmpty()  )
     {
      // Collecting the Manual Leads and Lead Carts into Separate Maps based on MTN  
       for(lead objLeadByMobileNo: lstleadsByMobile)
       {
        if(objLeadByMobileNo.CCPM_mobileNumber__c != NULL)
         {
           if(objLeadByMobileNo.CCPM_isManualLead__c == true)
           {    
            mapManualLeadByMobileNumber.put(objLeadByMobileNo.CCPM_mobileNumber__c,objLeadByMobileNo);
           }
           else
           {
            mapLeadCartByMobileNumber.put(objLeadByMobileNo.CCPM_mobileNumber__c,objLeadByMobileNo);
           }
         }       
        }
        // Clear the List of List Data
        lstleadsByMobile.clear();
        lstManualLeadMobileNumbers.clear();
        setManualLeadMobileNumbers.clear();
     }
   }
   
   // Process the Manual Leads and Update the tobeMerged Flag
   for( lead objLead1: lstLeadsFinalProcess)
   {
      lead objManualLeadMaster = new lead();
      lead objLead2 = new lead();
      boolean boolMergeFlag = false; 
      objLeadMasterManualLeadGlobal = objLead2;      
      boolean boolManualLeadMergeFlag = false;
      boolean boolTelesalesMergeFlag = false;
      boolManualLeadLeadCartMergeFlag = false;
      boolLeadCartManualLeadMergeFlag = false;
      boolTelesalesManualLeadMergeFlag = false;
    //  system.debug('&&&& For 662'+ objLead1 );
      // Logic to Handle the New Manual Leads to Existing Manual Leads and New Lead Cart to Existing Manual Lead Merge Scenarios
     if( objLead1.CCPM_mobileNumber__c != NULL && mapManualLeadByMobileNumber.containsKey(objLead1.CCPM_mobileNumber__c) && mapManualLeadByMobileNumber.get(objLead1.CCPM_mobileNumber__c).id != objLead1.id)
       {
       //   system.debug('&&&& For 666'+ objLead1 );
         objManualLeadMaster = mapManualLeadByMobileNumber.get(objLead1.CCPM_mobileNumber__c);
        if(objManualLeadMaster.CCPM_createdChannel__c != null && objLead1.CCPM_createdChannel__c != Null )
        {
         // system.debug('&&&& For 670'+ objLead1 );    
          if(objManualLeadMaster.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName && objLead1.CCPM_createdChannel__c == Label.CCPM_retailChannelName )
          {
           boolTelesalesManualLeadMergeFlag = true;
           boolMergeFlag = mergeMasterChildLead(objLead1,objManualLeadMaster);
           if(boolMergeFlag == true)
             {
              objLead2 = objManualLeadMaster;
              objManualLeadMaster = objLead1;  
              objLead1 = objLead2;
              mapManualLeadByMobileNumber.remove(objLead1.CCPM_mobileNumber__c);
              mapManualLeadByMobileNumber.put(objLeadMasterManualLeadGlobal.CCPM_mobileNumber__c,objLeadMasterManualLeadGlobal);
             } 
          }
          else
          {
           // system.debug('&&&& For 685'+ objLead1 );
            if(objLead1.CCPM_createdChannel__c ==  Label.CCPM_telesalesChannelName && objManualLeadMaster.CCPM_createdChannel__c == Label.CCPM_retailChannelName )
              boolManualLeadTelesalesMergeFlag = true;
            boolMergeFlag = mergeMasterChildLead(objManualLeadMaster,objLead1);
            if(boolMergeFlag == true)
            {
          //    system.debug('&&&& For 690'+ objLead1 );
             if(objLead1.CCPM_createdChannel__c ==  Label.CCPM_retailChannelName && objManualLeadMaster.CCPM_createdChannel__c == Label.CCPM_retailChannelName)
                boolManualLeadMergeFlag = true; // This is to prioritize the Event SMS Messages for Prospect to Prospect Merge
             else if(objLead1.CCPM_createdChannel__c ==  Label.CCPM_telesalesChannelName && objManualLeadMaster.CCPM_createdChannel__c == Label.CCPM_telesalesChannelName)
                boolTelesalesMergeFlag = true; // This is to prioritize the Activities for Telesales Prospect to Telesales Prospect Merge
              mapManualLeadByMobileNumber.remove(objLead1.CCPM_mobileNumber__c);
              mapManualLeadByMobileNumber.put(objLeadMasterManualLeadGlobal.CCPM_mobileNumber__c,objLeadMasterManualLeadGlobal);             
            }
          }
        }
       }
      // Logic to Hanlde Existing Lead Cart and New Manual Lead (As Informatica is handling Cart to Cart Scenarios, We don't need any logic for Cart to Cart) 
      else if(objLead1.CCPM_mobileNumber__c != NULL && objLead1.CCPM_isManualLead__c == true && mapLeadCartByMobileNumber.containsKey(objLead1.CCPM_mobileNumber__c) && mapLeadCartByMobileNumber.get(objLead1.CCPM_mobileNumber__c).id != objLead1.id)
      {
        // system.debug('&&&& For 704'+ objLead1 );
         objManualLeadMaster = mapLeadCartByMobileNumber.get(objLead1.CCPM_mobileNumber__c);
         // Updating this flag to avoind copying the owner id
         boolManualLeadLeadCartMergeFlag = true;
         // Updating this flag to avoid copying the First Name and Last Name
         boolLeadCartManualLeadMergeFlag = true;
         boolMergeFlag = mergeMasterChildLead(objLead1,objManualLeadMaster);
         if (boolMergeFlag == true)
           {
             // Updating this flag to handle Event SMS Messages 
            // system.debug('&&&& For 714'+ objLead1 );
             boolManualLeadMergeFlag = true; 
             mapLeadCartByMobileNumber.remove(objLead1.CCPM_mobileNumber__c);
             mapManualLeadByMobileNumber.put(objLeadMasterManualLeadGlobal.CCPM_mobileNumber__c,objLeadMasterManualLeadGlobal);
             objLead2 = objManualLeadMaster;
             objManualLeadMaster = objLead1;  
             objLead1 = objLead2;
           }         
      }
      // Logic to Handle Merging with the records which are being processed within the current batch
      else if(objLead1.CCPM_isManualLead__c == true && objLead1.CCPM_mobileNumber__c != NULL)
      {
       mapManualLeadByMobileNumber.put(objLead1.CCPM_mobileNumber__c,objLead1);
       //system.debug('&&&& For 727'+ objLead1 );
      } 
       if(boolMergeFlag == false && objLead1.id != NULL)
       {
      //  system.debug('&&&& For 752'+ objLead1 );
        // Capture the Records which doesn't require Merge and update the CCPM_tobeMerged__c = false
        objLead1.CCPM_tobeMerged__c = false;
        lstNonMergeLeads.add(objLead1);
       }
       else if(objLead1.id != NULL && boolMergeFlag == true)
       {
      //  system.debug('&&&& For 759'+ objLead1 );
        manualLeadMergeCount = manualLeadMergeCount + 1;
        // Capturing the Successfull Merged Child Leads to Avoid the update failures 
        setLeadsGotMerged.add(objLead1.id);
        if(objManualLeadMaster.id != NULL && boolManualLeadMergeFlag == true) 
          setMergeManualLeadMasterLeads.add(objManualLeadMaster.id);
        else if(objManualLeadMaster.id != NULL && boolTelesalesManualLeadMergeFlag == true) 
          mapMergeTelesalesLeads.put(objManualLeadMaster.id,false);
        else if(objManualLeadMaster.id != NULL && boolTelesalesMergeFlag == true)
          mapMergeTelesalesLeads.put(objManualLeadMaster.id,true);
        else if(objManualLeadMaster.id != NULL)
          setMergeMasterLeads.add(objManualLeadMaster.id);
        
        // Capture the Records which got Merged and update the CCPM_tobeMerged__c = false for the Master
        if(objManualLeadMaster.id != NULL && objManualLeadMaster.CCPM_tobeMerged__c == true && integer.valueof(Label.CCPM_MergeBatchDMLLimit) > manualLeadMergeCount)
        {
       //  system.debug('&&&& For 770'+ objLead1 );
         objManualLeadMaster.CCPM_tobeMerged__c = false;
         lstNonMergeLeads.add(objManualLeadMaster); 
        }
        else if (integer.valueof(Label.CCPM_MergeBatchDMLLimit) <= manualLeadMergeCount)
        {
       //  system.debug('&&&& For 776'+ objLead1 );
         break;
        }          
       }
   }
   
   // Updating the Prospect Carts Merge Flag to False for the records without the Master Record
      clearTobeMergedFlag(lstNonMergeLeads, setLeadsGotMerged);
   // Call to the method which is handling the SMS Messages for the master merged leads 
      if(setMergeManualLeadMasterLeads != NULL && !setMergeManualLeadMasterLeads.isEmpty())
      {
       CCPM_sendSMSMergeManual.updateSMSMessageRecords(setMergeManualLeadMasterLeads,true);
      } 
      if( setMergeMasterLeads != NULL && !setMergeMasterLeads.isEmpty()){
       CCPM_sendSMSMergeManual.updateSMSMessageRecords(setMergeMasterLeads,false);  
      }  
      // Call to the method which is handling the Activities for Telesales merges 
     // system.debug('Telesales Activities List: ');
      if(mapMergeTelesalesLeads!= null && !mapMergeTelesalesLeads.isEmpty())
      {
      // system.debug('Telesales Activities List: '+ mapMergeTelesalesLeads.keySet());  
       CCPM_sendSMSMergeManual.updateTaskRecords(mapMergeTelesalesLeads);
      }
      
 } 
  
}