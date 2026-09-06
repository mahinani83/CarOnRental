public with sharing class CarReviewController {
    public CarReviewController() {

    }
    @AuraEnabled(cacheable=true)
    public static ReviewWrapper getCarReview(Id carId){
        List<Review__c> reviews = [SELECT Id, Rating__c, Comments__c, CreatedDate, Booking__r.Car__c FROM Review__c 
                                    Where Booking__r.Car__c = :carId];

        // ratingDestribution
        Map<Integer,Integer> ratingDestribution = new Map<Integer,Integer>();
        for(Review__c review : reviews){
            if(ratingDestribution.containsKey((Integer) review.Rating__c)){
                ratingDestribution.put((Integer) review.Rating__c,ratingDestribution.get((Integer) review.Rating__c) + 1);
            }else {
                ratingDestribution.put((Integer) review.Rating__c,1);
            }
        }

        Decimal averageRating = 0;
        Car__c car = [SELECT Average_Rating__c FROM Car__c Where Id = :carId];
        if(car.Average_Rating__c != null )
            averageRating = car.Average_Rating__c;

        Integer totalReviews = reviews.size();
        ReviewWrapper rw = new ReviewWrapper(
            reviews,
            ratingDestribution,
            averageRating,
            totalReviews
        );

        System.debug('debuging the data' + rw);

        return rw;

    }

    public class ReviewWrapper{
        // reviews , ratingDestribution, averageRating,totalReviews
        @AuraEnabled
        public List<Review__c> reviews;
        @AuraEnabled
        public Map<Integer,Integer> ratingDestribution;
        @AuraEnabled
        public Decimal averageRating;
        @AuraEnabled
        public Integer totalReviews;

        public ReviewWrapper(
            List<Review__c> reviews,
            Map<Integer,Integer> ratingDestribution,
            Decimal averageRating,
            Integer totalReviews
        ){
            this.reviews = reviews;
            this.ratingDestribution = ratingDestribution;
            this.averageRating = averageRating;
            this.totalReviews = totalReviews;
        }

    }

}

