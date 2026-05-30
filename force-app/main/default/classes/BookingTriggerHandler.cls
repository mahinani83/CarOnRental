public with sharing class BookingTriggerHandler extends TriggerHandler {
    public BookingTriggerHandler() {

    }


    override public void afterUpdate(){
        BookingTriggerService.updateTotalBookingValueForCar((List<Booking__c>) Trigger.new,(Map<Id,Booking__c>) Trigger.oldMap);
    }




}