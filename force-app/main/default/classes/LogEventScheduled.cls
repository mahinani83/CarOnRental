public with sharing class LogEventScheduled implements Schedulable {
    public LogEventScheduled() {

    }
    // here we need to schedule the batch calss to execut

    public void execute(SchedulableContext sc) {
      
        Database.executeBatch(new LogEventBatchApex(), 200);

    }



    

}


