import { LightningElement,api } from 'lwc';

export default class CarTiles extends LightningElement {
    __car;
    pictureUrl;
    name;
    rentalRate;
    transmissionType;
    fuelType;
    numberOfSeats;
    averageRating = 0;
    constructor() {
        super();
        console.log('CarTiles component initialized');
    }

    @api
    get car() {
        return this.__car;
    }

    set car(value){
        console.log("valu ein car tile ",value);
        this.__car = value;
        this.pictureUrl = value.Primary_Image_Url__c;
        console.log("icture url " , this.pictureUrl);
        this.name = value.name;
        this.rentalRate = value.Rental_Rate_Per_Day__c;
        this.transmissionType = `Transmission: ${value.Transmission_Type__c}`;
        this.fuelType = `Fuel Type: ${value.Fuel_Type__c}`;
        this.numberOfSeats = value.Number_of_Seats__c;
        this.averageRating = value.Average_Rating__c || 0;
    }


    handleEstimateBookingClick(){
        const estimateBooking = new CustomEvent("estimatebooking",{
            detail: this.car.Id
        });
        this.dispatchEvent(estimateBooking);
    }

    handleBookNowClick(){
        const bookNow = new CustomEvent("booknow",{
            detail: this.car.Id
        });
        this.dispachEvent(bookNow);
    }

    
}