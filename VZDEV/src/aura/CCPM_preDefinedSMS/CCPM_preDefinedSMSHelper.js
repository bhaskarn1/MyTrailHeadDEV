({  
    
    initHelper : function(component, event, helper) {
    	var action = component.get("c.getLeadAndSendSMSWrapperInfo");
        var leadId = component.get('v.recordId');

        action.setParams({
            strLeadId : leadId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state == 'SUCCESS') {
                var resp = response.getReturnValue();
                if(resp) {
                    var strResp = JSON.stringify(resp);
                    console.log(strResp);
					component.set('v.lead',resp.objLead);
                    component.set('v.smsMap',resp.mapSmsMessage);
                    component.set('v.recordTypeName',resp.strMessage);
                    var strMsg = component.get('v.recordTypeName');
                    if (resp.setRestrictedWords != null) {
                        component.set('v.foulWordSet',resp.setRestrictedWords);
                    }
                    if (strMsg == 'Customer' || strMsg == 'Prospect' ) {
                        component.set('v.hideFields',false);
                    } 
                    if(strMsg == 'Customer') {
                        component.set('v.textLength',150);
                    } else {
                        component.set('v.textLength',160);
                    }
                    if (resp.mapSmsMessage != null) {
                        var smsList = Object.keys(resp.mapSmsMessage);
                        component.set('v.smsValues',smsList);
                    }
                    component.set('v.subStatValues',resp.lstSubStatusValues); 
                }
            } 
        });
        $A.enqueueAction(action);
    },
    
    sendSMSHelper : function (component, event, helper) {
        component.set('v.foulMsgError','');
        component.set('v.smsReqError','');
        var selectedSmsLabel = component.find("smsValLabels").get("v.value");
        var subStat = component.find("subStatLabels").get("v.value");
        if (selectedSmsLabel == '--None--' || selectedSmsLabel == null || selectedSmsLabel =='') {
            component.set('v.msgLabelError', true);
        } 
        if (subStat == '--None--' || subStat == null || subStat =='') {
            component.set('v.subStatError',true);
        } else {
            component.set('v.lead.CCPM_leadSubStatus__c',subStat);
        }
        
        var replySms = component.get('v.smsMsgVal');
        if (selectedSmsLabel == 'Custom Reply' && (replySms == null || replySms == '')) {
            component.set('v.customRepError',true);
        }
        
        var msgLabel = component.get('v.msgLabelError');
        var subStatErr = component.get('v.subStatError');
        var customRepErr = component.get('v.customRepError');
        var foulWordList = [];
        
        if (!msgLabel && !subStatErr ) {

            var msg = component.get('v.smsMsgVal');
           	msg = msg.trim();
            var foulWordSet = component.get('v.foulWordSet');
            var msgBody = msg.split(" ");
            if (foulWordSet.length>=1 && msgBody.length>=1 && selectedSmsLabel == 'Custom Reply') {
                
                for (var i=0;i<msgBody.length;i++) {
                    for (var j=0;j<foulWordSet.length;j++) {
                        if (msgBody[i].toLowerCase() == foulWordSet[j].toLowerCase()) {
                            foulWordList.push(msgBody[i]);
                        }
                    }
                }
                
                for (var k=0;k<msgBody.length;k++) {
                    for (var l=0;l<foulWordSet.length;l++){
                        if(k > 0 ) {
                            var flWord = msgBody[k-1]+' '+msgBody[k];
                            if (flWord.toLowerCase() == foulWordSet[l].toLowerCase()) {
                                foulWordList.push(foulWordSet[l]);
                            }
                        }
                    }
                }
            }
            var action = component.get("c.sendPreDefinedSMSToCustomer");
            action.setParams({
                objLead   : component.get('v.lead'),
                strMessageLabel : selectedSmsLabel,
                strSMSMessageBody : msg,
                lstFoulWords : foulWordList
            });
            
            action.setCallback (this,function(response){
                var state = response.getState();
                if (state == 'SUCCESS') {
                    var resp = response.getReturnValue();
                    if (resp == 204) {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : "SUCCESS",
                            type : "success",
                            message : "SMS sent Successfully"
                        });
                        toastEvent.fire();
                    } else if (foulWordList.length >=1){
                        component.set('v.foulMsgError',
                             'Foul language detected. Message not sent.');
                    } else {
                        component.set('v.smsReqError','Cannot send SMS.Please try again later');
                    }
                } else if(state == 'ERROR'){
                    var strErr = response.getError();
                    if (strErr && strErr.length > 0) {
                        component.set('v.smsReqError',strErr[0].message);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    onSMSValueChangeHelper : function(component, event, helper) {
        component.set('v.foulMsgError','');
        component.set('v.customRepError',false);
        var selectedVal = component.find("smsValLabels").get("v.value");
        component.set('v.selectedMessage',selectedVal);
        if (selectedVal != 'Custom Reply') {
            component.set('v.charLimitReached',false);
        }
        if (selectedVal != '--None--') {
            component.set('v.msgLabelError',false);
            if (selectedVal == 'Custom Reply') {
                component.set('v.messageLength',0);
                component.set('v.smsMsgVal','');
            } else {
                var smsMap = component.get('v.smsMap');
                for (var key in smsMap) {
                    if (selectedVal == key) {
                        component.set('v.smsMsgVal',smsMap[key]);
                    }
                }
            }
            var smsMsgVal = component.get('v.smsMsgVal');
            var recType = component.get('v.recordTypeName');
            if (smsMsgVal != null && smsMsgVal != null && recType != 'Prospect') {
                if (smsMsgVal.includes('FreeVzMsg')) {
                    component.set('v.showFreeMsg',false);
                } else {
                    component.set('v.showFreeMsg',true);
                }
            } else {
                component.set('v.showFreeMsg',false);
            }
        } 
    },
     
    maxLengthCheckHelper : function(component, event, helper){
        component.set('v.foulMsgError','');
        component.set('v.customRepError',false);
        var fieldValue = component.find("customReply").get("v.value");
        if(fieldValue != null){
            component.set('v.messageLength',fieldValue.length);
            var recType = component.get('v.recordTypeName');
            
            if (recType == 'Prospect' && fieldValue.length >= 160) {
                component.set('v.charLimitReached',true);

            } else if (recType == 'Customer' && fieldValue.length >= 150) {
                component.set('v.charLimitReached',true);
            } else {
                component.set('v.charLimitReached',false);
            }
        }
    },
})