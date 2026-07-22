@isTest
public with sharing class ContactTriggerTest {
    public ContactTriggerTest() {

    }

    @TestSetup
    public static void makeData(){
        List<Contact> contacts = TestDataFactory.createContacts(1);

    }

    @isTest
    static void testEmailValidationOfInsertOrUpdate(){
        // create a dummay response 
        // get and update the contact 



        Test.setMock(HttpCalloutMock.class, new EmailValidationHttpMock());

        // get contact and update the mail

        Contact con = [
            SELECT ID , EMAIL FROM CONTACT LIMIT 1
        ];

        con.Email = 'puligantimahi@gmail.com';

        Test.startTest();
            update con;
        Test.stopTest();

        Contact updatedCon = [
            SELECT Id, Email , Email_Verified__c  
            FROM CONTACT
            LIMIT 1
        ];
        System.Assert.areEqual(true ,updatedCon.Email_Verified__c, 'Invalid email status got wrong');

    }
}