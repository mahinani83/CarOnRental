@isTest
public with sharing class ReviewTriggerTest {
   
    // insert scenario test
        // 1.create review record 
        // 2.check whether it is assigned to public group 
        // 3.check whether average rating updated or not 
    // update scenario test
        // check whether it average rating updated or not
    // delete scenario test
        // check whether it average rating updated or not

    @testSetUp
    public static void createData(){
        List<Contact> contacts = TestDataFactory.createContacts(1);
        List<Car__c> cars = TestDataFactory.createCars(1);
        List<Booking__c> bookings = TestDataFactory.createBookings(1,contacts,cars);
        List<Review__c> reviews = TestDataFactory(1,contacts,bookings,8);

    }

    @isTest
    public static void testInsertReview(){
        Contact testContact = [SELECT ID FROM CONTACT LIMIT 1];
        Booking__c testBooking = [SELECT ID FROM BOOKING__C LIMIT 1];
        Car__c testCar = [SELECT ID FROM Car__c LIMIT 1];
        // testing sharing recor of review record
        Group customerSupportGroup = [select id from group where developerName = :Constants.CUSTOMER_SUPPORT_PUBLIC_GROUP];
        List<Booking__share> bookingShares = [select id from Booking__Share where parentId = :testBooking.Id and userOrGroupId = :customerSupportGroup.Id and RowCause = :Schema.Booking__share.RowCause.Manual];

        System.Assert.areEqual(1, bookingShares.size(), 'Error While Creating Sharing Record');

        // testing average rating assignement 
        System.Assert.areEqual(8, testCar.Rating__c, 'Failed to update the average rating');
    }


}