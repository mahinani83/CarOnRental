@RestResource(urlMapping='/v1/car/available/*')
global with sharing class CarAvailabilityCheckApi {
    public CarAvailabilityCheckApi() {

    }

    // approacch 
    // get the filter variables --> start,end date,location,fuel type and transmissiontype
    // get the car records by appliing those filters
    // create a response object class
    // create list resposnselistclass for cars records for main data
    // fields need , id, name, rentalRate,ImageUrl,transmissionType,fuelTpe , family, description,location

    @HttpGet
    global static responseWrapper getAvailableCars() {
        RestRequest req = RestContext.request;
        String startDateStr = req.params.get('startdate');
        String endDateStr = req.params.get('enddate');
        String location = req.params.get('location');
        String transmissionType = req.params.get('transmissiontype');
        String fuelType = req.params.get('fuelType');

        // to store the response data
        List<CarResponseWrapper> carData = new List<CarResponseWrapper>();

        if(startDateStr == null || endDateStr == null || location == null){
            return new responseWrapper('please provid date start date,end date,location',504,null);
        }
        Date startDate = Date.valueOf(startDateStr);
        Date endDate = Date.valueOf(endDateStr);

        Datetime startDateTime = Datetime.newInstance(
            startDate,
            Time.newInstance(0, 0, 0, 0)
        );

        Datetime endDateTime = Datetime.newInstance(
            endDate,
            Time.newInstance(23, 59, 59, 999)
        );


        String query = 'SELECT Id, Name, Rental_Rate_Per_Day__c, Primary_Image_Url__c, Transmission_Type__c, Fuel_Type__c, Car_Family__c, Car_Description__c, PickupLocation__c FROM Car__c WHERE PickupLocation__c= :location';
        if(transmissionType != null) query = query + ' AND Transmission_Type__c = :transmissionType';
        if(fuelType != null) query = query + ' AND Fuel_Type__c = :fuelType';
        // need car that does not have the booking in the date ranges
        List<Car__c> cars = Database.query(query);
        
        for(Car__c car : cars){
            List<Booking__c> bookings = [SELECT ID FROM BOOKING__C WHERE Start_Date_Time__c = :startDateTime AND End_Date_Time__c = :endDateTime ];
            if(bookings.size() == 0) carData.add(new CarResponseWrapper(car));
        }

        // check is there any car exist for that filter
        if(carData.size() < 0 ){
            return new responseWrapper('Error',404,null);
        }

        return new responseWrapper('Success',200,carData);

    }
    global class responseWrapper{
    String message;
    Integer responseCode;
    List<carResponseWrapper> cars;
    responseWrapper(String message,Integer responseCode , List<carResponseWrapper> cars){
        this.message = message;
        this.responseCode = responseCode;
        this.cars = cars;
    }

}

global class CarResponseWrapper{
    String id;
    String name;
    Decimal rentalRate;
    String imageUrl;
    String transmissionType;
    String fuelType;
    String carFamily;
    String description;
    String location;
    carResponseWrapper(Car__c car){
        this.id = car.id;
        this.name = car.name;
        this.rentalRate = car.Rental_Rate_Per_Day__c;
        this.imageUrl = car.Primary_Image_Url__c;
        this.transmissionType = car.Transmission_Type__c;
        this.fuelType = car.Fuel_Type__c;
        this.carFamily = car.Car_Family__c;
        this.description = car.Car_Description__c;
        this.location = car.PickupLocation__c;
    }
}

}

