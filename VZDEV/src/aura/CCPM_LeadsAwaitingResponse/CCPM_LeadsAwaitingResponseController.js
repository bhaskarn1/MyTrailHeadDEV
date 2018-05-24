({
    togglePopup : function(cmp, event) {
        var target = event.getSource();
        var popupId = target.get("v.name");
        var boolShowPopUp  = target.get("v.value");
        target.set("v.value",true);

         setTimeout(function(){ 
                var wrapperElement = document.getElementById(popupId);
        		var popover = wrapperElement.getElementsByClassName("slds-popover")[0];
        		popover.classList.toggle('ld-pop-show');
        		popover.classList.toggle('ld-pop-hide');
        }, 200); 
        

			
    },
    
    init : function(component, event, helper) {
        var leadAwaitingTable = document.getElementById("leadAwaitingResponse");
        leadAwaitingTable.style.visibility = "hidden";
        helper.loadSobjects(component,leadAwaitingTable);
    },
    
    
    calculateOffset : function(component, event,helper) {
        //Obtain the previously set offset values
        var offSetCurrent=parseInt(component.get("v.offSet"));
        //Get the button clicked-Next/Previous
        var currentContext = event.getSource().getLocalId();
        //Validate the requirement of buttons to be made visible
        var checkForMaxSizeMoreThanLimit= offSetCurrent+parseInt(component.get("v.sqlLimit"));
        if(currentContext=='Next' && checkForMaxSizeMoreThanLimit<component.get("v.maxSize") && ((parseInt(component.get("v.maxSize"))-checkForMaxSizeMoreThanLimit)>parseInt(component.get("v.sqlLimit") )) ) {	
            //Disable the Previous Button
            component.find("Previous").set("v.disabled", false);
            component.find("Next").set("v.disabled", false);
            //Calculate the new Offset
            offSetCurrent=parseInt(offSetCurrent)+parseInt(component.get("v.sqlLimit"));
            component.set("v.offSet",offSetCurrent.toString());
            console.log('offSetCurrenNextt->'+offSetCurrent);
        }
        else if(currentContext=='Next' &&(checkForMaxSizeMoreThanLimit>component.get("v.maxSize") || ((parseInt(component.get("v.maxSize"))-checkForMaxSizeMoreThanLimit)<parseInt(component.get("v.sqlLimit") )) ) ) 
        {	
            offSetCurrent=parseInt(offSetCurrent)+parseInt(component.get("v.sqlLimit"));
            component.set("v.offSet",offSetCurrent.toString());
            component.find("Next").set("v.disabled", true);
            component.find("Previous").set("v.disabled", false);
        }
            else if(currentContext=='Previous')
            {	
                //Enable the Next Button
                component.find("Next").set("v.disabled", false);
                //Calculate the new offset
                var offSetCurrentTemp= parseInt(offSetCurrent)-parseInt(component.get("v.sqlLimit"));
                if(offSetCurrentTemp>0)
                {
                    component.set("v.offSet",offSetCurrentTemp.toString());
                    console.log('offSetCurrentPrevious->'+offSetCurrentTemp); 
                }
                else if(offSetCurrentTemp<=0)
                {	component.set("v.offSet","0");
                 component.find("Previous").set("v.disabled", true); 
                }
                
                
            }
        console.log('Offset in Controller Calculated->'+component.get("v.offSet"));
        //Call the helper method
        helper.paginationUsingOffset(component, event,component.get("v.offSet"));
        
    },
    
    toggleColumnAccordion : function(cmp, event,rowId) {
        var target = event.getSource();
        var rowId = target.get("v.value");
        var wrapperElement = document.getElementById("leadAwaitingHiddencolumn"+rowId);
        wrapperElement.classList.toggle('ld-lead-xcolumn-hide');
        
        var actionElement = document.getElementById("LeadAwaitingActionColumn"+rowId);
        actionElement.classList.toggle('ld-table-open');
    },
     checkDateRange : function(date) {
        console.log(date);
         return true;
			
    },
})