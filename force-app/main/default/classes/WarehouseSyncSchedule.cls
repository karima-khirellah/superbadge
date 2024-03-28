public with sharing class WarehouseSyncSchedule implements Schedulable{
    public void execute(SchedulableContext ctx) {
        //call the wharehousecalloutservice
        System.enqueueJob(new WarehouseCalloutService());
    }
}