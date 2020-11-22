public with sharing class OPMetricsController {
    @AuraEnabled(cacheable = true)
    public static List<Period> getFiscalYears(){
        try {
            return [SELECT FullyQualifiedLabel, FiscalYearSettings.Name 
                FROM Period  WHERE Type =: GlobalConstants.PERIODTYPEYEAR
                WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static ChartDataWrapper getChartData(Id accountId, Integer fiscalYear) {
        List<AggregateResult> oppData       = new List<AggregateResult>();
        ChartDataWrapper cdw                = new ChartDataWrapper();

        cdw.datasets.add(new OPDataWrapper(GlobalConstants.OPPSTATUSWINS,    'green',    new List<Integer>()));
        cdw.datasets.add(new OPDataWrapper(GlobalConstants.OPPSTATUSLOST,    'red',      new List<Integer>()));
        cdw.datasets.add(new OPDataWrapper(GlobalConstants.OPPSTATUSPIPELINE,'blue',     new List<Integer>()));


        if(accountId == null || fiscalYear == null){
            return null;
        }
        try {
            oppData = [SELECT SUM(Amount) Sum, Calendar_Month(CloseDate) Month,
                        Calendar_Year(CloseDate) Year, StageName 
                        FROM Opportunity 
                        WHERE AccountId =: accountId
                        AND Fiscal_Year(CloseDate) =: fiscalYear
                        WITH SECURITY_ENFORCED
                        GROUP BY Calendar_Month(CloseDate),Calendar_Year(CloseDate), StageName
                        ORDER BY Calendar_Year(CloseDate),Calendar_Month(CloseDate)];
            if(oppData.isEmpty()){
                return null;
            }

            Integer prevMonth = 99;
            Integer curMonth;
            Utility util = new Utility();
            Integer sum = 0;
            List<Integer> data = new List<Integer>();
            for (Integer i = 0; i < oppData.size(); i++) {
                sum         = Integer.valueOf(oppData[i]?.get('Sum'));
                curMonth    = Integer.valueOf(oppData[i]?.get('Month'));
                if(prevMonth != curMonth){
                    cdw.labels.add(util.getFullMonthName(curMonth) + ' - ' +oppData[i]?.get('Year'));
                    if(oppData[i]?.get('StageName').equals(GlobalConstants.OPPSTATUSCLOSEDWON)){
                        cdw.datasets[0].data.add(sum);
                        cdw.datasets[1].data.add(0);
                        cdw.datasets[2].data.add(0);
                    }else if(oppData[i]?.get('StageName').equals(GlobalConstants.OPPSTATUSCLOSEDLOST)){
                        cdw.datasets[1].data.add(sum);
                        cdw.datasets[0].data.add(0);
                        cdw.datasets[2].data.add(0);
                    }else{
                        cdw.datasets[2].data.add(sum);
                        cdw.datasets[0].data.add(0);
                        cdw.datasets[1].data.add(0);
                    }
                    prevMonth = curMonth;
                }else{
                    if(oppData[i]?.get('StageName').equals(GlobalConstants.OPPSTATUSCLOSEDWON)){
                        data = cdw.datasets[0].data;
                        data.set(data.size()-1, sum);
                    }else if(oppData[i]?.get('StageName').equals(GlobalConstants.OPPSTATUSCLOSEDLOST)){
                        data = cdw.datasets[1].data;
                        data.set(data.size()-1, sum);
                    }else{
                        data = cdw.datasets[2].data;
                        if(oppData[i-1]?.get('StageName').equals(GlobalConstants.OPPSTATUSCLOSEDWON) || oppData[i-1]?.get('StageName').equals(GlobalConstants.OPPSTATUSCLOSEDLOST)){
                            data.set(data.size()-1, sum);
                        }else{
                            data.set(data.size()-1, data.get(data.size()-1) + sum);
                        }
                    }
                }
            }
        return cdw;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ChartDataWrapper{
        @AuraEnabled public List<String>        labels{get; set;}
        @AuraEnabled public List<OPDataWrapper> datasets{get; set;}
        ChartDataWrapper(){
            labels          = new List<String>();
            datasets  = new List<OPDataWrapper>();
        }
    }

    public class OPDataWrapper{
        @AuraEnabled public String          label{get; set;}
        @AuraEnabled public String          backgroundColor{get; set;}
        @AuraEnabled public List<Integer>   data{get; set;}
        OPDataWrapper(String label, String backgroundColor, List<Integer> data){
            this.label              = label;
            this.backgroundColor    = backgroundColor;
            this.data               = data;
        }
    }
}
