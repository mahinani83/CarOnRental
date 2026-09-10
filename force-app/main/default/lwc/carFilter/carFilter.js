  import { LightningElement,wire } from 'lwc';
  import {publish,MessageContext} from "lightning/messageService";
  import {getPicklistValues} from "lightning/uiObjectInfoApi";
  import TRANSMISSION_TYPE from "@salesforce/schema/Car__c.Transmission_Type__c";
  import FUEL_TYPE from "@salesforce/schema/Car__c.Fuel_Type__c";
  import PICKUP_LOCATION from "@salesforce/schema/Car__c.PickupLocation__c";
  import recordSelected from "@salesforce/messageChannel/carFilter__c";



  const DELAY = 350;
  export default class CarFilter extends LightningElement {


      // ---- approach ----
      // 1. get the all data
      // 2. publish the filters
      filters = {
      searchKey: "",
      maxSeats: 8,
      startDate: null,
      endDate: null,
      maxRentalRate: 10000,
      minRating: 0,
      pickupLocation: "Delhi",
      transmissionType: [],
      fuelType: []
    };

    transmissionTypeValues = [];
    fuelTypeValues = [];
    pickUpLocationValues = [];

    temp = false;
    delayTimeout;

    @wire(MessageContext)
    messageContext;

    // pickup location, startDate, End Date, MaxSeat , Maxrental Tate , min Rating , transmission Types , Fuel Types
    @wire(getPicklistValues, {
      recordTypeId: "012000000000000AAA",
      fieldApiName: TRANSMISSION_TYPE
    })
    wiredTransmissionTypeValues({ data, error }) {
      if (data) {
        this.transmissionTypeValues = data.values;
        console.log("Transmission Type values loaded", data.values);
      } else if (error) {
        console.error("Error loading transmission types", error);
      }
    }

    @wire(getPicklistValues, {
      recordTypeId: "012000000000000AAA",
      fieldApiName: FUEL_TYPE
    })
    wiredFuelTypeValues({ data, error }) {
      if (data) {
        console.log("log inside of fueltype values ",data);
        this.fuelTypeValues = data.values;
        console.log("Fuel Type values loaded", data.values);
      } else if (error) {
        console.error("Error loading fuel types", error);
      }
    }

    @wire(getPicklistValues, {
      recordTypeId: "012000000000000AAA",
      fieldApiName: PICKUP_LOCATION
    })
    wiredPickUpLocationValues({ data, error }) {
      if (data) {
      
        this.pickUpLocationValues = data.values;
        console.log("Pickup Location values loaded", data.values);
      } else if (error) {
        console.error("Error loading pickup locations", error);
      }
    }

    handleSearchChange(event) {
      this.filters.searchKey = event.target.value;
      this.publishFilter();
    }

    handlePickupLocationChange(event) {
      this.filters.pickupLocation = event.detail.value;
      this.publishFilter();
    }

    handleStartDateChange(event){
    this.filters.startDate = event.detail.value;
  }
  handleEndDateChange(event){
    this.filters.endDate = event.detail.value;
  }
  handleMaxSeatsChange(event){
    this.filters.maxSeats = event.detail.value;
  }
  handleMaxRentalRateChange(event){
    this.filters.maxRentalRate = event.detail.value;
  }

  handleMinRatingChange(event) {
    this.filters.minRating = event.target.value;
    this.publishFilter();
  }


  validateFilters() {
    const startDateInput = this.template.querySelector(".startDateClass");
    const endDateInput = this.template.querySelector(".endDateClass");

    if (!startDateInput || !endDateInput) {
      return true;
    }

    let isValid = true;

    startDateInput.setCustomValidity("");
    endDateInput.setCustomValidity("");

    if (!this.filters.startDate) {
      startDateInput.setCustomValidity("Start date is required");
      isValid = false;
    }

    if (!this.filters.endDate) {
      endDateInput.setCustomValidity("End date is required");
      isValid = false;
    }

    if (this.filters.startDate && this.filters.endDate) {
      if (this.filters.startDate > this.filters.endDate) {
        startDateInput.setCustomValidity("Start date should be less than end date");
        isValid = false;
      }
    }

    startDateInput.reportValidity();
    endDateInput.reportValidity();

    return isValid;
  }

  handleCheckboxChange(event){
    const value = event.target.dataset.value;
    const name = event.target.name;

    if(name == "transmissionType"){
        if (event.target.checked) {
        if (!this.filters.transmissionType.includes(value)) {
          this.filters.transmissionType.push(value);
        }
      } else {
        //keep all the existing values, except the values unchecked by user
        this.filters.transmissionType = this.filters.transmissionType.filter(
          (item) => item !== value
        );
      }
    }

    if (name === "fuelType") {
      if (event.target.checked) {
        if (!this.filters.fuelType.includes(value)) {
          this.filters.fuelType.push(value);
        }
      } else {
        this.filters.fuelType = this.filters.fuelType.filter(
          (item) => item !== value
        );
      }
    }
    this.publishFilter();
    }

  


  publishFilter(){
    if(this.validateFilters()){
        clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(()=>{
            const payload = {
                selCarFilter: {
                        filters : this.filters
                }
            };

            publish(this.messageContext,recordSelected, payload);
            console.log("payload" , payload);
        },DELAY);
    }
  }








  





  
}