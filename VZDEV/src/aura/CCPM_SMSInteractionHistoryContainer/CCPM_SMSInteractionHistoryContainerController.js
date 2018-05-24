/**
*@name          CCPM_SMSController.js
*@author        Paras Shah (Deloitte)
*@date          01/24/2016
*@description   controller.js for the SMSController component

Modification    Log:
------------------------------------------------------------------------------------
Developer                        Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)             01/24/2016                          Original Version
*/

({
    myAction : function(component, event, helper) {
        
        // To get the list of SMS activity from the Apex controller
        // This list has the SMS body in a order which resembles with the actual messages on mobile devices

        var actionGetSMSMessageList = component.get("c.getSMSMessageList");
        actionGetSMSMessageList.setCallback(this, function(response) {
            
            //Set the messageList variable to the list returned by the Apex controller
            component.set("v.messageList", response.getReturnValue());
        });
        
        $A.enqueueAction(actionGetSMSMessageList);

        //Pass the Lead record Id to the Apex controller to access tasks corresponding to that Lead
        var currentId = component.get("v.recordId");  
        actionGetSMSMessageList.setParams({
            idRecord : currentId
        });  
        
        //To get the Lead Phone number
        var actionGetLeadPhone = component.get("c.getLeadPhone");
        actionGetLeadPhone.setCallback(this, function(response) {
            
            //Set the lead phone number to the phone returned by the Apex controller
            component.set("v.strLeadPhone",response.getReturnValue());
        });
        
        $A.enqueueAction(actionGetLeadPhone);

        //Pass the Lead record Id to the Apex controller to access tasks corresponding to that Lead
        var currentId = component.get("v.recordId");  
        actionGetLeadPhone.setParams({
            idRecord : currentId
        });     
    }
})