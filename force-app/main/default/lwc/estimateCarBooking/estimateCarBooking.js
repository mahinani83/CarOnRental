import LightningModal from 'lightning/modal';
import { api } from "lwc";


export default class EstimateCarBooking extends LightningModal {
     @api carId;  
     @api startDate;
     @api endDate;


  get inputVariables() {
    console.log("start date , end date and carId" , this.startDate , this.endDate , this.carId);
    return [
      {
        name: "recordId",
        type: "String",
        value: this.carId
      },
      {
        name: "Start_Date_Updated",
        type: "Date",
        value: this.startDate
      },
      {
        name: "End_Date_Updated",
        type: "Date",
        value: this.endDate
      }
    ];
  }

  handleStatusChange(event) {
    if (event.detail.status === "FINISHED") {
      // set behavior after a finished flow interview
      this.close("Success");
    }
  }
}