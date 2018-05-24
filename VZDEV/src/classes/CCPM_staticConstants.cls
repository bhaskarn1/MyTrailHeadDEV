/**
*@name          CCPM_staticConstants
*@author        Deepak Mazumdar(Deloitte)
*@date          14/12/2016
@description    Class to define static constants              

Modification    Log:
-------------------------------------------------------------------------------------------------------
Developer                               Date                   Description
-------------------------------------------------------------------------------------------------------
Deepak Mazumdar(Deloitte)               16/12/2016             Original Version
Paras Shah(Deloitte)                    03/01/2017             Added constants for checkIn and checkOut 
TAG: #checkInCheckOut and #SMS
Deepak Mazumdar(Deloitte)               16/01/2017             Code indendeted and comments added
Sudhakara Reddy Nallamilli(Deloitte)    05/17/2017             Added Lead Open Status Set and Lead Retail, Digital Strings
Sudhakara Reddy Nallamilli(Deloitte)    05/31/2017             Removed the Event Type Constants for Prospect
Paras Shah(Deloitte)                    06/22/2017             Added a variable to refer to the custom settings for Recordtypes containing FreeVzMsg in SMS body.
Sudhakara Reddy Nallamilli(Deloitte)    06/22/2017             Added SOSL Related Constants
Brigadesh Chandrasekar(Deloitte)        08/03/2017             Added RequestID static constant 
Sudhakara Reddy Nallamilli(Deloitte)    09/05/2017             Added Unknown Static Constant
Soumya Panguluri(Deloitte)              09/08/2017             TKT-524 - Modified setMarkets,setDistricts,setTerritorys
*/
public class CCPM_staticConstants {
    
    public static integer NoOfRecordsOne                                = 1;
    public static integer NoOfRecords                                   = 4;    
    public static integer oneRecord                                     = 1; 
    public static String CCPM_cartlastHandledBy                         = '12345';
    public static String CCPM_storeID                                   = 'S12345';
    
    // #Apex class used in Process Builder to send SMS: static constants related to task types
    public static String strTaskSubjectCheckInSuccessful                = 'Customer CheckedIn Successfully';
    public static String strTaskSubjectCheckOutSuccessful               = 'Cart Converted Successfully';
    public static String strTaskSubjectTextMessageReceived              = 'Text Message Received';
    public static String strTaskSubjectTextMessageSent                  = 'Text Message Sent';
    public static String strTaskCompleted                               = 'Completed';
    public static String strTaskNotStarted                              = 'Not Started';
    public static String strTaskTypeCartCheckedOut                      = 'Cart Converted';
    public static String strTaskTypeCustomerCheckIn                     = 'Customer CheckedIn';
    public static String strTaskTypeOther                               = 'Other';
    public static String strTaskTypeSMS                                 = 'SMS';
    public static String strTaskCommunicationDirection                  = 'Inbound';
    public static String strTaskCommunicationOutbound                   = 'Outbound';
    public static String strTaskPriorityHigh                            = 'High';
    public static String strTaskPriorityNormal                          = 'Normal';
    
    // cart status
    public static String strCartStatusActive                            = 'A';
    public static String strCartStatusInActive                          = 'I';
    
    // Processing Queue Object Type field
    public static String strCartTypeProcessingforConvertedLeads        = 'Cart Type Processing for Converted Leads';
    public static String strSMSSchedulesToBeRemoved            = 'SMS Schedules To Be Removed';
    public static String strToUpdateTeleSalesLead            = 'To Update Tele Sales Lead';
    public static String strCartTypeAAL                        = 'AAL';
    public static String strCartTypeUPG                        = 'UPG';
    public static String strCartTypeEUP                        = 'EUP';
    public static String strCartTypeACC                        = 'ACC';
    public static String strCartTypeNEW                        = 'NEW';
    public static String strCartTypeOTHER                      = 'OTHER';
    
    // #SMS: static constants related to Initial SMS Sent or UnSuccessful
    public static String  strTaskTypeSMSInitialSMSSent                  = 'Initial SMS Sent';
    public static String  strTaskTypeInitialSMSFailed                   = 'Initial SMS Failed';
    public static String  strTaskSubjectInitialSMSSuccessfullySent      = 'Initial SMS Successfully Sent';
    public static String  strTaskSubjectInitialSMSFailed                = 'Initial SMS Failed';
    
    
    public static string strLeadDigital = 'Digital';
    public static string strLeadRetail = 'Retail';
    public static string strLeadNetace = 'NETACE';
    public static string strLeadCartType = 'PURCHASE_PATH';
    public static string strObjectLead = 'lead';
    public static string strSOSLFind = 'FIND ';
    public static string strSOSLGroupPhone = 'IN PHONE FIELDS RETURNING ';
    public static string strSOSLGroupEmail = 'IN EMAIL FIELDS RETURNING ';
    public static string strSOSLGroupAll = 'IN ALL FIELDS RETURNING ';
    public static string strPhone = 'PHONE';
    public static string strEmail = 'EMAIL';
    public static string strLogicalOR = ' OR ';
    public static string strUnknown = 'UNKNOWN';
    // lead statuses
    public static String  strLeadStatusNew                              = 'New';
    public static String  strLeadStatusEligible                         = 'Eligible';
    public static String  strLeadStatusConverted                        = 'Converted';
    public static String  strLeadStatusExpired                          = 'Expired';
    public static String  strLeadStatusCartConverted                    = 'Completed';
    public static String  strLeadStatusCartRejected                     = 'Rejected';   
    public static String  strLeadStatusCartRejectedDNS                  = 'Rejected - SMS DNS';
    public static String  strLeadStatusCartRejectedOptOut               = 'Rejected - SMS Opted Out';
    public static string  strLeadStatusQualified                        = 'Qualified';
    public static string  strLeadStatusContacted                        = 'Contacted';
    public static string  strLeadStatusResponded                        = 'Responded';
    public static String strLeadSubStatusCartDisinterested              = 'Cart-Disinterested';
    
    // Lead Sub Status
    public static String strLeadSubStatusOptedOut                       = 'Opted Out';
    public static String strLeadSubStatusActionRequired                 = 'Action Required';
    public static String strLeadSubStatusInDiscussion                   = 'In Discussion';
    public static String strLeadSubStatusAppointmentScheduled           = 'Appointment Scheduled';
    public static String strLeadSubStatusNeedsStoreReassignment         = 'Needs Store Reassignment';
    public static String strLeadSubStatusServiceIssue                   = 'Service Issue';
    public static String strLeadSubStatusDisinterested                  = 'Disinterested';
    
    
    
    
    public static boolean boolSMSSent                                   = true;
    public static boolean boolSMSUnSuccessful                           = false;
    
    public static String strInteractionHistoryRecordType                = 'Interaction History';
    public static String strFreeVzMsg                                   = 'FreeVzMsg';
    public static String strFreeVzMsgNewFormat                          = '(FreeVzMsg)';
    public static String strLeadAssignmentBody                          = 'Please login to Salesforce1 on your iPad';
    
    
    //Reference String For SMS Schedule Messages
    public static string strReferenceInitialSMS                         = 'VzWInitialSMS';
    public static string strReferenceFollowUpSMS                        = 'VzWFollowUpSMS';
    public static string strReferenceTaskOwnerSMS                       = 'VzWTaskOwnerSMS';
    public static string strReferenceProcessCustomerResponse            = 'VzWCustomerResponseSMS';
    public static string strReferenceProspectSMS                        = 'VzWNewProspectSMS';
    public static string strReferenceLeadProspectActionRequired         = 'VzWLeadProspectActionRequiredSMS';
    public static string strLeadOwnerChangeSMS                          = 'VzWLeadOwnerChangeSMS';
    public static string strLeadOwnerSMSOnCustomerResponse              = 'VzWLeadOwnerSMSOnCustomerResponse';
    public static string strMessageCustomerAutoResponse                 = 'Thank';
    
    public static string strCustomerResponseForOptOut                   = 'X';
    
    public static string strCustomerResponseForOptOutSmall              = 'x';
    public static string strFirstCustomerResponseForOptOut              = 'E';
    public static string strFirstCustomerResponseForOptOutSmall         = 'e'; 
    public static string strFirstCustomerResponseForOptOutQuote         = '"E"';
    public static string strCustomerResponseForOptOutQuote              = '"X"';
    public static string StatusNew                                      = 'New';
    public static string StatusCompleted                                = 'Completed';
    public static string StatusRejected                                 = 'Rejected';
    public static string SObjectTypeAccount                             = 'Account';
    //SMS Message Types used in Apex class for sending SMS through process builder
    public static string strMessageTypeInitialSMSPart1                  = 'InitialSMSPart1';
    public static string strMessageTypeInitialSMSPart2                  = 'InitialSMSPart2';
    public static string strMessageTypeFollowUpSMS                      = 'FollowUp';
    public static string strMessageTypeProcessCustomerResponse          = 'ProcessCustomerResponse';
    public static string strMessageTypeTaskOwnerSMS                     = 'TaskOwnerSMS';
    public static string strDoubleOptOutMessage                         = 'DoubleOptOutMessage';
    public static string strMessageTypeProspectFirstSMSPart1            = 'NewProspectSMS1';
    public static string strMessageTypeProspectFirstSMSPart2            = 'NewProspectSMS2';
    public static string strMessageTypeLeadActionRequired               = 'leadActionRequired';
    public static string strMessageTypeProspectActionRequired           = 'prospectActionRequired';
    public static string strMessageTypeManagers                         = 'SMSManagers';
    public static string strMessageTypeAssistantManagers                = 'SMSAssistantManagers';
    public static string strMessageTypeManagersActionRequired           = 'SMSManagersActionRequired';
    public static string strMessageTypeDistrictManagers                 = 'SMSDistrictManagers';
    public static string strMessageTypeAssistantManagersActionRequired  = 'SMSAssistantManagersActionRequired';
    public static string strMessageTypePreDefinedSMS                    = 'PreDefinedSMS';
    public static string strMessageTypeDoubleOptOutSMS                  = 'DoubleOptOutSMS';
    
    
    public static CCPM_globalSetting__c gs                              = CCPM_globalSetting__c.getInstance();
    public static integer intTriggerInitialSMSPart2Interval             = 1;
    public static string strStaggerInitialSMS                           = gs.CCPM_staggerInitialSMSInterval__c;
    public static string strCartClosedStatus                            = gs.CCPM_cartClosedStatus__c; 
    public static string strOutgoingSMSReferenceId                      = gs.CCPM_outgoingSMSReferenceId__c; 
    public static string strFollowUPNextBusiness                        = gs.CCPM_followUpSMSNextStartInterval__c;
    public static string strProspect1stSMS                              = gs.CCPM_prospectSMSNextStartInterval__c;
    public static string strProspectRecordTypeID                        = gs.CCPM_leadProspectRecordType__c;
    public static string strProspectAbandonedCartRecordTypeID           = gs.CCPM_leadProspectAbandonedCartRecordType__c;
    public static string strLeadCustomerAbandonedCartRecordTypeID       = gs.CCPM_leadCustomerAbandonedCartRecordType__c;
    public static string strLivetextPhoneNumber                         = gs.CCPM_liveTextPhoneNumber__c;
    public static string strLivetextPhoneNumberNonVerizon               = gs.CCPM_liveTextNumberNonVerizon__c;
    public static string strTaskInteractionHistoryRecordType            = gs.CCPM_taskInteractionHistoryRecordTypeId__c;
    public static string strTaskToDoRecordType                          = gs.CCPM_taskToDoRecordTypeId__c;
    public static string strRecordTypesWithFreeVzMsg                    = gs.CCPM_recordTypesWithFreeVzMsg__c;
    public static string strInitialSMSInterval                          = gs.CCPM_initialSMSInterval__c;
    public static string strFollowUpSMSInterval                         = gs.CCPM_followUpSMSInterval__c;
    public static string strDataIntegrationUserQueue                    = gs.CCPM_DataIntegrationQueue__c;
    public static string strTeleSalesQueue                              = gs.CCPM_HQTelesale__c;
    
    //SalesRep profile Id used to verify if the profile is of the salesrep
    public static string strsalesRepProfileId                           = gs.CCPM_salesRepProfileId__c;
    public static string strsystemAdminProfileId                        = gs.CCPM_systemAdminProfileId__c;
    public static string strIntegrationUserProfileId                    = gs.CCPM_dataIntegrationUserProfileId__c;
    
    public static string strEndpoint_x                                  = gs.CCPM_endpoint_x__c;
    public static string strClientCertName_x                            = gs.CCPM_clientCertName_x__c;
    public static string strEncryptedKey                                = gs.CCPM_EncryptedKey__c;
    public static string strEncryptionAlgorithm                         = gs.CCPM_EncryptionAlgorithm__c;
    
    
    public static string strStoreManager                                ='Store Manager';
    public static string strSystemAdministrator                         ='System Administrator';
    public static string strStoreAssistantManager                       ='Assistant Manager';
    public static string strStoreSalesRep                               ='Sales Rep'; 
    public static string strMessageStatusQueued                         ='Queued';
    public static string strLeadRecordTypeProspectCart                  ='Prospect Cart';
    public static string strLeadRecordTypeProspect                      ='Prospect';
    public static string strLeadRecordTypeCustomerCart                  ='CustomerCart';
    public static string strLeadRecordTypeLead                          ='Lead'; 
    public static string strLeadRecordTypeManualLead                    ='Manual Lead';
    public static string strLeadRecordTypeCustomerCartDevName           ='CCPM_customerCart';
    public static string strLeadRecordTypeProspectDevName               ='CCPM_prospect';
    
    
    //Prospect Event Types 
    public static string strContractTerminatingSoon                      = 'Contract Terminating Soon';
    public static string strConfirmingwithFamilyFirst                    = 'Confirming with Family First';
    public static string strGiftforUpcomingOccasion                      = 'Gift for Upcoming occasion'; 
    public static string strOtherEvent                                   = 'Other event';
    
    //Heywire API Constants
    public static Integer intSuccessResponseCode                         = 204;
    public static String strMessageStatusSent                            ='Sent'; 
    public static String strMessageStatusError                           ='Error';
    public static String strMessageStatusResendFailed                    ='Resend Failed'; 
    public static String strMessageStatusRemoved                         ='Removed'; 
    public static string strLeadTypeManualLead                          ='Manual Lead';
    public static string strSMSFailCounter                               = gs.CCPM_SMSFailCounter__c; 
    public static string strAccountID                                    = gs.CCPM_heywireAPIAccountID__c;
    public static string strAdminPassword                                = gs.CCPM_heywireAPIAdminPassword__c;
    public static string strEndPointURL                                  = gs.CCPM_heywireAPIEndpointURL__c;
    public static string strBatchLimit                                  = gs.CCPM_sendSMSBatchLimit__c;
    public static string strRemoveSmsScheduleBatchLimit                 = gs.CCPM_removeScheduleBatchSize__c; 
    public static string strBatchChunk                                  = gs.CCPM_sendSMSBatchChunk__c;
     public static string strProcessQueueBatchChunk                     = '200';
    public static string strSleepTime                                   = gs.CCPM_sleepTimeBetweenSMSBody__c;
    
    //Test MTN encryption Field
    public static string strCustomerMTN                                  ='9999999999';   
    //to format phone number
    public static  string strnondigits                                  ='[^0-9]';  
    //to schedule time for 10 min interval
    public static string StrCRONEXP                                      ='0 10 * * * ?';
    //to schedule time for t min interval
    public static string StrCRONInt                                      ='0 5 * * * ?';
    public static string StrCRONZero                                     ='0 0 * * * ?';
    public static string strSpace                                        =' ';
    public static string strEmpty                                        ='';
    public static string strPlus                                         ='+';
    public static string strColon                                        =':';
    public static string strHyphen                                       ='-';
    public static string strYesFlag                                      ='Y';
    public static string strNoFlag                                       ='N';
    public static string strVisionAccount                                ='Vision Account';
    public static string strsysDown                                      ='System Down';
    public static string strSFAccount                                    ='Salesforce Account';
    public static string strException                                    ='Unknown Exception';
    public static string strNoAccount                                    ='Account doesnt exist';
    public static string strRequestID                                   ='X-MF-RequestId';
    // Set for the Closed Status
    public static set<string> setClosedStatus                           = new set<string>(gs.CCPM_cartClosedStatus__c.split(CCPM_staticConstants.strColon));
    
    // Lead Open Status Set
    public static set<String> setOpenLeadStatus                         = new set<String>(gs.CCPM_leadOpenStatus__c.split(CCPM_staticConstants.strColon));
    public static string strDataIntegrationUserID                      = gs.CCPM_dataIntegrationUserID__c;
    
    public static CCPM_storesNotConsidered__c SNC                       = CCPM_storesNotConsidered__c.getInstance();
    public static string setMarkets                                   = SNC.CCPM_market__c;
    public static string setDistricts                                 = SNC.CCPM_district__c;
    public static string setTerritorys                                = SNC.CCPM_territory__c;     
    public static string strNone                                        ='--None--';
    //Brigadesh US Campaign Static Constants Created
    public static string strpowerSymbol                                 =';;';
    public static string strLeadTypeCampaignLead                        ='Campaign Lead'; 
    public static String strLeadSourceCRM                               ='CRM';
     
    //Sriram US Campaign Messages For Trigger
    public static string strMessageTypeCampaignInitialSMSPart1          = 'CampaignInitialSMSPart1';
    public static string strMessageTypeCampaignInitialSMSPart2          = 'CampaignInitialSMSPart2';
    public static string strMessageTypeCampaignFollowUpSMS              = 'CampaignFollowUp';
    public static string strHUMCampaignName                             = 'HUM';
    public static string strAALCampaignName                             = 'AAL';
    public static string strCreditAppCampaignName                       = 'Credit App';
    public static string strSourceCheck                                 = 'strSourceCheck';
    public static string strEventTypeIphone                             = 'iPhone X';
    public static string strIphoneDynUrl                                =gs.CCPM_iphoneXUrl__c;
    public static string strPixelDynUrl                                =gs.CCPM_Pixelfuturedevice__c;
    public static String strDataDictionary                              = 'DataDictionary';
    public static Map<String, CCPM_suppressOutboundSMS__c>  mapSuppressOutboundMessage  = CCPM_suppressOutboundSMS__c.getAll();
        public static Boolean boolCustomSwitch                              = gs.CCPM_CustomSwitchToAvoidUpdateTrigger__c;

    
}