({
    sendSMSHelper : function(component,labelInMetadata,objLeadInContext) {
        console.log('Inside helper child1');
        var toastEvent;
        var action = component.get('c.makeCalloutHeywire');
        action.setParams({ strDeveloperName : labelInMetadata, objLead : objLeadInContext});
        action.setCallback(this, function(response) {
            var responseCodeCheck= response.getReturnValue();
            if(responseCodeCheck==204)
            {
                var event=component.getEvent("CommunicateParent");
                event.setParam("Communicate","Lead Saved");
                event.fire();
                
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "SMS has been sent successfully!"
                });
                
                
            }
            else
            {
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error Sending SMS! Please try again!"
                });
                
            }
            toastEvent.fire();  
            
            
        });
        $A.enqueueAction(action);          
    },
    doInitHelper : function(component, event){
        var action = component.get("c.profileRestrictedfromSendingSMS");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var profilesDisabled = response.getReturnValue();
                component.set("v.isProfileDisabled", profilesDisabled);
            }
        });
        $A.enqueueAction(action);
    }
})