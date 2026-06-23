public with sharing class ReviewTriggerService {
   

    public static void shareLowRatingAndCreateCase(List<Review__c> lowReviews){
        Group customerSupportGroup = [select id from group where developerName = :Constants.CUSTOMER_SUPPORT_PUBLIC_GROUP];

        Set<id> bookingIds = new Set<Id>();

        for(Review__c review : lowReviews){
            if(review.booking__c != null){
                bookingIds.add(review.booking__c);
            }
        }

        // get all the bookingshared records which share witht eh group 
        List<Booking__share> bookingShares = [select id from Booking__Share where parentId in :bookingIds and userOrGroupId = :customerSupportGroup.Id and RowCause = :Schema.Booking__share.RowCause.Manual];

        set<Id> alreadySharedBookingIds = new set<Id>();

        for(Booking__share  shareRecord : bookingShares) {
            alreadySharedBookingIds.add(shareRecord.parentId);
        }

        List<Booking__share> bsrToInsert = new List<Booking__share>();

        for(Id bookingId : bookingIds){
            if(!alreadySharedBookingIds.contains(bookingId)){
                Booking__share bookingShare = new Booking__share();
                bookingShare.parentId = bookingId;
                bookingShare.userOrGroupId = customerSupportGroup.Id;
                bookingShare.RowCause = Schema.Booking__share.RowCause.Manual;
                bsrToInsert.add(bookingShare);
            }   
        }

        try{
            if(bsrToInsert.size() > 0) insert bsrToInsert;
        }catch(Exception ex){
            system.debug(ex.getMessage());
            Log logger = Log.get();
            logger.publish(ex.getMessage());
        }

    }


    public static void createCaseRecord(List<Review__c> reviews){
        Set<Id> reviewIds = getReviewIds(reviews);

        // get record type 
        Id recordTypeId = Schema.SObjectType.Case
        .getRecordTypeInfosByDeveloperName()
        .get(Constants.NEGATIVE_REVIEW_RECORD_TYPE)
        .getRecordTypeId();

        System.debug('record type had' + recordTypeId);
      // get existing case records 
      List<Case> existingCaseRecords = [
        Select Id, Review_ID__c from Case 
        Where recordTypeId = :recordTypeId and
        type = :Constants.NEGATIVE_REVIEW_CASE_TYPE and
        Review_ID__c in :reviewIds
        ];

    System.debug('existing record got ' + existingCaseRecords);

    Set<Id> existingCaseReviewRecordIds = new Set<Id>();

    for(Case caseRecord : existingCaseRecords){
        existingCaseReviewRecordIds.add(caseRecord.Review_ID__c);
    }

    List<Case> caseToAdd = new List<Case>();

    // Creating new Case for review how has not having case records
    for(Review__c review : reviews){
        if(!existingCaseReviewRecordIds.contains(review.Id)){
            Case newCase = new Case();
            newCase.Review_ID__c = review.Id;
            newCase.RecordTypeId = recordTypeId;
            newCase.Type = Constants.NEGATIVE_REVIEW_CASE_TYPE;
            newCase.Priority = Constants.CASE_PRIORITY_MEDIUM;
            newCase.Related_Booking__c = review.Booking__c;
            newCase.ContactId = review.Customer__c;
            newCase.Related_Car__c = review.Booking__r.Car__c;
            newCase.Subject = 'Low Rating Review : ' + review.Rating__c + ' Stars';
            newCase.Description = 'Review Comments ' + review.Comments__c;
            caseToAdd.add(newCase);
        }
    }
    

        try{
        if(caseToAdd.size() > 0){
            System.debug('inserting cases');
            insert caseToAdd;
        }
        }catch(Exception ex){
            //log error to the apex logs
            system.debug(ex.getMessage());
            Log logger = Log.get();
            logger.publish(ex.getMessage());
        }
   
    }

    public static void updateCarAverageRating(List<Review__c> reviews){
        // approach 
        // 1. get average rating of eeach car 
        // 2. update the average rating of with the that average rating 

        Set<Id> bookingIds = getBookingIds(reviews);
        System.debug('bookingids i got ' + bookingIds);
        set<Id> carIds = new Set<Id>();
        List<Car__c> carList = new List<Car__c>();




        // get booking records with id 
        Map<Id,booking__c> bookingsMap = new Map<Id,booking__c>([SELECT Id, Car__c from Booking__c where id in :bookingIds]);
        Map<Id,Id> carIdreviewidMap = getCarReviewIds(reviews,bookingsMap,carIds);
        System.debug('carIds i go tin update car average rating ' + carIds);
        Map<Id,Decimal> carAverageRatingMap = new Map<Id,Decimal>();

        // get average rating of each car and updating it to the car rating 
        for(AggregateResult agr : [select Booking__r.Car__c carId, avg(Rating__c) avgRating from review__c 
                               where Booking__r.Car__c in :carIds group by Booking__r.Car__c]){ 
                                Id carId = (Id) agr.get('carId');
                                Decimal averageRating = (Decimal) agr.get('avgRating');
                                System.debug('average Rating valuein inside of loop ' + averageRating);
                                carAverageRatingMap.put(carId,averageRating.round(System.RoundingMode.HALF_UP));
        }


    



        System.debug('carIds debug before for loop' + carIds);

        for(Id carId : carIds){
            System.debug('debug login inside of for loop ' + carId);
            Car__c car = new Car__c(Id = carId);
            if(carAverageRatingMap.containsKey(carId)) car.Average_Rating__c = carAverageRatingMap.get(carId);
            else car.Average_Rating__c = null;
            carList.add(car);
        }

        if(!carList.isEmpty()){
            try{
                update carList;
            }catch(Exception ex){
                //log error to the apex logs
                system.debug(ex.getMessage());
                Log logger = Log.get();
                logger.publish(ex.getMessage());
            }
        }




    }
    // ---- helper methods -----------------------

    public static Map<Id,Id> getCarReviewIds(List<Review__c> reviews,Map<Id,Booking__c> bookingMap,Set<Id> carIds){
        Map<Id,Id> reviewCarIdMap = new Map<Id,Id>();
        for(Review__c review : reviews){
            if( review.Booking__c != null && bookingMap.containsKey(review.Booking__c)){
                System.debug('inside of for loop for car__c ' + review.Booking__r.Car__c);
                carIds.add(bookingMap.get(review.Booking__c).Car__c);
                reviewCarIdMap.put(review.Id,review.Booking__r.car__c);
            }
        }
        return reviewCarIdMap;
    }


    public static Set<Id> getReviewIds(List<Review__c> reviews){
        Set<Id> reviewIds = new Set<Id>();
        for(Review__c review : reviews){
            reviewIds.add(review.Id);
        }
        return reviewIds;
    }

    public static Set<Id> getBookingIds(List<Review__c> reviews){
        Set<Id> bookingIds = new Set<Id>();
          for(Review__c review : reviews){
            bookingIds.add(review.Booking__c);
        }

        return bookingIds;
    }

   
}