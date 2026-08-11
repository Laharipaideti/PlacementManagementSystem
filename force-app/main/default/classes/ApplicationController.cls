public with sharing class ApplicationController {

    // ============================================================
    // GET ELIGIBLE JOBS
    // ============================================================

    @AuraEnabled(cacheable=true)
    public static List<Job__c> getEligibleJobs(
        Id studentId
    ) {

        try {

            return ApplicationService.getEligibleJobs(
                studentId
            );

        } catch (Exception e) {

            throw new AuraHandledException(
                e.getMessage()
            );
        }
    }


    // ============================================================
    // SUBMIT APPLICATION
    // ============================================================

    @AuraEnabled
    public static Id submitApplication(
        Id studentId,
        Id jobId
    ) {

        try {

            return ApplicationService.submitApplication(
                studentId,
                jobId
            );

        } catch (Exception e) {

            throw new AuraHandledException(
                e.getMessage()
            );
        }
    }


    // ============================================================
    // GET MY APPLICATIONS
    // ============================================================

    @AuraEnabled(cacheable=true)
    public static List<Application__c> getMyApplications(
        Id studentId
    ) {

        if (studentId == null) {

            throw new AuraHandledException(
                'Student Id is required.'
            );
        }


        return [
            SELECT Id,
                   Name,
                   student__c,
                   Job__c,
                   Job__r.Name,
                   Status__c,
                   Application_Date__c
            FROM Application__c
            WHERE student__c = :studentId
            ORDER BY Application_Date__c DESC
        ];
    }


    // ============================================================
    // UPDATE APPLICATION STATUS
    // ============================================================

    @AuraEnabled
    public static String updateApplicationStatus(
        Id applicationId,
        String status
    ) {

        try {

            return ApplicationService.updateApplicationStatus(
                applicationId,
                status
            );

        } catch (Exception e) {

            throw new AuraHandledException(
                e.getMessage()
            );
        }
    }
}