({
    init : function(component) {
        var action = component.get("c.getFiscalYears");
        this.showSpinner(component);
        action.setCallback(this, function(response) {
            this.hideSpinner(component);
            var state = response.getState();
            if(state === "SUCCESS"){
                var fiscalYears = response.getReturnValue();
                if($A.util.isEmpty(fiscalYears)){
                    this.showToast("Error: ", $A.get('$Label.c.ErrorFiscalData'), "error");
                }else{
                    component.set("v.fiscalYears", fiscalYears);
                }
            }else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        this.showToast("Error: ", errors[0].message, "error");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    generateBarChart: function (component) {
        var accountId   = component.get("v.recordId"),
        selFiscalYear	= component.get("v.selFiscalYear"),
            action 		= component.get("c.getChartData");
        
        action.setParams({
            "accountId"  :accountId,
            "fiscalYear":selFiscalYear
        });
        
        this.showSpinner(component);
        
        action.setCallback(this, function(response) {
            this.hideSpinner(component);
            var state = response.getState();
            if(state === "SUCCESS"){
                var chartData = response.getReturnValue();
                if($A.util.isEmpty(chartData)){
                    this.showToast("Error: ", $A.get('$Label.c.ErrorNoDataSelectedYear'), "error");
                }else{
                    component.find("chartComp").loadChart(chartData);
                }
            }else{
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        this.showToast("Error: ", errors[0].message, "error");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    
    hideSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})