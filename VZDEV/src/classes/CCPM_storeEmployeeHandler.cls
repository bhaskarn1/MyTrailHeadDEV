/**
*@name          CCPM_storeEmployeeHandler
*@author        Paras Shah (Deloitte)
*@date          08/08/2017
@description    Handler class for the Store Employee Trigger
@testClass      CCPM_storeEmployeeHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)        08/08/2017                      Original Version - US-1615 and US-1693
Sriraman Sridharan(Deloitte)								Updated Version - US-1712, 1714, 1718, 1751
Brigadesh Chandrasekar(Deloitte	)     08/28/2017		    Updated Version -  1719	
Sriraman Sridharan			9/14/2017						Updated Version - 1716
*/

public class CCPM_storeEmployeeHandler {

/**
@author         Paras Shah (Deloitte)
@description    This method is used to delete the LeadSharing records for the Assistant Managers - US-1615 and US-1693
@param          List of Store Employee records
@return         Void(None)
*/    
    /*
    public static void deleteLeadSharingRecordsForInActiveStoreEmployee(Map<id,id> mapUserStore)
    {
        
        // Set of Lead IDs belonging to the Assistant Managers
        set<id> setLeadId = new set<id>();
        
        // Declaration of a Map
        Map<id,Lead> mapLeadsStore = new Map<id,Lead>();

        try {
            // Map to add Lead ID and corresponsing Store
            mapLeadsStore = new Map<id,Lead>([select id,Store__c from Lead where Store__c IN :mapUserStore.values() and Status IN :CCPM_staticconstants.setOpenLeadStatus]);
        }
        catch(Exception e) {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','deleteLeadSharingRecordsForInActiveStoreEmployee','Exception thrown while Querying Leads into Map',true); 
        }
        
        if(!mapLeadsStore.isEmpty()) {
            // Add all LeadIDs into a set to query LeadShare records
            setLeadID.addAll(mapLeadsStore.keySet());
        }
 
        // List for LeadShare records
        List<LeadShare> lstLeadShare = new List<LeadShare>();
        
        try {
            // Query to pull relevant LeadShare records
            lstLeadShare = [select id, LeadID, UserOrGroupId  from leadShare where LeadId in :setLeadID and UserOrGroupId in :mapUserStore.keySet() and LeadAccessLevel=  'Edit'];
        }
        catch(Exception e) {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','','Exception thrown while Querying LeadShare',true); 
        }
        
        // List of LeadShare that needs to be deleted
        List<LeadShare> lstDeleteLeadShare = new List<LeadShare>();
        
        // Process each Leadshare record        
        for(LeadShare objLS: lstLeadShare) {
            
            // Set for USer and their Stores
            Id idUserStoreBasedOnLeadshare;
            
            if (mapUserStore.containsKey(objLS.UserOrGroupId)) {
                // Set of Stores for the LeadShare User
                idUserStoreBasedOnLeadshare = mapUserStore.get(objLS.UserOrGroupId);
            }
            
       
            // IF Lead Store Equals Store Employee Store where the User is Inactivated
            if (mapLeadsStore.get(objLS.LeadId).Store__c == idUserStoreBasedOnLeadshare) {
                    lstDeleteLeadShare.add(objLS);
                }
            
        }
        
        // Delete the LeadSharing records for Assistant Managers
        try{
            if(lstDeleteLeadShare != null    && 
               !lstDeleteLeadShare.isEmpty() ) {
                //Bulkified Delete
                delete lstDeleteLeadShare;
            }
        }   
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','deleteLeadSharingRecordsForInActiveStoreEmployee','Exception thrown while deleting LeadShare records',true); 
        }
        
        //return lstNewStoreEmployees;
        
    }
    */ 
    /**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is used to decide whether to give Lead access or delete Lead Access
@param          List of store Employees and map of old store employees
@return         Void
*/
    /*
    public static void decideLeadShareAccessForEmployee(List<CCPM_StoreEmployee__c> lstNewStoreEmployees, map<id,CCPM_StoreEmployee__c> mapOldStoreEmployees)
    {   
        //Instantiate Map to contain Employee Id as Key and related store as value for providing access
        map<id,id> mapEmployeeStoreIDGiveAccess = new map<id,id>();
         //Instantiate Map to contain Employee Id as Key and related store as value for removing access
        map<id,id> mapEmployeeStoreIDRemoveAccess = new map<id,id>();
        //For every store employee in current context
        for(CCPM_StoreEmployee__c objSE : lstNewStoreEmployees )
        {	//Check for role change
            if(objSE.CCPM_IsActive__c == true && objSE.CCPM_role__c!= null && objSE.CCPM_employee__c!=null && mapOldStoreEmployees.get(objSE.id).CCPM_role__c!=null && objSE.CCPM_role__c != mapOldStoreEmployees.get(objSE.id).CCPM_role__c)
            {	//When the role is moved to AM
                if(objSE.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager && objSE.CCPM_Store__c!=null && objSE.isactivetest__c)
                {
                    mapEmployeeStoreIDGiveAccess.put(objSE.CCPM_employee__c,objSE.CCPM_Store__c);
                }
                //When the role is moved to salesrep
                else if(objSE.CCPM_role__c == CCPM_staticConstants.strStoreSalesRep && mapOldStoreEmployees.get(objSE.id).CCPM_role__c==CCPM_staticConstants.strStoreAssistantManager && objSE.CCPM_Store__c!=null )
                {
                    mapEmployeeStoreIDRemoveAccess.put(objSE.CCPM_employee__c,objSE.CCPM_Store__c);
                }
                //When thew role is moved to Store manager from AM
                else if(objSE.CCPM_role__c == CCPM_staticConstants.strStoreManager && mapOldStoreEmployees.get(objSE.id).CCPM_role__c==CCPM_staticConstants.strStoreAssistantManager && objSE.CCPM_Store__c!=null )
                {
                    mapEmployeeStoreIDRemoveAccess.put(objSE.CCPM_employee__c,objSE.CCPM_Store__c);
                }
            }
            //Check if Store Employee is deactivated
            if(objSE.CCPM_IsActive__c == false && mapOldStoreEmployees.get(objSE.id).CCPM_IsActive__c == true && objSE.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager && objSE.CCPM_Store__c!=null)
            {
                mapEmployeeStoreIDRemoveAccess.put(objSE.CCPM_employee__c,objSE.CCPM_Store__c);
            }
            //Check if store of the Store employee is changed and he is the AM at the new store
            if(objSE.CCPM_IsActive__c == True && mapOldStoreEmployees.get(objSE.id).CCPM_IsActive__c == false && objSE.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager  && objSE.isactivetest__c) //&& objSE.CCPM_employee__r.isactive==true
               {
                   if(objSE.CCPM_Store__c!=null)
                   {
                       mapEmployeeStoreIDGiveAccess.put(objSE.CCPM_employee__c,objSE.CCPM_Store__c);
                   }
               }
        }
        //If the map for removing access is not Empty
        if(mapEmployeeStoreIDRemoveAccess!=null && mapEmployeeStoreIDRemoveAccess.isEmpty()==false)
        {
            deleteLeadSharingRecordsForInActiveStoreEmployee(mapEmployeeStoreIDRemoveAccess);
        }
        //If the map for providing access is not Empty
        if(mapEmployeeStoreIDGiveAccess!=null && mapEmployeeStoreIDGiveAccess.isEmpty()==false)
        {
            provideLeadShareAccess(mapEmployeeStoreIDGiveAccess);
        }
    }
    */
      /**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is used to provide LeadShareAccess
@param          Map of Employee ID and associated store
@return         Void
*/
    /*
    Public Static Void provideLeadShareAccess(map<id,id> mapEmployeeStoreIDGiveAccess)
    {
        list<Lead> lstLeadToBeConsidered = new list<Lead>();
        List<leadShare> lstApplySharing    = new List<leadShare>();
        //Check if the map parameter has values
        if(mapEmployeeStoreIDGiveAccess!=null && mapEmployeeStoreIDGiveAccess.isEmpty()==false)
        {
            try{
                //Query for all associated open Leads
                lstLeadToBeConsidered = [select id,Store__c,ownerid from Lead where Store__c in :mapEmployeeStoreIDGiveAccess.values() and status in :CCPM_staticconstants.setOpenLeadStatus];
                //and ownerid not in :mapEmployeeStoreIDGiveAccess.keySet()
            }
            catch(Exception e)
            {
                //Catch statement in case of failure in DML Statements
                CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','provideLeadShareAccess','Exception thrown while Querying for Associated Leads',true);
            }
        }
        //For all Leads obtained
        if(lstLeadToBeConsidered!=null && lstLeadToBeConsidered.isEmpty()==false)
        {	//For every store employee in the current context
            for(string strSE : mapEmployeeStoreIDGiveAccess.keySet() )
            {  //Validate against store on the Lead Object
                for(Lead objLead : lstLeadToBeConsidered)
                {   
                    if(objLead.Store__c == mapEmployeeStoreIDGiveAccess.get(strSE) && objLead.ownerid!=strSE)
                    {
                        lstApplySharing.add(CCPM_globalUtility.apexShareReadAccess(objLead.id,strSE)); 
                    }
                }
                
            }
        }
        
        try{
            //Try to Insert Apex Sharing
            if(lstApplySharing!=null && lstApplySharing.IsEmpty()==false)
            {
                insert lstApplySharing;
            }
        }
        catch(Exception e)
        {
            //Catch statement in case of failure in DML Statements
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','provideLeadShareAccess','Exception thrown while inserting Lead Shares',true);
        }
    }  
    */
/**
@author         Brigadesh Chandrasekar (Deloitte)
@description    This method is used to provide LeadShareAccess on insert
@param          List of Store Employee records in trigger context
@return         Void
*/
    /*
    Public Static Void provideLeadShareAccessOnInsert(List<CCPM_StoreEmployee__c> lstNewStoreEmployees)
    {
        map<id,id> mapEmployeeAssociatedStore = new map<id,id>();
        //For every store employee in trigger context
        for(CCPM_StoreEmployee__c objSE : lstNewStoreEmployees)
        {   //Validate if Role is Assistant Manager
            if(objSE.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager && objSE.CCPM_Store__c!=null && objSE.CCPM_Store__r.CCPM_IsActive__c && objSE.CCPM_employee__c!=null)
            {	//Put in Map of SE and store associated
                mapEmployeeAssociatedStore.put(objSE.CCPM_employee__c,objSE.CCPM_Store__c);
            }
        }
        //If map is not null
        if(mapEmployeeAssociatedStore!=null && mapEmployeeAssociatedStore.isEmpty()==false)
        {
            provideLeadShareAccess(mapEmployeeAssociatedStore);
        }
    }*/
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method is used to update the leads with new managers
@param          List of lead records
@return         Void
*/  /*  
    public static void UpdateLeadsWithNewOwners(List<CCPM_StoreEmployee__c> lstNewStoreEmployees, Set<Lead> setLeadsToBeUpdated,Map<String,Group> mapDistrictAndGroup,Set<ID> IdStoreEmployee,List<BusinessHours> lstBusinessHours)
    {   
        Set<String> setStoreID = new Set<String>();
        Map<String,CCPM_storeEmployee__c> mapStoreSFIDandStoreManager = new Map<String,CCPM_storeEmployee__c>();
        List<CCPM_storeEmployee__c> lstStoreEmployees = new List<CCPM_storeEmployee__c>();
       	List<CCPM_storeEmployee__c> lstStoreEmployeesExceptUpdatedOnes = new List<CCPM_storeEmployee__c>();
        List<CCPM_storeEmployee__c> lstmanagersAndAsstManagers = new List<CCPM_storeEmployee__c>();
        List<Lead> lstLeadsToBeUpdated = new List<Lead>();
        for(Lead objLead : setLeadsToBeUpdated){
            if(objLead.Store__c!= null && !setStoreID.contains(objLead.Store__c)){
                setStoreID.add(objLead.Store__c);
            }
            if(objLead != null){
                lstLeadsToBeUpdated.add(objLead);
            }
        }
        
        
        //System.debug('@@@IdStoreEmployee: ' + IdStoreEmployee);
        
        try{
            lstStoreEmployees  = [Select id,CCPM_Store__c,CCPM_Store__r.id,CCPM_Store__r.CCPM_StoreID__c,CCPM_role__c,CCPM_IsActive__c, CCPM_employee__c,CCPM_employee__r.name,CCPM_employee__r.Id,CCPM_employee__r.CCPM_EmployeeId__c, CCPM_employee__r.IsActive,CCPM_employee__r.mobilephone ,CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where CCPM_Store__c IN :setStoreID AND CCPM_IsActive__c = true AND CCPM_employee__r.IsActive = true];
    	}
        Catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','UpdateLeadsWithNewOwners','Exception thrown while querying for leads',true); 
		}
        
        for(CCPM_storeEmployee__c objStoreEmp : lstStoreEmployees){
            if(!IdStoreEmployee.contains(objStoreEmp.CCPM_employee__c)){
                lstStoreEmployeesExceptUpdatedOnes.add(objStoreEmp);
                if(objStoreEmp.CCPM_role__c == CCPM_staticConstants.strStoreManager || objStoreEmp.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager){
                    lstmanagersAndAsstManagers.add(objStoreEmp);
                }
            }
        }
        
        //System.debug('@@@lstStoreEmployeesExceptUpdatedOnes: ' + lstStoreEmployeesExceptUpdatedOnes);
        //Get Map of store and store Managers
        mapStoreSFIDandStoreManager = CCPM_leadHandlerAssignOwnership.getStoreandStoreManagerMap(lstStoreEmployeesExceptUpdatedOnes);
        
        for(Lead objLead : lstLeadsToBeUpdated){
            if(objLead.CCPM_isStoreEmployeeUpdated__c){
                objLead.CCPM_isStoreEmployeeUpdated__c = false;
            }else{
                objLead.CCPM_isStoreEmployeeUpdated__c = true;
            }
              // To check for lead owner update
            if(objLead.Store__c!= null && !mapStoreSFIDandStoreManager.isEmpty() && mapStoreSFIDandStoreManager.containsKey(objLead.Store__c)){
                CCPM_storeEmployee__c objStoreEmpForOwner =  mapStoreSFIDandStoreManager.get(objLead.Store__c);
                //system.debug('@@@objStoreEmpForOwner.CCPM_employee__r.id ' +objStoreEmpForOwner.CCPM_employee__r.id);
                objLead.OwnerId = objStoreEmpForOwner.CCPM_employee__r.id;
            }
            else if(!mapDistrictAndGroup.isEmpty() && mapDistrictAndGroup.containsKey(objLead.Store__r.CCPM_market__c)){
                objLead.OwnerId = mapDistrictAndGroup.get(objLead.Store__r.CCPM_market__c).id; 
                objLead.CCPM_storeManager__c = null;
            }
            else{
                objLead.OwnerId = CCPM_staticConstants.strDataIntegrationUserQueue;
                objLead.CCPM_storeManager__c = null;
            }
        }
        try{
            if(setLeadsToBeUpdated != null && setLeadsToBeUpdated.size()>0){
                //system.debug('@@@setLeadsToBeUpdated: '+setLeadsToBeUpdated);
                Update lstLeadsToBeUpdated;
            }
        }
        catch(Exception e){
           	CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','UpdateLeadsWithNewOwners','Exception thrown while Updating the leads',true); 

        }
        //US-1716
        List<CCPM_SMSMessage__c> lstSMSMessage = new List<CCPM_SMSMessage__c>();
        lstSMSMessage = insertSMSRecordsToManagersAndAssistantManagers(lstLeadsToBeUpdated,lstmanagersAndAsstManagers,lstBusinessHours);
    	try{
            if(lstSMSMessage != null && lstSMSMessage.size()>0){
                system.debug('@@@lstSMSMessage ' + lstSMSMessage); 
                insert lstSMSMessage;
            }
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','insertSMSRecordsToManagersAndAssistantManagers','Exception thrown while inserting messages',true);
		}
        
    }
*/
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method is used to send messages to the managers and assistant managers
@param          List of lead records
@return        	List<CCPM_SMSMessage__c>
*/    /*
    public static List<CCPM_SMSMessage__c> insertSMSRecordsToManagersAndAssistantManagers(List<Lead> lstLeadsToBeUpdated,List<CCPM_storeEmployee__c> lstmanagersAndAsstManagers,List<BusinessHours> lstBusinessHours)
    {        
    	BusinessHours objDefaultBusinessHour =new BusinessHours();
        BusinessHours objBusinessHoursStore = new BusinessHours();
        map<ID,List<CCPM_storeEmployee__c>> mapstoreAndStoreManagers = new map<ID,List<CCPM_storeEmployee__c>>();
        map<ID,List<CCPM_storeEmployee__c>> mapLeadAndStoreManagers = new map<ID,List<CCPM_storeEmployee__c>>();
        Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
        for(Integer i=0; i<lstBusinessHours.size();i++)
        {
            if(lstBusinessHours[i].IsDefault)
            {
                objDefaultBusinessHour = lstBusinessHours[i];
                break;
            }
        }
        //Construct a map of required store and store managers/asst managers
        for(CCPM_storeEmployee__c objemployee : lstmanagersAndAsstManagers){	
            List<CCPM_storeEmployee__c> lstStoreEmployee = new List<CCPM_storeEmployee__c>();
            if(objemployee!=null && objemployee.CCPM_Store__c != null && !mapstoreAndStoreManagers.containsKey(objemployee.CCPM_Store__c)){
                lstStoreEmployee.add(objemployee);
                mapstoreAndStoreManagers.put(objemployee.CCPM_Store__c, lstStoreEmployee);
            }
            else if(objemployee!=null && objemployee.CCPM_Store__c != null && mapstoreAndStoreManagers.containsKey(objemployee.CCPM_Store__c)){
                lstStoreEmployee.clear();
                lstStoreEmployee = mapstoreAndStoreManagers.get(objemployee.CCPM_Store__c);
                lstStoreEmployee.add(objemployee);
                mapstoreAndStoreManagers.put(objemployee.CCPM_Store__c, lstStoreEmployee);
            }
        }
        //Construct a map of required lead and store managers
        for(lead objlead : lstLeadsToBeUpdated){
            if(objlead!= null && objlead.Store__c != null && mapstoreAndStoreManagers.containsKey(objlead.Store__c) && !mapLeadAndStoreManagers.containsKey(objlead.Id)){
                mapLeadAndStoreManagers.put(objlead.Id, mapstoreAndStoreManagers.get(objlead.Store__c)); 
            }
        }
        system.debug('@@@mapLeadAndStoreManagers: ' + mapLeadAndStoreManagers);
		//Querying for active business hours from the org       
		
        mapLeadAndBusinessHours = CCPM_leadHandlerAssignOwnership.getCartIdORStoreIDAndBusinessHourMap(lstLeadsToBeUpdated,objDefaultBusinessHour,lstBusinessHours);          
        
        List<CCPM_SMSMessage__c> lstSMSMessage = new List<CCPM_SMSMessage__c>();
        Set<ID> setStoreEmployee = new Set<ID>();
        for(lead objlead : lstLeadsToBeUpdated){
            DateTime datTBusinessTime;
            if(objlead.Store__c != null && mapLeadAndBusinessHours != null && mapLeadAndBusinessHours.containsKey(objlead.store__c) && mapLeadAndBusinessHours.get(objlead.store__c)!=null)
            {
                //system.debug(' @@@@ '+mapLeadAndBusinessHours.get(objlead.store__c));
                objBusinessHoursStore = mapLeadAndBusinessHours.get(objlead.store__c);
            }
            else if(mapLeadAndBusinessHours != null && objlead.CCPM_cartID__c !=null && mapLeadAndBusinessHours.containsKey(objlead.CCPM_cartID__c) && mapLeadAndBusinessHours.get(objlead.CCPM_cartID__c)!=null)
            {
                objBusinessHoursStore = mapLeadAndBusinessHours.get(objlead.CCPM_cartID__c);
            }
            else
            {
                objBusinessHoursStore = objDefaultBusinessHour;
            } 
            
            datTBusinessTime = CCPM_leadHandlerAssignOwnership.calculateTimeToTriggerSMSWithInBusinessHours(objBusinessHoursStore, System.now());
            if(mapLeadAndStoreManagers.containsKey(objlead.Id)){
                List<CCPM_storeEmployee__c> lstStoreManagers = new List<CCPM_storeEmployee__c>();
                lstStoreManagers = mapLeadAndStoreManagers.get(objlead.Id);
                if(lstStoreManagers!= null){
                    for(CCPM_storeEmployee__c objEmployee :lstStoreManagers){
                        CCPM_SMSMessage__c objSmsMessage = new CCPM_SMSMessage__c();
                        String strMessage = objlead.CCPM_changeOwnershipAssignmentMsgBody__c;
                        String strToPhone = objEmployee.CCPM_employee__r.mobilephone;
                        objSmsMessage = CCPM_leadHandler.createRecordsForSmsMessageObject(objlead,strMessage,strToPhone,CCPM_staticConstants.strLeadOwnerChangeSMS,CCPM_StaticConstants.strTaskCommunicationOutbound,datTBusinessTime,CCPM_staticConstants.strLivetextPhoneNumber);
                        objSmsMessage.CCPM_internalCommunication__c=True;
                        objSmsMessage.CCPM_sentTo__c=objEmployee.CCPM_employee__c;
                        if(!setStoreEmployee.contains(objEmployee.CCPM_employee__c)){
                            lstSMSMessage.add(objSmsMessage);
                        }
                        setStoreEmployee.add(objEmployee.CCPM_employee__c);
                    }  
                } 
            }
        }
        
        return lstSMSMessage;
    }
*/
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method is used to get the list of leads associated with the updated store employees
@param          List of Store Employee records and old maps
@return         Void(None)
*/    /*
    public static List<Lead> getListofOpenLeadsForUpdatedEmployees(List<CCPM_StoreEmployee__c> lstNewStoreEmployees, map<id,CCPM_StoreEmployee__c> mapOldStoreEmployees)
    {    
		set<id> setSEStores = new set<id>();
        List<lead> lstLeadsAssociatedTotheUpdatedEmployees= new List<lead>();
        for (CCPM_StoreEmployee__c objStoreEmployee: lstNewStoreEmployees) {
            //system.debug(' @@@objStoreEmployee.CCPM_Store__r.CCPM_IsActive__c: ' + objStoreEmployee.CCPM_Store__r.CCPM_IsActive__c);
            if(objStoreEmployee.CCPM_Store__c != null){
                setSEStores.add(objStoreEmployee.CCPM_Store__c);
            }
        }
        //system.debug('@@@setSEStores: ' + setSEStores);
        try{
            lstLeadsAssociatedTotheUpdatedEmployees = [select id,Store__c, Store__r.id,Store__r.CCPM_market__c,CCPM_isStoreEmployeeUpdated__c, OwnerID,CCPM_changeOwnershipAssignmentMsgBody__c,Store__r.CCPM_territory__c,Store__r.CCPM_district__c from Lead where Store__c IN :setSEStores and Status IN :CCPM_staticconstants.setOpenLeadStatus];
        }Catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_storeEmployeeHandler','getListofLeadsForUpdatedEmployees','Exception thrown while querying for leads',true); 
    	}
        
        return lstLeadsAssociatedTotheUpdatedEmployees;
    }
*/
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method is used to update the owner for a list of leads using the list of store employees
@param          List of updated Store Employee records, old maps of the records and list of lead records
@return         List<CCPM_storeemployee__c>
*/    /*
    public static List<CCPM_storeemployee__c> updateOwnerForAssociatedLeads(List<CCPM_StoreEmployee__c> lstNewStoreEmployees, List<CCPM_StoreEmployee__c> lstOldStoreEmployees,List<Lead> lstLeadsAssociatedToStoreEmployees,Map<String,Group> mapDistrictAndGroup,List<BusinessHours> lstBusinessHours)
    {    
		Map<ID, List<Lead>> mapOwnerAndLead = new Map<ID, List<Lead>>();
        Set<lead> setLeadsToBeUpdated = new Set<lead>();
        mapOwnerAndLead = getmapOwnerAndLead(lstLeadsAssociatedToStoreEmployees,mapDistrictAndGroup);
        Set<ID> setStoreEmployees = new Set<ID>();
        for(Integer i=0;i<lstNewStoreEmployees.size();i++){
            //Check if role or isActive field has changed
            if(((lstNewStoreEmployees[i].CCPM_role__c != lstOldStoreEmployees[i].CCPM_role__c) && (lstNewStoreEmployees[i].CCPM_role__c == CCPM_staticConstants.strStoreSalesRep)) || 
               (lstNewStoreEmployees[i].CCPM_IsActive__c != lstOldStoreEmployees[i].CCPM_IsActive__c && !lstNewStoreEmployees[i].CCPM_IsActive__c)){
               //Check if IsActive field is set to false
                setStoreEmployees.add(lstNewStoreEmployees[i].CCPM_employee__c);
            }
        }
        //system.debug('@@@setStoreEmployees: ' + setStoreEmployees);
        for(ID IdOwner : setStoreEmployees){
            if(!mapOwnerAndLead.isEmpty() && IdOwner != null && mapOwnerAndLead.containsKey(IdOwner)){
                setLeadsToBeUpdated.addALL(mapOwnerAndLead.get(IdOwner));
            }  
        }
        
        if(setLeadsToBeUpdated != null && !setLeadsToBeUpdated.isEmpty()){
            system.debug('@@@setLeadsToBeUpdated : ' + setLeadsToBeUpdated);
            UpdateLeadsWithNewOwners(lstNewStoreEmployees,setLeadsToBeUpdated,mapDistrictAndGroup,setStoreEmployees,lstBusinessHours);
        }
        
        return lstNewStoreEmployees;
    }    
*/
    /**
@author         Sriraman Sridharan (Deloitte)
@description    This method is used to get the list of leads associated with the updated store employees
@param          List of lead records
@return         Map<ID, Lead>
*/    /*
    public static Map<ID, List<Lead>> getmapOwnerAndLead(List<Lead> lstLeadsAssociatedToStoreEmployees,Map<String,Group> mapDistrictAndGroup)
    {    
		Map<ID, List<Lead>> mapOwnerAndLead = new Map<ID, List<Lead>>();
        
        set<id> setQueueID = new set<id>();
        if(mapDistrictAndGroup!=null && !mapDistrictAndGroup.isEmpty())
        {
            setQueueID.addAll(CCPM_leadHandler.getSetOfQueueID(mapDistrictAndGroup));         
        }
        for(Lead objLead : lstLeadsAssociatedToStoreEmployees){
            if(objLead!= null && objLead.OwnerId != null && setQueueID!=null && !setQueueID.isEmpty() && !setQueueID.contains(objLead.OwnerId)){
                List<Lead> lstLeadByOwner = new List<Lead>();
                if(!mapOwnerAndLead.containsKey(objLead.OwnerId)){
                    lstLeadByOwner.add(objLead);
                    mapOwnerAndLead.put(objLead.OwnerId, lstLeadByOwner);
                }
                else if(mapOwnerAndLead.containsKey(objLead.OwnerId)){
                    lstLeadByOwner = mapOwnerAndLead.get(objLead.OwnerId);
                    lstLeadByOwner.add(objLead);
                    mapOwnerAndLead.put(objLead.OwnerId, lstLeadByOwner);
                }
            }
        }	
        return mapOwnerAndLead;
    }     
*/
}