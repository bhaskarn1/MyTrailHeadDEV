public class CCPM_REMergeTestDataFactory {

    /**
@author        Paras Shah (Deloitte)
@description   This method is used to create records
@param         ???? 
@return        ????
*/
    public Static CCPM_RERecord__c createRecords(String strUniqueRERecordName){
        CCPM_RERecord__c objRERecord = new CCPM_RERecord__c();
        objRERecord.CCPM_active__c = true;
        objRERecord.CCPM_primaryObject__c = 'Lead';
        objRERecord.CCPM_recordNameUnique__c = strUniqueRERecordName;
        //objRERecord.CCPM_RE_Record_ID__c = 
        
        return objRERecord;

    }    
    
    /**
@author        Paras Shah (Deloitte)
@description   This method is used to create rulese
@param         ???? 
@return        ????
*/
    public Static CCPM_Rule__c createRules(Id idExistingRERecord, Id idNewRecord,String strMergeUniqueField,String strWinningRecord,String strRERuleId){
        
        CCPM_Rule__c objRERuleRecord = new CCPM_Rule__c();
        objRERuleRecord.Name = 'Name';
        objRERuleRecord.CCPM_active__c = true;
        objRERuleRecord.CCPM_description__c = 'Sample Description';
        objRERuleRecord.CCPM_endDate__c = system.today();
        objRERuleRecord.CCPM_existingRecord__c = idExistingRERecord;
        objRERuleRecord.CCPM_mergeUniqueField__c = strMergeUniqueField;
        objRERuleRecord.CCPM_newRecord__c = idNewRecord;
        objRERuleRecord.CCPM_primaryObject__c = 'Lead';
        objRERuleRecord.CCPM_RE_Rule_ID__c = '999';
        objRERuleRecord.CCPM_startDate__c = system.today();
        objRERuleRecord.CCPM_winningRecord__c = strWinningRecord;
		
        return objRERuleRecord;
    }    
    
    /**
@author        Paras Shah (Deloitte)
@description   This method is used to create Action
@param         ???? 
@return        ????
*/
    public Static CCPM_Action__c createAction(String strActionID,String strRelatedObjectAction){
        
        CCPM_Action__c objAction = new CCPM_Action__c();
        objAction.Name = 'Name';
        objAction.CCPM_actionObject__c = 'Lead';
		objAction.CCPM_active__c = true;
		objAction.CCPM_description__c = 'Sample Decscription';
        objAction.CCPM_endDate__c = system.today();
        objAction.CCPM_masterObject__c = 'Lead';
        objAction.CCPM_RE_Action_ID__c = strActionID;
        objAction.CCPM_relatedObject__c = 'Task';
        objAction.CCPM_relatedObjectAction__c = strRelatedObjectAction;
        objAction.CCPM_startDate__c = system.today();
        objAction.CCPM_type__c = 'Insert';
        
        return objAction;
    }        

    /**
@author        Paras Shah (Deloitte)
@description   This method is used to create Action
@param         ???? 
@return        ????
*/
    public Static CCPM_ActionComponent__c createActionComponent(Id idActionID,String strFieldAPIName,String strActionComponentId){
        
        CCPM_ActionComponent__c objActionComponent = new CCPM_ActionComponent__c();
        objActionComponent.CCPM_Action__c = idActionID;
        objActionComponent.CCPM_active__c = true;
        objActionComponent.CCPM_fieldAPIName__c = strFieldAPIName;
		objActionComponent.CCPM_fieldValue__c = 'Sample Value';        
        objActionComponent.CCPM_mergeCopy__c = true;
        objActionComponent.CCPM_mergeCopyIfNullOrBlank__c = true;
        objActionComponent.CCPM_order__c = 123;
        objActionComponent.CCPM_RE_Action_Component_ID__c = strActionComponentId;
        objActionComponent.CCPM_variableName__c = 'Sample Name';
        
        return objActionComponent;
    }       
    
    /**
@author        Paras Shah (Deloitte)
@description   This method is used to create Action
@param         ???? 
@return        ????
*/
    public Static CCPM_Criteria__c createRuleCriteria(String strFieldType,String strOperator,Id idRERecord,id idRERuleRecord){
        
        CCPM_Criteria__c objCriteria = new CCPM_Criteria__c();
        
        objCriteria.CCPM_active__c = true;
        objCriteria.CCPM_fieldName__c = 'Sample field name';
        objCriteria.CCPM_fieldType__c = strFieldType;
        objCriteria.CCPM_operator__c = strOperator;
        objCriteria.CCPM_Record__c = idRERecord;
        objCriteria.CCPM_RE_Criteria_ID__c = '9999';
        objCriteria.CCPM_rule__c = idRERuleRecord;
        objCriteria.CCPM_valueDate__c = system.today();
        objCriteria.CCPM_valueDouble__c = 10.00;
        objCriteria.CCPM_valueText__c = 'Value Text';
        
        return objCriteria;
    }       
    
    /**
@author        Paras Shah (Deloitte)
@description   This method is used to create Action
@param         ???? 
@return        ????
*/
    public Static CCPM_RuleAction__c createRuleAction(Id idAction,String strRuleActionID,Id idRule){
        
        CCPM_RuleAction__c objRuleAction = new CCPM_RuleAction__c();
        objRuleAction.CCPM_action__c = idAction;
        objRuleAction.CCPM_active__c = true;
        objRuleAction.CCPM_RE_Rule_Action_ID__c = strRuleActionID;
        objRuleAction.CCPM_rule__c = idRule;
        
        return objRuleAction;
    }         
    
}