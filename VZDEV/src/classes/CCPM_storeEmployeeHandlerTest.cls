/**
*@name          CCPM_storeEmployeeHandler
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          08/28/2017
@description    Test class for 
@testClass      CCPM_storeEmployeeHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                        Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)       08/28/2017          	Original Version
Sriraman Sridharan(Deloitte)		   09/15/2017			Modified Version
*/
@isTest
public class CCPM_storeEmployeeHandlerTest {
    
    public static lead objLead;
    public static lead newLead;
    public static string StrMessageType;
    public static datetime dttScheduledate;
    public static list<string> lstAccountUniqueID=new list<string>();
    public static list<string> lstLastName=new list<string>();
    public static list<string> lstcartUniqueId=new list<string>();
    public static list<string> lststoreID=new list<string>();
    public static list<string> lstcartLastHandledBy=new list<string>();
    Public static list<id> lstLeadId= new list<id>();
    Public static list<Lead> lstLead=new list<Lead>();    
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    public static List<lead> createCart(Integer NoOfRecords, List<String> accountUniqueID, List<String> LastName, List<String> cartUniqueId, List<String> storeID, List<String> cartLastHandledBy,string strmobilenumber,string strRecordtypeID,boolean boolAccountUniqueIDFlag,string EventType)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        for(integer i=0;i<NoOfRecords;i++){
            Lead objCart=new Lead();
            objCart.LastName=LastName[i];
            objCart.FirstName=LastName[i];
            objCart.Status='New';
            objCart.Company = '1';           
            objCart.CCPM_accountNumber__c = accountUniqueID[i];
            if(boolAccountUniqueIDFlag)
            {
                objCart.CCPM_accountUniqueID__c = accountUniqueID[i];  
            }
            if(EventType!=null)
            {
                objCart.CCPM_eventType__c = EventType;
                
            }
                            objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
            objCart.CCPM_storeID__c = storeID[i];
            objCart.CCPM_cartlastHandledBy__c = cartLastHandledBy[i];
            objCart.CCPM_mobileNumber__c = '3213187287';
            objCart.CCPM_email__c ='test@gmail.com';
            objCart.CCPM_confirmEmail__c='test@gmail.com';
            datetime date1=Datetime.now();
            objCart.CCPM_createdDate__c=date1.addHours(-5);
            objCart.CCPM_cartUniqueID__c = cartUniqueId[i];
            objCart.CCPM_SMSLegalOptIn__c =true;
            objCart.CCPM_confirmMTN__c= strMobilenumber;
            if(i/2 == 0){
                objCart.CCPM_isStoreEmployeeUpdated__c = false;
            }
            else{
                objCart.CCPM_isStoreEmployeeUpdated__c = true;
            }
            objCart.RecordTypeId = strRecordtypeID;
            objCart.CCPM_cartID__c=cartUniqueId[i];
            objCart.CCPM_createdChannel__c ='Telesales';
            objCart.ccpm_leadtype__c = 'Prospect Telesales SFDC Manual';
            lstObjCart.add(objCart);
            
        }
        
        try{
            if(lstObjCart!= null){
                System.debug('@@@@ lstObjCart : ' + lstObjCart);
                insert lstObjCart;
            }
            return lstObjCart;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating cart/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    Public static void CreateData(string strmobilenumber,string strRecordtypeID,string strrole,boolean boolAccountUniqueIDFlag,string EventType)
    {
        CCPM_testDataFactory.createCustomer(1, 'abc');
        CCPM_testDataFactory.createStore(2);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lstStore!= null && lstStore.size()>0 && lstStore.isEmpty()==false){
            lststoreID.add(lstStore[0].CCPM_storeID__c);
        }
        list<Account > lstCustomer=[select CCPM_accountUniqueID__c from Account limit 1];
        if(lstCustomer!= null && lstCustomer.size()>0 &&lstCustomer.isEmpty()==false ){
            lstAccountUniqueID.add(lstCustomer[0].CCPM_accountUniqueID__c);
        }
        lstLastName.add('TestLastName');
        lstcartUniqueId.add('TestCartUniqueId');
        lstcartLastHandledBy.add('LHB'); 
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        if(strrole==null && EventType==null)
        {
            createCart(1, lstAccountUniqueID, lstLastName, lstcartUniqueId, lststoreID, lstcartLastHandledBy,strmobilenumber,strRecordtypeID,true,null);
        }
        else{
            list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_employee__r.IsActive from CCPM_storeEmployee__c where CCPM_role__c=:strrole];
            System.debug('@Test_lstStoreEmployee->'+lstStoreEmployee);
            list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
            System.debug('@Test_lstUser->'+lstUser);
            System.runas(lstUser[0])
            {
                createCart(1, lstAccountUniqueID, lstLastName, lstcartUniqueId, lststoreID, lstcartLastHandledBy,strmobilenumber,strRecordtypeID,boolAccountUniqueIDFlag,EventType);
            }
        }
    }    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test insertLeadShareSettings.
*/  
    
    static testmethod void StoreEmployeeInsertTest()
    {	
        list<Lead> lstLead = new list<Lead>();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_isStoreEmployeeUpdated__c,CCPM_mobileNumber__c,RecordTypeId,OwnerId,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_store__c> lstStore = new list<CCPM_store__c>();
        lstStore = [select id from CCPM_store__c where id != :lstLead[0].Store__c ];
        list<CCPM_storeEmployee__c> lstStoreEmployee = [select id,CCPM_Store__c, ccpm_employee__c,CCPM_employee__r.id,CCPM_employee__r.IsActive from CCPM_storeEmployee__c where CCPM_role__c=:CCPM_staticConstants.strStoreAssistantManager limit 1];
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
        update lstLead;
        task objtask = new task();
                objtask.WhoId =lstLead[0].id;
        objtask.RecordTypeId= Schema.SObjectType.task.getRecordTypeInfosByName().get(Label.CCPM_taskToDoRT).getRecordTypeId() ;
        objtask.status='Not Started';
        insert objtask;
        
        system.debug('@@@lstStoreEmployee.CCPM_employee__r.IsActive ' + lstStoreEmployee[0].CCPM_employee__r.IsActive);
        list<User> lstUsr = [Select id,isactive from User where id=:lstStoreEmployee[0].CCPM_employee__r.id];
        system.debug('@@@lstUsr '+ lstUsr);
        lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreSalesRep;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreAssistantManager;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_IsActive__c = false;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_IsActive__c = true;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreManager;
        update lstStoreEmployee;
                lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreAssistantManager;
        lstStoreEmployee[0].CCPM_IsActive__c = false;
         lstStoreEmployee[0].CCPM_previousactive__c=true;
        update lstStoreEmployee;
        
        
        Test.startTest();
        //Update Owner
        list<CCPM_storeEmployee__c> lstStoreEmployeOwner = [select id,CCPM_Store__c, ccpm_employee__c,CCPM_employee__r.id from CCPM_storeEmployee__c where CCPM_employee__r.id =: lstLead[0].OwnerId limit 1];
        if(lstStoreEmployeOwner!= null && lstStoreEmployeOwner.size()>0){
            system.debug('@@@lstStoreEmployeOwner Not Empty');
            lstStoreEmployeOwner[0].CCPM_IsActive__c = true;
            update lstStoreEmployeOwner;
            lstStoreEmployeOwner[0].CCPM_IsActive__c = false;
            update lstStoreEmployeOwner;
        }
        /*
        lstLead[0].Store__c = null;
        //lstLead[0].CCPM_storeID__c = null;
        Update lstLead[0];
        */
        list<CCPM_storeEmployee__c> lstStoreEmployeOwnerForEmptyStore = [select id,CCPM_Store__c, ccpm_employee__c,CCPM_employee__r.id from CCPM_storeEmployee__c where CCPM_employee__r.id =: lstLead[0].OwnerId limit 1];
        if(lstStoreEmployeOwnerForEmptyStore!= null && lstStoreEmployeOwnerForEmptyStore.size()>0){
            system.debug('@@@lstStoreEmployeOwnerForEmptyStore Not Empty');
            lstStoreEmployeOwnerForEmptyStore[0].CCPM_IsActive__c = true;
            update lstStoreEmployeOwnerForEmptyStore;
            lstStoreEmployeOwnerForEmptyStore[0].CCPM_IsActive__c = false;
            update lstStoreEmployeOwnerForEmptyStore;
            CCPM_storeEmployeeBatch storeEmployeeBatch =  new CCPM_storeEmployeeBatch();
             DataBase.executeBatch(storeEmployeeBatch);
        }
        Map<Id, CCPM_storeEmployee__c> mapstrEmp = new Map<id, CCPM_storeEmployee__c>(lstStoreEmployeOwner);
        CCPM_storeEmployeeTriggerHandler strEmpHdlr = new CCPM_storeEmployeeTriggerHandler();
        strEmpHdlr.BeforeInsert(mapstrEmp.values());
        strEmpHdlr.BeforeDelete(mapstrEmp);
        strEmpHdlr.AfterUpdate(mapstrEmp, mapstrEmp );
        strEmpHdlr.AfterDelete(mapstrEmp);
        strEmpHdlr.AfterUndelete(mapstrEmp);
        Test.stopTest();
    }
    
    static testmethod void StoreEmployeeBatchTest()
    {	
        list<Lead> lstLead = new list<Lead>();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_isStoreEmployeeUpdated__c,CCPM_mobileNumber__c,RecordTypeId,OwnerId,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_store__c> lstStore = new list<CCPM_store__c>();
        lstStore = [select id from CCPM_store__c where id != :lstLead[0].Store__c ];
        list<CCPM_storeEmployee__c> lstStoreEmployee = [select id,CCPM_Store__c, ccpm_employee__c,CCPM_employee__r.id,CCPM_employee__r.IsActive from CCPM_storeEmployee__c where CCPM_role__c=:CCPM_staticConstants.strStoreAssistantManager limit 1];
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
                    lstLead[0].CCPM_createdChannel__c ='Telesales';
        update lstLead;
        task objtask = new task();
                objtask.WhoId =lstLead[0].id;
        objtask.RecordTypeId= Schema.SObjectType.task.getRecordTypeInfosByName().get(Label.CCPM_taskToDoRT).getRecordTypeId() ;
        objtask.status='Not Started';
        insert objtask;
        
        system.debug('@@@lstStoreEmployee.CCPM_employee__r.IsActive ' + lstStoreEmployee[0].CCPM_employee__r.IsActive);
        list<User> lstUsr = [Select id,isactive from User where id=:lstStoreEmployee[0].CCPM_employee__r.id];
        system.debug('@@@lstUsr '+ lstUsr);
        lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreSalesRep;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreAssistantManager;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_IsActive__c = false;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_IsActive__c = true;
        update lstStoreEmployee;
        lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreManager;
        update lstStoreEmployee;
                lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreAssistantManager;
        lstStoreEmployee[0].CCPM_IsActive__c = false;
         lstStoreEmployee[0].CCPM_previousactive__c=true;
        update lstStoreEmployee;
         lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreAssistantManager;
         lstStoreEmployee[0].CCPM_IsActive__c = true;
         lstStoreEmployee[0].CCPM_previousactive__c=false;
        update lstStoreEmployee;
         lstStoreEmployee[0].CCPM_role__c = CCPM_staticConstants.strStoreAssistantManager;
         lstStoreEmployee[0].CCPM_IsActive__c = true;
         lstStoreEmployee[0].CCPM_previousactive__c=false;
        update lstStoreEmployee;
        
        Test.startTest();
        //Update Owner
        list<CCPM_storeEmployee__c> lstStoreEmployeOwner = [select id,CCPM_Store__c, ccpm_employee__c,CCPM_employee__r.id from CCPM_storeEmployee__c where CCPM_employee__r.id =: lstLead[0].OwnerId limit 1];
        if(lstStoreEmployeOwner!= null && lstStoreEmployeOwner.size()>0){
            system.debug('@@@lstStoreEmployeOwner Not Empty');
            lstStoreEmployeOwner[0].CCPM_IsActive__c = true;
            update lstStoreEmployeOwner;
            lstStoreEmployeOwner[0].CCPM_IsActive__c = false;
            update lstStoreEmployeOwner;
        }
        /*
        lstLead[0].Store__c = null;
        //lstLead[0].CCPM_storeID__c = null;
        Update lstLead[0];
        */
        list<CCPM_storeEmployee__c> lstStoreEmployeOwnerForEmptyStore = [select id,CCPM_Store__c, ccpm_employee__c,CCPM_employee__r.id from CCPM_storeEmployee__c where CCPM_employee__r.id =: lstLead[0].OwnerId limit 1];
        if(lstStoreEmployeOwnerForEmptyStore!= null && lstStoreEmployeOwnerForEmptyStore.size()>0){
            system.debug('@@@lstStoreEmployeOwnerForEmptyStore Not Empty');
            lstStoreEmployeOwnerForEmptyStore[0].CCPM_IsActive__c = true;
            update lstStoreEmployeOwnerForEmptyStore;
            lstStoreEmployeOwnerForEmptyStore[0].CCPM_IsActive__c = false;
            update lstStoreEmployeOwnerForEmptyStore;
            CCPM_storeEmployeeBatch storeEmployeeBatch =  new CCPM_storeEmployeeBatch();
             DataBase.executeBatch(storeEmployeeBatch);
        }
        CCPM_storeEmployeeBatch objbatch = new CCPM_storeEmployeeBatch();
			Database.executeBatch(objbatch,5);	
         String StrCRONEXP = ccpm_staticConstants.StrCRONEXP;
    CCPM_storeEmployeeBatch objSch = new CCPM_storeEmployeeBatch(); 
        system.schedule('CCPM_UpdateAccountUniqueIdBatchTest- 10 Mins', StrCRONEXP, objSch);
        Map<Id, CCPM_storeEmployee__c> mapstrEmp = new Map<id, CCPM_storeEmployee__c>(lstStoreEmployeOwner);
        CCPM_storeEmployeeTriggerHandler strEmpHdlr = new CCPM_storeEmployeeTriggerHandler();
        strEmpHdlr.BeforeInsert(mapstrEmp.values());
        strEmpHdlr.BeforeDelete(mapstrEmp);
        strEmpHdlr.AfterUpdate(mapstrEmp, mapstrEmp );
        strEmpHdlr.AfterDelete(mapstrEmp);
        strEmpHdlr.AfterUndelete(mapstrEmp);
        Test.stopTest();
    }
     
}