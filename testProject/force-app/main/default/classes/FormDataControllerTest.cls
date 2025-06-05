@isTest
private class FormDataControllerTest {


@IsTest
    static void testSaveFormData() {
        String jsonData = '{"account": {"name": "Test Account", "industry": "Technology", "rating": "Hot", "phone": "1234567890", "email": "test@example.com"}, "contact": {"firstName": "John", "lastName": "Doe", "email": "john.doe@example.com", "phone": "0987654321"}, "opportunity": {"name": "Test Opportunity", "stage": "Prospecting", "amount": "10000"}}';

        Test.startTest();
        FormDataController.saveFormData(jsonData);
        Test.stopTest();

        Account act = [SELECT Id, Name, Industry, Rating, Phone, Email__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id, FirstName, LastName, Email, Phone, AccountId FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        Opportunity opp = [SELECT Id, Name, StageName, Amount, CloseDate, AccountId FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];

        System.assertEquals('Test Account', act.Name,'Account Name should match');
        System.assertEquals('Technology', act.Industry,'Account Industry should match');
        System.assertEquals('Hot', act.Rating,'Account Rating should match');
        System.assertEquals('1234567890', act.Phone,'Account Phone should match');
        System.assertEquals('test@example.com', act.Email__c,'Account Email__c should match');

        System.assertEquals('John', con.FirstName,'Contact FirstName should match');
        System.assertEquals('Doe', con.LastName,'Contact LastName should match');
        System.assertEquals('john.doe@example.com', con.Email,'Contact Email should match');
        System.assertEquals('0987654321', con.Phone,'Contact Phone should match');
        System.assertEquals(act.Id, con.AccountId,'Contact Account should match');

        System.assertEquals('Test Opportunity', opp.Name,'Opportunity Name should match');
        System.assertEquals('Prospecting', opp.StageName,'Opportunity Stage should match');
        System.assertEquals(10000, opp.Amount,'Opportunity Amount should match');
        System.assertEquals(Date.today().addDays(30), opp.CloseDate,'Opportunity Closeddate should match');
        System.assertEquals(act.Id, opp.AccountId,'Opportunity Account should match');
    }

}