/**
*@name          CCPM_getLeadStatus
*@author        Aneesha Ragireddy(Deloitte)
@modification   Manjunath Keshava (Deloitte)
*@date          06/09/2017
@description   @(US_0392) this method makes a call out to vision based on the mtn and returns the account fields 
if vision  has the account 
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Aneesha Ragireddy(Deloitte)     07/02/2017                           Original Version
Manjunath Keshava (Deloitte)    07/19/2017                           Original Version(US-1640)
Manjunath Keshava (Deloitte)    08/20/2017                           Modified Version(US-1708)

*/
Global with sharing class CCPM_getLeadStatus 
{
    public static string s = null;
    public static Boolean isCurrentUserTelesalesUser = CCPM_utility.isCurrentUserTelesalesUser();
    public static Map<String, String> mapProfileIDName = CCPM_utility.getProfileIdNameMap(); 
    
    
    //to get the Lead status values
    @AuraEnabled
    public static List<String> getLeadStatusValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.Status.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    }
    //to get reason for purchase field  picklist value
    @AuraEnabled
    public static List<String> getReasonforPurchaseValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_reasonForPurchase__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        lstOptions.add( CCPM_staticConstants.strNone);
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    }  
    //to get event type picklist values
    /*  @AuraEnabled
public static List<String> getEventTypeValues(Boolean isManualLead){


Map<String, String> mapOptions = new Map<String, String>();
Schema.DescribeFieldResult objfieldResult = lead.CCPM_eventType__c.getDescribe();
List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
mapOptions.put(Label.CCPM_none, Label.CCPM_none);
//PRS
if (isManualLead  == true) {
mapOptions.put(Label.CCPM_NewEventTypeforManualLead,Label.CCPM_NewEventTypeforManualLead);
}
if(isCurrentUserTelesalesUser){
mapOptions.clear();
mapOptions.put(Label.CCPM_telesalesDefaultEventType, Label.CCPM_telesalesDefaultEventType);
}
for (Schema.PicklistEntry objPicklist: lstPle) {
if(objPicklist.getLabel()!=null && objPicklist.getLabel()!='iPhone X send message' && objPicklist.getLabel()!=Label.CCPM_telesalesDefaultEventType)
mapOptions.put(objPicklist.getLabel(), objPicklist.getLabel());
}
return mapOptions.values();


} */
    // to get preferred communication picklist values
    @AuraEnabled
    public static List<String> getCommPrefValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_communicationPreference__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    } 
    // to get channel picklist values
    @AuraEnabled
    public static List<String> getTransCompleteValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_Trans_Completion_Channel_Preference__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    } 
    //to get the quick notes value
    @AuraEnabled
    public static List<String> getQuickNotesDescriptionValues()
    {
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_quickNotesDescription__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    } 
    
    @AuraEnabled
    public static List<String> getCartStatusValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_cartStatus__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    } 
    // to pull the saluation picklist values n defaulting the value to none
    @AuraEnabled
    public static List<String> getSalutationValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.Salutation.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        lstOptions.add( CCPM_staticConstants.strNone);
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    } 
    
    @AuraEnabled
    public static List<String> getLeadSourceValues(){
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.LeadSource.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    }
    
    @AuraEnabled
    public static List<String> getClosedLeadSourceValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_closedLeadSource__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    }
    //current carrier picklist values
    @AuraEnabled
    public static List<String> getCurrentCarrierValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_currentCarrier__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        lstOptions.add( CCPM_staticConstants.strNone);
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    }
    //interested item values
    @AuraEnabled
    public static List<String> getItemsInterestedInValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_itemInterestedIn__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        lstOptions.add( CCPM_staticConstants.strNone);
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
        
    } 
    //to get the custom country picklist values
    @AuraEnabled
    public static List<String> getCountryValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_country__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) 
        {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
    }
    //to get the custom state picklist values
    @AuraEnabled
    public static List<String> getStateValues(){
        
        List<String> lstOptions = new List<String>();
        Schema.DescribeFieldResult objfieldResult = lead.CCPM_usstate__c.getDescribe();
        List<Schema.PicklistEntry> lstPle = objfieldResult.getPicklistValues();
        for (Schema.PicklistEntry objPicklist: lstPle) {
            if(objPicklist.getLabel()!=null)
                lstOptions.add(objPicklist.getLabel());
        }
        return lstOptions;
    }
    
    @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string strObjApiName , string strContrfieldApiName , string strDepfieldApiName){
        // system.debug(strObjApiName + '##' + strContrfieldApiName + '###' + strDepfieldApiName);
        
        String strObjectName = strObjApiName.toLowerCase();
        String strControllingField = strContrfieldApiName.toLowerCase();
        String strDependentField = strDepfieldApiName.toLowerCase();
        
        Map<String,List<String>> mapObjResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> mapObjGlobalMap = Schema.getGlobalDescribe();
        
        if (!Schema.getGlobalDescribe().containsKey(strObjectName)){
            //System.debug('OBJNAME NOT FOUND --.> ' + strObjectName);
            return null;
        }
        
        Schema.sobjectType objType = Schema.getGlobalDescribe().get(strObjectName);
        if (objType==null){
            return mapObjResults;
        }
        CCPM_Bitset objBitSetObj = new ccpm_Bitset();
        Map<String, Schema.SObjectField> mapObjFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!mapObjFieldMap.containsKey(strControllingField) || !mapObjFieldMap.containsKey(strDependentField)){
            //System.debug('FIELD NOT FOUND --.> ' + strControllingField + ' OR ' + strDependentField);
            return mapObjResults;     
        }
        
        List<Schema.PicklistEntry> lstContrEntries = mapObjFieldMap.get(strControllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> lstDepEntries = mapObjFieldMap.get(strDependentField).getDescribe().getPicklistValues();
        //system.debug('the list is'+lstContrEntries +lstDepEntries);
        mapObjFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<lstContrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = lstContrEntries[contrIndex];
            String strLabel = ctrlentry.getLabel();
            mapObjResults.put(strLabel,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> lstObjEntries = new List<Schema.PicklistEntry>();
        List<ccpm_PicklistEntryWrapper> lstObjJsonEntries = new List<ccpm_PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<lstDepEntries.size(); dependentIndex++){            
            Schema.PicklistEntry depEntry = lstDepEntries[dependentIndex];
            lstObjEntries.add(depEntry);
        } 
        lstObjJsonEntries = (List<CCPM_PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(lstObjEntries), List<CCPM_PicklistEntryWrapper>.class);
        List<Integer> lstIndexes;
        for (CCPM_PicklistEntryWrapper objJson : lstObjJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            lstIndexes = objBitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : lstIndexes){                
                String strContrLabel = lstContrEntries[idx].getLabel();
                mapObjResults.get(strContrLabel).add(objJson.label);
            }
        }
        lstObjEntries = null;
        lstObjJsonEntries = null;
        return mapObjResults;
    }
    
    
    //method to create a lead with the input values based on if its  a vision account or a salesforce account
    @AuraEnabled
    public static id createLeadRec(Lead objLead, Account objVsAccount,Account objSfAccount )
    {    
        try { 
            
            if( objVsAccount != null && objVsAccount.CCPM_mobileNumber__c!=null)
            {
                objVsAccount.CCPM_mobileNumber__c=  objVsAccount.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
            }
            if(objSfAccount!=null && objSfAccount.CCPM_mobileNumber__c!=null)
            {
                objSfAccount.CCPM_mobileNumber__c= objSfAccount.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
            }
            if(objlead!=null && objlead.CCPM_mobileNumber__c!=null)
            {
                objlead.CCPM_mobileNumber__c= objlead.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
            }
            if(objlead!=null && objlead.CCPM_confirmMTN__c!=null)
            {
                objlead.CCPM_confirmMTN__c= objlead.CCPM_confirmMTN__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
            }
            
            if(objVsAccount != null && objVsAccount.CCPM_mobileNumber__c == objLead.CCPM_mobileNumber__c && objVsAccount.CCPM_accountNumber__c!=null)
            {
                String strObjVsAccountNumber = objVsAccount.CCPM_accountNumber__c;
                String strBuildSOSLQuery = 'Find ';
                strBuildSOSLQuery = strBuildSOSLQuery + '\''+strObjVsAccountNumber+'\' IN ALL FIELDS RETURNING Account(Id, CCPM_accountNumber__c, CCPM_accountUniqueID__c)';
                //Query to check if the account returned from vision exists in Salesforce
                List<List<sObject>> lstSearchAccount = Search.query(strBuildSOSLQuery);
                //Map<id, Account> mapAccount = new Map<Id, Account>((List<Account>)lstSearchAccount[0]);
                List<Account> lstAccount = (List<Account>)lstSearchAccount[0];
                if(!(CCPM_Collection.isNotNullEmpty(lstAccount))){
                    //system.debug('*****mapAccount'+mapAccount);
                    //if there is an associated account then insert it and check the manual lead field to true;
                    insert objVsAccount;
                    objLead.CCPM_Account__c=objVsAccount.id;
                    objLead.CCPM_accountNumber__c=objVsAccount.CCPM_accountNumber__c;
                    objLead.CCPM_accountUniqueID__c=objVsAccount.CCPM_accountUniqueID__c;
                }
                else{
                    objLead.CCPM_Account__c=lstAccount[0].id;
                    objLead.CCPM_accountNumber__c=lstAccount[0].CCPM_accountNumber__c;
                    objLead.CCPM_accountUniqueID__c=lstAccount[0].CCPM_accountUniqueID__c;  
                }
                objLead.CCPM_leadType__c = isCurrentUserTelesalesUser ? Label.CCPM_CustomerTelesalesSFDCManual : Label.CCPM_CustomerSFDCManual;
                objLead.CCPM_isManualLead__c=true; 
                objLead.RecordTypeId=CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;
                
            }else if( objSfAccount!=null && objSfAccount.CCPM_mobileNumber__c == objLead.CCPM_mobileNumber__c)
            {
                //if there is an associated account then insert it and check the manual lead field to true;
                objLead.CCPM_leadType__c = isCurrentUserTelesalesUser ? Label.CCPM_CustomerTelesalesSFDCManual : Label.CCPM_CustomerSFDCManual;
                objLead.CCPM_isManualLead__c=true;
                objLead.CCPM_Account__c=objSfAccount.id;
                objLead.CCPM_accountNumber__c=objSfAccount.CCPM_accountNumber__c;
                objLead.CCPM_accountUniqueID__c=objSfAccount.CCPM_accountUniqueID__c;
                objLead.RecordTypeId=CCPM_staticConstants.strLeadCustomerAbandonedCartRecordTypeID;                
            }
            else {
                //populating lead type for prospect
                objLead.CCPM_leadType__c = isCurrentUserTelesalesUser ? Label.CCPM_ProspectTelesalesSFDCManual : Label.CCPM_ProspectSFDCManual;  
            }
            string strCompany; 
            strCompany = string.valueOf(objLead.Company);
            string strTimeStamp = string.valueOf(system.now());
            string strMtn= objlead.CCPM_mobileNumber__c;
            string strcartUniqueID= strTimeStamp + strMtn;
            objLead.Company = strCompany;
            objLead.CCPM_cartType__c = s;
            if(objlead.CCPM_reasonForPurchase__c==CCPM_staticConstants.strNone)
            {
                objlead.CCPM_reasonForPurchase__c=null;   
            }
            if(objlead.Salutation!=null && objlead.Salutation==CCPM_staticConstants.strNone)
            {
                objlead.Salutation=CCPM_staticConstants.strEmpty;
            }
            if(objlead.CCPM_SMSFollowUpDate__c == null)
            {
                objlead.CCPM_SMSFollowUpDate__c=system.now().addSeconds(360);
            }
            objLead.Status='New';
            
            objlead.CCPM_cartUniqueID__c=CCPM_EncryptKey.CCPM_EncryptKey(strcartUniqueID);
            if(objLead != null)
            {
                insert objLead; 
            }
            return objLead.Id; 
        } catch (Exception e) {
            String strdmlMessage;
            if(e.getTypeName()=='System.DmlException')
            {
                DmlException objdmlExc = (DmlException) e;
                for (integer i= 0; i<objdmlExc.getNumDml(); i++)
                {
                    strdmlMessage =    objdmlExc.getDmlMessage(i);
                }
            }
            else
            {
                strdmlMessage=e.getMessage();   
            }
            throw new AuraHandledException(strdmlMessage);
        } 
        
    }
    
    @AuraEnabled
    public static lead getRecord(Id recordId){
        Lead objLead = new Lead();
        if(recordId !=null){
            objLead = [select Id, Salutation, FirstName, LastName, Status, CCPM_leadSubStatus__c, CCPM_createdChannel__c, CCPM_mobileNumber__c, CCPM_confirmMTN__c, CCPM_email__c, CCPM_confirmEmail__c, CCPM_SMSLegalOptIn__c, Street, 
                       City, State,CCPM_usstate__c,RecordType.Developername,RecordTypeId,CCPM_Type__c, PostalCode, Country,CCPM_country__c, CCPM_reasonForPurchase__c, CCPM_eventType__c, CCPM_communicationPreference__c,CCPM_isManualLead__c, 
                       CCPM_SMSFollowUpDate__c, CCPM_reminder__c, CCPM_isMergedUIFlag__c, CCPM_currentCarrier__c, CCPM_Trans_Completion_Channel_Preference__c, CCPM_quickNotesDescription__c, CCPM_quickNotes__c, Company, CCPM_itemInterestedIn__c, CCPM_whenIsTheirContractUp__c from Lead where Id=:recordId];
            system.debug('*****objLead*******'+objLead.RecordType.Developername);
        } 
        return objLead;
    }
    
    @AuraEnabled
    public static Id updateLead(Lead objLead)
    {
        string strCompany = string.valueOf(objLead.Company);
        objLead.Company = strCompany;
        if(objlead.CCPM_country__c!=null & objlead.CCPM_country__c!=CCPM_staticConstants.strNone)
        {
            objlead.Country =objlead.CCPM_country__c;
        }
        if(objlead.CCPM_usstate__c!=null && objlead.CCPM_usstate__c!=CCPM_staticConstants.strNone)
        {
            objlead.State =objlead.CCPM_usstate__c;
        }
        if(objlead.CCPM_reasonForPurchase__c==CCPM_staticConstants.strNone)
        {
            objlead.CCPM_reasonForPurchase__c=null;   
        }
        if(objlead.CCPM_eventType__c==CCPM_staticConstants.strNone)
        {
            objlead.CCPM_eventType__c=null;   
        }
        if(objlead.Salutation!=null && objlead.Salutation==CCPM_staticConstants.strNone)
        {
            objlead.Salutation=CCPM_staticConstants.strEmpty;
        }
        if(objlead!=null && objlead.CCPM_mobileNumber__c!=null)
        {
            objlead.CCPM_mobileNumber__c= objlead.CCPM_mobileNumber__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
        }
        if(objlead!=null && objlead.CCPM_confirmMTN__c!=null)
        {
            objlead.CCPM_confirmMTN__c= objlead.CCPM_confirmMTN__c.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
        }
        if(objlead.CCPM_SMSFollowUpDate__c == null)
        {
            objlead.CCPM_SMSFollowUpDate__c=system.now().addSeconds(360);
        }
        
        try{
            
            if(objLead != null)
            {
                update objLead;
            }
            return objLead.Id;
        }catch (Exception e) {
            String strdmlMessage;
            DmlException objdmlExc = (DmlException) e;
            for (integer i= 0; i<objdmlExc.getNumDml(); i++)
            {
                strdmlMessage =    objdmlExc.getDmlMessage(i);
            }
            throw new AuraHandledException(strdmlMessage);
        } 
    }  
    
    @AuraEnabled
    public static void searchForRelatedAddress(string strsearchKeyVal){
    }
    /**
*@name          CCPM_getLeadStatus 
*@author        Manjunath Keshava (Deloitte)
*@date          07/22/2017
@description   @(US_1624) This is  a  method to retrieve account information from Salesforce and if not found then call out for vision and returns map if found. 
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    07/24/2017                           Original Version
*/
    
    @AuraEnabled
    public static Map<string,Account> searchAccount (string strMtn)
    { 
        
        // Account objofAccount = new Account();
        Map<string,Account>mapAccountSearch = new Map<string,Account>();
        List<List<Account>> lstleadAccList=new List<List<Account>>();
        if( strMtn!= NULL)
        {
            strMtn = strMtn.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
            lstleadAccList = [FIND :strMtn IN PHONE FIELDS RETURNING Account(Id,Name, CCPM_accountNumber__c, CCPM_mobileNumber__c ,CCPM_hasOptedOutOfEmail__c, CCPM_SMSOptOut__c, CCPM_hasOptedOutOfCall__c, CCPM_email__c, CCPM_accountUniqueID__c,CCPM_storeID__c ORDER BY createdDate Desc)limit 1 ];
        }
        
        List<Account> lstAccList = ((List<Account>)lstleadAccList[0]);
        //create a map between Mtn and Account
        map<string,Account> mapAccountByMtn = new map<string,Account>();
        if(lstAccList != null && !lstAccList.isEmpty())
        {
            for(Account objAcc:lstAccList)
            {
                objAcc.CCPM_mobilenumber__C = objAcc.CCPM_mobilenumber__C.replaceAll(CCPM_staticConstants.strnondigits,CCPM_staticConstants.strEmpty);
                if(objAcc.CCPM_mobilenumber__C!=null )
                {                    
                    mapAccountByMtn.put(objAcc.CCPM_mobilenumber__C, objAcc);
                }
            }  
            //if the map contains the lead's Mtn then pull them onto the leads account info
            if( mapAccountByMtn.containsKey(strMtn) )
            {
                mapAccountSearch.put(CCPM_staticConstants.strSFAccount,mapAccountByMtn.get(strMtn));
            }
        }
        else 
        { 
            mapAccountSearch = CCPM_getProspectAccountInformationVision.prospectAccountInfo(StrMtn);
            system.debug('the map is'+mapAccountSearch);
        }
        
        return mapAccountSearch;
    }
    /*
@AuraEnabled
public static map<String,list<CCPM_journeyMessage__c>> getJourneyMsg() {
Map<String, list<CCPM_journeyMessage__c>> mapEventJMRec = CCPM_utility.getEventlstJourneyMessageMap().get('EventSMSMap');
return mapEventJMRec;
}*/
    
    @AuraEnabled
    public static map<String,map<String,list<CCPM_smsTemplate__c>>> getEventTypeMap (String strUserId) {
        return ccpm_eventSmsUtil.getMapLeadTypeMapEvntLstSmsTemp(strUserId);
    }
    
    @Auraenabled
    public static boolean getIsTelesalesUser() {
        return isCurrentUserTelesalesUser;
    }
    
    @Auraenabled
    public static boolean getIscurrentUserhavingLeadCreatePermission() {
        list<String> lstRestrictedProfilesForLeadCreation = CCPM_utility.getListFromString(Label.CCPM_restrictedProfilesFromLeadCreation,',');        
        Boolean isUserProfileHavingPermission = lstRestrictedProfilesForLeadCreation.contains(mapProfileIDName.get(userinfo.getProfileId())) ? false: true;
        return isUserProfileHavingPermission;
    }
    
    @Auraenabled
    public static boolean getUserProfilePermissionforNotes() {
        list<String> lstRestrictedProfilesForLeadNotesUpdate = CCPM_utility.getListFromString(Label.CCPM_restrictedProfilesFromLeadNotesUpdate,',');        
        Boolean isPermissionRestricted = lstRestrictedProfilesForLeadNotesUpdate.contains(mapProfileIDName.get(userinfo.getProfileId())) ? true : false;
        return isPermissionRestricted;
    }
    
    @Auraenabled
    public static boolean getUserProfilePermissionforStatus() {
        Boolean isRetailMarketAnalyst = Label.CCPM_retailMarketAnalysts.equals(mapProfileIDName.get(userinfo.getProfileId())) ? true : false;
        return isRetailMarketAnalyst;
    }    
}