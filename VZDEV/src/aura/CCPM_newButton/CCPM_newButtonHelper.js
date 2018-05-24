({
    doInitHelper : function(component, event){
        var action = component.get("c.getIscurrentUserhavingLeadCreatePermission");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var leadCreatePermission = response.getReturnValue();
                component.set("v.iscurrentUserhavingPermission", leadCreatePermission);
            }
        });
        $A.enqueueAction(action);
    }
})