({
 navigateToMyComponent : function(component, event, helper) {
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:CCPM_prospectLayout",
        componentAttributes: {
            //isHomePageCancel : true
        },
        isredirect : true
    });
    evt.fire();
},
     doInit : function(component, event, helper) {
     helper.doInitHelper(component, event); 
} 
})