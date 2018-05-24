({
    init : function(component, event, helper) {
    	helper.initHelper(component, event, helper);    
    },
    
    sendSMS : function(component, event, helper) {
        helper.sendSMSHelper(component, event, helper);
    },
    
    onSMSValueChange : function (component, event, helper) {
        helper.onSMSValueChangeHelper(component, event, helper);
    },
    
    lengthCheck : function (component,event, helper) {
      helper.maxLengthCheckHelper(component, event, helper);
    },
    
    subStatusChange : function (component, event, helper) {
        var subStatValue = component.find("subStatLabels").get("v.value");
        if (subStatValue != '--None--') {
        	component.set('v.subStatError',false);
        }
    }
})