/**
*@name          CCPM_sendSMSMergedLeads
*@author        Brigadesh Chandrasekar (Deloitte)
*@date          07/12/2016
@description    US-533, US-534 , US-535, US-536, US-537, US-538,US 573, US 1697
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                             Date                              Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)    07/07/2017                       Original Version
Brigadesh Chandrasekar(Deloitte)    07/28/2017                       Updated Method: updateSMSMessageRecords
Brigadesh Chandrasekar(Deloitte)    08/04/2017                       Updated Method: updateSMSMessageRecords
Brigadesh Chandrasekar(Deloitte)    08/24/2017                       Updated Method: updateSMSMessageRecords -US 1786,1792,1794,1798,1799
*/ 
public class CCPM_sendSMSMergeManual {
    
    /**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is to return te map of id of the lead as key and value as list of SMS Message Records associated with the lead
@param          Set of Lead Id's
@return         map<id,list<CCPM_SMSMessage__c>> : Map of Lead id as key and list of SMS message Records
*/ 
    public static map<id,list<CCPM_SMSMessage__c>> createMapLeadSMSRelation(set<id> setLeadId)
    {   
        //Instantiating a list of SMS Message Records to store the results of a query
        list<CCPM_SMSMessage__c> lstSMS = new list<CCPM_SMSMessage__c>();
        //Instantiating a map of lead id's as key and SMS message records list as value associated with a particular lead
        map<id,list<CCPM_SMSMessage__c>> mapLeadSMS = new map<id,list<CCPM_SMSMessage__c>>();
        //Query for all SMS records associated with Leads passed in through the batch job, with Message type being Initial/Follow up/Prospect 1st SMS ordered by Schedule Date/TIme in descendinig order
        lstSMS = [select id,CCPM_leadRecord__c, CCPM_MessageStatus__c,CCPM_messageType__c,CCPM_ScheduleDateTime__c from CCPM_SMSMessage__c 
                  where CCPM_leadRecord__c in :setLeadId 
                  and CCPM_leadRecord__c!=null
                  and CCPM_ScheduleDateTime__c!=null
                  and (CCPM_messageType__c =:CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1 
                       or CCPM_messageType__c =: CCPM_staticConstants.strMessageTypeInitialSMSPart1 
                       or CCPM_messageType__c =: CCPM_staticConstants.strMessageTypeFollowUpSMS
                       or CCPM_messageType__c =: CCPM_staticConstants.strMessageTypeAssistantManagers
                       or CCPM_messageType__c =: CCPM_staticConstants.strLeadOwnerSMSOnCustomerResponse
                       or CCPM_messageType__c =: CCPM_staticConstants.strMessageTypeManagers)
                  and (CCPM_MessageStatus__c =: CCPM_staticConstants.strMessageStatusQueued
                       or CCPM_MessageStatus__c =: CCPM_staticConstants.strMessageStatusError) order by createddate desc];
        //Checking if the list has any rows retrieved from the query
        if(lstSMS!=null && lstSMS.size()>0)
        {
            //For Every SMS Message returned from the query made
            for(ccpm_smsmessage__c objSMS : lstSMS)
            {   
                //Checking if the associated Lead record is not null and If there is a SMS related to the lead
                if(objSMS.CCPM_leadRecord__c!=null) 
                {   
                    
                    //Instantiating a new list of SMS Messages to hold new values
                    list<ccpm_smsmessage__c> lstSMSToBeReplaced = new list<ccpm_smsmessage__c>();
                    //Check if there is already an entry in the map for associated lead
                    if (mapLeadSMS.containsKey(objSMS.CCPM_leadRecord__c) && mapLeadSMS.get(objSMS.CCPM_leadRecord__c)!= NULL)
                    {
                        //Get the list of SMS records already attached and add the new value of SMS record
                        lstSMSToBeReplaced = mapLeadSMS.get(objSMS.CCPM_leadRecord__c);
                        lstSMSToBeReplaced.add(objSMS);
                        mapLeadSMS.put(objSMS.CCPM_leadRecord__c, lstSMSToBeReplaced);
                    }
                    else
                    {   
                        //Create a new key, value pair for the new lead id identified
                        lstSMSToBeReplaced.add(objSMS);
                        mapLeadSMS.put(objSMS.CCPM_leadRecord__c,lstSMSToBeReplaced);   
                    }
                    
                }
                
            }
            
        }
        //Returning the Map of Lead id and list of SMS message Records 
        return mapLeadSMS;
        
    }
    
    /**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is to update the status and body of SMS message records associated with the master Lead Record 
@param          Set of Lead Id's, boolean flag to determine which SMS gets preference : Initial SMS/Prospect 1st SMS
@return         void
*/ 
    
    public static void updateSMSMessageRecords(set<id> setLeadId, boolean boolTrueIfEventSMS)
    {   
        //Instantiating a map of lead Id and List of SMS messages
        map<id,list<CCPM_SMSMessage__c>> mapSMSMessages = new map<id,list<CCPM_SMSMessage__c>>();
        //Making a callout to the method that returns map of Lead ID and associated SMS records
        mapSMSMessages= createMapLeadSMSRelation(setLeadId);
        //Instantiating a map of SMS messages records with its ID as key for Bulk Update
        map<id,CCPM_SMSMessage__c> mapSMSToUpdate = new map<id,CCPM_SMSMessage__c>();
        //Get the map of leads details to assign the updated Initial SMS body for SMS Message records after merge 
        map<id,Lead> mapLeadRecordDetails = new map<id,lead>([select id,recordtypeid,CCPM_SMSOptOut__c,CCPM_prospectSMSBody__c,CCPM_manualLeadSMSBody__c,CCPM_initialSMSBody__c,CCPM_Type__c,CCPM_prospectInitialSMSBody__c,CCPM_ProspectFollowUpSMSBody__c,CCPM_followupMessageBody__c from lead 
                                                              where id in :setLeadId]);
        //Checking if the map is empty
        if(mapSMSMessages!=null && mapSMSMessages.isEmpty()==false)
        {   
            //For every Lead id in setLeadID passed through the batch
            for(id idLeadID : setLeadId)
            {   
                //Setting the flag to 0 for each lead
                integer flag =0;
                //Instantiating a list of SMS message records to store the SMS records associated with a specific lead
                list<CCPM_SMSMessage__c> lstSMSMessageAssociatedLead = new list<CCPM_SMSMessage__c>();
                //Get the List of SMS message records associated with a specific Lead
                lstSMSMessageAssociatedLead = mapSMSMessages.get(idLeadID);
                //Checking if there is atleast 1 SMS message associated with the lead
                if(lstSMSMessageAssociatedLead!=null && lstSMSMessageAssociatedLead.size()>0)
                {   
                    if(!boolTrueIfEventSMS)
                    {
                        //Instantiating a list of SMS message records to store only those SMS messages which are of type Initial SMS(Not Required)
                        //list<CCPM_SMSMessage__c> lstInitialSMS = new list<CCPM_SMSMessage__c>();
                        //For every message in the list
                        for(ccpm_smsmessage__c objSMS : lstSMSMessageAssociatedLead)
                        {   //If the SMS type is Initial SMS then push it to the list created initially
                            //Have not used contains key as the SMS records are queried based on the set of lead ids passed into the method.
                            //This code has been developed with an understanding and assumption that Informatica team handles cart to cart merge scenarios for SMS.
                            if(objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeInitialSMSPart1 && flag==0 && mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c)!= NULL && mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_SMSOptOut__c == false)
                            {   
                                if(mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).recordtypeid == CCPM_staticConstants.strProspectRecordTypeID)
                                {
                                    objSMS.CCPM_message__c = mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_prospectInitialSMSBody__c;
                                }
                                else if(mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).recordtypeid == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID)
                                {
                                    objSMS.CCPM_message__c = mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_initialSMSBody__c;
                                }
                               
                                flag=1;
                            }
                            //If the SMS type is Follow-Up SMS then push it to the list created initially
                            else if(objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeFollowUpSMS && flag==0 && mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c)!= NULL && mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_SMSOptOut__c == false)
                            {   
                                if(mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).recordtypeid == CCPM_staticConstants.strProspectRecordTypeID)
                                {
                                    objSMS.CCPM_message__c = mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_ProspectFollowUpSMSBody__c;
                                }
                                else if(mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).recordtypeid == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID)
                                {
                                    objSMS.CCPM_message__c = mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_followupMessageBody__c;
                                }
                                
                                flag=1;   
                            }
                            else
                            {
                                objSMS.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                            }
                            
                            //Add the SMS to the map for Bulk Update
                            mapSMSToUpdate.put(objSMS.id,objSMS); 
                        }
                    }
                    
                    else{
                        for(ccpm_smsmessage__c objSMS : lstSMSMessageAssociatedLead)
                        {   //If the SMS type is Initial SMS then push it to the list created initially
                            //Have not used contains key as the SMS records are queried based on the set of lead ids passed into the method.
                            //This code has been developed with an understanding and assumption that Informatica team handles cart to cart merge scenarios for SMS.
                            if(objSMS.CCPM_messageType__c == CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1  && flag==0 && mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c)!= NULL && mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_SMSOptOut__c == false)
                            {   
                                if(mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).recordtypeid == CCPM_staticConstants.strProspectRecordTypeID)
                                {
                                    objSMS.CCPM_message__c = mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_prospectSMSBody__c;
                                }
                                else if(mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).recordtypeid == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID)
                                {
                                    objSMS.CCPM_message__c = mapLeadRecordDetails.get(objSMS.CCPM_leadRecord__c).CCPM_manualLeadSMSBody__c;
                                }
                                
                                flag=1;
                            }
                            else
                            {
                                objSMS.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                            }
                            
                            //Add the SMS to the map for Bulk Update
                            mapSMSToUpdate.put(objSMS.id,objSMS); 
                        }
                        
                    }
                    
                }
                
            }
            //Check if the SMS to Update map is not empty
            if(mapSMSToUpdate!=null && mapSMSToUpdate.isEmpty() == false)
            {   //Make a callout to the method to Update the SMS records
                updateSMSRecords(mapSMSToUpdate);
            }
        }
        
    }
    
    
     
    
    /**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is to update SMS Records after procecssing
@param          Map of SMS Message records
@return         void
*/ 
    Public static void updateSMSRecords(map<id,CCPM_SMSMessage__c> mapSMSMessageRecordsToUpdate)
    {
        try
        {   
            //Check if the SMS to Update map is not empty
            if(mapSMSMessageRecordsToUpdate!=null && mapSMSMessageRecordsToUpdate.isEmpty() == false)
            {   
             //DML statement to update the SMS records pushed into the map
              update mapSMSMessageRecordsToUpdate.values();
            }
        }
        
        catch(Exception e){
            //Log it in the Log error object
            CCPM_LogMessageUtility.logMessage(e,'CCPM_sendSMSMergedLeads','Updating SMS Message Records after Merging Prospect Prospect Cart','Exception thrown while trying to update SMS Message Records after Merge',true); 
        }
    }
    
/**
@author         Bharath Ammanamanchi (Deloitte)
@description    This method is to update Activities after the Telesales merge
@param          Map of Lead Ids and Boolean 
@return         void
*/     
    
    public static void updateTaskRecords(Map<String, Boolean> mapLeadIdProcessType){
        List<Task> lstTaskToUpdate = new List<Task>();
        Set<String> setTaskOpenStatus = CCPM_utility.getSetFromString(Label.CCPM_telesalesTaskStatus, ',');
        
        if(CCPM_Collection.isNotNullEmpty(mapLeadIdProcessType)){
            for(Lead objlead : [Select id, (Select id, Status from Tasks WHERE RecordType.Name =:Label.CCPM_taskToDoRT and Status IN:setTaskOpenStatus Order By CreatedDate DESC) 
                                FROM Lead where id IN:mapLeadIdProcessType.keySet()]){                  
                if(mapLeadIdProcessType.containsKey(objlead.Id)){
                    List<Task> lstTask = new List<Task>();
                    if(CCPM_Collection.isNotNullEmpty(objlead.Tasks)){
                        Boolean boolisFirstRecSkipped = false;
                        for(Task objTask : objlead.Tasks){                                
                            if(mapLeadIdProcessType.get(objlead.Id) == true && boolisFirstRecSkipped == false){
                                boolisFirstRecSkipped = true;
                                continue;
                            }
                            objTask.Status = Label.CCPM_taskCancelled;
                            lstTaskToUpdate.add(objTask);
                        }  
                    } 
                }
            }
        }
        if(CCPM_Collection.isNotNullEmpty(lstTaskToUpdate)){
            try{
                update lstTaskToUpdate; 
            }
            catch(Exception e){
                //Log it in the Log error object
                CCPM_LogMessageUtility.logMessage(e,'CCPM_sendSMSMergedLeads','CCPM_sendSMSMergedLeads','Exception thrown while trying to update Task records after Merge',true); 
            }
            
        }
    }
    
}