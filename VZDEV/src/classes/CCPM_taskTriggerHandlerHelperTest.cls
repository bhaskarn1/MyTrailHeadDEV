/**
*@name          CCPM_taskTriggerHandlerHelperTest 
*@author        Aneesha Ragireddy(Deloitte)
*@date          11/21/2017
@description    Test class for 
@testClass      CCPM_taskTriggerHandlerHelper 
Modification    Log:
------------------------------------------------------------------------------------
Developer                               Date                        Description
------------------------------------------------------------------------------------
Aneesha Ragireddy(Deloitte)             11/21/2017                 Original Version
*/
@isTest
public class CCPM_taskTriggerHandlerHelperTest {
    @isTest
    Public static void updateLeadReminderTest(){
      
        
         test.startTest();
          //Group objTeleSales= [Select id from Group where DeveloperName =: Label.CCPM_telesalesUsersGroupName];
          //List<CCPM_storeEmployee__c> lststrEmp = [Select id from CCPM_storeEmployee__c Where CCPM_storeSource__c =: Label.CCPM_telesalesChannelName];
      Profile p = [SELECT Id,Name FROM Profile WHERE Name='CCPM Sales Rep' Limit 1]; 
      User u = new User(Alias = 'tstusr1', Email='standardtestuser1412@testorgUAT.com',
                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',firstname='a', 
                   LocaleSidKey='en_US', ProfileId = p.Id, IsActive = True,
                   TimeZoneSidKey='America/Los_Angeles', UserName= 'makeUnique'+'stest@testorg.com',mobilephone='3214249106');             
      insert u;
        system.debug('User ID is*****'+u.id);
        List<CCPM_store__c> lstStore = CCPM_testDataFactory.createStore(1);
        CCPM_store__c objStore = lstStore[0];
        // test.stopTest();
        //test.startTest();
        objStore.CCPM_source__c = 'Telesales';
        update objStore;
        objStore = [Select id, CCPM_source__c From CCPM_store__c Where id = :objStore.id];
        System.debug('******objStore**********'+objStore);
        CCPM_storeEmployee__c objStoreEmp = new CCPM_storeEmployee__c();
        //gm.GroupId = objTeleSales.id;
         system.debug('*******u.id*********'+u.id);
        objStoreEmp.CCPM_employee__c = u.id;
        
        objStoreEmp.CCPM_uniqueStoreEmployeeID__c = '1234';
        objStoreEmp.CCPM_Store__c = objStore.id;
        insert objStoreEmp;
        system.debug('*******objStoreEmp.CCPM_employee__c*********'+objStoreEmp.CCPM_employee__c);
        system.debug('*****Store Source of employee*****'+objStoreEmp.CCPM_storeSource__c);
        system.debug('*****objStoreEmp******'+objStoreEmp);
        //lststrEmp.add(sm);
        //List<GroupMember> AllMembers = [select id, GroupId, UserOrGroupId from GroupMember where UserOrGroupId=:userID];
        //system.debug('*****AllMembers******'+AllMembers);
        //test.stopTest();
        //system.debug('******objTeleSales********'+objTeleSales);
           Lead objCart=new Lead();
            CCPM_testDataFactory.createCustomSetting();
        
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1'; 
        objCart.CCPM_eventType__c = 'Reminder';
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
        
        ccpm_utility.isCurrentUserTelesalesUser();
        /*objCart = [Select id, CCPM_createdChannel__c FROM Lead where id =: objCart.id];
            System.debug('******objCart******'+objCart);
        Task objTask = [select id,WhoId,Status from task where WhoId=:objCart.id];
        objTask.Status = 'Completed';
        update objTask;
        delete objTask;
        undelete objTask;
       objTask.Status = 'Cancelled';
         update objTask;*/
        Task objTask =new task();
        objTask.WhoId=objCart.id;
        objTask.Status='Completed';
        insert objTask;
        delete objTask;
        undelete objTask;
       objTask.Status = 'Cancelled';
         update objTask;
   
    }

}