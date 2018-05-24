/**
*@name          CCPM_globalUtility
*@author        Brigadesh Chandrasekar(Deloitte)
*@date          14/12/2016
@description    US-0029: Assigns Sharing Settings when a Cart is created 
				US-0095: Makes a call to HTTP handler class(CCPM_serviceCallOutUtility)
Modification    Log:
----------------------------------------------------------------------------------------------------------
Developer               Date                                Description
----------------------------------------------------------------------------------------------------------
Brigadesh Chandrasekar(Deloitte)    14/12/2016          	Original Version
Brigadesh Chandrasekar(Deloitte)	03/01/2017              Original Version
Deepak Mazumdar(Deloitte)			16/01/2017				Removed "makeCallout" method as SMS is not sent
															via OneMessage
*/

public class CCPM_globalUtility {
    
    /**
	*@author        Brigadesh Chandrasekar (Deloitte)
	*@description   This method is targeted to handle the operations on lead records after updating/Inserting to Set Sharing Rules
	*@param         Id of the Record that needs Sharing Settings, Id of the User who is given the Write Access on the record
	*@return        LeadShare Record
	**/     
    public static leadshare apexShareReadAccess(id idRecordId, id idUserOrGroupId){
        
        // Create new sharing object for Cart
        leadshare CCPM_leadShr      = new leadshare();
        
        // Set the ID of record being shared.
        CCPM_leadShr.leadId         = idRecordId;
        
        // Set the ID of user or group being granted access.
        CCPM_leadShr.UserOrGroupId  = idUserOrGroupId;
        
        // Set the access level.
        CCPM_leadShr.leadAccessLevel= 'Edit';
        
        // Database.SaveResult sr   = Database.insert(CCPM_leadShr,false);
        // Returning the leadshare created
        return CCPM_leadShr;
    }
    
 	/**
	*@author        Brigadesh Chandrasekar (Deloitte)
	*@description   This method is targeted to make the Call out to One Message API
	*@param         String: AppId,BPId,ESRId,MTN,SId,CusId,AccNo,ECPDId,ContractID
	*@return        HttpResponse
	**/    
    /*
    public static HttpResponse makeCallout(String strAppId,String strBPId,String strESRId,String strMTN,String strSId,String strCusId,String strAccNo,String strECPDId,String strContractID)
    {
 		//Obtaining the custom setting for whether the call needs to be maded either to the One Message API or Mock API
        CCPM_globalSetting__c settings=CCPM_globalSetting__c.getOrgDefaults();
        
        //Make callout to the One Message API if the checkbox(CCPM_useOneMessageMock__c) in global settings is set to false
        if(!settings.CCPM_useOneMessageMock__c)
        {
            HttpResponse response    = CCPM_serviceCallOutUtility.createHTTPReq(strAppId,strBPId,strESRId,strMTN,strSId,strCusId,strAccNo,strECPDId,strContractID);
            return response;
        }
        //Make a callout to mock API otherwise
        else
        {
            HttpRequest req			= new HttpRequest();
            CCPM_mockAPI mockAPI	= new CCPM_mockAPI();
            HTTPResponse response	= mockAPI.respond(req);
            return response;
        }
    }
    */
}