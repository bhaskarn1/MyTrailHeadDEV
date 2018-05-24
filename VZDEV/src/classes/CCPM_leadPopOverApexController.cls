/**
*@name          CCPM_leadsAwaitingChildApexController
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          12/11/2017
*@description   For "CCPM_leadPopOverApexController" Component in UI
Modification    Log:
------------------------------------------------------------------------------------
Developer                      				  Date               Description
------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)             12/11/2017         Original Version   
Paras Shah (Deloitte)						 01/09/2017			Added 'with sharing' as part of Spring '18 release changes
*/
public with sharing class CCPM_leadPopOverApexController {
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   This Method decides the Live text number to display
*@return        Void(None)
*/
    @AuraEnabled
    public static CCPM_leadPopOverWrapperLead sendLiveTextNumber(Lead objLead)
    {	
        String strParentLiveTextNumber='';
        if(objLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_leadCustomerCartRT).getRecordTypeId())
        {	
            System.debug('Inside first if->');
            strParentLiveTextNumber=Label.CCPM_liveTextPhoneNumber;
           // CCPM_leadPopOverWrapperLead objleadPopOverWrapper = new CCPM_leadPopOverWrapperLead(objLead,Label.CCPM_liveTextPhoneNumber);
            
        }
        else if(objLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.CCPM_LeadProspectRecordType).getRecordTypeId())
        {	
            System.debug('Inside first if->');
            strParentLiveTextNumber=Label.CCPM_liveTextNumberNonVerizon;            
            
        }
        CCPM_leadPopOverWrapperLead objleadPopOverWrapper = new CCPM_leadPopOverWrapperLead(objLead,strParentLiveTextNumber); 
        System.debug('objleadPopOverWrapper->'+objleadPopOverWrapper);
        return objleadPopOverWrapper;
    }
    
    public class CCPM_leadPopOverWrapperLead{
        @AuraEnabled public List<CCPM_leadPopOverWrapperTask> lstWrapperTask{get;set;}
        @AuraEnabled public Lead objLead{get;set;}
        @AuraEnabled public string strliveTextNumber{get;set;}
        
        public CCPM_leadPopOverWrapperLead(Lead objLeadin,string strliveTextNumberin){
            System.debug('Inside Constructor->');
            lstWrapperTask=new List<CCPM_leadPopOverWrapperTask>();
            objLead = new Lead();
            objLead = objLeadin;
            
            list<Task> lstTask = new list<Task>();
            lstTask=[select Id,Description,CreatedDate,CCPM_communicationDirection__c from task where recordtype.name =:CCPM_staticConstants.strInteractionHistoryRecordType and whoid=:objLead.id and (CCPM_SMSMessageType__c in :CCPM_utility.setsmsTypeOnTask or CCPM_SMSMessageType__c='' or CCPM_communicationDirection__c= :CCPM_staticConstants.strTaskCommunicationDirection) order by createddate desc];
            list<CCPM_leadPopOverWrapperTask> lstTaskWrapper = new list<CCPM_leadPopOverWrapperTask>();
            for(Task objTask : lstTask)
            {	
                System.debug('Inside For loop');
                CCPM_leadPopOverWrapperTask wrapperTaskSingle = new CCPM_leadPopOverWrapperTask();
                wrapperTaskSingle.objTask=objTask;
                if(objTask.CCPM_communicationDirection__c==CCPM_staticConstants.strTaskCommunicationOutbound)
                {
                    
                    wrapperTaskSingle.strToNumber=objLead.CCPM_mobileNumber__c;
                    wrapperTaskSingle.strFromNumber=strliveTextNumberin;
                }
                else if(objTask.CCPM_communicationDirection__c==CCPM_staticConstants.strTaskCommunicationDirection)
                {
                    wrapperTaskSingle.strToNumber=strliveTextNumberin;
                    wrapperTaskSingle.strFromNumber=objLead.CCPM_mobileNumber__c;
                    
                }
                lstTaskWrapper.add(wrapperTaskSingle);
                lstWrapperTask=lstTaskWrapper;
                System.debug('wrapperTaskSingle->'+lstWrapperTask);
            }
        }
    }
    
    public class CCPM_leadPopOverWrapperTask{
        @AuraEnabled public Task objTask{get;set;}
        @AuraEnabled public string strToNumber{get;set;}
        @AuraEnabled public string strFromNumber{get;set;}
    }
    
}