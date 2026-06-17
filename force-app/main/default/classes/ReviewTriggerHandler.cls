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

        ReviewTriggerService.updateCarAverageRating(lowReviews);
        
    }

    override public void afterUpdate(){

    }
}