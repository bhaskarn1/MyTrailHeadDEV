/**
*@name          CCPM_Collection 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          10/18/2017
*@description   This is a controller or class
*@Class         CCPM_Collection
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    10/18/2017   Initial Implementation.
*/
public with sharing class CCPM_Collection  {
    
    /**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0 
	@param         Map<Id, sObject>
	@return        Boolean
	*/ 
    public static Boolean isNotNullEmpty(Map<Id, sObject> mapIDSObject){
		if(mapIDSObject != null && !mapIDSObject.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Map<String, sObject>
	@return        Boolean
	*/ 
	public static Boolean isNotNullEmpty(Map<String, sObject> mapStrSObject){
		if(mapStrSObject != null && !mapStrSObject.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	/**
	@author        Sriraman Sridharan (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Map<String, sObject>
	@return        Boolean
	*/ 
	public static Boolean isNotNullEmpty(Map<String, String> mapStrSObject){
		if(mapStrSObject != null && !mapStrSObject.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	}
    /**
	@author        Sriraman Sridharan (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Map<String, sObject>
	@return        Boolean
	*/ 
	public static Boolean isNotNullEmpty(Set<ID> setString){
		if(setString != null && !setString.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Map<String, sObject>
	@return        Boolean
	*/ 
	public static Boolean isNotNullEmpty(Map<String, Set<String>> mapIn){
		if(mapIn != null && !mapIn.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	
      /**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Map<String, String>
	@return        Boolean
	*/ 
	public static Boolean isNotNullEmpty(Map<String, Boolean> mapIn){
		if(mapIn != null && !mapIn.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	}
    
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Map<String, sObject>
	@return        Boolean
	*/ 
	public static Boolean isNotNullEmpty(Map<String, List<sObject>> mapIn){
		if(mapIn != null && !mapIn.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	}
	
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         List<sObject> 
	@return        Boolean
	*/
	public static Boolean isNotNullEmpty(List<sObject> lstSObject){
		if(lstSObject != null && !lstSObject.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         List<String> 
	@return        Boolean
	*/
	public static Boolean isNotNullEmpty(List<String> lstString){
		if(lstString != null && !lstString.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Set<sObject> 
	@return        Boolean
	*/
	public static Boolean isNotNullEmpty(Set<sObject> setSObject){
		if(setSObject != null && !setSObject.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns true if the param passed is not null or size > 0
	@param         Set<String> 
	@return        Boolean
	*/
	public static Boolean isNotNullEmpty(Set<String> setString){
		if(setString != null && !setString.isEmpty()){
			return true;
		}			
		else{
			return false;
		}
	} 
	/**
	@author        Bharath Ammanamanchi (Deloitte)
	@description   This method returns a Set of String sperated by the Seperated Param provided
	@param         Set<String> 
	@return        String, String
	*/
	public static Set<String> populateSetFromString(String strInput, String strSeperator){
		Set<String> setToReturn = new Set<String>();
		if(String.isNotBlank(strInput)){
			for(String strS : strInput.split(strSeperator)){
				setToReturn.add(strS);
			}
		}
		return setToReturn;
	}
}