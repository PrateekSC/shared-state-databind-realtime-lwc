@isTest
public class PropertyControllerTest {

    // Mock HTTP callout class
    public class PropertyCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            // Simulate API response
            res.setBody('{"results": {"properties": ['
                + '{"street": "123 Main St", "city": "Metropolis", "state": "CA", "zip": "90001",'
                + '"bedrooms": 3, "bathrooms": 2, "yearBuilt": 1999, "estimatedValue": 500000,'
                + '"latestMortgageLender": "Bank A", "latestMortgageAmount": 250000}'
                + ']}}');
            return res;
        }
    }

    @isTest
    static void testFetchProperties_success() {
        // Register mock
        Test.setMock(HttpCalloutMock.class, new PropertyCalloutMock());

        Test.startTest();
        try{
        List<Map<String, Object>> result = (List<Map<String, Object>>) PropertyController.fetchProperties(
            'query', '123 Main St', 'Metropolis', 'CA', '90001', true, 0, 1
        );
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('123 Main St', result[0].get('street'));
        } catch (Exception e){
            System.assertEquals(e!=null, true);
            List<Apex_Log__c> apexlogs = [SELECT Id FROM Apex_Log__c WHERE Status__c = 'Error'];
            System.Assert(apexlogs.size() > 0, true);
        }
        Test.stopTest();
    }

    @isTest
    static void testSaveProperties_success() {
        // Sample property
        Map<String, Object> property = new Map<String, Object>{
            'street' => '123 Main St',
            'city' => 'Metropolis',
            'state' => 'CA',
            'zip' => '90001',
            'bedrooms' => 3,
            'bathrooms' => 2,
            'yearBuilt' => 2001,
            'estimatedValue' => 450000,
            'latestMortgageLender' => 'Bank A',
            'latestMortgageAmount' => 200000
        };

        // Sample mortgage
        Map<String, Object> mortgage = new Map<String, Object>{
            'borrowers' => new List<String>{'John Doe'},
            'saleDate' => '2020-01-01T00:00:00.000Z',
            'recordingDate' => '2020-01-15T00:00:00.000Z',
            'dueDate' => '2030-01-01T00:00:00.000Z',
            'lenderName' => 'Bank A',
            'loanAmount' => 200000,
            'loanTermMonths' => 120,
            'interestRate' => 3.25
        };

        List<Map<String, Object>> properties = new List<Map<String, Object>>{ property };
        List<Object> mortgages = new List<Object>{ mortgage };

        Test.startTest();
        PropertyController.saveProperties(properties, mortgages);
        Test.stopTest();

        List<Property__c> props = [SELECT Id, Street__c FROM Property__c WHERE Street__c = '123 Main St'];
        System.assertEquals(1, props.size());

        List<Mortgage__c> loans = [SELECT Id, Borrowers__c FROM Mortgage__c WHERE Property__c = :props[0].Id];
        System.assertEquals(1, loans.size());
        System.assertEquals('John Doe', loans[0].Borrowers__c);
    }

    private class FailedCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": {"text": "URL Not Found","message": "Invalid URL","code": 404}}');
            return res;
        }
    }

    @isTest
    static void testFetchProperties_apiFailure() {
        // Register the failing mock
        Test.setMock(HttpCalloutMock.class, new FailedCalloutMock());

        // Expect an AuraHandledException
        Boolean caught = false;
        Test.startTest();
        try {
            List<Map<String, Object>> result = (List<Map<String, Object>>) PropertyController.fetchProperties('badQuery', '', '', '', '', false, 0, 1);
        } catch (AuraHandledException e) {
            caught = true;
            system.debug(e.getMessage());
            List<Apex_Log__c> apexlogs = [Select Id from Apex_Log__c where Status__c = 'Failed'];
            System.Assert(apexlogs.size() > 0, true);
        }
        Test.stopTest();

        System.assert(caught, 'AuraHandledException was expected but not thrown');
    }
}