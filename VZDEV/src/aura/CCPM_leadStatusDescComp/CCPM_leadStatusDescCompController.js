({
	init : function(component, event, helper) {
		helper.initHelper(component, event, helper);
        var device = $A.get("$Browser.isIPad");
        if (!device){
            document.querySelector("html body.sfdcBody").style.padding = "0px";
        }
        
	}
})