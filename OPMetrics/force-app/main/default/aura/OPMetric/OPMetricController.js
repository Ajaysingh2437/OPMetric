({
	init : function(component, event, helper) {
		helper.init(component);
    },
    
    onChange : function(component, event, helper) {
        var inputCmp = component.find('field');
        if (!$A.util.isEmpty(inputCmp.get("v.value"))) {
            helper.generateBarChart(component);
        } else {
            helper.showToast("",  $A.get('$Label.c.SelectFiscalYear'), "error");
        }
	},
})