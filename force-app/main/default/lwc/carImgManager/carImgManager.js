import { LightningElement,api,wire } from 'lwc';
import getCarImages from '@salesforce/apex/CarImageController.getCarImages';
import createFile from '@salesforce/apex/CarImageController.createFile';
import {refreshApex} from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
export default class CarImgManager extends LightningElement {
    @api recordId;

    isPrimaryChecked = false;
    hideUploadSection = false;
    @wire(getCarImages,{
        carId: "$recordId"
    })
    carImages;


    connectedCallback(){
        console.log('car imaes values ', JSON.stringify(this.carImages));
    }


get hasProductImages() {
    return this.carImages?.data?.length > 0;
}
    handlePrimaryImage(event){
        this.isPrimaryChecked = event.target.checked;
    }


    get showUploadSection(){
        return !this.hideUploadSection;
    }

    async handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        const carFile = uploadedFiles[0];

        let documentId = carFile.documentId;

        try{
            await createFile({
                    documentId: documentId,
                    recordId : this.recordId,
                    isPrimaryImage: this.isPrimaryChecked
                }   
            )
            .then(() => {
                this.showToast("Success", "Image Uploaded successfully","success");
                console.log('Image uploaded successfully');
            })
            .catch(error => {
                console.error('Error:', JSON.stringify(error));

                const message = error?.body?.message || 'Something went wrong';

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Upload Failed',
                        message: message,
                        variant: 'error'
                    })
                );
            });
            await refreshApex(this.carImages);
            await notifyRecordUpdateAvailable([{recordId : this.recordId}])
        } catch(error){
            this.showToast("Error","Image failed to upload","error");
        }
    }



    showToast(title,message,variant){
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        })

        this.dispatchEvent(event);

    }




}