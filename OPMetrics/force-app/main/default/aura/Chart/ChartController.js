({	
    loadChart : function(cmp, event, helper) {
        try {
            var params = event.getParam('arguments');
            if (params) {
                var data = JSON.parse(JSON.stringify(params.chartData));
                var ctx = cmp.find("barChart").getElement().getContext('2d');
                new Chart(ctx, {
                    type: 'bar',
                    data: data,
                    options: {
                        barValueSpacing: 5,
                        scales: {
                            yAxes: [{
                                ticks: {
                                    min: 0,
                                }
                            }]
                        }
                    }
                });
            }
        } catch (error) {
            helper.showToast("Error: ", $A.get('$Label.c.ErrorChartData'), "error");
        }
    }
})