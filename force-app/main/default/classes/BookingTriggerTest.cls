@isTest
public with sharing class BookingTriggerTest {
    
    @TestSetup
    static void makeData(){
        List<Car__c> cars = TestDataFactory.createCars(2);
        List<Contact> contacts = TestDataFactory.createContacts(2);
    }
    
    @isTest
    static void testTotalPaymentFoCar(){
        Car__c testCar = [select id,Name from Car__c limit  1];
        Contact con = [Select id from Contact limit 1];

        Booking__c newBooking  = new Booking__c();
        newBooking.Customer__c = con.Id;
        newBooking.car__c = testCar.Id;
        newBooking.Start_date_time__c = datetime.now().addDays(1);
        newBooking.End_date_time__c = datetime.now().addDays(3);
        newBooking.Status__c = Constants.BOOKING_PENDING_STATUS;
        newBooking.payment_status__c = Constants.BOOKING_PAYMENT_PENDING;
        newBooking.Final_Booking_Price__c = 200;

        insert newBooking;
        System_thredshould__mdt securityDepositThr = System_thredshould__mdt.getInstance(Constants.SECURITY_DEPOSIT_THRESHOLD);
        Decimal sercurityDepositeDecimalVal =  Decimal.valueOf(securityDepositThr.value__c)/100;
        Decimal securityDepositVal = sercurityDepositeDecimalVal * newBooking.Final_Booking_Price__c;

        Payment_Transaction__c securityPayment = new Payment_Transaction__c(Booking__c = newBooking.Id, Amount__c = securityDepositVal,
                                                                            Status__c = Constants.SUCCESS, Type__c = Constants.TYPE_SECURITY_DEPOSIT,
                                                                            Transaction_Date__c = datetime.now()
                                                                            );

        //create payment - rental payment
        Payment_Transaction__c rentalPayment = new Payment_Transaction__c(Booking__c = newBooking.Id, Amount__c = newBooking.Final_Booking_Price__c,
                                                                          Status__c = Constants.SUCCESS, Type__c = Constants.TYPE_INITIAL_PAYMENT,
                                                                          Transaction_Date__c = datetime.now());


        List<Payment_Transaction__c> payments = new List<Payment_Transaction__c>{securityPayment, rentalPayment};
        insert payments;
        Set<Id> carIds = new Set<Id>{
    'a02gL00000JMFFCQA9'
};

        Test.startTest();
            newBooking.Status__c = Constants.BOOKING_CLOSED_STATUS;
            update newBooking;
        // System.enqueueJob(new BookingQueableJob(carIds));
        Test.stopTest();

        Car__c testingCar = [select Id,Name,Total_Bookings_Value__c from Car__c where Id = :testCar.Id];

        Decimal expectedVal = newBooking.Final_Booking_Price__c;
        Decimal resultVal = testingCar.Total_Bookings_Value__c;
        



        System.Assert.areEqual(expectedVal, resultVal, 'Car Booking value is not updated');

        

        

    }
}