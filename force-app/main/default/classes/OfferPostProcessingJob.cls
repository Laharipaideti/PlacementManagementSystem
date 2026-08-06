public with sharing class OfferPostProcessingJob implements Queueable {

    private Id applicationId;

    public OfferPostProcessingJob(Id applicationId) {
        this.applicationId = applicationId;
    }

    public void execute(QueueableContext context) {

        // Retrieve latest Application
        Application__c app = [
            SELECT Id,
                   Name,
                   Status__c,
                   Student__c,
                   Job__c
            FROM Application__c
            WHERE Id = :applicationId
            LIMIT 1
        ];

        // Retrieve Student
        Student__c student = [
            SELECT Id,
                   Name
            FROM Student__c
            WHERE Id = :app.Student__c
            LIMIT 1
        ];

        // Retrieve Job
        Job__c job = [
            SELECT Id,
                   Name
            FROM Job__c
            WHERE Id = :app.Job__c
            LIMIT 1
        ];

        System.debug('===== Queueable Started =====');
        System.debug('Application : ' + app.Name);
        System.debug('Student     : ' + student.Name);
        System.debug('Job         : ' + job.Name);
        System.debug('Synchronizing with external placement system...');
        System.debug('Preparing Notifications...');
        System.debug('Updating Analytics...');

        System.debug('===== Queueable Completed =====');
    }
}