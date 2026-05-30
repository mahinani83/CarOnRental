public with sharing class BookingQueableJob implements Queueable  {

    Set<Id> carIds;
    public BookingQueableJob(Set<Id> carIds) {
        this.carIds = carIds;
    }

    Map<Id,Decimal> carTotalValues = new Map<Id,Decimal>();

    public void execute(QueueableContext qc){
        for(AggregateResult agr : [select Car__c carId, sum(Total_Paid_Amount__c) totalValue 
                                    from Booking__c where Status__c  = :Constants.BOOKING_CLOSED_STATUS 
                                    AND Car__c in :carIds
                                    group by Car__c ]){
            Id carId = (Id) agr.get('carId');
            Decimal totalValue = (Decimal) agr.get('totalValue');
            System.debug('carId and totalValue' + carId + ' ' + totalValue); 
            carTotalValues.put(carId,totalValue);
        }

        // adding to Car List
        List<Car__c> carList = new List<Car__c>();

        for(Id carId : carIds){
            Car__c newCar = new Car__c(Id = carId);
            newCar.Total_Bookings_Value__c = carTotalValues.get(carId);
            carList.add(newCar);
        }

        try{
            if(carList.size() > 0){
                System.debug('inside the if block' + carList[0]);
                update carList;
            }
        } catch(Exception ex){
            System.debug('inside catch block' + ex.getMessage());
            system.debug(ex.getMessage());
            Log logger = Log.get();
            logger.publish(ex.getMessage());
        }
    }


}