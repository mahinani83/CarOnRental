public with sharing class carTileListController {
    public carTileListController() {

    }
    public class Filters {
        @AuraEnabled
        public List<String> fuelType{get;set;}
        @AuraEnabled
        public List<String> transmissionType{get;set;}
        @AuraEnabled
        public String searchKey{get;set;}
        @AuraEnabled
        public Decimal maxSeats {get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public Decimal maxRentalRate{get;set;}
        @AuraEnabled
        public Decimal minRating{get;set;}
        @AuraEnabled
        public String pickupLocation{get;set;}
    }

    // approach 
    // get all the data assign to the instance value 
    // create a dynamic query 
    // get the date and return

    @AuraEnabled(cacheable=true)
    public static List<Car__c> getCars(Filters filters){
        List<String> criteria = new List<String>();
        String searchKey,pickupLocation;
        Decimal maxSeats,maxRentalRate,minRating;
        List<String> fuelType,transmissionType;
        String availableCars = Constants.AVAILABLE_CARS;

        criteria.add('Availability_Status__c = :availableCars');

        if(String.isNotBlank(filters.searchKey)){
            searchKey = '%' + filters.searchKey + '%';
            criteria.add('Name like :searchKey');
        }
        if(String.isNotBlank(filters.pickupLocation)){
            pickupLocation = filters.pickupLocation;
            criteria.add('PickupLocation__c = :pickupLocation');
        }

        if(filters.maxSeats != null){
            maxSeats = filters.maxSeats;
            criteria.add('Number_of_Seats__c <= :maxSeats');
        }
        if(filters.maxRentalRate != null){
            maxRentalRate = filters.maxRentalRate;
            criteria.add('Rental_Rate_Per_Day__c <= :maxRentalRate');
        }
        if(filters.minRating != null){
            minRating = filters.minRating;
            criteria.add('Average_Rating__c >= :minRating');
        }

        if(filters.fuelType != null && !filters.fuelType.isEmpty()){
            fuelType = filters.fuelType;
            criteria.add('Fuel_Type__c IN :fuelType');
        }

        if(filters.transmissionType != null && !filters.transmissionType.isEmpty()){
            transmissionType = filters.transmissionType;
            criteria.add('Transmission_Type__c IN :transmissionType');
        }

        Datetime startDateTime = Datetime.newInstance(filters.startDate,Time.newInstance(0, 0, 0, 0));
        Datetime endDateTime = Datetime.newInstance(filters.endDate, Time.newInstance(23, 59, 59, 0));

        List<Booking__c> bookings = [SELECT Id,Car__c FROM Booking__c WHERE Start_Date_Time__c = :startDateTime AND End_Date_Time__c = :endDateTime];

        Set<Id> carIds = new Set<Id>();
        if(!bookings.isEmpty()){
            for(Booking__c booking : bookings){
                    carIds.add(booking.Car__c);
            }
        }

        if(!carIds.isEmpty()){
            criteria.add('id not in :carIds');
        }


        String queryToGetCars = 'SELECT Id,Average_Rating__c,Availability_Status__c,Car_Description__c,Car_Family__c,Fuel_Type__c,Make__c,Mileage_Limit_Per_Day__c,Model__c,Name,Number_of_Seats__c,PickupLocation__c,Primary_Image_Url__c,Rental_Rate_Per_Day__c,Transmission_Type__c  FROM Car__c';
        String whereClause = ' WHERE ' + String.join(criteria, ' AND ');
        queryToGetCars = queryToGetCars + whereClause + ' order by Name';
        
        System.debug('query to get cars' + queryToGetCars);
        return Database.query(queryToGetCars);

    }



}