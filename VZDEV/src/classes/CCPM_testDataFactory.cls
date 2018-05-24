/**
*@name          CCPM_testDataFactory
*@author        Brigadesh (Deloitte)
*@date          07/12/2016
@description    This class is used for generating test data.
@inputs :       


Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Brigadesh(Deloitte)     07/12/2016                          Original Version
Sriraman Sridharan    2/16/2017              Modified Version
*/

public class CCPM_testDataFactory {
    
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is used for inserting a store
*@param :       Integer- Number of records needed to be inserted
*@return :      CCPM_Store__c- Returns List of Store Records 
*/
    public static list<CCPM_Store__c> createStore(integer NoOfRecords)
    {
        list<CCPM_Store__c> lstObjStore=new list<CCPM_Store__c>();
        for(integer i=0;i<NoOfRecords;i++)
        {
            CCPM_Store__c objStore=new CCPM_Store__c();    
            objStore.Name='TS'+i;
            objStore.CCPM_city__c='testCity';
            objStore.CCPM_country__c='USA';
            objStore.CCPM_longcode__c=''+i;
            objStore.CCPM_street__c='testStreet';
            objStore.CCPM_state__c='testState';
            objStore.CCPM_zipcode__c='32746';
            objStore.CCPM_phone__c='1234567890';
            objStore.CCPM_storeID__c= 'SID'+i;
            objStore.CCPM_market__c ='testMarket';
            objStore.CCPM_district__c='testDistrict';
            objStore.CCPM_territory__c='testTerritory'; 
            objStore.CCPM_TimeZone__c='EST';
            objStore.CCPM_IsActive__c=true;    
            lstObjStore.add(objStore);    
        }   
        try{
            insert lstObjStore;
            return lstObjStore;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating store/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is used for inserting a Store Employee
*@param :       Integer- Number of records needed to be inserted
*@return :      Store Employee- Returns List of Store Employee Records 
*/
    public static void createStoreEmployee(String managerName, String repName, String CommisionableRepID,String assistantManager, ID StoreID)
    {
        list<CCPM_StoreEmployee__c> lstObjStoreEmployee=new list<CCPM_StoreEmployee__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='CCPM Sales Rep'];
        User u = new User(Alias = managerName, Email='standardtestuser2UAT@testorgUAT.com',firstname='a', 
                          EmailEncodingKey='UTF-8', LastName=managerName, LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                          TimeZoneSidKey='America/Los_Angeles', UserName=managerName+'UAT@testorgUAT.com',mobilephone='3214249106');
        insert u;
        User u1 = new User(Alias = repName, Email='standardtestuser21UAT@testorgUAT.com',firstname='a', 
                           EmailEncodingKey='UTF-8', LastName= repName, LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                           TimeZoneSidKey='America/Los_Angeles', UserName=repName+'UAT@testorgUAT.com', CCPM_commissionableRepID__c=CommisionableRepID,mobilephone='3214249105');
        insert u1;
        User u2 = new User(Alias = assistantManager, Email='standardtestuser21UAT@testorgUAT.com', firstname='a',
                           EmailEncodingKey='UTF-8', LastName= assistantManager, LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                           TimeZoneSidKey='America/Los_Angeles', UserName=assistantManager+'UAT@testorgUAT.com',mobilephone='3213187287');
        insert u2;
        
        User u3 = new User(Alias = assistantManager, Email='standardtestuser@testorgUAT.com', firstname='a',
                           EmailEncodingKey='UTF-8', LastName= assistantManager, LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                           TimeZoneSidKey='America/Los_Angeles', UserName=assistantManager+'UAT1@testorgUAT.com',mobilephone='3213187280');
        insert u3;
        
        // system.debug('&&&& New Users: '+ u2);
        //Manager
        CCPM_StoreEmployee__c objStoreEmployee=new CCPM_StoreEmployee__c();    
        objStoreEmployee.CCPM_employee__c=u.id;
        objStoreEmployee.CCPM_role__c='Store Manager'; 
        objStoreEmployee.CCPM_Store__c=StoreID; 
        objStoreEmployee.CCPM_IsActive__c=true;
        objStoreEmployee.CCPM_uniqueStoreEmployeeID__c='1';
        lstObjStoreEmployee.add(objStoreEmployee);    
        //Salesrep   
        CCPM_StoreEmployee__c objStoreEmployee2=new CCPM_StoreEmployee__c();    
        objStoreEmployee2.CCPM_employee__c=u1.id;
        objStoreEmployee2.CCPM_role__c='Sales Rep'; 
        objStoreEmployee2.CCPM_Store__c=StoreID;
        objStoreEmployee2.CCPM_IsActive__c=true;
        objStoreEmployee2.CCPM_uniqueStoreEmployeeID__c='2';
        lstObjStoreEmployee.add(objStoreEmployee2);    
        //AssistantManager   
        CCPM_StoreEmployee__c objStoreEmployee3=new CCPM_StoreEmployee__c();    
        objStoreEmployee3.CCPM_employee__c=u2.id;
        objStoreEmployee3.CCPM_role__c='Assistant Manager'; 
        objStoreEmployee3.CCPM_Store__c=StoreID;
        objStoreEmployee3.CCPM_uniqueStoreEmployeeID__c='3';
        objStoreEmployee3.CCPM_IsActive__c=true;
        lstObjStoreEmployee.add(objStoreEmployee3);    
        //AssistantManager  - InActive 
        CCPM_StoreEmployee__c objStoreEmployee4=new CCPM_StoreEmployee__c();    
        objStoreEmployee4.CCPM_employee__c=u3.id;
        objStoreEmployee4.CCPM_role__c='Assistant Manager'; 
        objStoreEmployee4.CCPM_Store__c=StoreID;
        objStoreEmployee4.CCPM_IsActive__c=true;
        objStoreEmployee4.CCPM_uniqueStoreEmployeeID__c='4';
        lstObjStoreEmployee.add(objStoreEmployee4); 
        try{
            insert lstObjStoreEmployee;
            //   system.debug('&&&& lstObjStoreEmployee : '+ lstObjStoreEmployee);
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating storeEmployee/ClassName:CCPM_testDataFactory: ' + e.getMessage());
        }
        
    }
    
    /**
*@author        Brigadesh (Deloitte)
*@description   This method is used for inserting a Customer
*@param :       Integer- Number of records needed to be inserted and a string to append to the unique ID field
*@return :      Account- Returns List of Customer Records 
*/
    public static list<Account> createCustomer(integer NoOfRecords, String appendUnique)
    {   
        list<Account> lstObjCustomer=new list<Account>();
        id customerRecordtype=[select id from recordtype where name='Customer Account'].id;
        for(integer i=0;i<NoOfRecords;i++)
        {
            Account objCustomer=new Account();
            objCustomer.Name='testuatCustomer'+appendUnique+i;
            objCustomer.RecordTypeId=customerRecordtype;
            objCustomer.CCPM_accountNumber__c=''+appendUnique+i;
            objCustomer.CCPM_accountUniqueID__c=''+appendUnique+i;
            objCustomer.Phone='1243658790';
            objCustomer.CCPM_email__c='test@salesforce.com';
            objCustomer.BillingStreet='testStreet';
            objCustomer.BillingCity='testStreet';
            objCustomer.BillingState='testState';
            objCustomer.BillingPostalCode='32745';
            ObjCustomer.CCPM_SMSOptOut__c=false;
            ObjCustomer.CCPM_mobileNumber__c='3214249106';
            lstObjCustomer.add(objCustomer);
            
        }
        try{
            insert lstObjCustomer;
            return lstObjCustomer;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating customer/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is used for inserting a Cart
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Cart Records 
*/    
    public static List<lead> createCart(Integer NoOfRecords, List<String> accountUniqueID, List<String> LastName, List<String> cartUniqueId, List<String> storeID, List<String> cartLastHandledBy)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        //System.debug('@@@@ accountUniqueID : ' + accountUniqueID);
        //System.debug('@@@@ LastName : ' + LastName);
        //System.debug('@@@@ cartUniqueId : ' + cartUniqueId);
        //System.debug('@@@@ storeID : ' + storeID);
        //System.debug('@@@@ cartLastHandledBy : ' + cartLastHandledBy);
        for(integer i=0;i<NoOfRecords;i++){
            Lead objCart=new Lead();
            objCart.LastName=generateRandomString(10);
            objCart.Status='New';
            //objCart.CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusInDiscussion;
            objCart.Company = '1';           
            objCart.CCPM_accountNumber__c = accountUniqueID[i];
            objCart.CCPM_accountUniqueID__c = accountUniqueID[i];
            objCart.CCPM_storeID__c = storeID[i];
            objCart.CCPM_cartlastHandledBy__c = cartLastHandledBy[i];
            objCart.CCPM_mobileNumber__c = '3213187287';
            objCart.CCPM_email__c ='test@gmail.com';
            datetime date1=Datetime.now();
            objCart.CCPM_createdDate__c=date1.addHours(-5);
            objCart.CCPM_cartUniqueID__c = cartUniqueId[i];
            objCart.CCPM_cartID__c = cartUniqueId[i];
            //   objCart.CCPM_SMSFollowUpDate__c system.today();
            objCart.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
            objCart.CCPM_SMSLegalOptIn__c = true;
            
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
*@author        Paras Shah (Deloitte)
*@description   This method is used for inserting a Cart
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Cart Records 
*/    
    /*public static List<lead> createCartWithStatus(Boolean boolSMSResponse, String strLeadStatus,Integer NoOfRecords, List<String> accountUniqueID, List<String> LastName, String cartUniqueId, List<String> storeID, List<String> cartLastHandledBy)
{   
//To create test user and assign as OwnerId
List<lead> lstObjCart = new List<lead>();
//System.debug('@@@@ accountUniqueID : ' + accountUniqueID);
//System.debug('@@@@ LastName : ' + LastName);
//System.debug('@@@@ cartUniqueId : ' + cartUniqueId);
//System.debug('@@@@ storeID : ' + storeID);
//System.debug('@@@@ cartLastHandledBy : ' + cartLastHandledBy);
for(integer i=0;i<NoOfRecords;i++){
Lead objCart=new Lead();
objCart.LastName=generateRandomString(10);
objCart.Status=strLeadStatus;

objCart.CCPM_isSMSResponseReceived__c = boolSMSResponse;
objCart.Company='1';   
Date dattoday = system.today();
objCart.CCPM_SMSFollowUpDate__c = dattoday.addMonths(-1);
objCart.CCPM_accountNumber__c = accountUniqueID[i];
objCart.CCPM_accountUniqueID__c = accountUniqueID[i];
objCart.CCPM_storeID__c = storeID[i];
objCart.CCPM_cartlastHandledBy__c = cartLastHandledBy[i];
objCart.CCPM_mobileNumber__c = '9999999999';
objCart.CCPM_email__c ='test@gmail.com';
datetime date1=Datetime.now();
objCart.CCPM_createdDate__c=date1.addHours(-90);
objCart.CCPM_cartUniqueID__c = cartUniqueId;
objCart.CCPM_cartID__c = cartUniqueId;
objCart.RecordTypeId = CCPM_staticConstants.strProspectAbandonedCartRecordTypeID;
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

}*/
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is used for inserting a Cart
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Cart Records 
*/    
    public static List<lead> createCartWithoutLastCartHandledBy(Integer NoOfRecords, List<String> accountUniqueID, List<String> LastName, List<String> cartUniqueId, List<String> storeID)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        
        for(integer i=0;i<NoOfRecords;i++){
            Lead objCart=new Lead();
            objCart.LastName=generateRandomString(10);
            objCart.Status='New';
            objCart.Company='1';           
            objCart.CCPM_accountNumber__c = accountUniqueID[i];
            objCart.CCPM_accountUniqueID__c = accountUniqueID[i];
            objCart.CCPM_storeID__c = storeID[i];
            objCart.CCPM_mobileNumber__c = '3213187287';
            datetime date1=Datetime.now();
            objCart.CCPM_createdDate__c=date1.addHours(-5);
            objCart.CCPM_cartUniqueID__c = cartUniqueId[i];
            objCart.CCPM_cartID__c = cartUniqueId[i];
            lstObjCart.add(objCart);
        }
        
        try{
            insert lstObjCart;
            return lstObjCart;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating customer/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    
    /**
*@author        Paras (Deloitte)
*@description   This method is used for inserting a Task
*@param :       Lead Id and communication direction
*@return :      Lead- Returns List of Cart Records 
*/    
    public static Task createTaskWithDescription(Id leadId,String communicationDirection, String strTaskDescription)
    {   
        Task objTask=new Task();
        objTask.Subject = 'Other';
        objTask.Description = strTaskDescription;
        objTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Interaction History').getRecordTypeId();
        objTask.WhoId = leadId;
        objTask.Status = 'In Progress';
        objTask.Priority = 'Normal';
        objTask.CCPM_communicationDirection__c = communicationDirection;  
        
        try{
            insert objTask;
            return objTask;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating task/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    /**
*@author        Paras (Deloitte)
*@description   This method is used for inserting a Task
*@param :       Lead Id and communication direction
*@return :      Lead- Returns List of Cart Records 
*/    
    public static Task createTask(Id LeadId,String communicationDirection)
    {   
        Task objTask=new Task();
        objTask.Subject = 'Other';
        objTask.Description = 'FreeVzMsg';
        objTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Interaction History').getRecordTypeId();
        objTask.WhoId = leadId;
        objTask.Status = 'In Progress';
        objTask.Priority = 'Normal';
        objTask.CCPM_communicationDirection__c = communicationDirection;  
        
        try{
            insert objTask;
            return objTask;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating task/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    
    /**
*@author        Brigadesh (Deloitte)
*@description   This method is used for inserting a User
*@param :       String - Profile Name
*@return :      User- Returns Record of the inserted User
*/    
    
    public static User CreateUser(String Profile1, String makeUnique)
    {
        Profile p = [SELECT Id,Name FROM Profile WHERE Name=:Profile1 Limit 1]; 
        User u = new User(Alias = 'tstusr1', Email='standardtestuser1412@testorgUAT.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',firstname='a', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsActive = True,
                          TimeZoneSidKey='America/Los_Angeles', UserName= makeUnique+'stest@testorg.com',mobilephone='3214249106');             
        try{
            insert u;
            return u;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating User/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    /**
*@author        Brigadesh (Deloitte)
*@description   This method is used for inserting a User
*@param :       String - Profile Name
*@return :      User- Returns Record of the inserted User
*/
    
    Public static void createCustomSetting(){
        //CCPM_testDataFactory.CreateUser('CCPM Integration User', 'IU');
        //list<User> u= [select id from user where Alias = 'tstusr1' limit 1]; 
        CCPM_globalSetting__c objCustSettings = CCPM_globalSetting__c.getOrgDefaults();   
        list<group> lstHeadQuartersQueue = [select id from group where type = 'Queue' and name='Headquarters' limit 1]; 
        objCustSettings.CCPM_initialSMSInterval__c = '5';
        objCustSettings.CCPM_leadExpiryRecordTypes__c = 'Customer Cart';
        objCustSettings.CCPM_outgoingSMSReferenceId__c='InitialSMSPart1:InitialSMSPart2:FollowUp:NewProspectSMS1:NewProspectSMS2:PreDefinedSMS';
        objCustSettings.CCPM_followUpSMSInterval__c = '600';
        objCustSettings.CCPM_cartClosedStatus__c = 'Expired:Converted:Rejected:Rejected-DNS';
        objCustSettings.CCPM_liveTextPhoneNumber__c ='+17206864418';
        objCustSettings.CCPM_liveTextNumberNonVerizon__c ='+17206864418';
        objCustSettings.CCPM_taskInteractionHistoryRecordTypeId__c='01241000000xyiR';
        objCustSettings.CCPM_taskToDoRecordTypeId__c= '01241000000xyiS'; 
        objCustSettings.CCPM_leadReqActionSMSTimeInterval__c = 2;
        objCustSettings.CCPM_heywireAPIAccountID__c = '487c5776-e291-4152-8596-87b07b1b5c8a';
        objCustSettings.CCPM_heywireAPIAdminPassword__c = '690d7269-0a2e-45a7-88a1-da264da42f8e';
        objCustSettings.CCPM_heywireAPIEndpointURL__c  = 'https://app.hwlivetext.com/api/4.3/account/-LiveTextNumber-/message?to=%2B1-MTN-&body=-MsgBody';  
        objCustSettings.CCPM_leadCustomerAbandonedCartRecordType__c = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer Cart').getRecordTypeId();
        objCustSettings.CCPM_leadProspectAbandonedCartRecordType__c = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Prospect Cart').getRecordTypeId();
        objCustSettings.CCPM_leadProspectRecordType__c = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        objCustSettings.CCPM_SMSFailCounter__c='2';
        objCustSettings.CCPM_sendSMSBatchChunk__c='50';
        objCustSettings.CCPM_removeScheduleBatchSize__c='50';
        objCustSettings.CCPM_sendSMSBatchLimit__c='2000';
        objCustSettings.CCPM_leadOpenStatus__c = 'New:Eligible:Contacted:Responded:Qualified';
        objCustSettings.CCPM_DataIntegrationQueue__c = lstHeadQuartersQueue[0].id;
        objCustSettings.CCPM_EncryptedKey__c ='6159644412316563';
        objCustSettings.CCPM_EncryptionAlgorithm__c ='AES128';
        objCustSettings.CCPM_customSwitchToAvoidUpdateTrigger__c=false;
        
        CCPM_storesNotConsidered__c objSNCCustomsettings = CCPM_storesNotConsidered__c.getOrgDefaults();
        objSNCCustomsettings.CCPM_market__c = 'South Central';
        objSNCCustomsettings.CCPM_territory__c = 'South Texas';
        objSNCCustomsettings.CCPM_district__c = 'ST06-Houston Northeast';
        upsert objSNCCustomsettings ;
        
        //objCustSettings.CCPM_dataIntegrationUserID__c = u[0].id;
        system.debug('&&&& objCustSettings: '+ objCustSettings);
        upsert objCustSettings;
        
        List<CCPM_suppressOutboundSMS__c> lstSuppressOutboundMessage = new List<CCPM_suppressOutboundSMS__c>();
        CCPM_suppressOutboundSMS__c objSuppressOutboundMessage = CCPM_suppressOutboundSMS__c.getOrgDefaults();
        objSuppressOutboundMessage.Name = 'Test Setting1';
        objSuppressOutboundMessage.District__c = 'District';
        objSuppressOutboundMessage.IsActive__c = true;
        objSuppressOutboundMessage.Market__c = 'Market';
        objSuppressOutboundMessage.Territory__c = 'Territory';
        lstSuppressOutboundMessage.add(objSuppressOutboundMessage);
        upsert lstSuppressOutboundMessage;
    }
    
    public static void updateTriggerSwitch(){
        CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(UserInfo.getUserId());
        settings.CCPM_DisableOldTriggerForTest__c = true;
        upsert settings;
    }
    
    public static Boolean IsDisabled()
    {
        boolean boolTriggerDisabled = false;
        CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(UserInfo.getUserId());
        system.debug('@@@CCPM_DisableOldTriggerForTest__c : ' +settings.CCPM_DisableOldTriggerForTest__c) ;
        if(settings != null && settings.CCPM_DisableTrigger__c == true){
            return true;
        }
        else if(settings != null && settings.CCPM_DisableOldTriggerForTest__c == true){
            return true;
        }
        else{
            return boolTriggerDisabled;
        }  
    }
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This method is used for inserting a Cart of default record type
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Cart Records 
*/    
    public static List<lead> createCartdefaultRecordType(Integer NoOfRecords, List<String> accountUniqueID, List<String> LastName, List<String> cartUniqueId, List<String> storeID, List<String> cartLastHandledBy)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        //System.debug('@@@@ accountUniqueID : ' + accountUniqueID);
        //System.debug('@@@@ LastName : ' + LastName);
        //System.debug('@@@@ cartUniqueId : ' + cartUniqueId);
        //System.debug('@@@@ storeID : ' + storeID);
        //System.debug('@@@@ cartLastHandledBy : ' + cartLastHandledBy);
        for(integer i=0;i<NoOfRecords;i++){
            Lead objCart=new Lead();
            objCart.LastName=LastName[i];
            objCart.Status='New';
            objCart.Company = '1';           
            objCart.CCPM_accountNumber__c = accountUniqueID[i];
            objCart.CCPM_accountUniqueID__c = accountUniqueID[i];
            objCart.CCPM_storeID__c = storeID[i];
            objCart.CCPM_cartlastHandledBy__c = cartLastHandledBy[i];
            objCart.CCPM_mobileNumber__c = '3213187287';
            objCart.CCPM_email__c ='test@gmail.com';
            datetime date1=Datetime.now();
            objCart.CCPM_createdDate__c=date1.addHours(-5);
            objCart.CCPM_cartUniqueID__c = cartUniqueId[i];
            objCart.CCPM_SMSLegalOptIn__c =true;
            objCart.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
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
*@author        Aneesha Ragireddy (Deloitte)
*@description   This method is used for inserting a Cart
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Cart Records 
*/    
    public static lead createCartProspectTestContacted(Integer NoOfRecords,String event)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        Lead objCart=new Lead();
        objCart.LastName= 'testName';
        //objCart.CCPM_isSMSResponseReceived__c= false;
        objCart.CCPM_SMSLegalOptIn__c = true;
        Date dattoday = system.today().addMonths(1);
        objCart.CCPM_eventType__c= event;
        objCart.CCPM_SMSFollowUpDate__c = dattoday;
        objCart.Status=CCPM_staticConstants.strLeadStatusContacted;
        objCart.Company = '1';   
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_confirmMTN__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.RecordTypeId = CCPM_staticConstants.strProspectRecordTypeID;
        try{
            if(objCart!= null){
                System.debug('@@@@ objCart : ' + objCart);
                insert objCart;
            }
            return objCart;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating cart/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    /**
*@author        Aneesha Ragireddy (Deloitte)
*@description   This method is used for inserting Leads
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Leads
*/    
    public static List<Lead> createmyActiveLeadsTest(Integer NoOfRecords,String event, String strLeadtype)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        List<String> lstAlphabets = new List<String>{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
            for(Integer i=0; i<NoOfRecords;i++){
                Lead objCart=new Lead();
                objCart.LastName= 'test'+lstAlphabets[i];
                //objCart.CCPM_isSMSResponseReceived__c= false;
                objCart.CCPM_SMSLegalOptIn__c = true;
                Date dattoday = system.today().addMonths(1);
                objCart.CCPM_eventType__c= event;
                objCart.CCPM_SMSFollowUpDate__c = dattoday;
                objCart.Status=CCPM_staticConstants.strLeadStatusContacted;
                objCart.Company = '1';   
                objCart.CCPM_mobileNumber__c = '3213187287';
                objCart.CCPM_confirmMTN__c = '3213187287';
                objCart.CCPM_email__c ='test@gmail.com';
                objCart.CCPM_LeadType__C= strLeadtype;
                lstObjCart.add(objCart);
            }
        try{
            if(lstObjCart!= null){
                System.debug('@@@@ lstObjCart : ' + lstObjCart);                 
            } 
            return lstObjCart;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating cart/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    public static List<CCPM_SMSMessage__c> insertSMSObjectRecord(integer NoOfRecords, string strmessage, string messageType,id idLead){
        List<CCPM_SMSMessage__c> insSMSMessageObj= new List<CCPM_SMSMessage__c>();
        for(integer i=0;i<NoOfRecords;i++)
        {
            system.debug('&&&& i: '+ i);
            system.debug('&&&& NoOf Records: '+NoOfRecords);
            CCPM_SMSMessage__c smsMessageObj = new CCPM_SMSMessage__c();
            smsMessageObj.CCPM_leadRecord__c = idLead;
            smsMessageObj.CCPM_LiveTextNumber__c = '+17206864418';
            smsMessageObj.CCPM_message__c = strmessage;
            smsMessageObj.CCPM_messageType__c = messageType;
            smsMessageObj.CCPM_referenceId__c = 'InitialSMSPart100Q63000003ju7jEAA';
            smsMessageObj.CCPM_ScheduleDateTime__c = Datetime.now();
            smsMessageObj.CCPM_toPhoneNumber__c = '(321) 424-9106';
            smsMessageObj.CCPM_SMSFailCounter__c = '0';
            smsMessageObj.CCPM_communicationDirection__c= 'Outbound';
            smsMessageObj.CCPM_MessageStatus__c=CCPM_staticconstants.strMessageStatusQueued;
            insSMSMessageObj.add(smsMessageObj);
        }
        return insSMSMessageObj;
    }
    
    public static List<CCPM_SMSMessage__c> insertSMSObjectRecordTest(integer NoOfRecords, string strmessage, string messageType,id idLead){
        List<CCPM_SMSMessage__c> insSMSMessageObj= new List<CCPM_SMSMessage__c>();
        for(integer i=0;i<NoOfRecords;i++)
        {
            system.debug('&&&& i: '+ i);
            system.debug('&&&& NoOf Records: '+NoOfRecords);
            CCPM_SMSMessage__c smsMessageObj = new CCPM_SMSMessage__c();
            smsMessageObj.CCPM_leadRecord__c = idLead;
            smsMessageObj.CCPM_LiveTextNumber__c = '+17206864418';
            smsMessageObj.CCPM_message__c = strmessage;
            smsMessageObj.CCPM_messageType__c = messageType;
            smsMessageObj.CCPM_referenceId__c = 'InitialSMSPart100Q63000003ju7jEAA';
            smsMessageObj.CCPM_ScheduleDateTime__c = Datetime.now();
            smsMessageObj.CCPM_toPhoneNumber__c = '(321) 424-9106';
            smsMessageObj.CCPM_SMSFailCounter__c = '0';
            smsMessageObj.CCPM_communicationDirection__c= 'Outbound';
            smsMessageObj.CCPM_MessageStatus__c=CCPM_staticconstants.strMessageStatusSent;
            insSMSMessageObj.add(smsMessageObj);
        }
        return insSMSMessageObj;
    }
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is used for generating a random string
*@param :       Integer - length of the string to be returned
*@return :      String - random unique string
*/     
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is used for inserting a Cart
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Cart Records 
*/    
    public static lead createCartProspectTest(Integer NoOfRecords,String event)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        Lead objCart=new Lead();
        objCart.LastName= 'testName';
        objCart.CCPM_SMSLegalOptIn__c = true;
        Date dattoday = system.today().addMonths(1);
        objCart.CCPM_eventType__c= event;
        objCart.CCPM_SMSFollowUpDate__c = dattoday;
        objCart.Status='New';
        objCart.Company = '1';   
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_confirmMTN__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_LeadType__c = 'Prospect Abandoned Cart Digital';
        try{
            if(objCart!= null){
                System.debug('@@@@ objCart : ' + objCart);
                insert objCart;
            }
            return objCart;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating cart/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
    
    public static CCPM_SMSMessage__c insertSMSRecord(integer NoOfRecords, string strmessage, string messageType,id idLead){
        List<CCPM_SMSMessage__c> insSMSMessageObj= new List<CCPM_SMSMessage__c>();
        CCPM_SMSMessage__c smsMessageObj = new CCPM_SMSMessage__c();
        smsMessageObj.CCPM_leadRecord__c = idLead;
        smsMessageObj.CCPM_LiveTextNumber__c = '+17206864418';
        smsMessageObj.CCPM_message__c = strmessage;
        smsMessageObj.CCPM_messageType__c = messageType; 
        smsMessageObj.CCPM_referenceId__c = 'InitialSMSPart100Q63000003ju7jEAA';
        smsMessageObj.CCPM_ScheduleDateTime__c = Datetime.now();
        smsMessageObj.CCPM_toPhoneNumber__c = '(321) 424-9106';
        smsMessageObj.CCPM_SMSFailCounter__c = '0';
        smsMessageObj.CCPM_communicationDirection__c= 'Outbound';
        smsMessageObj.CCPM_MessageStatus__c=CCPM_staticconstants.strMessageStatusQueued;
        system.debug('@@@insSMSMessageObj'+smsMessageObj);
        return smsMessageObj;
    }        
    
    /**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This method is used for inserting a NPS
*@param :       id- Account id, Integer- Number of records needed to be inserted
*@return :      NPS- Returns List of NPS Records 
*/
    public static list <CCPM_NPS__c> createNPS(Account ObjCustomer)
    {
        list<CCPM_NPS__c> lstObjNPS = new list<CCPM_NPS__c>();
        CCPM_NPS__c objNPS = new CCPM_NPS__c();
        objNPS.Name = 'Test NPS';
        objNPS.CCPM_AccountHolderName__c = ObjCustomer.Id;
        objNPS.CCPM_dateSurveyCompleted__c = system.today();
        objNPS.CCPM_NPSChannel__c = 'Retail';
        objNPS.CCPM_NPSComments__c = 'testing NPS comments';
        objNPS.CCPM_NPSScore__c = 1;
        objNPS.CCPM_surveyMobileNumber__c = '1234567890';
        lstObjNPS.add(objNPS);
        try {
            insert lstObjNPS;
            return lstObjNPS;
        }
        Catch(DmlException e) {
            System.debug('The following exception has occurred while creating NPS/ClassName:CCPM_testDataFactory: ' + e.getMessage());
            return null;
        }
        
    }
    
   /**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This method is used to disable trigger
*@param :       none
*@return :      void 
*/
    public static void disableTrigger(){
        CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(UserInfo.getUserId());
        settings.CCPM_DisableTrigger__c = true;
        upsert settings;
    }

    /**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This method is to create Journey Message
*@param :       Integer- Number of records needed to be inserted
*@return :      Journey Message- Returns List of Journey Message Records  
*/ 
    public static list <CCPM_journeyMessage__c> createJourneyMessage(Integer NoOfRecords)
    { 
        list<CCPM_journeyMessage__c> lstJrnyMsg = new list <CCPM_journeyMessage__c> ();
        id JourneyMessageEventRecordtypeId=[select id from recordtype where name='Event Message'].id;
        for(integer i=0;i<NoOfRecords;i++)
        {
          CCPM_journeyMessage__c objJM = new CCPM_journeyMessage__c(); 
           objJM.CCPM_JourneyMessageName__c = 'test'+i;
           objJM.RecordTypeId = JourneyMessageEventRecordtypeId; 
           objJM.CCPM_isActive__c = true;
           objJM.CCPM_eventType__c = 'Tablets';
           lstJrnyMsg.add(objJM); 
        }
         return lstJrnyMsg;
    }
    
/**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This method is used for inserting a Cart
*@param :       Integer- Number of records needed to be inserted
*@return :      Lead- Returns List of Cart Records 
*/    
    public static List<lead> createCartProspectTestwithStore(Integer NoOfRecords,String event, CCPM_Store__c objStore, list<CCPM_storeEmployee__c> lsStoreEmployee)
    {   
        //To create test user and assign as OwnerId
        id LeadProspectRecordtypeId=[select id from recordtype where name='Prospect'].id;
        List<lead> lstObjCart = new List<lead>();
        for(integer i=0;i<NoOfRecords;i++)
        {
        Lead objCart=new Lead();
        objCart.LastName= 'testName'+i;
        objCart.CCPM_SMSLegalOptIn__c = true;
        Date dattoday = system.today().addMonths(1);
        objCart.CCPM_eventType__c= event;
        objCart.CCPM_SMSFollowUpDate__c = dattoday;
        objCart.Status='New';
        objCart.Company = '1';   
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_confirmMTN__c = '3213187287';
        objCart.Store__c = objStore.id; 
        objCart.CCPM_storeID__c = objStore.CCPM_storeID__c;
        objCart.CCPM_storeManager__c = lsStoreEmployee[0].CCPM_employee__c;
        objCart.ownerid = lsStoreEmployee[1].CCPM_employee__c;            
        objCart.RecordTypeId = LeadProspectRecordtypeId;        
        lstObjCart.add(objCart);    
        }
       return lstObjCart;        
    }
    
    /**
*@author        Anupreeta Chakraborty (Deloitte)
*@description   This method is to create store Sales Rep
*@param :       None
*/ 
    public static void createStoreRep(User u, CCPM_Store__c objStore)
    {
        list<CCPM_StoreEmployee__c> lstObjStoreEmployee=new list<CCPM_StoreEmployee__c>();     
        CCPM_StoreEmployee__c objStoreEmployee =new CCPM_StoreEmployee__c();    
        objStoreEmployee.CCPM_employee__c=u.id;
        objStoreEmployee.CCPM_role__c='Sales Rep'; 
        objStoreEmployee.CCPM_Store__c=objStore.Id;
        objStoreEmployee.CCPM_IsActive__c=true;
        objStoreEmployee.CCPM_uniqueStoreEmployeeID__c='12';
        lstObjStoreEmployee.add(objStoreEmployee);
        
         try{
            insert lstObjStoreEmployee;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating storeSalesRep/ClassName:TestDataFacory: ' + e.getMessage());
        }
    }
}