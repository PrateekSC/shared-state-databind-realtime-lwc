@isTest
private class MyCustomExceptionTest {


@IsTest
    static void testCustomException() {
        try {
            throw new MyCustomException('This is a custom exception.');
        } catch (MyCustomException e) {
            System.assertEquals('This is a custom exception.', e.getMessage());
        }
    }

}