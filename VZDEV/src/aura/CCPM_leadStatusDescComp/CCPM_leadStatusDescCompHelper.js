({
	initHelper : function(component, event, helper) {
        
		var action = component.get("c.getStatusDetails");
        var leadId = component.get('v.recordId');
        action.setParams({
            leadId : leadId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state == 'SUCCESS') {
                var resp = response.getReturnValue();
                if(resp) {
                    component.set('v.description',resp.description);
                    component.set('v.nextSteps',resp.nextSteps);
                }
            } 
        });
        $A.enqueueAction(action);
	}
})