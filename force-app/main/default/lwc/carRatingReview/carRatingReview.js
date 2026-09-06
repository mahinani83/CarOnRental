import { LightningElement,api,wire } from 'lwc';
import getCarReview from "@salesforce/apex/CarReviewController.getCarReview";
export default class CarRatingReview extends LightningElement { 
    //get the reviews 
    // write a wirehandler that class
    // write a date farmater
    // logic for getting distributed data
    @api recordId;
    reviews = [];
    averageRating = 0;
    totalReviews = 0;
    ratingDistribution = {};
    error;
    hasData = false;

    @wire(getCarReview,
        {carId:"$recordId"}
    )
    getCarReviewHandler({data,error}){
        if(data != null){
            console.log("insdie of if  getCarReviewHandler");
            this.averageRating = data.averageRating;
            this.totalReviews = data.totalReviews;
            this.ratingDestribution = data.ratingDestribution;
            this.reviews = data.reviews;
            this.processReviews();
            this.hasData = true;
        }else{
            console.log("inside of else");
            this.error = error;
            this.reviews = undefined;
        }
    }

    processReviews(){
        this.reviews = this.reviews.map(review =>{
            return {
                ...review,
                CreatedFormatted : this.formateDate(review.CreatedDate)
            };
        })
    }

    formateDate(dateString){
        const date  = new Date(dateString);
        return date.toLocaleDateString("en-US",{
            year: "numeric",
            month: "long",
            day : "numeric"
        })
    }

    get ratingDistributionList() {
    const distribution = [];
    for (let i = 8; i >= 1; i--) {
      //let 3 customer have provided 5 rating
      //let 2 customer have provided 8 rating
      if(this.ratingDistribution[i] == null) continue;

      //3 customers / 5 customers = 60%
      //2 customers / 5 customers = 40%
      const count = this.ratingDistribution[i];
      const totalReview = this.totalReviews;
      let fixedPercentage;
      if (totalReview > 0) {
        const percentage = (count / totalReview) * 100;
        fixedPercentage = percentage.toFixed(2);
      } else {
        fixedPercentage = 0;
      }

      let ratingDistributionObj = {
        rating: i,
        count: count,
        percentage: fixedPercentage
      };
      distribution.push(ratingDistributionObj);
    }
    return distribution;
  }



}