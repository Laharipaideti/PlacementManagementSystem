public with sharing class EligibleJobsController {

    @AuraEnabled(cacheable=true)
    public static List<Job__c> getEligibleJobs() {

        return [
            SELECT Id,
                   Name,
                   Minimum_cgpa__c,
                   Eligible_branches__c,
                   Last_date__c,
                   Application_deadline__c
            FROM Job__c
            ORDER BY Application_deadline__c ASC
        ];
    }


    @AuraEnabled
    public static Id submitApplication(Id studentId, Id jobId) {

        if (studentId == null) {
            throw new AuraHandledException(
                'Student ID is required.'
            );
        }

        if (jobId == null) {
            throw new AuraHandledException(
                'Job ID is required.'
            );
        }

        Application__c applicationRecord =
            new Application__c();

        applicationRecord.Student__c = studentId;
        applicationRecord.Job__c = jobId;
        applicationRecord.Status__c = 'Applied';
        applicationRecord.Application_Date__c =
            Date.today();

        insert applicationRecord;

        return applicationRecord.Id;
    }
}