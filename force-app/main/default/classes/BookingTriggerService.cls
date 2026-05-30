public with sharing class BookingTriggerService {
   


    public static void updateTotalBookingValueForCar(List<Booking__c> bookings , Map<Id,Booking__c> oldBookings){
        Set<Id> carIds = new Set<Id>();

        for(Booking__c booking : bookings){
            if(booking.Status__c == 'Closed' && booking.Status__c != oldBookings.get(booking.Id).Status__c){
                carIds.add(booking.Car__c);
            }
        }

        System.enqueueJob(new BookingQueableJob(carIds));

    }
}