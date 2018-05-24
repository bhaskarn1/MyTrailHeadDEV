/**
*@name          CCPM_processConvertedLeadsBatchHandler
*@author        Paras Shah (Deloitte)
*@date          12/12/2017
@description    Handler class to Process Converted Leads
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer             				  	Date       			Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)        			12/12/2017    		Original Version					
*/

public class CCPM_processConvertedLeadsBatchHandler {
    
/**
*@author        Paras Shah (Deloitte)
*@description   This method processes Converted Leads
*@Params		List<Lead>
*@return        Void(None)
*/ 
    
    public static void processConvertedLeads(List<Lead> lstConvertedLeadRecords){
        //Check if the parameter is not null and process it
        if(CCPM_Collection.isNotNullEmpty(lstConvertedLeadRecords)){ //isNotNullEmpty
            
            // List to hold the Cart Type records
            List<CCPM_CartType__c> lstCartType = new List<CCPM_CartType__c>();
            Map<String, Lead> mapOpenLeads = new Map<String, Lead>();
            Set<String> setMTN = new Set<String>();
            //Process through each record in the Queue and create individual Cart type records
            for(Lead objConvertedLeads: lstConvertedLeadRecords) {
                
                // String array to hold Cart types separated by Comma
                List<String> lstCartTypes = new List<String>();
                
                // Split the Cart types based on Comma                 
                if (objConvertedLeads.CCPM_convertedCartType__c != null) {
                	if(objConvertedLeads.CCPM_mobileNumber__c != null){
                		setMTN.add(objConvertedLeads.CCPM_mobileNumber__c);	
                	}
                    lstCartTypes = CCPM_utility.getListFromString(objConvertedLeads.CCPM_convertedCartType__c, ','); 
                }
                
                if(CCPM_Collection.isNotNullEmpty(lstCartTypes)){
                    // Create records for each Cart type
                    for(String strCtVal : lstCartTypes){
                        CCPM_CartType__c objCartType = new CCPM_CartType__c(Lead__c = objConvertedLeads.Id, CCPM_CartType__c = strCtVal.trim());
                        objCartType.CCPM_CartTypeMapping__c = CCPM_utility.setCartTypeValues.contains(objCartType.CCPM_CartType__c) ? objCartType.CCPM_CartType__c : Label.CCPM_cartTypeOTHER;
                        lstCartType.add(objCartType);
                    }
                }
                objConvertedLeads.CCPM_cartTypeProcessed__c = true;
            }
            // code to update open leads for the MTN which were converted.
            
            
            List<LOG_LogMessage__c> lstBatchLogMsg = new List<LOG_LogMessage__c>();
            Savepoint sp = Database.setSavepoint();
            boolean boolContinue = true;
            try
            { 
                if(CCPM_Collection.isNotNullEmpty(lstCartType))
                {
                    insert lstCartType;
                } 
            }
            catch(Exception e)
            {
                boolContinue = false;
                lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while creating records for Converted Cart Types',''));
            }

            try
            { 
                if(CCPM_Collection.isNotNullEmpty(lstConvertedLeadRecords) && boolContinue){
                	update lstConvertedLeadRecords;	
                }
                
            }
            catch(Exception e)
            {
            	boolContinue = false;
                lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while updating the Converted Lead records',''));
            }
            //Code to update the existing open leads
            if(CCPM_Collection.isNotNullEmpty(setMTN)){
            	Set<String> setOpenLeadStatus = CCPM_utility.setleadOpenStatus;
            	List<String> lstNewMTN = new List<String>();
            	lstNewMTN.addAll(setMTN);
            	String strBuildSOSLQuery = 'FIND \''+String.join(lstNewMTN, ' OR ')+'\' IN PHONE FIELDS RETURNING LEAD (id,CCPM_mobileNumber__c WHERE Status IN :setOpenLeadStatus Order By CreatedDate ASC)';
            	List<List<sObject>> lstSearchLead = Search.query(strBuildSOSLQuery);
            	Map<Id, Lead> mapLead = new Map<Id, Lead>((List<Lead>)lstSearchLead[0]);
            	for(Lead objLead : mapLead.values()){
            		if(!mapOpenLeads.containsKey(objLead.CCPM_mobileNumber__c)){
            			mapOpenLeads.put(objLead.CCPM_mobileNumber__c, new Lead(id=objLead.id));
            		}
            	}
            } 
			//******to get a difference in time between converted leads and Open leads			
            Datetime timeToUpdate = System.now().addSeconds(Integer.valueOf(Label.CCPM_openLeadsUpdateGap));
            while(System.now() < timeToUpdate){
            } 
            
            //******end
            
            try{
            	if(CCPM_Collection.isNotNullEmpty(mapOpenLeads.values()) && boolContinue){
            		update mapOpenLeads.values();
            	}
            }
            catch(Exception e)
            {
            	boolContinue = false;
            	lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while updating the Open Lead records',''));
            }
            
            try{
            	if(boolContinue == false){
            		Database.rollback(sp);	
            	}  
            	if(CCPM_Collection.isNotNullEmpty(lstBatchLogMsg)){
            		upsert lstBatchLogMsg;
            	}
            	
            }  
            catch(Exception e){
            	insert CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while inserting logs','');
            }
        }
    }
}