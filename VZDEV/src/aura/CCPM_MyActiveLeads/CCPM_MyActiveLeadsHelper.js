({

/**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description  Helper metod that gets data from Server Controller and Loads data
*/
    loadLeadDetails : function(component,leadTable) {
        component.set('v.offSet', '0');
        var action = component.get('c.loadComponentWithRecords');
        action.setParams({ strSortBy : '',strOrderby :'',strLimit : '',strOffSet:'0' });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var objWrapperClass= response.getReturnValue();
                if(objWrapperClass.metadataSettings!=null)
                {
                    component.set('v.selectedTabToSort',objWrapperClass.metadataSettings.CCPM_orderByField__c);
                    component.set('v.orderToConsider',objWrapperClass.metadataSettings.CCPM_order__c);
                    component.set('v.sqlLimit',objWrapperClass.metadataSettings.CCPM_recordLimit__c);
                }
                component.set('v.maxSize',objWrapperClass.intMaxSize);
                if(objWrapperClass.intMaxSize<=component.get("v.sqlLimit"))
                {
                    component.find("Next").set("v.disabled", true);
                }
                else
                {
                    console.log('Inside Else in init->');
                    component.find("Next").set("v.disabled", false);  
                }
                component.find("Previous").set("v.disabled", true);
                console.log('Max SizeInit->'+objWrapperClass.intMaxSize);
                component.set('v.lstSobject', objWrapperClass.lstLead);
                leadTable.style.visibility = "visible";
                
            }
        });
        $A.enqueueAction(action);
    },

    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description  Helper metod that gets data from Server Controller and Loads data based on sorting chosen by column
*/
    
    sortHelper : function(component, event, sortByColumnValue)
    {  
        var action = component.get('c.loadComponentWithRecords');
        action.setParams({ strSortBy : sortByColumnValue,strOrderby : component.get("v.orderToConsider"),strLimit : component.get("v.sqlLimit"),strOffSet : '0'});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var objWrapperClass= response.getReturnValue();
                //set response value in wrapperList attribute on component.
                component.set('v.lstSobject', objWrapperClass.lstLead);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    /**
*@author        Brigadesh Chandrasekar (Deloitte)
*@description  Helper metod that gets data from Server Controller and Loads data based on offset and sorting chosen
*/
    paginationUsingOffset : function(component, event,offsetCalculated)
    {
        //Call the Server Controller
        var action = component.get('c.loadComponentWithRecords');
        //Set Parameters for the Server Controller
        action.setParams({ strSortBy : component.get("v.selectedTabToSort"),strOrderby : component.get("v.orderToConsider"),strLimit : component.get("v.sqlLimit"),strOffSet : 
        //Get the current offset value
        component.get("v.offSet")});
        //Callback for the function called in the Server side
        action.setCallback(this, function(response) {
            //Get the current State
            var state = response.getState();
            //Check if we have not thrown any exceptions on the component
            if (state === "SUCCESS") {
                //Store the returned wrapper class from Server Side
                var objWrapperClass= response.getReturnValue();
                //Set the Attribute to load the Leads
                component.set('v.lstSobject', objWrapperClass.lstLead);
            }
        });
        $A.enqueueAction(action);
        
    }
})