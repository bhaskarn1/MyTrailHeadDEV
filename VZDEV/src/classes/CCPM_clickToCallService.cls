/**
*@name          CCPM_clickToCallService 
*@author        Ritwik Koneru (Deloitte)
*@date          02/08/2018
*@description   WSDL to Apex class
*@Class         CCPM_clickToCallService
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Ritwik Koneru (Deloitte)    	04/03/2018   	Initial Implementation.
*/
public class CCPM_clickToCallService {
    public class makeCtiCallResponse {
        public CCPM_clickToCallService.optInSFDCServiceResponse return_x;
        private String[] return_x_type_info = new String[]{'return','http://sfdcproxy.ctisfce.verizonwireless.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://sfdcproxy.ctisfce.verizonwireless.com','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class makeCtiCall {
        public String userid;
        public String reqId;
        public String agentCbr;
        public String custCbr;
        public String env;
        private String[] userid_type_info = new String[]{'userid','http://sfdcproxy.ctisfce.verizonwireless.com',null,'0','1','false'};
        private String[] reqId_type_info = new String[]{'reqId','http://sfdcproxy.ctisfce.verizonwireless.com',null,'0','1','false'};
        private String[] agentCbr_type_info = new String[]{'agentCbr','http://sfdcproxy.ctisfce.verizonwireless.com',null,'0','1','false'};
        private String[] custCbr_type_info = new String[]{'custCbr','http://sfdcproxy.ctisfce.verizonwireless.com',null,'0','1','false'};
        private String[] env_type_info = new String[]{'env','http://sfdcproxy.ctisfce.verizonwireless.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://sfdcproxy.ctisfce.verizonwireless.com','false','false'};
        private String[] field_order_type_info = new String[]{'userid','reqId','agentCbr','custCbr','env'};
    }
    public class optInSFDCResponseBody {
        public String errorCode;
        public String errorMessage;
        private String[] errorCode_type_info = new String[]{'errorCode','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://sfdcproxy.ctisfce.verizonwireless.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://sfdcproxy.ctisfce.verizonwireless.com','false','false'};
        private String[] field_order_type_info = new String[]{'errorCode','errorMessage'};
    }
    public class optInSFDCServiceResponse {
        public CCPM_clickToCallService.serviceHeader_element serviceHeader;
        public CCPM_clickToCallService.optInSFDCResponseBody serviceBody;
        private String[] serviceHeader_type_info = new String[]{'serviceHeader','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] serviceBody_type_info = new String[]{'serviceBody','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://sfdcproxy.ctisfce.verizonwireless.com','false','false'};
        private String[] field_order_type_info = new String[]{'serviceHeader','serviceBody'};
    }
    public class serviceHeader_element {
        public String serviceName;
        public String subserviceName;
        public String clientName;
        public String reqID;
        public String statusCode;
        public String correlationId;
        private String[] serviceName_type_info = new String[]{'serviceName','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] subserviceName_type_info = new String[]{'subserviceName','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] clientName_type_info = new String[]{'clientName','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] reqID_type_info = new String[]{'reqID','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] correlationId_type_info = new String[]{'correlationId','http://sfdcproxy.ctisfce.verizonwireless.com',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://sfdcproxy.ctisfce.verizonwireless.com','false','false'};
        private String[] field_order_type_info = new String[]{'serviceName','subserviceName','clientName','reqID','statusCode','correlationId'};
    }
    public class CtiRetailOutboundServicePort {
        Boolean isSandbx = CCPM_utility.isRunningInASandbox;
        public String endpoint_x =  isSandbx ?Label.CCPM_clicktoCallEndpoint:Label.CCPM_clickToCallProdEndpoint;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x = CCPM_staticconstants.strClientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://sfdcproxy.ctisfce.verizonwireless.com', 'CCPM_clickToCallService'};
        public CCPM_clickToCallService.optInSFDCServiceResponse makeCtiCall(String userid,String reqId,String agentCbr,String custCbr,String env) {
            CCPM_clickToCallService.makeCtiCall request_x = new CCPM_clickToCallService.makeCtiCall();
            request_x.userid = userid;
            request_x.reqId = reqId;
            request_x.agentCbr = agentCbr;
            request_x.custCbr = custCbr;
            request_x.env = env;
            CCPM_clickToCallService.makeCtiCallResponse response_x;
            Map<String, CCPM_clickToCallService.makeCtiCallResponse> response_map_x = new Map<String, CCPM_clickToCallService.makeCtiCallResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://sfdcproxy.ctisfce.verizonwireless.com',
              'makeCtiCall',
              'http://sfdcproxy.ctisfce.verizonwireless.com',
              'makeCtiCallResponse',
              'CCPM_clickToCallService.makeCtiCallResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
    }
}