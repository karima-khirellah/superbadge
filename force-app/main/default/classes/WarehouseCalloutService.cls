public with sharing class WarehouseCalloutService implements Queueable{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void synchEquipmentInventory(){
      	Http http = new Http();
		HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
		request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Product2> equipmentRecords = new List<Product2>();
        if(response.getStatusCode() == 200) {
            //parse the response
            // Deserialize the JSON string into collections of primitive data types.
          List<Object> responseResults = (List<Object>) JSON.deserializeUntyped(response.getBody());
          System.debug(response.getBody());
            for(Object equipment : responseResults){
                Map<String,Object> equipmentJSON = (Map<String,Object>) equipment;
                // update/ create Equipment in Salesforce
                Product2 eq = new Product2();
                eq.Replacement_Part__c = (Boolean) equipmentJSON.get('replacement');
                eq.Name = (String) equipmentJSON.get('name');
                eq.Maintenance_Cycle__c = (Integer) equipmentJSON.get('maintenanceperiod');
                eq.Lifespan_Months__c = (Integer) equipmentJSON.get('lifespan');
                eq.Cost__c = (Integer) equipmentJSON.get('cost');
                eq.Warehouse_SKU__c = (String) equipmentJSON.get('sku');
                eq.Current_Inventory__c = (Double) equipmentJSON.get('quantity');
                equipmentRecords.add(eq);
                
            }
            
            if(!equipmentRecords.isEmpty()){
                System.debug('Number of equipment records: '+equipmentRecords.size());  
 
                upsert equipmentRecords Warehouse_SKU__c;   
                   
               
                System.debug('synch finished with success');
            }
  
    }
  }
    public static void execute (QueueableContext context){
       synchEquipmentInventory();
    }
    
}