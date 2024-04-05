@isTest
public with sharing class WarehouseSyncScheduleTest {

    @isTest static void WarehousescheduleTest(){
        String scheduleTime = '00 00 01 * * ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobID=System.schedule('ScheduledWarehouseTest', scheduleTime, new WarehouseSyncSchedule());
        Test.stopTest();
        System.assertEquals('ScheduledWarehouseTest', [SELECT CronJobDetail.Name FROM CronTrigger WHERE Id = :jobID].CronJobDetail.Name, 'Expected job name to match');
             
       
       
    }
}