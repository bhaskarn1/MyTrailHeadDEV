({
	doInitHelper : function(component, event, helper) {
		var action = component.get("c.isCurrentUserTelesalesUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.isTelesalesUser", result);
            }
        });
        $A.enqueueAction(action);
    }
})