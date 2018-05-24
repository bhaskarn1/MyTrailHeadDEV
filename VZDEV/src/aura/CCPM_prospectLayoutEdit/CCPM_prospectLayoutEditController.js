({
    doInit : function(component, event, helper) {
   //helper.getPicklistValues(component, event); 
   helper.getPicklistValues1(component, event); 
   //helper.getPicklistValuesforEventType(component, event);
   helper.getPicklistValuesforCommPref(component, event);
   helper.getPicklistValuesforTransComp(component, event);
   helper.getPicklistValuesforQuickNotesDesc(component, event);
   helper.getPicklistValuesforSalutation(component, event);
   //helper.getCountry(component, event);
   //helper.getState(component, event);
   helper.fetchPicklistValues(component, 'Status', 'CCPM_leadSubStatus__c');
   helper.passId(component, event);  
   //helper.getPicklistValuesforEventType(component, event,component.get("v.leadEventType"));
   helper.getPicklistValuesforCurrentCarrier(component, event);
   helper.getPicklistValuesforItemsInterestedIn(component, event);
   helper.doInitHelper(component, event, helper);
   helper.getProfilePermissionforNotes(component, event);
   helper.getProfilePermissionforStatus(component, event);
}, 
  //method for the controlling Lead status field to disable sub status based on value
    onControllerFieldChange: function(component, event, helper) {
      // get the selected value
      var controllerValueKey = event.getSource().get("v.value");
 	var leadstatus=component.find("LeadStatus");
      // get the map values   
      var Map = component.get("v.depnedentFieldMap");
 		
      // check if selected value is not equal to None then call the helper function.
      // if controller field value is none then make dependent field value is none and disable field
      if (controllerValueKey != '--- None ---') {
 
         // get dependent values for controller field by using map[key].  
         var ListOfDependentFields = Map[controllerValueKey];
         helper.fetchDepValues(component, ListOfDependentFields);
          if(controllerValueKey != 'Qualified' && controllerValueKey!='Responded'){
              component.set("v.isleadStatusChangeIncorrect",true);
              
          }
          else{
              component.set("v.isleadStatusChangeIncorrect",false);
          }
 
      } /* else {
         var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         }];
         component.find('LeadSubStatus').set("v.options", defaultVal);
          component.set("v.isDependentDisable", true);
         
      } */
   },
    //method for the controlling field country to disable state based on value
    /*onControllerCountryChange: function(component, event, helper) {
      // get the selected value
      var controllerValueKey = event.getSource().get("v.value");
 
      // get the map values   
     // var Map = component.get("v.depnedentFieldMap");
 
      // check if selected value is not equal to None then call the helper function.
      // if controller field value is none then make dependent field value is none and disable field
      if ( controllerValueKey != '--None--') 
      {
                    component.set("v.isStateDependentDisable", false); 
 
      } else {
          var defaultVal = [{
            class: "optionClass",
            label: '--None--',
            value: '--None--'
         }];
         component.find('state').set("v.options", defaultVal);
          console.log(component.get("v.isStateDependentDisable"));
          if(component.get("v.isStateDependentDisable")==false)
          {
            		helper.getState(component, event);
                    component.set("v.isStateDependentDisable", true); 
          }
         
      }
   },*/
    

    changeValue : function (component, event, helper) {
      component.set("v.init", false);
    },

    handleValueChange : function (component, event, helper) {
        // handle value change
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
    },
   
    submit: function(component, event, helper){
            var varsubmit = event.getSource();
            //console.log("varsubmit->"+varsubmit);
            varsubmit.set("v.disabled",true);//Disable the button
        var eventTypeFld = component.find("eventTypeId");
        if (eventTypeFld){
            var eventTypeVal = eventTypeFld.get("v.value");
            var isLdExists = component.get('v.IsManualLead');
            if((eventTypeFld == '' || eventTypeFld==null) && isLdExists) {
                component.find("eventTypeId").set("v.value",'Reminder');
            }
        }
        
            helper.clickSubmit(component, event);
        
    },
    cancel: function(component, event, helper){
        
        var theLead = component.get("v.recordId");
        console.log(theLead);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId" : theLead,
            "slideDevName" : "detail",
            "isredirect": true
            
        });
        navEvt.fire();
    },
    
    display: function(component, event, helper){
       helper.displayHelper(component, event);
    },
    displayOut: function(component, event, helper){
        helper.displayHelper(component, event);
    },
    onEventFollowupChange: function(component, event, helper)
    {
        component.set('v.eventMsgVal','');
        component.set('v.eventTypeErr',false);
        helper.eventTypeChangeHelper(component, event, helper);
                    component.set("v.isDisableEvent",false);

       if(component.find("eventTypeId").get("v.value")=='Black Friday/Cyber Monday')
        {
        	component.set("v.isDisableEvent",true);
        }
       else 
        {
                component.set("v.isDisableEvent",false);
        }
            
    }
}

})