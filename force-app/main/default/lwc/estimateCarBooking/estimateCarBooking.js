import { LightningElement } from 'lwc';
import { api } from "lwc";

export default class EstimateCarBooking extends LightningElement {
     @api carId;
  get inputVariables() {
    return [
      {
        name: "recordId",
        type: "String",
        value: this.carId
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