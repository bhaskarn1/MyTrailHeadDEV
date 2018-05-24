({
    
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
   
    /*
    getPicklistValuesforEventType : function(component, event) {
        var action1 = component.get("c.getEventTypeValues");
        var inputsel1 = component.find("eventType");
        var opts1=[];
        if((component.get("v.isVisionAccount")||component.get("v.isSfdcAccount"))){
            var isManualLead = true;
            //opts1.pop({"class": "optionClass", label: "TMP OE - Q2 2018", value: "TMP OE - Q2 2018"});
        }
        
        action1.setParams({
            "isManualLead" : isManualLead,
        });
        
        action1.setCallback(this, function(response) {
            for(var i=0;i< response.getReturnValue().length;i++){
                opts1.push({"class": "optionClass",  label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }

            inputsel1.set("v.options", opts1);
        	
        });
        $A.enqueueAction(action1); 
    },*/
    
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
    clickSubmit : function(component, event, helper){
        
        var mtn='';
        var confirmMtn = '';
        var hasError = false;
        var mtnField = component.find("MTN");
        component.set("v.isErrorMessage", null);
        mtnField.set("v.errors", null);
        if(component.get("v.isVisionAccount")==false && component.get("v.isSfdcAccount")==false)
        {
        var confirmMtnField = component.find("confirmMTN");
        confirmMtnField.set("v.errors", null);
        }
        if (!$A.util.isEmpty(mtnField)) {
            if (!$A.util.isEmpty(mtnField.get("v.value"))) 
            {
                mtn = mtnField.get("v.value");
                mtn=mtn.replace(/[- ( )]/g,'');
            }
            
            
        }
        if (!$A.util.isEmpty(confirmMtnField)){
            if (!$A.util.isEmpty(confirmMtnField.get("v.value"))) {
                confirmMtn = confirmMtnField.get("v.value");
                confirmMtn=confirmMtn.replace(/[- ( )]/g,'');
            }
        }
        var email = '';
        var emailField='';
        emailField = component.find("Email");
        console.log(emailField);
        emailField.set("v.errors", null);
        if(!$A.util.isEmpty(emailField)){
            email = emailField.get("v.value"); 
        }
        if(component.get("v.isVisionAccount")==false && component.get("v.isSfdcAccount")==false)
        {
        var confirmEmailVal = '';
        var confirmEmailField = component.find("confirmEmail");
            console.log(confirmEmailField);
        confirmEmailField.set("v.errors", null);
        if(!$A.util.isEmpty(confirmEmailField)){
            confirmEmailVal = confirmEmailField.get("v.value");
            
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
        var eventTypeField = component.find("eventTypeId").get("v.value");
        var eventTyMap = component.get('v.eventTypeMap');
        debugger;
        console.log(eventTyMap);
        if(eventTypeField == '--None--' || !eventTypeField) {
            component.set('v.eventTypeErr',true);
        } else {
            debugger;
            for (var key in eventTyMap) {
                if (eventTypeField == key.split('_')[0]) {
                    component.set('v.lead.CCPM_eventType__c',key.split('_')[1]);
                }
            }
        }
       
        var msgConsentval='';
        var msgConsent=component.find("agree");
        msgConsent.set("v.errors", null);
        if(!$A.util.isEmpty(msgConsent))
        {
            msgConsentval = msgConsent.get("v.value");
        }
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
        
        var numberOfLinesField = component.find("numberOfLines");
        var numberOfLinesVal = numberOfLinesField.get("v.value");
        numberOfLinesField.set("v.errors", null);
        var charRegExp = RegExp("^[a-z + A-Z]*$");
        var mtnRegExp = RegExp("^[0-9 + (+)+-]*$");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        console.log(mtn + ' - ' +confirmMtn);
        if(($A.util.isEmpty(mtn) || mtn.length=='') && $A.util.isEmpty(email)   )
        {
            mtnField.set("v.errors", [{message: "MTN or Email is required to save the record"}]);
            hasError = true;   
        }
         if($A.util.isEmpty(email) && !$A.util.isEmpty(mtn) && (mtn.length<10 || mtn.length>15 || mtn.search(mtnRegExp)!=0))
        {
            mtnField.set("v.errors", [{message: "Please enter valid MTN"}]);
            hasError = true;

        }
             if (component.get("v.isVisionAccount")==false && component.get("v.isSfdcAccount")==false && !$A.util.isEmpty(mtn) && $A.util.isEmpty(confirmMtn))
            {
                confirmMtnField.set("v.errors", [{message: " Please confirm MTN before proceeding"}]);
                //confirmMtnField.getElementFocus();
                hasError = true;
            }
                 if(component.get("v.isVisionAccount")==false && component.get("v.isSfdcAccount")==false && !$A.util.isEmpty(mtn) && !$A.util.isEmpty(confirmMtn) && mtn != confirmMtn)
                {
                    confirmMtnField.set("v.errors", [{message: "Both the MTN's should match"}]);
                    hasError = true;
                    //component.find('scrollerID').scrollTo('top',0,0);
                }
        
                     if (component.get("v.isVisionAccount")==false && component.get("v.isSfdcAccount")==false && !$A.util.isEmpty(email) && $A.util.isEmpty(confirmEmailVal))
                    {
                        confirmEmailField.set("v.errors", [{message: " Please confirm Email before proceeding"}]);
                        //confirmMtnField.getElementFocus();
                        hasError = true;
                        
                    }
                         if(component.get("v.isVisionAccount")==false && component.get("v.isSfdcAccount")==false && !$A.util.isEmpty(email) && !$A.util.isEmpty(confirmEmailVal) && email != confirmEmailVal)
                        {
                            confirmEmailField.set("v.errors", [{message: "Both the Email's should match"}]);                            
                            hasError = true;
                        }
        					 if($A.util.isEmpty(fName)){
                                    firstNameCmp.set("v.errors", [{message: "First Name is mandatory"}]);
                                    hasError = true;
                                }
                             if(!$A.util.isEmpty(fName) && fName.search(charRegExp)!=0){
                                firstNameCmp.set("v.errors", [{message: "First Name cannot contain special characters or numbers"}]);
                                hasError = true;
                            }
                                 if($A.util.isEmpty(lName)){
                                    lastName.set("v.errors", [{message: "Last Name is mandatory"}]);
                                    hasError = true;
                                }
                                     if(!$A.util.isEmpty(lName) && lName.search(charRegExp)!=0){
                                        lastName.set("v.errors", [{message: "Last Name cannot contain special characters or numbers"}]);
                                        hasError = true;  
                                    } 
                                         if(!$A.util.isEmpty(email) && !email.match(regExpEmailformat))
                                        {
                                            emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                                            hasError = true;
                                        }
                                             if($A.util.isEmpty(msgConsentval) || msgConsentval ==false)
                                            {
                                                console.log("msgConsentval");
                                                msgConsent.set("v.errors", [{message: "Please agree the consent Message"}]);
                                                hasError = true;
                                            }
                                                 //event type
                                                     if(component.get("v.isEventBasedDisable")==false && $A.util.isEmpty(smsFollowUpDateVal)){
                                                        smsFollowUpDateField.set("v.errors", [{message: "Please enter SMS Follow-Up Date"}]);
                                                        hasError = true;
                                                    }
        											 if(!$A.util.isEmpty(smsFollowUpDateVal) && (isNaN(smsFollowUpDate)))
                                                        {
                                                            console.log('the debug is entered')
                                                            smsFollowUpDateField.set("v.errors", [{message: "Please enter Valid SMS Follow Up Date/Time "}]);
                                                            hasError = true;
                                                        }
                                                         if(!$A.util.isEmpty(smsFollowUpDateVal) && smsFollowUpDate<todayDate )
                                                        {
                                                            smsFollowUpDateField.set("v.errors", [{message: "SMS Follow Up Date/Time cannot be in Past. Please correct the 'SMS Follow Up Date/Time' field. "}]);
                                                            hasError = true;
                                                        }
                                                         if(!$A.util.isEmpty(smsFollowUpDateVal) && todayDate<IphoneDate && smsFollowUpDate<IphoneDate && $A.util.isEmpty(eventTypeVal) && eventTypeVal == "iPhone X"  )
                                                            {
                                                                console.log("newevent"+eventTypeVal);
                                                                smsFollowUpDateField.set("v.errors", [{message: " Please select October 26th for the iPhone X pre-order "}]);
                                                                hasError = true;
                                                            }
                                                             if($A.util.isEmpty(numberOfLinesVal))
                                                            {
                                                                numberOfLinesField.set("v.errors", [{message: "Please enter Number of Lines Interested In"}]);    
                                                                hasError = true;
                                                            }
                                                                 if(!$A.util.isEmpty(numberOfLinesVal) && numberOfLinesVal.search(mtnRegExp)!=0)
                                                                {
                                                                    numberOfLinesField.set("v.errors", [{message: "Please enter valid Number of Lines Interested In"}]);    
                                                                    hasError = true;
                                                                }
                                                                   /*  if( !$A.util.isEmpty(PostalCodeval) && (PostalCodeval.length<5 || PostalCodeval.length>5 || PostalCodeval.search(mtnRegExp)!=0)  )
                                                                    {
                                                                        PostalCode.set("v.errors", [{message: "Please enter a valid Zip/Postal Code"}]);
                                                                        hasError = true;
                                                                    }*/
        
        var isEventTypeErr = component.get('v.eventTypeErr');
        if(!hasError && !isEventTypeErr){
            console.log("Lead 0");
            var theLead = component.get("v.lead");
            /*var jsCountry=component.find('country');
            if(jsCountry.get("v.value")!='--None--')
            {
                theLead.Country=jsCountry.get("v.value");
            }
            var jsState=component.find('state');
            if(jsState.get("v.value")!='--None--')
            {
                theLead.State=jsState.get("v.value");    
            }*/
            var VisionAccount = component.get("v.isVisionAccount");
            var SalesforceAccount = component.get("v.isSfdcAccount");
            console.log(VisionAccount);
            
            
            var VsAccount;
            console.log("component get account");
            if(VisionAccount == true)
            {                        
                VsAccount = component.get("v.account");
                console.log('sfvision test'+VsAccount.CCPM_email__c);
                console.log(VsAccount);
                
            }
            var SfAccount;
            if(SalesforceAccount == true)
            {
                SfAccount = component.get("v.account");
                console.log(SfAccount);
            }
            console.log("Lead 1" +theLead.sobjectType);
            console.log(VsAccount);
            console.log(SfAccount);
            console.log(theLead);
            var action = component.get("c.createLeadRec");
            //console.log("trying" +a1);
            action.setParams({
                "objLead" : theLead,
                "objVsAccount" : VsAccount,
                "objSfAccount"  : SfAccount
            });
            console.log("Lead" +theLead);
            action.setCallback(this, function(response){
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS")
                {
                    console.log("error not throwm");
                    theLead = response.getReturnValue();
                    if (!$A.util.isEmpty(theLead)) {
                        this.navigateToDetail(component, theLead);
                        //component.set("v.lead", theLead);
                    }
                }else if(state === "ERROR")
                {
                    component.find('scrollerID').scrollTo('top',0,0);
                    var varsubmit = event.getSource();
                    varsubmit.set("v.disabled",false);//Enable the button
                    var errors = action.getError();
                    console.log("errors"+errors[0].message);  
                    component.set("v.isErrorMessage", errors[0].message);
                }
                
            });
            $A.enqueueAction(action);
        }else
        {
            console.log("yes");
            component.find('scrollerID').scrollTo('top',0,0);
             component.set("v.isGlobalErrorMessage",true);
            var varsubmit = event.getSource();
            varsubmit.set("v.disabled",false);//Enable the button
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
    clickCancel : function(component, event, helper) {
        //this.navigateToDetail(component, event,helper);
        var evt = $A.get("e.force:navigateToURL");
        evt.setParams({
            //componentDef : "c:CCPM_prospectLayout",
            "url": "/00Q"
            //isredirect : true
        });
        evt.fire();
    },
    
    getPicklistValuesforCartStatus : function(component, event) {
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
                opts1.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
            }
            inputsel1.set("v.options", opts1);
            
        });
        $A.enqueueAction(action1); 
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
    
    eventTypeChangeHelper : function(component, event, helper) {
        var selectedType = component.find("eventTypeId").get("v.value");

        var isLeadExists = component.get('v.isMtnExist');
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
                    if (msgList != null && msgList != ''){
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
      /*  var eventMap = component.get('v.eventMap');
        var isLeadExists = component.get('v.isMtnExist');
        var currDat = new Date();
        var currentDate = currDat.toISOString().replace('T', ' ').replace(/\..*$/, '');
        var eventMsgV = '';
        if (selectedType == '--None--') {
            component.set('v.eventMsgVal','');
            var emptList = [];
            component.set('v.eventMsgList',emptList);
        } 
        else {
            for (var key in eventMap){
                if (selectedType == key) {
                    var lstJM = JSON.stringify(eventMap[key]);
                    var lstJourneyMsg = eventMap[key];
                    if (lstJourneyMsg.length > 1) {
                        for (var i =0;i<lstJourneyMsg.length;i++) {
                            if (lstJourneyMsg[i].CCPM_eventSMSFollowUpEndDate__c != null && 
                                lstJourneyMsg[i].CCPM_eventSMSFollowUpEndDate__c != '') {
                                if (currentDate <= lstJourneyMsg[i].CCPM_eventSMSFollowUpEndDate__c && 
                                    currentDate >= lstJourneyMsg[i].CCPM_eventSMSFollowUpStartDate__c) {
                                    if(isLeadExists){
                                        eventMsgV = lstJourneyMsg[i].CCPM_customerMessage__c;
                                    } else {
                                        eventMsgV = lstJourneyMsg[i].CCPM_prospectMessage__c;
                                    }
                                }
                            } else {
                                if (currentDate >= lstJourneyMsg[i].CCPM_eventSMSFollowUpStartDate__c) {
                                    if(isLeadExists){
                                        eventMsgV = lstJourneyMsg[i].CCPM_customerMessage__c;
                                    } else {
                                        eventMsgV = lstJourneyMsg[i].CCPM_prospectMessage__c; 
                                    }
                                }
                            }
                        }
                    } else {
                        if(isLeadExists){
                            eventMsgV = lstJourneyMsg[0].CCPM_customerMessage__c;
                        } else {
                            eventMsgV = lstJourneyMsg[0].CCPM_prospectMessage__c; 
                        }
                    }
                    component.set('v.eventMsgVal',eventMsgV);
                    var finalVal = [eventMsgV];
                    if (eventMsgV.includes("%")){
                       finalVal = eventMsgV.split("%");
                        if (finalVal.length>1){
                            component.set('v.eventMsgList',finalVal);
                        } 
                    }
                }
            }
        }
    },
    
    doInitHelper : function (component, event, helper) {
        var action = component.get('c.getJourneyMsg');
        action.setCallback(this,function(response){
            var status = response.getState();
            if (status == 'SUCCESS') {
                var resp = response.getReturnValue();
                if(resp){
                    component.set('v.eventMap',resp);
                    console.log(JSON.stringify(resp));
                    var evMap = component.get('v.eventMap'); 
                }
            }
        });
        $A.enqueueAction(action);
    }*/
    
    getEventTypeMapHelper : function(component, event, helper) {
        var action = component.get('c.getEventTypeMap');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var isLeadExists = component.get('v.isMtnExist');
      /*  var mainMap = component.get('v.eventMap');
        if(mainMap){
            if (isLeadExists) {
                component.set('v.eventTypeMap',mainMap['Customer']);
            } else {
                component.set('v.eventTypeMap',mainMap['Prospect']);
            }
            var eventTypMap = component.get('v.eventTypeMap');
            var evtNameList = [];
            var isTelesales = component.get('v.isTelesalesUser');
            if (!isTelesales) {
                evtNameList = ['--None--']; 
            }
            for (var key in eventTypMap) {
                
                evtNameList.push(key.split('_')[0]);
            }
            component.set('v.eventNameList',evtNameList);
        }*/
        
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
                    var isTelesales = component.get('v.isTelesalesUser');
                    if (!isTelesales) {
                       evtNameList = ['--None--']; 
                    }
                    for (var key in eventTypMap) {
                        
                        evtNameList.push(key.split('_')[0]);
                    }
                    component.set('v.eventNameList',evtNameList);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsTelesalesUserHelper : function(component, event, helper) {
        var action = component.get('c.getIsTelesalesUser');
        action.setCallback(this,function(response){
            var status = response.getState();
            if (status === 'SUCCESS') {
                var resp = response.getReturnValue();
                component.set('v.isTelesalesUser', resp);
                helper.getEventTypeMapHelper (component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
   /* doInitHelper : function(component,event,helper) {
        var action = component.get('c.getEventTypeMap');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({
            strUserId : userId
        });
        action.setCallback (this,function(response){
            var status = response.getState();
            if (status === 'SUCCESS') {
                var resp = response.getReturnValue();
                if (resp){
                    component.set('v.eventMap',resp);
                }
            }
        });
        $A.enqueueAction(action);
    }*/
    
});