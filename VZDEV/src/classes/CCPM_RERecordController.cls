/**
*@name          CCPM_RERecordController 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          01/25/2018
*@description   This is a controller or class
*@Class         CCPM_RERecordController
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    01/25/2018   Initial Implementation.
*/
public with sharing class CCPM_RERecordController  {
    
    public RERecordPackage recordPackage{get;set;}
    public Map<String, Schema.sObjectField> mapTargetFields = new Map<String, Schema.sObjectField>();
    public Integer intCRowNum{get;set;}
    public boolean boolCloneRecord {get;set;}
    public String strRecordID{get;set;}
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  Constructor
	@param        N/A
	@return       N/A
	*/ 
    public CCPM_RERecordController(){
    	strRecordID = '';
        boolCloneRecord = false;
        try{
            recordPackage = new RERecordPackage();
            strRecordID =ApexPages.CurrentPage().getparameters().get('recordid'); 
            if(ApexPages.CurrentPage().getparameters().get('clone') == '1'){boolCloneRecord = true;}
            CCPM_RERecord__c objRecord = new CCPM_RERecord__c();
            if(strRecordID != ''){
                objRecord = [Select id, Name, CCPM_primaryObject__c, CCPM_active__c, CreatedDate,
                        CreatedById, CreatedBy.Name, LastModifiedBy.Name, LastModifiedDate, LastModifiedById,
                        (Select Id,CCPM_fieldName__c,CCPM_operator__c,CCPM_valueText__c,CCPM_active__c,CCPM_fieldType__c,
                        CCPM_valueDouble__c,CCPM_valueDate__c From CCPM_RECriterias__r)
                        From CCPM_RERecord__c WHERE id =:strRecordID];
                recordPackage = new RERecordPackage(objRecord, objRecord.CCPM_RECriterias__r);
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid RecordID. <br/>');
            	ApexPages.addMessage(myMsg);
            }
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid RecordID. <br/>'+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference save(){
        List<sObject> lstObjToInsert = new List<sobject>();
        List<sObject> lstObjToUpdate = new List<sobject>();
        if(boolCloneRecord){
            RERecordPackage clonerulePackage = recordPackage;
            clonerulePackage.objRecord.id = null;
            for(CCPM_Criteria__c objCri: clonerulePackage.mapCriteria.values()){
                objCri.id=null;
            }
            recordPackage = clonerulePackage;
        }
        try{
            upsert recordPackage.objRecord; 
            if(recordPackage.mapCriteria.size() > 0){
                for(CCPM_Criteria__c objCri : recordPackage.mapCriteria.values()){
                    if(objCri.CCPM_valueText__c != null && objCri.CCPM_valueText__c.contains('<Today>')){
                        objCri.CCPM_valueDate__c = null;
                    }
                    if(objCri.Id == null){ 
                        objCri.CCPM_Record__c = recordPackage.objRecord.id;
                        lstObjToInsert.add(objCri);
                    }
                    else{lstObjToUpdate.add(objCri);}
                }   
            }
            if(lstObjToInsert.size() > 0){ insert lstObjToInsert;}
            if(lstObjToUpdate.size() > 0){ update lstObjToUpdate;}
            PageReference viewPage = new PageReference('/apex/CCPM_RERecordViewPage?recordid='+recordPackage.objRecord.id);
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
        if(String.isNotBlank(recordPackage.objRecord.CCPM_primaryObject__c)){
        	mapTargetFields = Schema.getGlobalDescribe().get(recordPackage.objRecord.CCPM_primaryObject__c).getDescribe().fields.getMap();
	        for(String key : mapTargetFields.KeySet()){
	            fieldTypeList.add(new SelectOption(mapTargetFields.get(key)+'', mapTargetFields.get(key).getDescribe().getLabel()+''));
	        }
	        fieldTypeList.sort();
        }
        return fieldTypeList;
    }
    
    public void setFieldType(){
        try{
            Schema.DisplayType ftype = mapTargetFields.get(recordPackage.mapCriteria.get(intCRowNum).CCPM_fieldName__c).getDescribe().getType();
            System.debug('**********ftype *************** '+ftype);
            if(ftype ==  Schema.DisplayType.DATE || ftype ==  Schema.DisplayType.DATETIME){
                recordPackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Date';
            }
            else if(ftype ==  Schema.DisplayType.INTEGER || ftype ==  Schema.DisplayType.DOUBLE || ftype ==  Schema.DisplayType.PERCENT || ftype ==  Schema.DisplayType.CURRENCY){
                recordPackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Double';
            }
            else if(ftype ==  Schema.DisplayType.BOOLEAN){
                recordPackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Boolean';
            }
            else {
                recordPackage.mapCriteria.get(intCRowNum).CCPM_fieldType__c = 'Text';
            }
            System.debug('*****************recordPackage.mapCriteria.get(intCRowNum)************'+recordPackage.mapCriteria.get(intCRowNum));
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Delete Row. Error: '+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void removeCriteriaRow(){
        CCPM_Criteria__c objCriToRemove = null;
        try{
            if(recordPackage.mapCriteria.get(intCRowNum).id != null){
                objCriToRemove = recordPackage.mapCriteria.get(intCRowNum);
                delete objCriToRemove;
            }
            recordPackage.mapCriteria.remove(intCRowNum);
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Delete Row. Error: '+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference edit(){
        PageReference viewPage = new PageReference('/apex/CCPM_RERecordEditPage?recordid='+recordPackage.objRecord.id);
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    public PageReference cloneRecordPackage(){
        PageReference viewPage = new PageReference('/apex/CCPM_RERecordEditPage?recordid='+recordPackage.objRecord.id+'&clone=1');
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    
    
    /**
	*@name          RERecordPackage 
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
    public class RERecordPackage{
        public CCPM_RERecord__c objRecord{get; set;}
        public Map<Integer, CCPM_Criteria__c> mapCriteria{get;set;}
        Integer intCRowNum = 0;
        
        public RERecordPackage(CCPM_RERecord__c objRecord, List<CCPM_Criteria__c> lstcriteria){
            
            this.objRecord = objRecord;
            mapCriteria = new Map<Integer, CCPM_Criteria__c>();
            for(CCPM_Criteria__c objC : lstcriteria){
                mapCriteria.put(intCRowNum, objC);
                intCRowNum++;
            }
        }
        
        public RERecordPackage(){
            
            objRecord= new CCPM_RERecord__c(CCPM_active__c=true);
            mapCriteria = new Map<Integer, CCPM_Criteria__c>();
        }
        
        public void addCriteriaRow(){
            mapCriteria.put(intCRowNum, new CCPM_Criteria__c(CCPM_fieldName__c='Id',CCPM_active__c=true,CCPM_fieldType__c='Text', CCPM_operator__c='Equals'));
            intCRowNum++;
        }
    }
}