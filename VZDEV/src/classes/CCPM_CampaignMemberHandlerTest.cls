/**
*@name          CCPM_CampaignMemberTest
*@author        Sriraman Sridharan (Deloitte)
*@date          09/21/2017
@description    The Test Class is meant to unit test the Campaign Member trigger and its handler class
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                   Description
------------------------------------------------------------------------------------
Sriraman Sridharan(Deloitte)          09/27/2017              Original Version
*/
@isTest
public class CCPM_CampaignMemberHandlerTest {

    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    public static List<lead> createCart(Integer NoOfRecords, List<Account> accountUniqueID,string strmobilenumber, string unique)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        for(integer i=0;i<NoOfRecords;i++){
            Lead objCart=new Lead();
            objCart.LastName= 'LeadCampaign';
            objCart.FirstName='Count';
            objCart.Status='New';
            objCart.Company = '1';           
            objCart.CCPM_accountUniqueID__c = accountUniqueID[i].CCPM_accountUniqueID__c;
            objCart.CCPM_mobileNumber__c = '3213187287';
            datetime date1=Datetime.now();
            objCart.CCPM_cartUniqueID__c = accountUniqueID[i].CCPM_accountUniqueID__c + i + unique;
            objCart.CCPM_cartID__c = accountUniqueID[i].CCPM_accountUniqueID__c + i + unique;
            objCart.RecordTypeId = CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
            objCart.LeadSource = 'CRM';
            objCart.CCPM_LeadType__c = 'Customer Campaign';
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
            System.debug('The following exception has occurred while creating cart/ClassName:CCPM_CampaignMemberHandlerTest: ' + e.getMessage());
            return null;
        }
    }
public static List<lead> createClosedCart(Integer NoOfRecords, List<Account> accountUniqueID,string strmobilenumber, string unique)
    {   
        //To create test user and assign as OwnerId
        List<lead> lstObjCart = new List<lead>();
        for(integer i=0;i<NoOfRecords;i++){
            Lead objCart=new Lead();
            objCart.LastName= 'LeadCampaign';
            objCart.FirstName='Count';
            objCart.Status='Expired';
            objCart.Company = '1';           
            objCart.CCPM_accountUniqueID__c = accountUniqueID[i].CCPM_accountUniqueID__c;
            objCart.CCPM_mobileNumber__c = '3213187287';
            datetime date1=Datetime.now();
            objCart.CCPM_cartUniqueID__c = accountUniqueID[i].CCPM_accountUniqueID__c + i +unique;
            objCart.CCPM_cartID__c = accountUniqueID[i].CCPM_accountUniqueID__c + i +unique;
            objCart.RecordTypeId = CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
            objCart.LeadSource = 'CRM';
            objCart.CCPM_LeadType__c = 'Customer Campaign';            
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
            System.debug('The following exception has occurred while creating cart/ClassName:CCPM_CampaignMemberHandlerTest: ' + e.getMessage());
            return null;
        }
    }    
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to create Account with nearest store and store employee.
*/      
    public static List<Account> CreateAccountsWithNearestStore(integer NoOfRecords, String appendUnique){
        CCPM_testDataFactory.createStore(1);
        CCPM_store__c lstStore = [select id, CCPM_storeID__c from CCPM_store__c Limit 1];
        CCPM_testDataFactory.createStoreEmployee('Man','RN', 'IDC','AM', lstStore.id);
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
            objCustomer.BillingState='Alaska';
            objCustomer.BillingPostalCode='32745';
            ObjCustomer.CCPM_SMSOptOut__c=false;
            ObjCustomer.CCPM_storeID__c = lstStore.CCPM_storeID__c;
            lstObjCustomer.add(objCustomer);
        }
        try{
            insert lstObjCustomer;
            return lstObjCustomer;
        }
        Catch(DmlException e)
        {
            System.debug('The following exception has occurred while creating customer/ClassName:CCPM_CampaignMemberHandlerTest: ' + e.getMessage());
            return null;
        }
    }
    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to create cart data.
*/   
    public static void CreateData(){
        CCPM_testDataFactory.createCustomSetting();
        list<Account> lstObjCustomer= new List<Account>();
        lstObjCustomer =  CreateAccountsWithNearestStore(1, 'AccountOne');
        if(lstObjCustomer != null && lstObjCustomer.size()>0){
            List<lead> lstObjCart = createCart(1, lstObjCustomer,'3214249105','Unique');
            List<lead> lstObjCartConverted = createClosedCart(1, lstObjCustomer,'3214249105','Uni');
            System.debug('@@@lstObjCart: ' + lstObjCart);
        }
        else{
            System.debug('@@@lstObjCustomer: ' + lstObjCustomer);
        }
        //Create Journey message
        
        User SysAdmin = CCPM_testDataFactory.CreateUser('System Administrator' ,'SysAdmin');
        System.runAs(SysAdmin){ 
            CCPM_journeyMessage__c objCampaignJourneyMessage = new CCPM_journeyMessage__c();
            objCampaignJourneyMessage.CCPM_isActive__c = true;
            objCampaignJourneyMessage.CCPM_messageFollowUpSMS__c = 'FollowUpMessage';
            objCampaignJourneyMessage.CCPM_messageInitialSMS__c = 'InitialMessage';
            try{
                insert objCampaignJourneyMessage;
            }
            catch(Exception e){
                system.debug('@@@Exception :' + e);
            } 
        }
        
        //Create Campaign
        CCPM_journeyMessage__c objCampaignJourneyMessage = [Select id,CCPM_messageFollowUpSMS__c,CCPM_messageInitialSMS__c from CCPM_journeyMessage__c];
        if(objCampaignJourneyMessage != null){
            Campaign objCampaign = new Campaign();
            objCampaign.Name = 'Black Friday Campaign';
            objCampaign.IsActive = true;
            objCampaign.CCPM_campaignJourneyMessage__c = objCampaignJourneyMessage.id;
            try{
                insert objCampaign; 
            }
            Catch(Exception e){
                System.debug('@@@Exception' + e);
            }
        }
        else{
            System.debug('@@@objCampaignJourneyMessage Is Null');
        }
        
    }    

    /**
@author        Sriraman Sridharan(Deloitte)
@description   This method is targeted to test the handler class.
*/       
  static testmethod void CampaignMemberInsertTest()
  {
      CreateData();
      lead ObjCart = [Select id, name from Lead Limit 1];
      System.debug('@@@ObjCart: ' + ObjCart);
      test.startTest();
      Campaign objCampaign = [Select id, name from Campaign Limit 1];
      System.debug('@@@objCampaign: ' + objCampaign);
      //Create campaign member
      CampaignMember objCampaignMember = new CampaignMember();
      objCampaignMember.LeadID = ObjCart.Id;
      objCampaignMember.CampaignId = objCampaign.Id;
      try{
         insert objCampaignMember; 
      }
      catch(Exception e){
          system.debug('@@@objCampaignMember ' + objCampaignMember);
      }
      try{
          CampaignMember ObjFinalCampaignMember = [Select id, name, LeadId, CampaignId from CampaignMember];
            System.debug('@@@ObjFinalCampaignMember: ' + ObjFinalCampaignMember);
      }
      Catch(Exception e){
          System.debug('@@@ObjFinalCampaignMember error');
      }
      
      
      CampaignMember objCampaignMemberUpdate = [Select id, name ,CCPM_cartUniqueID__c from CampaignMember Limit 1];
      objCampaignMemberUpdate.CCPM_cartUniqueID__c = '3214249105Test';
      update objCampaignMemberUpdate;
      //delete objCampaignMemberUpdate;
      Map<Id, SObject> mapOldItems = null;
      CCPM_CampaignMemberTriggerHandler objcampaignclass = new CCPM_CampaignMemberTriggerHandler();
      objcampaignclass.AfterUndelete(mapOldItems);
      
      Map<string, CCPM_DynamicCampaignSMS__mdt> mapdynamicCampaignSMS = new map<string, CCPM_DynamicCampaignSMS__mdt>();
        List<CCPM_DynamicCampaignSMS__mdt> lstdynamicCampaignSMS = [Select MasterLabel,CCPM_CampaignName__c,CCPM_campaignSMSDate__c ,CCPM_dynamicURL__c
                                                                   From CCPM_DynamicCampaignSMS__mdt Where CCPM_isActive__c = true];
      //CreateData();
      string strexpired ='Expired';
      
      lead ObjCartOne = [Select id, name from Lead where status =: strexpired Limit 1];
      try{
          ObjCartOne.CCPM_isInitialSMSSent__c = true;
          ObjCartOne.Status = CCPM_staticConstants.strLeadStatusConverted;
          update ObjCartOne;
      }
      catch(Exception e){
          system.debug('@@@ObjCartOne ' + ObjCartOne);
      }
      CampaignMember objCampaignMemberOne = new CampaignMember();
      objCampaignMemberOne.LeadID = ObjCartOne.Id;
      objCampaignMemberOne.CampaignId = objCampaign.Id;
      
      try{
         insert objCampaignMemberOne; 
      }
      catch(Exception e){
          system.debug('@@@objCampaignMemberOne ' + objCampaignMemberOne);
      }
      test.stopTest();
  }  
}