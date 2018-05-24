/**
*@name          CCPM_getProspectAccountInformationTest 
*@author        Manjunath Keshava (Deloitte)
*@date          06/13/2017
@description    This is the Unit Test Class for the CCPM_getProspectAccountInformationTest Class  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    06/13/2017               			 Original Version
*/
@isTest(SeeAllData=false)
public class CCPM_getProspectAccountInformationTest
{   
    
    
    public static   testmethod void  getAccountInfo_Test()
    {
        CCPM_testdataFactory.createCustomSetting();
        CCPM_staticConstants.strEncryptedKey='6159644412316563';
        CCPM_staticConstants.strEncryptionAlgorithm='AES128';
         test.startTest();
         Test.setMock(WebServiceMock.class, new CCPM_WebServiceMockGenerator());
	    CCPM_getProspectAccountInformationVision.prospectAccountInfo('7036159022');
        
        Test.stopTest();
    }
     public static   testmethod void  getNoAccountInfo_Test()
    {
        CCPM_testdataFactory.createCustomSetting();
        //CCPM_staticConstants.strEncryptedKey='6159644412316563';
         test.startTest();
         Test.setMock(WebServiceMock.class, new CCPM_WebServiceMockTwo());
	    CCPM_getProspectAccountInformationVision.prospectAccountInfo('7036159022');
        Test.stopTest();
    }
    public static   testmethod void  getEmptyAccountInfo_Test()
    {
        CCPM_testdataFactory.createCustomSetting();
        CCPM_staticConstants.strEncryptedKey='6159644412316563';
          CCPM_staticConstants.strColon=':';
         test.startTest();
         Test.setMock(WebServiceMock.class, new CCPM_WebServiceMockThree());
	    CCPM_getProspectAccountInformationVision.prospectAccountInfo('7036159022');
        Test.stopTest();
    }


}