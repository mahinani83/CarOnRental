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

    }

    @isTest
    public static void testInsertReview(){
        List<Contact> testContacts = [SELECT ID FROM CONTACT LIMIT 1];
        List<Booking__c> testBookings = [SELECT ID FROM BOOKING__C LIMIT 1];
        List<Review__c> reviews = TestDataFactory.createReviews(1,testContacts,testBookings,2);
        List<Car__c> testCars = [SELECT ID FROM Car__c LIMIT 1];
        // testing sharing recor of review record
        Group customerSupportGroup = [select id from group where developerName = :Constants.CUSTOMER_SUPPORT_PUBLIC_GROUP];
        List<Booking__share> bookingShares = [select id from Booking__Share where parentId = :testBookings[0].Id and userOrGroupId = :customerSupportGroup.Id and RowCause = :Schema.Booking__share.RowCause.Manual];

        System.debug('booking shared records created ' + bookingShares);
        
        // geting review and review Id 
        // Set<Id> reviewIds = new Set<Id>();
        // List<Review__c> reviews = [SELECT ID FROM REVIEW__C];





        List<Case> newCases = [SELECT ID FROM CASE 
            WHERE Review_ID__c = :reviews[0].id];
        // tesing case creation

        System.Assert.areEqual(1,newCases.size(),'Error While Creating Case');


        // Case 

        System.Assert.areEqual(1, bookingShares.size(), 'Error While Creating Sharing Record');

        // testing average rating assignement 
        // System.Assert.areEqual(8, testCar.Rating__c, 'Failed to update the average rating');
    }
    @isTest
    public static void testUpdateReviewTriggerHandlerForNegativeRating(){
        // approach 
        // create a review record with more then average rating required
        // update review record with below average arating 
        // after update records check whether check whether the share record is created or not 
        List<Contact> contacts = [SELECT id from Contact];
        List<Booking__c> bookings = [SELECT id from Booking__c];

        List<Review__c> reviews = TestDataFactory.createReviews(1,contacts,bookings,8);
//  TestDataFactory.updateReviewRating(reviews,2);
        System.debug('before update' + reviews);
        TestDataFactory.updateReviewRating(reviews,2);
        System.debug('after update' + reviews);
        update reviews;

        Group customerSupportGroup = [select id from group where developerName = :Constants.CUSTOMER_SUPPORT_PUBLIC_GROUP];
        List<Booking__share> bookingShares = [select id from Booking__Share where parentId = :bookings[0].Id and userOrGroupId = :customerSupportGroup.Id and RowCause = :Schema.Booking__share.RowCause.Manual];

        List<Case> newCases = [SELECT ID FROM CASE 
            WHERE Review_ID__c = :reviews[0].id];

        System.Assert.areEqual(1,newCases.size(),'Error While Creating Case');
        System.Assert.areEqual(1, bookingShares.size(), 'Error While Creating Sharing Record');


        // testing that it is creating the share record 
    }

    // testInsertAverageRating
    @isTest
    public static void testInsertAverageRating(){
        // create a review record
        // calculate the average rating of the car 
        // systemassert with the expected and current value
        List<Contact> contacts = [SELECT ID FROM CONTACT];
        List<Car__c> cars = [SELECT ID FROM CAR__C];
        List<Booking__c> bookings = [SELECT ID FROM BOOKING__C];
        Car__c carBeforeInsert = [SELECT ID , AVERAGE_RATING__C FROM CAR__C WHERE ID = :cars[0].Id];
        System.debug('carBefreInsert ' + carBeforeInsert);

        List<Review__c> firstReview = TestDataFactory.createReviews(1,contacts,bookings,6);
        List<Review__c> secondReview = TestDataFactory.createReviews(1,contacts,bookings,2);
        Integer expectedAvgRating = 4;

        Car__c car = [SELECT ID , AVERAGE_RATING__C FROM CAR__C WHERE ID = :cars[0].Id];
        System.debug('car average raing after insert' + car);

        System.Assert.areEqual(expectedAvgRating,car.average_rating__c,'Error While Creating Case');
    }
    // testUpdateAverageRating
    @isTest
    public static void testUpdateAverageRating(){
        // create review record and update the review record
        // and check the average rating the car
         List<Contact> contacts = [SELECT ID FROM CONTACT];
        List<Car__c> cars = [SELECT ID FROM CAR__C];
        List<Booking__c> bookings = [SELECT ID FROM BOOKING__C];
        Car__c carBeforeInsert = [SELECT ID , AVERAGE_RATING__C FROM CAR__C WHERE ID = :cars[0].Id];
        System.debug('carBefreInsert ' + carBeforeInsert);

        List<Review__c> firstReviews = TestDataFactory.createReviews(1,contacts,bookings,6);
        List<Review__c> secondReviews = TestDataFactory.createReviews(1,contacts,bookings,8);

        Review__c firstReview = firstReviews[0];
        Review__c secondReview = secondReviews[0];


        // updating 
        firstReview.Rating__c = 2;
        secondReview.Rating__c = 1;

        List<Review__c> updateReviews = new List<Review__c>();

        updateReviews.add(firstReview);
        updateReviews.add(secondReview);
        System.debug('before update updating' + updateReviews);


        update updateReviews;

        Car__c car = [SELECT ID,AVERAGE_RATING__C FROM CAR__C WHERE ID = :cars[0].Id LIMIT 1];


        double expectedRating = 2;

        System.Assert.areEqual(expectedRating,car.average_rating__c,'Error While updating the caraverage rating for update case');


    }
    // testDeleteAverageRating

    @isTest
    public static void testDeleteAverageRating(){
        // create a review record
        // delete the review record
        // check the expected and result values
        List<Contact> contacts = [SELECT ID FROM CONTACT];
        List<Car__c> cars = [SELECT ID FROM CAR__C];
        List<Booking__c> bookings = [SELECT ID FROM BOOKING__C];

        List<Review__c> firstReviews = TestDataFactory.createReviews(1,contacts,bookings,6);
        List<Review__c> secondReviews = TestDataFactory.createReviews(1,contacts,bookings,8);
        List<Review__c> thirdReviews = TestDataFactory.createReviews(1,contacts,bookings,4);

        Review__c firstReview = firstReviews[0];
        delete secondReviews;

        Car__c car = [SELECT ID,AVERAGE_RATING__C FROM CAR__C WHERE ID = :cars[0].Id];
        Integer actualResult = (car.Average_Rating__c).intValue();
        System.assertEquals(5,actualResult, 'something went wrong while updating the average rating while deleting the review');
    }
}