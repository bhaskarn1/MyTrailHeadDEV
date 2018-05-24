/**
*@name          CCPM_sendMessageUsingApexTest
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          08/22/2017
@description    Test class for CCPM_sendMessageUsingApex
@testClass      CCPM_sendMessageUsingApexTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                        Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)       08/22/2017          Original Version
*/
@istest public class CCPM_sendMessageUsingApexTest 
{
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
    Public static list<CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex> lstVRA=new list<CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex>();
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    Public static void CreateData()
    {
        //Create Custom setting
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testDataFactory.createCustomer(1, 'abc');
        CCPM_testDataFactory.createStore(1);
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
        CCPM_testDataFactory.createCartdefaultRecordType(1, lstAccountUniqueID, lstLastName, lstcartUniqueId, lststoreID, lstcartLastHandledBy);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        if(lstLead!= null && lstLead.size()>0 && lstLead.isEmpty()==false)
        {
            lstLeadId.add(lstLead[0].id);
        }
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test Follow-Up SMS.
*/  
    
    Static testmethod void sendFollowUpSMSTest()
    {
        test.startTest();
        //Create Custom setting
        //CCPM_testDataFactory.createCustomSetting();
        CreateData();
        CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
        VRA.StrMessageType=CCPM_staticConstants.strMessageTypeFollowUpSMS;
        
        if(lstLead!= null && lstLead.size()>0 &&lstLead.isEmpty()==false ){
            VRA.Leads=lstLead[0];
            lstVRA.add(VRA);
            VRA.dttScheduledate=System.now();
       //     CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
        }  
        test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test Initial SMS Part 1.
*/  
    
    Static testmethod void sendInitialSMS1Test()
    {
        test.startTest();
        CreateData();
        CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
        VRA.StrMessageType=CCPM_staticConstants.strMessageTypeInitialSMSPart1;
        
        if(lstLead!= null && lstLead.size()>0 && lstLead.isEmpty()==false){
            VRA.Leads=lstLead[0];
            VRA.dttScheduledate=System.now();
            lstVRA.add(VRA);
          //  CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
        }
        test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test Initial SMS Part 2.
*/ 
    Static testmethod void sendInitialSMS2Test()
    {
        test.startTest();
        CreateData();
        CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
        VRA.StrMessageType=CCPM_staticConstants.strMessageTypeInitialSMSPart2;
        
        if(lstLead!= null && lstLead.size()>0 && lstLead.isEmpty()==false ){
            VRA.Leads=lstLead[0];
            VRA.dttScheduledate=System.now();
            lstVRA.add(VRA);
         //   CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
        }
        test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test Initial SMS Part 2.
*/ 
    
   @istest Static void sendProcessCustomerResponseTest()
    {
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
       // User sysadminUser =CCPM_testDataFactory.CreateUser('System Administrator','sysadmin');
        CCPM_testDataFactory.createCustomer(1, 'abc');
        CCPM_testDataFactory.createStore(1);
        list<CCPM_Store__c > lststore=[select id,CCPM_storeID__c from CCPM_Store__c limit 1];
        if(lstStore!= null && lstStore.size()>0 &&lstStore.isEmpty()==false ){
            lststoreID.add(lstStore[0].CCPM_storeID__c);
        }
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_IsActive__c from CCPM_storeEmployee__c where CCPM_role__c ='Store Manager' ];
        list<Account > lstCustomer=[select CCPM_accountUniqueID__c from Account limit 1];
        if(lstCustomer!= null && lstCustomer.size()>0 && lstCustomer.isEmpty()==false){
            lstAccountUniqueID.add(lstCustomer[0].CCPM_accountUniqueID__c);
        }
        lstLastName.add('TestLastName');
        lstcartUniqueId.add('TestCartUniqueId');
        lstcartLastHandledBy.add('LHB'); 
        Lead objCart=new Lead();
        objCart.LastName=lstLastName[0];
        objCart.Status='New';
        objCart.Company='1';           
        // objCart.CCPM_accountNumber__c = lstAccountUniqueID[0];
        objCart.CCPM_accountUniqueID__c = lstCustomer[0].CCPM_accountUniqueID__c;
        objCart.CCPM_storeID__c = lststoreID[0];
        // objCart.CCPM_cartlastHandledBy__c = cartLastHandledBy[i];
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_SMSLegalOptIn__c = ccpm_staticConstants.boolSMSSent;
        objCart.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
        if(objcart!=null )
            insert objCart;
        // CCPM_testDataFactory.createCart(1, lstAccountUniqueID, lstLastName, lstcartUniqueId, lststoreID, lstcartLastHandledBy);
        lstLead=[Select Id,CCPM_isLeadOwnerActive__c,CCPM_isManualLead__c,RecordTypeId,CCPM_isSMSResponseReceived__c,CCPM_mobileNumber__c,ownerid,Store__c,CCPM_SMSResponseBodyForProspect__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c,CCPM_SMSOptOut__c from lead limit 1];
        if(lstLead!= null && lstLead.size()>0 &&lstLead.isEmpty()==false )
        {
            
                lstLead[0].ownerId=lstStoreEmployee[0].CCPM_employee__c;
                update lstLead;
            
            lstLeadId.add(lstLead[0].id);
        }
       // CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        
        lstLead=[select id,RecordTypeId,CCPM_isLeadOwnerActive__c,store__c,CCPM_isManualLead__c,CCPM_isSMSResponseReceived__c,CCPM_SMSResponseBody__c,CCPM_SMSResponseBodyForProspect__c,OwnerId,LastName,CCPM_SMSOptOut__c from lead limit 1];
        
        //list<LiveText__LiveText_Number__c> LiveTextNumber= [select id from LiveText__LiveText_Number__c limit 1];
        /*
         createITRRecords();
        
        list<LiveText__ITR_Message__c> lstITR=[select id,LiveText__Originating_Number__c,LiveText__Message__c,LiveText__Lead__c from LiveText__ITR_Message__c limit 1];
        CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
        VRA.StrMessageType=CCPM_staticConstants.strMessageTypeProcessCustomerResponse;
        lstLead[0].store__c =lstStore[0].id;
        update lstLead;
        if(lstLead!= null && lstLead.size()>0 && lstLead.isEmpty()==false){
            VRA.Leads=lstLead[0];
            VRA.ITRRecord=lstITR[0];
            lstVRA.add(VRA);
            CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
        }
        list<task> lstTasks=[select id,whoid,status,subject from task where subject like'SMS for Review%' limit 1];
        CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA1 = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
        CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA2 = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
        list<CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex> lstVRA1=new list<CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex>();
        if(lstTasks!=null && lstTasks.size()>0 &&lstTasks.isEmpty()==false )
        {   
            System.assert(lstTasks[0].status==CCPM_staticConstants.strTaskNotStarted);
            VRA1.Tasks=lstTasks[0];
            VRA1.StrMessageType=CCPM_staticConstants.strMessageTypeTaskOwnerSMS;
            lstVRA1.add(VRA1);
            CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA1);
        }
        ccpm_sendMessageUsingApex.CustomerResponseForDoubleOptOut(lstITR[0],lstLead[0]);
        lstITR[0].LiveText__Message__c =CCPM_staticConstants.strFirstCustomerResponseForOptOutQuote;
        Update lstITR[0];
        VRA.Leads=lstLead[0];
        VRA.ITRRecord=lstITR[0];
        lstVRA.add(VRA);
        ccpm_sendMessageUsingApex.CustomerResponseForDoubleOptOut(lstITR[0],lstLead[0]);
        CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
        
        
        lstLead[0].RecordTypeId = ccpm_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
        VRA2.Leads=lstLead[0];
        VRA2.ITRRecord=lstITR[0];
        lstVRA.add(VRA2);
        CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
        */
        test.stopTest();
    }  
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test Prospect Action Required SMS.
*/ 
    
    @istest Static void ProspectActionRequiredSMS()
    {
        test.startTest();
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        System.runAs(u)
        {
            
            CreateData();
            createITRRecords();
            list<LiveText__ITR_Message__c> lstITR=[select id,LiveText__Originating_Number__c,LiveText__Message__c,LiveText__Lead__c from LiveText__ITR_Message__c limit 1];
            CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
            VRA.StrMessageType=CCPM_staticConstants.strMessageTypeProspectActionRequired;
            if(lstLead!= null && lstLead.size()>0 && lstLead.isEmpty()==false){
                VRA.Leads=lstLead[0];
                
                lstVRA.add(VRA);
             //   CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
            }
            
            
        }
        test.stopTest();
        
    } 
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test Prospect Action Required SMS.
*/ 
    
    @istest Static void newProspectSMS()
    {
        test.startTest();
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        System.runAs(u)
        {
            
            CreateData();
            lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
            createITRRecords();
            
            CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA1 = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
            VRA1.StrMessageType=CCPM_staticConstants.strMessageTypeProspectFirstSMSPart1;
            if(lstLead!= null && lstLead.size()>0){
                VRA1.Leads=lstLead[0];
                VRA1.dttScheduledate=system.now();
                
                lstVRA.add(VRA1);
            }
            
            CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
            VRA.StrMessageType=CCPM_staticConstants.strMessageTypeProspectFirstSMSPart2;
            if(lstLead!= null && lstLead.size()>0 && lstLead.isEmpty()==false){
                VRA.Leads=lstLead[0];
                VRA.dttScheduledate=system.now();
                lstVRA.add(VRA);
              //  CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
            }
            
            
        }
        test.stopTest();
        
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test SMS to task owners.
*/  
    
    Static testmethod void createTasksToSendSMSTest()
    {	
        test.startTest();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        list<task> lstTask = new list<Task>();
        CreateData();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        CCPM_testDataFactory.createTask(lstLead[0].id,'outbound');
        lstTask = [select id,whoid,Status,ownerid from task limit 1];
        lstStoreEmployee = [select id,CCPM_employee__c from CCPM_storeEmployee__c where CCPM_role__c='Sales Rep'];
        lstTask[0].ownerid= lstStoreEmployee[0].CCPM_employee__c;
        update lstTask;
        CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex VRA = new CCPM_sendMessageUsingApex.setVariablesRequiredtoSendSMSforApex();
        VRA.StrMessageType=CCPM_staticConstants.strMessageTypeTaskOwnerSMS;
        
        if(lstTask!= null && lstTask.size()>0){
            VRA.tasks=lstTask[0];
            lstVRA.add(VRA);
            //VRA.dttScheduledate=System.now();
        //    CCPM_sendMessageUsingApex.SendMessageViaApex(lstVRA);
        }  
        test.stopTest();
    }    
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test method send SMS to managers
*/  
    
    Static testmethod void createTasksToSendSMSManagersTest()
    {	
        test.startTest();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        CreateData();
        createITRRecords();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        
        list<LiveText__ITR_Message__c> lstITR=[select id,LiveText__Originating_Number__c,LiveText__Message__c,LiveText__Lead__c from LiveText__ITR_Message__c limit 1];
        lstStoreEmployee = [select id,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstStoreEmployee.clear();
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        map<id,User> mapOwnerFirstname = new map<id,User>([select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1]);
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        
        System.runAs(u)
        {
            mapOwnerFirstname.get(lstStoreEmployee[0].CCPM_employee__c).firstname=null;
            update mapOwnerFirstname.values();
        }
     //   CCPM_sendMessageUsingApex.SendSMSToManagers(lstITR[0],lstLead[0],lstStoreEmployee[0],mapOwnerFirstname,System.now());
        
        //CCPM_sendMessageUsingApex.SendSMSToManagers(lstITR[0],lstLead[0],lstStoreEmployee[0],null,System.now());
        test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test method send SMS to managers
*/  
    
    Static testmethod void createTasksToSendSMSManagersTest2()
    {	
        test.startTest();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        CreateData();
        createITRRecords();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        
        list<LiveText__ITR_Message__c> lstITR=[select id,LiveText__Originating_Number__c,LiveText__Message__c,LiveText__Lead__c from LiveText__ITR_Message__c limit 1];
        lstStoreEmployee = [select id,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstStoreEmployee.clear();
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        
        
     //   CCPM_sendMessageUsingApex.SendSMSToManagers(lstITR[0],lstLead[0],lstStoreEmployee[0],null,System.now());
        test.stopTest();
    }    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test all the returning null functionality
*/  
    
    Static testmethod void ReturnNullTest1()
    {	
        test.startTest();
        CreateData();
        createITRRecords();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        //update lstLead;
        list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        
        System.runAs(u)
        {
            lstUser[0].isactive=false;
            lstUser[0].mobilephone=null;
            update lstUser;
        }
        
     //   CCPM_sendMessageUsingApex.createToDoTaskforCustomerResponse(lstLead[0],null);
        
        test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test all the returning null functionality
*/  
    
    Static testmethod void ReturnNullTest2()
    {	
        test.startTest();
        CreateData();
        createITRRecords();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        lstLead[0].CCPM_mobileNumber__c=null;
        //update lstLead;
        list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        
        System.runAs(u)
        {
            lstUser[0].isactive=false;
            lstUser[0].mobilephone=null;
            update lstUser;
        }
        
      //  CCPM_sendMessageUsingApex.InitialSMS(lstLead[0],null,null);
        
        test.stopTest();
    } 
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test all the returning null functionality
*/  
    
    Static testmethod void ReturnNullTest3()
    {	
        test.startTest();
        CreateData();
        createITRRecords();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        lstLead[0].CCPM_mobileNumber__c=null;
        //update lstLead;
        list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        
        System.runAs(u)
        {
            lstUser[0].isactive=false;
            lstUser[0].mobilephone=null;
            update lstUser;
        }
       // CCPM_sendMessageUsingApex.FollowUpSMS(lstLead[0],null);
        test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test all the returning null functionality
*/  
    
    Static testmethod void ReturnNullTest4()
    {	
        test.startTest();
        CreateData();
        createITRRecords();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        lstLead[0].CCPM_mobileNumber__c=null;
        //update lstLead;
        list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        
        System.runAs(u)
        {
            lstUser[0].isactive=false;
            lstUser[0].mobilephone=null;
            update lstUser;
        }
      //  CCPM_sendMessageUsingApex.newProspectSMS(lstLead[0],null,null);
        test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test all the returning null functionality
*/  
    
    Static testmethod void ReturnNullTest5()
    {	
        test.startTest();
        CreateData();
        createITRRecords();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        lstLead[0].CCPM_mobileNumber__c=null;
        //update lstLead;
        list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        
        System.runAs(u)
        {
            lstUser[0].isactive=false;
            lstUser[0].mobilephone=null;
            update lstUser;
        }
        lstStoreEmployee.clear();
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
     //   CCPM_sendMessageUsingApex.sendLeadOrProspectActionRequiredSMS(null,null,lstStoreEmployee[0],null);
        test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to test all the returning null functionality
*/  
    
    Static testmethod void ReturnNullTest6()
    {	
        test.startTest();
        CreateData();
        createITRRecords();
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        lstLead.clear();
        lstLead=[select id,CCPM_prospectSMSBodyPartII__c,CCPM_prospectSMSBodyPartI__c,CCPM_mobileNumber__c,store__c,CCPM_SMSResponseBody__c,OwnerId,LastName from lead limit 1];
        lstStoreEmployee = [select id,CCPM_storeEmployee__c.CCPM_role__c,CCPM_employee__r.firstname,CCPM_employee__r.lastname,CCPM_employee__r.MobilePhone from CCPM_storeEmployee__c where CCPM_role__c = :CCPM_staticConstants.strStoreAssistantManager];
        lstLead[0].ownerid = lstStoreEmployee[0].CCPM_employee__c;
        lstLead[0].CCPM_mobileNumber__c=null;
        lstLead[0].CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
        update lstLead;
        list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
        User u=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        
        System.runAs(u)
        {
            lstUser[0].isactive=false;
            lstUser[0].mobilephone=null;
            update lstUser;
        }
        list<LiveText__ITR_Message__c> lstITR=[select id,LiveText__Originating_Number__c,LiveText__Message__c,LiveText__Lead__c from LiveText__ITR_Message__c limit 1];
      //  CCPM_sendMessageUsingApex.CustomerResponseForDoubleOptOut(lstITR[0],lstLead[0]);
        test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create ITR records for testing purpose
*/  
    public static void createITRRecords()
    {
        
        LiveText__LiveText_Number__c LiveTextNumber1=new LiveText__LiveText_Number__c();
        LiveTextNumber1.Name='test';
        LiveTextNumber1.LiveText__Validated__c=ccpm_staticConstants.boolSMSSent;
        LiveTextNumber1.LiveText__Number__c='13214249106';
        if(LiveTextNumber1!=null)
            insert LiveTextNumber1;
        
        LiveText__ITR_Message__c ITR=new LiveText__ITR_Message__c();
        ITR.LiveText__LiveText_Number__c=LiveTextNumber1.Id;
        ITR.Name='Test';
        ITR.LiveText__Originating_Number__c='+13213187287';
        ITR.LiveText__Message__c='Okay';
        ITR.LiveText__Lead__c=lstLead[0].id;
        insert ITR;
    }        
}