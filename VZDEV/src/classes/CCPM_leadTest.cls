/**
*@name          CCPM_lead
*@author        Sriraman Sridharan (Deloitte)
*@date          02/16/2017
@description    US-0074: Associates the cart with the correct customer using Account Number
US-0024: Associates the preferred Store on the customer record on the correct Cart.


@testClass:     CCPM_leadTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sriraman(Deloitte)     01/30/2016              Modified Version
*/
//(SeeAllData=False)
@istest
public class CCPM_leadTest {
    
    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is targeted to test the CCPM_Lead Insert and few cases of Update Trigger
*@param :       None
*/
    //(SeeAllData=False)  
    @istest public static void testLeadCreation()
    {   
        //Create Custom setting
        CCPM_testDataFactory.createCustomSetting();
        //User integrationUser=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'integrationUser');
        User SysAdminUser=CCPM_testDataFactory.CreateUser('System Administrator','SysAdminUser');
        User objStoreEmployeeWithoutStore = CCPM_testDataFactory.CreateUser('CCPM Sales Rep', 'Salesrep');
        
        System.runAs(SysAdminUser){ 
             
            //Creating Store,Customer and Cart test data and it also triggers the before Insert Condition on CCPM_leadHandler
            list<CCPM_Store__c> lstObjStore = CCPM_testDataFactory.createStore(CCPM_staticConstants.NoOfRecords);
            //Parameters to createStoreEmployee -> (String managerName, String repName, String CommisionableRepID, String assistantManager, ID StoreID)
            //Returns a list of store employees.
            List<String> accountUniqueID = new List<String>();
            List<String> storeID = new List<String>();
            for(CCPM_Store__c store: lstObjStore){
                String managerName = 'M'+store.Name;
                String repName = 'S'+store.Name; 
                String CommisionableRepID = 'repID' + repName; 
                String assistantManager = 'A'+store.Name;
                CCPM_testDataFactory.createStoreEmployee(managerName,repName,CommisionableRepID,assistantManager,store.Id);
            }
            //Create Customer and assign one nearest store per customer.(Number of customers and stores are same for now)
            list<Account> lstCustomer=CCPM_testDataFactory.createCustomer(CCPM_staticConstants.NoOfRecords,'A');
            try{
                list<CCPM_Store__c> stores=[Select id,CCPM_storeID__c from CCPM_store__c limit :(lstCustomer.size())];
                for(integer i=0;i<(lstCustomer.size());i++)
                {
                    if(stores.size()>0 && stores!=null){
                        lstCustomer[i].CCPM_Store__c=stores[i].id;
                        lstCustomer[i].CCPM_storeID__c=stores[i].CCPM_storeID__c;
                        accountUniqueID.add(lstCustomer[i].CCPM_accountUniqueID__c);
                        storeID.add(stores[i].CCPM_storeID__c);
                    }
                }
            }
            Catch(DMLException e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadTest','testLeadCreation','Exception thrown while querying for store records',true);
            }
            //Individual Customer without a nearest store
            List<Account> lstCustomerWithoutNearestStore = CCPM_testDataFactory.createCustomer(1,'B');
            //Create Carts and assert test
            try{
                
                //CreateCarts
                //Parameters to create a Cart -> (String accountUniqueID, String LastName, String cartUniqueId, String storeID, string cartLastHandledBy)
                List<String> cartUniqueId = new List<String>();
                List<String> cartLastName = new List<String>(); 
                List<CCPM_storeEmployee__c> storeEmployee = [Select id, CCPM_employee__r.CCPM_commissionableRepID__c from CCPM_storeEmployee__c where CCPM_employee__r.CCPM_commissionableRepID__c!=null limit :CCPM_staticConstants.NoOfRecords];
                List<String> cartLastHandledBy = new List<String>();
                for(integer i=0;i<(CCPM_staticConstants.NoOfRecords /2);i++){
                    string strCartLastName = 'Cart'+i;
                    string strCartUniqueId = 'cartUniqueId'+strCartLastName;
                    cartLastName.add(strCartLastName);
                    cartUniqueId.add(strCartUniqueId);
                    cartLastHandledBy.add('asd');
                        //storeEmployee[i].CCPM_employee__r.CCPM_commissionableRepID__c);
                }
                for(integer i=(CCPM_staticConstants.NoOfRecords /2);i<CCPM_staticConstants.NoOfRecords;i++){
                    string strCartLastName = 'Cart'+i;
                    string strCartUniqueId = 'cartUniqueId'+strCartLastName;
                    cartLastName.add(strCartLastName);
                    cartUniqueId.add(strCartUniqueId);
                    cartLastHandledBy.add(''+i);
                }
                
                List<lead> lstCarts = CCPM_testDataFactory.createCart(CCPM_staticConstants.NoOfRecords,accountUniqueID,cartLastName,cartUniqueId, storeID, cartLastHandledBy);
                //List<lead> lstProsCarts = CCPM_testDataFactory.createCartProspectTest(CCPM_staticConstants.NoOfRecords,accountUniqueID,cartLastName,cartUniqueId, storeID, cartLastHandledBy);
                
                System.debug('@@@lstCartsfirst' +lstCarts);
                
               /* String CRON_EXP = '0 5 * * * ?'; 
        		CCPM_sendSMSBatch sch = new CCPM_sendSMSBatch();
        		system.schedule('CCPM_sendSMSBatch-5 Mins', CRON_EXP, sch); */
                
                List<String> cartUniqueId1 = new List<String>();
                List<String> cartLastName1 = new List<String>();
                test.startTest();
                //Cover UpdateCartUniqueId Else
                CCPM_leadHandler.run = true;
                List<Lead> lstCart1 = [Select id,Status from lead where Status = 'new' AND RecordTypeID =: CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID limit:1];
                if(lstCart1.size()>0 && lstCart1 != null){
                    lstCart1[0].Status = 'Responded';
                    lstCart1[0].CCPM_leadSubStatus__c = 'Action Required';
                    lstCart1[0].CCPM_isInitialSMSSent__c =false;
					//lstCart1[0].   
                    System.debug('@@@lstCart1' +lstCart1);
                    update lstCart1;
                }
                
                CCPM_leadHandler.run = true;
                //Cover UpdateCartUniqueId If
                List<Lead> lstCart2 = [Select id,Status from lead where Status = 'Contacted' AND RecordTypeID =: CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID limit:1];
                if(lstCart2.size()>0 && lstCart2 != null){
                    lstCart2[0].Status = 'Expired';
                    lstCart2[0].CCPM_accountUniqueID__c = lstCustomer[lstCustomer.size()-1].CCPM_accountUniqueID__c;
                    System.debug('@@@lstCart2' +lstCart2);
                    lstCart2[0].CCPM_isInitialSMSSent__c =false;
                    update lstCart2;
                }
                
                //Create Cart without cartlast handled by
                CCPM_leadHandler.run = true;
                List<String> storeIDSplit = new List<String>();
                for(integer i=0;i<(CCPM_staticConstants.NoOfRecords /2);i++){
                    string strCartLastName1 = 'Cart2'+i;
                    string strCartUniqueId1 = 'cartUniqueId2'+strCartLastName1;
                    cartLastName1.add(strCartLastName1);
                    cartUniqueId1.add(strCartUniqueId1);
                    storeIDSplit.add(storeID[i]);
                }
                for(integer i=(CCPM_staticConstants.NoOfRecords /2);i<CCPM_staticConstants.NoOfRecords;i++){
                    string strCartLastName1 = 'Cart2'+i;
                    string strCartUniqueId1 = 'cartUniqueId2'+strCartLastName1;
                    cartLastName1.add(strCartLastName1);
                    cartUniqueId1.add(strCartUniqueId1);
                    storeIDSplit.add('12345'+i);
                }
                
                List<lead> lstCartIndividualCustomer = CCPM_testDataFactory.createCartWithoutLastCartHandledBy(CCPM_staticConstants.NoOfRecords,accountUniqueID,cartLastName1,cartUniqueId1, storeIDSplit);
                System.debug('@@@lstCartsSecond' +lstCartIndividualCustomer);
                //Cart With Only wrong storeID's
                List<String> storeIDWrong = new List<String>();
                CCPM_leadHandler.run = true;
                List<String> cartUniqueId2 = new List<String>();
                List<String> cartLastName2 = new List<String>();
                for(integer i=0;i<(CCPM_staticConstants.NoOfRecords);i++){
                    string strCartLastName2 = 'Cart2'+i;
                    string strCartUniqueId2 = 'cartUniqueId2'+strCartLastName2;
                    cartLastName2.add(strCartLastName2);
                    cartUniqueId2.add(strCartUniqueId2);
                    storeIDWrong.add('abcd'+i);
                }
                List<lead> lstCartWithCustomer = CCPM_testDataFactory.createCartWithoutLastCartHandledBy(CCPM_staticConstants.NoOfRecords,accountUniqueID,cartLastName2,cartUniqueId2,storeIDWrong);
                System.debug('@@@lstCartsThird' +lstCartWithCustomer);
                //Change store ID to the List of all leads
                List<lead> allLeads = [Select id,OwnerId,CCPM_isInitialSMSSent__c, CCPM_storeID__c,CCPM_accountUniqueID__c,LastName,CCPM_cartUniqueID__c,CCPM_cartID__c,Store__r.id,CCPM_cartlastHandledBy__c from lead WHERE Store__r.id != null limit : CCPM_staticConstants.NoOfRecords];
                List<User> lstOwner = [Select id,CCPM_commissionableRepID__c from User where CCPM_commissionableRepID__c!= null limit:CCPM_staticConstants.NoOfRecords ];
                List<ID> lstOwnerReverse = new List<ID>();
                list<CCPM_Store__c> lstAllStore = [Select id,CCPM_storeID__c from CCPM_store__c limit :CCPM_staticConstants.NoOfRecords];
                List<ID> lstStoreIdBeforeReverse = new List<ID>();
                List<String> lstStoreReverse = new List<String>();
                //CCPM_leadHandler.run = true;
                System.debug('Size of lstAllStore'+lstAllStore.size());
                System.debug('Size of allLeads'+allLeads.size());
                for(integer i=0;i<lstAllStore.size();i++){
                    System.debug('Value of i: '+i);
                    if(allLeads!=null && allLeads.size()> i){
                        allLeads[i].CCPM_storeID__c = lstAllStore[i].CCPM_storeID__c;
                        if(i / 2 == 0){
                            allLeads[i].Status = 'Completed';
                            //allLeads[i].CCPM_isInitialSMSSent__c = false;
                        }
                        else{
                            allLeads[i].Status = 'Contacted'; 
                        }
                        allLeads[i].CCPM_cartUniqueID__c = 'abc'+i;
                        allLeads[i].CCPM_cartID__c = 'abcd'+i; 
                        //allLeads[i].CCPM_isInitialSMSSent__c = false;
                        lstStoreIdBeforeReverse.add(lstAllStore[i].id);
                    }
                }
                Update allLeads;
                CCPM_leadHandler.run = true;
                List<lead> allLeadsAfterUpdate = [Select id,OwnerId,CCPM_isInitialSMSSent__c, CCPM_storeID__c,CCPM_accountUniqueID__c,LastName,CCPM_cartID__c,CCPM_cartUniqueID__c,Store__r.id,CCPM_cartlastHandledBy__c from lead where Store__r.id IN:lstStoreIdBeforeReverse limit : CCPM_staticConstants.NoOfRecords];
                List<Account> lstAllCustomerAccount = [Select id,CCPM_store__r.id, CCPM_storeID__c,CCPM_accountUniqueID__c,CCPM_accountNumber__c from Account limit : CCPM_staticConstants.NoOfRecords];
                List<String> lstCustomerUniqueId = new List<String>();
                Integer j=0;
                for(integer i=(lstOwner.size()-1);i>0;i--){
                    if(lstOwner[j]!=null){
                        lstOwnerReverse.add(lstOwner[j].id);
                        lstStoreReverse.add(lstAllStore[j].CCPM_storeID__c);
                        lstCustomerUniqueId.add(lstAllCustomerAccount[j].CCPM_accountUniqueID__c);
                        j++;
                    }
                }
                for(integer i=0;i<lstOwnerReverse.size();i++){
                    if(allLeadsAfterUpdate!=null && allLeadsAfterUpdate.size()>i){
                        allLeadsAfterUpdate[i].OwnerId = lstOwnerReverse[i];
                        allLeadsAfterUpdate[i].CCPM_storeID__c = lstStoreReverse[i];   
                        allLeadsAfterUpdate[i].CCPM_accountUniqueID__c = lstCustomerUniqueId[i];
                        allLeadsAfterUpdate[i].CCPM_cartUniqueID__c = 'after'+i;
                        allLeadsAfterUpdate[i].CCPM_cartID__c = 'after'+i; 
                        allLeadsAfterUpdate[i].Status = 'Completed';
                        
                    } 
                }
                
                Update allLeadsAfterUpdate;
            
			}
            Catch(DMLException e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadTest','testLeadCreation','Exception thrown while Upserting',true);
            }
        
		}
        CCPM_leadHandler.run = true;
		List<Lead> L1 = [Select id,CCPM_isInitialSMSSent__c,CCPM_cartID__c FROM lead where CCPM_isInitialSMSSent__c = false LIMIT 1];
        system.debug('@@@L1' + L1);
        try{
            if(L1.size()>0 && L1 != null)
            {
                L1[0].CCPM_isInitialSMSSent__c = true;
                L1[0].CCPM_cartID__c = 'Unique12IDAB';
                Update L1;
            } 
        }Catch(DMLException e)
        {
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadTest','testLeadCreation','Exception thrown while Upserting',true);
        }
        
        test.stopTest();
    }
    @istest public static void assignProspectSMSDateTimeBeforeInsertTeststrContractTerminatingSoon()
    { 
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='CCPM Sales Rep'];
        list<CCPM_Store__c> lstObjStore = CCPM_testDataFactory.createStore(1);
        User u2 = new User(Alias = 'UToRun', Email='standardtestuser21UAT@testorgUAT.com', firstname='aA',
                          EmailEncodingKey='UTF-8', LastName= 'UserToRunAs', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='UserToRunAsUATA@testorgUAT.com',mobilephone='3213187287');
        CCPM_StoreEmployee__c objStoreEmployee3=new CCPM_StoreEmployee__c();    
        
        try{
            insert u2;
            objStoreEmployee3.CCPM_employee__c=u2.id;
            objStoreEmployee3.CCPM_role__c='Store Manager'; 
            objStoreEmployee3.CCPM_Store__c=lstObjStore[0].id;
            insert objStoreEmployee3;
        }
        catch(Exception e){
            CCPM_LogMessageUtility.logMessage(e,'CCPM_leadTest','assignProspectSMSDateTimeBeforeInsertTeststrContractTerminatingSoon','Exception thrown while inserting into user',true);
        }
        
        
        System.runAs(u2){ 
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strContractTerminatingSoon);
        }
        test.stopTest();
    }
     @istest public static void assignProspectSMSDateTimeBeforeInsertTeststrConfirmingwithFamilyFirst()
    {
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strConfirmingwithFamilyFirst);
        test.stopTest();
    }
     @istest public static void assignProspectSMSDateTimeBeforeInsertTeststrGiftforUpcomingOccasion()
    { 
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strGiftforUpcomingOccasion);
    	test.stopTest();
    }
     @istest public static void assignProspectSMSDateTimeBeforeInsertTeststrOtherEvent()
    { 
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        CCPM_testDataFactory.createCartProspectTest(1,CCPM_staticConstants.strOtherEvent);
    	test.stopTest();
    }
}