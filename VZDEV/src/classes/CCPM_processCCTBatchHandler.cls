/**
*@name          CCPM_processCCTBatchHandler
*@author        Brigadesh Chandrasekar (Deloitte)
*@date          02/14/2018
@description    Handler class to process converted Leads to extract the commisionable Cart Type Records and mark Lead commissionable
@testClass      CCPM_processCCTBatchHandlerTestClass
Modification    Log:
------------------------------------------------------------------------------------------------
Developer             				  					Date       			Description
------------------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)        			12/12/2017    		Original Version					
*/

public class CCPM_processCCTBatchHandler {
    public static Map<String, BusinessHours> mapBusinessHoursNameRec = CCPM_utility.mapBusinessHoursNameRec;
    public static Set<String> setQueueIDs = CCPM_utility.populateQueueIds();
    public static set<id> setLeadOwnerIDs = new set<id>();
    public static list<CCPM_leadOwnerWrapper> lstOwnerWrapper= new list<CCPM_leadOwnerWrapper>();
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   The Method entry for Batch Class
*/ 
    public static void extractCartTypes(List<Lead> lstConvertedLead){
        //Validate if there are any leads coming in through the Scope 
        if(CCPM_Collection.isNotNullEmpty(lstConvertedLead)){ 
            //Initialization of List Of Leads to Update
            list<Lead> lstLead = new list<Lead>();
            //Initialization of public list of Cart types to insert
            list<CCPM_CartType__c> lstCartType = new list<CCPM_CartType__c>();
            //Initialization of list of Journey's to be inserted
            List<CCPM_journey__c> lstJourney = new List<CCPM_journey__c>();
            //Initialization of set of strings to Store MTN for capturing open Leads
            set<String> setMTN = new set<String>();
            //Set String for list of Commissionable cart types saved in Label 
            set<String> setCommisionableCartType = new set<String>();
            //Set String of ESN codes saved into the set from list
            set<String> setESNCodes = new set<String>();
            //Initialize list to store all Commissionable cart types
            list<String> lstCommisionableCarttypes = new list<String>();
            //Validate if the label storing Commisionable cart types are not null
            if(label.CCPM_commisionableCartType!=null)
            {	
                System.debug('Label containing values for Commissionable CartType->'+label.CCPM_commisionableCartType);
                //Obtain the values of all Commissionable cart types from Label and split based on the delimeter
                lstCommisionableCarttypes = label.CCPM_commisionableCartType.split(',');
                System.debug('lstCommisionableCarttypes->'+lstCommisionableCarttypes);
                //Validate if the list is not Empty
                if(!lstCommisionableCarttypes.isEmpty())
                {	//Load the list into a set to store all commissionable cart types	
                    setCommisionableCartType.addAll(lstCommisionableCarttypes);
                }
                System.debug('setCommisionableCartType->'+setCommisionableCartType);
            }
            
            
            //Store the List into Set of ESN codes
            for(CCPM_ESNCodes__c objESNCodes : [select id,Name from CCPM_ESNCodes__c where CCPM_isActive__c=true])
            {
                setESNCodes.add(objESNCodes.Name);
            }
            System.debug('setESNCodes->'+setESNCodes);
            
            
            //For Every Lead obtained from calling out to the handler method from the Scope Context
            for(Lead objLead: lstConvertedLead) {
                System.debug('Inside list of Leads that are iterated for the scope obtained in the batch job->');
                //Make a callout to Process Individual Converted Leads
                objLead = processConvertedLeads(objLead,lstCartType,setESNCodes,setMTN,setCommisionableCartType);
                //Add the processed Lead into the List of final leads that needs update
                lstLead.add(objLead);
                //Create Journey record for each converted record
                CCPM_journey__c objJourney = CCPM_utility.createJourneyForCLosedLead(objLead);
                system.debug('objJourney'+objJourney);
                //Add the journey record into the list of final jouney's to be inserted
                lstJourney.add(objJourney);
            }
            system.debug('***lstJourney****'+lstJourney);
            //Make a callout to the Method to perform the final DML operations   
            doUpdates(lstCartType,lstLead,setMTN, lstJourney);   
        }
    }
    
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   The Method to process Converted leads
*/ 
    public static Lead processConvertedLeads(Lead objLead,list<CCPM_CartType__c> lstCartType,set<string> setESNCodes,set<String> setMTN,set<String> setCommisionableCartType)
    {
        System.debug('Inside processConvertedLeads method');
        //Set the Processed type on the Lead to indicate that it shouldnt be picked up in the batch again
        objLead.CCPM_cartTypeProcessed__c = true;
        //Temporary List of Cart types, that gets destroyed after each execution
        list<CCPM_CartType__c> lstTempListCartType = new list<CCPM_CartType__c>();
        //Validate if the mobile number on the closed lead is available to extract all associated open Leads for them
        if(objLead.CCPM_mobileNumber__c != null){
            System.debug('Inside check for Mobile number of Customer->'+objLead.CCPM_mobileNumber__c);
            //Set of MTN storing all MTN's in context
            setMTN.add(objLead.CCPM_mobileNumber__c);	
        }
        //Validate if there is any value stored in the Converted Cart type text field
        if (objLead.CCPM_convertedCartType__c != null && objLead.CCPM_convertedCartType__c != '') {
            System.debug('Inside the condition after checking for Converted Cart type not being equal to null'+objLead.CCPM_convertedCartType__c);
            //Process Individual cart types
            lstTempListCartType=processCartType(objLead,setESNCodes,setCommisionableCartType);
            //Validate if the list returned is not Empty
            if(!lstTempListCartType.isEmpty())
            {	//Add it to the public list of Cart types to be inserted
                lstCartType.addAll(lstTempListCartType);
            }
        }
        return objLead;
        
    }
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   The Method processes Cart Types
*/ 
    public static list<CCPM_CartType__c> processCartType(Lead objLead,set<string> setESNCodes,set<String> setCommisionableCartType)
    {	
        System.debug('Inside process Cart Type Method');
        List<CCPM_CartType__c> lstCartType = new List<CCPM_CartType__c>();
        List<String> lstCartTypes = new List<String>();
        boolean boolFlagtoScheduleSMS = false;
        //Extract the Individual cart types with ESN codes(if applicable) into a list
        lstCartTypes = CCPM_utility.getListFromString(objLead.CCPM_convertedCartType__c, ','); 
        System.debug('lstCartTypes->'+lstCartTypes);
        //Iterating over each element in the list to mark them commissionable if applicable
        for (String strIndividualCartType : lstCartTypes)
        {	
            //Instantiating new Object for Cart type
            CCPM_CartType__c objCartType = new CCPM_CartType__c();
            System.debug('EUP Label Extraction value->'+Label.CCPM_EUPlabel);
            //Validate if there is a cart type of EUP
            if(strIndividualCartType.contains(Label.CCPM_EUPlabel))
            {	
                System.debug('Inside if after checking for the Label EUP-->');
                list<String> lstCartTypeESN = new list<String>();
                //Extract ESN codes associated with EUP cart type  
                lstCartTypeESN = CCPM_utility.getListFromString(strIndividualCartType, '-');
                System.debug('lstCartTypeESN->'+lstCartTypeESN);
                //Validate if the list is empty
                if(!lstCartTypeESN.isEmpty())
                {
                    //Store the Cart type
                    if(lstCartTypeESN[0]!=null && lstCartTypeESN[0]!='')
                    {
                        objCartType.CCPM_CartType__c = lstCartTypeESN[0].trim();
                    }
                    if(lstCartTypeESN[1]!=null && lstCartTypeESN[1]!='')
                    {	
                        //Store the ESN codes into field on the Cart type object
                        objCartType.CCPM_ESNCode__c =lstCartTypeESN[1].trim();
                        if(setESNCodes!=null && !setESNCodes.isEmpty() && setESNCodes.contains(lstCartTypeESN[1].trim()))
                        {	//Check the flag to indicate the Commissionable criteria
                            objCartType.CCPM_CommissionEligible__c=true; 
                            boolFlagtoScheduleSMS=true;
                        }
                    }
                    
                }
            }
            else
            {
                objCartType.CCPM_CartType__c=strIndividualCartType.trim();
                //Validate for Commissionable cart types without ESN codes
                if(setCommisionableCartType!=null && !setCommisionableCartType.isEmpty() && setCommisionableCartType.contains(objCartType.CCPM_CartType__c))
                {
                    objCartType.CCPM_CommissionEligible__c=true; 
                    boolFlagtoScheduleSMS=true;
                }
                
            }
            //Validate if the Label for the cart type storing Other is not empty
            if(Label.CCPM_cartTypeOTHER!=null && Label.CCPM_cartTypeOTHER!='')
            {
                objCartType.CCPM_CartTypeMapping__c = CCPM_utility.setCartTypeValues.contains(objCartType.CCPM_CartType__c) ? objCartType.CCPM_CartType__c : Label.CCPM_cartTypeOTHER;
            }
            
            System.debug('objCartType->'+objCartType);
            objCartType.Lead__c=objLead.Id;
            lstCartType.add(objCartType);
        }
        
        if(boolFlagtoScheduleSMS && setQueueIDs!=null && setQueueIDs.isEmpty()==false && !setQueueIDs.contains(objLead.ownerid))
        {
            setLeadOwnerIDs.add(objLead.ownerid);
            CCPM_leadOwnerWrapper objownerMap = new CCPM_leadOwnerWrapper();
            objownerMap.idOwner = objLead.ownerid;
            objownerMap.objLead = objLead; 
            lstOwnerWrapper.add(objownerMap);
            System.debug('lstOwnerWrapper->'+lstOwnerWrapper);
        }
        
        return lstCartType;
    }
    
    /**
*@author        Brigadesh (Deloitte)
*@description   The Method that performs final DML Statements
*/ 
    public static void doUpdates(List<CCPM_CartType__c> lstCartType,list<Lead> lstConvertedlead,Set<String> setMTN, List<CCPM_journey__c> lstJourney)
    {	
        System.debug('Inside doUpdates->');
        //Initialization of public list of SMS messages to Insert
        list<CCPM_SMSMessage__c> lstSMSforConvertedLead = new list<CCPM_SMSMessage__c>();
        Map<id,User> mapLeadOwners = new Map<id,User>();
        List<LOG_LogMessage__c> lstBatchLogMsg = new List<LOG_LogMessage__c>();
        Map<String, Lead> mapOpenLeads = new Map<String, Lead>();
        Savepoint sp = Database.setSavepoint();
        boolean boolContinue = true;
        try
        { 
            if(CCPM_Collection.isNotNullEmpty(lstCartType))
            {
                insert lstCartType;
            } 
        }
        catch(Exception e)
        {
            boolContinue = false;
            lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processCCTBatchHandler','processConvertedLeadsCartTypes','Exception thrown while creating records for Converted Cart Types',''));
        }
        try
        { 
            if(CCPM_Collection.isNotNullEmpty(lstJourney))
            {
                insert lstJourney;
            } 
        }
        catch(Exception e)
        {
            boolContinue = false;
            lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processCCTBatchHandler','processConvertedLeadsCartTypes','Exception thrown while inserting Journey record', ''));
        }
        
        if(lstOwnerWrapper!=null && lstOwnerWrapper.isEmpty()==false){
            try{
                System.debug('mapLeadOwners->'+mapLeadOwners);
                mapLeadOwners = new map<id,User>([select id,MobilePhone,firstname,LastName,CCPM_commissionableRepID__c from user where id in :setLeadOwnerIDs and mobilephone!=null and isactive=true]);
            }Catch(Exception e)
            {	
                lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processCCTBatchHandler','Sending SMS','Exception thrown while querying for the owner details',''));
                
            }
        }
        
        
        if(mapLeadOwners.keySet()!=null && mapLeadOwners.keySet().isEmpty()==false) 
        {
            for(CCPM_leadOwnerWrapper objwrapper : lstOwnerWrapper) 
            {	
                if(mapLeadOwners.containsKey((objwrapper.idowner)))
                {	
                    String strFirstName;
                    if(mapLeadOwners.get(objwrapper.idowner).firstname!=null)
                    {
                        strFirstName = mapLeadOwners.get(objwrapper.idowner).firstname;
                    }
                    else{
                        strFirstName = '';
                    }
                    if((objwrapper.objLead.CCPM_isInitialSMSSent__c || objwrapper.objLead.CCPM_isProspectSMSsent__c) && objwrapper.objLead.CCPM_isRepEcodeMatching__c && !objwrapper.objlead.CCPM_conversionEligible__c)
                    {
                        lstSMSforConvertedLead.add(CCPM_utility.createRecordsForSmsMessageObject(objwrapper.objLead, label.CCPM_commissionableSMS.replace('<rep name>',strFirstName), mapLeadOwners.get(objwrapper.idowner).MobilePhone, Label.CCPM_commissionableSMSType,Label.CCPM_taskCommunicationOutbound,CCPM_utility.calculateTimeToTriggerSMSWithInBusinessHours(mapBusinessHoursNameRec.get(objwrapper.objLead.CCPM_StoreTimeZone__c), System.now()), Label.CCPM_liveTextPhoneNumber));  
                    }
                    
                }
                
            }
        }
        
        if(lstSMSforConvertedLead!=null && lstSMSforConvertedLead.isEmpty()==false)
        {
            try
            { 
                System.debug('lstSMSforConvertedLead');
                insert lstSMSforConvertedLead;
                setLeadOwnerIDs.clear();
                lstOwnerWrapper.clear();
                
            }
            catch(Exception e)
            {
                boolContinue = false;
                lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processCCTBatchHandler','processConvertedLeadsCartTypes','Exception thrown while creating records for SMS message',''));
            }
            
        }
        /************************************************/
        
        try
        { 
            if(CCPM_Collection.isNotNullEmpty(lstConvertedLead) && boolContinue){
                update lstConvertedLead;	
            }
            
        }
        catch(Exception e)
        {
            boolContinue = false;
            lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while updating the Converted Lead records',''));
        }
        //Code to update the existing open leads
        if(CCPM_Collection.isNotNullEmpty(setMTN)){
            Set<String> setOpenLeadStatus = CCPM_utility.setleadOpenStatus;
            List<String> lstNewMTN = new List<String>();
            lstNewMTN.addAll(setMTN);
            String strBuildSOSLQuery = 'FIND \''+String.join(lstNewMTN, ' OR ')+'\' IN PHONE FIELDS RETURNING LEAD (id,CCPM_mobileNumber__c WHERE Status IN :setOpenLeadStatus Order By CreatedDate ASC)';
            List<List<sObject>> lstSearchLead = Search.query(strBuildSOSLQuery);
            Map<Id, Lead> mapLead = new Map<Id, Lead>((List<Lead>)lstSearchLead[0]);
            for(Lead objLead : mapLead.values()){
                if(!mapOpenLeads.containsKey(objLead.CCPM_mobileNumber__c)){
                    mapOpenLeads.put(objLead.CCPM_mobileNumber__c, new Lead(id=objLead.id));
                }
            }
        } 
        //******to get a difference in time between converted leads and Open leads			
        Datetime timeToUpdate = System.now().addSeconds(Integer.valueOf(Label.CCPM_openLeadsUpdateGap));
        while(System.now() < timeToUpdate){
        } 
        
        //******end
        
        try{
            if(CCPM_Collection.isNotNullEmpty(mapOpenLeads.values()) && boolContinue){
                update mapOpenLeads.values();
            }
        }
        catch(Exception e)
        {
            boolContinue = false;
            lstBatchLogMsg.add(CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while updating the Open Lead records',''));
        }
        
        try{
            if(boolContinue == false){
                Database.rollback(sp);	
            }  
            if(CCPM_Collection.isNotNullEmpty(lstBatchLogMsg)){
                upsert lstBatchLogMsg;
            }
            
        }  
        catch(Exception e){
            insert CCPM_utility.logMessage(e,'Error','CCPM_processConvertedLeadsBatchHandler','processConvertedLeadsCartTypes','Exception thrown while inserting logs','');
        }
        
        
        
        
    }
    /**
*@author        Brigadesh (Deloitte)
*@description   Wrapper class to store the Lead and associated owner
*/ 
    public class CCPM_leadOwnerWrapper{
        public id idowner{get;set;}
        public lead objLead{get;set;}
        
    }
    
    
    
}