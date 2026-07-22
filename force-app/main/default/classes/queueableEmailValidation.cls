public with sharing class queueableEmailValidation implements Queueable, Database.AllowsCallouts {

    private List<Id> contactIds;
    public queueableEmailValidation(List<Id> contactIds) {
        this.contactIds = contactIds;
    }

    // get all the contacts for this id
    // check the email field 
    // updat ethe field email_verified field 


    public void execute(QueueableContext qc){
    System.debug('inside of quable context');
        // get the api key
        System_thredshould__mdt apiKey = System_thredshould__mdt.getInstance(Constants.EMAIL_REPUTATION_APIKEY);

        List<Contact> contacts = [
            SELECT Id, Email FROM Contact Where Id In :this.contactIds
        ];

        List<Contact> contactToUpdate = new List<Contact>();

        for(Contact con : contacts){
            if(con.Email != null){
                Boolean isValidEmail = checkEmailStatus(con.Email);
                System.debug('is valid email log' + isValidEmail);
                if(isValidEmail) con.Email_Verified__c = true;
                else con.Email_Verified__c = false;
                contactToUpdate.add(con);
            }
        }

        try{
            if(contactToUpdate.size() > 0) update contactToUpdate;
        }catch(DMLException ex){
            system.debug(ex.getMessage());
            Log logger = Log.get();
            logger.publish(ex.getMessage());
        }

    }

    public Boolean checkEmailStatus(String email){
        System_thredshould__mdt emailValidMdt = System_thredshould__mdt.getInstance('Email_Reputation');
        String apiKey = emailValidMdt.value__c;
        // making request
        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:EmailReputation/?api_key=' + apiKey + '&email=' + email);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(120000);

        Log logger = Log.get();

        try{
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('res from the api call ' + res);
            if(res.getStatusCode() == 200){
                Map<String,Object> responseData = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                Map<String,Object> delivarability = (Map<String,Object>) responseData.get('email_deliverability');
                String status = (String) delivarability.get('status');
                String status_detail = (String) delivarability.get('status_detail');
                if(status == Constants.STATUS_EMAIL && status_detail == Constants.STATUS_DETAIL_EMAIL){
                    return true;
                }
                return false;
            }
            else{
                logger.publish('API Email Validation Failed ' + res.getStatusCode() + ' ' + res.getBody());
                return false;
            }

        }catch(Exception ex){
            System.debug('Exception occured while validating email ' + ex.getMessage());
            logger.publish('API Email Validation Failed ' + ex.getMessage());
            return false;
        }
    }
}




