/**
*@name          CCPM_getProspectAccountInformationAsync 
*@author        Manjunath Keshava (Deloitte)
*@date          06/21/2017
@description   @(US_0392) This is  a  method to Encypt CCPM_accountUniqueID__c using a custom Key 
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    07/21/2017               			 Original Version
*/
public class CCPM_EncryptKey 
{
    public static string CCPM_EncryptKey(string strName)
    {
        string StrFinalData;
        blob newdata = blob.valueOf(strName);
        //system.debug('the newdata is'+newdata);
        Blob cryptoKey = Blob.valueOf(CCPM_staticConstants.strEncryptedKey);
        Blob encryptedData = Crypto.encryptWithManagedIV(CCPM_staticConstants.strEncryptionAlgorithm,cryptoKey, newdata );
        String strData = EncodingUtil.base64Encode(encryptedData);
        if(strData!=null && strData.length()>=32)
         StrFinalData= strData.substring(0, 32);
        //system.debug('encrypt data'+encryptedData);
        //system.debug('the final output is'+StrFinalData);
        
        // Blob decryptedData = Crypto.decryptWithManagedIV(CCPM_staticConstants.strEncryptionAlgorithm, cryptoKey ,encryptedData);
        //String strdryptData = decryptedData.toString();
         //System.debug('Printing dryptData '+dryptData);
		
    return StrFinalData;
    }
}