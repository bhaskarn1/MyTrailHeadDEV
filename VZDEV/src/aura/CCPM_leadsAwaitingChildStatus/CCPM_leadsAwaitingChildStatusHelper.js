({
    saveLeadHelper : function(component,subStatusToSave,objLeadInContext) {
        var action = component.get('c.saveLeadServer');
        var toastEvent;
        action.setParams({ strSubStatusToSave : subStatusToSave, objLead : objLeadInContext});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseMessage= response.getReturnValue();
                console.log('Lead Saved');
                
                if(responseMessage==='Success')
                {
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Status has been Updated Successfully!"
                    });
                    
                }
                else
                {
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error while updating Status!"
                    });
                    
                }
                toastEvent.fire();
                
                var event=component.getEvent("CommunicateParent");
                event.setParam("Communicate","Lead Saved");
                event.fire();
            }  
        });
        $A.enqueueAction(action);  
        
    },
    
    substatusCreationHelper : function(component){
        
        var action = component.get('c.createSubStatusMap');
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapToBeUsed= response.getReturnValue();
                var optionsList=[];
                console.log('mapToBeUsed updated->'+JSON.stringify(mapToBeUsed));
                for ( var key in mapToBeUsed ) {
                    console.log('key->'+key);
                    optionsList.push({value:mapToBeUsed[key], key:key});
                    console.log('mapToBeUsed[key]->'+mapToBeUsed[key]+' '+'key'+key);
                }
                component.set("v.mapSubStatus", optionsList);
            }
        });
        $A.enqueueAction(action);     
    },
    
    leadStatusUpdatePermission : function(component){
        var action = component.get("c.profileRestrictedfromLeadStatusUpdate");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var leadUpdatePermission = response.getReturnValue();
                component.set("v.isProfileRestricted", leadUpdatePermission);
            }
        });
        $A.enqueueAction(action);
    }
})