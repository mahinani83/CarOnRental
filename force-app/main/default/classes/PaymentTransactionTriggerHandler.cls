public with sharing class PaymentTransactionTriggerHandler extends TriggerHandler{

    override public void afterInsert(){
        PaymentTransactionTriggerHandlerService.handlerPaymentTransactions(Trigger.new);
    }
    override public void afterDelete(){
        PaymentTransactionTriggerHandlerService.handlerPaymentTransactions(Trigger.old);
    }
}