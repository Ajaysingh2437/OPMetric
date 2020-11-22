public with sharing class Utility {
    public String getFullMonthName(Integer month) {
        if(month == null){return null;}
        Map<Integer, String> intMonthVSFullMonthMap = new Map<Integer, String>();
        String fullMonth = '';

        if(intMonthVSFullMonthMap.containsKey(month)){
            fullMonth = intMonthVSFullMonthMap.get(month);
        }else{
            fullMonth  = DateTime.newInstanceGMT(Date.newInstance(2000, month, 1), Time.newInstance(0, 0, 0, 0)).formatGMT('MMM');
            intMonthVSFullMonthMap.put(month, fullMonth);
        }

        return fullMonth;
    }
}
