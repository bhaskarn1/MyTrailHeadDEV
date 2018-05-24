/**
*@name          CCPM_SMSInteractionHistoryControllerTest
*@author        Paras Shah (Deloitte)
*@date          02/06/2016
@description    To Test the class CCPM_SMSInteractionHistoryController


@testClass:     CCPM_SMSInteractionHistoryControllerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)    02/06/2016                          Original Version
*/

@istest(SeeAllData=False)
public class CCPM_SMSInteractionHistoryControllerTest {    
    /**
*@author        Paras Shah (Deloitte)
*@description   This method is targeted to test the CCPM_SMSInteractionHistoryController class
*@param :       None
*/
    @istest(SeeAllData=False) public static void testLeadCreation()
    {   
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        User integrationUser=CCPM_testDataFactory.CreateUser('CCPM Integration User','integrationUser');
        //User objStoreEmployeeWithoutStore = CCPM_testDataFactory.CreateUser('CCPM Sales Rep');
        System.runAs(integrationUser){ 
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
            list<Account> lstCustomer=CCPM_testDataFactory.createCustomer(CCPM_staticConstants.NoOfRecords,'A1');
            try{
                system.debug('disp#1lstcustomer'+lstCustomer);
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
        system.debug('disp#2'+lstCustomerWithoutNearestStore);
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
                }
                for(integer i=(CCPM_staticConstants.NoOfRecords /2);i<CCPM_staticConstants.NoOfRecords;i++){
                    string strCartLastName = 'Cart'+i;
                    string strCartUniqueId = 'cartUniqueId'+strCartLastName;
                    cartLastName.add(strCartLastName);
                    cartUniqueId.add(strCartUniqueId);
                    cartLastHandledBy.add(''+i);
                }
                system.debug('disp#3'+cartLastName);
                system.debug('disp#4'+cartUniqueId);
                
                //insert new CCPM_globalSetting__c(CCPM_initialSMSInterval__c = '180',CCPM_followUpSMSInterval__c = '3600'); 
                
                List<lead> lstCarts = CCPM_testDataFactory.createCart(CCPM_staticConstants.NoOfRecords,accountUniqueID,cartLastName,cartUniqueId, storeID, cartLastHandledBy);
                
                list<Lead> lstLeadCart =[select id,store__c,CCPM_SMSOptOut__c from lead];
                upsert lstLeadCart;
                
                system.debug('disp#5'+lstCarts);
                
                CCPM_testDataFactory.createTask(lstLeadCart[0].id,'Inbound');
                CCPM_testDataFactory.createTask(lstLeadCart[0].id,'Outbound');
                
                //Method calls with valid Id
                String strLeadPhone = CCPM_SMSInteractionHistoryController.getLeadPhone(lstLeadCart[0].id);
                CCPM_SMSInteractionHistoryController.getSMSMessageList(lstLeadCart[0].id);
                
                List<lead> lstQueryleadPhone = [select CCPM_mobileNumber__c from Lead where id = :lstLeadCart[0].id limit 1];
                system.assertEquals(strLeadPhone,lstQueryleadPhone[0].CCPM_mobileNumber__c);
                
                //Method calls with null id
                String strLeadPhoneNull = CCPM_SMSInteractionHistoryController.getLeadPhone(null);
                CCPM_SMSInteractionHistoryController.getSMSMessageList(null); 
                
                system.assertEquals(strLeadPhoneNull,null );
            }
            Catch(DMLException e)
            {
                System.debug('Exception occured while updating lead Cart/Class:CCPM_leadTest ' + e.getMessage());
            }
            
            
        }
        test.stopTest();
    }
}