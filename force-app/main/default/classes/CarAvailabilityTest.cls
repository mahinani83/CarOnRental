@isTest
public with sharing class CarAvailabilityTest {
    public CarAvailabilityTest() {

    }

    @TestData
    static void createData(){
        List<Car__c> cars = TestDataFActory.createCars(4);
    }
    @isTest
    static void testCarAvailability(){
        // make api request and see the status code given by the response
        Request req = new Request();
        Response res = new Response();


        req.params.put('startDate',formatDate(date.today().addDays(10)));
        req.params.put('endDate',formatDate(date.today().addDays(30)));
        req.params.put('location','Pune');
        req.params.put('fuelType','Petrol');
        req.params.put('transmissionType','Automatic');

        // making api call
        Test.startTest();
        CarAvailabilityCheckApi.responseWrapper response  = new CarAvailabilityCheckApi.getAvailableCars();
        Test.stopTest();

        System.assertEquals('Success', response.message, 'Call SuccessFull');
    }

    private static string formatDate(Date inpDate){
          return inpDate.year() + '-' + inpDate.month() + '-' + inpDate.day();  
    }


}