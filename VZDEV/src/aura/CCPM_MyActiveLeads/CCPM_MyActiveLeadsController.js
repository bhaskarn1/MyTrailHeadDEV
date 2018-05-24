({
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Client Method to load data initially and during refresh
*/
    init : function(component, event, helper) {
        var leadTable = document.getElementById("myActiveLeads");
        leadTable.style.visibility = "hidden";
        helper.loadLeadDetails(component,leadTable);
        /*setTimeout(function(){ 
        	leadTable.style.visibility = "visible";
        }, 200); */       
    },
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Client Method to help sort the data based on the column selected
*/ 
    
    sortBySelectedColumn: function(component, event, helper) {
        //Initializing the offset value to 0 during the firs load of the component otr during a refresh
        component.set("v.offSet","0");
        //Checking if the total number of records meeting the criteria is less than the limit used in SOQL
        if(component.get("v.maxSize")<=component.get("v.sqlLimit"))
        {
            //Disabling the Next Button incase we have no more records to load after the first pull from SOQL
            component.find("Next").set("v.disabled", true);
        }
        else
        {
            component.find("Next").set("v.disabled", false);
        }
        //Disabling the previous button for the first page loaded
        component.find("Previous").set("v.disabled", true);
        // set current selected header field on selectedTabsoft attribute.  
       
           
       
        if(event.target.title){
             var sortByColumnValue=event.target.title;
        }
        else{
            var sortByColumnValue=component.get("v.selectedTabToSort");
        }
        
        
        //Obtaining the current column used for sorting
        var checkCurrentSortColumn= component.get("v.selectedTabToSort");
        //Obtaining the order by which the column is sorted
        var ordertoConsider = component.get("v.orderToConsider");
        //Check if the Column used for sorting has changed
        if(sortByColumnValue!=checkCurrentSortColumn)
        {   
            //Toggle the order
            component.set("v.orderToConsider", "ASC");    
        }
        else
        {   //Always toggle the order of the column used for sorting hasn't changed
            if(ordertoConsider=='ASC')
            {
                component.set("v.orderToConsider", "DESC");   
            }
            else
            {
                component.set("v.orderToConsider", "ASC");   
            }
            
        }
        //Setting the attribute of selected column for the next iteration in the same session
        component.set("v.selectedTabToSort", sortByColumnValue);
        //Callout made to helper class
        helper.sortHelper(component, event, sortByColumnValue);
    } ,
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description   Client Method to help calculate offset values for pagination
*/
    
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
    
    /**
*@author        Anoj Phillip(Deloitte)
*@description   
*/
    toggleColumnAccordion : function(cmp, event,rowId) {
        var target = event.getSource();
        var rowId = target.get("v.value");
        var wrapperElement = document.getElementById("activeLdHiddencolumn"+rowId);
        wrapperElement.classList.toggle('ld-lead-xcolumn-hide');
        
        var actionElement = document.getElementById("ActiveLdActionColumn"+rowId);
        actionElement.classList.toggle('ld-table-open');
    }
    
    
    
})