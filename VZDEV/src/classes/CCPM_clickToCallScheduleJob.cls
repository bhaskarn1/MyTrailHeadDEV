/**
*@name          CCPM_clickToCallScheduleJob
*@author        Sriraman Sridharan (Deloitte)
*@date          04/06/2018
@description    DISTSCE-3054  
@testClass      
Modification    Log:
------------------------------------------------------------------------------------
Developer               			Date                           Description
------------------------------------------------------------------------------------
Sriraman Sridharan (Deloitte)    04/06/2018          			Original Version   
   
*/ 
global class CCPM_clickToCallScheduleJob implements Schedulable {
/* 
* Method Name: execute
* Author     : Sriraman Sridharan (Deloitte)
* Date       : 04/06/2018
* Description: This method is used to execute the batch job with specific batch size    
*/  
    
    global void execute(SchedulableContext BG)    
    {
        // Creating the object for the Batch Class and invoking the batch execution  
        Datetime objCurrentDateTime = System.now().addMinutes(-30);
        string strDate = objCurrentDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        string strquery = 'select id, CreatedDate, CCPM_callStatus__c from CCPM_callDetails__c where CCPM_callStatus__c = \'Call In-Progress\' AND CreatedDate < ' + strDate;
       // system.debug('@@@strquery : ' + strquery);
        List<CCPM_callDetails__c> lstcallDetails = Database.query(strquery);
       // system.debug('@@@lstcallDetails : ' + lstcallDetails);
        
        if(CCPM_Collection.isNotNullEmpty(lstcallDetails)){
            for(CCPM_callDetails__c objCallDetails : lstcallDetails){
                objCallDetails.CCPM_callStatus__c = label.CCPM_StatusResponseFailed;
            }
            try{
                update lstcallDetails;
            }
            Catch(Exception e){
                LOG_LogMessage__c objLogError = CCPM_utility.logMessage(e,'Error','execute','CCPM_clickToCallScheduleJob','Exception thrown while updating call details','');
                insert objLogError;
            }
        }
        /*
        String StrCRONEXP = '0 15 * * * ?'; 
		CCPM_clickToCallScheduleJob objSch = new CCPM_clickToCallScheduleJob(); 
		system.schedule('CCPM_clickToCallBatchJob- 15 Mins', StrCRONEXP, objSch);*/
    }   
}