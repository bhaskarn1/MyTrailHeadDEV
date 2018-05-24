({
    doinit : function(component, event, helper) {
        
        helper.substatusCreationHelper(component);
        helper.leadStatusUpdatePermission(component);
    },
    
    updateSelectedSubStatus: function(component, event, helper){
        var selectedValue = component.get("v.selectedValueSubStatus");
        if(selectedValue=='--Select--')
        {
            component.set("v.isSelectedSelect", true);            
        }
        else{
            component.set("v.isSelectedSelect", false);  
        }
        
    },
    
   saveLead: function(component, event, helper){
    console.log('Inside sendSMS->');
	var subStatusToSave=component.find("SubStatusPicklist").get("v.value");
    var objLeadInContext=component.get("v.objLead");
        console.log('subStatusToSave'+subStatusToSave);
    helper.saveLeadHelper(component,subStatusToSave,objLeadInContext);
    
}
    
    
})