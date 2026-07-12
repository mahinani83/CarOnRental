public with sharing class LogEventBatchApex  implements Database.Batchable<SObject>{
    private Integer successCount = 0;
    private Integer failureCount = 0;
    // private String notificationEmail = '';
    public LogEventBatchApex() {
    }

    // ---- aproach ------------
    // 1. get all the logevent that are before seven days
    // 2. delete them and count the successfull and unsucessfull delete
    // 3. send email with details notes of successfull and unsuccessfull notes
    public Database.QueryLocator start(Database.BatchableContext bc) {
         Date cutoffDate = Date.today().addDays(-Constants.ALLOWED_DAYS_LOGS);
String query =
        'SELECT Id, Name FROM LogEvent__c WHERE CreatedDate < :cutoffDate';
        return Database.getQueryLocator(query);
    }
     public void execute(Database.BatchableContext bc, List<LogEvent__c> logEventsToDelete) {
        // deleting the logevent srecords
        List<DataBase.DeleteResult> deletedRecords = Database.delete(logEventsToDelete,false);
        for(Database.DeleteResult deleteRecord : deletedRecords){
            if(deleteRecord.isSuccess()) this.successCount += 1;
        }
        this.failureCount = deletedRecords.size() - this.successCount;

    }

     public void finish(Database.BatchableContext bc){
        // sending the data
        System_thredshould__mdt toEmails  = System_thredshould__mdt.getInstance(Constants.TO_EMAIL_METADATA_API);
        System.debug('to email frm the cmd ' + toEmails);
        
        // spliting the email by , to find the to address
        String[] toAddress =  new String[] {toEmails.value__c};

        String subject = 'LogCleanupBatch Complete - ' + datetime.now().format('MM dd, yyyy');
        String body = 'Log Cleanup Batch Job Completed\n\n' +
                      'Records processed : ' + (this.successCount + this.failureCount) + '\n' +
                      'Record Deleted Successfully :' + this.successCount + '\n' +
                      'Record Deletion Failed : ' + this.failureCount + '\n' +
                      'This is an automated recport from the Car on Rental System';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Assign the addresses for the To to the mail object.
        mail.setToAddresses(toAddress);

        // Specify the name used as the display name.
        mail.setSenderDisplayName('Car On Rental');

        mail.setSubject(subject);

        mail.setPlainTextBody(body);

        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }


}