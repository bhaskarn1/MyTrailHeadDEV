/**
*@name          CCPM_RERuleController 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          01/10/2018
*@description   This is a controller for CCPM_RERuleviewPage
*@testClass     CCPM_RERuleController
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    01/10/2018   Initial Implementation.
*/
public with sharing class CCPM_RERuleController  {
    
    public RERulePackage rulePackage{get;set;}
    public Map<String, Schema.sObjectField> mapTargetFields = new Map<String, Schema.sObjectField>();
    public Integer intCRowNum{get;set;}
    public Integer intRARowNum{get;set;}
    public boolean boolCloneRecord {get;set;}
    public String strRuleRecordType {get;set;}
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  Constructor
	@param        N/A
	@return       N/A
	*/ 
    public CCPM_RERuleController(){
    	String strRuleID = '';
        boolCloneRecord = false;
        strRuleRecordType = '';
        try{
            rulePackage = new RERulePackage();
            strRuleID =ApexPages.CurrentPage().getparameters().get('ruleid'); 
            if(ApexPages.CurrentPage().getparameters().get('clone') == '1'){boolCloneRecord = true;}
            CCPM_Rule__c objrule = new CCPM_Rule__c();
            if(strRuleID != ''){
                objrule = [Select id, Name, CCPM_primaryObject__c, CCPM_startDate__c, CCPM_endDate__c, CCPM_active__c, CreatedDate, RecordType.Name, 
                        CreatedById, CreatedBy.Name, LastModifiedBy.Name, LastModifiedDate, LastModifiedById, CCPM_description__c,
                        CCPM_existingRecord__c,CCPM_newRecord__c, CCPM_winningRecord__c, 
                        (Select Id,CCPM_fieldName__c,CCPM_operator__c,CCPM_valueText__c,CCPM_active__c,CCPM_fieldType__c,CCPM_valueDouble__c,CCPM_valueDate__c From CCPM_Criterias__r),
                        (Select Id,CCPM_action__c,CCPM_active__c,CCPM_Action__r.Name From CCPM_RERuleActions__r) 
                        From CCPM_Rule__c WHERE id =:strRuleID];
                rulePackage = new RERulePackage(objrule, objrule.CCPM_Criterias__r, objrule.CCPM_RERuleActions__r);
                strRuleRecordType = objrule.RecordType.Name;
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid RuleID. <br/>');
            	ApexPages.addMessage(myMsg);
            }
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid RuleID. <br/>'+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference save(){
        List<sObject> lstObjToInsert = new List<sobject>();
        List<sObject> lstObjToUpdate = new List<sobject>();
        if(boolCloneRecord){
            RERulePackage clonerulePackage = rulePackage;
            clonerulePackage.objrule.id = null;
            for(CCPM_Criteria__c objCri: clonerulePackage.mapCriteria.values()){
                objCri.id=null;
            }
            for(CCPM_RuleAction__c objRA: clonerulePackage.mapRuleAction.values()){
                objRA.id=null;
            }
            rulePackage = clonerulePackage;
        }
        try{
            upsert rulePackage.objrule; 
            if(rulePackage.mapCriteria.size() > 0){
                for(CCPM_Criteria__c objCri : rulePackage.mapCriteria.values()){
                    if(objCri.CCPM_valueText__c != null && objCri.CCPM_valueText__c.contains('<Today>')){
                        objCri.CCPM_valueDate__c = null;
                    }
                    if(objCri.Id == null){ 
                        objCri.CCPM_rule__c = rulePackage.objrule.id;
                        lstObjToInsert.add(objCri);
                    }
                    else{lstObjToUpdate.add(objCri);}
                }   
            }
            if(rulePackage.mapRuleAction.size() > 0){
                for(CCPM_RuleAction__c objRA : rulePackage.mapRuleAction.values()){
                    if(objRA.Id == null){ 
                        objRA.CCPM_rule__c = rulePackage.objrule.id;
                        lstObjToInsert.add(objRA);
                    }
                    else{lstObjToUpdate.add(objRA);}
                }
            }
            if(lstObjToInsert.size() > 0){ insert lstObjToInsert;}
            if(lstObjToUpdate.size() > 0){ update lstObjToUpdate;}
            PageReference viewPage = new PageReference('/apex/CCPM_RERuleViewPage?ruleid='+rulePackage.objrule.id);
            viewPage.setRedirect(true);
            return viewPage;
        }
        catch(Exception e){
            String error = 'ERROR in saving. \n';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error+e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    public List<SelectOption> getFieldTypes(){
        List<SelectOption> fieldTypeList= new List<SelectOption>();
        if(String.isNotBlank(rulePackage.objrule.CCPM_primaryObject__c)){
        	mapTargetFields = Schema.getGlobalDescribe().get(rulePackage.objrule.CCPM_primaryObject__c).getDescribe().fields.getMap();
	        for(String key : mapTargetFields.KeySet()){
	            fieldTypeList.add(new SelectOption(mapTargetFields.get(key)+'', mapTargetFields.get(key).getDescribe().getLabel()+''));
	        }
	        fieldTypeList.sort();
        }
        return fieldTypeList;
    }
    
    public void setFieldType(){
        try{
            Schema.DisplayType ftype = mapTargetFields.get(rulePackage.mapCriteria.get(intCRowNum).CCPM_fieldName__c).getDescribe().getType();
            System.debug('**********ftype *************** '+ftype);
            if(ftype ==  Schema.DisplayType.DATE || ftype ==  Schema.DisplayType.DATETIME){
                rulePackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Date';
            }
            else if(ftype ==  Schema.DisplayType.INTEGER || ftype ==  Schema.DisplayType.DOUBLE || ftype ==  Schema.DisplayType.PERCENT || ftype ==  Schema.DisplayType.CURRENCY){
                rulePackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Double';
            }
            else if(ftype ==  Schema.DisplayType.BOOLEAN){
                rulePackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Boolean';
            }
            else {
                rulePackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Text';
            }
            System.debug('*****************rulePackage.mapCriteria.get(intCRowNum)************'+rulePackage.mapCriteria.get(intCRowNum));
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Delete Row. Error: '+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void removeCriteriaRow(){
        CCPM_Criteria__c objCriToRemove = null;
        try{
            if(rulePackage.mapCriteria.get(intCRowNum).id != null){
                objCriToRemove = rulePackage.mapCriteria.get(intCRowNum);
                delete objCriToRemove;
            }
            rulePackage.mapCriteria.remove(intCRowNum);
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Delete Row. Error: '+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void removeRuleActionRow(){
        CCPM_RuleAction__c objRAToRemove = null;
        try{
            if(rulePackage.mapRuleAction.get(intRARowNum).id != null){
                objRAToRemove = rulePackage.mapRuleAction.get(intRARowNum);
                delete objRAToRemove;
            }
            rulePackage.mapRuleAction.remove(intRARowNum);
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Delete Row. Error: '+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference edit(){
        PageReference viewPage = new PageReference('/apex/CCPM_RERuleEditPage?ruleid='+rulePackage.objrule.id);
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    public PageReference cloneRulePackage(){
        PageReference viewPage = new PageReference('/apex/CCPM_RERuleEditPage?ruleid='+rulePackage.objrule.id+'&clone=1');
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    
    
    /**
	*@name          RERulePackage 
	*@author        Bharath Ammanamanchi (Deloitte)
	*@date          01/10/2018
	*@description   This is a wrapper class
	*@testClass     
	Modification    Log:
	------------------------------------------------------------------------------------
	Developer                          Date         Description
	------------------------------------------------------------------------------------
	Bharath Ammanamanchi (Deloitte)    01/10/2018   Initial Implementation.
	*/
    public class RERulePackage{
        public CCPM_Rule__c objRule{get; set;}
        public Map<Integer, CCPM_Criteria__c> mapCriteria{get;set;}
        public Map<Integer, CCPM_RuleAction__c> mapRuleAction{get;set;} 
        Integer intCRowNum = 0;
        Integer intRARowNum = 0;
        
        public RERulePackage(CCPM_Rule__c objRule, List<CCPM_Criteria__c> lstcriteria, List<CCPM_RuleAction__c> lstRuleAction){
            
            this.objRule = objRule;
            mapCriteria = new Map<Integer, CCPM_Criteria__c>();
            for(CCPM_Criteria__c objC : lstcriteria){
                mapCriteria.put(intCRowNum, objC);
                intCRowNum++;
            }
            
            mapRuleAction = new Map<Integer, CCPM_RuleAction__c>();
            for(CCPM_RuleAction__c objRA : lstRuleAction){
                mapRuleAction.put(intRARowNum, objRA);
                intRARowNum++;
            }
            
        }
        
        public RERulePackage(){
            
            objRule= new CCPM_Rule__c(CCPM_active__c=true);
            mapCriteria = new Map<Integer, CCPM_Criteria__c>();
            mapRuleAction = new Map<Integer, CCPM_RuleAction__c>();
            
        }
        
        public void addCriteriaRow(){
            mapCriteria.put(intCRowNum, new CCPM_Criteria__c(CCPM_fieldName__c='Id',CCPM_active__c=true,CCPM_fieldType__c='Text', CCPM_operator__c='Equals'));
            intCRowNum++;
        }
        
        public void addRuleActionRow(){
            mapRuleAction.put(intRARowNum, new CCPM_RuleAction__c(CCPM_active__c=true));
            intRARowNum++;
        }
    }
}