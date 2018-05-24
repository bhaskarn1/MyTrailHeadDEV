/**
*@name          CCPM_eventSMSUtil 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          03/10/2018
*@description   This is a class For Event Framework. 
*@Class         CCPM_eventSMSUtil
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    03/10/2018   Initial Implementation.
*/
public class CCPM_eventSMSUtil {
    
    /**
@author        Bharath Ammanamanchi(Deloitte)
@description   Method to return Map of Lead Type and Map of event types and List of Sms templates to be displayed on the UI
				This method is put here as this is needed only for UI and webservice.
@param         String
@return        Map<String, Map<String, List<CCPM_smsTemplate__c>>>
*/    
    public static Map<String, Map<String, List<CCPM_smsTemplate__c>>> getMapLeadTypeMapEvntLstSmsTemp(string strUserId){
        Map<String, Map<String, List<CCPM_smsTemplate__c>>> mapLeadTypeEvntTypeLstSmsTempMap = new Map<String, Map<String, List<CCPM_smsTemplate__c>>>();
        String strTimeZone = UserInfo.getTimeZone()+'';
        
        String strSegQuery = 'Select id, CCPM_campaign__r.Name, CCPM_campaign__r.CCPM_eventStartDate__c, CCPM_campaign__r.CCPM_eventEndDate__c,'+
            'CCPM_campaign__r.CCPM_eventSMSFollowUpStartDate__c, CCPM_campaign__r.CCPM_eventSMSFollowUpEndDate__c, CCPM_campaign__r.CCPM_leadCustomerType__c, CCPM_campaign__r.CCPM_eventLabel__c,'+
            '(Select id, CCPM_eventMessageStartDate__c, CCPM_eventMessageEndDate__c, CCPM_startDate__c, CCPM_endDate__c, CCPM_customerMessage__c,'+ 
            '	CCPM_eventCampaignId__c, CCPM_prospectMessage__c  FROM CCPM_smsTemplates__r Where CCPM_isActive__c = true)'+
            'From CCPM_segmentation__c Where CCPM_isActive__c = true AND CCPM_campaign__r.IsActive=true ';
        String strChannel = '';
        String strMarket = '';
        String strTerritory = '';
        String strDisctict = '';
        
        if(String.isNotBlank(strUserId)){
            CCPM_storeEmployee__c objrStoreEmpRec = CCPM_utility.getUserStoreEmpRec(strUserId);
            if(objrStoreEmpRec != null){
                if(String.isNOtBlank(objrStoreEmpRec.CCPM_Store__r.CCPM_TimeZone__c)){
                    strTimeZone = CCPM_utility.mapBusinessHoursNameRec.get(objrStoreEmpRec.CCPM_Store__r.CCPM_TimeZone__c).TimeZoneSidkey;
                }
                
                strChannel = (objrStoreEmpRec.CCPM_Store__r.CCPM_source__c == null || objrStoreEmpRec.CCPM_Store__r.CCPM_source__c == 'Retail') ? 'Retail' : objrStoreEmpRec.CCPM_Store__r.CCPM_source__c;
                strMarket = objrStoreEmpRec.CCPM_Store__r.CCPM_market__c;
                strTerritory = objrStoreEmpRec.CCPM_Store__r.CCPM_territory__c;
                strDisctict = objrStoreEmpRec.CCPM_Store__r.CCPM_district__c;
                strSegQuery = strSegQuery + 'AND CCPM_channels__c includes (:strChannel) AND CCPM_markets__c includes (:strMarket) AND CCPM_territories__c includes (:strTerritory) AND '+
                    '(CCPM_districts1__c includes (:strDisctict) OR CCPM_districts2__c includes (:strDisctict) OR CCPM_districts3__c includes (:strDisctict)) ';
            }
        }
        strSegQuery = strSegQuery+'Order By CCPM_campaign__r.CCPM_eventOrder__c ASC';
        List<CCPM_segmentation__c> lstSeg= Database.query(strSegQuery);
        
        if(CCPM_Collection.isNotNullEmpty(lstSeg)){
            for(CCPM_segmentation__c objseg: lstSeg){        
                DateTime dtmEvntStartDate = objseg.CCPM_campaign__r.CCPM_eventStartDate__c != null ? CCPM_utility.getDtTimeForTimeZone(objseg.CCPM_campaign__r.CCPM_eventStartDate__c, strTimeZone) : null;
                DateTime dtmEvntEndDate = objseg.CCPM_campaign__r.CCPM_eventEndDate__c != null ? CCPM_utility.getDtTimeForTimeZone(objseg.CCPM_campaign__r.CCPM_eventEndDate__c, strTimeZone) : null;
                Datetime datTSysNowForEvent = CCPM_utility.datTSysNowForEvent;
                if(dtmEvntStartDate != null && datTSysNowForEvent >= dtmEvntStartDate && (dtmEvntEndDate == null || (dtmEvntEndDate != null && datTSysNowForEvent <= dtmEvntEndDate))){
                    if(CCPM_Collection.isNotNullEmpty(objseg.CCPM_smsTemplates__r)){
                        for(CCPM_smsTemplate__c objSMSTemp : objseg.CCPM_smsTemplates__r){
                            if(objSMSTemp.CCPM_eventMessageStartDate__c != null){
                                objSMSTemp.CCPM_startDate__c = CCPM_utility.getDtTimeForTimeZone(objSMSTemp.CCPM_eventMessageStartDate__c,strTimeZone);
                            }
                            if(objSMSTemp.CCPM_eventMessageEndDate__c != null){
                                objSMSTemp.CCPM_endDate__c = CCPM_utility.getDtTimeForTimeZone(objSMSTemp.CCPM_eventMessageEndDate__c,strTimeZone);
                            }
                        }
                    }
                   
                    if(String.isNotBlank(objseg.CCPM_campaign__r.CCPM_leadCustomerType__c)){
                        for(String strLeadType : CCPM_utility.getSetFromString(objseg.CCPM_campaign__r.CCPM_leadCustomerType__c, ';')){
                            strLeadType = strLeadType.trim();
                            String strEventName = objseg.CCPM_campaign__r.CCPM_eventLabel__c+'_'+objseg.CCPM_campaign__r.Name;
                            if(mapLeadTypeEvntTypeLstSmsTempMap.containsKey(strLeadType)){
                                mapLeadTypeEvntTypeLstSmsTempMap.get(strLeadType).put(strEventName, objseg.CCPM_smsTemplates__r);
                            }
                            else{
                                mapLeadTypeEvntTypeLstSmsTempMap.put(strLeadType, new Map<String, List<CCPM_smsTemplate__c>>{strEventName =>objseg.CCPM_smsTemplates__r });
                            }
                        }   
                    }
                }                
            }
        }
        
        return mapLeadTypeEvntTypeLstSmsTempMap;
    }  
}