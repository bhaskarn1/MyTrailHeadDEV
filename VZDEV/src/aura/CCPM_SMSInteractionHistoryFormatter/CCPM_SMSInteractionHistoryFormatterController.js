/**
*@name          CCPM_SMSMessageController.js
*@author        Paras Shah (Deloitte)
*@date          01/24/2016
*@description   controller.js for the SMSMessageController component

Modification    Log:
------------------------------------------------------------------------------------
Developer                        Date                                Description
------------------------------------------------------------------------------------
Paras Shah(Deloitte)             01/24/2016                          Original Version
*/
({
    init : function(component, event, helper) {
        var messageContainer = component.find("message-container");
        var message = component.find("message");
        var direction = component.get("v.strDirection");
        var status = component.find("status");
        var vstatus = component.get("v.status");
        //var getStr2pn = component.get()
        var pn = component.find("pn");
        var getStrtoPIN= component.get("v.strToPN");
        console.log('getStrtoPIN'+getStrtoPIN);
        
          // Check if it is a Inbound message. Otherwise set it to outbound message.
          // This is a failsafe incase the Communication direction is null the flow will go in the ELSE section in direction check below
          if (direction != 'Inbound') {
              direction = 'Outbound';
          }

        if (direction.toLowerCase() == 'inbound') {
            
            //pn.set("v.value", fromPhone);
            
            //Align messages to the left for inbound messages
            
            $A.util.addClass(message, "slds-nubbin--left slds-m-left--small slds-theme--shade");
            $A.util.addClass(status, "slds-p-left--small slds-p-right--small")
        }
        else {
            
            //Align messages to the right for outbound messages
            //pn.set("v.value", component.get("v.strToPN"));
            //pn2.set("v.value", "sample");
            $A.util.addClass(messageContainer, "slds-grid slds-grid--align-end");
            $A.util.addClass(message, "slds-nubbin--right slds-m-right--small");
            $A.util.addClass(status, "slds-grid slds-grid--align-end slds-p-right--small slds-p-left--small")
            
            if (vstatus=='undelivered')
                $A.util.addClass(message, "slds-theme--offline");
            else
                $A.util.addClass(message, "slds-theme--alt-inverse");
        }
        
    }
}
})