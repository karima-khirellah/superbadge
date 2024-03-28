@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @IsTest
    static void testSynchEquipmentInventory() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.execute(null);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM Product2]);
        Product2 eq = [SELECT Warehouse_SKU__c FROM Product2];
        System.assertEquals('100003', eq.Warehouse_SKU__c);
        
    }

}