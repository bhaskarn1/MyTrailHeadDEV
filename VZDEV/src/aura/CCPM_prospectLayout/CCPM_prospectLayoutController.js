({
    doInit : function(component, event, helper) {
     component.set("v.isDisplayOnlyMTN",false);
     //helper.doInitHelper(component, event, helper);
}, 
    Click : function(component, event, helper) {
        var hasError = false;
        var searchMTN = component.find("Mobile");
        var MTN ='';
        component.set('v.eventTypeErr',false);
        searchMTN.get("v.value");
        searchMTN.set("v.errors", null);
        if(!$A.util.isEmpty(searchMTN)){
            if (!$A.util.isEmpty(searchMTN.get("v.value")))
            {
                MTN = searchMTN.get("v.value");
            }
        }
        var mtnRegExp = RegExp("^[0-9 + (+)+-]*$");
        if(MTN.length=='' ||MTN.length<10 || MTN.length>15 || MTN.search(mtnRegExp)!=0){
            hasError = true;
            component.set("v.isMtnEmpty","Please enter a valid MTN to begin search");
        }
        else{
        var searchAction = component.get("c.searchAccount");
        searchAction.setParams({"strMtn": component.get("v.lead.CCPM_mobileNumber__c")});
        component.set("v.isSfdcAccount",false);
        component.set("v.isVisionAccount",false);
        component.set("v.isEmptyAccount",false);
         component.set("v.searchResult",false);
         component.set("v.isErrorAccount",false);
		 component.set("v.isDisplayOnlyMTN",true);
         component.set("v.isMtnExist",false);
 
		 
         //searchAction.setCallback(this, function(Response){
        searchAction.setCallback(this,function(response){
            if(response.getState() == "SUCCESS")
            {
            //var state = response.getState();
            //if(component.isValid() && state === "SUCCESS"){
                var accounts = response.getReturnValue();
                 console.log(accounts);
                for ( var key in accounts ) 
                {
                    console.log(key);
                    if(key == 'Salesforce Account')
                    {
                        console.log(accounts[key]);
                        accounts[key].sobjectType = "Account";
                        component.set("v.account",accounts[key]);
                        component.set("v.isSfdcAccount",true);
                        component.set("v.searchResult",true); 
                        var splitName = accounts[key].Name.split(" ");
                        var email ="";
                        if(accounts[key].CCPM_email__c!=null)
                        {
                        email=accounts[key].CCPM_email__c;
                        }
                    	var LastName = splitName[splitName.length-1]; //The last one
                    	var FirstName = ""; // <- forgot to initialize to an empty string
                    	for (var i=0; i < splitName.length-1; i++)
                        {
                       	 FirstName += splitName[i] + " ";
   						 }
                          console.log(email,FirstName);
                        if(FirstName!=null && FirstName!="")
                        {
                        console.log(LastName,FirstName);
                        component.find("prospectFirstName").set("v.value",FirstName.trim());
                        }
                        component.find("prospectName").set("v.value",LastName);
                        if(email!=null)
                        {
 							component.find("Email").set("v.value",email.trim());  
                        }
                        component.set("v.isMtnExist",true);
                    }
                    else if(key == 'Vision Account')
                    {
                        //if(!$A.util.isEmpty(accounts[key]))
                        {
                            console.log(accounts[key]);
                            accounts[key].sobjectType = "Account";
                            component.set("v.account",accounts[key]);
                            component.set("v.isVisionAccount",true);
                            component.set("v.searchResult",true);  
							var email =accounts[key].CCPM_email__c;
                            var splitName = accounts[key].Name.split(" ");
                        //console.log(splitName);
                    	var LastName = splitName[splitName.length-1]; //The last one
                    	var FirstName = ""; // <- forgot to initialize to an empty string
                    	for (var i=0; i < splitName.length-1; i++)
                        {
                       	 FirstName += splitName[i] + " ";
   						 }
                        if(FirstName!=null && FirstName!="")
                        {
                        component.find("prospectFirstName").set("v.value",FirstName.trim());
                        }
                        component.find("prospectName").set("v.value",LastName);
                        if(email!=null)
                        {
 							component.find("Email").set("v.value",email.trim());  
                        }  
                        }
                        component.set("v.isMtnExist",true);
                    }
                    else if(key == 'System Down')
                    {
                        component.set("v.isErrorAccount",true);
                         console.log(accounts[key]);
                        component.set("v.account",null); 
                        component.set("v.searchResult",false);
                    }else if(key == 'Account doesnt exist')
                    {
                            component.set("v.isEmptyAccount",true);
                            console.log("v.isEmptyAccount");
                            component.set("v.searchResult",false);
                    }else if(key == 'Unknown Exception')
                    {
                            component.set("v.isException",true);
                            //console.log("v.isEmptyAccount");
                            component.set("v.searchResult",false);
                    }
                    
               } 
                helper.getIsTelesalesUserHelper(component, event, helper);
            }
           // helper.getPicklistValuesforEventType(component, event);
            
 });
    helper.getPicklistValues1(component, event); 
   //helper.getPicklistValuesforEventType(component, event);
   
   helper.getPicklistValuesforCommPref(component, event);
   helper.getPicklistValuesforTransComp(component, event);
   helper.getPicklistValuesforQuickNotesDesc(component, event);
   helper.getPicklistValuesforSalutation(component, event);
   helper.getPicklistValuesforCurrentCarrier(component, event);
   helper.getPicklistValuesforItemsInterestedIn(component, event);
    $A.enqueueAction(searchAction);
        }
    
        //console.log('enter Click - 1':b);;
       
    },
   
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
	varsubmit.set("v.disabled",true);//Disable the button
        var eventTypeFld = component.find("eventTypeId").get("v.value");
        var isTelesales = component.get('v.isTelesalesUser');
        if((eventTypeFld == '' || eventTypeFld==null) && isTelesales) {
            component.find("eventTypeId").set("v.value",'Reminder');
        }
        helper.clickSubmit(component, event);
		
    },
    cancel: function(component, event, helper){
        helper.clickCancel(component, event);
        //helper.navigateToDetail(component, event);
    },
    
    display: function(component, event, helper){
       helper.displayHelper(component, event);
    },
    displayOut: function(component, event, helper){
        helper.displayHelper(component, event);
    },
    
    onEventTypeChange: function(component, event, helper)
    {
        component.set('v.eventMsgVal','');
        component.set('v.eventTypeErr',false);
        helper.eventTypeChangeHelper(component, event, helper);
       /* if(component.find("eventType").get("v.value")=='Black Friday/Cyber Monday'){
        	component.set("v.isEventBasedDisable",true);
        }else {
                component.set("v.isEventBasedDisable",false);
        } */
    }
 
})