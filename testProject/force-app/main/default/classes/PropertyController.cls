public with sharing class PropertyController {

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> fetchProperties(String query, String street, String city, String state, String zip, Boolean useYearBuilt, Integer skip, Integer take) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        //request.setEndpoint('https://api.batchdata.com/property/search');
        request.setEndpoint('https://stoplight.io/mocks/batchdata/batchdata/20349728/property/search');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        //request.setHeader('Authorization', 'Bearer API_KEY_HERE'); // Replace with real API key
        request.setHeader('Authorization', '');
        request.setHeader('Prefer', 'code=200');

        Map<String, Object> compAddress = new Map<String, Object>{
            'street' => street,
            'city'   => city,
            'state'  => state,
            'zip'    => zip
        };

        Map<String, Object> searchCriteria = new Map<String, Object>{
            'query' => query,
            'compAddress' => compAddress
        };

        Map<String, Object> options = new Map<String, Object>{
            'useYearBuilt' => useYearBuilt,
            'skip' => skip,
            'take' => take
        };

        Map<String, Object> payload = new Map<String, Object>{
            'searchCriteria' => searchCriteria,
            'options' => options
        };

        request.setBody(JSON.serialize(payload));

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> properties = (List<Object>) ((Map<String, Object>)jsonResponse.get('results')).get('properties');
                logMessage('Success',response.getStatusCode(),'PropertyController','fetchProperties',JSON.serialize(payload),JSON.serialize(jsonResponse),null,null);                
                return (List<Map<String, Object>>)properties;
            } else {
                Map<String, Object> jsonErrorResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> errorMessageResponseDeserialize = (Map<String, Object>)jsonErrorResponse.get('status');
                String errorMessageResponse = (String) errorMessageResponseDeserialize.get('message');
                String errorTextResponse = (String)errorMessageResponseDeserialize.get('text');
                logMessage('Failed',response.getStatusCode(),'PropertyController','fetchProperties',JSON.serialize(payload),JSON.serialize(jsonErrorResponse),null,errorMessageResponse);                
                throw new AuraHandledException('BATCH api error: '+errorTextResponse.replaceAll('[\\n\\r\\t\\{\\}\\[\\]\"]', ' '));
            }
        } catch (Exception e) {
            logMessage('Error',null,'PropertyController','fetchProperties',JSON.serialize(payload),null,String.valueOf(e.getStackTraceString()),String.valueOf(e.getMessage()));
            String exceptionMsg = e != null ? e.getMessage() : null;
            String processErrorMsg = (String.isBlank(exceptionMsg) ? 'Unknown error during API call.' : (exceptionMsg.length() > 200 ? exceptionMsg.substring(0, 200) : exceptionMsg));
            processErrorMsg = processErrorMsg.replaceAll('[\\n\\r\\t\\{\\}\\[\\]\"]', ' ').trim().removeEndIgnoreCase('.');
            String errorMsg = String.isBlank(processErrorMsg) ? 'Unknown error during API call.' : processErrorMsg;
            throw new AuraHandledException(errorMsg);
        }
    }

    public static void logMessage(String status, Integer httpStatusCode, String className, String methodName, String request, String response, String stackTrace, String errorMessage){
        Apex_Log__c apexLog = new Apex_Log__c(
            Status__c          = status,
            HTTPStatusCode__c  = httpStatusCode,
            Class_Name__c      = className,
            Method_Name__c     = methodName,
            RequestPayload__c  = request,
            ResponsePayload__c = response,
            StackTrace__c      = stackTrace,
            Error_Message__c   = errorMessage
        );
        insert apexLog;
    }

    @AuraEnabled
    public static void saveProperties(List<Map<String, Object>> properties, List<Object> mortgagesHistory) {
        List<Property__c> records = new List<Property__c>();
        List<Mortgage__c> mortgages = new List<Mortgage__c>();

        for (Map<String, Object> p : properties) {
            Property__c prop = new Property__c();
            prop.Street__c = (String)p.get('street');
            prop.City__c = (String)p.get('city');
            prop.State__c = (String)p.get('state');
            prop.Zip__c = (String)p.get('zip');
            prop.Bedrooms__c = String.valueOf(p.get('bedrooms'));
            prop.Bathrooms__c = String.valueOf(p.get('bathrooms'));
            prop.Year_Built__c = String.valueOf(p.get('yearBuilt'));
            prop.Estimated_Value__c = String.valueOf(p.get('estimatedValue'));
            prop.Mortgage_Lender__c = (String)p.get('latestMortgageLender');
            prop.Latest_Mortgage__c = String.valueOf(p.get('latestMortgageAmount'));
            records.add(prop);
        }
        insert records;

        for (Object obj : mortgagesHistory) {
            Map<String, Object> loanMap = (Map<String, Object>) obj;

            // Borrowers is a list
            List<Object> borrowers = (List<Object>) loanMap.get('borrowers');
            String borrowerNames = String.join((List<String>)borrowers, ', ');
            Mortgage__c mortgage = new Mortgage__c();
            mortgage.Borrowers__c = borrowerNames;
            mortgage.Name = (String) loanMap.get('lenderName');
            mortgage.Sale_Date__c = Datetime.valueOf(((String) loanMap.get('saleDate')).replace('Z', '').split('\\.')[0].replace('T', ' '));
            mortgage.Recording_Date__c = Datetime.valueOf(((String) loanMap.get('recordingDate')).replace('Z', '').split('\\.')[0].replace('T', ' '));
            mortgage.Due_Date__c = Datetime.valueOf(((String) loanMap.get('dueDate')).replace('Z', '').split('\\.')[0].replace('T', ' '));
            mortgage.Loan_Amount__c = (Integer) loanMap.get('loanAmount');
            mortgage.Loan_Term_Months__c = (Integer) loanMap.get('loanTermMonths');
            mortgage.Interest_Rate__c = (Decimal) loanMap.get('interestRate');
            mortgage.Property__c = records[0].Id;
            mortgages.add(mortgage);
        }
        insert mortgages;
    }
}
