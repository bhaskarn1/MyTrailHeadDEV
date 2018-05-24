/**
*@name          CCPM_SMSInteractionHistoryController
*@author        Paras Shah (Deloitte)
*@date          01/24/2016
*@description   For SMS Interaction history
*@testClass     CCPM_SMSInteractionHistoryControllerTest

Modification    Log:
------------------------------------------------------------------------------------
Developer                        Date               Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)             01/24/2017         Original Version
Paras Shah(Deloitte)             03/28/2017         Fix to Ticket - TKT-000109
Paras Shah(Deloitte)             05/03/2017         Changes for SMS Interaction Limit to 30    
Paras Shah(Deloitte)			 01/09/2017			Added 'with sharing' as part of Spring '18 release changes
*/

public with sharing class CCPM_SMSInteractionHistoryController {
    /**
    *@author        Paras Shah (Deloitte)
    *@description   Constructor for the CCPM_SMSInteractionHistoryController class
    *@return        Void(None)
    */ 

    public CCPM_SMSInteractionHistoryController() {

    }
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method is used to get the Lead Phone number to display in the message history
    *@return        Lead Phone number
    */ 
    @AuraEnabled
    public static String getLeadPhone (Id idRecord) {
        //Query to pull Lead Phone number to display in the message history
        if (idRecord != null) { 
            
            String strLeadPhone = ' ';
            String queryLeadPhone = 'SELECT Id,CCPM_mobileNumber__c  from Lead where Id = ' + '\'' + idRecord + '\'' + ' LIMIT 1';
            List<Lead> sObjQueryLeadPhone = Database.query(queryLeadPhone);
            
            //Null pointer check for Phone number
            if(sObjQueryLeadPhone[0].CCPM_mobileNumber__c != null) {
                strLeadPhone = sObjQueryLeadPhone[0].CCPM_mobileNumber__c;
                
                //Remove unwanted characters from the phone field to display in the SMS interaction history
                strLeadPhone = strLeadPhone.replaceAll('[^0-9]', '');
            }
            return strLeadPhone;   
        } else {
            return null;
        }
    }
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method is used to get the list of last 30 SMS interactions with the customer
    *@return        Task records containing SMS body
    */ 
    @AuraEnabled
    public static List<Task> getSMSMessageList (Id idRecord) {
        // Check to see of the record ID of the parent record is present
        if (idRecord != null) {
            // Query just the Last 30 interactions from the Activity object
            String queryString = 'SELECT id, Description, CreatedDate, CCPM_communicationDirection__c,CCPM_SMSMessageType__c ' +
                'FROM Task WHERE ( recordtype.name = ' + '\'Call Notes\'  OR ' + 
                'recordtype.name = ' + '\'' + CCPM_staticConstants.strInteractionHistoryRecordType + '\') ' + 
                'AND WhoId  =' + '\'' + idRecord + '\' ' + 
                'ORDER BY createdDate ASC';
            
            List<Task> sobjQueryList = Database.query(queryString);
            
            //Temporary list to store the results of the SMSs 
            List<Task> sobjList = new List<Task>();
  
            Integer j = 1;
            
            //Iterate through all the elements returned from the SELECT query
            //Select only the 30 interactions that are eligible to be displayed on the Interaction History
            
            for(Integer i=sobjQueryList.size()-1; j <= 30 && i >= 0; i--) {
                if ((String.valueof(sobjQueryList[i].Description) != null) && (sobjQueryList[i].CCPM_communicationDirection__c.toLowerCase() != null)) {
                    
					set<String> setOutBoundSMS = new set<String>();
                    boolean boolValidSMSMessageType;
                    boolValidSMSMessageType = false;
                    
                    //Getting all the values of OutBound messages
                    String[] strOutBoundSMS =CCPM_staticConstants.strOutgoingSMSReferenceId.split(':');
                    
                    for(integer m=0;m<strOutBoundSMS.size();m++) {
                        setOutBoundSMS.add(strOutBoundSMS[m]);
                    } 
                    
                    if(String.valueof(sobjQueryList[i].CCPM_SMSMessageType__c) != null) {
                        if(setOutBoundSMS.contains(sobjQueryList[i].CCPM_SMSMessageType__c)) {
                            boolValidSMSMessageType = true;
                        } 
                    }
                
                    //Check if this is a Outbound Message starting with FreeVzMsg
                    //This will eliminate all the rest of the messages which are sent to the Verizon staff
                    
                    if((String.valueof(sobjQueryList[i].Description).contains(CCPM_staticConstants.strFreeVzMsgNewFormat)) || boolValidSMSMessageType || (String.valueof(sobjQueryList[i].Description).contains(CCPM_staticConstants.strMessageCustomerAutoResponse))) {
                        sobjList.add(sobjQueryList[i]);
                        j = j + 1;
                    }
                    else if (sobjQueryList[i].CCPM_communicationDirection__c.toLowerCase() == CCPM_staticConstants.strTaskCommunicationDirection) {
                        //Add inbound messages to the list
                        sobjList.add(sobjQueryList[i]);
                        j = j + 1;
                    }
                }
            }
            
            
            return sobjList;
        }
        else // Throw an exception if the parent ID is null.
            return null;
    }
}