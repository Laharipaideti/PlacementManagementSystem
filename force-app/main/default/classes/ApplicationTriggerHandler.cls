public with sharing class ApplicationTriggerHandler {

    public static void beforeInsert(List<Application__c> applications) {
        ApplicationService.validateApplications(applications);
    }

    public static void afterUpdate(List<Application__c> applications) {
        StatisticsService.updateStatistics(applications);
        NotificationService.sendNotifications(applications);
    }

}