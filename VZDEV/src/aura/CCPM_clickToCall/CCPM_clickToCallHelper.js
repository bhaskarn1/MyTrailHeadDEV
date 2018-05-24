({
	doInitHelper : function(component, event, helper) {
        
        var leadId = component.get('v.recordId');
		var action = component.get('c.getResponse');
        var isIpad = $A.get("$Browser.isIPad");
        action.setParams({
            leadId : leadId,
            isIpad : isIpad
        });
        action.setCallback(this,function(response) {
            
            var status = response.getState();
            helper.hideSpinner(component, event, helper);
            if (status == 'SUCCESS') {
                
                var resp = response.getReturnValue();
                if (resp.statusCode != '00000'){
                    var notMsg = component.find('notificationMsg');
                    notMsg.set('v.variant','error');
                    notMsg.set('v.header','ERROR');
                    notMsg.set('v.message',resp.errorMessage);
                    $A.get("e.force:closeQuickAction").fire();
                    notMsg.init();
                } else {
                    helper.onSuccessfulCallout (component, event, helper, resp);
                }
            } else if (status == 'ERROR') {
                
                var errors = response.getError();
                var notMsg = component.find('notificationMsg');
                notMsg.set('v.variant','error');
                notMsg.set('v.header','ERROR');
                if( errors) {
                    if(errors[0] && errors[0].message)
                    {
                        notMsg.set('v.message',errors[0].message);
                    }
                }
                $A.get("e.force:closeQuickAction").fire();
                notMsg.init();
            } else if (status == 'INCOMPLETE') {
                
                var notMsg = component.find('notificationMsg');
                notMsg.set('v.variant','error');
                notMsg.set('v.header','ERROR');
                notMsg.set('v.message','Something went wrong. Please try again later');
                $A.get("e.force:closeQuickAction").fire();
                notMsg.init();
            }
        });
        $A.enqueueAction(action);
	},
    
    onSuccessfulCallout : function (component, event, helper, resp) {
        component.set('v.showCall',true);
        component.set('v.objTask',resp.objTask);
        component.set('v.statusValues',resp.statusValues);
        component.set('v.objTask.CCPM_nextSteps__c','');
    },
    
    hideSpinner : function(component, event, helper) {
        var spinner = component.find("spinnerId");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    updateTaskHelper : function (component, event, helper) {
        var subjVal = component.get('v.objTask.Subject');
        var notVal = component.get('v.objTask.CCPM_notes__c');
        if (subjVal && notVal) {
            var action = component.get('c.updateTaskRecord');
            action.setParams({
                objTask : component.get('v.objTask')
            });
            action.setCallback (this,function(response){
                var status = response.getState();
                if (status === 'SUCCESS') {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : "SUCCESS",
                        type : "success",
                        message : "Changes saved successfully"
                    });
                    toastEvent.fire();
                } 
            }); 
            $A.enqueueAction(action);
        }
    }
})