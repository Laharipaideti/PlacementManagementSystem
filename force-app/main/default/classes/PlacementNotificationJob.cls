public with sharing class PlacementNotificationJob implements Queueable {

    private Id applicationId;

    public PlacementNotificationJob(Id applicationId) {
        this.applicationId = applicationId;
    }

    public void execute(QueueableContext context) {

        Application__c app = [
            SELECT Id,
                   Name,
                   Status__c,
                   Student__r.Name,
                   Job__r.Name
            FROM Application__c
            WHERE Id = :applicationId
            LIMIT 1
        ];

        System.debug('===== Placement Notification Job Started =====');

        System.debug('Application : ' + app.Name);
        System.debug('Student : ' + app.Student__r.Name);
        System.debug('Job : ' + app.Job__r.Name);
        System.debug('Status : ' + app.Status__c);

        // Simulate sending notification
        System.debug('Notification sent successfully.');

        System.debug('===== Placement Notification Job Completed =====');
    }
}