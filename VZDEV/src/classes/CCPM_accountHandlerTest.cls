/**
*@name          CCPM_accountHandler
*@author        Sriraman Sridharan (Deloitte)
*@date          07/12/2016
@description    To Test the Handler class CCPM_accountHandler


@testClass:     CCPM_accountHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sriraman(Deloitte)      01/31/2016                          Original Version
*/

@istest(SeeAllData=False)
public class CCPM_accountHandlerTest {    
    /**
*@author        Sriraman Sridharan (Deloitte)
*@description   This method is targeted to test the CCPM_accountHandler class
*@param :       None
*/
    @istest(SeeAllData=False) public static void testAccountCreation()
    {   
        test.startTest();
        User integrationUser=CCPM_testDataFactory.CreateUser('CCPM Integration User', 'integrationUser');
        System.runAs(integrationUser){
            try{
                CCPM_testDataFactory.createCustomSetting();
                //Create and query all the stores
                list<CCPM_Store__c> lstObjStore = CCPM_testDataFactory.createStore(CCPM_staticConstants.NoOfRecords);
                if(CCPM_staticConstants.NoOfRecords!=null)
                {
                list<CCPM_Store__c> stores=[Select id,CCPM_storeID__c from CCPM_store__c limit :CCPM_staticConstants.NoOfRecords];
                //Create Customers
                list<Account> lstCustomer = CCPM_testDataFactory.createCustomer(CCPM_staticConstants.NoOfRecords,'A');
                list<Account> lstCustomerWithStoreId = CCPM_testDataFactory.createCustomer(CCPM_staticConstants.NoOfRecords,'B');
                if(lstCustomer!=null && lstCustomer.size()>0 && lstCustomer.isEmpty()==false)
                {
                for(integer i=0;i<(lstCustomer.size()/2);i++)
                {
                    if(stores.size()>0 && stores!=null){
                        lstCustomer[i].CCPM_Store__c=stores[i].id;
                        lstCustomer[i].CCPM_storeID__c=stores[i].CCPM_storeID__c;
                         lstCustomer[i].CCPM_SMSOptOut__c=true;

                    }
                }
                
                Update lstCustomer;
                
                for(integer i=0;i<lstCustomer.size()/2;i++){
                    System.assert(lstCustomer[i].CCPM_store__c == stores[i].id);
                }
                for(integer i=0;i<lstCustomer.size();i++)
                {
                    lstCustomer[i].CCPM_storeID__c=null;
                }
                Update lstCustomer;
                }
                }
            }
            Catch(DMLException e)
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_leadTest','testLeadCreation','Exception thrown while querying for store records',true);
            }
        }
        test.stopTest();
    }
}