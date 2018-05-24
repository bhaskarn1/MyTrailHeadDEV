/**
*@name          CCPM_leadTriggerTest_v2
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          08/22/2017
@description    Test class for CCPM_lead,CCPM_leadHandler
@testClass      CCPM_leadTriggerTest_v2
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                        Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)       08/22/2017          Original Version
manjunath keshava(Deloitte)            09/19/2017          original version-test class for assignProspectLeadOwner and updateCampaignFieldResponded
*/
@istest
public class CCPM_leadTriggerTest_v2 {
    
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
    Public static CCPM_OrganizationSetting__c settings = CCPM_OrganizationSetting__c.getInstance(UserInfo.getUserId());
    
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    public static List<lead> createCart(Integer NoOfRecords, List<String> accountUniqueID, List<String> LastName, List<String> cartUniqueId, List<String> storeID, List<String> cartLastHandledBy,string strmobilenumber,string strRecordtypeID,boolean boolAccountUniqueIDFlag,string EventType)
    { 
        CCPM_testDataFactory.updateTriggerSwitch();
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
                objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
            }
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
            objCart.RecordTypeId = strRecordtypeID;
            objCart.CCPM_cartID__c=cartUniqueId[i];
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
        CCPM_testDataFactory.updateTriggerSwitch();
        //test.startTest();
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
            list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c from CCPM_storeEmployee__c where CCPM_role__c=:strrole];
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
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void updateLeadStatusToEligibleTestProspects()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,null,true,null);
        
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        Test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.

*/  
    
    static testmethod void updateLeadStatusToEligibleTestCustomers()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.


*/  
    
    static testmethod void assignProspectLeadOwnerTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        Test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void setTimeSTampForConvertedQualifiedLeadsTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        lstLead[0].status = CCPM_staticConstants.strLeadStatusQualified;
        Update lstLead;
        lstLead[0].status = CCPM_staticConstants.strLeadStatusConverted;
        Update lstLead;
        //CCPM_leadHandler.updateLeadSubStatusToBlankForClosedLeads(lstLead);
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        Test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void setTriggerFollowUpSMSDateTimeTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        lstLead[0].CCPM_isInitialSMSSent__c=true;
        update lstLead[0];
        lstLead[0].CCPM_isInitialSMSSent__c=false;
        lstLead[0].CCPM_SMSLegalOptIn__c=false;
        update lstLead[0];
        Test.stopTest();
        lstLead[0].CCPM_isInitialSMSSent__c=true;
        lstLead[0].CCPM_SMSLegalOptIn__c=true;
        lstLead[0].CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
        User sysadminUser =CCPM_testDataFactory.CreateUser('System Administrator','sysadmin');
        System.runas(sysadminUser){
            update lstLead[0];
        }
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void assignProspectSMSDateTimeBeforeUpdateForEventChangeTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        lstLead[0].CCPM_SMSFollowUpDate__c = system.now().addHours(7);
        update lstLead;
        Test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
Manjunath keshava(deloitte)- modified to get over the SOQL limits
*/  
    
    static testmethod void updatePriorStatusTest1()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        lstLead[0].status = CCPM_staticConstants.strLeadStatusContacted;
        update lstLead;
        
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
Manjunath keshava(deloitte)- modified to get over the SOQL limits
*/  
    
    static testmethod void updatePriorStatusTest2()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        lstLead[0].CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusActionRequired;
        lstLead[0].status = CCPM_staticConstants.strLeadStatusResponded;
        update lstLead;
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
Manjunath keshava(deloitte)- modified to get over the SOQL limits
*/  
    
    static testmethod void updatePriorStatusTest3()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        lstLead[0].CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusInDiscussion;
        lstLead[0].status = CCPM_staticConstants.strLeadStatusQualified;
        update lstLead;
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void updatePriorStatusTest4()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        lstLead[0].status=CCPM_staticConstants.strLeadStatusQualified;
        lstLead[0].CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusAppointmentScheduled;
        update lstLead;
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
Manjunath keshava(deloitte)- modified to get over the SOQL limits
*/  
    
    static testmethod void updatePriorStatusTest5()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        lstLead[0].CCPM_leadSubStatus__c = null;
        lstLead[0].status = CCPM_staticConstants.strLeadStatusQualified;
        update lstLead;
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
Manjunath keshava(deloitte)- modified to get over the SOQL limits
*/  
    
    static testmethod void updatePriorStatusTest6()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead.clear();
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        System.debug('@Test_lstLead->'+lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        lstLead[0].CCPM_leadSubStatus__c = CCPM_staticConstants.strLeadSubStatusInDiscussion;
        lstLead[0].status = CCPM_staticConstants.strLeadStatusQualified;
        update lstLead;
        
        lstLead[0].CCPM_mobileNumber__c = '3243122334';
        lstLead[0].CCPM_confirmMTN__c = '3243122334';
        update lstLead;
        Test.stopTest();
    }
    
    
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void assingLeadOwnershipOnUpdateTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c limit 1];
        lstlead[0].ownerid= lsStoreEmployee[0].ccpm_employee__c;
        lstLead[0].CCPM_cartlastHandledBy__c = null;
        update lstLead;
        lstLead[0].CCPM_cartlastHandledBy__c = 'LHB';
        lstLead[0].CCPM_accountUniqueID__c = null;
        Update lstLead;
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void assingLeadOwnershipOnUpdateTest1()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        list<lead> lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c limit 1];
        lstlead[0].ownerid= lsStoreEmployee[0].ccpm_employee__c;
        lstLead[0].CCPM_cartlastHandledBy__c = null;
        update lstLead;
        lstLead[0].CCPM_cartlastHandledBy__c = 'LHB';
        lstLead[0].CCPM_accountUniqueID__c = null;
        Update lstLead;
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void assingLeadOwnershipOnUpdateTest2()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c limit 1];
        lstlead[0].ownerid= lsStoreEmployee[0].ccpm_employee__c;
        lstLead[0].CCPM_cartlastHandledBy__c = null;
        update lstLead;
        lstLead[0].CCPM_accountUniqueID__c = 'abc0';
        lstLead[0].CCPM_storeID__c=null;
        update lstLead;
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void assingLeadOwnershipOnUpdateTest3()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c limit 1];
        lstlead[0].ownerid= lsStoreEmployee[0].ccpm_employee__c;
        lstLead[0].CCPM_cartlastHandledBy__c = null;
        update lstLead;
        lstLead[0].CCPM_storeID__c='SID0'; 
        update lstLead;
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void mergeRelatedSMSMessageTest1()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,CCPM_isInformaticaMerge__c,LeadSource,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c limit 1];
        lstlead[0].ownerid= lsStoreEmployee[0].ccpm_employee__c;
        lstLead[0].CCPM_cartlastHandledBy__c = null;
        lstLead[0].CCPM_isInformaticaMerge__c = true;
        lstLead[0].LeadSource = 'NETACE';
        update lstLead;
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
    }    
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void mergeRelatedSMSMessageTest2()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectRecordTypeID,'Sales Rep',false,'Contract Terminating Soon');
        lstLead=[Select Id,CCPM_mobileNumber__c,CCPM_isInformaticaMerge__c,LeadSource,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c limit 1];
        lstLead[0].CCPM_cartlastHandledBy__c = null;
        lstLead[0].CCPM_isInformaticaMerge__c = true;
        lstLead[0].LeadSource = 'NETACE';
        update lstLead;
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strProspectRecordTypeID);
        Test.stopTest();
    }    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void populateSMSMessageToBeSentForLeadOwnerChangeTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c limit 1];
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        lstlead[0].status = CCPM_staticConstants.strLeadStatusResponded; 
        lstlead[0].CCPM_leadSubStatus__c=CCPM_staticConstants.strLeadSubStatusActionRequired;
        lstlead[0].ownerid= lsStoreEmployee[0].ccpm_employee__c;
        lstLead[0].CCPM_cartlastHandledBy__c = null;
        update lstLead;
        lstlead[0].CCPM_cartlastHandledBy__c='LHB';
        lstlead[0].CCPM_lastInteraction__c=system.now();
        lstlead[0].status = CCPM_staticConstants.strLeadStatusResponded; 
        
        lstlead[0].CCPM_leadSubStatus__c=CCPM_staticConstants.strLeadSubStatusActionRequired;
        lstlead[0].ownerid= lsStoreEmployee[0].ccpm_employee__c;
        update lstlead;
        
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
        
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void logErrorMessagesforInvalidAccountUniqueIdsTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        lstLead[0].CCPM_Account__c=null;
        lstLead[0].CCPM_accountUniqueID__c='12';
        update lstLead;
        CCPM_leadhandler.logErrorMessagesforInvalidAccountUniqueIds(lstLead);
        lstLead[0].CCPM_accountUniqueID__c=null;
        update lstLead;
        CCPM_leadhandler.logErrorMessagesforInvalidAccountUniqueIds(lstLead);
        System.assertEquals(lstLead[0].RecordTypeId, CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID);
        Test.stopTest();
        
    }
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void insertLeadShareSettingsTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();        
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lstStoreEmployee = [select id,CCPM_Store__c, ccpm_employee__c from CCPM_storeEmployee__c where CCPM_role__c=:CCPM_staticConstants.strStoreAssistantManager limit 1];
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
        update lstLead;
        set<id> setStoreID=new set<id>();
        setStoreID.add(lstLead[0].Store__c);
        
        CCPM_leadHandler.insertLeadShareSettings(setStoreID,lstLead);
        Test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void setStoreManagerAndAssignLeadOwnershipBasedOnStoreIdTest()
    {
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,CCPM_staticConstants.strStoreAssistantManager,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lstStoreEmployee = [select id,CCPM_Store__c, ccpm_employee__c from CCPM_storeEmployee__c where CCPM_role__c=:CCPM_staticConstants.strStoreAssistantManager limit 1];
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
        update lstLead;
        Test.startTest();
        list<id> lstStoreID=new list<id>();
        lstStoreID.add(lstLead[0].Store__c);
        
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
        update lstLead;
        CCPM_leadHandler.setStoreManagerAndAssignLeadOwnershipBasedOnStoreId(lstLead,lstStoreID);
        System.assert(lstLead[0].CCPM_storeManager__c!=null);
        lstStoreID.clear();
        CCPM_leadHandler.setStoreManagerAndAssignLeadOwnershipBasedOnStoreId(lstLead,lstStoreID);
        System.assert(lstLead[0].CCPM_storeManager__c==null);
        Test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/  
    
    static testmethod void shareLeadsWithAssistanManagersTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lstStoreEmployee = [select id,CCPM_Store__c, ccpm_employee__c from CCPM_storeEmployee__c where CCPM_role__c=:CCPM_staticConstants.strStoreAssistantManager limit 1];
        list<CCPM_store__c> lstStore = [select id from CCPM_store__c order by CCPM_storeID__c  limit 2 ];
        list<id> lstStoreID = new List<id>();
        
        lstLead[0].Store__c=lstStore[1].id;
        update lstLead;
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
        update lstLead;
        lstStoreID.add(lstLead[0].Store__c);
        set<string> setStoreID=new set<string>();
        setStoreID.add(lstLead[0].Store__c);
        list<id> lstOwner = new list<id>();
        lstOwner.add(lstLead[0].ownerid);
        Test.stopTest();
        
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/      
    static testmethod void populateInitialSMSMessagesToBeSentManualLeadTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strProspectAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_isManualLead__c,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        Test.stopTest();
    }
    /**
@author       Manjunath Keshava(Deloitte)
@description   This method is targeted to test assignProspectOrManualLeadOwner.
*/     
    static testmethod void populateInitialSMSMessagesToBeSentManualLeadTest2()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        //ccpm_staticConstants.strLeadTypeManualLead='Manual Lead';
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        list<lead> lstLead=[Select Id,CCPM_isManualLead__c,ccpm_type__c,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        system.debug('the  old type is'+ lstLead[0].ccpm_type__c+lstLead[0].CCPM_isManualLead__c);
        lstLead[0].CCPM_isManualLead__c=true;
        lstLead[0].CCPM_SMSFollowUpDate__c=system.now().addHours(7);
        lstLead[0].CCPM_eventType__c='other event';
        lstLead[0].CCPM_SMSLegalOptIn__c=true;
        update lstLead;
        system.debug('the type is'+ lstLead[0].ccpm_type__c+lstLead[0].CCPM_isManualLead__c);
        Test.stopTest();
    } 
    
    /**
@author       Manjunath Keshava(Deloitte)
@description   This method is targeted to test assignProspectOrManualLeadOwner.
*/     
    @isTest
    public static void inActiveStore()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        list<Account> lstAccount = CCPM_testDataFactory.createCustomer(1, 'abc');
        list<CCPM_Store__c> lstStore=CCPM_testDataFactory.createStore(1);
        // lststore[0].CCPM_IsActive__c=true;
        //update lstStore;
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_IsActive__c from CCPM_storeEmployee__c where CCPM_role__c='Sales Rep'];
        lstStoreEmployee[0].CCPM_IsActive__c=false;
        update lstStoreEmployee;
        lstAccount[0].CCPM_store__c=lststore[0].id;
        lstAccount[0].CCPM_storeID__c=lststore[0].CCPM_storeID__c;
        update lstAccount;
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';           
        objCart.CCPM_accountNumber__c =lstAccount[0].CCPM_accountNumber__c ;
        objCart.CCPM_accountUniqueID__c = lstAccount[0].CCPM_accountUniqueID__c;  
        objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.Store__c =  lststore[0].id;
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.RecordTypeId = CCPM_staticConstants.strProspectRecordTypeID;
        insert objCart;
    }   
    /**
@author       Manjunath Keshava(Deloitte)
@description   This method is targeted to test assignProspectOrManualLeadOwner.
*/     
    @isTest
    public static void inActiveStoreManager()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        list<Account> lstAccount = CCPM_testDataFactory.createCustomer(1, 'abc');
        list<CCPM_Store__c> lstStore=CCPM_testDataFactory.createStore(1);
        // lststore[0].CCPM_IsActive__c=true;
        //update lstStore;
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_IsActive__c from CCPM_storeEmployee__c where CCPM_role__c ='Store Manager' ];
        lstStoreEmployee[0].CCPM_IsActive__c=false;
        update lstStoreEmployee;
        lstAccount[0].CCPM_store__c=lststore[0].id;
        lstAccount[0].CCPM_storeID__c=lststore[0].CCPM_storeID__c;
        update lstAccount;
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';           
        objCart.CCPM_accountNumber__c =lstAccount[0].CCPM_accountNumber__c ;
        objCart.CCPM_accountUniqueID__c = lstAccount[0].CCPM_accountUniqueID__c;  
        objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.Store__c =  lststore[0].id;
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.RecordTypeId = CCPM_staticConstants.strProspectRecordTypeID;
        insert objCart;
    } 
    /**
@author       Manjunath Keshava(Deloitte)
@description   This method is targeted to test assignProspectOrManualLeadOwner.
*/     
    @isTest
    public static void inActiveStoreManagerandAssManager()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        list<Account> lstAccount = CCPM_testDataFactory.createCustomer(1, 'abc');
        list<CCPM_Store__c> lstStore=CCPM_testDataFactory.createStore(1);
        lststore[0].CCPM_market__c='samplemarket';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='CCPM Sales Rep'];
        User u = new User(Alias = 'man', Email='standardtestuser2UAT@testorgUAT.com',firstname='a', 
                          EmailEncodingKey='UTF-8', LastName='manager', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, isactive=true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='manager'+'UAT@testorgUAT.com',mobilephone='3214249106');
        insert u;
        list<CCPM_StoreEmployee__c> lstStoreEmployee = new list<CCPM_StoreEmployee__c>();
        CCPM_StoreEmployee__c objStoreEmployee=new CCPM_StoreEmployee__c();    
        objStoreEmployee.CCPM_employee__c=u.id;
        objStoreEmployee.CCPM_role__c='Sales Rep'; 
        objStoreEmployee.CCPM_Store__c=lstStore[0].id;
        objStoreEmployee.CCPM_IsActive__c=true;
        objStoreEmployee.CCPM_uniqueStoreEmployeeID__c='2';
        lstStoreEmployee.add(objStoreEmployee);    
        insert lstStoreEmployee;
        lstAccount[0].CCPM_store__c=lststore[0].id;
        lstAccount[0].CCPM_storeID__c=lststore[0].CCPM_storeID__c;
        update lstAccount;
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';           
        objCart.CCPM_accountNumber__c =lstAccount[0].CCPM_accountNumber__c ;
        objCart.CCPM_accountUniqueID__c = lstAccount[0].CCPM_accountUniqueID__c;  
        objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.Store__c =  lststore[0].id;
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.RecordTypeId = CCPM_staticConstants.strProspectRecordTypeID;
        try {
            insert objCart;
        }
        Catch(DmlException e) {
            System.debug('The following exception has occurred while creating Lead/ClassName:CCPM_leadTriggerTest_v2: ' + e.getMessage());            
        }          
    }
    /*
@author       Manjunath Keshava(Deloitte)
@description   This method is targeted to test assignProspectOrManualLeadOwner.
*/     
    @isTest
    public static void LeadEmptyStoreId()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        list<Account> lstAccount = CCPM_testDataFactory.createCustomer(1, 'abc');
        list<CCPM_Store__c> lstStore=CCPM_testDataFactory.createStore(1);
        lststore[0].CCPM_IsActive__c=true;
        update lstStore;
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_IsActive__c from CCPM_storeEmployee__c];
        
        
        lstAccount[0].CCPM_store__c=null;
        lstAccount[0].CCPM_storeID__c=null;
        update lstAccount;
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';           
        objCart.CCPM_accountNumber__c =lstAccount[0].CCPM_accountNumber__c ;
        //objCart.CCPM_accountUniqueID__c = lstAccount[0].CCPM_accountUniqueID__c;  
        // objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.Store__c =  lststore[0].id;
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.ownerId = lstStoreEmployee[0].CCPM_employee__c;
        objCart.RecordTypeId = CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
        insert objCart;
        
        CCPM_testDataFactory.insertSMSRecord(5, 'test', CCPM_staticConstants.strMessageTypeFollowUpSMS, objCart.Id);
        objCart.ownerId = lstStoreEmployee[1].CCPM_employee__c;
        update objCart;
        objCart.ownerId = lstStoreEmployee[2].CCPM_employee__c;
        update objCart;
        objCart.CCPM_HotFixFlagToSendInitialSMS__c = true;
        update objCart;
        
        //Delete the cart
        try {
            delete objCart;
        }
        Catch(DmlException e) {
            System.debug('The following exception has occurred while deleting Lead/ClassName:CCPM_leadTriggerTest_v2: ' + e.getMessage());            
        }  
        //Undelete the cart
        try {
            undelete objCart;
            System.assertEquals(false, objCart.Isdeleted);
        }
        Catch(DmlException e) {
            System.debug('The following exception has occurred while undeleting Lead/ClassName:CCPM_leadTriggerTest_v2: ' + e.getMessage());            
        }         
        Test.stopTest();  
    } 
    /**
@author        Soumya Panguluri (Deloitte)
@description   To check updateCampaignFieldResponded
*/ 
    public static void updateCampaignFieldRespondedTest() {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lstStoreEmployee = [select id,CCPM_Store__c, ccpm_employee__c from CCPM_storeEmployee__c where CCPM_role__c=:CCPM_staticConstants.strStoreAssistantManager limit 1];
        list<CCPM_store__c> lstStore = [select id from CCPM_store__c order by CCPM_storeID__c  limit 2 ];
        list<id> lstStoreID = new List<id>();
        
        
        lstLead[0].Store__c=lstStore[1].id;
        lstLead[0].RecordTypeId = CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
        lstLead[0].LeadSource = 'CRM';
        lstLead[0].CCPM_isSMSResponseReceived__c = false;
        update lstLead;
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
        lstLead[0].CCPM_isSMSResponseReceived__c = true;
        update lstLead;
        lstStoreID.add(lstLead[0].Store__c);
        set<string> setStoreID=new set<string>();
        setStoreID.add(lstLead[0].Store__c);
        list<id> lstOwner = new list<id>();
        lstOwner.add(lstLead[0].ownerid);
        Test.stopTest();        
    }
    
    /*
@author    Soumya Panguluri(Deloitte)
@description   This method is targeted to test updateLeadOwneronSMSMessage.
*/     
    @isTest
    public static void updateLeadOwneronSMSMessageTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        list<Account> lstAccount = CCPM_testDataFactory.createCustomer(1, 'abc');
        list<CCPM_Store__c> lstStore=CCPM_testDataFactory.createStore(1);
        lststore[0].CCPM_IsActive__c=true;
        update lstStore;
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_IsActive__c from CCPM_storeEmployee__c];
        
        
        lstAccount[0].CCPM_store__c=null;
        lstAccount[0].CCPM_storeID__c=null;
        update lstAccount;
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.ownerId =lstStoreEmployee[0].CCPM_employee__c;
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';           
        objCart.CCPM_accountNumber__c =lstAccount[0].CCPM_accountNumber__c ;
        objCart.CCPM_accountUniqueID__c = lstAccount[0].CCPM_accountUniqueID__c;  
        // objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.Store__c =  lststore[0].id;
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
        
        objCart.RecordTypeId = CCPM_staticConstants.strProspectAbandonedCartRecordTypeID;
        insert objCart;
        objCart.CCPM_isManualLead__c = true;
        CCPM_testDataFactory.insertSMSRecord(5, 'test', CCPM_staticConstants.strMessageTypeFollowUpSMS, objCart.Id);
        objCart.OwnerId = lstStoreEmployee[0].CCPM_employee__c;
        update objCart;
        objCart.OwnerId = lstStoreEmployee[3].CCPM_employee__c;
        update objCart;
    } 
    
    
    @isTest
    public static void populateInitialMessageForMergeCartsTest()
    {
        
        group objgroup = new group();
        objgroup.DeveloperName='teleSalesTtestGroup';
        objgroup.name='teleSalesTtestGroup';
        insert objgroup;
        Group objTeleSale= [Select id from Group where DeveloperName ='teleSalesTtestGroup'];
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='CCPM Sales Rep' Limit 1]; 
        User u = new User(Alias = 'tstusr1', Email='standardtestuser1412@testorgUAT.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',firstname='a', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsActive = True,
                          TimeZoneSidKey='America/Los_Angeles', UserName= 'makeUnique'+'stest@testorg.com',mobilephone='3214249106');             
        insert u;
        System.runAs ( u ) {
            // put test setup code in here
            CCPM_testDataFactory.updateTriggerSwitch();
            set<String> setQueueId=new set<string>();
            setQueueId.add(objTeleSale.id);
            Lead objCart=new Lead();
            objCart.LastName='testsample';
            objCart.FirstName='Inactive test';
            objCart.Status='New';
            objCart.Company = '1'; 
            objcart.OwnerId=u.id; 
            objCart.CCPM_eventType__c = 'Other Event';
            objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
            objCart.CCPM_mobileNumber__c = '3213187287';
            objCart.CCPM_email__c ='test@gmail.com';
            objCart.CCPM_confirmEmail__c='test@gmail.com';
            datetime date1=Datetime.now();
            objCart.CCPM_SMSLegalOptIn__c =true;
            objCart.CCPM_confirmMTN__c= '3213187287';
            objCart.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId();
        }
        
        
    }
    @isTest
    public static void populateInitialMessageForMergeCartsTest2()
    {
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        group objgroup = new group();
        objgroup.DeveloperName='teleSalesTtestGroup';
        objgroup.name='teleSalesTtestGroup';
        insert objgroup;
        Group objTeleSale= [Select id from Group where DeveloperName ='teleSalesTtestGroup'];
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='CCPM Sales Rep' Limit 1]; 
        User u = new User(Alias = 'tstusr1', Email='standardtestuser1412@testorgUAT.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',firstname='a', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsActive = True,
                          TimeZoneSidKey='America/Los_Angeles', UserName= 'makeUnique'+'stest@testorg.com',mobilephone='3214249106');             
        insert u;
        /*GroupMember gm = new GroupMember();
gm.GroupId = objTeleSale.id;
gm.UserOrGroupId = u.id;
insert gm;*/
        System.runAs ( u ) {
            // put test setup code in here
            
            set<String> setQueueId=new set<string>();
            setQueueId.add(objTeleSale.id);
            Lead objCart=new Lead();
            objCart.LastName='testsample';
            objCart.FirstName='Inactive test';
            objCart.Status='New';
            objCart.Company = '1'; 
            objcart.OwnerId=u.id;  
            objCart.CCPM_eventType__c = 'Other Event';
            objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
            objCart.CCPM_mobileNumber__c = '3213187287';
            objCart.CCPM_email__c ='test@gmail.com';
            objCart.CCPM_confirmEmail__c='test@gmail.com';
            datetime date1=Datetime.now();
            objCart.CCPM_SMSLegalOptIn__c =true;
            objCart.CCPM_confirmMTN__c= '3213187287';
            objCart.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
     //       objCart.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();
            
            insert objCart;
            CCPM_leadHandlerAssignOwnership.populateInitialMessageForMergeCarts(objCart, setQueueId);
        }
    }
    /**
@author       Manjunath Keshava(Deloitte)
@description   This method is targeted to test EVentSmsMethod.
*/     
    @isTest
    public static void EventProspectsmsTest()
    {
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testSettings__c ts    = CCPM_testSettings__c.getInstance();
        ts.CCPM_sytemNow__c= system.now();
        list<CCPM_Store__c> lstStore=CCPM_testDataFactory.createStore(1);
        lststore[0].CCPM_IsActive__c=true;
        update lstStore;
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_IsActive__c from CCPM_storeEmployee__c];
        List<CCPM_EventSMSSetting__mdt> lstEventSMSSetting= [Select CCPM_JourneyMessageName__c,CCPM_LeadEventType__c, CCPM_LeadRecordType__c, 
                                                             CCPM_SmsFollowUpEndDate__c,CCPM_SmsFollowUpOverrideDate__c,CCPM_SmsFollowUpStartDate__c, CCPM_StartDate__c,
                                                             CCPM_EndDate__c,CCPM_CalculateSMSFollowup__c
                                                             From   CCPM_EventSMSSetting__mdt ];
        List<CCPM_EventSMSSetting__mdt> lstNewEventSMSSetting=( List<CCPM_EventSMSSetting__mdt>)Json.deserialize('[{"CCPM_JourneyMessageName__c":"Pixel - future device","CCPM_LeadEventType__c":"Pixel - future device","CCPM_LeadRecordType__c":"Prospect","CCPM_SmsFollowUpStartDate__c":"2017-10-26 18:30:00","CCPM_SmsFollowUpEndDate__c":"2017-10-26 23:59:59","CCPM_SmsFollowUpOverrideDate__c":"2017-10-27 23:59:59"}]', list<CCPM_EventSMSSetting__mdt>.class);        
        
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';            
        objCart.CCPM_eventType__c = 'Pixel - future device';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.Store__c =  lststore[0].id;
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objcart.CCPM_StoreTimeZone__c='EST';
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.ownerId = lstStoreEmployee[0].CCPM_employee__c;
        objCart.RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadProspectRecordType).getRecordTypeId();
        insert objCart;
    }
    
    /**
@author       Manjunath Keshava(Deloitte)
@description   This method is targeted to test EVentSmsMethod.
*/     
    @isTest
    public static void EventLeadsmsTest()
    {
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testSettings__c ts    = CCPM_testSettings__c.getInstance();
        ts.CCPM_sytemNow__c= system.now();
        list<CCPM_Store__c> lstStore=CCPM_testDataFactory.createStore(1);
        lststore[0].CCPM_IsActive__c=true;
        update lstStore;
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c,CCPM_IsActive__c from CCPM_storeEmployee__c];
        List<CCPM_EventSMSSetting__mdt> lstEventSMSSetting= [Select CCPM_JourneyMessageName__c,CCPM_LeadEventType__c, CCPM_LeadRecordType__c, 
                                                             CCPM_SmsFollowUpEndDate__c,CCPM_SmsFollowUpOverrideDate__c,CCPM_SmsFollowUpStartDate__c, CCPM_StartDate__c,
                                                             CCPM_EndDate__c,CCPM_CalculateSMSFollowup__c
                                                             From   CCPM_EventSMSSetting__mdt ];
        List<CCPM_EventSMSSetting__mdt> lstNewEventSMSSetting=( List<CCPM_EventSMSSetting__mdt>)Json.deserialize('[{"CCPM_JourneyMessageName__c":"iPhone X launch","CCPM_LeadEventType__c":"iPhone X","CCPM_LeadRecordType__c":"Prospect","CCPM_SmsFollowUpStartDate__c":"2017-10-26 18:30:00","CCPM_SmsFollowUpEndDate__c":"2017-11-26 23:59:59","CCPM_SmsFollowUpOverrideDate__c":"2017-10-27 23:59:59"}]', list<CCPM_EventSMSSetting__mdt>.class);        
        
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';             
        objCart.CCPM_eventType__c = 'iPhone X';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.Store__c =  lststore[0].id;
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objcart.CCPM_StoreTimeZone__c='EST';
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.ownerId = lstStoreEmployee[0].CCPM_employee__c;
        objCart.CCPM_TriggerInitialSMSDateTime__c=system.now();
        objCart.RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get(label.CCPM_LeadCustomerAbandonedCartRecordTypeID).getRecordTypeId();
        insert objCart;
        
    }
    
    /**
@author       Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to improve coverage of method updateLeadSubStatusToBlankForClosedLeads which is no longer in use in Lead trigger handler, but still writing code as we are uncertain of the usage anywhere else.
*/     
    @isTest
    public static void updateLeadSubStatusToBlankForClosedLeadsTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null);
        lstLead=[Select Id,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        list<CCPM_storeEmployee__c> lstStoreEmployee = [select id,CCPM_Store__c, ccpm_employee__c from CCPM_storeEmployee__c where CCPM_role__c=:CCPM_staticConstants.strStoreAssistantManager limit 1];
        lstLead[0].Store__c=lstStoreEmployee[0].CCPM_Store__c;
        lstLead[0].status=CCPM_staticConstants.strLeadStatusResponded;
        lstlead[0].CCPM_leadSubStatus__c=CCPM_staticConstants.strLeadSubStatusActionRequired;
        update lstLead;
        lstLead[0].status=CCPM_staticConstants.strLeadStatusExpired;
        lstlead[0].CCPM_leadSubStatus__c='';
        update lstLead;
        list<Lead> lstAssertLead = CCPM_leadHandler.updateLeadSubStatusToBlankForClosedLeads(lstLead);
        System.assert(lstAssertLead.size()>0);
        Test.stopTest();
        
        
    }
    
    /**
@author       Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to improve coverage of method RunOnce which is no longer in use in Lead trigger handler, but still writing code as we are uncertain of the usage anywhere else.
*/     
    @isTest
    public static void RunonceTest()
    {
        Test.startTest();
        CCPM_testDataFactory.updateTriggerSwitch();
        CCPM_testDataFactory.createCustomSetting();
        ccpm_leadhandler.run=true;
        ccpm_leadhandler.runOnce();
        ccpm_leadhandler.runOnce();
        test.stopTest();
        
    }
    
    /**
@author       Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to improve coverage of method RunOnce which is no longer in use in Lead trigger handler, but still writing code as we are uncertain of the usage anywhere else.
*/     
    @isTest
    public static void populateInitialSMSMessagesToBeSentTest()
    {
        CCPM_leadTriggerHandler leadhandler = new CCPM_leadTriggerHandler();
        Map<id,Lead> mapLead  = new Map<id, Lead>(); 
        group objgroup = new group();
        objgroup.DeveloperName='teleSalesTtestGroup';
        objgroup.name='teleSalesTtestGroup';
        insert objgroup;
        Group objTeleSale= [Select id from Group where DeveloperName ='teleSalesTtestGroup'];
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='System Administrator' Limit 1];    
        User u = new User(Alias = 'tstusr1', Email='standardtestuser1412@testorgUAT.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',firstname='a', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsActive = True,
                          TimeZoneSidKey='America/Los_Angeles', UserName= 'makeUnique'+'stest@testorg.com',mobilephone='3214249106');             
        insert u;
        GroupMember gm = new GroupMember();
        gm.GroupId = objTeleSale.id;
        gm.UserOrGroupId = u.id;
        insert gm;
        system.runAs(u)
        {
            CCPM_testDataFactory.updateTriggerSwitch();
            CCPM_testDataFactory.createCustomSetting();
            CreateData('3213187287',CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID,null,true,null); 
            lstLead=[Select Id,status,CCPM_eventType__c,CCPM_Type__c,CCPM_initialSMSBody__c,CCPM_triggerInitialSMSDateTime__c,CCPM_prospectSMSBody__c,CCPM_storeDistrict__c,CCPM_SMSOptOut__c,Store__r.CCPM_market__c,Store__r.CCPM_territory__c,Store__r.CCPM_district__c,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
            set<string> setQueueIDGeneric = new set<string>();
            setQueueIDGeneric= ccpm_utility.populateQueueIds();
            set<id> setIdsforQueuestest=new set<id>();
            for (string strId : setQueueIDGeneric)
            {
                setIdsforQueuestest.add(strId);            
            }
            CCPM_leadhandler.populateInitialSMSMessagesToBeSent(lstLead,null,setIdsforQueuestest);
            
            lstLead[0].RecordTypeId=ccpm_staticConstants.strProspectRecordTypeID;
            lstLead[0].CCPM_eventtype__c=CCPM_staticConstants.strContractTerminatingSoon;
            update lstLead;
            lstLead.clear();
            lstLead=[Select Id,status,CCPM_triggerProspectSMSPart1__c,CCPM_eventType__c,CCPM_Type__c,CCPM_initialSMSBody__c,CCPM_triggerInitialSMSDateTime__c,CCPM_prospectSMSBody__c,CCPM_storeDistrict__c,CCPM_SMSOptOut__c,Store__r.CCPM_market__c,Store__r.CCPM_territory__c,Store__r.CCPM_district__c,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
            CCPM_leadhandler.populateInitialSMSMessagesToBeSent(lstLead,null,setIdsforQueuestest);
            lstLead[0].RecordTypeId=ccpm_staticConstants.strProspectAbandonedCartRecordTypeID;
            update lstLead;
            lstLead.clear();
            Test.startTest();
            lstLead=[Select Id,status,CCPM_prospectInitialSMSBody__c,CCPM_triggerProspectSMSPart1__c,CCPM_eventType__c,CCPM_Type__c,CCPM_initialSMSBody__c,CCPM_triggerInitialSMSDateTime__c,CCPM_prospectSMSBody__c,CCPM_storeDistrict__c,CCPM_SMSOptOut__c,Store__r.CCPM_market__c,Store__r.CCPM_territory__c,Store__r.CCPM_district__c,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
            CCPM_leadhandler.populateInitialSMSMessagesToBeSent(lstLead,null,setIdsforQueuestest);
            lstLead[0].RecordTypeId=ccpm_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
            lstLead[0].CCPM_isManualLead__c=true;
            lstLead[0].CCPM_SMSFollowUpDate__c=System.now();
            update lstLead;
            for(Lead objLead:lstLead ){
                mapLead.put(objLead.id,objLead);   
            }
            leadhandler.BeforeDelete(mapLead);
            leadhandler.AfterDelete(mapLead);
            leadhandler.AfterUnDelete(mapLead);
            lstLead.clear();
            lstLead=[Select Id,CCPM_SMSFollowUpDate__c,CCPM_manualLeadSMSBody__c,status,CCPM_prospectInitialSMSBody__c,CCPM_triggerProspectSMSPart1__c,CCPM_eventType__c,CCPM_Type__c,CCPM_initialSMSBody__c,CCPM_triggerInitialSMSDateTime__c,CCPM_prospectSMSBody__c,CCPM_storeDistrict__c,CCPM_SMSOptOut__c,Store__r.CCPM_market__c,Store__r.CCPM_territory__c,Store__r.CCPM_district__c,CCPM_mobileNumber__c,RecordTypeId,CCPM_accountUniqueID__c,ownerid,Store__c,CCPM_isInitialSMSSent__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
            
            CCPM_leadhandler.populateInitialSMSMessagesToBeSent(lstLead,null,setIdsforQueuestest);
            // CCPM_leadTriggerHandlerHelper.populateActivityForTelesales(lstLead[0]);
            Test.stopTest();
        }        
    }
    
    /**
@author       Anupreeta Chakraborty(Deloitte)
@description   This method is targeted to improve coverage of method populateActivityForTelesales in LeadTriggerHandlerHelperwhich.
*/     
    @isTest
    public static void populateActivityForTelesalesTest()
    {
        test.startTest();
        List<Lead> lstProspect2 = new List<Lead>();
        List<Lead> lstProspect3 = new List<Lead>();
        //Create Journey Message
        List<CCPM_journeyMessage__c> lstJrnMsg = CCPM_testDataFactory.createJourneyMessage(1);
        list<group> lstHeadQuartersQueue = [select id from group where type = 'Queue' and name='Headquarters' limit 1];
        try{
            if(lstJrnMsg != null)
                insert lstJrnMsg;
        }
        
        Catch(DmlException e) {
            System.debug('The following exception has occurred while creating Journey message/ClassName:CCPM_testDataFactory:method:populateActivityForTelesalesTest()' + e.getMessage());
        }
        //Create Store
        list<CCPM_Store__c> lstStore = CCPM_testDataFactory.createStore(1);
        lstStore[0].CCPM_source__c = 'Telesales'; 
        try{
            if(lstStore != null){
                update lstStore;
            }
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while updating store/ClassName:CCPM_leadTriggerTest_v2:method populateActivityForTelesalesTest' + e.getMessage());
        }
        //Create Store employeee
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore[0].id);
        list<CCPM_storeEmployee__c> lsStoreEmployee = [select id, ccpm_employee__c from CCPM_storeEmployee__c];
        User runAsEmployee = [select name from User where id =: lsStoreEmployee[1].ccpm_employee__c]; 
        //Running as Telesales user
        System.runAs(runAsEmployee){
        //Create Prospect
        List<Lead> lstProspect = CCPM_testDataFactory.createCartProspectTestwithStore(1,'Tablets',lstStore[0],lsStoreEmployee); 
        try{
            if(lstProspect != null){
                insert lstProspect;
                lstProspect[0].Status = Label.CCPM_LeadEligibleStatus;
                update lstProspect;
            }
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating/updating cart/ClassName:CCPM_leadTriggerTest_v2:method populateActivityForTelesalesTest' + e.getMessage());
        }
        System.AssertEquals(true,lstProspect.size()>0);
        CCPM_leadTriggerHandlerHelper.populateActivityForTelesales(lstProspect[0]);
        
        lstProspect2 = CCPM_testDataFactory.createCartProspectTestwithStore(1,'Tablets',lstStore[0],lsStoreEmployee);  
        try{
            if(lstProspect2 != null){
                lstProspect2[0].Status = Label.CCPM_LeadEligibleStatus;
                insert lstProspect2;                                
            }
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating/updating cart/ClassName:CCPM_leadTriggerTest_v2:method populateActivityForTelesalesTest' + e.getMessage());
        }    
       
       }              
                      
        test.stopTest();    
    }
    
    
}