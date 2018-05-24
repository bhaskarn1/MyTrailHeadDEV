/**
*@name          CCPM_sendMessageUsingApex
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          02/01/2017
@description    The apex class to be Used for process builder sending SMS
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                        Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)     	02/01/2017					Original Version
Brigadesh Chandrasekar(Deloitte)     	02/02/2017                 	Created Seperate methods for readability
Deepak Mazumdar(Deloitte)				02/09/2017					Code review, variable naming changed to align with dev standards	
Sriraman Sridharan													Customer Response
Brigadesh Chandrasekar(Deloitte)     	03/23/2017                 	Created Seperate method for Sending SMS to Managers and Store Managers
Brigadesh Chandrasekar(Deloitte)     	04/02/2017                 	Created Seperate method for Sending SMS to Task Owners
Brigadesh Chandrasekar(Deloitte)     	05/04/2017                 	Created Seperate method for Sending SMS to Prospect Walk in
Sriraman Sridharan						06/22/2017                  TKT-000304 - Customer Response	- Changed SMS Body for Prospect and Prospect Cart	
keshava manjunath(Deloitte)             08/07/2017                  TKT-00392  -   Customer Response sms not sent to Managers  
Dheeraj R Shetty(Deloitte)              08/15/2017                  US-1625 - Changes for Messaging Store Employees - Action Required Lead during next open store operating hours
*/

global class CCPM_sendMessageUsingApex {
    
    /* Variable Declarations */
    // create instance of global settings custom settings
    public static CCPM_globalSetting__c gs					= CCPM_globalSetting__c.getInstance();
    
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This Class is targeted to create parameters for the Apex class to be used in the 
process builder to send SMS
*/  
    global class setVariablesRequiredtoSendSMSforApex
    {
        @InvocableVariable(Label='Message Type' Description='Mention if it is FollowUp/InitialSMS/ProcessCustomerResponse' Required=true)
        public String StrMessageType;
        
        @invocableVariable(Label='Lead Record' Description='Enter the Lead Record that started the process' Required=false)
        public lead Leads;
        @invocableVariable(Label='ITR Record' Description='Enter the ITR Record that started the process' Required=false)
        public LiveText__ITR_Message__c ITRRecord;
        
        @invocableVariable(Label='ScheduleDate' Description='Enter the date/time for scheduling' Required=false)
        public datetime dttScheduledate;
        
        @invocableVariable(Label='Task Record' Description='Provide the associated Lead ID' Required=false)
        public task Tasks;
        
        @InvocableVariable(Label='Lead Record Type' Description='Mention the rcord type of the lead' Required=false)
        public String StrRecordType;
    }
    
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is made invocable so that we can use this method in the process builder to create required SMS
@param         List<setVariablesRequiredtoSendSMSforApex>
@return        Void(None)
*/ 
  /*  @invocableMethod(Label='SendMessageViaApex' Description='Send Message to associated Lead via Apex')
    public static void SendMessageViaApex(List<setVariablesRequiredtoSendSMSforApex> lstVRA)
    {    
        list<CCPM_storeEmployee__c> lstManagers = new list<CCPM_storeEmployee__c>();
        list<task> lstCreateTaskCustomerResponse	= new list<task>();
        list<User> lstUsers = new list<User>();
        set<id> setLeadStoreID=new set<id>();
        set<id> setUserID=new set<id>();
        map<id,list<CCPM_storeEmployee__c>> mapManagersContact=new map<id,list<CCPM_storeEmployee__c>>();
        map<id,User> mapOwnerFirstname;
        map<id,User> mapTaskOwner;
        map<id,Lead> mapLeads;
        set<id> setLeadID=new set<id>();
        List<LiveText.ScheduleItem> lstSMIall		= new List<LiveText.ScheduleItem>();
        List<CCPM_SMSMessage__c> lstSMSMessages 	=new List<CCPM_SMSMessage__c>();
        List<Lead> lstleadsforBusinessHour 			= new List<Lead>();
        List<BusinessHours> objBusinessHours = CCPM_LeadHandler.getBusinessHours();
        Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
        Boolean boolBusinessHoursFlag = true;
        
        BusinessHours objDefaultBusinessHours;
        for(Integer i=0; i<objBusinessHours.size();i++)
        {
            if(objBusinessHours[i].IsDefault)
            {
                objDefaultBusinessHours = objBusinessHours[i];
                break;
            }
        }
        
        for(setVariablesRequiredtoSendSMSforApex v : lstVRA )
        {
            System.debug('Inside SetVariable instance->');
            if(v.leads!=null)
            {	
                System.debug('v.Leads-> '+v.leads);
                setLeadStoreID.add(v.leads.store__c);
                setUserID.add(v.leads.OwnerId);  
                lstleadsforBusinessHour.add(v.leads);
            }
            if(v.tasks!=null && v.tasks.WhoId!=null)
            {
                System.debug('v.tasks-> '+v.tasks);
                setLeadID.add(v.tasks.WhoId);
                System.debug('# Lead Id associate with task : '+v.tasks.WhoId);
                System.debug('# SetVariables in current context: '+v);
                
            }
            
        }
        
        //Querying for the list of Managers/Assistant Managers to Send SMS
        if(setLeadStoreID!=null && setLeadStoreID.size()>0)
        {
            lstManagers=[select CCPM_employee__c,CCPM_employee__r.firstname,CCPM_store__r.id,CCPM_employee__r.MobilePhone,CCPM_role__c from CCPM_storeEmployee__c where (CCPM_role__c='Store Manager' or CCPM_role__c='Assistant Manager') and CCPM_store__r.id in :setLeadStoreID and CCPM_IsActive__c = true];
        }
        if(setUserID!=null && setUserID.size()>0)
        {
            mapOwnerFirstname=new map<id,User>([select firstname,lastname,mobilephone from user where id in :setUserID]);
        }
        //Querying to get the Lead records for SMS to Task Owners
        //Populating setUserId for SMS to task owner as Lead id is passed instead of lead Record
        if(setLeadID!=null && setLeadID.size()>0)
        {
            mapLeads=new map<id,lead>([select ownerid,owner.isactive,lastname from lead where id in :setLeadID]);
            for(setVariablesRequiredtoSendSMSforApex v : lstVRA )
            {
                setUserID.add(mapLeads.get(v.tasks.WhoId).ownerid);   
            }
            //Creating Map of Owner firstname and mobilephone from setUserId
            mapTaskOwner=new map<id,User>([select firstname,mobilephone from user where id in :setUserID]);
            System.debug('# SetUserId->: ' +setUserID+' Size'+setUserID.size());
            System.debug('# MapTaskOwner->: ' +mapTaskOwner+' Size'+maptaskowner.size());
        }
        
        //Iterating over each instance created through the Process Builder
        for( setVariablesRequiredtoSendSMSforApex v : lstVRA )
        {   
            //Checking if the type of message to be sent is Initial SMS
            if( v.StrMessageType == CCPM_staticConstants.strMessageTypeInitialSMSPart1 
               || v.StrMessageType == CCPM_staticConstants.strMessageTypeInitialSMSPart2 )
            {   
                //calling out to the private method of the class to create "Schedule Item" instance for scheduling Initial SMS
                lstSMIall.add(InitialSMS(v.Leads,v.StrMessageType,v.dttScheduledate));
            }
            //Checking if the type of Message to be sent is Prospect 1st SMS
            else if(v.StrMessageType == CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1 
                    || v.StrMessageType == CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2 )
            {    //Calling out to the method of the class to create "Schedule Item" instance for scheduling Prospect 1st SMS
                lstSMIall.add(newProspectSMS(v.Leads,v.StrMessageType,v.dttScheduledate));
            }
            
            //Checking if the type of message to be sent is FollowUp SMS
            else if( v.StrMessageType == CCPM_staticConstants.strMessageTypeFollowUpSMS )
            {   //calling out to the private method of the class to create "Schedule Item" instance for scheduling Initial SMS/FollowUpSMS
                lstSMIall.add(FollowUpSMS(v.Leads,v.dttScheduledate));
            }
            
            //Checking if the type of message to be sent is Process Customer Response SMS
            else if( v.StrMessageType == CCPM_staticConstants.strMessageTypeProcessCustomerResponse)
            {   
                System.debug('Inside Process Customer response->');
                if(lstManagers.size()>0 && !(v.leads.CCPM_SMSOptOut__c) && v.ITRRecord.LiveText__Message__c!=CCPM_staticConstants.strFirstCustomerResponseForOptOut 
                   && v.ITRRecord.LiveText__Message__c!=CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall && v.ITRRecord.LiveText__Message__c!=CCPM_staticConstants.strFirstCustomerResponseForOptOutQuote
                   && lstManagers!=Null && v.ITRRecord.LiveText__Message__c!=CCPM_staticConstants.strCustomerResponseForOptOut && v.ITRRecord.LiveText__Message__c!=CCPM_staticConstants.strCustomerResponseForOptOutSmall
                   && v.ITRRecord.LiveText__Message__c!=CCPM_staticConstants.strCustomerResponseForOptOutQuote)
                {
                    list<CCPM_storeEmployee__c> lstAddmanagersToAssociatedStoreIds= new list<CCPM_storeEmployee__c>();
                    for(CCPM_storeEmployee__c m:lstManagers)
                    {
                        if(m.CCPM_store__r.id==v.leads.store__c)
                        {
                            lstAddmanagersToAssociatedStoreIds.add(m);
                        }
                    }
                    mapManagersContact.put(v.leads.store__c,lstAddmanagersToAssociatedStoreIds); 
                }
                //calling out to the private method of the class to create "Schedule Item" instance for Process Customer Response SMS
                //!v.Leads.CCPM_isManualLead__c && 
                If(v.Leads.RecordTypeId == ccpm_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && (!v.Leads.CCPM_isSMSResponseReceived__c || !v.Leads.CCPM_isFollowUpSMSSent__c)
                   && (v.ITRRecord.LiveText__Message__c==CCPM_staticConstants.strFirstCustomerResponseForOptOut || v.ITRRecord.LiveText__Message__c==CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall || v.ITRRecord.LiveText__Message__c==CCPM_staticConstants.strFirstCustomerResponseForOptOutQuote)){
                       lstSMIall.add(CustomerResponseForDoubleOptOut(v.ITRRecord,v.Leads));
                   }
                else{
                    lstSMIall.add(CustomerResponseSMS(v.ITRRecord,v.Leads));
                }
                //calling out to the private method of the class to create "Schedule Item" instance for Sending SMS to Managers
                if(mapManagersContact != null && mapManagersContact.size()>0 )
                {
                    if(v.leads.store__c != null && mapManagersContact.containsKey(v.leads.store__c) && mapManagersContact.get(v.leads.store__c).size()>0 )
                    {
                        BusinessHours objBusinessHoursStore = new BusinessHours();
                        if(boolBusinessHoursFlag == true)
                        {    
                            mapLeadAndBusinessHours = CCPM_leadHandler.getCartIdORStoreIDAndBusinessHourMap(lstleadsforBusinessHour,objDefaultBusinessHours,objBusinessHours);
                            boolBusinessHoursFlag = false;
                        }
                        if(mapLeadAndBusinessHours != null && mapLeadAndBusinessHours.containsKey(v.leads.store__c))
                        {
                            objBusinessHoursStore = mapLeadAndBusinessHours.get(v.leads.store__c);
                        }
                        else if(mapLeadAndBusinessHours != null && v.leads.CCPM_cartID__c !=null && mapLeadAndBusinessHours.containsKey(v.leads.CCPM_cartID__c))
                        {
                            objBusinessHoursStore = mapLeadAndBusinessHours.get(v.leads.CCPM_cartID__c);
                        }
                        else
                        {
                            objBusinessHoursStore = objDefaultBusinessHours;
                        }
                        DateTime datTBusinessTime = CCPM_leadHandler.calculateTimeToTriggerSMSWithInBusinessHours(objBusinessHoursStore, System.now());
                        
                        for(CCPM_storeEmployee__c SE : mapManagersContact.get(v.leads.store__c) )
                        {
                            CCPM_SMSMessage__c objSmsManager = new CCPM_SMSMessage__c();
                            if(v.Leads.OwnerId!=SE.CCPM_employee__c )
                            {
                                objSmsManager=SendSMSToManagers(v.ITRRecord,v.Leads,SE,mapOwnerFirstname,datTBusinessTime);
                                if( objSmsManager!=null)
                                {
                                    lstSMSMessages.add(objSmsManager);
                                }
                            }      
                        }
                    }
                }
                
                //Creating Tasks : To-do and Interaction History Tasks once response is received from customer
                Task objTask =createToDoTaskforCustomerResponse(v.Leads,v.ITRRecord);
                if(objTask!=null)
                {
                    lstCreateTaskCustomerResponse.add(objTask);
                }
                //lstCreateTaskCustomerResponse.add(createToDoTaskforCustomerResponse(v.Leads,v.ITRRecord));
                lstCreateTaskCustomerResponse.add(createInteractionTaskforCustomerResponse(v.Leads,v.ITRRecord));
            }
            
            //Checking if the type of message to be sent is ProspectActionRequired
            else if(v.StrMessageType == CCPM_staticConstants.strMessageTypeProspectActionRequired)
            {
                system.debug('Inside prospectActionRequired');
                if(lstManagers.size()>0 && lstManagers!=Null)
                {
                    list<CCPM_storeEmployee__c> lstAddmanagersToAssociatedStoreIds= new list<CCPM_storeEmployee__c>();
                    for(CCPM_storeEmployee__c m:lstManagers)
                    {
                        
                        if(m.CCPM_store__r.id==v.leads.store__c)
                        {
                            lstAddmanagersToAssociatedStoreIds.add(m);
                        }
                        
                    }
                    mapManagersContact.put(v.leads.store__c,lstAddmanagersToAssociatedStoreIds); 
                }
                //calling out to the private method of the class to create "Schedule Item" instance for Sending SMS to Managers
                if(mapManagersContact.size()>0 && mapManagersContact != null){
                    if(mapManagersContact.get(v.leads.store__c).size()>0)
                    {
                        for(CCPM_storeEmployee__c SE : mapManagersContact.get(v.leads.store__c) )
                        {
                            if(v.Leads.OwnerId!=SE.CCPM_employee__c)
                            {
                                lstSMIall.add(sendLeadOrProspectActionRequiredSMS(v.Leads,v.StrRecordType, SE,mapOwnerFirstname));
                            }
                        }
                        
                    }
                }
                
            }
            
            else if(v.StrMessageType==CCPM_staticConstants.strMessageTypeTaskOwnerSMS)
            {	
                //Check if TaskOwner Mobile is not Null
                system.debug('the output debug is'+mapLeads.get(v.tasks.WhoId).ownerid);
                if(mapTaskOwner.get(mapLeads.get(v.tasks.WhoId).ownerid).mobilephone!=null && v.tasks.Status!='Completed')
                {
                    System.debug('# Sending SMS to Task Owner->: '+v.tasks.WhoId+' Tasks '+v.tasks.Id+' Tasks Subject '+v.tasks.Subject);
                    //Send SMS To Task Owner
                    lstSMIall.add(sendSMSToTaskOwner(v.tasks.WhoId,mapTaskOwner,mapLeads));
                }
                
            }
        }
        
        system.debug('# List of SMSes scheduled : ' + lstSMIall);
        //Scheduling the list of SMS "Schedule Items" to be actually sent to the Customer
        livetext.ScheduleMessageAction.scheduleMessages(lstSMIall);  
        
        try
        {
            //Inserting the set of tasks created after receiving Customer Response(Bulk Insert)
            if( lstCreateTaskCustomerResponse.size() > 0 && lstCreateTaskCustomerResponse != null )
            {
                System.debug('Insert Task->');
                insert lstCreateTaskCustomerResponse;
            }
        }
        catch(Exception e)
        {
            //Logging Exception in case of DML Exception
            CCPM_LogMessageUtility.logMessage(e,'CCPM_processBuilderThroughApex','CreateMessage','Exception thrown while inserting task and Updating Interaction History',true);  
        }
        
        try
        {
            //Inserting the set of tasks created after receiving Customer Response(Bulk Insert)
            if( lstSMSMessages.size() > 0 && lstSMSMessages != null )
            {
                System.debug('Insert SMSMessages for Managers/AssistantManagers->');
                insert lstSMSMessages;
            }
        }
        catch(Exception e)
        {
            //Logging Exception in case of DML Exception
            CCPM_LogMessageUtility.logMessage(e,'CCPM_processBuilderThroughApex','CreateMessage','Exception thrown while inserting SMSMessages records for AM and Managers',true);  
        }
        
    }
    */
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This private method is used to compose and add Initial SMS to "Schedule Items"
@param         Lead Record
@return        List<LiveText.ScheduleItem>
*/ 
 /*   @TestVisible 
    private static LiveText.ScheduleItem InitialSMS(lead objlead,String strMessageType,datetime dtmSchDate)
    {
        system.debug('$ InitialSMS called --> strMessageType : ' + strMessageType);
        if(objlead.CCPM_mobileNumber__c!=null)
        {
            // instance of livetext schedule item
            LiveText.ScheduleItem objSI	= new LiveText.ScheduleItem();
            //Setting the Object ID to the lead Id
            objSI.ObjectId				= objlead.Id;
            
            // check if schedule date time is passed
            If( dtmSchDate != Null)
            {
                objSI.ScheduleDate = dtmSchDate;
            }
            
            //Composing and scheduling initial SMS body part 1
            if( strMessageType == CCPM_staticConstants.strMessageTypeInitialSMSPart1 )
            {
                system.debug('# Inside InitialMessagePartI');
                
                objSI.Message		= objlead.CCPM_initialMessageBodyPartI__c;
                //Setting reference string for Initial SMS
                objSI.ReferenceId	= CCPM_staticConstants.strReferenceInitialSMS + '-' + objlead.Id; 
                
                objSI.ToPhoneNumber	= objlead.CCPM_mobileNumber__c;
            }
            //Composing and scheduling initial SMS body part 2
            else if( strMessageType == CCPM_staticConstants.strMessageTypeInitialSMSPart2 ) {
                system.debug('# Inside InitialMessagePartII');
                
                objSI.Message		= objlead.CCPM_initialMessageBodyPartII__c;
                objSI.ReferenceId	= CCPM_staticConstants.strMessageTypeInitialSMSPart2 + '-' + objlead.Id; 
                objSI.ToPhoneNumber	= objlead.CCPM_mobileNumber__c;
            }
            
            //Setting the Customer Mobile Number to whom the message shall be sent
            
            //Setting the Live Text Number from which the message is to be sent
            objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
            return objSI; 
        }
        else{
            return null;
        }
        
    }
    */
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This private method is used to compose and add Follow-Up SMS to "Schedule Items"
@param         Lead Record, DateTime to ScheduleMessage
@return        LiveText.ScheduleItem
*/  
  /*  @TestVisible
    public static LiveText.ScheduleItem FollowUpSMS(lead objlead, datetime dtmSchDate)
    {   
        if(objlead.CCPM_mobileNumber__c!=null)
        {
            // instance of schecudel item
            LiveText.ScheduleItem objSI	= new LiveText.ScheduleItem();
            //Setting the Object ID to the lead Id
            objSI.ObjectId				= objlead.Id;
            
            // set the date/time whem message is scheduled to be sent
            If( dtmSchDate != null)
            {
                objSI.ScheduleDate	= dtmSchDate;
            }
            
            //Setting Reference String and body for FollowUp SMS
            objSI.ReferenceId		= CCPM_staticConstants.strReferenceFollowUpSMS + '-' + objlead.Id;
            objSI.Message			= objlead.CCPM_followupMessageBody__c; 
            
            //Setting the Customer Mobile Number to whom the message shall be sent
            objSI.ToPhoneNumber	= objlead.CCPM_mobileNumber__c;
            
            //Setting the Live Text Number from which the message is to be sent
            objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
            
            return objSI; 
        }
        else{
            return null;
        }
        
    }
    */
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This method is used to compose and add Prospect 1st SMS to "Schedule Items"
@param         Lead Record, DateTime to ScheduleMessage
@return        LiveText.ScheduleItem
*/   
  /*  @TestVisible
    public static LiveText.ScheduleItem newProspectSMS(lead objlead,string strMessageType, datetime dtmSchDate)
    {   
        if(objlead.CCPM_mobileNumber__c!=null)
        {
            // instance of schecudel item
            LiveText.ScheduleItem objSI	= new LiveText.ScheduleItem();
            //Setting the Object ID to the lead Id
            objSI.ObjectId				= objlead.Id;
            
            // set the date/time whem message is scheduled to be sent
            If( dtmSchDate != null)
            {
                objSI.ScheduleDate	= dtmSchDate;
            }
            if(strMessageType==CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1)
            {	//Set the Reference ID and Message body depending on which part of the SMS is being scheduled
                objSI.ReferenceId		= CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1 + '-' + objlead.Id;
                objSI.Message			= objlead.CCPM_prospectSMSBodyPartI__c; 
            }
            else if(strMessageType==CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2)
            {   //Set the Reference ID and Message body depending on which part of the SMS is being scheduled
                objSI.ReferenceId		= CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2 + '-' + objlead.Id;
                objSI.Message			= objlead.CCPM_prospectSMSBodyPartII__c; 
                
            }
            
            //Setting the Customer Mobile Number to whom the message shall be sent
            objSI.ToPhoneNumber	= objlead.CCPM_mobileNumber__c;
            
            //Setting the Live Text Number from which the message is to be sent
            objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
            
            return objSI; 
        }
        else{
            return null;
        }
        
    } */
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This private method is used to compose and add Process Customer Response SMS to "Schedule Items"
@param         Lead Record, ITR Record created after receiving a response from Customer
@return        LiveText.ScheduleItem
*/  
  /*  @TestVisible
    private static LiveText.ScheduleItem CustomerResponseSMS(LiveText__ITR_Message__c ITR,lead objlead)
    {
        // instance of livetext schedule item
        LiveText.ScheduleItem objSI	= new LiveText.ScheduleItem(); 
        //Setting the Object Id to Lead ID
        objSI.ObjectId			= objlead.Id;
        //Setting the reference string for Process Customer Response
        objSI.ReferenceId		= CCPM_staticConstants.strReferenceProcessCustomerResponse; 
        //Setting the SMS body
        if((objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || objlead.RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID) && 
           (ITR.LiveText__Message__c==CCPM_staticConstants.strFirstCustomerResponseForOptOut || ITR.LiveText__Message__c==CCPM_staticConstants.strFirstCustomerResponseForOptOutSmall
            || ITR.LiveText__Message__c==CCPM_staticConstants.strFirstCustomerResponseForOptOutQuote) ){
                objSI.Message			= objlead.CCPM_CustomerResponseMsgBodyforProsp__c;
            }
        else if(objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || objlead.RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID){
            objSI.Message			= objlead.CCPM_SMSResponseBodyForProspect__c;
        }
        else if((objlead.RecordTypeId == ccpm_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && 
                 (ITR.LiveText__Message__c==CCPM_staticConstants.strCustomerResponseForOptOut || ITR.LiveText__Message__c==CCPM_staticConstants.strCustomerResponseForOptOutSmall
                  || ITR.LiveText__Message__c==CCPM_staticConstants.strCustomerResponseForOptOutQuote))){
                      objSI.Message			= objlead.CCPM_CustomerResponseMessageBody__c;
                  }
        else{
            objSI.Message			= objlead.CCPM_SMSResponseBody__c;
        }
        //Setting the customer number to whom the message shall be sent
        objSI.ToPhoneNumber		= ITR.LiveText__Originating_Number__c;
        //Setting the Live Text Number from which the message is to be sent
        if(objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID ||objlead.RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID)
        {
            objSI.LiveTextNumber	= gs.CCPM_liveTextNumberNonVerizon__c;
        }
        else
        {
            objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
        }
        //objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
        return objSI; 
    }  */  /**
@author        Sriraman Sridharan (Deloitte)
@description   This private method is used to compose and add Process Customer Response SMS for DoubleOptOut
@param         Lead Record, ITR Record created after receiving a response from Customer
@modification  making the private class visible to test classes
@return        LiveText.ScheduleItem
*/   
 /*   @TestVisible
    private static LiveText.ScheduleItem CustomerResponseForDoubleOptOut(LiveText__ITR_Message__c ITR,lead objlead)
    {
        // instance of livetext schedule item
        LiveText.ScheduleItem objSI	= new LiveText.ScheduleItem(); 
        //Setting the Object Id to Lead ID
        objSI.ObjectId			= objlead.Id;
        //Setting the reference string for Process Customer Response
        objSI.ReferenceId		= CCPM_staticConstants.strReferenceProcessCustomerResponse; 
        //Setting the SMS body
        if(objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID || objlead.RecordTypeId==ccpm_staticConstants.strProspectAbandonedCartRecordTypeID){
            objSI.Message			= objlead.CCPM_SMSResponseBodyForProspect__c;
        }
        else{
            objSI.Message			= objlead.CCPM_DoubleOptOutSmsBody__c;
        }
        //Setting the customer number to whom the message shall be sent
        objSI.ToPhoneNumber		= ITR.LiveText__Originating_Number__c;
        //Setting the Live Text Number from which the message is to be sent
        if(objlead.RecordTypeId==ccpm_staticConstants.strProspectRecordTypeID)
        {
            objSI.LiveTextNumber	= gs.CCPM_liveTextNumberNonVerizon__c;
        }
        else
        {
            objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
        }
        //objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
        return objSI; 
    }   
    */
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This private method is used to compose and add Managers SMS to SMSMessages Object
@param         Lead Record, ITR Record created after receiving a response from Customer,Manager Details, Map of users containing id and Firstname
@return        CCPM_SMSMessage__c
*/  
 /*   @TestVisible 
    private static CCPM_SMSMessage__c SendSMSToManagers (LiveText__ITR_Message__c ITR,lead objlead,CCPM_storeEmployee__c ObjManagerAssistantManager,map<id,User> mapOwnerFirstname, DateTime datTWithinBusinessHours)
    {	
        if(ObjManagerAssistantManager.CCPM_employee__r.MobilePhone!=null && mapOwnerFirstname!=null && mapOwnerFirstname.isEmpty()==false && (mapOwnerFirstname.get(objlead.ownerid).firstname!=null || mapOwnerFirstname.get(objlead.ownerid).lastname!=null))
        {
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
            CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
            //Populating the fields required to insert into the SMSMessage Object
            objSmsMessage.CCPM_leadRecord__c = objlead.Id;
            objSmsMessage.CCPM_LiveTextNumber__c = CCPM_staticConstants.strLivetextPhoneNumber;
           if(objlead.CCPM_storeMarket__c!= null && objlead.CCPM_storeTerritory__c!= null && objlead.CCPM_storeDistrict__c!= null 
           && setMarket!=null && setMarket.isempty()==false && setDistrict!=null && setDistrict.isempty()==false
           && setTerritory!=null && setTerritory.isempty()==false && setMarket.contains(objlead.CCPM_storeMarket__c) 
           && setTerritory.contains(objlead.CCPM_storeTerritory__c) && setDistrict.contains(objlead.CCPM_storeDistrict__c)){
                objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;  
            }
                else{
                   objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusQueued;  
                }
            */
    /*        Map<String, CCPM_suppressOutboundSMS__c> mapSuppressOutboundMessage = CCPM_staticConstants.mapSuppressOutboundMessage;
            CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
            //Populating the fields required to insert into the SMSMessage Object
            objSmsMessage.CCPM_leadRecord__c = objlead.Id;
            objSmsMessage.CCPM_LiveTextNumber__c = CCPM_staticConstants.strLivetextPhoneNumber;
            if(mapSuppressOutboundMessage != null && !mapSuppressOutboundMessage.isEmpty()){
                For(string strkey : mapSuppressOutboundMessage.keySet()){
                    CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = new CCPM_suppressOutboundSMS__c();
                    objSuppressOutboundMessage = mapSuppressOutboundMessage.get(strkey);
                    //Check for Market/Territory/District
                    if(objSuppressOutboundMessage.IsActive__c && objlead.CCPM_storeDistrict__c!= null && objSuppressOutboundMessage.District__c != null && objSuppressOutboundMessage.District__c == objlead.CCPM_storeDistrict__c){
                        if(objlead.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objlead.CCPM_storeTerritory__c
                           && objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                               objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                               objSmsMessage.CCPM_removedByLocationSetting__c = True;
                               //system.debug('@@@Inside District');
                           }
                    }
                    else if(objSuppressOutboundMessage.IsActive__c && objSuppressOutboundMessage.District__c == null){
                        if(objlead.CCPM_storeTerritory__c!= null && objSuppressOutboundMessage.Territory__c != null && objSuppressOutboundMessage.Territory__c == objlead.CCPM_storeTerritory__c){
                            if(objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
                                objSmsMessage.CCPM_MessageStatus__c = CCPM_staticConstants.strMessageStatusRemoved;
                                objSmsMessage.CCPM_removedByLocationSetting__c = True;
                                //system.debug('@@@Inside Territory');
                            }
                        }
                        else if(objSuppressOutboundMessage.Territory__c == null){
                            if(objlead.CCPM_storeMarket__c != null && objSuppressOutboundMessage.Market__c != null && objSuppressOutboundMessage.Market__c == objlead.CCPM_storeMarket__c){
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
            objSmsMessage.CCPM_ScheduleDateTime__c = datTWithinBusinessHours;
            objSmsMessage.CCPM_toPhoneNumber__c = ObjManagerAssistantManager.CCPM_employee__r.MobilePhone;
            objSmsMessage.CCPM_SMSFailCounter__c = '0';
            objSmsMessage.CCPM_communicationDirection__c=CCPM_StaticConstants.strTaskCommunicationOutbound;
            objSmsMessage.CCPM_internalCommunication__c=True;
            objSmsMessage.CCPM_sentTo__c=ObjManagerAssistantManager.CCPM_employee__c;
            
            //Setting the reference string and Message Type for SMS to Managers/Assistant Managers
            if(objManagerAssistantManager.CCPM_role__c==CCPM_staticConstants.strStoreManager)
            {
                objSmsMessage.CCPM_referenceId__c		= CCPM_staticConstants.strStoreManager; 
                objSmsMessage.CCPM_messageType__c 		= CCPM_staticConstants.strMessageTypeManagers;
            }
            else
            {
                objSmsMessage.CCPM_referenceId__c		= CCPM_staticConstants.strStoreAssistantManager;
                objSmsMessage.CCPM_messageType__c 		= CCPM_staticConstants.strMessageTypeAssistantManagers;
            }
            if(mapOwnerFirstname.get(objlead.ownerid).firstname!=null && mapOwnerFirstname.get(objlead.ownerid).lastname!=null)
            {
               objSmsMessage.CCPM_message__c 			= 'Hi '+ObjManagerAssistantManager.CCPM_employee__r.firstname+', '+Objlead.lastname+' has responded to ' + mapOwnerFirstname.get(objlead.ownerid).firstname +' '+ mapOwnerFirstname.get(objlead.ownerid).lastname+ '. To review the lead login to Salesforce and view the \'Leads Requiring Action\' report.'; 
            }
            else if(mapOwnerFirstname.get(objlead.ownerid).firstname==null && mapOwnerFirstname.get(objlead.ownerid).lastname!=null)
            {
               objSmsMessage.CCPM_message__c 			= 'Hi '+ObjManagerAssistantManager.CCPM_employee__r.firstname+', '+Objlead.lastname+' has responded to ' +  mapOwnerFirstname.get(objlead.ownerid).lastname+ '. To review the lead login to Salesforce and view the \'Leads Requiring Action\' report.';  
            }
            else{
                objSmsMessage.CCPM_message__c 			= 'Hi '+ObjManagerAssistantManager.CCPM_employee__r.firstname+', '+Objlead.lastname+' has responded to ' +  mapOwnerFirstname.get(objlead.ownerid).firstname+ '. To review the lead login to Salesforce and view the \'Leads Requiring Action\' report.';  
            }
            //Setting the SMS body
            
            return objSmsMessage;
        }
        else{
            return null;
        }
    } */
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This private method is used to send SMS to Task Ownwers
@param         Lead,Map of users containing id and Firstname,  Map of Leads containing id ownerId and lastName
@return        LiveText.ScheduleItem
*/  
  /*  @TestVisible
    private static LiveText.ScheduleItem sendLeadOrProspectActionRequiredSMS (lead objlead, String strLeadType, CCPM_storeEmployee__c ObjManagerAssistantManager, map<id,User> mapOwnerFirstname)
    {  
        if(ObjManagerAssistantManager.CCPM_employee__r.MobilePhone!=null)
        {
            // instance of livetext schedule item
            LiveText.ScheduleItem objSI	= new LiveText.ScheduleItem(); 
            
            //Setting the Object Id to Lead ID
            objSI.ObjectId			= objlead.Id;
            
            //Setting the reference string
            objSI.ReferenceId    = CCPM_staticConstants.strReferenceLeadProspectActionRequired+objlead.Id; 
            
            //Setting the SMS body
            if(mapOwnerFirstname.get(objlead.ownerid).firstname!=null)
            {
                objSI.Message      = 'Action Required: A '+strLeadType+' has responded to your store and '+ mapOwnerFirstname.get(objlead.ownerid).firstname+
                    ' has not followed up in 3 hours. Please login to Salesforce and view \'Leads Requiring Action\'.';
            }
            
            //Setting the customer number to whom the message shall be sent
            objSI.ToPhoneNumber		= ObjManagerAssistantManager.CCPM_employee__r.MobilePhone;
            //Setting the Live Text Number from which the message is to be sent
            
            objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
            return objSI; 
        }
        else
        {
            return null;
        }
    } */
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This private method is used to send SMS to Task Ownwers
@param         Lead Id,Map of users containing id and Firstname,  Map of Leads containing id ownerId and lastName
@return        LiveText.ScheduleItem
*/  
 /*   @TestVisible
    private static LiveText.ScheduleItem sendSMSToTaskOwner (id idLead,map<id,User> mapTaskOwner,map<id,Lead> mapLeads)
    {	
        System.debug('# Inside SMS to Task Owner');
        // instance of livetext schedule item
        LiveText.ScheduleItem objSI	= new LiveText.ScheduleItem(); 
        //Setting the Object Id to Lead ID
        objSI.ObjectId			= idLead;
        //Setting the reference string for Process Customer Response
        objSI.ReferenceId		= CCPM_staticConstants.strReferenceTaskOwnerSMS+idLead; 
        //Setting the SMS body 
        objSI.Message			= 'Hi '+ mapTaskOwner.get(mapLeads.get(idLead).ownerid).firstname + ', '+mapLeads.get(idLead).LastName+' has responded. Please review \'Leads Requiring Action\' in Salesforce and take appropriate action.';
        //Setting the customer number to whom the message shall be sent
        objSI.ToPhoneNumber		= mapTaskOwner.get(mapLeads.get(idLead).ownerid).mobilephone;
        //Setting the Live Text Number from which the message is to be sent
        objSI.LiveTextNumber	= gs.CCPM_liveTextPhoneNumber__c;
        return objSI; 
        
    }
    */
    /**
@author        	Brigadesh Chandrasekar (Deloitte)
@description   	This Private method is used to create task once the Process Customer Response SMS is sent 
with record tpye: TO DO
@param         	Lead Record, ITR Record created after receiving a response from Customer
@return        	Task
*/  
  /*  @TestVisible
    private static Task createToDoTaskforCustomerResponse(lead objlead,LiveText__ITR_Message__c ITR)
    {	
        if(objlead.CCPM_isLeadOwnerActive__c)
        {
            Task objTask 			= new task();
            //Setting the Assigned to ID
            objTask.OwnerId			= objlead.OwnerId;
            //Setting Task Type
            objTask.Type			= CCPM_staticConstants.strTaskTypeSMS;    
            //Setting Communication Direction
            objTask.CCPM_communicationDirection__c	= CCPM_staticConstants.strTaskCommunicationOutbound;        
            //Setting the Comments field with message received from Customer
            objTask.Description		= ITR.LiveText__Message__c;
            //Setting the Record type of task to be created and associated fields
            objTask.RecordTypeId	= gs.CCPM_taskToDoRecordTypeId__c;
            // set the date as today
            objTask.ActivityDate	= System.today();
            // set the priority of the task to high
            objTask.Priority		= CCPM_staticConstants.strTaskPriorityHigh;
            // set the status of the 
            objTask.Status			= CCPM_staticConstants.strTaskNotStarted;
            // set subject for the task
            objTask.Subject			= 'SMS for Review [' +  string.valueOf(objlead.LastName) +']';  
            
            // link the task to lead/cart
            objTask.Whoid			= objlead.id;
            
            return objTask; 
        }
        else{
            return null; 
        }
        
    }
    */
    /**
@author        Brigadesh Chandrasekar (Deloitte)
@description   This Private method is used to create task once the Process Customer Response SMS is sent with record tpye: Interaction History
@param         Lead Record, ITR Record created after receiving a response from Customer
@return        Task
*/  
  /*  @TestVisible
    private static Task createInteractionTaskforCustomerResponse(lead objlead,LiveText__ITR_Message__c ITR)
    {
        // instance of task object
        Task objTask 			= new task();
        //Setting the Assigned to ID
        objTask.OwnerId			= CCPM_staticConstants.strDataIntegrationUserID;
        //Setting Task Type
        objTask.Type			= CCPM_staticConstants.strTaskTypeSMS;
        //Setting Communication Direction
        objTask.CCPM_communicationDirection__c=CCPM_staticConstants.strTaskCommunicationDirection;
        //Setting the Comments field with message received from Customer
        objTask.Description		= ITR.LiveText__Message__c;
        //Setting the Record type of task to be created and associated fields
        objTask.RecordTypeId	= gs.CCPM_taskInteractionHistoryRecordTypeId__c;
        // set the priority of the task to normal
        objTask.Priority		= CCPM_staticConstants.strTaskPriorityNormal;
        // set the status of task to completed
        objTask.Status			= CCPM_staticConstants.strTaskCompleted;
        // set the subject of the task
        objTask.Subject			= CCPM_staticConstants.strTaskSubjectTextMessageReceived;
        // associate the task to lead record
        objTask.whoid			= ITR.LiveText__Lead__c;
        //Custom field for interaction bubble
        objTask.CCPM_SMSMessageType__c = CCPM_staticConstants.strMessageTypeDoubleOptOutSMS;
        return objTask; 
    }
    */
    
}