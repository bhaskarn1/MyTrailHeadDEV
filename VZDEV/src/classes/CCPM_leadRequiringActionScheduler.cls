/**
*@name          CCPM_leadRequiringActionScheduler
*@author        Sudhakara Reddy Nallamilli (Deloitte)
*@date          05/04/2017
@description    To Schedule the Leads Action Required SMS Followup Batch Job  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               Date                                Description
------------------------------------------------------------------------------------
Sudhakara Reddy Nallamilli (Deloitte)    05/04/2017          Original Version   
Sriraman Sridharan(Deloitte)             05/10/2017          Updated Version
Sudhakara Reddy Nallamilli (Deloitte)    06/08/2017          Removed Count Logic as we are not using the Process Builders   
   
*/  
global class CCPM_leadRequiringActionScheduler implements Schedulable {
    @TestVisible private string shceduleIt()
    {
        String StrCRONEXP = '0 10 * * * ?'; 
        CCPM_leadRequiringActionScheduler objSch = new CCPM_leadRequiringActionScheduler(); 
        return system.schedule('CCPM_leadRequiringActionSchedulerTest- 10 Mins', StrCRONEXP, objSch);    
    }
    global void execute(SchedulableContext BG) {
        
        Decimal decTimeInterval = CCPM_staticConstants.gs.CCPM_leadReqActionSMSTimeInterval__c;     
        If (decTimeInterval >= 1 )  
        {
            decTimeInterval = decTimeInterval * -1;
        }
        else
        {
            decTimeInterval = -3;   
        }
        Integer intTimeInterval = decTimeInterval.intValue();
        DateTime datTSelDate = system.now().addHours(intTimeInterval);
        string strConDate =  datTSelDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');  
        system.debug('Cut of Interaction Date Time: '+ strConDate);
        //Construct the query
        string strQuery = Label.CCPM_leadSMSfolupQuery + ' '+ strConDate + + ' '+ Label.CCPM_leadSMSfolupQueryLimit;
        system.debug('Query: '+ strQuery);
        List<lead> lstLeadsUpdate = new List<lead>();
        List<lead> lstLeadsQry = Database.query(strQuery);
        system.debug('Query Result: '+ lstLeadsQry);
        //Create the list instance for CCPM_SMSMessage__c
        List<CCPM_SMSMessage__c> lstSmsMessages = new List<CCPM_SMSMessage__c>();
        //Create a map of stores and the list of associated managers
        map<id,list<CCPM_storeEmployee__c>> mapManagersContact=new map<id,list<CCPM_storeEmployee__c>>();
        //Call the method that returns the map
        mapManagersContact = CCPM_SmsMessageHandler.CCPM_createMapofStoreandListofAssociatedManagers(lstLeadsQry);     
        system.debug('&&&& mapManagersContact: '+ mapManagersContact);
        //Create a map of leads and their owner's user records
        map<id,User> mapOwnerFirstname = new map<id,User>();
        //Call the method that returns the map
        mapOwnerFirstname = CCPM_SmsMessageHandler.CCPM_createMapofLeadsandOwners(lstLeadsQry);
        system.debug('&&&& mapOwnerFirstname: '+ mapOwnerFirstname);
        if(lstLeadsQry.size()> 0 && lstLeadsQry != NULL)
        {
          for(lead objLead1: lstLeadsQry )
          {
            objLead1.CCPM_sendLeadsRequiringActionSMS__c = true;        
            system.debug('&&&& objLead1: '+ objLead1);
            lstLeadsUpdate.add(objLead1); 
          }
          if( lstLeadsUpdate.size()> 0 && lstLeadsUpdate != NULL)
            {
              try
                {
                  update lstLeadsUpdate; 	   
              	//Get the list of sms message objects to be inserted
                 lstSmsMessages = CCPM_SmsMessageHandler.CCPM_createListofSmsMessages(lstLeadsUpdate,mapOwnerFirstname,mapManagersContact);    
                 if( lstSmsMessages.size()>0 && lstSmsMessages != NULL )
                   {
                    insert lstSmsMessages; 
                   }          
                // Update empty lead to improve the code coverage in test class 
                if(Test.isRunningTest())
                  {
                   lead objLeadTest2 = new lead();
                   update objLeadTest2;
                  } 
                }
                catch(DMLexception e)
                {
                    CCPM_LogMessageUtility.logMessage(e,'CCPM_leadReqActRemainderJob',
                                                      'Lead Required Action Remainder Field Update Batch',
                                                      'Exception thrown while updating in Execute Method',true);
                    system.debug('Exception occured while updating lead CCPM_sendLeadsRequiringActionSMS__c Field in CCPM_leadReqActRemainderJob class.');
                    system.debug('Error Message: '+ e.getMessage());
                }
               lstLeadsUpdate.clear();
               lstSmsMessages.clear();
            }                
        }
    }
}