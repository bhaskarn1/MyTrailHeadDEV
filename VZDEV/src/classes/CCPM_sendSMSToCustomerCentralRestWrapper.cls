/**
*@name          CCPM_sendSMSToCustomerCentralWrapper
*@author        Tanweer Maredia (Deloitte)
*@date          05/18/2017
@description    Creating a response body which have list of activity and lead object attributes
@testClass      CCPM_sendSMSToCustomerCentralRestTest
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Tanweer Maredia(Deloitte)    05/19/2017                          Original Version
*/

/*
 * Wrapper support class calls from getCustomerInteractions method to format all task and 
 * lead attribute naming convention in Json Response body
 */

global with sharing class CCPM_sendSMSToCustomerCentralRestWrapper {
    
    public String ActivityId;
    public String LeadId;
    public String AccountNumber;
    public String CustomerName;
    public String MTN;
    public String Subject;
    public String Comments;
    public String Type;
    public String CommunicationDirection;
    Public Datetime LastModifiedDate;
    public Datetime CreatedDate;
    
    //creating a response wrapper that calling from setSMStoCustomerCentral with list of task and accountnumber to generate responsebody
    public List<CCPM_sendSMSToCustomerCentralRestWrapper> setSMStoCustomerCentralResponse(List<Task> lstTaskResult, lead leadEncrptingAccountNumberAndMTN){
        List<CCPM_sendSMSToCustomerCentralRestWrapper> wrapActivityobjectlist = new List<CCPM_sendSMSToCustomerCentralRestWrapper>();
       
        if (lstTaskResult.size()>0){
            
            //looping through task query result assigned it and add in responsebody
            for( Task tsk : lstTaskResult){
                CCPM_sendSMSToCustomerCentralRestWrapper wrapActivity = new CCPM_sendSMSToCustomerCentralRestWrapper();
                wrapActivity.ActivityId =tsk.id;
                wrapActivity.AccountNumber = leadEncrptingAccountNumberAndMTN.CCPM_accountNumber__c;
                wrapActivity.MTN = leadEncrptingAccountNumberAndMTN.CCPM_mobileNumber__c;
                wrapActivity.Subject = tsk.Subject;
                wrapActivity.Comments = tsk.Description;
                wrapActivity.Type = tsk.Type;
                wrapActivity.CustomerName = tsk.who.name;
                wrapActivity.leadId = tsk.who.id;
                wrapActivity.CommunicationDirection = tsk.CCPM_communicationDirection__c;
                wrapActivity.LastModifiedDate = tsk.LastModifiedDate;
                wrapActivity.CreatedDate = tsk.CreatedDate;
               
                wrapActivityobjectlist.add(wrapActivity);
            }            
        }else{
           System.debug('Wrapper Activity was not found');
        }
        return wrapActivityobjectlist;
    }
 
}