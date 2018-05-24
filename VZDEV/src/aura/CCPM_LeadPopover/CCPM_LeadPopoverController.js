({
	togglePopup : function(cmp, event) {
         var popupId = cmp.get("v.popupid");
        console.log(popupId);
        var wrapperElement = document.getElementById(popupId);
        var popover = wrapperElement.getElementsByClassName("slds-popover")[0];
        popover.classList.toggle('ld-pop-show');
        popover.classList.toggle('ld-pop-hide');
			
    },
    
    doinit :  function(component,helper, event) {
        
         var objLead = component.get("v.objLead");
       // var objTask = component.get("v.objLead.Tasks");
       console.log('Inside pop up wrapper');
       
        var action = component.get('c.sendLiveTextNumber');
        action.setParams({objLead : objLead});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var objWrapperClass= response.getReturnValue();
                //set response value in wrapperList attribute on component.
                component.set('v.objPopWrapper', objWrapperClass);
                console.log('wrapperpop'+JSON.stringify(objWrapperClass));
            }
        });
        $A.enqueueAction(action);
			
    },
    
    
    
})