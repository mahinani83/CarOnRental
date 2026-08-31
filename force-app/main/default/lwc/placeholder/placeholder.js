import { LightningElement,api } from 'lwc';
import logo from "@salesforce/resourceUrl/Car_Rental_Default_Img";


export default class Placeholder extends LightningElement {
    @api message;
    logoUrl = logo;
}