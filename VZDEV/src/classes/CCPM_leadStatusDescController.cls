/**
*@name          CCPM_leadStatusDescController 
*@author        Ritwik Koneru (Deloitte)
*@date          03/09/2018
*@description   This is a component controller class for CCPM_leadStatusDescController
*@Class         CCPM_leadStatusDescController
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Ritwik Koneru (Deloitte)    	03/09/2018   Initial Implementation.
*/

public class CCPM_leadStatusDescController {

    /**
	@author        Ritwik Koneru(Deloitte)
	@description   Method which returns the ccpm_leadStatusDesc__mdt
	@param         LeadId
	@return        ccpm_leadStatusDesc__mdt metadata record
	*/
    @AuraEnabled
    public static statusDescWrapper getStatusDetails (String leadId) {
        system.debug('fff=  '+leadId);
        
        ccpm_leadStatusDesc__mdt objCMD;
        String strStatus='';
        statusdescWrapper retWrap = new statusdescWrapper();
        
        lead objLead = [SELECT id, status,ccpm_leadSubstatus__c,CCPM_createdChannel__c 
                          FROM lead 
                         WHERE id =: leadId];
        
        
        if (String.isNotBlank(objLead.ccpm_leadSubStatus__c)){
        	strStatus = objLead.status+'-'+objLead.ccpm_leadSubStatus__c; 
        } else {
            strStatus = objLead.status;
        }
            
        if (objLead.ccpm_createdchannel__c.tolowercase() == 'telesales'){
            objCMD = getMetadataRec(objLead.ccpm_createdChannel__c.tolowercase(),strStatus);
        } else {
            objCMD = getMetadataRec('retail',strStatus);
        }
        
        if (objCMD != null) {
            retWrap.description = objCMD.CCPM_description__c;
            retWrap.nextSteps = objCMD.ccpm_nextSteps__c;
        }
        return retWrap;
    }
    
    /**
	@author        Ritwik Koneru(Deloitte)
	@description   Method which returns the ccpm_leadStatusDesc__mdt
	@param         createdchannel, status
	@return        ccpm_leadStatusDesc__mdt metadata record
	*/
    public static ccpm_leadStatusDesc__mdt getMetadataRec(String createdChannel,String strStatus) {
        list<ccpm_leadStatusDesc__mdt> lstCMD = [SELECT id,MasterLabel, ccpm_description__c, ccpm_nextSteps__c,ccpm_createdChannel__c
                        					 	   FROM ccpm_leadStatusDesc__mdt
                       						      WHERE MasterLabel =: strStatus
                         					  	 	AND ccpm_createdChannel__c =: createdChannel
                       							  LIMIT 1];
        return lstCMD[0];
    }
    
    /**
	*@name          statusDescWrapper 
	*@author        Ritwik Koneru (Deloitte)
	*@date          03/09/2018
	*@description   This is a wrapper class for send data back to aura component
	*@Class         statusDescWrapper
	*/
    public class statusDescWrapper {
       @AuraEnabled public String description{get;set;}
       @AuraEnabled public string nextSteps{get;set;}       
    }
}