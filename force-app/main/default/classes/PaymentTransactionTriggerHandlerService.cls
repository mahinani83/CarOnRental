public with sharing class PaymentTransactionTriggerHandlerService{
    public static void handlerPaymentTransactions(List<Payment_Transaction__c> paymentTransactions){

        Set<Id> bookingIds = new Set<Id>();

        List<Booking__c> updateBookingRecords = new List<Booking__c>();

        // get booking id
        for(Payment_Transaction__c payment : paymentTransactions){
            bookingIds.add(payment.Booking__c);
        }

        // queriig bookings
        Set<String> paymentType = new Set<String>();
        paymentType.add(Constants.TYPE_INITIAL_PAYMENT);
        paymentType.add(Constants.TYPE_PARTIAL_PAYMENT);
        paymentType.add(Constants.TYPE_SECURITY_DEPOSIT);

        List<Booking__c> bookingList = [SELECT Id,Status__c,Payment_Status__c,Final_Booking_Price__C,Security_Deposit__c,
        (SELECT id,Amount__c,Type__c,Status__c FROM Payment_Transactions__r where status__c =:Constants.SUCCESS AND type__c in :paymentType) FROM Booking__c WHERE Id in:bookingIds];

        for(Booking__c booking : bookingList){
            Decimal initialPayment = 0;
            Decimal partialPayment = 0;
            Decimal securityPayment = 0;

            for(Payment_Transaction__c payment : booking.Payment_Transactions__r){
                if(payment.Type__c == Constants.TYPE_INITIAL_PAYMENT) initialPayment += payment.Amount__c;
                if(payment.Type__c == Constants.TYPE_PARTIAL_PAYMENT) partialPayment += payment.Amount__c;
                if(payment.Type__c == Constants.TYPE_SECURITY_DEPOSIT) securityPayment += payment.Amount__c;
            }       


        System.debug('initialPayment'+initialPayment);
        System.debug('partialPayment'+partialPayment);
        System.debug('securityPayment'+securityPayment);

        booking.Payment_Status__c = calculatePaymentStatus(initialPayment, partialPayment, securityPayment, booking.Final_Booking_Price__c, booking.Security_Deposit__c);
        booking.Status__c = calculateBookingStatus(initialPayment, partialPayment, securityPayment, booking.Status__c);
        updateBookingRecords.add(booking);
        }

        if(updateBookingRecords.size() > 0){
            try{
                update updateBookingRecords;
            }catch(Exception e){
                System.debug('error while updating hte payment status and booking statu ' + e.getMessage());
                Log logger = Log.get();
                logger.publish('errr while updating payment and booking status ' + e.getMessage());
            }
        }
    }

    public static String calculatePaymentStatus(Decimal initialPayment,Decimal partialPayment,Decimal securityPayment,Decimal finalBookingPrice,Decimal securityDeposit){
        if(initialPayment == 0 && partialPayment == 0 && securityDeposit == 0 && finalBookingPrice == 0) return Constants.BOOKING_PENDING_STATUS;
        Decimal totalRentalPayment = initialPayment + partialPayment;
        Boolean isTotalRentalPaymentCompleted = finalBookingPrice <= totalRentalPayment;
        Boolean isSecurityDepositCompleted = securityDeposit <= securityPayment;
        System.debug('istotal rental paymentcompleted ' + isTotalRentalPaymentCompleted);

        if(isTotalRentalPaymentCompleted && isSecurityDepositCompleted) return Constants.BOOKING_PAID;
        return Constants.BOOKING_PARTIAL_PAID;
    }

    public static String calculateBookingStatus(Decimal initialPayment,Decimal partialPayment,Decimal securityPayment,String currentBookingStatus){
        System.debug('current status in the function ' + currentBookingStatus);
        if(currentBookingStatus == Constants.BOOKING_PAYMENT_PENDING && (initialPayment >0 || partialPayment > 0 || securityPayment > 0)) return Constants.BOOKING_CONFIRM_STATUS;
        return currentBookingStatus;
    }
}