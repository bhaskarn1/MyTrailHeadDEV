/**
*@name          CCPM_LeadsAwaitingResponseApexTest
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          12/15/2017
*@description   Test Class
Modification    Log:
------------------------------------------------------------------------------------
Developer                                     Date               Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)             12/15/2017         Original Version       
*/
@isTest
public class CCPM_leadsAwaitingChildApexTest {
    
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
    
    @isTest 
    public static void loadComponentWithRecordsTest(){
        test.startTest();
        list<CCPM_Store__c> lstStore=new list<CCPM_Store__c>();
        lstStore=createStore(1);
        CCPM_testDataFactory.createCustomSetting();
        List<Lead> lstLead = new List<Lead>();
        List<Lead> lstLead1 = new List<Lead>();
        Test.setMock(HttpCalloutMock.class, new CCPM_MockHttpResponseGenerator());
        lstLead1 = CCPM_testDataFactory.createmyActiveLeadsTest(5, 'Confirming with Family First','Customer Abandoned Cart Digital');
        insert lstLead1;
        CCPM_leadsAwaitingChildApexController.makeCalloutHeywire('CCPM_PromoiPhoneX', lstLead1[0]);
        CCPM_testDataFactory.createCustomSetting();
        CreateData('3213187287','Customer Abandoned Cart Digital',null,true,null);
        lstLead=[Select Id,CCPM_ownerEcode__c,CCPM_storeEcode__c,CCPM_mobileNumber__c,RecordTypeId,ownerid,Store__c,CCPM_followupMessageBody__c,CCPM_initialMessageBodyPartII__c,CCPM_initialMessageBodyPartI__c from lead limit 1];
        
        CCPM_leadsAwaitingChildApexController.makeCalloutHeywire('CCPM_PromoiPhoneX', lstLead[0]);
        //CCPM_leadsAwaitingChildApexController.makeCalloutHeywire('CCPM_PromoiPhoneX', lstLead1[0]);
        lstLead[0].CCPM_Leadtype__c = 'Prospect SFDC Manual'; 
        update lstLead;
        CCPM_leadsAwaitingChildApexController.makeCalloutHeywire('CCPM_PromoiPhoneX', lstLead[0]);
        //CCPM_leadsAwaitingChildApexController.makeCalloutHeywire('CCPM_PromoiPhoneX', lstLead1[0]);
        test.stopTest();
    }
    
    
    
    @isTest 
    public static void createInteractionTouchPointTest(){
        test.startTest();
        CCPM_testDataFactory.createCustomSetting();
        List<Lead> lstLead = new List<Lead>();
        lstLead = CCPM_testDataFactory.createmyActiveLeadsTest(5, 'Confirming with Family First','Customer Abandoned Cart Digital');
        insert lstLead;
        CCPM_leadsAwaitingChildApexController.createInteractionTouchPoint('CCPM_PromoiPhoneX','Predefined' ,lstLead[0]);
        CCPM_leadsAwaitingChildApexController.updateLead(lstLead[0],'CCPM_PromoiPhoneX');
        CCPM_leadsAwaitingChildApexController.updateLead(lstLead[0],'CCPM_PromoiPhoneX');
        test.stopTest();
    }
    
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
            objStore.CCPM_storeEcode__c='123';
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
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    Public static void CreateData(string strmobilenumber,string strLeadtype,string strrole,boolean boolAccountUniqueIDFlag,string EventType)
    {
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
            createCart(1, lstAccountUniqueID, lstLastName, lstcartUniqueId, lststoreID, lstcartLastHandledBy,strmobilenumber,strLeadtype,true,null);
        }
        else{
            list<CCPM_StoreEmployee__c> lstStoreEmployee = [select id,CCPM_employee__c from CCPM_storeEmployee__c where CCPM_role__c=:strrole];
            System.debug('@Test_lstStoreEmployee->'+lstStoreEmployee);
            list<User> lstUser = [select id,firstname,lastname from user where id = :lstStoreEmployee[0].CCPM_employee__c limit 1];
            System.debug('@Test_lstUser->'+lstUser);
            System.runas(lstUser[0])
            {
                createCart(1, lstAccountUniqueID, lstLastName, lstcartUniqueId, lststoreID, lstcartLastHandledBy,strmobilenumber,strLeadtype,boolAccountUniqueIDFlag,EventType);
            }
        }
        
        //test.stopTest();
    }
    
    /**
@author        Brigadesh Chandrasekar(Deloitte)
@description   This method is targeted to create Data required for the test class.
*/     
    public static List<lead> createCart(Integer NoOfRecords, List<String> accountUniqueID, List<String> LastName, List<String> cartUniqueId, List<String> storeID, List<String> cartLastHandledBy,string strmobilenumber,string strLeadtype,boolean boolAccountUniqueIDFlag,string EventType)
    {   
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
            objCart.CCPM_LeadType__c = strLeadtype;
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
    
}