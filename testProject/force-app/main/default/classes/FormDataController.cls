public with sharing class FormDataController {
    @AuraEnabled
    public static void saveFormData(String jsonData) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

        Map<String, Object> accMap = (Map<String, Object>) data.get('account');
        Map<String, Object> conMap = (Map<String, Object>) data.get('contact');
        Map<String, Object> oppMap = (Map<String, Object>) data.get('opportunity');

        Account acc = new Account(
            Name = (String) accMap.get('name'),
            Industry = (String) accMap.get('industry'),
            Rating = (String) accMap.get('rating'),
            Phone = (String) accMap.get('phone'),
            Email__c = (String) accMap.get('email') // Assume custom Email field
        );
        if(Schema.sObjectType.Account.isCreateable()){
            insert acc;
        }
        Contact con = new Contact(
            FirstName = (String) conMap.get('firstName'),
            LastName = (String) conMap.get('lastName'),
            Email = (String) conMap.get('email'),
            Phone = (String) conMap.get('phone'),
            AccountId = acc.Id
        );
        if(Schema.sObjectType.Contact.isCreateable()){
            insert con;
        }
        Opportunity opp = new Opportunity(
            Name = (String) oppMap.get('name'),
            StageName = (String) oppMap.get('stageName'),
            Amount = Decimal.valueOf((String)oppMap.get('amount')),
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        if(Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
    }
}
