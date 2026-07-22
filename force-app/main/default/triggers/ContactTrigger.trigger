trigger ContactTrigger on Contact (after insert,after update) {
    System.debug('inside the trigger');
    new MetadataTriggerHandler().run();
}