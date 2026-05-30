
@isTest
public with sharing class PaymentTransactionTriggerHandlerTest {
    public PaymentTransactionTriggerHandlerTest() {

    }
    // // creating data
    @TestSetup
    static void makeData(){
        List<Contact> contactTestData = TestDataFactory.createContacts(2);
        List<Car__c> carTestData = TestDataFactory.createCars(2);
        List<Booking__c> bookingTestData = TestDataFactory.createBookings(2,contactTestData,carTestData);
    }

    @isTest
    static void testBookingAndPaymentStatus(){
        Booking__c testBooking = [select id,status__c,Payment_status__c from Booking__c limit 1];
        // create payment transactin record
        Payment_Transaction__c payment = new Payment_Transaction__c();
        payment.Booking__c = testBooking.Id;
        payment.Amount__c = 100;
        payment.Status__c = Constants.SUCCESS;
        payment.Type__c = Constants.TYPE_INITIAL_PAYMENT;
        payment.Transaction_Date__c = Datetime.now();
        Test.startTest();
            insert payment;
        Test.stopTest();
         String expectedPaymentStatus = Constants.BOOKING_PARTIAL_PAID;
        String expectedBookingStatus = Constants.BOOKING_CONFIRM_STATUS;
         Booking__c updatedBookingRec = [select id,status__c,Payment_status__c from Booking__c where id = :testBooking.id limit 1];
         System.debug('Booking Id: ' + testBooking.Id);
System.debug('Payment Status: ' + updatedBookingRec.Payment_status__c);
System.debug('Booking Status: ' + updatedBookingRec.Status__c);
         Assert.areEqual(expectedPaymentStatus, updatedBookingRec.Payment_status__c, 'Payment status is not updated correctly');
         Assert.areEqual(expectedBookingStatus, updatedBookingRec.status__c, 'Booking status is not updated correctly');


         Payment_Transaction__c partialPayment = new Payment_Transaction__c();
         partialPayment.Booking__c = updatedBookingRec.id;
          partialPayment.Amount__c = 100;
        partialPayment.Status__c = Constants.SUCCESS;
        partialPayment.Type__c = Constants.TYPE_PARTIAL_PAYMENT;
        partialPayment.Transaction_Date__c = Datetime.now();

         //Security Deposit Payment
        Payment_Transaction__c securityPayment = new Payment_Transaction__c();
        securityPayment.Booking__c = updatedBookingRec.id;
        securityPayment.Amount__c = 40;
        securityPayment.Status__c = Constants.SUCCESS;
        securityPayment.Type__c = Constants.TYPE_SECURITY_DEPOSIT;
        securityPayment.Transaction_Date__c = Datetime.now();

         //store the transactions in collection.
         List<Payment_Transaction__c> transactionCollection = new List<Payment_Transaction__c>();
         transactionCollection.add(partialPayment);
         transactionCollection.add(securityPayment);

         insert transactionCollection;
        
        Booking__c updatedBookingAfterFullPayment = [select id,status__c,Payment_status__c from Booking__c where id = :updatedBookingRec.id limit 1];

        expectedPaymentStatus = Constants.BOOKING_PAID;
        Assert.areEqual(expectedPaymentStatus, updatedBookingAfterFullPayment.Payment_status__c, 'Payment status is not updated correctly');


         List<Payment_Transaction__c> securityTran = [select id from Payment_Transaction__c where Type__c = :Constants.TYPE_SECURITY_DEPOSIT limit 1];
        delete securityTran;
        
        expectedPaymentStatus = Constants.BOOKING_PARTIAL_PAID;
        Booking__c updatedBookingAfterDeletion = [select id,status__c,Payment_status__c from Booking__c where id = :updatedBookingRec.id limit 1];
        Assert.areEqual(expectedPaymentStatus, updatedBookingAfterDeletion.Payment_status__c, 'Payment status is not updated correctly');

         
    }


    
}