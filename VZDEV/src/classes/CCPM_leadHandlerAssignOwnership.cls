/**
*@name          CCPM_leadHandlerAssignOwnership
*@author        Sriraman Sridharan (Deloitte)
*@date          07/12/2016
@description    US-0074: Associates the cart with the correct customer using Account Number
US-0024: Associates the preferred Store on the customer record on the correct Cart
US-0040: Expired leads after 30 days of no interaction with the lead/cart
US-1683: Added check for Store Store IsActive is TRUE
@testClass      CCPM_leadTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)        07/12/2017              Original Version
keshava manjunath(Deloitte)         08/17/2017              modification(TKT_475) && US_1756
keshava manjunath(Deloitte)         09/15/2017              Added condition in assignAccountForLead to avoid prospect and manual leads from assigning the leads
Sriraman Sridharan(Deloitte)        09/15/2017              Added update logic for ownership for US-1830              
*/
public class CCPM_leadHandlerAssignOwnership {
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to populate store and ownership fields on the lead during creation
@param         list of new leads
@return        Void
*/ 
    public static List<Lead> assignLeadOwnershipOnCreate(list<Lead> lstNewLeads , List<BusinessHours> lstBusinessHours,Map<String,Group> mapDistrictAndGroup){
        Set<String> setCartLastHandledBy    = new Set<String>();    //set of cartLastHandledBy Values
        Set<String> setCustomerAccountNumber= new Set<String>();    //Set of Customer Account Numbers from the leads
        Set<String> setStoreId               = new Set<String>();    // set of store Id's from the lead object
        Set<String> setNearestStoreId        = new Set<String>();        
        List<CCPM_storeEmployee__c> lstEntireStoreEmployees = new List<CCPM_storeEmployee__c>();        
        List<Account> lstCustomerAccount = new List<Account>();       
        List<CCPM_Store__c> lstStoreRecords = new List<CCPM_Store__c>();
        Map<String,Account> mapAccountAndUniqueID = new Map<String, Account>();
        Map<ID,CCPM_Store__c> mapStoreSFIdAndStore = new Map<ID,CCPM_Store__c>();
        Map<String,CCPM_Store__c> mapStoreIdAndStore = new Map<String,CCPM_Store__c>();
        List<CCPM_storeEmployee__c> lstStoreEmp = new List<CCPM_storeEmployee__c>();
        Map<String,CCPM_storeEmployee__c> mapCartlastHandledByAndStoreEmp = new Map<String,CCPM_storeEmployee__c>();
        Map<String,CCPM_storeEmployee__c> mapStoreSFIDandStoreManager = new Map<String,CCPM_storeEmployee__c>();
        Map<String,CCPM_storeEmployee__c> mapStoreIDandStoreManager = new Map<String,CCPM_storeEmployee__c>();
        List<Lead> lstObjListAfterAssigningOwnership = new List<Lead>();
        List<Lead> lstObjListAfterpopulatingStoreManager = new List<Lead>();
        List<Lead> lstObjListAfterpopulatingAccount = new List<Lead>();
        if(lstNewLeads!=null && lstNewLeads.size()>0){
            for(Lead objLead: lstNewLeads){
                if(objLead.CCPM_cartlastHandledBy__c != null){
                    //add last cart handled by field to the list from all the leads
                    setCartLastHandledBy.add(objLead.CCPM_cartlastHandledBy__c);
                }
                if(objLead.CCPM_accountUniqueID__c != null){
                    //add account number field to the list from all the leads
                    setCustomerAccountNumber.add(objLead.CCPM_accountUniqueID__c);
                }
                if(objLead.CCPM_storeID__c != null){
                    //add store ID field to the list from all the leads
                    setStoreId.add(objLead.CCPM_storeID__c);
                }
            }
            //Create Account Map
            if( setCustomerAccountNumber!= null  && setCustomerAccountNumber.size() > 0){
                try{
                    //Query for the list of active users using cartlasthandledby field
                    lstCustomerAccount = [Select Id,CCPM_store__c,CCPM_store__r.id,CCPM_store__r.CCPM_storeID__c,CCPM_accountNumber__c,CCPM_storeID__c, CCPM_accountUniqueID__c from Account where Account.CCPM_accountUniqueID__c IN : setCustomerAccountNumber];
                }
                catch(Exception e){
                    CCPM_LogMessageUtility.logMessage(e,'leadHandlerAssignOwnership','assignLeadOwnershipOnCreate','Exception thrown while querying Valid Users',true);
                }
                //Create the map for Account and Unique ID
                for(Account objAccount : lstCustomerAccount){
                    //Set of nearest store ID's
                    if(objAccount.CCPM_store__c!= null && objAccount.CCPM_store__r.CCPM_storeID__c != null){
                        setNearestStoreId.add(objAccount.CCPM_store__r.CCPM_storeID__c);
                    }
                    if(objAccount.CCPM_accountUniqueID__c != null){
                        mapAccountAndUniqueID.put(objAccount.CCPM_accountUniqueID__c, objAccount);
                    }
                }
                setStoreId.addAll(setNearestStoreId);
                setStoreId.remove(Null); 
            }
            
            //Get the list of all the required store records
            lstStoreRecords = getListofStoreRecords(setStoreId);
            if( lstStoreRecords!= null && lstStoreRecords.size()>0 ){
                mapStoreSFIdAndStore = getStoreAndStoreSFIDMap(lstStoreRecords);
                mapStoreIdAndStore = getStoreAndStoreIDMap(lstStoreRecords);
            }
            //Get the list of all the required employees
            lstEntireStoreEmployees = getEntireListOfEmployees(null,setCartLastHandledBy,setStoreId,mapStoreIdAndStore);
            //Make Map of cartlasthandledby and employee
            if( lstEntireStoreEmployees!= null && lstEntireStoreEmployees.size()>0){
                mapCartlastHandledByAndStoreEmp = getCartlastHandledByAndStoreEmpMap(lstEntireStoreEmployees);
                mapStoreIDandStoreManager = getStoreIDandStoreManagerMap(lstEntireStoreEmployees);
                mapStoreSFIDandStoreManager = getStoreandStoreManagerMap(lstEntireStoreEmployees);
            }
            //Assign account
            lstObjListAfterpopulatingAccount = assignAccountForLead(lstNewLeads, mapAccountAndUniqueID);
            //system.debug('@@@lstObjListAfterpopulatingAccount ' + lstObjListAfterpopulatingAccount);
            //Assign owner
            if( lstObjListAfterpopulatingAccount != null && !lstObjListAfterpopulatingAccount.isEmpty()  ){
                for(Lead objlead: lstObjListAfterpopulatingAccount)
                { 
                    Lead objl2 = new lead();
                    if(objlead.RecordTypeId!=CCPM_staticConstants.strProspectRecordTypeID && objlead.CCPM_isManualLead__c==false)
                    {
                        objl2 = assignOwnershipForLead(objlead,mapAccountAndUniqueID,mapCartlastHandledByAndStoreEmp,mapStoreSFIdAndStore,mapStoreIdAndStore,mapStoreIDandStoreManager,mapDistrictAndGroup);
                        lstObjListAfterAssigningOwnership.add(objl2); 
                    }
                    system.debug('the method is called');
                    
                }
            }
            //Assign manager
            if(lstObjListAfterAssigningOwnership!= null && !lstObjListAfterAssigningOwnership.isEmpty() ){
                lstObjListAfterpopulatingStoreManager = assignStoreManagerForLeads(lstObjListAfterAssigningOwnership,mapStoreSFIDandStoreManager);
            }
        }
        //Return Leads
        if( lstObjListAfterpopulatingStoreManager!= null && !lstObjListAfterpopulatingStoreManager.isEmpty() ){
            return lstObjListAfterpopulatingStoreManager;   
        }
        else if( lstObjListAfterAssigningOwnership!= null && !lstObjListAfterAssigningOwnership.isEmpty() ){
            return lstObjListAfterAssigningOwnership;
        }
        else if( lstObjListAfterpopulatingAccount!= null && !lstObjListAfterpopulatingAccount.isEmpty() ){
            return lstObjListAfterpopulatingAccount;
        }
        else{
            return lstNewLeads;
        }
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method assigns account Holder and Account Unique ID
@param         list of new leads and map mapAccountAndUniqueID
@return        lead
*/  
    public static List<lead> assignAccountForLead(List<Lead> lstLeads, Map<String,Account> mapAccountAndUniqueID ){
        //Set Account and Account Number Using Account Unique ID
        for(Lead objlead: lstLeads){
            if(objlead.CCPM_accountUniqueID__c != null && objlead.RecordTypeId!=CCPM_staticConstants.strProspectRecordTypeID && objlead.CCPM_isManualLead__c==false){
                if(!mapAccountAndUniqueID.isEmpty() && mapAccountAndUniqueID.containsKey(objlead.CCPM_accountUniqueID__c)){
                    Account objAccount = mapAccountAndUniqueID.get(objlead.CCPM_accountUniqueID__c);
                    objlead.CCPM_Account__c     = objAccount.Id;
                    objlead.CCPM_accountNumber__c= objAccount.CCPM_accountNumber__c;   
                }
            }
        }
        return lstLeads;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method assigns Store Managers for Leads
@param         list of new leads and map mapAccountAndUniqueID
@return        List of leads
*/  
    public static List<lead> assignStoreManagerForLeads(List<Lead> lstLeads, Map<String,CCPM_storeEmployee__c> mapStoreSFIDandStoreManager ){
        //Set Account and Account Number Using Account Unique ID
        for(Lead objlead: lstLeads){
            //Make change to the assignment
            if(objlead.Store__c != null && !mapStoreSFIDandStoreManager.isEmpty() && mapStoreSFIDandStoreManager.containsKey(objlead.Store__c) && mapStoreSFIDandStoreManager.get(objlead.Store__c).CCPM_employee__c != null){
                objlead.CCPM_storeManager__c = mapStoreSFIDandStoreManager.get(objlead.Store__c).CCPM_employee__c;
            }
        }
        return lstLeads;
    }    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method retreives the list of all the store employees required for the current trigger instance
@param         Set of cartlasthandledby values and set of storeID's on the lead and the account level
@return        list of store employees
*/  
    public static List<CCPM_storeEmployee__c> getEntireListOfEmployees(Set<ID> SetOwnerIdFromUpdate, Set<String> lstCartLastHandledBy,Set<String> setStoreId,Map<String,CCPM_Store__c> mapStoreIdAndStore){
        //Set Account and Account Number Using Account Unique ID
        List<CCPM_storeEmployee__c> lstEntireStoreEmployees = new List<CCPM_storeEmployee__c>();
        List<User> lstOwner = new List<User>();
        Set<ID> setownerID = new Set<ID>();
        Set<String> setStoreSFID = new Set<String>();
        for(String idstoreID : setStoreId){
            if(idstoreID!= null && mapStoreIdAndStore.containsKey(idstoreID) && mapStoreIdAndStore.get(idstoreID).id != null){
                setStoreSFID.add(mapStoreIdAndStore.get(idstoreID).id);
            }
        }
        if(SetOwnerIdFromUpdate != null && SetOwnerIdFromUpdate.size()>0){
            setownerID.addAll(SetOwnerIdFromUpdate);
        }
        
        List<CCPM_storeEmployee__c> lstStoreEmployees = new List<CCPM_storeEmployee__c>();
        //check if list of cartlasthandledby values is empty
        if( lstCartLastHandledBy!= null && lstCartLastHandledBy.size()>0 ){
            try{
                //Query for the list of active users using cartlasthandledby field
                lstOwner = [Select id,CCPM_commissionableRepID__c from User Where IsActive = True and CCPM_commissionableRepID__c IN : lstCartLastHandledBy];
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'leadHandlerAssignOwnership','getEntireListOfEmployees','Exception thrown while querying Valid Users',true);
            }  
        }
        //system.debug('@@@lstOwner: ' + lstOwner);
        //check if list of owners is empty and copy it to the set of owners
        if( lstOwner != null && lstOwner.size()>0 ){
            for(User objlstOwner : lstOwner){
                setownerID.add(objlstOwner.id);
            }
        }
        //Query for valid store employees using list of valid store owners
        if(( setownerID != null && setownerID.size()>0 ) || ( setStoreSFID!= null && setStoreSFID.size()>0 )){
            try{
                //Query for the list of active users using cart last handled by field and the employees from all the required stores using storeID's
                //lstStoreEmployees  = [Select id,CCPM_Store__c,CCPM_Store__r.id,CCPM_Store__r.CCPM_storeID__c,CCPM_StoreID__c,CCPM_role__c,CCPM_IsActive__c, CCPM_employee__c,CCPM_employee__r.name,CCPM_employee__r.Id,CCPM_employee__r.CCPM_EmployeeId__c ,CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where CCPM_employee__c IN : stownerID OR CCPM_StoreID__c IN :stStoreId];
                //lstStoreEmployees  = [Select id,CCPM_Store__c,CCPM_Store__r.id,CCPM_Store__r.CCPM_StoreID__c,CCPM_role__c,CCPM_IsActive__c, CCPM_employee__c,CCPM_employee__r.name,CCPM_employee__r.Id,CCPM_employee__r.CCPM_EmployeeId__c ,CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where CCPM_employee__c IN : setownerID OR CCPM_Store__c IN :setStoreSFID];
                //US1683 - Added a condition for Store Employee IsActive is TRUE
                lstStoreEmployees  = [Select id,CCPM_Store__c,CCPM_Store__r.id,CCPM_Store__r.CCPM_StoreID__c,CCPM_role__c,CCPM_IsActive__c, CCPM_employee__c,CCPM_employee__r.name,CCPM_employee__r.Id,CCPM_employee__r.CCPM_EmployeeId__c, CCPM_employee__r.IsActive ,CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where (CCPM_employee__c IN : setownerID OR CCPM_Store__c IN :setStoreSFID) AND CCPM_IsActive__c = true AND CCPM_employee__r.IsActive = true];
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'leadHandlerAssignOwnership','getEntireListOfEmployees','Exception thrown while querying Valid Employees',true);
            } 
        }
        //system.debug('@@@lstStoreEmployees: '+ lstStoreEmployees);
        //Check if the list of store employees related to all the leads is empty
        if( lstStoreEmployees!= null && lstStoreEmployees.size()>0 ){
            //add stores of store employees to stStoreId
            for(CCPM_storeEmployee__c objStoreEmp : lstStoreEmployees){
                if(!setStoreSFID.contains(objStoreEmp.CCPM_Store__r.id)){
                    //Add unique Store ID's to the set of store ID's
                    setStoreSFID.add(objStoreEmp.CCPM_Store__r.id);
                }
            }
            //system.debug('@@@setStoreSFID ' + setStoreSFID);
            //Query for valid store employees using list of valid store owners
            try{
                //Query for the list of active users using cart last handled by field and the employees from all the required stores using storeID's
                lstEntireStoreEmployees  = [Select id,CCPM_Store__c,CCPM_Store__r.id,CCPM_Store__r.CCPM_StoreID__c,CCPM_role__c,CCPM_IsActive__c, CCPM_employee__c,CCPM_employee__r.name,CCPM_employee__r.Id,CCPM_employee__r.CCPM_EmployeeId__c,CCPM_employee__r.IsActive ,CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where CCPM_Store__c IN :setStoreSFID AND CCPM_IsActive__c = true AND CCPM_employee__r.IsActive = true];
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'leadHandlerAssignOwnership','getEntireListOfEmployees','Exception thrown while querying Valid Employees',true);
            }
        }
        
        return lstEntireStoreEmployees;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method retreives the list of all store records goven a set of store ID's
@param         Set of Store ID's
@return        List of Store Records
*/  
    public static List<CCPM_Store__c> getListofStoreRecords(Set<String> stStoreId){
        List<CCPM_Store__c> lstStoreRecords = new List<CCPM_Store__c>();
        if( stStoreId!= null && stStoreId.size()>0 ){
            try{
                //Query for the list of active users using cart last handled by field
                lstStoreRecords = [Select Id,Name,CCPM_IsActive__c, CCPM_storeID__c,CCPM_market__c,CCPM_TimeZone__c from CCPM_Store__c where CCPM_storeID__c IN:stStoreId AND CCPM_IsActive__c = true];
            }
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'leadHandlerAssignOwnership','getListofStoreRecords','Exception thrown while querying Valid Employees',true);
            }
        }
        return lstStoreRecords;
    } 
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method constructs a map of cartlasthandledby value and store employee
@param         list of store employees
@return        map of cartlasthandledby and store employee record
*/    
    public static Map<String,CCPM_storeEmployee__c> getCartlastHandledByAndStoreEmpMap(List<CCPM_storeEmployee__c> lstEntireStoreEmployees){
        Map<String,CCPM_storeEmployee__c> mapCartlastHandledByAndStoreEmp = new Map<String,CCPM_storeEmployee__c>();
        //system.debug('@@@lstEntireStoreEmployees '+lstEntireStoreEmployees);
        //Create map with stores and list of related store employee
        if(lstEntireStoreEmployees!= null && lstEntireStoreEmployees.size()>0){
            for(CCPM_storeEmployee__c objStoreEmp : lstEntireStoreEmployees){
                if(objStoreEmp.CCPM_employee__r.CCPM_commissionableRepID__c != null && !mapCartlastHandledByAndStoreEmp.containsKey(objStoreEmp.CCPM_employee__r.CCPM_commissionableRepID__c)){
                    //system.debug('@@@objStoreEmp.CCPM_employee__r.CCPM_commissionableRepID__c ' + objStoreEmp.CCPM_employee__r.CCPM_commissionableRepID__c);
                    mapCartlastHandledByAndStoreEmp.put(objStoreEmp.CCPM_employee__r.CCPM_commissionableRepID__c, objStoreEmp);
                }
            }
        }
        //system.debug('@@@mapCartlastHandledByAndStoreEmp: '+mapCartlastHandledByAndStoreEmp);
        return mapCartlastHandledByAndStoreEmp;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method creates a map of storeID(SFID) and the store
@param         list of store records
@return        map of store and store ID
*/      
    public static Map<ID,CCPM_Store__c> getStoreAndStoreSFIDMap(List<CCPM_Store__c> lstStoreRecords){
        Map<ID,CCPM_Store__c> mapStoreSFIdAndStore = new Map<ID,CCPM_Store__c>();
        if( lstStoreRecords!= null && lstStoreRecords.size()>0 ){
            for(CCPM_Store__c objStore : lstStoreRecords){
                if(!mapStoreSFIdAndStore.containsKey(objStore.Id)){
                    mapStoreSFIdAndStore.put(objStore.Id,objStore);
                }
            }
        }
        return mapStoreSFIdAndStore;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method creates a map of storeID(SFID) and the store
@param         list of store records
@return        map of store and store ID
*/        
    
    public static Map<String,CCPM_Store__c> getStoreAndStoreIDMap(List<CCPM_Store__c> lstStoreRecords){
        Map<String,CCPM_Store__c> mapStoreIdAndStore = new Map<String,CCPM_Store__c>();
        if(lstStoreRecords!= null && lstStoreRecords.size()>0){
            for(CCPM_Store__c objStore : lstStoreRecords){
                if(!mapStoreIdAndStore.containsKey(objStore.CCPM_storeID__c)){
                    mapStoreIdAndStore.put(objStore.CCPM_storeID__c,objStore);
                }
            }
        }
        return mapStoreIdAndStore;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method assigns ownership for a lead
@param         Lead, Map of account and  list of store records
@return        lead
*/     
    
    public static lead assignOwnershipForLead(Lead objLead,Map<String,Account> mapAccountAndUniqueID,Map<String,CCPM_storeEmployee__c> mapCartlastHandledByAndStoreEmp, Map<ID,CCPM_Store__c> mpStoreSFIdAndStore,Map<String,CCPM_Store__c> mpStoreIdAndStore,Map<String,CCPM_storeEmployee__c> mapStoreIDandStoreManager,Map<String,Group> mapDistrictAndGroup){
        //Assign Ownership
        Boolean boolforCartLastHandledBy = false;
        Boolean boolflagforStoreId = false;
        Boolean boolflagforAccountNearestStore = false;
        Boolean boolflagforHandlingGarbageMarketValue = false;
        system.debug('@@@assignOwnershipForLead ');
        if(objLead.CCPM_cartlastHandledBy__c!=null){
            //Construct the set of all related employees
            //Assign based on CartLastHandledBy
            //system.debug('@@@AssignBasedOnCLHB');
            //system.debug('@@@mapCartlastHandledByAndStoreEmp ' + mapCartlastHandledByAndStoreEmp);
            
            if(!mapCartlastHandledByAndStoreEmp.isEmpty() && mapCartlastHandledByAndStoreEmp.containsKey(objLead.CCPM_cartlastHandledBy__c) && !boolforCartLastHandledBy){
                //Get the store employee for ownership 
                CCPM_storeEmployee__c objStoreEmp = mapCartlastHandledByAndStoreEmp.get(objLead.CCPM_cartlastHandledBy__c);
                if(objStoreEmp != null && objStoreEmp.CCPM_employee__r.CCPM_commissionableRepID__c!= null && objLead.CCPM_cartlastHandledBy__c == objStoreEmp.CCPM_employee__r.CCPM_commissionableRepID__c ){
                    objLead.OwnerId = objStoreEmp.CCPM_employee__r.Id;
                    objLead.Store__c = objStoreEmp.CCPM_Store__c;
                    boolforCartLastHandledBy = true;
                }
            }
        }
        if(!boolforCartLastHandledBy && objLead.CCPM_storeID__c!= null){
            //Assign using store ID
            //Get the store employee for ownership
            //system.debug('@@@AssignBasedOnStore');
            if(!mapStoreIDandStoreManager.isEmpty() && mapStoreIDandStoreManager.containsKey(objLead.CCPM_storeID__c)){
                CCPM_storeEmployee__c objStoreEmpForOwner = mapStoreIDandStoreManager.get(objLead.CCPM_storeID__c);
                if((objStoreEmpForOwner.CCPM_role__c == CCPM_staticConstants.strStoreManager || objStoreEmpForOwner.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager) && !boolflagforStoreId){
                    objLead.OwnerId = objStoreEmpForOwner.CCPM_employee__r.Id;
                    objLead.Store__c = objStoreEmpForOwner.CCPM_Store__c;
                    boolflagforStoreId = true;
                }
            }
            else if(!mpStoreIdAndStore.isEmpty() && mpStoreIdAndStore.containsKey(objLead.CCPM_storeID__c)){
                objLead.Store__c = mpStoreIdAndStore.get(objLead.CCPM_storeID__c).id;
                if(mapDistrictAndGroup.containsKey(mpStoreIdAndStore.get(objLead.CCPM_storeID__c).CCPM_market__c)){
                    objLead.OwnerId = mapDistrictAndGroup.get(mpStoreIdAndStore.get(objLead.CCPM_storeID__c).CCPM_market__c).id; 
                    boolflagforStoreId = true;
                }
                boolflagforHandlingGarbageMarketValue = true;
            }
        }
        //Account Nearest Store
        if(!boolforCartLastHandledBy && !boolflagforStoreId && !boolflagforHandlingGarbageMarketValue && objLead.CCPM_accountUniqueID__c != null && !mapAccountAndUniqueID.isEmpty() 
           && mapAccountAndUniqueID.containsKey(objLead.CCPM_accountUniqueID__c) && (mapAccountAndUniqueID.get(objLead.CCPM_accountUniqueID__c).CCPM_store__c) != null){
               //system.debug('@@@AssignBasedOnNearest');
               CCPM_storeEmployee__c objStoreEmpForOwner = new CCPM_storeEmployee__c();
               objLead.Store__c =    mapAccountAndUniqueID.get(objLead.CCPM_accountUniqueID__c).CCPM_store__c;
               if(!mpStoreSFIdAndStore.isEmpty() && mpStoreSFIdAndStore.containsKey((mapAccountAndUniqueID.get(objLead.CCPM_accountUniqueID__c).CCPM_store__c)) 
                  && (mpStoreSFIdAndStore.get((mapAccountAndUniqueID.get(objLead.CCPM_accountUniqueID__c).CCPM_store__c))) != null 
                  && !mapStoreIDandStoreManager.isEmpty() && mapStoreIDandStoreManager.ContainsKey(mpStoreSFIdAndStore.get((mapAccountAndUniqueID.get(objLead.CCPM_accountUniqueID__c).CCPM_store__c)).CCPM_storeID__c)){
                      //Get the store employee for ownership   
                      objStoreEmpForOwner = mapStoreIDandStoreManager.get(mpStoreSFIdAndStore.get((mapAccountAndUniqueID.get(objLead.CCPM_accountUniqueID__c).CCPM_store__c)).CCPM_storeID__c);
                      if(objStoreEmpForOwner != null && (objStoreEmpForOwner.CCPM_role__c == CCPM_staticConstants.strStoreManager || objStoreEmpForOwner.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager) && !boolflagforAccountNearestStore){
                          objLead.OwnerId = objStoreEmpForOwner.CCPM_employee__r.Id;
                          //L1.Store__c = objStoreEmpForOwner.CCPM_Store__c;
                          boolflagforAccountNearestStore = true;
                      }
                  }
           }
        if(!boolforCartLastHandledBy && !boolflagforStoreId && !boolflagforAccountNearestStore){
            //Sys Admin
            //system.debug('@@@AssignDefault');
            if(objLead.Store__c != null && mapDistrictAndGroup!= null && !mapDistrictAndGroup.isEmpty() && mpStoreSFIdAndStore.containsKey(objLead.Store__c) && mapDistrictAndGroup.containsKey(mpStoreSFIdAndStore.get(objLead.Store__c).CCPM_market__c)){
                //system.debug('@@InsideMarket' + mpStoreSFIdAndStore.get(objLead.Store__c).CCPM_market__c);
                objLead.OwnerId = mapDistrictAndGroup.get(mpStoreSFIdAndStore.get(objLead.Store__c).CCPM_market__c).id; 
            }
            else{
                objLead.OwnerId = CCPM_staticConstants.strDataIntegrationUserQueue;
                objLead.Store__c = null;
                objLead.CCPM_storeManager__c = null;
            }
            //L1.Store__c = null;
        }   
        return objLead;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method constructs a map of store SFID and store manager
@param         list of leads, map of store employee and store, map of store ID and store
@return        map of of store SFID and store manager
*/     
    public static Map<String,CCPM_storeEmployee__c> getStoreandStoreManagerMap(List<CCPM_storeEmployee__c> lstEntireStoreEmployees){
        //System.debug('@@@InsideassignStoreManagerForLead');
        Map<String,CCPM_storeEmployee__c> mapStoreSFIDandStoreManager = new Map<String,CCPM_storeEmployee__c>();
        List<CCPM_storeEmployee__c> lstEntireStoreEmployeesCopy = new List<CCPM_storeEmployee__c>();
        lstEntireStoreEmployeesCopy.addAll(lstEntireStoreEmployees);
        for(Integer i=0; i<lstEntireStoreEmployeesCopy.size(); i++){
            if(lstEntireStoreEmployeesCopy[i].CCPM_role__c == CCPM_staticConstants.strStoreManager 
               && lstEntireStoreEmployeesCopy[i].CCPM_Store__c!=null &&  !mapStoreSFIDandStoreManager.containsKey(lstEntireStoreEmployeesCopy[i].CCPM_Store__c)){
                   mapStoreSFIDandStoreManager.put(lstEntireStoreEmployeesCopy[i].CCPM_Store__c,lstEntireStoreEmployeesCopy[i]) ;
                   lstEntireStoreEmployeesCopy.remove(i);
               }
        }
        for(CCPM_storeEmployee__c objStoreEmpForOwner: lstEntireStoreEmployeesCopy){
            if(objStoreEmpForOwner.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager
               && objStoreEmpForOwner.CCPM_Store__c!=null && !mapStoreSFIDandStoreManager.containsKey(objStoreEmpForOwner.CCPM_Store__c)){
                   mapStoreSFIDandStoreManager.put(objStoreEmpForOwner.CCPM_Store__c,objStoreEmpForOwner) ;
               } 
        }
        return mapStoreSFIDandStoreManager;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method constructs a map of store ID and store manager
@param         list of leads, map of store employee and store, map of store ID and store
@return        map of of store ID and store manager
*/     
    public static Map<String,CCPM_storeEmployee__c> getStoreIDandStoreManagerMap(List<CCPM_storeEmployee__c> lstEntireStoreEmployees){
        Map<String,CCPM_storeEmployee__c> mapStoreIDandStoreManager = new Map<String,CCPM_storeEmployee__c>();
        List<CCPM_storeEmployee__c> lstEntireStoreEmployeesCopy = new List<CCPM_storeEmployee__c>();
        lstEntireStoreEmployeesCopy.addAll(lstEntireStoreEmployees);
        for(Integer i=0; i<lstEntireStoreEmployeesCopy.size(); i++){
            if(lstEntireStoreEmployeesCopy[i].CCPM_role__c == CCPM_staticConstants.strStoreManager 
               && lstEntireStoreEmployeesCopy[i].CCPM_Store__c!=null && lstEntireStoreEmployeesCopy[i].CCPM_Store__r.CCPM_StoreID__c !=null &&  !mapStoreIDandStoreManager.containsKey(lstEntireStoreEmployeesCopy[i].CCPM_Store__r.CCPM_StoreID__c)){
                   mapStoreIDandStoreManager.put(lstEntireStoreEmployeesCopy[i].CCPM_Store__r.CCPM_StoreID__c,lstEntireStoreEmployeesCopy[i]) ;
                   lstEntireStoreEmployeesCopy.remove(i);
               }
        }
        for(CCPM_storeEmployee__c objStoreEmpForOwner: lstEntireStoreEmployeesCopy){
            if(objStoreEmpForOwner.CCPM_role__c == CCPM_staticConstants.strStoreAssistantManager
               && objStoreEmpForOwner.CCPM_Store__c!=null && objStoreEmpForOwner.CCPM_Store__r.CCPM_StoreID__c !=null && !mapStoreIDandStoreManager.containsKey(objStoreEmpForOwner.CCPM_Store__r.CCPM_StoreID__c)){
                   mapStoreIDandStoreManager.put(objStoreEmpForOwner.CCPM_Store__r.CCPM_StoreID__c,objStoreEmpForOwner) ;
               } 
        }
        return mapStoreIDandStoreManager;
    }
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method constructs a map of store ID and store manager
@param         list of leads, map of store employee and store, map of store ID and store
@return        map of of store ID and store manager
*/     
    public static List<lead> assignTriggerSMSTimeOnInsert(List<lead> lstLeads, List<BusinessHours> lstBusinessHours, String strSourceCheck){
        System.debug('inside');
        try{
            BusinessHours objDefaultBusinessHour;
            for(Integer i=0; i<lstBusinessHours.size();i++){
                if(lstBusinessHours[i].IsDefault){
                    objDefaultBusinessHour = lstBusinessHours[i];
                    break;
                }
            }
            Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
            //Querying for active business hours from the org
            //system.debug('@@@lstBusinessHoursbefore' + lstBusinessHours);
            mapLeadAndBusinessHours = getCartIdORStoreIDAndBusinessHourMap(lstLeads,objDefaultBusinessHour,lstBusinessHours);
            //system.debug('@@@lstBusinessHours' + lstBusinessHours);
            for(Lead objLead: lstLeads){
                //Insert CCPM_TriggerInitialSMSDateTime__c values selectively
                if(objlead.CCPM_Type__c != ccpm_staticConstants.strLeadTypeCampaignLead || strSourceCheck == CCPM_staticConstants.strSourceCheck ){
                    if(CCPM_staticConstants.strInitialSMSInterval != null && CCPM_staticConstants.strFollowUpSMSInterval != null && objLead.RecordTypeId!=CCPM_staticConstants.strProspectRecordTypeID)
                    {   
                        if(objlead.recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && objlead.CCPM_Type__c == CCPM_staticConstants.strLeadTypeCampaignLead && 
                           !mapLeadAndBusinessHours.isEmpty() && objLead.Store__c != null && mapLeadAndBusinessHours.get(objLead.Store__c)!= null ){
                               //system.debug('@@@insideIf');
                               objLead.CCPM_ActualSMSScheduleDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours((mapLeadAndBusinessHours.get(objLead.Store__c)), System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
                               //System.debug('@@@l.CCPM_TriggerInitialSMSDateTime__c '+l.CCPM_TriggerInitialSMSDateTime__c + '@@@BHB '+mapLeadAndBusinessHours.get(l.CCPM_cartID__c));
                           }
                        else if(!mapLeadAndBusinessHours.isEmpty() && objLead.CCPM_cartID__c != null && mapLeadAndBusinessHours.get(objLead.CCPM_cartID__c)!= null ){
                            //system.debug('@@@insideIf');
                            objLead.CCPM_ActualSMSScheduleDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours((mapLeadAndBusinessHours.get(objLead.CCPM_cartID__c)), System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
                            //System.debug('@@@l.CCPM_TriggerInitialSMSDateTime__c '+l.CCPM_TriggerInitialSMSDateTime__c + '@@@BHB '+mapLeadAndBusinessHours.get(l.CCPM_cartID__c));
                        }
                        else{
                            //system.debug('@@@insideElse');
                            objLead.CCPM_ActualSMSScheduleDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours(objDefaultBusinessHour, System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
                        }
                    } 
                }
            }
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandlerAssignOwnership','assignLeadOwnershipOnCreate','Exception thrown while querying Customer Account Fields',true);
            
        }
        return lstLeads;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method inserts records in the sms messages object when a lead/prospect record is created.
@param         list of new leads
@return        Void(None)
*/ 
    public static Map<String,BusinessHours> getCartIdORStoreIDAndBusinessHourMap(list<Lead> lstNewLeads,BusinessHours objDefaultBusinessHour,List<BusinessHours> lstBusinessHours)   
    {
        //List<BusinessHours> lstBusinessHours; //Object for Business hours
        map<String,String> mapStoreAndLeadid = new map<String,String>();
        map<String,BusinessHours> mapTimeZoneAndBusinessHours = new map<String,BusinessHours>();
        Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
        //Querying for active business hours from the org
        try{
            //Querying for active business hours from the org
            Set<ID> setStoreForBusinessHours = new Set<ID>();
            for(Lead objLead: lstNewLeads)
            {
                if(objLead.Store__c != null){
                    setStoreForBusinessHours.add(objLead.Store__c);
                }
            }
            Set<String> setTimeZones = new Set<String>();
            if(setStoreForBusinessHours != null && setStoreForBusinessHours.size()>0){
                //system.debug('@@@setStoreForBusinessHours'+setStoreForBusinessHours);
                List<CCPM_Store__c> lstStoreRecords = [Select Id,name,CCPM_storeID__c,CCPM_TimeZone__c From CCPM_Store__c Where id IN :setStoreForBusinessHours];
                for(Integer i=0;i<lstNewLeads.size();i++){
                    for(Integer j=0;j<lstStoreRecords.size();j++){
                        //system.debug('@@@lstNewLeads[i].Store__c'+lstNewLeads[i].Store__c + '@@@lstStoreRecords[j].id' +lstStoreRecords[j].id);
                        if(lstNewLeads[i].Store__c == lstStoreRecords[j].id ){
                            if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectRecordTypeID ||
                               (lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_Type__c == CCPM_staticConstants.strLeadTypeCampaignLead))
                            {
                                if(lstNewLeads[i].Store__c != null && !(mapStoreAndLeadid.containsKey(lstNewLeads[i].Store__c))){
                                    mapStoreAndLeadid.put(lstNewLeads[i].Store__c, lstStoreRecords[j].CCPM_TimeZone__c);
                                }
                            }
                            else{
                                mapStoreAndLeadid.put(lstNewLeads[i].CCPM_cartID__c, lstStoreRecords[j].CCPM_TimeZone__c);
                            }
                        }
                    }
                }
                //System.debug('@@@mapStoreAndLeadid' +mapStoreAndLeadid);
                //List of business hours objects
                //lstBusinessHours  = [Select Id,name From BusinessHours Where IsActive = true];
                //Store Unique Time zones
                
                for(CCPM_Store__c ObjStore: lstStoreRecords){
                    setTimeZones.add(ObjStore.CCPM_TimeZone__c);
                }
            }
            else{
                //system.debug('@@@InsideElseOfgetCartIdORStoreIDAndBusinessHourMap');
                //lstBusinessHours  = [Select Id,name From BusinessHours Where IsActive = true and IsDefault = true];
                //default TimeZone
                setTimeZones.add('EST');
            }
            //List of unique timezones
            List<String> lstTimeZones = new List<String>();
            lstTimeZones.addAll(setTimeZones);
            //system.debug('@@@lstTimeZones'+lstTimeZones);
            for(Integer i=0;i<lstTimeZones.size();i++){
                for(Integer j=0;j<lstBusinessHours.size();j++){
                    //Check if the name of the Business hour consists of the name of time zone and add it to a map
                    //system.debug('@@@lstBusinessHours[j].name'+lstBusinessHours[j].name + '@@@lstTimeZones.get(i)' +lstTimeZones.get(i));
                    if(lstTimeZones.get(i) != null && lstBusinessHours[j].name.contains(lstTimeZones.get(i))){
                        mapTimeZoneAndBusinessHours.put(lstTimeZones.get(i), lstBusinessHours[j]);
                    }
                }
            }
            //System.debug('@@@mapTimeZoneAndBusinessHours' +mapTimeZoneAndBusinessHours);
            
            for(Integer i=0;i<lstNewLeads.size();i++){
                if(!mapStoreAndLeadid.isEmpty()){
                    if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectRecordTypeID ||
                       (lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_Type__c == CCPM_staticConstants.strLeadTypeCampaignLead))
                    {
                        if(lstNewLeads[i].Store__c != null && mapStoreAndLeadid.containsKey(lstNewLeads[i].Store__c) && mapTimeZoneAndBusinessHours.containsKey(mapStoreAndLeadid.get(lstNewLeads[i].Store__c))){
                            mapLeadAndBusinessHours.put(lstNewLeads[i].Store__c, mapTimeZoneAndBusinessHours.get(mapStoreAndLeadid.get(lstNewLeads[i].Store__c)));
                        }
                    }
                    else{
                        if(lstNewLeads[i].CCPM_cartID__c != null && mapStoreAndLeadid.containsKey(lstNewLeads[i].CCPM_cartID__c) && mapTimeZoneAndBusinessHours.containsKey(mapStoreAndLeadid.get(lstNewLeads[i].CCPM_cartID__c))){
                            mapLeadAndBusinessHours.put(lstNewLeads[i].CCPM_cartID__c, mapTimeZoneAndBusinessHours.get(mapStoreAndLeadid.get(lstNewLeads[i].CCPM_cartID__c)));
                        }
                    }
                }
                else{
                    if(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strProspectRecordTypeID ||(lstNewLeads[i].recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID && lstNewLeads[i].CCPM_Type__c == CCPM_staticConstants.strLeadTypeCampaignLead))
                    {
                        if(lstNewLeads[i].Store__c != null){
                            mapLeadAndBusinessHours.put(lstNewLeads[i].Store__c,objDefaultBusinessHour);
                        }
                    }
                    else{
                        if(lstNewLeads[i].CCPM_cartID__c != null){
                            mapLeadAndBusinessHours.put(lstNewLeads[i].CCPM_cartID__c,objDefaultBusinessHour);
                        }
                    }
                }
            }
            return mapLeadAndBusinessHours;
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandlerAssignOwnership','setTriggerFollowUpSMSDateTime','Exception thrown while querying business hours',true);
            return null;
        }
    }
    /**
@author         Sriraman Sridharan
@description    This method retrieves the business hours by retrirving the business hours defined
at the org level
@param          list of new leads
@return         Void(None)
*/  
    public static DateTime calculateTimeToTriggerSMSWithInBusinessHours(BusinessHours objbh, Datetime inputDatetime) {
        // retrieves list of business hours which are active
        // if date/time is within the business hours, if yes then no change 
        //system.debug('@@@objbh ' + objbh);
        if(BusinessHours.isWithin(objbh.id,inputDatetime)){
            System.debug('@@@ inputDatetime : ' + inputDatetime);
            return inputDatetime;
        } 
        // if date/time is outside the business hours, then get the next date/time
        else{
            Datetime nextstart;
            nextStart = BusinessHours.nextStartDate(objbh.id, inputDatetime); 
            System.debug('@@@ NextStart : ' + nextStart);
            return nextStart;
        }
    }
    
    /**
@author         Sriraman Sridharan
@description    This method retrieves the map of queue and the store district name
@param          list of new leads
@return         Void(None)
*/  
/*
    public static Map<String,Group> getMapOfStoreDistrictAndGroup() {
        Map<String,Group> mapDistrictAndGroup = new Map<String,Group>();
        Try{
            List<Group> lstQueues = new List<Group>([Select id, name from Group where Type = 'Queue']);
            if(lstQueues != null && !lstQueues.isEmpty()){
                for(Group objGroup : lstQueues){
                    if(objGroup != null && !mapDistrictAndGroup.containsKey(objGroup.Name)){
                        mapDistrictAndGroup.put(objGroup.Name, objGroup);
                    }
                }
            }
        }Catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandlerAssignOwnership','getMapOfStoreDistrictAndGroup','Exception thrown while querying Queues',true);
        }
        return mapDistrictAndGroup;
    }  
    */
     public static Map<String,Group> getMapOfStoreDistrictAndGroup() {
        Map<String,Group> objDistrictAndGroup = CCPM_utility.mapCopyDistrictAndGroup;
        Map<String,Group> mapDistrictAndGroup = new Map<String,Group>();
        Try{
            if(objDistrictAndGroup == null){
            List<Group> lstQueues = new List<Group>([Select id, name from Group where Type = 'Queue']);
            if(lstQueues != null && !lstQueues.isEmpty()){
                for(Group objGroup : lstQueues){
                    if(objGroup != null && !mapDistrictAndGroup.containsKey(objGroup.Name)){
                        mapDistrictAndGroup.put(objGroup.Name, objGroup);
                    }
                }
                 CCPM_utility.mapCopyDistrictAndGroup =mapDistrictAndGroup;
            	}
                
            }
            else{
                mapDistrictAndGroup = objDistrictAndGroup;
            }
        }Catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadHandlerAssignOwnership','getMapOfStoreDistrictAndGroup','Exception thrown while querying Queues',true);
        }
        return mapDistrictAndGroup;
    }  

    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method is targeted to populate store and ownership fields on the lead during update
@param         list of new leads, old leads
@return        Void
*/ 
    public static List<Lead> assignLeadOwnershipOnUpdate(list<Lead> lstNewLeads ,list<Lead> lstOldLeads , List<BusinessHours> lstBusinessHours,Map<String,Group> mapDistrictAndGroup)
    {
        if(!CCPM_staticConstants.boolCustomSwitch)
        {
            Set<ID> setOwnerId                 = new Set<ID>();   //list of Owner ID's from User object
            Set<String> setCartLastHandledBy    = new Set<String>();//set of cartLastHandledBy Values
            Set<String> setStoreId               = new Set<String>();//set of store Id's from the lead object
            Set<String> setCustomerAccountNumber= new Set<String>();//Set of Customer Account Numbers from the leads
            Boolean ownerAssigned               = False;            //boolean value to check if the owner is assigned to a sales rep
            Set<String> setNearestStoreId        = new Set<String>();  
            set<id> setQueueID = new set<id>();
            List<CCPM_storeEmployee__c> lstEntireStoreEmployees = new List<CCPM_storeEmployee__c>();        
            List<Account> lstCustomerAccount = new List<Account>();       
            List<CCPM_Store__c> lstStoreRecords = new List<CCPM_Store__c>();
            Map<String,Account> mapAccountAndUniqueID = new Map<String, Account>();
            Map<ID,CCPM_Store__c> mapStoreSFIdAndStore = new Map<ID,CCPM_Store__c>();
            Map<String,CCPM_Store__c> mapStoreIdAndStore = new Map<String,CCPM_Store__c>();
            List<CCPM_storeEmployee__c> lstStoreEmp = new List<CCPM_storeEmployee__c>();
            Map<String,CCPM_storeEmployee__c> mapCartlastHandledByAndStoreEmp = new Map<String,CCPM_storeEmployee__c>();
            Map<String,CCPM_storeEmployee__c> mapStoreSFIDandStoreManager = new Map<String,CCPM_storeEmployee__c>();
            Map<String,CCPM_storeEmployee__c> mapStoreIDandStoreManager = new Map<String,CCPM_storeEmployee__c>();
            Map<String,CCPM_storeEmployee__c> mapOwnerIDandStore = new Map<String,CCPM_storeEmployee__c>();
            Map<String,String> mapLeadOwnerID = new map<string,String>();
            List<Lead> lstObjListAfterAssigningOwnership = new List<Lead>();
            Set<Lead> setUpdatedLeads = new Set<Lead>();
            List<Lead> ListUpdateAccountInLeads = new List<Lead>();
            List<Lead> lstObjListAfterpopulatingAccount = new List<Lead>();
            if(mapDistrictAndGroup!=null && !mapDistrictAndGroup.isEmpty())
            {
                setQueueID.addAll(CCPM_leadHandler.getSetOfQueueID(mapDistrictAndGroup));         
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
                           setOwnerId.add(lstNewLeads[i].OwnerId);
                           setUpdatedLeads.add(lstNewLeads[i]);
                           if(!mapLeadOwnerID.containsKey(lstNewLeads[i].id)){
                               mapLeadOwnerID.put(lstNewLeads[i].id, lstNewLeads[i].OwnerId); 
                           }
                       }
                    if(lstNewLeads[i].CCPM_cartlastHandledBy__c!=null && lstNewLeads[i].CCPM_cartlastHandledBy__c!=lstOldLeads[i].CCPM_cartlastHandledBy__c){
                        //add last cart handled by field to the list from all the leads
                        setCartLastHandledBy.add(lstNewLeads[i].CCPM_cartlastHandledBy__c);
                        setUpdatedLeads.add(lstNewLeads[i]);
                    }
                    if(lstNewLeads[i].CCPM_accountUniqueID__c!=null && lstNewLeads[i].CCPM_accountUniqueID__c!=lstOldLeads[i].CCPM_accountUniqueID__c){
                        //add account number field to the list from all the leads
                        setUpdatedLeads.add(lstNewLeads[i]);
                        ListUpdateAccountInLeads.add(lstNewLeads[i]);
                    }
                    if(lstNewLeads[i].CCPM_storeID__c!=null && lstNewLeads[i].CCPM_storeID__c!=lstOldLeads[i].CCPM_storeID__c){
                        //add store ID field to the list from all the leads
                        setUpdatedLeads.add(lstNewLeads[i]);
                    }
                    if(lstNewLeads[i].CCPM_storeID__c!=null){
                        setStoreId.add(lstNewLeads[i].CCPM_storeID__c);
                    }
                    if(lstNewLeads[i].CCPM_accountUniqueID__c!=null){
                        setCustomerAccountNumber.add(lstNewLeads[i].CCPM_accountUniqueID__c);  
                    } 
                }
                //system.debug('@@@stStoreId' + setStoreId);
            }
            //Create Account Map
            if( setCustomerAccountNumber!= null  && setCustomerAccountNumber.size() > 0){
                try{
                    //Query for the list of active users using cartlasthandledby field
                    lstCustomerAccount = [Select Id,CCPM_store__c,CCPM_store__r.id,CCPM_store__r.CCPM_storeID__c,CCPM_accountNumber__c,CCPM_storeID__c, CCPM_accountUniqueID__c from Account where Account.CCPM_accountUniqueID__c IN : setCustomerAccountNumber];
                }
                catch(Exception e){
                    CCPM_LogMessageUtility.logMessage(e,'leadHandlerAssignOwnership','assignLeadOwnershipOnCreate','Exception thrown while querying Valid Users',true);
                }
                //Create the map for Account and Unique ID
                if(lstCustomerAccount!= null && lstCustomerAccount.size() >0){
                    for(Account objAccount : lstCustomerAccount){
                        //Set of nearest store ID's
                        if(objAccount.CCPM_store__c!= null && objAccount.CCPM_store__r.CCPM_storeID__c != null){
                            setNearestStoreId.add(objAccount.CCPM_store__r.CCPM_storeID__c);
                        }
                        if(objAccount.CCPM_accountUniqueID__c != null){
                            mapAccountAndUniqueID.put(objAccount.CCPM_accountUniqueID__c, objAccount);
                        }
                    }
                    if(setNearestStoreId != null && !setNearestStoreId.isEmpty()){
                        setStoreId.addAll(setNearestStoreId);
                        setStoreId.remove(Null);  
                    }
                }
            }
            //Get the list of all the required store records
            lstStoreRecords = getListofStoreRecords(setStoreId);
            if( lstStoreRecords!= null && lstStoreRecords.size()>0 ){
                mapStoreSFIdAndStore = getStoreAndStoreSFIDMap(lstStoreRecords);
                mapStoreIdAndStore = getStoreAndStoreIDMap(lstStoreRecords);
            }
            //Get the list of all the required employees
            lstEntireStoreEmployees = getEntireListOfEmployees(SetOwnerId,setCartLastHandledBy,setStoreId,mapStoreIdAndStore);
            //Make Map of cartlasthandledby and employee
            if( lstEntireStoreEmployees!= null && lstEntireStoreEmployees.size()>0){
                mapCartlastHandledByAndStoreEmp = getCartlastHandledByAndStoreEmpMap(lstEntireStoreEmployees);
                mapStoreIDandStoreManager = getStoreIDandStoreManagerMap(lstEntireStoreEmployees);
                mapStoreSFIDandStoreManager = getStoreandStoreManagerMap(lstEntireStoreEmployees);
                mapOwnerIDandStore = getOwnerIDandStoreEmpMap(lstEntireStoreEmployees);
            }
            //Assign account
            lstObjListAfterpopulatingAccount = assignAccountForLead(ListUpdateAccountInLeads, mapAccountAndUniqueID);
            //system.debug('@@@lstObjListAfterpopulatingAccount ' + lstObjListAfterpopulatingAccount);
            //Assign Ownership
            for(Lead objlead: setUpdatedLeads)
            { 
                //Check if the ownership is (manually/script) updated
                if(!mapLeadOwnerID.isEmpty() && mapLeadOwnerID.containsKey(objlead.Id) && setQueueID!=null && !setQueueID.isEmpty() && !setQueueID.contains(objlead.OwnerId)){
                    Lead objlead1 = new lead();
                    objlead1 = ValidateOwnershipForLead(objlead,mapOwnerIDandStore,mapStoreSFIDandStoreManager);
                    lstObjListAfterAssigningOwnership.add(objlead1);
                }
                else{
                    Lead objlead1 = new lead();
                    objlead1 = assignOwnershipForLead(objlead,mapAccountAndUniqueID,mapCartlastHandledByAndStoreEmp,mapStoreSFIdAndStore,mapStoreIdAndStore,mapStoreIDandStoreManager,mapDistrictAndGroup);
                    if(objlead1.Store__c != null && !mapStoreSFIDandStoreManager.isEmpty() && mapStoreSFIDandStoreManager.containsKey(objlead1.Store__c) && mapStoreSFIDandStoreManager.get(objlead1.Store__c).CCPM_employee__c != null){
                        objlead1.CCPM_storeManager__c = mapStoreSFIDandStoreManager.get(objlead1.Store__c).CCPM_employee__c;
                    }
                    else{
                        objlead1.CCPM_storeManager__c = null;
                    }
                    lstObjListAfterAssigningOwnership.add(objlead1); 
                }
            }
        }
        return lstNewLeads;
    }    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method validates the ownership for a lead on update
@param         Lead, Map of ownerID and StoreEmp, Map of store SFID and Store Manager
@return        lead
*/     
    
    public static lead ValidateOwnershipForLead(Lead objLead,Map<String,CCPM_storeEmployee__c> mapOwnerIDandStoreEmp,Map<String,CCPM_storeEmployee__c> mapStoreSFIDandStoreManager){
        //Assign Ownership
        //System.debug('@@@ValidateOwnershipForLead');
        if(mapOwnerIDandStoreEmp != null && mapOwnerIDandStoreEmp.containsKey(objLead.OwnerId)){
            CCPM_storeEmployee__c objStoreEmp = mapOwnerIDandStoreEmp.get(objLead.OwnerId);
            if(objStoreEmp != null && objStoreEmp.CCPM_employee__c!= null && objLead.OwnerId == objStoreEmp.CCPM_employee__c ){
                //system.debug('@@@objStoreEmp.CCPM_Store__c ' + objStoreEmp.CCPM_Store__c);
                objLead.Store__c = objStoreEmp.CCPM_Store__c;
                if(objlead.Store__c != null && !mapStoreSFIDandStoreManager.isEmpty() && mapStoreSFIDandStoreManager.containsKey(objlead.Store__c) && mapStoreSFIDandStoreManager.get(objlead.Store__c).CCPM_employee__c != null){
                    objlead.CCPM_storeManager__c = mapStoreSFIDandStoreManager.get(objlead.Store__c).CCPM_employee__c;
                }
                else{
                    objlead.CCPM_storeManager__c = null;
                }
            }
            else{
                //system.debug('@@@Error');
                objlead.addError('Please ensure the Lead Owner is a store employee.');
            }
        }
        else{
            //system.debug('@@@ErrorMapEmpty');
            objlead.addError('Please ensure the Lead Owner is a store employee.');
        }
        return objLead;
    }
    
    /**
@author        Sriraman Sridharan (Deloitte)
@description   This method constructs a map of Owner ID and store manager
@param         list of leads, map of store employee and store, map of store ID and store
@return        map of of store ownerID and Store Employee
*/     
    public static Map<String,CCPM_storeEmployee__c> getOwnerIDandStoreEmpMap(List<CCPM_storeEmployee__c> lstEntireStoreEmployees){
        Map<String,CCPM_storeEmployee__c> mapOwnerIDandStoreEmp = new Map<String,CCPM_storeEmployee__c>();
        //Create map with stores and list of related store employee
        if(lstEntireStoreEmployees!= null && lstEntireStoreEmployees.size()>0){
            for(CCPM_storeEmployee__c objStoreEmp : lstEntireStoreEmployees){
                if(objStoreEmp.CCPM_employee__c != null && !mapOwnerIDandStoreEmp.containsKey(objStoreEmp.CCPM_employee__c)){
                    mapOwnerIDandStoreEmp.put(objStoreEmp.CCPM_employee__c, objStoreEmp);
                }
            }
        }
        //system.debug('@@@mapOwnerIDandStoreEmp: '+mapOwnerIDandStoreEmp);
        return mapOwnerIDandStoreEmp;
    }
    /**
@author         Sriraman Sridharan
@description    This method assigns the message date and time
@param          list of new leads
@return         List<lead>
*/      
    public static void populateTriggerSmsValues(list<Lead> lstLeads, List<BusinessHours> lstBusinessHours){
        BusinessHours objDefaultBusinessHour;
        for(Integer i=0; i<lstBusinessHours.size();i++){
            if(lstBusinessHours[i].IsDefault){
                objDefaultBusinessHour = lstBusinessHours[i];
                break;
            }
        }
        Map<String,BusinessHours> mapLeadAndBusinessHours = new map<String,BusinessHours>();
        mapLeadAndBusinessHours = getCartIdORStoreIDAndBusinessHourMap(lstLeads,objDefaultBusinessHour,lstBusinessHours); 
        for(Lead objLead: lstLeads)
        {
            //Insert CCPM_TriggerInitialSMSDateTime__c values selectively
            if(objlead.CCPM_Type__c != ccpm_staticConstants.strLeadTypeCampaignLead && CCPM_staticConstants.strInitialSMSInterval != null && CCPM_staticConstants.strFollowUpSMSInterval != null)
            {
                if(!mapLeadAndBusinessHours.isEmpty() && objLead.Store__c != null && mapLeadAndBusinessHours.containsKey(objLead.Store__c) && mapLeadAndBusinessHours.get(objLead.Store__c)!= null ){
                    //system.debug('@@@insideIf');
                    objLead.CCPM_TriggerInitialSMSDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours((mapLeadAndBusinessHours.get(objLead.Store__c)), System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
                    //System.debug('@@@l.CCPM_TriggerInitialSMSDateTime__c '+l.CCPM_TriggerInitialSMSDateTime__c + '@@@BHB '+mapLeadAndBusinessHours.get(l.CCPM_cartID__c));
                }
                else if(!mapLeadAndBusinessHours.isEmpty() && objLead.CCPM_cartID__c != null && mapLeadAndBusinessHours.containsKey(objLead.CCPM_cartID__c) && mapLeadAndBusinessHours.get(objLead.CCPM_cartID__c)!= null ){
                    objLead.CCPM_TriggerInitialSMSDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours((mapLeadAndBusinessHours.get(objLead.CCPM_cartID__c)), System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
                }
                else{
                    //system.debug('@@@insideElse');
                    objLead.CCPM_TriggerInitialSMSDateTime__c = calculateTimeToTriggerSMSWithInBusinessHours(objDefaultBusinessHour, System.now().addminutes(integer.valueof(CCPM_staticConstants.strInitialSMSInterval)));
                }
            } 
        }
    } 
    /**
@author         Sriraman Sridharan
@description    This method populates the initial message
@param          list of new leads
@return         CCPM_SMSMessage__c
*/ 
     
    public static CCPM_SMSMessage__c populateInitialMessageForMergeCarts(lead objlead,Set<String> setQueueIDs){
        
        CCPM_SMSMessage__c objSmsMessage = null;
        if(objlead.ownerid!=null && CCPM_Collection.isNotNullEmpty(setQueueIDs) && !setQueueIDs.contains(objlead.ownerid)){
            String MTN = objlead.CCPM_mobileNumber__c;
            String strMessage1 = '';
            //SMS initial Messages
            // RecordType is Prospect, Lead Status is not equal to Expired,Dismissed,Responded,Qualified,Converted 
            // AND Event Type is not equal toiPhone X,TMP,Pixel - future device 
            if((objlead.RecordTypeId==Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId()
                && !(CCPM_utility.setleadStatusTOExclude.contains(objlead.Status)) && !CCPM_utility.setleadEventToExclude.contains(objlead.CCPM_eventType__c)) 
               || (objlead.recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId()))
            {                       
                //strMessage1 = objlead.CCPM_prospectSMSBody__c; 
                strMessage1 = objlead.CCPM_initialSMSBody__c;
                objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage1,MTN,Label.CCPM_MessageTypeInitialSMSPart1,Label.CCPM_taskCommunicationOutbound,objlead.CCPM_triggerInitialSMSDateTime__c,CCPM_staticConstants.strLivetextPhoneNumberNonVerizon);          
            }
            if(objlead.recordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId()){
                strMessage1 = objlead.CCPM_initialSMSBody__c;
                objSmsMessage = CCPM_utility.createRecordsForSmsMessageObject(objlead,strMessage1,MTN,Label.CCPM_MessageTypeInitialSMSPart1,Label.CCPM_taskCommunicationOutbound,objlead.CCPM_triggerInitialSMSDateTime__c,CCPM_staticConstants.strLivetextPhoneNumber);
            }
        } 
        return objSmsMessage;
    } 
}