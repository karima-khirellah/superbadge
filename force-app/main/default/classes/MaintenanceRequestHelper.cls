/**
 * 
 * @author  karima KHIR ELLAH
 * @since 
 */
public with sharing class MaintenanceRequestHelper {
    
    /**
     *  Create new maintenance request with the same Vehicle and Equipment Records as the original closed request
     * @param updatedMRequests 
     * @param oldMRequests 
     */
    public static void updateWorkOrders(List<Case> updatedMRequests, Map<Id,Case> oldMRequests){
        List<Case> newMaintenanaceRequests = new List<Case>();
        Map<Id,Id> closedMaintenanceRequests = new Map<Id,Id>();
        //get the MIN OF maintenance cycle from  the old  maintenace request 
        AggregateResult[] results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)maintenanceCycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :updatedMRequests GROUP BY Maintenance_Request__c ];
        Map<Id,Decimal> maintenaceCycleMap = new Map<Id,Decimal>();
        for(AggregateResult result : results){
            maintenaceCycleMap.put((Id) result.get('Maintenance_Request__c'), (Decimal) result.get('maintenanceCycle'));
        }
        
        for(Case maintenanceRequest : updatedMRequests){  
            //
            if(oldMRequests.get(maintenanceRequest.Id).Status != 'Closed' && maintenanceRequest.Status == 'Closed'){
                if(maintenanceRequest.Type == 'Repair'|| maintenanceRequest.Type == 'Routine Maintenance'){
                
                Case newMRequest = new Case();
                newMRequest.Status = 'New';
                // use a field to store the Id of current case and use it later
                newMRequest.ParentId = maintenanceRequest.Id;
                newMRequest.Type = 'Routine Maintenance';
                newMRequest.Subject = 'Future routine checkup Test';
                newMRequest.Vehicle__c = maintenanceRequest.Vehicle__c;  
                newMRequest.Date_Reported__c = Date.today();
                newMRequest.Date_Due__c = Date.today().addDays((Integer) maintenaceCycleMap.get(maintenanceRequest.Id));
                newMaintenanaceRequests.add(newMRequest);
                System.debug('New Maintenance Request to be created : '+newMRequest);
                closedMaintenanceRequests.put(maintenanceRequest.Id,maintenanceRequest.Id);
            }
            }  
            
        }
        if(!newMaintenanaceRequests.isEmpty()){
            insert newMaintenanaceRequests; 
            System.debug('Number of Maintenance Requests created : '+newMaintenanaceRequests.size());
            //call this method to create the maintenanace request items for the new M requests
            createNewEquipmentMaintenanceItems(newMaintenanaceRequests,closedMaintenanceRequests);
    }
    }

    /**
     * Create Equipment Maintenance Items and assign to new maintenance request
     * @param newCreatedMRequests 
     * @param closedMaintenanceRequests 
     */
    public static void createNewEquipmentMaintenanceItems(List<Case> newCreatedMRequests, Map<Id,Id> closedMaintenanceRequests){

        List<Equipment_Maintenance_Item__c> newEquipmentItems = new List<Equipment_Maintenance_Item__c>();
        // get ParentIds from newCreatedMRequests
        Set<Id> parentIds = new Set<Id>();
        for (Case mRequest : newCreatedMRequests) {
            parentIds.add(mRequest.ParentId);
        }

        // get all related equipment items using ParentIds
        Map<Id, List<Equipment_Maintenance_Item__c>> maintenanceItemsMap = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        for (Equipment_Maintenance_Item__c eqItem : [SELECT Equipment__c, Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :parentIds]) {
            if (!maintenanceItemsMap.containsKey(eqItem.Maintenance_Request__c)) {
                maintenanceItemsMap.put(eqItem.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>());
            }
            maintenanceItemsMap.get(eqItem.Maintenance_Request__c).add(eqItem);
        }

        // Creating new Equipment Maintenance Items
        for (Case mRequest : newCreatedMRequests) {
            System.debug('the new maintenance request: ' + mRequest);

            if (maintenanceItemsMap.containsKey(mRequest.ParentId)) {
                for (Equipment_Maintenance_Item__c eqItem : maintenanceItemsMap.get(mRequest.ParentId)) {
                    Equipment_Maintenance_Item__c newEquipmentItem = new Equipment_Maintenance_Item__c();
                    newEquipmentItem.Equipment__c = eqItem.Equipment__c;
                    newEquipmentItem.Maintenance_Request__c = mRequest.Id;
                    System.debug('The New Equipment maintenance Item to create : ' + newEquipmentItem);
                    newEquipmentItems.add(newEquipmentItem);
                }
            }
        }

        if(!newEquipmentItems.isEmpty()) {
            insert newEquipmentItems;
        }  
      

    }

}