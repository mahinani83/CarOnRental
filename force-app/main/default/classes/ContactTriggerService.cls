public with sharing class ContactTriggerService {
    public ContactTriggerService() {

    }

    public static void processContact(List<Contact> contacts){
        System.debug('inside of serive and process contact method');
        // get ids and pass it to the queable process
        List<Id> contactIds = new  List<Id>();

        for(Contact con : contacts){
            contactIds.add(con.Id);
        }

        if(contactIds.size() > 0){
            System.enqueueJob(new queueableEmailValidation(contactIds)); 
        }

    }

}