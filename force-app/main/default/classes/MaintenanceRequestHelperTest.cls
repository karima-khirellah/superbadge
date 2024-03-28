@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    private static final string STATUS_NEW = 'New';
    private static final string STATUS_CLOSED = 'Closed';
    private static final string STATUS_WORKING = 'Working';
    private static final string PRIORITY = 'High';
    private static final string TYPE_ROUTINE = 'Routine Maintenance';
    private static final string TYPE_REPAIR = 'Repair';
    private static final string SUBJECT = 'Test Maintenance Request subject';
    
    private static Vehicle__c createNewVehicle(){
       Vehicle__c v = new Vehicle__c(name ='MyTestVehicule');
        return v;
    }      
    private static Product2 createNewEquipment(){
        Product2 newEquipment = new Product2();
        newEquipment.Name ='MYTESTEQUIPMENT';
        newEquipment.Lifespan_Months__c = 20;
        newEquipment.Maintenance_Cycle__c = 20;
        newEquipment.replacement_part__c =true;           
      return newEquipment;
    }
    private static Case createNewMaintenanceRequest(id vehicleId){
        case maintenanceRequest = new case(Type=TYPE_REPAIR,
                          Status=STATUS_NEW,
                          Subject=SUBJECT,
                          Vehicle__c=vehicleId);
        return maintenanceRequest;
    }
    private static Equipment_Maintenance_Item__c createEquipmentItem(id equipmentId,id maintenanceRequestId){
        Equipment_Maintenance_Item__c eqItem = new Equipment_Maintenance_Item__c();
         eqItem.Equipment__c = equipmentId;
         eqItem.Maintenance_Request__c = maintenanceRequestId;
        return eqItem;
    }
    
    @isTest
    static void testUpdateWorkOrdersPositive() {
        // Test data setup
        Vehicle__c vehicle = createNewVehicle();
        insert vehicle;
        id vehicleId = vehicle.Id;
        
        Product2 equipment = createNewEquipment();
        insert equipment;
        Id equipmentId = equipment.Id;
        
        Case maintenanceRequest= createNewMaintenanceRequest(vehicleId);
        insert maintenanceRequest;
        Id maintenanceRequestId = maintenanceRequest.Id;
        
        Equipment_Maintenance_Item__c eqItem = createEquipmentItem(equipmentId,maintenanceRequestId);
        insert eqItem;
       
        
        // run the test on after update
        Test.startTest();
        maintenanceRequest.Status = STATUS_CLOSED;
        update maintenanceRequest;
        Test.stopTest();
        
        List<Case> updatedMRequests = [SELECT Id, Status,Subject,Type,Vehicle__c FROM Case WHERE Status=:STATUS_NEW ];
        List<Equipment_Maintenance_Item__c> eqItems = [select id
                                                 from Equipment_Maintenance_Item__c
                                                 where Maintenance_Request__c =:updatedMRequests[0].Id];
        System.assert(updatedMRequests.size() == 1);
        System.assertEquals(updatedMRequests[0].Type, TYPE_ROUTINE);
        System.assertEquals(updatedMRequests[0].Vehicle__c,vehicleId);
        System.assert(eqItems[0]!=null);
    
    }
     @isTest
    static void testUpdateWorkOrdersNegative() {
        // Test data setup
        Vehicle__c vehicle = createNewVehicle();
        insert vehicle;
        id vehicleId = vehicle.Id;
        
        Product2 equipment = createNewEquipment();
        insert equipment;
        Id equipmentId = equipment.Id;
        
        Case maintenanceRequest= createNewMaintenanceRequest(vehicleId);
        insert maintenanceRequest;
        Id maintenanceRequestId = maintenanceRequest.Id;
        
        Equipment_Maintenance_Item__c eqItem = createEquipmentItem(equipmentId,maintenanceRequestId);
        insert eqItem;
       
        
        // run the test on after update
        Test.startTest();
        maintenanceRequest.Priority = PRIORITY;
        maintenanceRequest.Status = STATUS_WORKING;
        update maintenanceRequest;
        Test.stopTest();
        
        List<Case> updatedMRequests = [SELECT Id FROM Case WHERE Status=:STATUS_NEW ];
        List<Case> workingMRequests = [SELECT Id FROM Case WHERE Status=:STATUS_WORKING ];
       
        System.assert(updatedMRequests.size() == 0);
         System.assert(workingMRequests.size() == 1);
        
    
    }
    
  @istest
    private static void testUpdateWorkOrdersBulk(){
        list<Vehicle__C> vehicleList = new list<Vehicle__C>();
        list<Product2> equipmentList = new list<Product2>();
        list<Equipment_Maintenance_Item__c> equipmentItemList = new list<Equipment_Maintenance_Item__c>();
        list<case> maintenanceRequestList = new list<case>();
        list<id> oldRequestIds = new list<id>();
        
        for(integer i = 0; i < 300; i++){
            vehicleList.add(createNewVehicle());
            equipmentList.add(createNewEquipment());
        }
        insert vehicleList;
        insert equipmentList;
        
        for(integer i = 0; i < 300; i++){
            maintenanceRequestList.add(createNewMaintenanceRequest(vehicleList.get(i).id));
        }
        insert maintenanceRequestList;
        
        for(integer i = 0; i < 300; i++){
            equipmentItemList.add(createEquipmentItem(equipmentList.get(i).id, maintenanceRequestList.get(i).id));
        }
        insert equipmentItemList;
        
        test.startTest();
        for(case req : maintenanceRequestList){
            req.Status = STATUS_CLOSED;
            oldRequestIds.add(req.Id);
        }
        update maintenanceRequestList;
        test.stopTest();
        
        list<case> allRequests = [select id
                                 from case
                                 where status =: STATUS_NEW];
        

        
        system.assert(allRequests.size() == 300);
    }      

}