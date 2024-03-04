({
	myAction : function(component, event, helper) {
		var columns= [
            {label:"Name", fieldName:"Name", type:"text"},
            {label:"Id", fieldName:"Id", type:"text"},
            {label:"Need Contact", fieldName:"Need_Contact__c", type:"checkbox"}
        ];
        component.set("v.Columns",columns);
        var action = component.get("c.accList");
        action.setCallback(this, function(data) {
            var state = data.getState();
            if(state === "SUCCESS"){
                component.set("v.Accounts", data.getReturnValue());
            }
            else{
                alert("ERROR");
            }
        });
        $A.enqueueAction(action);
	},
    createAccount  :function(component,event,helper){
        component.set("v.showCreateAccount",true);
        component.set("v.showAccountTable",false);
    },
    handleSubmit : function(component, event, helper) {
        component.set("v.showCreateAccount",false);
        component.set("v.showAccountTable",true);
        var a = component.get('c.myAction');
        $A.enqueueAction(a);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams
        ({
            "title": "Success",
            "message": "An Account and a Contact has been created successfully!",
            "type": "success",
        }).fire();
    },
    close : function(component, event, helper) {
      component.set("v.showCreateAccount", false);
    }
})