@isTest
public with sharing class MaintenanceRequestHelperTest {
    
    private static final String STATUS_NEW = 'New';
    private static final String STATUS_CLOSED = 'Closed';
    private static final String STATUS_WORKING = 'Working';
    private static final String PRIORITY = 'High';
    private static final String TYPE_ROUTINE = 'Routine Maintenance';
    private static final String TYPE_REPAIR = 'Repair';
    private static final String SUBJECT = 'Test Maintenance Request subject';
    
    private static Vehicle__c createNewVehicle(){
       Vehicle__c vehicule = new Vehicle__c(Name ='MyTestVehicule');
        return vehicule;
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
        
        Product2 equipment = createNewEquipment();
        insert equipment;
        
        Case maintenanceRequest= createNewMaintenanceRequest(vehicle.Id);
        insert maintenanceRequest;
        
        Equipment_Maintenance_Item__c eqItem = createEquipmentItem(equipment.Id,maintenanceRequest.Id);
        insert eqItem;
       
        
        // run the test on after update
        Test.startTest();
        maintenanceRequest.Status = STATUS_CLOSED;
        update maintenanceRequest;
        Test.stopTest();
        
        List<Case> updatedMRequests = 
            [SELECT Id, Status,Subject,Type,Vehicle__c 
            FROM Case 
            WHERE Status = :STATUS_NEW ];
        List<Equipment_Maintenance_Item__c> eqItems = [SELECT id
                                                 FROM Equipment_Maintenance_Item__c
                                                 WHERE Maintenance_Request__c =:updatedMRequests[0].Id];
        System.assert(updatedMRequests.size() == 1);
        System.assertEquals(updatedMRequests[0].Type, TYPE_ROUTINE);
        System.assertEquals(updatedMRequests[0].Vehicle__c,vehicleId);
        System.assert(!empty(eqItems));
        
    
    }
     @isTest
    static void testUpdateWorkOrdersNegative() {
        // Test data setup
        Vehicle__c vehicle = createNewVehicle();
        insert vehicle;
        
        Product2 equipment = createNewEquipment();
        insert equipment;
        
        Case maintenanceRequest= createNewMaintenanceRequest(vehicle.Id);
        insert maintenanceRequest;

        
        Equipment_Maintenance_Item__c eqItem = createEquipmentItem(equipment.Id,maintenanceRequest.Id);
        insert eqItem;
       
        
        // run the test on after update
        Test.startTest();
        maintenanceRequest.Priority = PRIORITY;
        maintenanceRequest.Status = STATUS_WORKING;
        update maintenanceRequest;
        Test.stopTest();
        
        List<Case> updatedMRequests = [SELECT Id 
                                        FROM Case 
                                        WHERE Status=:STATUS_NEW ];
        List<Case> workingMRequests = [SELECT Id 
                                        FROM Case 
                                        WHERE Status=:STATUS_WORKING ];
       
        System.assert(updatedMRequests.size() == 0);
        System.assert(workingMRequests.size() == 1);
        
    
    }
    
  @istest
    private static void testUpdateWorkOrdersBulk(){
        List<Vehicle__C> vehicleList = new List<Vehicle__C>();
        List<Product2> equipmentList = new List<Product2>();
        List<Equipment_Maintenance_Item__c> equipmentItemList = new list<Equipment_Maintenance_Item__c>();
        List<case> maintenanceRequestList = new List<case>();
        List<id> oldRequestIds = new List<id>();
        
        for(Integer i = 0; i < 300; i++){
            vehicleList.add(createNewVehicle());
            equipmentList.add(createNewEquipment());
        }
        insert vehicleList;
        insert equipmentList;
        
        for(Integer i = 0; i < 300; i++){
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
        
        List<case> allRequests = [SELECT id
                                 FROM case
                                 WHERE status =: STATUS_NEW];
        

        
        system.assert(allRequests.size() == 300);
    }      

}