({
    doinit : function(component, event, helper) {
        console.log("Inside Client Controller Leads Awaiting Response Child1");
        console.log("Lead Returned from Parent->"+JSON.stringify(component.get("v.objLead")));
        var optionsList = [];
        var mapToBeUsed = component.get("v.mapSMS");
        console.log('mapToBeUsed uodated->'+JSON.stringify(mapToBeUsed));
        for ( var key in mapToBeUsed ) {
            console.log('key->'+key);
            optionsList.push({value:mapToBeUsed[key], key:key});
            console.log('mapToBeUsed[key]->'+mapToBeUsed[key]+' '+'key'+key);
        }
        component.set("v.mapSMS1", optionsList);
        helper.doInitHelper(component, event);    
    },
    
    updateSelectedPicklistVal: function(component, event, helper){
        var selectedValue = component.get("v.selectedValueReplyPicklist");
        if(selectedValue=='--None--')
        {
            component.set("v.isSelectedNone", true);            
        }
        else{
            component.set("v.isSelectedNone", false);  
        }
        
    },
    
    sendSMS: function(component, event, helper){
    console.log('Inside sendSMS->');
	var labelInMetadata=component.find("ReplyPicklist").get("v.value");
    var objLeadInContext=component.get("v.objLead");
        console.log('labelInMetadata'+labelInMetadata);
    helper.sendSMSHelper(component,labelInMetadata,objLeadInContext);
    
}
    
    
})