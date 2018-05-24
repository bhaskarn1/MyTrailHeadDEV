/**
*@name          CCPM_SendMessageToManagersHandler
*@author        Sriraman Sridharan (Deloitte)
*@date          05/19/2016
@description    This class contains methods that take a list of leads as a parameter and returns a list of sms messages records that has to be inserted in order to send messages.
@testClass      CCPM_SendMessageToManagersHandlerTest
Modification    Log: US-336, US-417
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          05/19/2016              Original Version
Manjunath Keshava(Deloitte)           07/14/2017              Added Null checks and Avoid Hardcoding (US-1616)
Sudhakara Reddy Nallamilli (Deloitte) 08/08/2017              TKT-000434 - Changed the method to correct the Lead Required Action 3 hour followup SMS messages to AM and SM
Dheeraj R Shetty(Deloitte)            08/15/2017              US-1625: Made changes for Messaging Store Employees (over 3 hours responded action required) - Action Required Next Open Store Operating Hour
Paras Shah(Deloitte)                  08/15/2017              US-1615: Added Changes for IsActive checks for Store Employees
Anupreeta Chakraborty(Deloitte)       01/16/2018              Defect 2371: Schedule Date/Time of SMS is outside business hours.
*/

public class CCPM_SmsMessageHandler {
    
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This class method takes a list of leads as a parameter and returns a map of stores and the list of associated managers. 
@param          List of new leads
@return         map<id,list<CCPM_storeEmployee__c>>
*/ 
    public static map<id,list<CCPM_storeEmployee__c>> CCPM_createMapofStoreandListofAssociatedManagers(List<Lead> lstNewLeads){
        map<id,list<CCPM_storeEmployee__c>> mapManagersContact = new map<id,list<CCPM_storeEmployee__c>>();
        list<CCPM_storeEmployee__c> lstManagers = new list<CCPM_storeEmployee__c>();
        
        set<id> setLeadStoreID=new set<id>();
        
        for(lead objLead2: lstNewLeads)
        {
            setLeadStoreID.add(objLead2.store__c);
            //system.debug('&&&& Leads inside SmsMessageHandler: '+ objLead2 );
        }
         
        //Querying for the list of Managers/Assistant Managers to Send SMS
        if(setLeadStoreID!=null && setLeadStoreID.size()>0 &&!setLeadStoreID.isEmpty() )
        {
            lstManagers=[select CCPM_employee__c,CCPM_employee__r.firstname,CCPM_store__r.id,CCPM_employee__r.MobilePhone,CCPM_role__c from CCPM_storeEmployee__c where (CCPM_role__c='Store Manager' or CCPM_role__c='Assistant Manager') and CCPM_store__r.id in :setLeadStoreID and CCPM_employee__r.MobilePhone!=null and CCPM_isActive__c = true];
        }
        //system.debug('&&&& lstManagers : ' + lstManagers);
        //Maping the Lead Store and Manager and Assistance Manager
        for(lead objLead3: lstNewLeads)
        {
            if(lstManagers!= Null  && lstManagers.size()>0  && !lstManagers.isEmpty() )
            {
                list<CCPM_storeEmployee__c> lstAddmanagersToAssociatedStoreIds= new list<CCPM_storeEmployee__c>();
                for(CCPM_storeEmployee__c m:lstManagers)
                {         
                    if(m.CCPM_store__r.id==objLead3.store__c)
                    {
                        lstAddmanagersToAssociatedStoreIds.add(m);
                    }
                }
                if( lstAddmanagersToAssociatedStoreIds != NULL && lstAddmanagersToAssociatedStoreIds.size() > 0 && !lstAddmanagersToAssociatedStoreIds.isEmpty())
                {
                    mapManagersContact.put(objLead3.store__c,lstAddmanagersToAssociatedStoreIds); 
                }
                //system.debug('&&&& lstAddmanagersToAssociatedStoreIds: ' + lstAddmanagersToAssociatedStoreIds);
                //system.debug('&&&& mapManagersContact : '+ mapManagersContact);
            }
        }    
        return mapManagersContact;
    }

    /**
@author         Sriraman Sridharan (Deloitte)
@description    This class method takes a list of leads as a parameter and returns a map of leads and their owner's user records. 
@param          List of new leads
@return         map<id,User>
*/ 
    public static map<id,User> CCPM_createMapofLeadsandOwners(List<Lead> lstNewLeads){
        map<id,User> mapOwnerFirstname;
        set<id> setUserID=new set<id>();
        for(lead objLead2: lstNewLeads)
        {
            setUserID.add(objLead2.OwnerId);
        }
        if(setUserID!=null && setUserID.size()>0 && !setUserID.isEmpty())
        {
            mapOwnerFirstname=new map<id,User>([select firstname,lastname,mobilephone from user where id in :setUserID AND mobilephone != null]);
        }   
        return mapOwnerFirstname;
    }

    /**
@author         Sriraman Sridharan (Deloitte)
@description    This class method takes a lead as a parameter and returns a map of leads and their owner's user records. 
@param          List<Lead>, list<CCPM_SMSMessage__c>, list<CCPM_SMSMessage__c>
@return         List<CCPM_SMSMessage__c>
*/ 
    public static List<CCPM_SMSMessage__c> CCPM_createListofSmsMessages(List<Lead> lstLeadsQry,map<id,User> mapOwnerFirstname,map<id,list<CCPM_storeEmployee__c>> mapManagersContact){
        List<CCPM_SMSMessage__c> lstSmsMessages = new List<CCPM_SMSMessage__c>();
        String strLeadType;
        String strMessage;         
        BusinessHours bhrs = null;
        Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapGetBusinessHours();
        
        for(lead objLead1: lstLeadsQry )
        {
            CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
            if(objLead1.Store__c!= null && mapManagersContact.containsKey(objLead1.Store__c) && objLead1.ownerid!=null && mapOwnerFirstname.containsKey(objLead1.ownerid))
            {
                if( objLead1.RecordTypeId == CCPM_staticConstants.strProspectRecordTypeID || objLead1.RecordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID )
                {
                    strLeadType = CCPM_staticConstants.strLeadRecordTypeProspect;
                }
                else strLeadType = CCPM_staticConstants.strLeadRecordTypeLead;
                string strOwnerName;
                if(mapOwnerFirstname.get(objLead1.ownerid).firstname!= null)
                   strOwnerName = mapOwnerFirstname.get(objLead1.ownerid).firstname;
                else
                   strOwnerName = mapOwnerFirstname.get(objLead1.ownerid).lastname;  
                strMessage  = 'Action Required: A '+strLeadType+' has responded to your store and '+ strOwnerName +
                    ' has not followed up in 3 hours. Please login to Salesforce and view \'Leads Requiring Action\'.';
            bhrs = CCPM_utility.getBusinessHrForLead(objlead1);   
                 
                DateTime datTBusinessTime = bhrs != null ? CCPM_utility.calculateTimeWithInBusinessHours(bhrs, System.now()): null;         
         /*       if(CCPM_Collection.isNotNullEmpty(mapBusinessHoursNameRec)){
            if(String.isNotBlank(Label.CCPM_defaultLabel) && mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel) != null){
                bhrs = mapBusinessHoursNameRec.get(Label.CCPM_defaultLabel);
            }
            if(String.isNotBlank(objlead1.CCPM_StoreTimeZone__c) && mapBusinessHoursNameRec.get(objlead1.CCPM_StoreTimeZone__c) != null){
                bhrs = mapBusinessHoursNameRec.get(objlead1.CCPM_StoreTimeZone__c);
            }
        }         
                DateTime datTBusinessTime = CCPM_utility.calculateTimeWithInBusinessHours(bhrs, System.now()); */
                list<CCPM_storeEmployee__c> lstManagersAtStore = mapManagersContact.get(objLead1.Store__C);     
                for(CCPM_storeEmployee__c objManagersAtStore: lstManagersAtStore )
                {
                    string strMessageType = CCPM_staticConstants.strMessageTypeProspectActionRequired;
                    string strToPhone = objManagersAtStore.CCPM_employee__r.MobilePhone;
                    if(objManagersAtStore.CCPM_role__c==CCPM_staticConstants.strStoreManager)
                    {
                      strMessageType = CCPM_staticConstants.strMessageTypeManagersActionRequired;
                    }
                    else if(objManagersAtStore.CCPM_role__c==CCPM_staticConstants.strStoreAssistantManager)
                    {
                      strMessageType = CCPM_staticConstants.strMessageTypeAssistantManagersActionRequired;
                    }
                    objSmsMessage = CCPM_leadHandler.createRecordsForSmsMessageObject(objLead1, strMessage,strToPhone,strMessageType,CCPM_StaticConstants.strTaskCommunicationOutbound,datTBusinessTime,CCPM_staticConstants.strLivetextPhoneNumber);
                    if( objSmsMessage != NULL)
                    {
                        lstSmsMessages.add(objSmsMessage);
                    }
                }
            }
            
        } 
        return lstSmsMessages;
    }
}