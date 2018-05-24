/**
*@name          CCPM_REMergeHandler 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          01/18/2018
*@description   This is a class
*@Class         CCPM_REMergeHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    01/18/2018   Initial Implementation.
*/
public with sharing class CCPM_REMergeHandler  {
    
    public static Date todayDt = System.today();
    public static Map<String, String> mapVariable = new Map<String, String> ();
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This method searches for existing Lead Records with the MTN by SOSL query
	@param        Set<String>
	@return       Map<id, Lead>
	*/ 
    public static List<Lead> REReturnExisitngRecordBYSOSL(Set<String> setNewMTN, Set<String> setLeadStatus){
    	List<Lead> lstLead = new List<Lead>();
    	Set<String> setMergeFrameWorkLeadTypes = CCPM_utility.getSetFromString(Label.CCPM_mergeFrameworkLeadTypes, ',');        
        List<String> lstNewMTN = new List<String>();
    	lstNewMTN.addAll(setNewMTN);
    	String strBuildSOSLQuery = 'FIND ';
    	strBuildSOSLQuery = strBuildSOSLQuery + '\''+String.join(lstNewMTN, ' OR ')+'\' IN PHONE FIELDS RETURNING LEAD (id, Name WHERE Status IN :setLeadStatus AND CCPM_mfToBeMerged__c = false AND CCPM_leadType__c IN :setMergeFrameWorkLeadTypes)';
    	List<List<sObject>> lstSearchLead = Search.query(strBuildSOSLQuery);
    	Map<Id, Lead> mapLead = new Map<Id, Lead>((List<Lead>)lstSearchLead[0]);
    	String strBuildSOQLQuery = REgetMergeQueryWOWhereClause('Lead');
    	Set<id> setLeadIds = mapLead.keySet();
    	strBuildSOQLQuery = strBuildSOQLQuery + ' Where id IN : setLeadIds Order By CreatedDate ASC';
    	//System.debug('******'+strBuildSOQLQuery);
    	if(String.isNotBlank(strBuildSOQLQuery)){
    		lstLead = (List<Lead>)Database.query(strBuildSOQLQuery);
    	}
    	return lstLead;
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This method searches for existing Lead Records with the MTN by SOQL query
	@param        Set<String>
	@return       Map<id, Lead>
	*/ 
    public static List<Lead> REReturnExisitngRecordBYSOQL(Set<String> setNewMTN, Set<String> setLeadStatus){
    	List<Lead> lstLead = new List<Lead>();
        Set<String> setMergeFrameWorkLeadTypes = CCPM_utility.getSetFromString(Label.CCPM_mergeFrameworkLeadTypes, ',');
    	String strBuildSOQLQuery = REgetMergeQueryWOWhereClause('Lead');
    	strBuildSOQLQuery = strBuildSOQLQuery + ' Where Status IN : setLeadStatus AND CCPM_mobileNumber__c IN : setNewMTN AND CCPM_leadType__c IN :setMergeFrameWorkLeadTypes AND CCPM_mfToBeMerged__c = false Order By CreatedDate ASC';
    	if(String.isNotBlank(strBuildSOQLQuery)){
    		lstLead = (List<Lead>)Database.query(strBuildSOQLQuery);
    	}
    	return lstLead;
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This method sorts the map with MTN as key
	@param        List<Lead>
	@return       Map<String, List<Lead>>
	*/ 
    public static Map<String, List<String>> REReturnLeadsSortedByMTN(List<Lead> lstLead){
    	Map<String, List<String>> mapMTNListLead = new Map<String, List<String>>();
    	if(lstLead != null && lstLead.size() > 0){
    		for(Lead objLead : lstLead){
    			
    			if(mapMTNListLead.containsKey(objLead.CCPM_mobileNumber__c)){
    				mapMTNListLead.get(objLead.CCPM_mobileNumber__c).add(objLead.id);
    			}
    			else{
    				mapMTNListLead.put(objLead.CCPM_mobileNumber__c, new List<String>{objLead.id});	
    			}
    			
    		}
    	}
    	return mapMTNListLead; 
    }
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  This is the Lsit which does the merge
	@param        N/A
	@return       Void(None)
	*/ 
    public static void REMergeRecords(List<Lead> lstLead, String strSearchType){
    	
    	Map<String, CCPM_RERecord__c> mapFieldValueWithRec = new Map<String, CCPM_RERecord__c>();
    	
    	Map<Id, sObject> mapLoserRecordsToUpdate = new Map<Id, sObject>();
    	Map<Id, Lead> mapWinnerLeadsToUpdate = new Map<Id, Lead>();
        Map<Id, sObject> mapLoserRecordsToDelete = new Map<Id, sObject>();
    	Map<String, Lead> mapAllLeads = new Map<String, Lead>(lstLead);
    	List<sObject> lstRecTobeInserted = new List<sObject>();
    	System.debug('*****mapAllLeads.size First****'+mapAllLeads.size());
    	
    	Map<String, List<String>> mapMTNandLeadNewRecsIdFromBatch = REReturnLeadsSortedByMTN(lstLead);
    	
    	System.debug('*******'+mapMTNandLeadNewRecsIdFromBatch.keySet());
    	
    	List<Lead> lstExistingLeads = new List<Lead>();
    	Map<String, Lead> mapExistingLeads = new Map<String, Lead>();
    	if(mapMTNandLeadNewRecsIdFromBatch != null && !mapMTNandLeadNewRecsIdFromBatch.isEmpty() && String.isNotBlank(strSearchType) && CCPM_Collection.isNotNullEmpty(CCPM_utility.setleadOpenStatus)){
    		if(strSearchType == 'SOSL'){
    			lstExistingLeads = REReturnExisitngRecordBYSOSL(mapMTNandLeadNewRecsIdFromBatch.keySet(), CCPM_utility.setleadOpenStatus);
                mapExistingLeads = new Map<String, Lead>(REReturnExisitngRecordBYSOSL(mapMTNandLeadNewRecsIdFromBatch.keySet(), CCPM_utility.setleadOpenStatus));
    		}
    		else{
    			lstExistingLeads = REReturnExisitngRecordBYSOQL(mapMTNandLeadNewRecsIdFromBatch.keySet(), CCPM_utility.setleadOpenStatus);
                mapExistingLeads = new Map<String, Lead>(REReturnExisitngRecordBYSOQL(mapMTNandLeadNewRecsIdFromBatch.keySet(), CCPM_utility.setleadOpenStatus));
    		}
    	}
    	Map<String, List<String>> mapMTNandLeadExistRecsIdFromQuery = REReturnLeadsSortedByMTN(lstExistingLeads);
    	//Loop to remove New records which do not have existing records.
    	for(String strNewMTN : mapMTNandLeadNewRecsIdFromBatch.keyset()){
    		if((!mapMTNandLeadExistRecsIdFromQuery.containsKey(strNewMTN)) && mapMTNandLeadNewRecsIdFromBatch.get(strNewMTN).size() == 1){
    			if(CCPM_Collection.isNotNullEmpty(mapMTNandLeadNewRecsIdFromBatch.get(strNewMTN))){
    				for(String strLeadId : mapMTNandLeadNewRecsIdFromBatch.get(strNewMTN)){
    					Lead objLead  = new Lead(Id = strLeadId, CCPM_mfToBeMerged__c = false);
    					mapLoserRecordsToUpdate.put(objLead.id, objLead);
    				}
    			}
    			mapMTNandLeadNewRecsIdFromBatch.remove(strNewMTN);
    		}
    	}
    	//This map contains two lead id's for each mtn, the ID in 0 position is the existing Record ID and the ID at 1 position is the new Record ID
    	Map<String, List<String>> mapMTNLeadIds = new Map<String, List<String>>();
    	//Set to collect MTN values which have duplicate leads in open status already in the system. 
    	Set<String> setDupMTNInExisting = new set<String>();
                
    	if(CCPM_Collection.isNotNullEmpty(lstExistingLeads)){
    		for(Lead objExistLead : lstExistingLeads){
    			mapAllLeads.put(objExistLead.id, objExistLead);
    			if(mapMTNLeadIds.containsKey(objExistLead.CCPM_mobileNumber__c) && mapMTNLeadIds.get(objExistLead.CCPM_mobileNumber__c).size() > 0){
    				if(mapMTNandLeadNewRecsIdFromBatch.containsKey(objExistLead.CCPM_mobileNumber__c)){
    					//if the MTN already exists in the duplicate list means that there are more than two records that are not previously merged for the same MTN.
    					//These Leads will be updated as to be merged so that they will be merged in the next run.
    					if(setDupMTNInExisting.contains(objExistLead.CCPM_mobileNumber__c)){
    						Lead objExistingLeadDup = new Lead(id = objExistLead.id, CCPM_mfToBeMerged__c = true);
    						mapLoserRecordsToUpdate.put(objExistingLeadDup.Id, objExistingLeadDup);
    					}
    					else{
    						//since the MTN is not in the duplicate list means that this is the second duplicate record. This lead will replace the lead ids in 
    						//the new list. THis is because the before processing the new records, the old records must be merged first. 
    						mapMTNandLeadNewRecsIdFromBatch.put(objExistLead.CCPM_mobileNumber__c, new List<String>{objExistLead.id});
    						setDupMTNInExisting.add(objExistLead.CCPM_mobileNumber__c);
    					}
    				}
    			}
    			else{
    				mapMTNLeadIds.put(objExistLead.CCPM_mobileNumber__c, new List<String>{objExistLead.id});
    			}
    		}
    	}
    	if(mapMTNandLeadNewRecsIdFromBatch != null && mapMTNandLeadNewRecsIdFromBatch.size() > 0){
    		//now processing through the new list 
    		for(String strNewMTN : mapMTNandLeadNewRecsIdFromBatch.keySet()){
    			if((mapMTNandLeadNewRecsIdFromBatch.get(strNewMTN).size() > 1) && !mapMTNLeadIds.containsKey(strNewMTN)){
    				List<String> lstLeadId = new List<String>();
    				for(Integer i=0;i<=1;i++){
    					lstLeadId.add(mapMTNandLeadNewRecsIdFromBatch.get(strNewMTN)[i]);
    				}
    				mapMTNLeadIds.put(strNewMTN, lstLeadId);
    			}
    			else if(mapMTNLeadIds.containsKey(strNewMTN) && mapMTNandLeadNewRecsIdFromBatch.get(strNewMTN).size() >= 1){
    				mapMTNLeadIds.get(strNewMTN).add(mapMTNandLeadNewRecsIdFromBatch.get(strNewMTN)[0]);
    			}
    		}
    	}
    	List<CCPM_RERecord__c> lstRecords = [Select Name, Id, CCPM_active__c,
											(Select Id,CCPM_fieldName__c,CCPM_operator__c,CCPM_valueText__c,CCPM_active__c,CCPM_fieldType__c,
                							CCPM_valueDouble__c,CCPM_valueDate__c From CCPM_RECriterias__r)
											 From CCPM_RERecord__c Where CCPM_primaryObject__c = 'Lead'];
    	
    	Map<String, CCPM_Action__c> mapAction = getActionMap();
    	
    	Map<String, CCPM_Rule__c> mapUniqConcatKeyRule = getRuleMap();
    	for(String strNewMTN : mapMTNLeadIds.keyset()){
    		List<String> lstRecConcatKey = new List<String>();
    		for(String strLeadId : mapMTNLeadIds.get(strNewMTN)){
    			Lead objLead = mapAllLeads.get(strLeadId);
    			for(CCPM_RERecord__c objRec : lstRecords){
    				System.debug('*****Evaluate :'+objRec.Name);
    				Integer intCounter = 0;
    				if ((objRec.CCPM_RECriterias__r).size() > 0) {
    					for (CCPM_Criteria__c objCri : objRec.CCPM_RECriterias__r) {
    						boolean boolCriEvalResult = true;
    						boolCriEvalResult = evaluateCriteria(objLead, objCri);
    						if (boolCriEvalResult == false) {
    							break;
    						}
    						intCounter++;
    					}
    				}
    				if (intCounter == objRec.CCPM_RECriterias__r.size()) {
    					System.debug('*****Record Matched :'+objRec.Name);
    					lstRecConcatKey.add(String.valueOf(objRec.id).substring(0, 15));
						break;
					}
    			}
    		}
    		if(lstRecConcatKey.size() == 2 && CCPM_Collection.isNotNullEmpty(mapUniqConcatKeyRule) && mapUniqConcatKeyRule.get(String.join(lstRecConcatKey, '_')) != null){
    			
    			CCPM_Rule__c objRule = mapUniqConcatKeyRule.get(String.join(lstRecConcatKey, '_'));
                System.debug('********objRule.Name********'+objRule.Name);
    			Lead objLeadWinner = mapAllLeads.get(mapMTNLeadIds.get(strNewMTN)[0]);
    			Lead objLeadLoser = mapAllLeads.get(mapMTNLeadIds.get(strNewMTN)[1]);
    			
				if(objRule.CCPM_winningRecord__c == 'New Record'){
					objLeadWinner = mapAllLeads.get(mapMTNLeadIds.get(strNewMTN)[1]);
					objLeadLoser = mapAllLeads.get(mapMTNLeadIds.get(strNewMTN)[0]);
				}
				if(CCPM_Collection.isNotNullEmpty(objRule.CCPM_RERuleActions__r)){
					//Map TO collect Variables
					
					for(CCPM_RuleAction__c objRuleAct : objRule.CCPM_RERuleActions__r){
						CCPM_Action__c objAction = mapAction.get(objRuleAct.CCPM_action__c);
						
						//Map<String, Schema.sObjectField> targetFields =  Schema.getGlobalDescribe().get(objAction.CCPM_actionObject__c).getDescribe().fields.getMap();
						if(CCPM_Collection.isNotNullEmpty(objAction.CCPM_ActionComponents__r)){
							
							System.debug('*****objAction.Name****'+objAction.Name);
							Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objAction.CCPM_actionObject__c);
			                SObject newSobject = targetType.newSObject();
			                Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
			                
							if(objAction.CCPM_type__c == 'Update' && objAction.CCPM_masterObject__c == objAction.CCPM_actionObject__c ){
								newSobject = mapWinnerLeadsToUpdate.containsKey(objLeadWinner.id) ? mapWinnerLeadsToUpdate.get(objLeadWinner.id) : objLeadWinner;
							}
							for(CCPM_ActionComponent__c objAC : objAction.CCPM_ActionComponents__r){
                                System.debug('******objAC.CCPM_fieldAPIName__c*******'+objAC.CCPM_fieldAPIName__c);
								if(objAC.CCPM_mergeCopy__c){
                                    if(objAC.CCPM_mergeCopyIfNullOrBlank__c == false || (objAC.CCPM_mergeCopyIfNullOrBlank__c && objLeadWinner.get(objAC.CCPM_fieldAPIName__c) == null)){
                                        newSobject.put(objAC.CCPM_fieldAPIName__c, objLeadLoser.get(objAC.CCPM_fieldAPIName__c));
                                    }                                    
								}
								else{
									String value = String.isNotBlank(objAC.CCPM_fieldValue__c) ? (objAC.CCPM_fieldValue__c).trim() : null;
									Schema.DisplayType valueType = null;
									if (objAC.CCPM_fieldAPIName__c != 'Variable') {
										valueType = targetFields.get(objAC.CCPM_fieldAPIName__c).getDescribe().getType();
									}
									else{
										mapVariable.put(objAC.CCPM_variableName__c, value);
									}
									if (value!= null && checkforTagsandOperators(value)) {
										value = parseStringWithTag(value, objLeadLoser, objLeadWinner, newSobject);
									}
									System.debug('****objAC.CCPM_fieldAPIName__c******'+objAC.CCPM_fieldAPIName__c+'***Value***'+value+'*****valueType***'+valueType);
									if (valueType != null) {
                                        if(value == null){
                                            newSobject.put(objAC.CCPM_fieldAPIName__c, null);
                                        }
                                        else if(value.toLowerCase() == 'null'){
											newSobject.put(objAC.CCPM_fieldAPIName__c, null);
										}
										else if (valueType != Schema.DisplayType.String)
										{
											if (valueType == Schema.DisplayType.Date) {
												if (value.contains('<Today>')) {
													newSobject.put(objAC.CCPM_fieldAPIName__c, evaluavateDate(value));
												}
												else {
													newSobject.put(objAC.CCPM_fieldAPIName__c, Date.valueOf(value));
												}
											}
											else if (valueType == Schema.DisplayType.DateTime) {
												Date d = System.Today();
												if (value.contains('<Today>')) {
													d = evaluavateDate(value);
												}
												else {
													d = Date.valueOf(value);
												}
												newSobject.put(objAC.CCPM_fieldAPIName__c, datetime.newInstance(d.year(), d.month(), d.day()));
											}
			
											else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency) {
												newSobject.put(objAC.CCPM_fieldAPIName__c, value == '' ? null : Decimal.valueOf(value));
											}
											else if (valueType == Schema.DisplayType.Double) {
												newSobject.put(objAC.CCPM_fieldAPIName__c, value == '' ? null : Double.valueOf(value));
											}
											else if (valueType == Schema.DisplayType.Integer) {
												newSobject.put(objAC.CCPM_fieldAPIName__c, Integer.valueOf(value));
											}
											else if (valueType == Schema.DisplayType.Base64) {
												newSobject.put(objAC.CCPM_fieldAPIName__c, Blob.valueOf(value));
											}
											else if (valueType == Schema.DisplayType.Boolean) {
												if (value.contains('rue')) {
													newSobject.put(objAC.CCPM_fieldAPIName__c, true);
												}
												else {
													newSobject.put(objAC.CCPM_fieldAPIName__c, false);
												}
											}
											else {
												if(objAC.CCPM_fieldAPIName__c == 'RecordTypeId'){
												
													value = Schema.getGlobalDescribe().get(objAction.CCPM_actionObject__c).getDescribe().getRecordTypeInfosByName().get(value).getRecordTypeId();
													System.debug('*****value*****RecordType***'+value);
												}
												newSobject.put(objAC.CCPM_fieldAPIName__c, value);
											}
			
										}
										else {
											
											newSobject.put(objAC.CCPM_fieldAPIName__c, value);
										}
									}
								}
							}
							if(objAction.CCPM_type__c == 'Update' && objAction.CCPM_masterObject__c == objAction.CCPM_actionObject__c ){
								mapWinnerLeadsToUpdate.put(newSobject.Id, (Lead)newSobject);
							}
							if(objAction.CCPM_type__c == 'Insert' ){
								lstRecTobeInserted.add(newSobject);
							}
                            
                            mapLoserRecordsToDelete.put(objLeadLoser.Id, objLeadLoser);                            
						}
						else{
							if(objAction.CCPM_relatedObject__c == 'SMSMessage'){
								if(CCPM_Collection.isNotNullEmpty(objLeadLoser.SMS_Message_Sent__r)){
									for(CCPM_SMSMessage__c objSMS : objLeadLoser.SMS_Message_Sent__r){
										objSMS.CCPM_leadRecord__c = objLeadWinner.Id;
                                        if(objSMS.CCPM_MessageStatus__c == 'Queued'){
                                            objSMS.CCPM_MessageStatus__c = 'Removed';
                                        }
										mapLoserRecordsToUpdate.put(objSMS.id, objSMS);
									}
								}
							}
							else if(objAction.CCPM_relatedObject__c == 'Task'){
								if(CCPM_Collection.isNotNullEmpty(objLeadLoser.Tasks)){
									for(Task objtask : objLeadLoser.Tasks){
                                        objtask.WhoId = objLeadWinner.Id;
                                        if(objtask.IsClosed == false && objtask.Status != 'Cancelled'){
                                            objtask.Status = 'Cancelled';
                                        }
										mapLoserRecordsToUpdate.put(objtask.id, objtask);
									}
								}
							}
						}
					}
				}	
			}
    	}
    	
    	if(CCPM_Collection.isNotNullEmpty(lstRecTobeInserted)){
    		insert lstRecTobeInserted;
    	}
    	
    	if(CCPM_Collection.isNotNullEmpty(mapLoserRecordsToUpdate)){
    		update mapLoserRecordsToUpdate.values();
    	} 
    	
    	if(CCPM_Collection.isNotNullEmpty(mapWinnerLeadsToUpdate)){
    		System.debug('********mapWinnerLeadsToUpdate*******'+mapWinnerLeadsToUpdate.keySet());
    		update mapWinnerLeadsToUpdate.values();
    	}   	
        if(CCPM_Collection.isNotNullEmpty(mapLoserRecordsToDelete)){
            delete mapLoserRecordsToDelete.values();
        }
    }
    
    public static Map<String, CCPM_Rule__c> getRuleMap(){
    	Map<String, CCPM_Rule__c> mapUniqConcatKeyRule = new Map<String, CCPM_Rule__c>();
    	for(CCPM_Rule__c objRule : [Select id, Name, CCPM_winningRecord__c, CCPM_primaryObject__c, CCPM_newRecord__c, CCPM_existingRecord__c, CCPM_mergeUniqueField__c, 
   									(Select CCPM_action__c From CCPM_RERuleActions__r Where CCPM_active__c = true) 
   									From CCPM_Rule__c WHERE CCPM_active__c = true AND CCPM_startDate__c <= :todayDt
		                            AND(CCPM_endDate__c = :null OR CCPM_endDate__c >= :todayDt) AND CCPM_primaryObject__c = :'Lead' AND RecordType.Name = 'Batch Merge Rule']){
			mapUniqConcatKeyRule.put(objRule.CCPM_mergeUniqueField__c, objRule);		                            		
		}
		return mapUniqConcatKeyRule;
    }
    
    public static Map<String, CCPM_Action__c> getActionMap(){
    	Set<String> setRecType = new Set<String>{'Merge Insert Or Update Action', 'Related Object Action'};
    	
    	Map<String, CCPM_Action__c> mapAction = new Map<String, CCPM_Action__c>([Select Id, Name, CCPM_type__c, CCPM_masterObject__c,CCPM_actionObject__c,CCPM_relatedObject__c,CCPM_relatedObjectAction__c,    									
										(Select CCPM_order__c, CCPM_variableName__c, CCPM_fieldAPIName__c, CCPM_fieldValue__c, CCPM_active__c, CCPM_mergeCopy__c,CCPM_mergeCopyIfNullOrBlank__c From CCPM_ActionComponents__r
			 							where CCPM_active__c = true ORDER BY CCPM_order__c)
									     From CCPM_Action__c where CCPM_active__c = true AND CCPM_startDate__c <= :todayDt
									     AND(CCPM_endDate__c = :null OR CCPM_endDate__c >= :todayDt) AND RecordType.Name IN:setRecType]);
    	
		return mapAction;
    }
        
    public static String REgetMergeQueryWOWhereClause(String strObjectAPIName){
		String strBuildQuery = REGetQueryWithAllFields(strObjectAPIName);
		if(strObjectAPIName == 'Lead'){
    		strBuildQuery = strBuildQuery + ', (Select Id, CCPM_MessageStatus__c From SMS_Message_Sent__r)';
    		strBuildQuery = strBuildQuery + ', (Select Id, Status, IsClosed From Tasks) ';
    		strBuildQuery = strBuildQuery + 'From '+strObjectAPIName;
    	}
    	return strBuildQuery;
    }
    
    public static String REGetQueryWithAllFields(String strObjectAPIName){
    	Set<String> setFieldNames = new Set<String>(Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe().fields.getMap().keySet());
    	List<String> lstFieldNames = new List<String>();
		lstFieldNames.addAll(setFieldNames);
		String strBuildQuery = 'Select '+ String.join(lstFieldNames, ', ');
		return strBuildQuery;
    }
    
    /**
	 * Method name   : parseStringWithTag
	 * Description   : 
	 * Return Type   : String
	 * Parameter     : String, sObject, sObject, sObject
	 **/

	public static String parseStringWithTag(String input, sObject objLosingLeadRec, sObject objWinningLeadRec, sObject objActionRec) {
		String value = input;
		System.debug('******value*******422*****'+value);
		try {
			while (value.contains('<w>')) {
				String fieldName = value.substringBetween('<w>', '</w>');
				value = value.replace(value.substring(value.indexOf('<w>'), value.indexOf('</w>') + 4), objWinningLeadRec.get(fieldname) + '');
				//System.debug(value.center(value.length() + 10, '*'));
			}
			while (value.contains('<l>')) {
				String fieldName = value.substringBetween('<l>', '</l>');
				System.debug('******fieldName*******431*****'+fieldName);
				value = value.replace(value.substring(value.indexOf('<l>'), value.indexOf('</l>') + 4), objLosingLeadRec.get(fieldname) + '');
				//System.debug(value.center(value.length() + 10, '*'));
				system.debug('******value'+value);
			}
			while (value.contains('<s>')) {
				String fieldName = value.substringBetween('<s>', '</s>');
				value = value.replace(value.substring(value.indexOf('<s>'), value.indexOf('</s>') + 4), objActionRec.get(fieldname) + '');
				//System.debug(value.center(value.length() + 10, '*'));
			}
			while (value.contains('<v>')) {
				String fieldName = value.substringBetween('<v>', '</v>');
				value = value.replace(value.substring(value.indexOf('<v>'), value.indexOf('</v>') + 4), mapVariable.get(fieldname) + '');
				//System.debug(value.center(value.length() + 10, '*'));
			}
			if (value.contains('<conStr>')) {
				String concatString = value.substringBetween('<conStr>', '</conStr>');
				for (String s : concatString.split(',')) {
					value += s;
				}
                //System.debug(value.center(value.length() + 10, '*'));
            }
            else {
                if (value.contains(' ')) {
                    List<String> strs = value.split(' ');
                    boolean boolSkip = false;
                    for(Integer i = 0;i<strs.size();i++){
                        if(math.mod(i, 2) == 0){
                            try{
                                Double dblVal = Double.valueOf(strs[i]);
                            }
                            catch(Exception e){
                                boolSkip = true;
                                break;
                            }
                        }                        
                    }
                    if(boolSkip == false){
                        Map<String, Integer> precedence = new Map<String, Integer> { '*' => 2, '/' => 2, '%' => 2, '+' => 1, '-' => 1 };
                            List<String> postfixStr = new List<String> ();
                        List<String> oprStack = new List<String> ();
                        
                        for (String s : strs) {                        
                            s = s.trim();
                            if (precedence.containsKey(s)) {
                                while (oprStack.size() > 0 && precedence.get(oprStack[oprStack.size() - 1]) >= precedence.get(s)) {
                                    postfixStr.add(oprStack[oprStack.size() - 1]);
                                    oprStack.remove(oprStack.size() - 1);
                                }
                                oprStack.add(s);
                            } else {
                                postfixStr.add(s);
                            }						
                        }
                        while (oprStack.size() > 0) {
                            postfixStr.add(oprStack[oprStack.size() - 1]);
                            oprStack.remove(oprStack.size() - 1);
                        }
                        //System.debug('postFixStr: '+postFixStr);
                        oprStack.clear();
                        for (String s : postfixStr) {
                            if (precedence.containsKey(s)) {
                                Integer i = oprStack.size() - 1;
                                if (s == '/') {
                                    oprStack[i - 1] = String.valueOf(Double.valueOf(oprStack[i - 1]) / Double.valueOf(oprStack[i]));
                                    oprStack.remove(i);
                                } else if (s == '*') {
                                    oprStack[i - 1] = String.valueOf(Double.valueOf(oprStack[i - 1]) * Double.valueOf(oprStack[i]));
                                    oprStack.remove(i);
                                } else if (s == '%') {
                                    oprStack[i - 1] = String.valueOf(Math.mod(Integer.valueOf(oprStack[i - 1]), Integer.valueOf(oprStack[i])));
                                    oprStack.remove(i);
                                } else if (s == '-') {
                                    oprStack[i - 1] = String.valueOf(Double.valueOf(oprStack[i - 1]) - Double.valueOf(oprStack[i]));
                                    oprStack.remove(i);
                                } else {
                                    oprStack[i - 1] = String.valueOf(Double.valueOf(oprStack[i - 1]) + Double.valueOf(oprStack[i]));
                                    oprStack.remove(i);
                                }
                            } else {
                                oprStack.add(s);
                            }
                        }
                        while (oprStack.size() > 1) {
                            Integer i = oprStack.size() - 1;
                            String s = oprStack[i];
                            if (s == '/') {
                                oprStack[i - 2] = String.valueOf(Double.valueOf(oprStack[i - 2]) / Double.valueOf(oprStack[i - 1]));
                                oprStack.remove(i);
                                oprStack.remove(i - 1);
                            } else if (s == '*') {
                                oprStack[i - 2] = String.valueOf(Double.valueOf(oprStack[i - 2]) * Double.valueOf(oprStack[i - 1]));
                                oprStack.remove(i);
                                oprStack.remove(i - 1);
                            } else if (s == '%') {
                                oprStack[i - 1] = String.valueOf(Math.mod(Integer.valueOf(oprStack[i - 2]), Integer.valueOf(oprStack[i - 1])));
                                oprStack.remove(i);
                                oprStack.remove(i - 1);
                            } else if (s == '-') {
                                oprStack[i - 2] = String.valueOf(Double.valueOf(oprStack[i - 2]) - Double.valueOf(oprStack[i - 1]));
                                oprStack.remove(i);
                                oprStack.remove(i - 1);
                            } else {
                                oprStack[i - 2] = String.valueOf(Double.valueOf(oprStack[i - 2]) + Double.valueOf(oprStack[i - 1]));
                                oprStack.remove(i);
                                oprStack.remove(i - 1);
                            }
                        }
                        value = Decimal.valueOf(oprStack[0]).setScale(2) + '';
                    }                    
                }
            }
		}
		catch(Exception e) {
			String error = 'Cannot process request. Problem with invalid value.';
			System.debug((e.getMessage()).center('EXCEPTION'.length() + 10, '*'));
		}
		return value;
	}
    
    /**
	 * Method name   : evaluavateDate
	 * Description   : 
	 * Return Type   : Date
	 * Parameter     : String
	 **/

	public static Date evaluavateDate(String inValue) {
		Date todayDate = System.today();
		if (inValue.contains(' ')) {
			Integer numOfDays = Integer.valueOf(inValue.split(' ').get(2));
			if (inValue.split(' ').get(1) == '-') {
				numOfDays = - numOfDays;
			}
			todayDate = todayDate.addDays(numOfDays);
		}
		return todayDate;
	}
    
    /**
	 * Method name   : checkforTagsandOperators
	 * Description   : 
	 * Return Type   : Boolean
	 * Parameter     : String
	 **/

	public static boolean checkforTagsandOperators(String s) {
		if ((s.contains('<w>') || s.contains('<l>') || s.contains('<s>') || s.contains('<v>') || s.contains(' + ') || s.contains(' - ') ||
		     s.contains(' * ') || s.contains(' / ') || s.contains(' % ')) && (!s.contains('<Today>'))) {
			return true;
		}
		else {
			return false;
		}
	}
    
    /**
	 * Method name   : evaluateCriteria
	 * Description   : 
	 * Return Type   : Boolean
	 * Parameter     : sObject, CCPM_Criteria__c
	 **/

	public static boolean evaluateCriteria(sObject newObject, CCPM_Criteria__c c) {
		boolean returnValue = false;
		//System.debug('*************c.CCPM_valueText__c************** ' + c.CCPM_fieldName__c + '*******' + c.CCPM_operator__c + '*******' + c.CCPM_valueText__c);
		//System.debug('*************c.CCPM_valueDate__c************** ' + c.CCPM_fieldName__c + '*******' + c.CCPM_operator__c + '*******' + c.CCPM_valueDate__c);
		//System.debug('*************c.CCPM_valueDouble__c************** ' + c.CCPM_fieldName__c + '*******' + c.CCPM_operator__c + '*******' + c.CCPM_valueDouble__c);
		if (String.isNotEmpty(c.CCPM_fieldType__c)) { c.CCPM_fieldType__c = c.CCPM_fieldType__c.trim(); }
		try {
			if (String.isNotEmpty(c.CCPM_valueText__c) || String.isNotEmpty(String.valueOf(c.CCPM_valueDate__c)) || String.isNotEmpty(String.valueOf(c.CCPM_valueDouble__c))) {
				if ((c.CCPM_fieldType__c == 'Text') || (c.CCPM_fieldType__c == 'Boolean')) {
					if (c.CCPM_operator__c == 'Equals') { if ((newObject.get(c.CCPM_fieldName__c) + '').toLowerCase() == (c.CCPM_valueText__c).toLowerCase()) returnValue = true; }
					else if (c.CCPM_operator__c == 'Not Equal To') { if ((newObject.get(c.CCPM_fieldName__c) + '').toLowerCase() != (c.CCPM_valueText__c).toLowerCase()) returnValue = true; }
					else if (c.CCPM_operator__c == 'Contains') { if (newObject.get(c.CCPM_fieldName__c)!=null && ((String) newObject.get(c.CCPM_fieldName__c)).contains(c.CCPM_valueText__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Does Not Contain') { if (newObject.get(c.CCPM_fieldName__c)==null || !((String) newObject.get(c.CCPM_fieldName__c)).contains(c.CCPM_valueText__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Starts With') { if (((String) newObject.get(c.CCPM_fieldName__c)).startsWith(c.CCPM_valueText__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Ends with') { if (((String) newObject.get(c.CCPM_fieldName__c)).endsWith(c.CCPM_valueText__c)) returnValue = true; }
				}
				else if (c.CCPM_fieldType__c == 'Date') {
					Schema.DisplayType t = (newObject.Id.getSobjectType().getDescribe().fields.getMap()).get(c.CCPM_fieldName__c).getDescribe().getType();
					Date dtAvalue = (Date) newObject.get(c.CCPM_fieldName__c);
					if (t == Schema.DisplayType.DateTime) {
						Datetime dT = (Datetime) newObject.get(c.CCPM_fieldName__c);
						dtAvalue = date.newinstance(dT.year(), dT.month(), dT.day());
					}
					Date dtBvalue = c.CCPM_valueDate__c;
					if ((c.CCPM_valueText__c).contains('<Today>')) { dtBvalue = evaluavateDate(c.CCPM_valueText__c); }
					if (c.CCPM_operator__c == 'Equals') { if (dtAvalue == dtBvalue) returnValue = true; }
					else if (c.CCPM_operator__c == 'Not Equal To') { if (dtAvalue != dtBvalue) returnValue = true; }
					else if (c.CCPM_operator__c == 'Greater Than') { if (dtAvalue> dtBvalue) returnValue = true; }
					else if (c.CCPM_operator__c == 'Greater Or Equal') { if (dtAvalue >= dtBvalue) returnValue = true; }
					else if (c.CCPM_operator__c == 'Less Than') { if (dtAvalue<dtBvalue) returnValue = true; }
					else if (c.CCPM_operator__c == 'Less Or Equal') { if (dtAvalue <= dtBvalue) returnValue = true; }
				}
				else if (c.CCPM_fieldType__c == 'Double') {
					String intValue = ((c.CCPM_valueDouble__c + '').contains('.00')) ? (c.CCPM_valueDouble__c + '').substringBefore('.') : (c.CCPM_valueDouble__c + '');
					//System.debug('***************intValue***********' + intValue);
					if (c.CCPM_operator__c == 'Equals') { if (((Double) newObject.get(c.CCPM_fieldName__c)) == (c.CCPM_valueDouble__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Not Equal To') { if (((Double) newObject.get(c.CCPM_fieldName__c)) != (c.CCPM_valueDouble__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Contains') { if ((((Double) newObject.get(c.CCPM_fieldName__c)) + '').contains(intValue)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Does Not Contain') { if (!(((Double) newObject.get(c.CCPM_fieldName__c)) + '').contains(intValue)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Starts With') { if ((((Double) newObject.get(c.CCPM_fieldName__c)) + '').startsWith(intValue)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Ends with') { if ((((Double) newObject.get(c.CCPM_fieldName__c)) + '').endsWith(intValue)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Greater Than') { if (((Double) newObject.get(c.CCPM_fieldName__c))> (c.CCPM_valueDouble__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Greater Or Equal') { if (((Double) newObject.get(c.CCPM_fieldName__c)) >= (c.CCPM_valueDouble__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Less Than') { if (((Double) newObject.get(c.CCPM_fieldName__c)) < (c.CCPM_valueDouble__c)) returnValue = true; }
					else if (c.CCPM_operator__c == 'Less Or Equal') { if (((Double) newObject.get(c.CCPM_fieldName__c)) <= (c.CCPM_valueDouble__c)) returnValue = true; }
				}
			}
			else {
				if (c.CCPM_operator__c == 'Equals') { if (newObject.get(c.CCPM_fieldName__c) == null) returnValue = true; }
				else if (c.CCPM_operator__c == 'Not Equal To') { if (newObject.get(c.CCPM_fieldName__c) != null) returnValue = true; }
			}
		}
		catch(Exception e) {
			String error = 'Cannot process request. Problem with invalid criteria: ' + c.Name + ' ' + e.getMessage()+'\n';
			error += e.getStackTraceString();
			System.debug((e.getMessage()).center('EXCEPTION'.length() + 10, '*'));
			newObject.addError(error);
		}
		//System.debug('*************criteria**************' + c);
		//System.debug('*************returnValue**************' + returnValue);
		return returnValue;
	}
}