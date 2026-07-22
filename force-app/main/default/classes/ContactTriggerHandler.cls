public with sharing class ContactTriggerHandler extends TriggerHandler{
    public ContactTriggerHandler() {

    }

    override public void afterInsert(){
        System.debug('inside handler and afterinsert');
        // get contact ids and pass it to the service 
        ContactTriggerService.processContact((List<Contact>) Trigger.new);
    }

    override public void afterUpdate(){
        List<Contact> oldContacts = (List<Contact>) Trigger.old;
        Map<Id,Contact> newContacts = (Map<Id,Contact>) Trigger.newMap; 
        List<Contact> contactsToProcess = new List<Contact>();
        for(Contact con : oldContacts){
            Contact updatedContact = newContacts.get(con.Id);
            if(con.Email != updatedContact.Email){
                contactsToProcess.add(updatedContact);
            }
        }

        if(contactsToPfrocess.size() > 0) 
            ContactTriggerService.processContact(contactsToProcess);

    }

}