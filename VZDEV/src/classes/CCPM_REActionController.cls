/**
*@name          CCPM_REActionController 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          01/11/2018
*@description   This is a controller or class
*@Class         CCPM_REActionController
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    01/11/2017   Initial Implementation.
*/
public with sharing class CCPM_REActionController  {
    
    public ActionPackage actionPackage{get;set;}
    public Map<String, Schema.sObjectField> mapTargetFields = new Map<String, Schema.sObjectField>();
    public Integer intACRowNum{get;set;}
    public Integer intRARowNum{get;set;}
    public boolean boolCloneRecord {get;set;}
    public String strFieldAPIName{get;set;}
    public String strMergeRec{get;set;}
    public String strActionRecordName{get;set;}
    public String actionID = '';
    
    public CCPM_REActionController(){
        
        boolCloneRecord = false;
        strActionRecordName = '';
        strMergeRec = 'Winner';
        try{
            actionPackage = new ActionPackage();
            actionID =ApexPages.CurrentPage().getparameters().get('actionid'); 
            if(ApexPages.CurrentPage().getparameters().get('clone') == '1'){boolCloneRecord = true;}
            CCPM_Action__c objAction = new CCPM_Action__c();
            if(actionID != ''){
                objAction = [Select CCPM_startDate__c, CCPM_actionObject__c, Name, LastModifiedDate, LastModifiedById, Id,CCPM_masterObject__c, 
                        CCPM_endDate__c, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedBy.Name, CCPM_active__c, CCPM_description__c,CCPM_type__c,
                        CCPM_actionNumber__c, RecordType.Name, CCPM_relatedObject__c,CCPM_relatedObjectAction__c,
                        (Select Id, CCPM_order__c, CCPM_Action__c, CCPM_active__c, CCPM_fieldAPIName__c, CCPM_fieldValue__c, CCPM_variableName__c, CCPM_mergeCopy__c, CCPM_mergeCopyIfNullOrBlank__c
                         From CCPM_ActionComponents__r ORDER BY CCPM_order__c),
                        (Select Id,CCPM_rule__c,CCPM_active__c,CCPM_rule__r.Name From CCPM_RERuleActions__r)
                        From CCPM_Action__c WHERE id =:actionID]; 
                actionPackage = new ActionPackage(objAction, objAction.CCPM_ActionComponents__r, objAction.CCPM_RERuleActions__r);
                strActionRecordName = objAction.RecordType.Name;
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid ActionID. <br/>');
            	ApexPages.addMessage(myMsg);
            }
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid ActionID. <br/>'+e.getMessage());
            ApexPages.addMessage(myMsg);
            actionPackage.objAction.CCPM_actionObject__c = getSObjectTypes().get(0).getLabel();
            actionPackage.objAction.CCPM_masterObject__c = getSObjectTypes().get(0).getLabel();
        }
    }
    
    public List<SelectOption> getSObjectTypes(){
        List<SelectOption> sObjectTypes = new List<SelectOption>();
        for(Schema.SObjectType item : ProcessInstance.TargetObjectId.getDescribe().getReferenceTo())  
        {  
            //Excluding custom setting objects  
            if(!item.getDescribe().CustomSetting && item.getDescribe().isUpdateable())
            {  
                //Adding to list  
                sObjectTypes.add(new SelectOption(item.getDescribe().getLocalName() , item.getDescribe().getLabel() ));  
            }  
        }
        sObjectTypes.sort();
        return sObjectTypes;        
    }
    
    public List<SelectOption> getACFieldTypes(){
        List<SelectOption> fieldTypeList= new List<SelectOption>{new SelectOption('Variable','--Variable--')};
        List<String> strFieldValues = new List<String>();
        if(String.isNotBlank(actionPackage.objAction.CCPM_actionObject__c)){
        	mapTargetFields = Schema.getGlobalDescribe().get(actionPackage.objAction.CCPM_actionObject__c).getDescribe().fields.getMap();
	        for(String key : mapTargetFields.KeySet()){
                if(mapTargetFields.get(key).getDescribe().isUpdateable()){
                    strFieldValues.add(mapTargetFields.get(key).getDescribe().getLabel()+';'+mapTargetFields.get(key).getDescribe().getLocalName());
                }
	        }
	        strFieldValues.sort();
	        for(String strFV: strFieldValues){
	        	String[] arrStr = strFV.split(';');
	        	fieldTypeList.add(new SelectOption(arrStr[1], arrStr[0]));
	        }
        }
        return fieldTypeList;
    }
    
    public List<SelectOption> getFieldTypes(){
        List<SelectOption> fieldTypeList= new List<SelectOption>();
        
        System.debug('***************'+actionPackage.objAction.CCPM_masterObject__c);
        Map<String, Schema.sObjectField> mapTargetFieldsdisp = Schema.getGlobalDescribe().get(actionPackage.objAction.CCPM_masterObject__c).getDescribe().fields.getMap();
        List<String> strFieldValues = new List<String>();
        for(String key : mapTargetFieldsdisp.KeySet()){
        	strFieldValues.add(mapTargetFieldsdisp.get(key).getDescribe().getLabel()+';'+mapTargetFieldsdisp.get(key).getDescribe().getLocalName()+';'+mapTargetFieldsdisp.get(key).getDescribe().getType());
        }
        strFieldValues.sort();
        for(String strFV: strFieldValues){
        	String[] arrStr = strFV.split(';');
            if(strMergeRec == 'Winner'){
                fieldTypeList.add(new SelectOption('<w>'+arrStr[1]+'</w> (Field Type: '+arrStr[2]+')', arrStr[0]));
            }
            else if(strMergeRec == 'Loser')
        	fieldTypeList.add(new SelectOption('<l>'+arrStr[1]+'</l> (Field Type: '+arrStr[2]+')', arrStr[0]));
        }
        return fieldTypeList;
        
    }
    
    public void removeVCRow(){
        CCPM_ActionComponent__c objActToRemove = null;
        try{
            if(actionPackage.mapActionComponents.get(intACRowNum).id != null){
                objActToRemove = actionPackage.mapActionComponents.get(intACRowNum);
                delete objActToRemove;
            }
            actionPackage.mapActionComponents.remove(intACRowNum);
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Delete Row. Error: '+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference save(){
        List<sObject> lstObjectsToInsert = new List<sobject>();
        List<sObject> lstObjectsToUpdate = new List<sobject>();
        if(boolCloneRecord){
            ActionPackage cloneActionPackage = actionPackage;
            cloneActionPackage.objAction.id = null;
            for(CCPM_ActionComponent__c objAC: cloneActionPackage.mapActionComponents.values()){
                objAC.id=null;
            }
            actionPackage = cloneActionPackage;
        }
        try{
            upsert actionPackage.objAction;   
            if(actionPackage.mapActionComponents.size() > 0){
                for(CCPM_ActionComponent__c objAC : actionPackage.mapActionComponents.values()){
                    
                    if(objAC.Id == null){ 
                        objAC.CCPM_Action__c = actionPackage.objAction.id;
                        lstObjectsToInsert.add(objAC);}
                    else{lstObjectsToUpdate.add(objAC);}
                }   
            }
            if(lstObjectsToInsert.size() > 0){ insert lstObjectsToInsert;}
            if(lstObjectsToUpdate.size() > 0){ update lstObjectsToUpdate;}
            PageReference viewPage = new PageReference('/apex/CCPM_REActionViewPage?actionid='+actionPackage.objAction.id);
            viewPage.setRedirect(true);
            return viewPage;
        }
        catch(Exception e){
            String error = 'ERROR in saving values \n';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,error+e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    public PageReference edit(){
        PageReference viewPage = new PageReference('/apex/CCPM_REActionEditPage?actionid='+actionPackage.objAction.id);
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    public PageReference cancel(){
        PageReference viewPage = new PageReference('/apex/CCPM_REActionViewPage?actionID='+actionID);
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    public PageReference clonevaluePackage(){
        PageReference viewPage = new PageReference('/apex/CCPM_REActionEditPage?actionID='+actionPackage.objAction.id+'&clone=1');
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    /*Name: ActionPackage
    *Description: This is a package class for Value. 
    * Date:        - Case#/Project:            - Developer/Company                            - Description
    * ------------------------------------------------------------------------------------------------------------------------- *
    * 01/28/2015   - Fee Rule Engine           - Bharath Ammanamanchi, Deloitte                  - Initial Implementation.
    */
    public class ActionPackage{
        public CCPM_Action__c objAction{get; set;}
        public Map<Integer, CCPM_ActionComponent__c> mapActionComponents{get;set;}
        public Map<Integer, CCPM_RuleAction__c> mapRuleAction{get;set;}
        Integer intACRowNum = 0;
        Integer intRARowNum = 0;
        
        public ActionPackage(CCPM_Action__c objAction, List<CCPM_ActionComponent__c> lstActComp, List<CCPM_RuleAction__c> lstRuleAct){
            
            this.objAction = objAction;
            mapActionComponents = new Map<Integer, CCPM_ActionComponent__c>();
            for(CCPM_ActionComponent__c objAC : lstActComp){
            	objAC.CCPM_order__c = intACRowNum+1;
                mapActionComponents.put(intACRowNum, objAC);
                intACRowNum++;
            }
            mapRuleAction = new Map<Integer, CCPM_RuleAction__c>();
            for(CCPM_RuleAction__c rv : lstRuleAct){
                mapRuleAction.put(intRARowNum, rv);
                intRARowNum++;
            }
            
        }
        
        public ActionPackage(){
            objAction= new CCPM_Action__c(CCPM_active__c=true, CCPM_actionObject__c = 'Lead', CCPM_masterObject__c = 'Lead');
            mapActionComponents = new Map<Integer, CCPM_ActionComponent__c>();
            addACRow();
            mapRuleAction = new Map<Integer, CCPM_RuleAction__c>();
            
        }
        
        public void addACRow(){
            mapActionComponents.put(intACRowNum,new CCPM_ActionComponent__c(CCPM_active__c=true, CCPM_order__c=intACRowNum+1));
            intACRowNum++;
        }
        
        public void addRARow(){
            mapRuleAction.put(intRARowNum, new CCPM_RuleAction__c(CCPM_active__c=true));
            intRARowNum++;
        }
        
    }
}