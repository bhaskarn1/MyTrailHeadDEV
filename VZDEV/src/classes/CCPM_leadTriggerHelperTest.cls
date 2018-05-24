@isTest(seeAllData=false)
public class CCPM_leadTriggerHelperTest {
    
    static String strLeadProspectRT = 
        Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId();
    
    static String strLeadProspectCartRT = 
        Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadProspectCartRT).getRecordTypeId();
    
    static String strLeadCustomerCartRT = 
        Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId();

    static Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapGetBusinessHours();
    
    static Set<String> setQueueIDs = CCPM_utility.populateQueueIds();
    
    static String strJMRec = 
        Schema.SObjectType.CCPM_JourneyMessage__c.getRecordTypeInfosByName().get('Event Message').getRecordTypeId();

    static testMethod void testgetAccUniqIDAccountRecMap() {
        
        test.startTest();
        // Create Store
        list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
        for (ccpm_store__c objStore : lstStore) {
                objStore.Name = '15 Ave';
                objStore.ccpm_storeId__c = '0101019';
                objStore.CCPM_market__c = 'TSTMKT';
                objStore.CCPM_territory__c = 'TSTTERR';
                objStore.CCPM_district__c = 'TSTDIST';
         }
        insert lstStore;
        
        //Create Lead
        list<lead> lstLead = ccpm_testDataUtil.createLead(1,strLeadprospectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].recordTypeId = strLeadProspectRT;
        lstLead[0].status = Label.CCPM_leadStatusNew;
        lstlead[0].ccpm_eventtype__c = 'Add a Line';
        insert lstLead;
        list<Account> lstAccount = ccpm_testDataUtil.createAccount(1);
        lstAccount[0].ccpm_store__c = lstStore[0].id;
        lstAccount[0].ccpm_storeId__c = '0101019';
        insert lstAccount;
        map<String,Account> mapParam = new map<String,Account>();
        mapParam.put(lstAccount[0].CCPM_accountUniqueID__c, lstAccount[0]);
        map<String,Account> resMap = ccpm_leadTriggerHandlerHelper.getAccUniqIDAccountRecMap(mapParam);
        test.stopTest();
        system.assertEquals(lstAccount[0].id, resMap.get('010101').id);
    }
    
    static testMethod void testpopulateInitialSMS () {
        
        test.startTest();
        
        //Create User
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 1);

        insert lstUser;
        
        // Create Store
        list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
        for (ccpm_store__c objStore : lstStore) {
                objStore.Name = '15 Ave';
                objStore.ccpm_storeId__c = '0101019';
                objStore.CCPM_market__c = 'TSTMKT';
                objStore.CCPM_territory__c = 'TSTTERR';
                objStore.CCPM_district__c = 'TSTDIST';
         }
        insert lstStore;
        
        //Create Lead
        list<lead> lstLead = ccpm_testDataUtil.createLead(1,strLeadProspectCartRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].recordTypeId = strLeadProspectCartRT;
        lstLead[0].status = Label.CCPM_leadStatusNew;
        lstLead[0].OwnerId = lstUser[0].id;
        lstLead[0].ccpm_eventtype__c = 'Add a Line';
        insert lstLead;
        
        //Create Account
        list<Account> lstAccount = ccpm_testDataUtil.createAccount(1);
        lstAccount[0].ccpm_store__c = lstStore[0].id;
        lstAccount[0].ccpm_storeId__c = '0101019';
        
        insert lstAccount;
        map<String,Account> mapParam = new map<String,Account>();
        mapParam.put(lstAccount[0].CCPM_accountUniqueID__c, lstAccount[0]);
        CCPM_SMSMessage__c objMessage = ccpm_leadTriggerHandlerHelper.populateInitialSMS(lstLead[0],mapParam);
        
        test.stopTest();
        //system.assert(objMessage != null);
    }
    
    static testMethod void testpopulateInitialSMSProspect () {
        
        test.startTest();
        
        //Create User
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 1);

        insert lstUser;
        
        // Create Store
        list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
        for (ccpm_store__c objStore : lstStore) {
                objStore.Name = '15 Ave';
                objStore.ccpm_storeId__c = '0101019';
                objStore.CCPM_market__c = 'TSTMKT';
                objStore.CCPM_territory__c = 'TSTTERR';
                objStore.CCPM_district__c = 'TSTDIST';
         }
        insert lstStore;
        
        //Create Lead
        list<lead> lstLead = ccpm_testDataUtil.createLead(1,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].recordTypeId = strLeadProspectRT;
        lstLead[0].ccpm_eventType__c = 'Add a Line';
        lstLead[0].status = Label.CCPM_leadStatusNew;
        lstLead[0].OwnerId = lstUser[0].id;
        insert lstLead;
        
        //Create Account
        list<Account> lstAccount = ccpm_testDataUtil.createAccount(1);
        lstAccount[0].ccpm_store__c = lstStore[0].id;
        lstAccount[0].ccpm_storeId__c = '0101019';
        
        insert lstAccount;
        map<String,Account> mapParam = new map<String,Account>();
        mapParam.put(lstAccount[0].CCPM_accountUniqueID__c, lstAccount[0]);
        CCPM_SMSMessage__c objMessage = ccpm_leadTriggerHandlerHelper.populateInitialSMS(lstLead[0],mapParam);
        
        test.stopTest();
    }
    
    static testMethod void testprocessSMSMessageOnUpdate() {
        test.startTest();
         
        //Create User
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 2);
        lstUser[0].isActive = true;
        lstUser[1].isActive = true;
        insert lstUser;
        
        map<id,user> mapLeadOwners = new map<id,User>([SELECT id,MobilePhone,firstname,LastName 
                                                         FROM user 
                                                        WHERE mobilephone!=null 
                                                          AND isactive=true]);

        // Create Store
        list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
        for (ccpm_store__c objStore : lstStore) {
                objStore.Name = '15 Ave';
                objStore.ccpm_storeId__c = '0101019';
                objStore.CCPM_market__c = 'TSTMKT';
                objStore.CCPM_territory__c = 'TSTTERR';
                objStore.CCPM_district__c = 'TSTDIST';
         }
        insert lstStore;
        
        //Create Lead
        list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        
        
        set<String> grpString = ccpm_utility.populateQueueIds();
        list<String> lstStr = new list<String>();
        lstStr.addall(grpString);
        
        //lstLead[0].recordTypeId = strLeadProspectCartRT;
        lstLead[0].ccpm_eventType__c = 'Add a Line';
        lstLead[0].status = Label.CCPM_LeadEligibleStatus;
        lstLead[0].CCPM_isInitialSMSSent__c = false;
        lstLead[0].OwnerId = id.valueof(lstStr[0]);
        
        lstLead[1].recordTypeId = strLeadProspectCartRT;
        lstLead[1].ownerId = lstUser[0].id;
        lstLead[1].status = Label.CCPM_LeadEligibleStatus;
        lstLead[1].CCPM_isInitialSMSSent__c = true;
        lstLead[1].CCPM_isFollowUpSMSSent__c = false;
        //lstLead[1].sms_message_sent
        insert lstLead;
        
        Map<id,Lead> mapExistingRelatedRecs = new Map<id,Lead>();
        mapExistingRelatedRecs.put(lstLead[1].id, new lead());
        mapExistingRelatedRecs.put(lstLead[0].id,lstLead[0]);
        
        //Create Account
        list<Account> lstAccount = ccpm_testDataUtil.createAccount(1);
        lstAccount[0].ccpm_store__c = lstStore[0].id;
        lstAccount[0].ccpm_storeId__c = '0101019';
        
        insert lstAccount;
        
        map<String,Account> mapParam = new map<String,Account>();
        mapParam.put(lstAccount[0].CCPM_accountUniqueID__c, lstAccount[0]);

        list<ccpm_smsMessage__c> lstMsg = 
            ccpm_leadTriggerHandlerHelper.processSMSMessageOnUpdate(lstLead[1],lstLead[0],mapExistingRelatedRecs.get(lstLead[1].Id),mapParam,mapLeadOwners);
        
        test.stopTest();
        //system.assert(!lstMsg.isEmpty());
    }

    static testMethod void testpopulateActivityForTelesales() {
                
        Task objTask;
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 1);
        insert lstUser;
        system.runAs(lstUser[0]) {
            Test.startTest();
            list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
            lstStore[0].ccpm_source__c = Label.CCPM_telesalesChannelName;
            insert lstStore;
            
            list<ccpm_storeEmployee__c> lstStEmp = 
                ccpm_testDataUtil.createStoreEmployee(1, lstStore[0].id, lstUser[0].id, 'Store Manager');
            lstStEmp[0].CCPM_IsActive__c = true;
            insert lstStEmp;
            
            
            list<lead> lstLead = ccpm_testDataUtil.createLead(1,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
            lstLead[0].status = 'Excluded';
            lstLead[0].ccpm_eventType__c = 'Add a Line';
            lstLead[0].CCPM_SMSFollowUpDate__c = system.now().adddays(1);
            lstLead[0].recordTypeId = strLeadProspectRT;
            insert lstLead;
            
            objTask = ccpm_leadTriggerHandlerHelper.populateActivityForTelesales(lstLead[0]);
            Test.stopTest();
            
        }
        system.assert(objTask == null);
    }
    
    static testMethod void testassignAccountDetailsToLead () {
        test.startTest();
        
        list<lead> lstLead = ccpm_testDataUtil.createLead(1,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].CCPM_accountUniqueID__c = '10101';
        insert lstLead;
        
        list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
        lstAcc[0].CCPM_accountNumber__c = '10901';
        lstAcc[0].CCPM_accountUniqueID__c = '10101';
        insert lstAcc;
        
        map<String,Account> mapParam = new map<String,Account>();
        mapParam.put(lstAcc[0].CCPM_accountUniqueID__c, lstAcc[0]);
        
        ccpm_leadTriggerHandlerHelper.assignAccountDetailsToLead(lstLead[0],mapParam);
        test.stopTest();
        system.assertEquals(lstAcc[0].CCPM_accountNumber__c,lstLead[0].CCPM_accountNumber__c);
    }
    
    static testMethod void testassignOwnerForManualLead () {
        
        test.startTest();
        
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 1);
        insert lstUser;
        
        list<lead> lstLead = ccpm_testDataUtil.createLead(1,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].CCPM_accountUniqueID__c = '10101';
        insert lstLead;
        
        list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
        lstAcc[0].CCPM_accountNumber__c = '10901';
        lstAcc[0].CCPM_accountUniqueID__c = '10101';
        insert lstAcc;
        
        map<String,Account> mapParam = new map<String,Account>();
        mapParam.put(lstAcc[0].CCPM_accountUniqueID__c, lstAcc[0]);
        
        list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
        insert lststore;
        
        list<ccpm_storeEmployee__c> lstStEmp = 
            ccpm_testDataUtil.createStoreEmployee(1, lstStore[0].id, lstUser[0].id, 'Store Manager');
        insert lstStEmp;
        
        list<ccpm_store__c> lstStr = [SELECT id,Name,CCPM_storeID__c,CCPM_district__c,CCPM_market__c,ccpm_territory__c,
                                             ccpm_isActive__c, CCPM_TimeZone__c,
                                        (select id,ccpm_Role__c,CCPM_Store__c,CCPM_employee__c,CCPM_IsActive__c,
                                                CCPM_uniqueStoreEmployeeID__c
                                           from store_employees__r) 
                                        FROM ccpm_store__c
                                       WHERE id =: lstStore[0].id];
        
        map<id,ccpm_store__c> mapStore = new map<id,ccpm_store__c>();
        map<String,ccpm_store__c> mapStoreId = new map<String,ccpm_store__c>();
        mapStore.put(lstStr[0].id, lstStr[0]);
        mapStore.put(lstStr[0].id, lstStr[0]);
        mapStoreId.put(lstStr[0].CCPM_storeID__c, lstStr[0]);      

        ccpm_leadTriggerHandlerHelper.assignOwner(lstLead[0],null,mapStore,mapStoreId,lstStEmp[0], null, mapParam);
        test.stopTest();
        system.assertEquals(lstLead[0].CCPM_storeManager__c,lstStEmp[0].ccpm_employee__c);
    }
    
    static testMethod void testAssignConvOrQualifiedTime () {
        
        test.startTest();
        list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].ccpm_eventType__c = 'Add a Line';
        lstLead[0].status = Label.CCPM_leadStatusConverted;
        
        lstLead[1].recordTypeId = strLeadProspectCartRT;
        lstLead[1].status = Label.CCPM_leadStatusResponded;
        insert lstLead;
        
        ccpm_leadTriggerHandlerHelper.assignConvOrQualifiedTime(lstLead[0],lstLead[1]);
        test.stopTest();
        system.assert(lstLead[0].CCPM_convertedDateTime__c != null);
        
    } 
    
    static testMethod void testQualiAssignConvOrQualifiedTime () {
        
        test.startTest();
        list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].ccpm_eventType__c = 'Add a Line';
        lstLead[0].status = Label.CCPM_leadStatusQualified;
        
        lstLead[1].recordTypeId = strLeadProspectCartRT;
        lstLead[1].status = Label.CCPM_leadStatusResponded;
        insert lstLead;
        
        ccpm_leadTriggerHandlerHelper.assignConvOrQualifiedTime(lstLead[0],lstLead[1]);
        test.stopTest();
        system.assert(lstLead[0].CCPM_qualifiedDateTime__c != null);
    } 
    
    static testMethod void testPopulateActivityForTelesalesOnUpdate () {
        
        test.startTest();
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 2);
        insert lstUser;
        
        list<group> lstGroup = [Select id, name from Group where Type = 'Queue'];
        list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].ccpm_eventType__c = 'Add a Line';
        lstLead[0].status = Label.CCPM_LeadEligibleStatus;
        lstLead[0].ownerId = lstUser[1].id;
        
        lstLead[1].recordTypeId = strLeadProspectCartRT;
        lstLead[1].status = Label.CCPM_LeadEligibleStatus;
        lstLead[1].ownerId = lstGroup[0].id;
        insert lstLead;
        
        task objTask = ccpm_leadTriggerHandlerHelper.PopulateActivityForTelesalesOnUpdate(lstLead[0],lstLead[1]);
        test.stopTest();
        system.assert(objTask == null);
    }
    
    static testMethod void testpopulatepreviousStatus() {
        
        test.startTest();
        
        list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].status = Label.CCPM_LeadEligibleStatus;
        
        
        lstLead[1].recordTypeId = strLeadProspectCartRT;
        lstLead[1].status = Label.CCPM_leadStatusResponded;
        lstLead[1].CCPM_leadSubStatus__c = 'Action Required';
        insert lstLead;
        
        ccpm_leadTriggerHandlerHelper.populatepreviousStatus(lstLead[1],lstLead[0]);
        test.stopTest();
        system.assert(lstLead[1].CCPM_previousLeadStatus__c != null);
    }
    
    static testMethod void testManageInformaticaMerge () {
        
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 2);
        lstUser[0].isActive = true;
        insert lstUser;
        system.runAs(lstUser[0]){
        test.startTest();
        
        list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
        lstStore[0].CCPM_storeID__c = '0101019';
        insert lstStore;
       
        list<ccpm_store__c> lstSt = [SELECT id,ccpm_storeId__c from ccpm_store__c where id=: lstStore[0].id];
        
        list<ccpm_storeEmployee__c> lstEmp = ccpm_testDataUtil.createStoreEmployee(1, lstSt[0].id, lstUser[0].id, 'Store Manager');
        insert lstEmp;
        
        list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
        lstAcc[0].ccpm_store__c = lstSt[0].id;
        lstAcc[0].ccpm_storeId__c = '0101019';
        insert lstAcc;
        
        list<ccpm_storeEmployee__c> lstStEmp = [select id,ccpm_employee__c from ccpm_storeEmployee__c where id=: lstEmp[0].id];
        

        list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
        lstLead[0].CCPM_isInformaticaMerge__c = false;
            lstLead[0].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
        lstLead[1].status = 'Contacted';
            lstLead[0].ccpm_eventType__c = 'Add a Line';
        lstLead [1].ownerId = lstUser[0].id;
        lstLead[1].Store__c = lstSt[0].id;
            lstLead[1].ccpm_eventType__c = 'Add a Line';
        lstLead[1].CCPM_isInformaticaMerge__c = true;
        lstLead[1].recordTypeId = strLeadProspectCartRT;
        lstLead[1].leadSource = Label.CCPM_leadSourceNetace;
        lstLead[1].CCPM_isManualLead__c = true;
        lstLead[1].CCPM_Account__c = lstAcc[0].id;
            lstLead[1].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
        insert lstLead; 
        list<lead> newLead = [select id,status,ownerId,CCPM_isInformaticaMerge__c,ccpm_type__c,ccpm_eventType__c,
                                    leadSource,CCPM_mobileNumber__c,store__c,ccpm_isManualLead__c,recordTypeId,
                                    CCPM_informaticaMergeLeadType__c,CCPM_smsOptOutAccount__c
                               from lead where id =: lstLead[1].id];
                               

        ccpm_leadTriggerHandlerHelper.manageInformaticaMerge(newLead[0], lstLead[0]);
           
        test.stopTest();
            system.assertEquals(newLead[0].status,'Eligible');
             }
        
    }
    
    static testMethod void testUpdateMessageBodyonLeadOwnerChange() {
        
        insert new CCPM_globalSetting__c(CCPM_cartClosedStatus__c = 'Expired:Converted:Dismissed',CCPM_leadOpenStatus__c = 'New:Eligible:Contacted:Responded:Qualified');

        
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 1);
        lstUser[0].isActive = true;
        insert lstUser;
        
        system.runAs(lstUser[0]){
            
            list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
            lstStore[0].CCPM_storeID__c = '0101019';
            insert lstStore;
            
            list<ccpm_store__c> lstSt = [SELECT id,ccpm_storeId__c from ccpm_store__c where id=: lstStore[0].id];
            
            list<ccpm_storeEmployee__c> lstEmp = 
                ccpm_testDataUtil.createStoreEmployee(1, lstSt[0].id, lstUser[0].id, 'Store Manager');
            insert lstEmp;
            
            list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
            lstAcc[0].ccpm_store__c = lstSt[0].id;
            lstAcc[0].ccpm_storeId__c = '0101019';
            lstAcc[0].CCPM_SMSOptOut__c = true;
            insert lstAcc;
            
            list<ccpm_storeEmployee__c> lstStEmp = 
                [select id,ccpm_employee__c from ccpm_storeEmployee__c where id=: lstEmp[0].id];
            
            list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
            lstLead[0].recordTypeId = strLeadProspectRT;
            lstLead[0].ccpm_eventType__c = 'Add a Line';
            lstLead[0].ownerId = lstUser[0].id;
            lstLead[0].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[0].CCPM_createdChannel__c = 'Digital';
            lstLead[0].store__c = lstStore[0].id;
            lstLead[0].ccpm_account__c = lstAcc[0].id;
            lstLead[1].ccpm_eventType__c = 'Add a Line';
            lstLead[1].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            insert lstLead;
            
            list<CCPM_smsMessage__c> lstMsg = ccpm_testDataUtil.createSMSMessage(1, lstLead[0].id);
            lstMsg[0].CCPM_messageType__c = Label.CCPM_SmsMessageTypeActionRequired;
            insert lstMsg;
            
            map<id,user> mapParam = new map<id,user>();
            mapParam.put(lstUser[0].id, lstUser[0]);
            test.startTest();
            ccpm_smsMessage__c objMsg = 
                ccpm_leadTriggerHandlerHelper.UpdateMessageBodyonLeadOwnerChange(lstLead[0],lstLead[1],lstMsg[0],mapParam);
            system.assert(objMsg != null);
            lstLead[0].recordTypeId = strLeadCustomerCartRT;
            update lstLead[0];
            
            ccpm_smsMessage__c objMsg1 = 
                ccpm_leadTriggerHandlerHelper.UpdateMessageBodyonLeadOwnerChange(lstLead[0],lstLead[1],lstMsg[0],mapParam);
            system.assert(objMsg1!=null);
            lstMsg[0].CCPM_messageType__c = Label.CCPM_MessageTypeInitialSMSPart1;
            update lstMsg[0];
            ccpm_smsMessage__c objMsg2 = 
                ccpm_leadTriggerHandlerHelper.UpdateMessageBodyonLeadOwnerChange(lstLead[0],lstlead[1],lstMsg[0],mapParam);
            system.assert(objMsg2!=null);
            
            lstMsg[0].CCPM_messageType__c =Label.CCPM_telesalesTaskSubject;
            update lstMsg[0];
            ccpm_smsMessage__c objMsg3 = 
                ccpm_leadTriggerHandlerHelper.UpdateMessageBodyonLeadOwnerChange(lstLead[0],lstLead[1],lstMsg[0],mapParam);
            system.assert(objMsg3!=null);
            
            lstMsg[0].CCPM_messageType__c = Label.CCPM_MessageTypeProspectFirstSMSPart1;
            update lstMsg[0];
            ccpm_smsMessage__c objMsg4 = 
                ccpm_leadTriggerHandlerHelper.UpdateMessageBodyonLeadOwnerChange(lstLead[0],lstLead[1],lstMsg[0],mapParam);
            system.assert(objMsg4!=null);
            
            lstLead[0].recordTypeId = strLeadProspectCartRt;
            update lstLead[0];
            ccpm_smsMessage__c objMsg5 = 
                ccpm_leadTriggerHandlerHelper.UpdateMessageBodyonLeadOwnerChange(lstLead[0],lstLead[1],lstMsg[0],mapParam);
            system.assert(objMsg5!=null);
            test.stopTest();
               
        }
    }
    
    static testMethod void testPopulateFollowUpSMS () {
                list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 2);
        lstUser[0].isActive = true;
        insert lstUser;
        system.runAs(lstUser[0]){
            test.startTest();
            
            list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
            lstStore[0].CCPM_storeID__c = '0101019';
            insert lstStore;
            
            list<ccpm_store__c> lstSt = [SELECT id,ccpm_storeId__c from ccpm_store__c where id=: lstStore[0].id];
            
            list<ccpm_storeEmployee__c> lstEmp = 
                ccpm_testDataUtil.createStoreEmployee(1, lstSt[0].id, lstUser[0].id, 'Store Manager');
            insert lstEmp;
            
            list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
            lstAcc[0].ccpm_store__c = lstSt[0].id;
            lstAcc[0].ccpm_storeId__c = '0101019';
            insert lstAcc;
            
            list<ccpm_storeEmployee__c> lstStEmp = 
                [select id,ccpm_employee__c from ccpm_storeEmployee__c where id=: lstEmp[0].id];
            
            list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
            lstLead[0].status = 'Contacted';
            lstLead[0].ownerId = lstUser[0].id;
            lstLead[0].Store__c = lstSt[0].id;
            lstLead[0].ccpm_eventType__c = 'Add a Line';
            lstLead[0].CCPM_isInformaticaMerge__c = true;
            lstLead[0].recordTypeId = strLeadCustomerCartRT;
            lstLead[0].leadSource = Label.CCPM_leadSourceNetace;
            lstLead[0].CCPM_isManualLead__c = true;
            lstLead[0].CCPM_Account__c = lstAcc[0].id;
            lstLead[0].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[1].status = 'Contacted';
            lstLead[1].ownerId = lstUser[0].id;
            lstLead[1].Store__c = lstSt[0].id;
            lstLead[1].ccpm_eventType__c = 'Add a Line';
            lstLead[1].recordTypeId = strLeadCustomerCartRT;
            lstLead[1].leadSource = 'CRM';
            lstLead[1].CCPM_isManualLead__c = true;
            lstLead[1].CCPM_Account__c = lstAcc[0].id;
            lstLead[1].CCPM_accountUniqueID__c = '010101';
            lstLead[1].ccpm_isManualLead__c = false;
            lstLead[1].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            insert lstLead;
            
            map<String,account> mapParam = new map<String,Account>();
            mapParam.put(lstAcc[0].CCPM_accountUniqueID__c, lstAcc[0]);
            ccpm_smsmessage__c objMsg = 
                ccpm_leadTriggerHandlerHelper.populateFollowUpSMS(lstLead[0],mapParam);
            system.assert(objMsg!=null);

            ccpm_smsmessage__c objMsg1 = 
                ccpm_leadTriggerHandlerHelper.populateFollowUpSMS(lstLead[1],mapParam);
            system.assert(objMsg1!=null);
            test.stopTest();
        }
    }
    
    static testMethod void testPopCreatedLeadFields () {
                
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 2);
        lstUser[0].isActive = true;
        insert lstUser;
        system.runAs(lstUser[0]){
            test.startTest();
            
            list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
            lstStore[0].CCPM_storeID__c = '0101019';
            insert lstStore;
            
            list<ccpm_store__c> lstSt = [SELECT id,ccpm_storeId__c from ccpm_store__c where id=: lstStore[0].id];
            
            list<ccpm_storeEmployee__c> lstEmp = 
                ccpm_testDataUtil.createStoreEmployee(1, lstSt[0].id, lstUser[0].id, 'Store Manager');
            insert lstEmp;
            
            list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
            lstAcc[0].ccpm_store__c = lstSt[0].id;
            lstAcc[0].ccpm_storeId__c = '0101019';
            insert lstAcc;
            
            list<ccpm_storeEmployee__c> lstStEmp = 
                [select id,ccpm_employee__c from ccpm_storeEmployee__c where id=: lstEmp[0].id];
            
            list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
            lstLead[0].status = 'Eligible';
            lstLead[0].ownerId = lstUser[0].id;
            lstLead[0].Store__c = lstSt[0].id;
            lstLead[0].ccpm_eventType__c = 'Add a Line';
            lstLead[0].recordTypeId = strLeadCustomerCartRT;
            lstLead[0].leadSource = 'ATG-ECOM-TDOT';
            lstLead[0].CCPM_Account__c = lstAcc[0].id;
            lstLead[0].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[0].CCPM_closedLeadSource__c = 'ACSS';
            lstLead[0].CCPM_Created_Lead_Source__c = '';
            lstLead[1].status = 'Eligible';
            lstLead[1].ownerId = lstUser[0].id;
            lstLead[1].Store__c = lstSt[0].id;
            lstLead[1].ccpm_eventType__c = 'Add a Line';
            lstLead[1].recordTypeId = strLeadCustomerCartRT;
            lstLead[1].leadSource = 'NETACE';
            lstLead[1].CCPM_Account__c = lstAcc[0].id;
            lstLead[1].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[1].CCPM_closedLeadSource__c = 'ACSS';
            lstLead[1].CCPM_Created_Lead_Source__c = '';
            insert lstLead; 
            list<lead> objLead = [SELECT status,ownerId,store__c,ccpm_eventType__c,recordTypeId,leadSource,ccpm_isManualLead__c,
                                         CCPM_Account__c,CCPM_SMSFollowUpDate__c,CCPM_closedLeadSource__c,
                                        CCPM_Created_Lead_Source__c,CCPM_leadChannel__c,ccpm_type__c,CCPM_createdChannel__c
                                   FROM lead where id=:lstLead[0].id];
            
            lead resLead = ccpm_leadTriggerHandlerHelper.populateCreatedLeadFields(objLead[0]);
            system.assertEquals('Digital',resLead.CCPM_createdChannel__c);
            
            list<lead> objLead1 = [SELECT status,ownerId,store__c,ccpm_eventType__c,recordTypeId,leadSource,ccpm_isManualLead__c,
                                         CCPM_Account__c,CCPM_SMSFollowUpDate__c,CCPM_closedLeadSource__c,
                                        CCPM_Created_Lead_Source__c,CCPM_leadChannel__c,ccpm_type__c,CCPM_createdChannel__c
                                   FROM lead where id=:lstLead[1].id];

            lead resLead1 = ccpm_leadTriggerHandlerHelper.populateCreatedLeadFields(objLead1[0]);
            system.assertEquals(resLead1.CCPM_createdChannel__c,Label.CCPM_retailChannelName);
            test.stopTest();
        }
    }
    
    static testMethod void testESMSFWKCalculateSMSFOllowupDate(){
        ccpm_journeymessage__c objMsg = new ccpm_journeymessage__c();
        objMsg.ccpm_isActive__c = true;
        objMsg.CCPM_CustomerMessage__c = 'tygvedh l';
        objMsg.CCPM_eventSMSFollowUpStartDate__c = '2017-02-01 00:00:00';
        objMsg.CCPM_eventSMSFollowUpEndDate__c = '2023-01-01 00:00:00';
        objMsg.CCPM_eventStartDate__c = '2017-01-01 00:00:00';
        objMsg.ccpm_eventType__c = 'Add a Line';
        objMsg.CCPM_journeyMessageName__c = 'Add a Line';
        objMsg.ccpm_prospectMessage__c = 'teshjbbjhd';
        
        objMsg.CCPM_calculateSMSFollowUp__c = true;
        objMsg.recordTypeId = strJMRec;
        objMsg.CCPM_overrideEcode__c = true;
        insert objMsg;
 //       CCPM_utility.mapTypeEventNameLstJMRec = CCPM_utility.getEventlstJourneyMessageMap();
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 2);
        lstUser[0].isActive = true;
        insert lstUser;
        
         
        list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
        lstStore[0].CCPM_storeID__c = '0101019';
        insert lstStore;
        
        list<ccpm_storeEmployee__c> lstEmp = 
            ccpm_testDataUtil.createStoreEmployee(1, lstStore[0].id, lstUser[0].id, 'Store Manager');
        insert lstEmp;
            
        system.runAs(lstUser[0]){
            
            list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
            lstAcc[0].ccpm_store__c = lstStore[0].id;
            lstAcc[0].ccpm_storeId__c = '0101019';
            insert lstAcc;
            
            test.startTest();
            list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
            lstLead[0].status = 'Eligible';
            lstLead[0].ccpm_eventType__c = 'Add a Line';
            lstLead[0].recordTypeId = strLeadCustomerCartRT;
            lstLead[0].CCPM_isManualLead__c = true;
            lstLead[0].CCPM_Account__c = lstAcc[0].id;
            lstLead[0].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[1].status = 'Eligible';
            lstLead[1].ccpm_eventType__c = 'Add a Line';
            lstLead[1].recordTypeId = strLeadCustomerCartRT;
            lstLead[1].CCPM_Account__c = lstAcc[0].id;
            lstLead[1].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[1].CCPM_closedLeadSource__c = 'ACSS';
            lstLead[1].ccpm_isManualLead__c = true;
            insert lstLead;
              test.stopTest();
        }
    }
    
    static testMethod void testpopulateInitialMessageForMergeCarts () {
        list<user> lstUser = ccpm_testDataUtil.createTestUsers('CCPM Sales Rep', 2);
        lstUser[0].isActive = true;
        insert lstUser;
        system.runAs(lstUser[0]){
            test.startTest();
            
            list<ccpm_store__c> lstStore = ccpm_testDataUtil.createStore(1);
            lstStore[0].CCPM_storeID__c = '0101019';
            insert lstStore;
            
            list<ccpm_store__c> lstSt = [SELECT id,ccpm_storeId__c from ccpm_store__c where id=: lstStore[0].id];
            
            list<ccpm_storeEmployee__c> lstEmp = 
                ccpm_testDataUtil.createStoreEmployee(1, lstSt[0].id, lstUser[0].id, 'Store Manager');
            insert lstEmp;
            
            list<Account> lstAcc = ccpm_testDataUtil.createAccount(1);
            lstAcc[0].ccpm_store__c = lstSt[0].id;
            lstAcc[0].ccpm_storeId__c = '0101019';
            insert lstAcc;
            
            list<ccpm_storeEmployee__c> lstStEmp = 
                [select id,ccpm_employee__c from ccpm_storeEmployee__c where id=: lstEmp[0].id];
            
            list<lead> lstLead = ccpm_testDataUtil.createLead(2,strLeadProspectRT,false,'Prospect Abandoned Cart Digital');
            lstLead[0].status = 'Eligible';
            lstLead[0].ownerId = lstUser[0].id;
            lstLead[0].Store__c = lstSt[0].id;
            lstLead[0].ccpm_eventType__c = 'Add a Line';
            lstLead[0].recordTypeId = strLeadProspectCartRT;
            lstLead[0].leadSource = 'ATG-ECOM-TDOT';
            lstLead[0].CCPM_Account__c = lstAcc[0].id;
            lstLead[0].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[0].CCPM_closedLeadSource__c = 'ACSS';    
            lstLead[1].status = 'Eligible';
            lstLead[1].ownerId = lstUser[0].id;
            lstLead[1].Store__c = lstSt[0].id;
            lstLead[1].ccpm_eventType__c = 'Add a Line';
            lstLead[1].recordTypeId = strLeadCustomerCartRT;
            lstLead[1].leadSource = 'ATG-ECOM-TDOT';
            lstLead[1].CCPM_Account__c = lstAcc[0].id;
            lstLead[1].CCPM_SMSFollowUpDate__c = system.now().adddays(4);
            lstLead[1].CCPM_closedLeadSource__c = 'ACSS'; 
            insert lstLead;
            
            ccpm_smsMessage__c objMsg = 
                    ccpm_leadTriggerHandlerHelper.populateInitialMessageForMergeCarts(lstLead[0],setQueueIDs);
            system.assert(objMsg != null);
            
            ccpm_smsMessage__c objMsg1 = 
                    ccpm_leadTriggerHandlerHelper.populateInitialMessageForMergeCarts(lstLead[1],setQueueIDs);
            system.assert(objMsg1 != null);
            test.stopTest();
        }
    }
    
}