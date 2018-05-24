@isTest
global class CCPM_clickToCallMock implements webservicemock{
    
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {

            CCPM_clickToCallService.serviceHeader_element objElement = new CCPM_clickToCallService.serviceHeader_element();
            objElement.serviceName = 'Sample';
            objElement.subserviceName = 'Sample';
            objElement.clientName = 'Sample';
            objElement.reqID = 'Sample';
            objElement.statusCode = 'Sample';
            objElement.correlationId = 'Sample'; 
            
            CCPM_clickToCallService.optInSFDCResponseBody objResponseBody = new CCPM_clickToCallService.optInSFDCResponseBody();
            objResponseBody.errorCode = '0000';
            objResponseBody.errorMessage = 'Sample';
            
            CCPM_clickToCallService.optInSFDCServiceResponse objResElement = new CCPM_clickToCallService.optInSFDCServiceResponse();
            objResElement.serviceBody = objResponseBody;
            objResElement.serviceHeader = objElement;
            
            system.debug('!!!objResElement'+objResElement);
            
            CCPM_clickToCallService.makeCtiCallResponse objmakeCtiCallResponse = new CCPM_clickToCallService.makeCtiCallResponse();
            objmakeCtiCallResponse.return_x = objResElement;

            
            system.debug('!!!objmakeCtiCallResponse' + objmakeCtiCallResponse);
            response.put('response_x',objmakeCtiCallResponse);
            
        }
}