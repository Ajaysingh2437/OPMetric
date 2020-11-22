@isTest
public with sharing class OPMetricsControllerTest {
    @testSetup static void setup() {
        Account acc = new Account(Name = 'TestAccount');
        Insert acc;
        
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(new Opportunity(Name='Test Opportunity 1',Amount = 2000, CloseDate = System.now().Date(), 
        StageName = 'Qualification', AccountId = acc.Id));
        opps.add(new Opportunity(Name='Test Opportunity 2',Amount = 3000, CloseDate = System.now().Date(), 
        StageName = 'Qualification', AccountId = acc.Id));
        opps.add(new Opportunity(Name='Test Opportunity 3',Amount = 5000, CloseDate = System.now().Date(), 
        StageName = GlobalConstants.OPPSTATUSCLOSEDWON, AccountId = acc.Id));
        opps.add(new Opportunity(Name='Test Opportunity 4',Amount = 6000, CloseDate = System.now().Date().addMonths(1), 
        StageName = GlobalConstants.OPPSTATUSCLOSEDLOST, AccountId = acc.Id));
        Insert opps;
    }
    
    @isTest
    static void testgetFiscalYears(){
        List<Period> fiscals = OPMetricsController.getFiscalYears();
        System.assert(!fiscals.isEmpty());
    }
    
    @isTest
    static void testgetHeatMap(){
        List<Account> accs = [SELECT Id from Account];
        System.assertNotEquals(null, OPMetricsController.getChartData(accs[0].Id, System.now().Year()));
    }
}
