public with sharing class ReviewTriggerHandler extends TriggerHandler {
    public ReviewTriggerHandler() {

    }

    override public void afterInsert(){
        List<Review__c> lowReviews = new List<Review__c>();
        List<Review__c> reviews = (List<Review__c>) trigger.new;
        for(Review__c review : reviews){
            if(review.Rating__c < Constants.LOW_RATING_THRESHOLD ){
                lowReviews.add(review);
                System.debug('id debug ' + review.Id);
            }
        }
        if(lowReviews.size() > 0) ReviewTriggerService.shareLowRatingAndCreateCase(reviews);
        ReviewTriggerService.updateCarAverageRating(reviews);
    }

    override public void afterUpdate(){

        List<Review__c> newReviews = (List<Review__c>)Trigger.new;
        Map<Id,Review__c> oldReviews = (Map<Id,Review__c>)Trigger.oldMap;
        List<Review__c> lowReviews = new List<Review__c>();
        List<Review__c> reviewsToUpdate = new List<Review__c>();

        for(Review__c review : newReviews){
            Decimal newRating = review.Rating__c;
            Decimal oldRating = (oldReviews.get(review.Id)).Rating__c;

            // filtering lowRating Reviews 
            if(newRating != oldRating && newRating < Constants.LOW_RATING_THRESHOLD ) lowReviews.add(review);
            if(newRating != oldRating) reviewsToUpdate.add(review);

            if(lowReviews.size() > 0) ReviewTriggerService.shareLowRatingAndCreateCase(lowReviews);
            if(reviewsToUpdate.size() > 0) ReviewTriggerService.updateCarAverageRating(reviewsToUpdate);

        }

    }


    override public void afterDelete(){
        List<Review__c> reviews = (List<Review__c>)Trigger.old;
        ReviewTriggerService.updateCarAverageRating(reviews);
    }
}