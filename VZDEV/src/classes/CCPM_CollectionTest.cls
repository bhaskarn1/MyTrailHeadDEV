/**
*@name          CCPM_CollectionTest 
*@author        Manjunath Keshava (Deloitte)
*@date          06/13/2017
@description    This is the Unit Test Class for the CCPM_Collection Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    10/25/2017                          Original Version
Paras Shah (Deloitte)           11/28/2017                          Additional Test case scenario
*/
@isTest
public class CCPM_CollectionTest 
{
    @isTest
    public static void isNotNullEmptyTest()
    {
        CCPM_testdataFactory.createCustomSetting();
        Lead objCart=new Lead();
        objCart.LastName='testsample';
        objCart.FirstName='Inactive test';
        objCart.Status='New';
        objCart.Company = '1';  
        objcart.CCPM_accountUniqueID__c='23467';
        //objCart.CCPM_eventType__c = 'SMB';
        objcart.CCPM_SMSFollowUpDate__c = system.now().addHours(5);
        objCart.CCPM_mobileNumber__c = '3213187287';
        objCart.CCPM_email__c ='test@gmail.com';
        objCart.CCPM_confirmEmail__c='test@gmail.com';
        datetime date1=Datetime.now();
        objCart.CCPM_createdDate__c=date1.addHours(-5);
        objCart.CCPM_SMSLegalOptIn__c =true;
        objCart.CCPM_confirmMTN__c= '3213187287';
        objCart.CCPM_LeadType__c = 'Customer Abandoned Cart Digital';
        
        
        insert objCart;
        
        map<id,lead> maplead= new map<id,lead>();
        Boolean isNotNullEmplty = CCPM_collection.isNotNullEmpty(maplead);
        System.assertEquals(false, isNotNullEmplty);
        
        map<String,lead> mapleadStr= new map<String,lead>();
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(mapleadStr);
        System.assertEquals(false, isNotNullEmplty);
        
        maplead.put(objcart.id, objCart);
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(maplead);
        System.assertEquals(true, isNotNullEmplty);
        list<string> lststr= new  list<string>();
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(lststr);
        System.assertEquals(false, isNotNullEmplty);
        
        lststr.add('Test');
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(lststr);
        System.assertEquals(true, isNotNullEmplty);
        
        Set<sObject> setSObj = new Set<sObject>();
        
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(setSObj);
        System.assertEquals(false, isNotNullEmplty);
        setSObj.add(objCart);
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(setSObj);
        System.assertEquals(true, isNotNullEmplty);
         CCPM_collection.populateSetFromString('strCustom,Label', ',');
                Set<string> setString = new Set<string>();
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(setString);
                        System.assertEquals(false, isNotNullEmplty);
                    setString.add('Test');
                isNotNullEmplty = CCPM_collection.isNotNullEmpty(setString);
                System.assertEquals(true, isNotNullEmplty);
        list<sObject> lstSObj = new list<sObject>();
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(lstSObj);
        System.assertEquals(false, isNotNullEmplty);
        lstSObj.add(objCart);
        isNotNullEmplty = CCPM_collection.isNotNullEmpty(lstSObj);
        System.assertEquals(true, isNotNullEmplty);
        
        //Updates by Paras Shah
        
        setString.add('TestString1');
        setString.add('TestString2');  
        
        Map<String, Set<String>> mapStringSetString = new Map<String, Set<String>>();
        mapStringSetString.put('mapKeyOne',setString);
        Boolean boolTestMapWithStringSetString = CCPM_collection.isNotNullEmpty(mapStringSetString);
        
        Map<String, List<sObject>> mapStringSObject = new Map<String, List<sObject>>();
        mapStringSObject.put('mapKeyOne',lstSObj);
        Boolean boolTestMapWithStringSObject = CCPM_collection.isNotNullEmpty(mapStringSObject);
        
        Map<String, Boolean> mapStringBoolean = new Map<String, Boolean>();
        mapStringBoolean.put('mapKeyOne',true);
        Boolean boolTestMapStringBoolean = CCPM_collection.isNotNullEmpty(mapStringBoolean);
        
        Map<String, String> mapStringString = new Map<String, String>();
        mapStringString.put('mapKeyOne','StringOne');
        Boolean boolTestMapStringString = CCPM_collection.isNotNullEmpty(mapStringString);
    }
    

}