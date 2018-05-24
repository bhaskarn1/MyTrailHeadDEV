@isTest
public class CCPM_ProspectManualLeadUpdateBatchTest 
{
    @isTest
    public static void LeadTest()
    {
      CCPM_testdataFactory.createCustomSetting();
       
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';  
        objcart.CCPM_accountUniqueID__c='23467';
        // objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.CCPM_LeadType__c = 'Prospect SFDC Manual';
        insert objCart;
        CCPM_ProspectManualLeadUpdateBatch objbatch = new CCPM_ProspectManualLeadUpdateBatch();
            Database.executeBatch(objbatch);    
 // Creating the object for the scheduler class and invoking the execution
       String StrCRONEXP = ccpm_staticConstants.StrCRONEXP;
    CCPM_ProspectManualLeadUpdateBatchJob objSch = new CCPM_ProspectManualLeadUpdateBatchJob(); 
        system.schedule('CCPM_ProspectManualLeadUpdateBatchTest- 10 Mins', StrCRONEXP, objSch); 
    }

}