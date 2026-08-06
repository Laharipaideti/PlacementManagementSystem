public with sharing class ExternalPlacementSyncJob implements Queueable {

    private Id applicationId;

    public ExternalPlacementSyncJob(Id applicationId) {
        this.applicationId = applicationId;
    }

    public void execute(QueueableContext context) {

        Application__c app = [
            SELECT Id,
                   Name,
                   Student__c,
                   Job__c,
                   Status__c
            FROM Application__c
            WHERE Id = :applicationId
            LIMIT 1
        ];

        System.debug('===== External Placement Sync Started =====');
        System.debug('Application : ' + app.Name);

        // Simulate External Sync
        System.debug('Application Synced Successfully');

        // Queue next job
        System.enqueueJob(
            new PlacementNotificationJob(applicationId)
        );

        System.debug('===== External Placement Sync Completed =====');
    }
}