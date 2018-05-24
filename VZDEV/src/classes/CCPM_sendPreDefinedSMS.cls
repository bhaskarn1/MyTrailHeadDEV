/**
*@name          CCPM_sendPreDefinedSMS
*@author        Paras Shah (Deloitte)
*@date          06/05/2017
*@description   To send PreDefined SMS to Customers
*@testClass     CCPM_sendPreDefinedSMSTest

Modification    Log:
------------------------------------------------------------------------------------
Developer                        Date               Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)             06/05/2017         Original Version 
Paras Shah(Deloitte)             06/22/2017         US-0514 : To ad the '(FreeVzMsg)'at the end of the SMS body for the RecordTypes maintained in the global custom settings
                                                    CCPM_recordTypesWithFreeVzMsg__c
Manjunath Keshava(Deloitte)      07/14/2017           Added Null checks (US-1616)
Paras Shah(Deloitte)			 08/07/2017			US1657 : Added Phone number field in the SOQL query to pass it back to the Lightning component
Soumya Panguluri(Deloitte)       09/08/2017         US-1745 : added merged fields in the Soql query to pass it back to the Lightning component
Soumya Panguluri(Deloitte)       09/14/2017         US-1745 : added corrected merged fields in the Soql query to pass it back to the Lightning component
Manjunath Keshava(Deloitte)      11/07/2017         DISTSCE-1851: Added 4 New promo messages with labels to send sms with dynamic Ecode of the rep 
Paras Shah (Deloitte)			 01/09/2017			Added 'with sharing' as part of Spring '18 release changes
*/


public with sharing class CCPM_sendPreDefinedSMS {
    
    public static list<CCPM_SMSMessage__c> lstSuccessSMS = new List<CCPM_SMSMessage__c>();
    public static String strRecordTypeName = CCPM_staticConstants.strEmpty;
    public static  List<CCPM_promoMessage__mdt> listPromoSMSSetting = new  List<CCPM_promoMessage__mdt>();
    public static  List<Lead> sObjQueryLeadPhone= new  List<Lead>();
    /**
    *@author        Paras Shah (Deloitte)
    *@description   Constructor for the CCPM_sendPreDefinedSMS class
@modification Added logic to send 4 new promo messages
    *@return        Void(None)
    */ 
    
    public CCPM_sendPreDefinedSMS(id idRecord) {

    }
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   Get Phone number of the Lead
    *@return        Void(None)
    */ 
    
    @AuraEnabled
    public static List<Lead> getLeadPhone (Id idRecord) {
        //Query to pull Lead Phone number to display in the message history
        if (idRecord != null) { 
		//-Added CCPM_ownerEcode__c,CCPM_promoMessageSent__c field to the query
           // String strQueryLeadPhone = 'SELECT Id,CCPM_ownerEcode__c,RecordTypeId,CCPM_promoFirstSent__c,CCPM_promoSecondSent__c,CCPM_lastPromoSent__c,CCPM_isMerged__c,CCPM_isInformaticaMerge__c,CCPM_isMergedUIFlag__c, recordtype.name,CCPM_mobileNumber__c, Store__r.name, Store__r.CCPM_street__c, Store__r.CCPM_city__c, Store__r.CCPM_phone__c,Store__r.CCPM_zipcode__c, Status,CCPM_leadSubStatus__c,CCPM_firstPredefinedSMSFlag__c,CCPM_finalPreDefinedSMSFlag__c FROM Lead where Id = ' + '\'' + idRecord + '\'' + ' LIMIT 1';
            //List<Lead> sObjQueryLeadPhone = Database.query(strQueryLeadPhone);
             sObjQueryLeadPhone = [SELECT Id,CCPM_ownerEcode__c,CCPM_storeEcode__c,RecordTypeId,CCPM_promoFirstSent__c,CCPM_promoSecondSent__c,CCPM_lastPromoSent__c,CCPM_isMerged__c,CCPM_isInformaticaMerge__c,CCPM_isMergedUIFlag__c, recordtype.name,CCPM_mobileNumber__c, Store__r.name, Store__r.CCPM_street__c, Store__r.CCPM_city__c, Store__r.CCPM_phone__c,Store__r.CCPM_zipcode__c, Status,CCPM_leadSubStatus__c,CCPM_firstPredefinedSMSFlag__c,CCPM_finalPreDefinedSMSFlag__c FROM Lead where Id =:idRecord LIMIT 1];
           // strRecordTypeName = sObjQueryLeadPhone[0].recordtype.name;
              strRecordTypeName = sObjQueryLeadPhone[0].recordtype.name;
            system.debug('the recordtype is'+strRecordTypeName);
            
            return sObjQueryLeadPhone;   
            
        } else { 
            return null;
        }
    }
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method is used to send Pre defined SMS to Customers
@modification log: Added logic to get promo messages from custom metadata type and add to the picklist
    *@return        Lead Phone number (tbd)
    */ 
    
    @AuraEnabled
    public static Integer sendPreDefinedSMSToCustomer (Id idRecord,String strMTN,String strSMSMessageBody, Boolean boolFirstPreDefinedSMSFlag, String strLeadSubStatus, Id recordTypeId,string ownerEcode,string strFirstPromolabel,string strSecondPromolabel,string strLastPromoLabel,string strLeadStoreEcode) 
    { 
        //query for the custom metadata object "Send Pre Defined Sms" to get the label and sms contents for both prospects and customer carts
        List<CCPM_promoMessage__mdt> listPromoSMSSetting = [Select MasterLabel,CCPM_finalPreDefinedResponse__c,CCPM_firstPreDefinedResponse__c,CCPM_MessageContentForLeads__c,CCPM_messageContentForProspects__c From CCPM_promoMessage__mdt ];
        map<string,string> mapPromoMessage= new map<string,string>();
        for(CCPM_promoMessage__mdt objPromo : listPromoSMSSetting)
        {
            //get Sms content Based on the record type and add it to the map
            if(recordTypeId == CCPM_staticConstants.strProspectRecordTypeID)
            {
                mapPromoMessage.put(objPromo.MasterLabel,objPromo.CCPM_messageContentForProspects__c);
            }
            else if(recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID)
            {
                mapPromoMessage.put(objPromo.MasterLabel,objPromo.CCPM_MessageContentForLeads__c);
            }
        }
        
        String strSMSMessageContentURLFormat;
        String strLivetextPhoneNumber;
        string strSmsInteractionMessage;
        //string strUpdateFirstPromoLabel;
        //string strUpdateSecondPromoLabel;
        //string strUpdateSecondPromoLabel;

        
        //Assigning Live text number based on record type prospect and lead
        if(recordTypeId == CCPM_staticConstants.strProspectAbandonedCartRecordTypeID  || recordTypeId == CCPM_staticConstants.strProspectRecordTypeID ){
            strLivetextPhoneNumber =CCPM_staticConstants.strLivetextPhoneNumberNonVerizon;
           
        }else if(recordTypeId == CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID){
            strLivetextPhoneNumber = CCPM_staticConstants.strLivetextPhoneNumber;
        
        }
        strMTN = strMTN.replaceAll(CCPM_staticConstants.strnondigits, CCPM_staticConstants.strEmpty);
        
        //system.debug('@@@@ strLeadSubStatus'+strLeadSubStatus);
        
        if(strSMSMessageBody!= null) 
        {
            
            system.debug('the map is'+mapPromoMessage);
            //if the strSMSMessageBody value from the picklist matches the label from the map we get the message content 
           if(mapPromoMessage.containsKey(strSMSMessageBody))
           {
               string strTempMsg= mapPromoMessage.get(strSMSMessageBody);
                              system.debug('the temp msg is'+strTempMsg);
               //populating the promolabel field on lead 
              
               if(strFirstPromolabel!=null && strSMSMessageBody!=null)
               {
                strSecondPromolabel = strSMSMessageBody.replace('Promo', '');
                }
               else if(strSMSMessageBody!=null )
               {
                strFirstPromolabel  =strSMSMessageBody.replace('Promo', '');
               }
               if( strSMSMessageBody!=null)
               {
                   strLastPromoLabel=strSMSMessageBody.replace('Promo', '');
               }
                string strReplaceEcode='';
               //replacing the ecode dynamically with rep's Ecode
               system.debug('the rep ecode is'+ownerEcode);
               system.debug('the store ecode is'+strLeadStoreEcode);
               if(ownerEcode!=null)
               {
                strReplaceEcode=strTempMsg.replace('[ECODE]',ownerEcode);
               }
               else if( strLeadStoreEcode!=null)
               {
                   strReplaceEcode=strTempMsg.replace('[ECODE]',strLeadStoreEcode);
               }
               else
               {
                       strReplaceEcode=strTempMsg.replace('[ECODE]','');

               }
                strSmsInteractionMessage=strReplaceEcode;
               strSMSMessageContentURLFormat = strReplaceEcode.replace(ccpm_staticConstants.StrSpace , ccpm_staticConstants.StrPlus);
               
               system.debug('the msg is'+strSMSMessageContentURLFormat);
 
           }
            else
            {
                //Added this string to display the interaction history
                strSmsInteractionMessage=strSMSMessageBody;
                //system.debug('@@@@ innside SMSMessageBody!= null');
            //Replace Spaces with '+' to make string in URL format
            strSMSMessageContentURLFormat = strSMSMessageBody.replace(ccpm_staticConstants.StrSpace , ccpm_staticConstants.StrPlus);
            //system.debug('the split is'+strSMSMessageContentURLFormat);
            }
            
            
        }
        
        
        HTTPResponse httpResponseFromHeywire;
        
        if (strSMSMessageBody.startsWith('Yes! Our Store Address Is:') && strSMSMessageBody.length() > 160) {
            
            String[] strStoreAddressPreDefinedSMS = strSMSMessageContentURLFormat.split('-');
 
            for (Integer i=0;i<strStoreAddressPreDefinedSMS.size();i++) 
            {
                httpResponseFromHeywire = CCPM_HttpCallOutUtility.createHeyWireHttpRequest(strStoreAddressPreDefinedSMS[i],strMTN,strLivetextPhoneNumber);
                //system.debug('the answer is '+httpResponseFromHeywire );
            }
        }
        else {
            //Http call to send SMS to customer
            httpResponseFromHeywire = CCPM_HttpCallOutUtility.createHeyWireHttpRequest(strSMSMessageContentURLFormat,strMTN, strLivetextPhoneNumber);
            //system.debug('the output is '+httpResponseFromHeywire );
        }
        
        //Process the HeyWire Response code for Successful response code
        //system.debug('the res is '+httpResponseFromHeywire );
        //system.debug('result'+httpResponseFromHeywire.getStatusCode());
         //system.debug('result'+CCPM_staticConstants.intSuccessResponseCode);
        
        if (httpResponseFromHeywire.getStatusCode() == CCPM_staticConstants.intSuccessResponseCode)
        {
		
            Lead objLeadRecord = new Lead();
            objLeadRecord.id = idRecord;
            objLeadRecord.status = CCPM_staticConstants.strLeadStatusQualified;
            objLeadRecord.CCPM_leadSubStatus__c = strLeadSubStatus;
            objLeadRecord.CCPM_lastInteraction__c = System.now();
            if(strFirstPromolabel!=null && strSecondPromolabel==null)
            {
            objLeadRecord.CCPM_promoFirstSent__c=strFirstPromolabel;
            objLeadRecord.CCPM_promoFirstSentDate_Time__c=system.now();
            }
            if(strSecondPromolabel!=null)
            {
             objLeadRecord.CCPM_promoSecondSent__c=strSecondPromolabel;
             objLeadRecord.CCPM_promoSecondSentDate_Time__c=system.now();
            }
            objLeadRecord.CCPM_lastPromoSent__c=strLastPromoLabel;
            //objLeadRecord.CCPM_promoMessageSentDate_Time__c=system.now();
           
   
            if(boolFirstPreDefinedSMSFlag == true) {
                objLeadRecord.CCPM_finalPreDefinedSMSFlag__c = true;    
            } else {
                objLeadRecord.CCPM_firstPredefinedSMSFlag__c = true;
            }
            
            try{
                if(objLeadRecord!=null)
                //Bulkified update
                update objLeadRecord;
            }   
            catch(Exception e){
                CCPM_LogMessageUtility.logMessage(e,'CCPM_sendPreDefinedSMS','Update Lead Send SMS Status','Exception thrown while sending Lead SMS',true); 
            }
            
            CCPM_SMSMessage__c objSMSMessage = new CCPM_SMSMessage__c();
            List<String> lstSMSMessageBody = new List<String>();
            lstSMSMessageBody.add(strSmsInteractionMessage);
            
            objSMSMessage=CCPM_SMSMessageBatchHandler.createRecordsForSmsMessageObject(idRecord, lstSMSMessageBody[0],strMTN, CCPM_staticConstants.strMessageTypePreDefinedSMS,CCPM_staticConstants.strTaskCommunicationOutbound,System.now(),CCPM_staticConstants.strMessageStatusSent,strLivetextPhoneNumber);
            lstSuccessSMS.add(objSMSMessage);

            //Creating a list to hold the Lead records for which SMS were sent out successfully
            list<Lead> lstLead = new list<Lead>();
            
            if(idRecord!=null)
             //Get the list of Lead records for whom the fields need to be updated based on the success response codes
            lstLead = [select id,ownerid from lead where id = :idRecord ];
            
            //Map to hold the lead records as values and ID as key
            map<id,Lead> mapLead = new map<id,Lead>();
            if(lstLead!=null && !lstLead.isEmpty() )
            {
            for (Lead objL : lstLead)
            {
                mapLead.put(objL.Id,objL);
            }
            }
            
            CCPM_SMSMessageBatchHandler.createInteractionTouchPoint(lstSuccessSMS, mapLead);
                
            return CCPM_staticConstants.intSuccessResponseCode;
        } else {
            return 0;
        }
    }
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method process the Lead record type and determines if there needs to be a (FreeVzMsg)
    *@return        Lead Sub Statuses
    */ 
    @AuraEnabled
    public static String determineFreeVzMsgSuffix(){

        String strFreeVzMsg = ccpm_staticConstants.strEmpty;
        
        String[] strOutBoundSMSFreeVzMsg =CCPM_staticConstants.strRecordTypesWithFreeVzMsg.split(ccpm_staticConstants.strColon);
            
        for(integer j=0;j<strOutBoundSMSFreeVzMsg.size();j++)
        {
            if (strRecordTypeName ==strOutBoundSMSFreeVzMsg[j])
            {
                strFreeVzMsg=CCPM_staticConstants.strFreeVzMsgNewFormat;
                break;
            }   
        }
        //system.debug('@@@@freevzmsg'+strFreeVzMsg);
        return strFreeVzMsg;
    }
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method is used to get the picklist values
    *@return        Lead Sub Statuses
    */ 
    @AuraEnabled
    public static List<String> getLeadSubStatus(){
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult getLeadQualifiedSubStatus = lead.CCPM_qualifiedSubStatusForPreDefinedSMS__c.getDescribe();
        List<Schema.PicklistEntry> lstPicklistValuesLeadSubStatus = getLeadQualifiedSubStatus.getPicklistValues();
        for (Schema.PicklistEntry strSubStatus: lstPicklistValuesLeadSubStatus) {
            lstOptions.add(strSubStatus.getLabel());
        }
        return lstOptions;
    }
     @AuraEnabled
    public static List<String> getCaptureReponse(string strRecordTypeName,CCPM_promoMessage__mdt objMessage,list<string> lstOptions)
    {
        string strSuffix = determineFreeVzMsgSuffix();
        
                 if(objMessage.CCPM_dispalyOrignialMessage__c==true)
                 {
                     if( strRecordTypeName==label.CCPM_leadCustomerCartRT && objMessage.CCPM_MessageContentForLeads__c!='Yes! Our Store Address Is:-' && objMessage.CCPM_MessageContentForLeads__c!='Please call the store to discuss further')
                     {
                         lstOptions.add(objMessage.CCPM_MessageContentForLeads__c);
                     }
                      else if ( strRecordTypeName==label.CCPM_LeadProspectRecordType && objMessage.CCPM_messageContentForProspects__c!='Yes! Our Store Address Is:-' && objMessage.CCPM_messageContentForProspects__c!='Please call the store to discuss further')
                      {
                         
                          lstOptions.add(objMessage.CCPM_messageContentForProspects__c);
                      }
                     else if(objMessage.CCPM_MessageContentForLeads__c=='Yes! Our Store Address Is:-' || objMessage.CCPM_messageContentForProspects__c=='Yes! Our Store Address Is:-')
                     {
                            lstOptions.add(objMessage.CCPM_MessageContentForLeads__c +' '+sObjQueryLeadPhone[0].Store__r.CCPM_street__c + ' ' + sObjQueryLeadPhone[0].Store__r.CCPM_city__c + ' ' + sObjQueryLeadPhone[0].Store__r.CCPM_zipcode__c + '. ' + strSuffix);
                     }
                     else if(objMessage.CCPM_MessageContentForLeads__c=='Please call the store to discuss further' || objMessage.CCPM_messageContentForProspects__c=='Please call the store to discuss further')
                     {
                         lstOptions.add(objMessage.CCPM_MessageContentForLeads__c + ' '+sObjQueryLeadPhone[0].Store__r.CCPM_phone__c + ' ' + strSuffix);
                     }
                 }
                 else 
                 {
                   lstOptions.add(objMessage.MasterLabel);  
                 }
             
        return lstOptions;
    }
    
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method is used to get the First Pre defined response picklist values
    *@return        Picklist values for first pre defined response
    */ 
    @AuraEnabled
    public static List<String> getFirstpreDefinedSMSReponse()
    {
        List<String> lstOptions = new List<String>();
          listPromoSMSSetting = [Select MasterLabel,CCPM_dispalyOrignialMessage__c,CCPM_finalPreDefinedResponse__c,CCPM_firstPreDefinedResponse__c,CCPM_MessageContentForLeads__c,CCPM_messageContentForProspects__c From CCPM_promoMessage__mdt order by MasterLabel desc ];
       
        for (CCPM_promoMessage__mdt strMessage: listPromoSMSSetting) 
        {
            
           system.debug('the record type is'+strRecordTypeName); //To make sure the freeVzMsg is added to other messages except the promo messages
         if(strMessage.CCPM_firstPreDefinedResponse__c==true)
         {
             getCaptureReponse(strRecordTypeName,strMessage,lstOptions);
            
            /* if( strRecordTypeName==label.CCPM_leadCustomerCartRT)
             {
                 if(strMessage.CCPM_dispalyOrignialMessage__c==true )
                 {
                         lstOptions.add(strMessage.CCPM_MessageContentForLeads__c);
                 }
                 else 
                 {
                   lstOptions.add(strMessage.MasterLabel);  
                 }
             }
             else if ( strRecordTypeName==label.CCPM_LeadProspectRecordType)
             {
                 if(strMessage.CCPM_dispalyOrignialMessage__c==true )
                 {
                 	lstOptions.add(strMessage.CCPM_messageContentForProspects__c);
                 }
                 else
                 {
                     lstOptions.add(strMessage.MasterLabel);
                 }
             }*/
             
         }     
        }
        return lstOptions;
    }
    
    /**
    *@author        Paras Shah (Deloitte)
    *@description   This method is used to get the First Pre defined response picklist values
    *@return        Picklist values for first pre defined response
    */ 
    @AuraEnabled
    public static List<String> getFinalPreDefinedSMSReponse(){
        List<String> lstOptions = new List<String>();
        //Schema.DescribeFieldResult getLeadFinalPreDefinedResponse = Lead.CCPM_finalPreDefinedResponse__c.getDescribe();
        //List<Schema.PicklistEntry> lstPicklistValuesLeadSubStatus = getLeadFinalPreDefinedResponse.getPicklistValues();
         for (CCPM_promoMessage__mdt strMessage: listPromoSMSSetting) 
        {
            
           system.debug('the record type is'+strRecordTypeName); //To make sure the freeVzMsg is added to other messages except the promo messages
         if(strMessage.CCPM_finalPreDefinedResponse__c==true)
         {
             getCaptureReponse(strRecordTypeName,strMessage,lstOptions);
             
             
             /*if( strRecordTypeName==label.CCPM_leadCustomerCartRT)
             {
                 if(strMessage.CCPM_dispalyOrignialMessage__c==true )
                 {
                         lstOptions.add(strMessage.CCPM_MessageContentForLeads__c);
                 }
                 else 
                 {
                   lstOptions.add(strMessage.MasterLabel);  
                 }
             }
             else if ( strRecordTypeName==label.CCPM_LeadProspectRecordType)
             {
                 if(strMessage.CCPM_dispalyOrignialMessage__c==true )
                 {
                 	lstOptions.add(strMessage.CCPM_messageContentForProspects__c);
                 }
                 else
                 {
                     lstOptions.add(strMessage.MasterLabel);
                 }
             }
             
         } */    
        }
        }
        return lstOptions;
    }
}