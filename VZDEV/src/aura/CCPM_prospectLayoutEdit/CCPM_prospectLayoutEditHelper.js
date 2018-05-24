({
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValues1 : function(component, event) {
        var action1 = component.get("c.getReasonforPurchaseValues");
        var inputsel1 = component.find("reasonForPurchase");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    }, 
    
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValuesforCommPref : function(component, event) {
        var action1 = component.get("c.getCommPrefValues");
        var inputsel1 = component.find("communicationPreference");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValuesforTransComp : function(component, event) {
        var action1 = component.get("c.getTransCompleteValues");
        var inputsel1 = component.find("transCompletionChannelPreference");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValuesforQuickNotesDesc : function(component, event) {
        var action1 = component.get("c.getQuickNotesDescriptionValues");
        var inputsel1 = component.find("quickNotesDescription");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValuesforCartStatus : function(component, event) 
    {
        var action1 = component.get("c.getCartStatusValues");
        var inputsel1 = component.find("cartStatus");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValuesforSalutation : function(component, event) {
        var action1 = component.get("c.getSalutationValues");
        var inputsel1 = component.find("salutation");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    
    
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValuesforLeadSource : function(component, event) {
        var action1 = component.get("c.getLeadSourceValues");
        var inputsel1 = component.find("leadSource");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    
    
    getPicklistValuesforClosedLeadSource : function(component, event) {
        var action1 = component.get("c.getClosedLeadSourceValues");
        var inputsel1 = component.find("closedLeadSource");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label:response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    getPicklistValuesforCurrentCarrier : function(component, event) {
        var action1 = component.get("c.getCurrentCarrierValues");
        var inputsel1 = component.find("currentCarrier");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    
    //helper method to find the values from UI page using the aura:Id and set the response in the salesforce using the apex controller method
    getPicklistValuesforItemsInterestedIn : function(component, event) {
        var action1 = component.get("c.getItemsInterestedInValues");
        var inputsel1 = component.find("itemsInterestedIn");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    //helper method to find the values from UI page using the aura:Id and set the response in the salesforce using the apex controller method
    /*getCountry : function(component, event) {
        var action1 = component.get("c.getCountryValues");
        var inputsel1 = component.find("country");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    }, 
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getState : function(component, event) {
        var action1 = component.get("c.getStateValues");
        var inputsel1 = component.find("state");
        var opts1=[];
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },*/
    
    fetchPicklistValues: function(component, controllerField, dependentField) {
        console.log(controllerField,dependentField);
        // call the server side function  
        var action = component.get("c.getDependentOptionsImpl");
        // pass paramerters [object name , contrller field name ,dependent field name] -
        // to server side function 
        
        action.setParams({
            'strObjApiName': component.get("v.objInfo"),
            'strContrfieldApiName': controllerField,
            'strDepfieldApiName': dependentField
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                console.log(StoreResponse);
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap", StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on ui field. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    console.log(singlekey);
                    listOfkeys.push(singlekey);
                }
                /*
                //set the controller field value for ui:inputSelect  
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    
                    ControllerField.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                    
                }
                */
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
                // set the ControllerField variable values to leadStatus(controller picklist field)
                    component.find('LeadStatus').set("v.options", ControllerField);
            }
            else {
                console.log("is error");
            }
        });
        $A.enqueueAction(action);
    },
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field)  
        var dependentFields = [];
        
        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            
            dependentFields.push({
                class: "optionClass",
                label: "-- Select Sub-Status --",
                value: "-- Select Sub-Status --"
            });
            
        }
        
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push({
                class: "optionClass",
                label: ListOfDependentFields[i],
                value: ListOfDependentFields[i]
            });
        }
        // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
        component.find('LeadSubStatus').set("v.options", dependentFields);
        if(ListOfDependentFields.length == 0)
        {
            component.set("v.isDependentDisable", true);
        }else{
            component.set("v.isDependentDisable", false);
        }
        
        
        
    },
    
    
    Click : function(component, event) {
        console.log("Inside Helper");
        var b = component.get("v.testMobile");
        var d = component.find("Mobile");
        var e = d.get("v.value");
        var a = component.get("c.search");
        a.setParams({"c": e});
        
        a.setCallback(this, function(Response){
            console.log(Response.getState());
        });
        
        $A.enqueueAction(a);
    },
    fetchAccount: function(component, account){
        var action = component.get("c.search");
        action.setParams({
            'objofAccount': component.get("v.account"),
        });
    },
    displayHelper : function(component,event) {
        var auraId = event.currentTarget.dataset.helperId;
        //console.log(auraId);
        var helperBox = component.find(auraId);
        if(!$A.util.isEmpty(helperBox)){
            //helperBox.getElement().style.display = "block";
            $A.util.toggleClass(helperBox, "toggle");
        }
    },
    
    passId: function(component, event){
        console.log(component.get("v.recordId"));
        var searchRecord = component.get("c.getRecord");
        searchRecord.setParams({"recordId": component.get("v.recordId")});
        searchRecord.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")
            {
                var theLead = response.getReturnValue();
                
                /* TO SET THE EVENT TYPES */
                /*
                var action1 = component.get("c.getEventTypeValues");
                var inputsel1 = component.find("eventType"); */
                var opts1=[];
                var boolEventTypeFound = false;
                /*
                action1.setCallback(this, function(response) {
                    for(var i=0;i< response.getReturnValue().length;i++){
                        if (response.getReturnValue()[i] == theLead.CCPM_eventType__c) {
                            boolEventTypeFound = true;
                        }
                        opts1.push({"class": "optionClass",  label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                    }
                    
                    if (boolEventTypeFound == false) {
                        opts1.push({"class": "optionClass",label: theLead.CCPM_eventType__c, value: theLead.CCPM_eventType__c}); 	
                    }
                  
                   
                    inputsel1.set("v.options", opts1);
                    
                });
                $A.enqueueAction(action1); 
                */
                /* END OF CODE TO SET EVENT TYPE */
                
                component.set("v.lead", theLead); 
                component.set("v.leadEventType", theLead.CCPM_eventType__c);
                if(theLead.CCPM_isManualLead__c==true)
                {
                    component.set("v.isMtnDisable", true);   
                }
                var todaydate = new Date();
                var smsFollowupDate = Date.parse(theLead.CCPM_SMSFollowUpDate__c);
                
                if(smsFollowupDate < todaydate)
                {
                    component.set("v.isEventDisable", true);

                }
                if((smsFollowupDate < todaydate)||(component.find("eventTypeId").get("v.value")=='Black Friday/Cyber Monday'))
                {
                    component.set("v.isDisableEvent",true);
                }
                else 
                {
                    component.set("v.isDisableEvent",false);
                }
               
                
                console.log(theLead.Status);
                //console.log(theLead.CCPM_leadSubStatus__c);
                var Map = component.get("v.depnedentFieldMap");
                var ListOfDependentFields = Map[theLead.Status];
                var dependentFields = [];
                for (var i = 0; i < ListOfDependentFields.length; i++) {
                    dependentFields.push({
                        class: "optionClass",
                        label: ListOfDependentFields[i],
                        value: ListOfDependentFields[i]
                    });
                }
                component.find('LeadSubStatus').set("v.options", dependentFields);
                
                if(theLead.CCPM_usstate__c!=null && theLead.CCPM_country__c!=null &&  theLead.CCPM_country__c=='--None--' && theLead.CCPM_usstate__c=='--None--' )
                {
                    component.set("v.isStateDependentDisable",true);
                }
                if(theLead.CCPM_createdChannel__c == 'Telesales'){
                    component.set("v.isTelesalesLead",true); 
                } 
                if((theLead.Status=='Responded' && theLead.CCPM_leadSubStatus__c=='Action Required') || 
                	(theLead.CCPM_createdChannel__c == 'Telesales')){   
                    component.set("v.isLeadStatusDisable", false);
                    component.set("v.isDependentDisable", false);   
                }
                if(theLead.CCPM_reminder__c == 'Completed')
                {
                    console.log("is reminder Past due"+theLead.CCPM_reminder__c);
                    component.set("v.isReminderCompleted",true);
                }
                if(theLead.CCPM_isMergedUIFlag__c==true){
                    
                   component.set("v.isMerged",true);
                }
                
                if((theLead.RecordType.DeveloperName=='CCPM_customerCart' && theLead.CCPM_isManualLead__c!=true) || theLead.RecordType.DeveloperName=='CCPM_prospectCart' || theLead.RecordType.DeveloperName=='CCPM_CustomerAbandonedVisit'|| theLead.RecordType.DeveloperName=='CCPM_CustomerQuotes')
                {
                    
                    component.set("v.IsNotCustomerCart",false); 
                    
                } 
                if(theLead.RecordType.DeveloperName=='CCPM_customerCart' && theLead.CCPM_isManualLead__c==true) 
                {
                    component.set("v.IsManualLead",true); 
                }
                
            }
            
        });
        $A.enqueueAction(searchRecord);
    },
    /*
    //helper method to find the pick list values from  salesforce using the apex controller method and passing it on to  UI page using the aura:Id
    getPicklistValuesforEventType : function(component, event, leadEventType) {
        var action1 = component.get("c.getEventTypeValues");
        var inputsel1 = component.find("eventType");
        var opts1=[];
        opts1.push({"class": "optionClass",label: leadEventType, value: leadEventType}); 	
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                //if (response.getReturnValue()[i] != theLead.CCPM_eventType__c) {
                    opts1.push({"class": "optionClass",  label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                //}
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
    },
    */
    clickSubmit : function(component, event, helper)
    {
        console.log("Inside Submit->");
        var mtn='';
        var confirmMtn = '';
        var hasError = false;
        component.set("v.isErrorMessage", null);
        
        var mtnField = component.find("MTN");
        mtnField.set("v.errors", null);
        
        if (!$A.util.isEmpty(mtnField)) {
            if (!$A.util.isEmpty(mtnField.get("v.value"))) 
            {
                mtn = mtnField.get("v.value");
                mtn=mtn.replace(/[- ( )]/g,'');
            }  
            
        }
        if(component.get("v.IsNotCustomerCart")==true && component.get("v.IsManualLead")==false)
        {
            var confirmMtnField = component.find("confirmMTN");
            confirmMtnField.set("v.errors", null);
            if (!$A.util.isEmpty(confirmMtnField)){
                if (!$A.util.isEmpty(confirmMtnField.get("v.value"))) {
                    confirmMtn = confirmMtnField.get("v.value");
                    confirmMtn=confirmMtn.replace(/[- ( )]/g,'');
                }
            }
        }
        if(component.get("v.IsNotCustomerCart")==true)
        {
            var email = '';
            var emailField = component.find("email");
            emailField.set("v.errors", null);
            if(!$A.util.isEmpty(emailField)){
                email = emailField.get("v.value"); 
            }
            if(component.get("v.IsManualLead")==false)
            {
                var confirmEmailVal = '';
                var confirmEmailField = component.find("confirmEmail");
                confirmEmailField.set("v.errors", null);
                if(!$A.util.isEmpty(confirmEmailField)){
                    confirmEmailVal = confirmEmailField.get("v.value");
                    
                }
            }
        }
        var fName = '';
        var firstNameCmp = component.find("prospectFirstName");
        firstNameCmp.set("v.errors", null);
        if(!$A.util.isEmpty(firstNameCmp)){
            fName = firstNameCmp.get("v.value");
        }
        var lastName = component.find("prospectName");
        lastName.set("v.errors", null);
        var lName = lastName.get("v.value");
        /*
        if(component.get("v.IsNotCustomerCart")==true)
        {
            var eventTypeField = component.find("eventType");
            eventTypeField.set("v.errors", null);
            var eventTypeVal = '';
            if(!$A.util.isEmpty(eventTypeField)){
                eventTypeVal = eventTypeField.get("v.value");
                console.log(eventTypeVal);
            }
        }*/
        
        if(component.get("v.IsNotCustomerCart")==true)
        {
            var msgConsentval='';
            var msgConsent=component.find("consent");
            msgConsent.set("v.errors", null);
            if(!$A.util.isEmpty(msgConsent))
            {
                msgConsentval = msgConsent.get("v.value");
                console.log(msgConsentval);
            }
        } 
        var leadStatusVal='';
        var leadstatus=component.find("LeadStatus");
        leadstatus.set("v.errors", null);
        if(!$A.util.isEmpty(leadstatus))
        {
            leadStatusVal = leadstatus.get("v.value");
            console.log(leadStatusVal);
        }
        var leadSubStatusVal='';
        var leadSubstatus=component.find("LeadSubStatus");
        leadSubstatus.set("v.errors", null);
        if(!$A.util.isEmpty(leadSubstatus))
        {
            leadSubStatusVal = leadSubstatus.get("v.value");
            
        }
       /* var PostalCodeval='';
        var PostalCode=component.find("postal");
        PostalCode.set("v.errors", null);
        if(!$A.util.isEmpty(PostalCode))
        {
            PostalCodeval = PostalCode.get("v.value");
        }*/
        if(component.get("v.IsNotCustomerCart")==true)
        {
            var smsFollowUpDateField = component.find("smsFollowUpDate");
            smsFollowUpDateField.set("v.errors", null);
            var smsFollowUpDateVal = '';
            var smsFollowUpDate='';
            var todayDate = new Date();
            var IphoneDate =new Date("2017-10-26");
            if(!$A.util.isEmpty(smsFollowUpDateField))
            {
                //console.log('12344');
                smsFollowUpDateVal = smsFollowUpDateField.get("v.value");
                smsFollowUpDate=Date.parse(smsFollowUpDateVal);
                console.log(smsFollowUpDate);
            }
        }
        
        var numberOfLinesField = component.find("numberOfLines");
        var numberOfLinesVal = numberOfLinesField.get("v.value");
        numberOfLinesField.set("v.errors", null);
        var charRegExp = RegExp("^[a-z + A-Z]*$");
        var mtnRegExp = RegExp("^[0-9 + (+)+-]*$");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        console.log(mtn + ' - ' +confirmMtn);
        if(component.get("v.IsNotCustomerCart")==true && $A.util.isEmpty(mtn) && $A.util.isEmpty(email))
        {
            mtnField.set("v.errors", [{message: "MTN or Email is required to save the record"}]);
            hasError = true;   
        }
        if($A.util.isEmpty(email) && !$A.util.isEmpty(mtn) && (mtn.length<10 || mtn.length>15 || mtn.search(mtnRegExp)!=0))
        {
            mtnField.set("v.errors", [{message: "Please enter valid MTN"}]);
            hasError = true;
        }
        if (component.get("v.IsManualLead")==false && component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(mtn) && $A.util.isEmpty(confirmMtn))
        {
            confirmMtnField.set("v.errors", [{message: " Please confirm MTN before proceeding"}]);
            //confirmMtnField.getElementFocus();
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(mtn) && !$A.util.isEmpty(confirmMtn) && mtn != confirmMtn)
        {
            confirmMtnField.set("v.errors", [{message: "Both the MTN's should match"}]);
            hasError = true;
        }
        
        if (component.get("v.IsManualLead")==false && component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(email) && $A.util.isEmpty(confirmEmailVal))
        {
            confirmEmailField.set("v.errors", [{message: " Please confirm Email before proceeding"}]);
            //confirmMtnField.getElementFocus();
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(email) && !$A.util.isEmpty(confirmEmailVal) && email != confirmEmailVal)
        {	
            console.log("In Line 504->");
            confirmEmailField.set("v.errors", [{message: "Both the Email's should match"}]);                            
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && $A.util.isEmpty(fName)){
            firstNameCmp.set("v.errors", [{message: "First Name is mandatory"}]);
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(fName) && fName.search(charRegExp)!=0){
            firstNameCmp.set("v.errors", [{message: "First Name cannot contain special characters or numbers"}]);
            hasError = true;
        }
        if($A.util.isEmpty(lName)){
            lastName.set("v.errors", [{message: "Last Name is mandatory"}]);
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(lName) && lName.search(charRegExp)!=0){
            lastName.set("v.errors", [{message: "Last Name cannot contain special characters or numbers"}]);
            hasError = true;  
        } 
        if(!$A.util.isEmpty(email) && !email.match(regExpEmailformat) )
        {
            
            emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
            hasError = true;
            
        }
        
        if((leadStatusVal == 'Responded' && (leadSubStatusVal == undefined || leadSubStatusVal == '-- Select Sub-Status --')) ||
           (leadStatusVal == 'Qualified' && (leadSubStatusVal == undefined || leadSubStatusVal == '-- Select Sub-Status --'))) 
        {
            leadSubstatus.set("v.errors", [{message: "Please select a Sub-Status"}]);
            hasError = true;
        }
        
        if(!$A.util.isEmpty(leadStatusVal) && (component.get("v.isleadStatusChangeIncorrect")==true || (leadStatusVal =='Responded' && leadSubStatusVal!='Action Required')) && component.get("v.isTelesalesLead")==false && component.get("v.isLeadStatusDisable")==false) 
           /* && (leadStatusVal =='New' || leadStatusVal =='Eligible' || leadStatusVal =='Contacted' || (leadStatusVal =='Responded' && leadSubStatusVal!='Action Required') || leadStatusVal =='Converted' || leadStatusVal =='Expired' || leadStatusVal =='Dismissed') ) */
        {
            leadstatus.set("v.errors", [{message: "You are not allowed to change the Lead Status to New, Eligible, Contacted, Responded, Converted and Expired"}]);
            hasError = true;
        }
        
        if(!$A.util.isEmpty(leadStatusVal) && component.get("v.isTelesalesLead")==true && component.get("v.isLeadStatusDisable")==false)
        {
            if(component.get("v.isReminderCompleted")==false && leadStatusVal=='Qualified')
            {
             leadstatus.set("v.errors", [{message:"You can change the status after the Reminder date"}]);  
             hasError = true; 
            }else if(component.get("v.isleadStatusChangeIncorrect")==true || (leadStatusVal =='Responded' && leadSubStatusVal!='Action Required')){ 
                leadstatus.set("v.errors", [{message: "You are not allowed to change the Lead Status to New, Eligible, Contacted, Responded, Converted and Expired"}]);
                hasError = true;
            }
        }
        
        if(!$A.util.isEmpty(leadStatusVal) &&  component.get("v.isLeadStatusDisable")==false && leadStatusVal=='Qualified' && (leadSubStatusVal == "--None--"||$A.util.isEmpty(leadSubStatusVal)))
        {
            leadSubstatus.set("v.errors", [{message: "All Qualified leads need a sub-status selected"}]);
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && $A.util.isEmpty(msgConsentval) || msgConsentval ==false )
        {
            msgConsent.set("v.errors", [{message: "Please agree the consent Message"}]);
            hasError = true;
        }/*
        if(component.get("v.IsNotCustomerCart")==true && $A.util.isEmpty(eventTypeVal)|| eventTypeVal =="--None--"){
 
            eventTypeField.set("v.errors", [{message: "Event Type is mandatory"}]);
            hasError = true; 
        }*/
        if(component.get("v.IsNotCustomerCart")==true && $A.util.isEmpty(smsFollowUpDateVal)  )
        {
            smsFollowUpDateField.set("v.errors", [{message: "SMS Follow Up Date/Time cannot be empty. Please enter the 'SMS Follow Up Date/Time' field.  "}]);
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(smsFollowUpDateVal) && (isNaN(smsFollowUpDate)))
        {
            smsFollowUpDateField.set("v.errors", [{message: "Please enter Valid SMS Follow Up Date/Time "}]);
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(smsFollowUpDateVal) && component.get("v.isDisableEvent")==false &&  smsFollowUpDate<todayDate ){
            smsFollowUpDateField.set("v.errors", [{message: "SMS Follow Up Date/Time cannot be in Past. Please correct the 'SMS Follow Up Date/Time' field. "}]);
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(smsFollowUpDateVal) && todayDate<IphoneDate && smsFollowUpDate<IphoneDate && $A.util.isEmpty(eventTypeVal) && eventTypeVal == "iPhone X"  )
        {
            smsFollowUpDateField.set("v.errors", [{message: " Please select October 26th for the iPhone X pre-order "}]);
            hasError = true;
        }
        if($A.util.isEmpty(numberOfLinesVal)){
            numberOfLinesField.set("v.errors", [{message: "Please enter Number of Lines Interested In"}]);    
            hasError = true;
        }
        if(component.get("v.IsNotCustomerCart")==true && !$A.util.isEmpty(numberOfLinesVal) && numberOfLinesVal.search(mtnRegExp)!=0)
        {
            numberOfLinesField.set("v.errors", [{message: "Please enter valid Number of Lines Interested In"}]);    
            hasError = true;
        }
      /*  if( !$A.util.isEmpty(PostalCodeval) && (PostalCodeval.length<5 || PostalCodeval.length>5 || PostalCodeval.search(mtnRegExp)!=0)  )
        {
            PostalCode.set("v.errors", [{message: "Please enter a valid Zip/Postal Code"}]);
            hasError = true;
        }*/
        var eventTypeFld = component.find("eventTypeId");
        if (eventTypeFld){
            var eventTypeField = component.find("eventTypeId").get("v.value");
            
            if (eventTypeField){
                var eventTyMap = component.get('v.eventTypeMap');        
                for (var key in eventTyMap) {
                    debugger;
                    if (eventTypeField == key.split('_')[0]) {
                        component.set('v.lead.CCPM_eventType__c',key.split('_')[1]);
                    }
                }
            }
        }
        
        if(!hasError){
            var theLead = component.get("v.lead");
            theLead.sobjectType = "Lead";
            var action = component.get("c.updateLead");
            action.setParams({
                "objLead" : theLead
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS")
                {
                    theLead = response.getReturnValue();
                    if (!$A.util.isEmpty(theLead)) {
                        this.navigateToDetail(component, theLead);
                        //component.set("v.lead", theLead);
                    }
                }
                else if(state === "ERROR")
                {
                    component.find('scrollerID').scrollTo('top',0,0);
                    var varsubmit = event.getSource();
                    varsubmit.set("v.disabled",false);//Enable the button
                    var errors = action.getError(); 
                    component.set("v.isErrorMessage", errors[0].message);
                }
                
            });
            $A.enqueueAction(action);
        }
        else
        {
            var varsubmit = event.getSource();
            varsubmit.set("v.disabled",false);//Enable the button
            component.find('scrollerID').scrollTo('top',0,0);
            component.set("v.isGlobalErrorMessage",true);
        }
    },
    navigateToDetail: function(component, recordId){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId" : recordId,
            "slideDevName" : "Detail"
        });
        navEvt.fire();
    },
    eventTypeChangeHelper : function(component, event, helper) {
        var selectedType = component.find("eventTypeId").get("v.value");

        var isLeadExists = component.get('v.IsManualLead');
        var eventTypeMap = component.get('v.eventTypeMap');
        var currDat = new Date();
        var currentDate = currDat.toISOString().replace('T', ' ').replace(/\..*$/, '');
        var eventMsgV = '';
        if (selectedType == '--None--') {
            component.set('v.eventMsgVal','');
            var emptList = [];
            component.set('v.eventMsgList',emptList);
        } else {
            for (var key in eventTypeMap) {
                if (selectedType == key.split('_')[0]){
                    var msgList = eventTypeMap[key];
                    if(msgList !=null  && msgList != ''){
                     if (msgList.length > 1) {
                        for (var i =0;i<msgList.length;i++) {
                            if (msgList[i].CCPM_eventMessageEndDate__c != null && 
                                msgList[i].CCPM_eventMessageEndDate__c != '') {
                                if (currentDate <= msgList[i].CCPM_eventMessageEndDate__c && 
                                    currentDate >= msgList[i].CCPM_eventMessageStartDate__c) {
                                    if(isLeadExists){
                                        if (msgList[i].CCPM_customerMessage__c != null && 
                                            msgList[i].CCPM_customerMessage__c != '') {
                            				eventMsgV = msgList[i].CCPM_customerMessage__c;
                            			}
                                    } else {
                                        if (eventMsgV = msgList[i].CCPM_prospectMessage__c != null &&
                                           msgList[i].CCPM_prospectMessage__c != '') {
                                        	eventMsgV = msgList[i].CCPM_prospectMessage__c; 
                                        }
                                    }
                                }
                            } else {
                                if (currentDate >= msgList[i].CCPM_eventMessageStartDate__c) {
                                    if(isLeadExists){
                                        if (msgList[i].CCPM_customerMessage__c != null && 
                                            msgList[i].CCPM_customerMessage__c != '') {
                            				eventMsgV = msgList[i].CCPM_customerMessage__c;
                            			}
                                    } else {
                                        if (eventMsgV = msgList[i].CCPM_prospectMessage__c != null &&
                                           msgList[i].CCPM_prospectMessage__c != '') {
                                           eventMsgV = msgList[i].CCPM_prospectMessage__c; 
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if(isLeadExists){
                            if (msgList[0].CCPM_customerMessage__c != null && msgList[0].CCPM_customerMessage__c != '') {
                            	eventMsgV = msgList[0].CCPM_customerMessage__c;
                            }
                        } else {
                            if (msgList[0].CCPM_prospectMessage__c != null && msgList[0].CCPM_prospectMessage__c != '') {
                                eventMsgV = msgList[0].CCPM_prospectMessage__c; 
                            }
                        }
                    }
                        }
                    if (eventMsgV!=null && eventMsgV != ''){
                        var finalVal = [eventMsgV];
                        if (eventMsgV.includes("%")){
                            finalVal = eventMsgV.split("%");
                        }
                        if (finalVal.length>0){
                            component.set('v.eventMsgVal',eventMsgV);
                            component.set('v.eventMsgList',finalVal);
                        }
                    }
                }
            }
        }
    },
    
    doInitHelper : function (component, event, helper) {
        var action = component.get('c.getEventTypeMap');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var isLeadExists = component.get('v.IsManualLead');
        action.setParams({
            strUserId : userId
        });
        action.setCallback (this,function(response){
            var status = response.getState();
            if (status === 'SUCCESS') {
                var resp = response.getReturnValue();
                
                if (resp){
                    component.set('v.eventMap',resp);
                    if (isLeadExists) {
                        component.set('v.eventTypeMap',resp['Customer']);
                    } else {
                        component.set('v.eventTypeMap',resp['Prospect']);
                    }
                    var eventTypMap = component.get('v.eventTypeMap');
                    var evtNameList = [];
                    var fieldVal = component.get("v.lead.CCPM_eventType__c");
                    var eventTypeVal = component.find("eventTypeId");
                    var isValFound = false;
                    for (var key in eventTypMap) {
                        if (fieldVal == key.split('_')[1]) {
                            evtNameList.push(key.split('_')[0]);
                            isValFound = true;
                        }
                    }
                    
                    for (var key in eventTypMap) {
                        if (isValFound == true && !evtNameList.includes(key.split('_')[0])) {
                        	evtNameList.push(key.split('_')[0]);
                        }
                    }
                    component.set('v.eventNameList',evtNameList);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
   getProfilePermissionforNotes : function(component, event) {
	var action = component.get("c.getUserProfilePermissionforNotes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var notesPermission = response.getReturnValue();
                component.set("v.isLeadNotesDisable", notesPermission);
            }
        });
        $A.enqueueAction(action);
    },
    
    getProfilePermissionforStatus : function(component, event) {
	var action = component.get("c.getUserProfilePermissionforStatus");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var profileRetailMarketAnalyst = response.getReturnValue();
                component.set("v.isProfileRetailMarketAnalyst", profileRetailMarketAnalyst);
            }
        });
        $A.enqueueAction(action);
    }
})