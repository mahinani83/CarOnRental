public with sharing class CarImageController {

    @AuraEnabled(cacheable = true)
    public static List<Car_Image__c> getCarImages(Id carId){
        try{
            List<Car_Image__c> imageResult = [
                SELECT Id,Primary_Image__c,Image_Url__c,Car__r.Name FROM Car_Image__c 
                WHERE Car__c = : carId
                WITH USER_MODE
        ];
        return imageResult;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
       
    }

    @AuraEnabled
    public static void createFile(
        String documentId,
        String recordId,
        Boolean isPrimaryImage
    ){

        if(isPrimaryImage == false){
            List<Car_Image__c> imageResult = [
                SELECT Id FROM Car_Image__c 
                WHERE Car__c = :recordId AND Primary_Image__c = true
                WITH USER_MODE
            ];
            if(imageResult.size() == 0){
                 throw new AuraHandledException(
        'Please upload at least one primary image first.'
    );
            } 
        }
        List<ContentVersion> contentVersion = [
            SELECT Id,ContentDocumentId from ContentVersion
            where IsLatest = true and ContentDocumentId = :documentId
            order by CreatedDate desc limit 1
        ];

        if(contentVersion.isEmpty()){
            throw new AuraHandledException('Content version not found for content document id ' + isPrimaryImage);
        }

        Car_Image__c carImage = new Car_Image__c(
            Car__c = recordId,
            Image_Url__c = Constants.IMAGE_PATH_HELPER + contentVersion[0].Id   
        );

        if(isPrimaryImage){
            CarImage.Primary_Image__c = true;
        }
        try{
            insert CarImage;
        } catch(Exception ex){
            System.debug(ex.getMessage());
            Log logger = Log.get();
            logger.publish(ex.getMessage());
        }
    }

}