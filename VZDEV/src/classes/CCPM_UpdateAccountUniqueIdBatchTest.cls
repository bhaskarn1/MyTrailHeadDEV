/**
*@name          CCPM_UpdateAccountUniqueIdBatchTest 
*@author        Manjunath Keshava (Deloitte)
*@date          06/21/2017
@description   @(US_0392) This is  a  method to Test CCPM_UpdateAccountUniqueIdBatch  
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    11/03/2017               			 Original Version
*/
@isTest
public class CCPM_UpdateAccountUniqueIdBatchTest 
{
     @isTest
    public static void LeadUpdateTest()
    {
      CCPM_testdataFactory.createCustomSetting();
        Account objCustomer=new Account();
        objCustomer.Name='testuatCustomer';
        objCustomer.CCPM_accountNumber__c='3728-1';
        objCustomer.CCPM_accountUniqueID__c='';
        objCustomer.CCPM_isVisionAccount__c=true;
        objCustomer.Phone='1243658790';
        objCustomer.CCPM_email__c='test@salesforce.com';
        objCustomer.BillingStreet='testStreet';
        objCustomer.BillingCity='testStreet';
        objCustomer.BillingState='California';
        objCustomer.BillingPostalCode='32745';
        ObjCustomer.CCPM_SMSOptOut__c=false;
        ObjCustomer.CCPM_mobileNumber__c='3214249106';
       insert objCustomer;
        
        CCPM_updateAccountUniqueIDBatch objbatch = new CCPM_updateAccountUniqueIDBatch();
			Database.executeBatch(objbatch);	
 // Creating the object for the scheduler class and invoking the execution
       String StrCRONEXP = ccpm_staticConstants.StrCRONEXP;
    CCPM_updateAccountUniqueIDJob objSch = new CCPM_updateAccountUniqueIDJob(); 
        system.schedule('CCPM_UpdateAccountUniqueIdBatchTest- 10 Mins', StrCRONEXP, objSch); 
    }


}