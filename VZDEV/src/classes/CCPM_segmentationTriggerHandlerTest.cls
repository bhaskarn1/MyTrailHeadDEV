/**
*@name          CCPM_segmentationTriggerHandlerTest 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          Apr 17, 2018
*@description   This is a Test class for
*@Class         CCPM_segmentationTriggerHandlerTest
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    XX/XX/2017   Initial Implementation.
*/

@isTest
private class CCPM_segmentationTriggerHandlerTest {
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the constructor
	@param        N/A
	@return       Void(None)
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Chrissen Joseph (Deloitte)       04/19/2018   Initial Implementation.
	**/ 
    //This method is to cover the Before Insert and Before Update Scenarios
    static testMethod void myUnitTest1() { 
        Test.startTest();
        Campaign ca = new Campaign(Name='TestCampaign',
                                   CCPM_leadCustomerType__c = 'Customer',
                                   CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                   CCPM_eventLabel__c = 'testlabel',
                                   IsActive = true,
                                   recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event Type').getRecordTypeId());
        insert ca;
        CCPM_segmentation__c seg1 = new CCPM_segmentation__c	(CCPM_isActive__c = true, 
                                                             CCPM_campaign__c = ca.id, 
                                                             CCPM_districts1__c = 'AK01',
                                                             CCPM_districts2__c = 'GLW05-South Chicago-NW IN',
                                                             CCPM_districts3__c = 'ST03-Houston Southwest',
                                                             CCPM_markets__c = 'Great Lakes',
                                                             CCPM_territories__c = 'Alaska',
                                                             CCPM_channels__c = 'Retail');
        insert seg1;
        CCPM_segmentation__c seg2 = new CCPM_segmentation__c	(CCPM_isActive__c = True, 
                                                             CCPM_campaign__c = ca.id, 
                                                             CCPM_districts1__c = 'CC01',
                                                             CCPM_districts2__c = 'HI01',
                                                             CCPM_districts3__c = 'SN02',
                                                             CCPM_markets__c = 'HQ-Telesales',
                                                             CCPM_territories__c = 'Carolinas East',
                                                             CCPM_channels__c = 'Retail');
        
        insert seg2;
        seg1.CCPM_districts1__c = 'CAR01-Coastal Carolinas';
        seg1.CCPM_districts2__c = 'HQ-Telesales';
        seg1.CCPM_districts3__c = 'SN03';
        update seg1;
        Test.stopTest();
    }
    //This method is to cover the addError scenarios in Insert and Update  
    static testMethod void myUnitTest12() { 
        Test.startTest();
        Campaign ca = new Campaign(Name='TestCampaign',
                                   CCPM_leadCustomerType__c = 'Customer',
                                   CCPM_eventStartDate__c = '2018-09-09 02:02:02',
                                   CCPM_eventLabel__c = 'testlabel',
                                   IsActive = true,
                                   recordtypeid = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event Type').getRecordTypeId());
        insert ca;
        CCPM_segmentation__c seg1 = new CCPM_segmentation__c	(CCPM_isActive__c = true, 
                                                             CCPM_campaign__c = ca.id, 
                                                             CCPM_districts1__c = 'AK01',
                                                             CCPM_districts2__c = 'GLW05-South Chicago-NW IN',
                                                             CCPM_districts3__c = 'ST03-Houston Southwest',
                                                             CCPM_markets__c = 'Great Lakes',
                                                             CCPM_territories__c = 'Alaska',
                                                             CCPM_channels__c = 'Retail');
      insert seg1;
      Test.stopTest();
    }
    //This method is to cover the BeforeDelete class method
    static testMethod void myUnitTest2() {   
        Test.startTest();
        CCPM_segmentation__c seg1 = new CCPM_segmentation__c(CCPM_isActive__c = true, 
                                                             CCPM_districts1__c = 'AK01',
                                                             CCPM_markets__c = 'Great Lakes',
                                                             CCPM_territories__c = 'Alaska',
                                                             CCPM_channels__c = 'Retail');
        insert seg1;
        Map<id, CCPM_segmentation__c> segMap = new Map<id, CCPM_segmentation__c> ([select id from CCPM_segmentation__c where id =:seg1.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)segMap;
        CCPM_segmentationTriggerHandler segHandler = new CCPM_segmentationTriggerHandler();
        segHandler.BeforeDelete(mapOld);
        Test.stopTest();
    }
    //This method is to cover the AfterUpdate class method
    static testMethod void myUnitTest3() {   
        Test.startTest();
        CCPM_segmentation__c seg1 = new CCPM_segmentation__c(CCPM_isActive__c = true, 
                                                             CCPM_districts1__c = 'AK01',
                                                             CCPM_markets__c = 'Great Lakes',
                                                             CCPM_territories__c = 'Alaska',
                                                             CCPM_channels__c = 'Retail');
        insert seg1;
        Map<id, CCPM_segmentation__c> segMap = new Map<id, CCPM_segmentation__c> ([select id from CCPM_segmentation__c where id =:seg1.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)segMap;
        CCPM_segmentationTriggerHandler segHandler = new CCPM_segmentationTriggerHandler();
        segHandler.AfterUpdate(mapOld,mapOld);
        Test.stopTest();
    }
    //This method is to cover the AfterDelete class method
    static testMethod void myUnitTest4() {   
        Test.startTest();
        CCPM_segmentation__c seg1 = new CCPM_segmentation__c(CCPM_isActive__c = true, 
                                                             CCPM_districts1__c = 'AK01',
                                                             CCPM_markets__c = 'Great Lakes',
                                                             CCPM_territories__c = 'Alaska',
                                                             CCPM_channels__c = 'Retail');
        insert seg1;
        Map<id, CCPM_segmentation__c> segMap = new Map<id, CCPM_segmentation__c> ([select id from CCPM_segmentation__c where id =:seg1.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)segMap;
        CCPM_segmentationTriggerHandler segHandler = new CCPM_segmentationTriggerHandler();
        segHandler.AfterDelete(mapOld);
        Test.stopTest();
    }
    //This method is to cover the AfterUndelete class method
    static testMethod void myUnitTest5() {   
        Test.startTest();
        CCPM_segmentation__c seg1 = new CCPM_segmentation__c(CCPM_isActive__c = true, 
                                                             CCPM_districts1__c = 'AK01',
                                                             CCPM_markets__c = 'Great Lakes',
                                                             CCPM_territories__c = 'Alaska',
                                                             CCPM_channels__c = 'Retail');
        insert seg1;
        Map<id, CCPM_segmentation__c> segMap = new Map<id, CCPM_segmentation__c> ([select id from CCPM_segmentation__c where id =:seg1.id]);
        Map<id, sObject> mapOld = (Map<id, sObject>)segMap;
        CCPM_segmentationTriggerHandler segHandler = new CCPM_segmentationTriggerHandler();
        segHandler.AfterUndelete(mapOld);
        Test.stopTest();
    }
    
}