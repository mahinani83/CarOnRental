@isTest
public with sharing class LogEventBatchApexTest {
    public LogEventBatchApexTest() {

    }
    // ---- aproach ------------
    // 1. create 
    @isTest
    static void testDeleteOldLogs() {

        List<LogEvent__c> logs = new List<LogEvent__c>();

        for(Integer i = 0; i < 5; i++){
            logs.add(new LogEvent__c(
                 Log_Data__c = 'Old test log ' + i,
                Quiddity__c = 'Test Quiddity',
                Request_Id__c = 'TestRequest' + i
            ));
        }

        insert logs;

        // Make them 8 days old
        for(LogEvent__c log : logs){
            Test.setCreatedDate(log.Id, System.now().addDays(-8));
        }

        Test.startTest();

        Database.executeBatch(new LogEventBatchApex(), 200);

        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT Count() FROM LogEvent__c]
        );
    }
}