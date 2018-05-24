({
	init : function(component, event, helper) {
		component.find('notifLib').showNotice({
            "variant": component.get('v.variant'),
            "header": component.get('v.header'),
            "message": component.get('v.message'),
            closeCallback: function() {
            }
        });

	}
})