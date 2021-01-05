({
	doInit : function(component, event, helper) {
		var action = component.get("c.updateTeamMembers");
        action.setParams({team: component.get("v.recordId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Members successfully updated for this team",
                    "type": "success"
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error updating members. Check Litmos Sync Logs for details",
                    "type": "error"
                });
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
            }
        });
        $A.enqueueAction(action);
	}
})