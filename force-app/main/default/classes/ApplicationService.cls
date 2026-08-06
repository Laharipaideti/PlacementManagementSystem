public with sharing class ApplicationService {
    public static Student__c getStudent(Id studentId) {

        return [
            SELECT Id,
                   Name,
                   CGPA__c,
                   Branch__c,
                   Backlogs__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];
    }
    public static Job__c getJob(Id jobId) {
        

        return [
            SELECT Id,
                   Name,
                   Minimum_CGPA__c,
                   Eligible_Branches__c,
                   Application_Deadline__c
            FROM Job__c
            WHERE Id = :jobId
            LIMIT 1
        ];
    }
    public static Boolean checkDuplicateApplication(Id studentId, Id jobId) {

        List<Application__c> apps = [

            SELECT Id
            FROM Application__c
            WHERE Student__c = :studentId
            AND Job__c = :jobId
            LIMIT 1

        ];

        return !apps.isEmpty();
    }
    public static Boolean validateEligibility(Student__c student,
                                              Job__c job) {

        if(student.CGPA__c < job.Minimum_CGPA__c){
            return false;
        }

        if(job.Application_Deadline__c < Date.today()){
            return false;
        }

        return true;
    }
    public static String createApplication(Id studentId,
                                           Id jobId) {

        Student__c student = getStudent(studentId);

        Job__c job = getJob(jobId);


        if(checkDuplicateApplication(studentId, jobId)){
            return 'Duplicate Application';
        }


        if(!validateEligibility(student, job)){
            return 'Student Not Eligible';
        }


        Application__c app = new Application__c();

        app.Student__c = studentId;
        app.Job__c = jobId;
        app.Status__c = 'Applied';
        app.Application_Date__c = Date.today();

        insert app;

        return 'Application Submitted Successfully';
    }
    public static String updateApplicationStatus(Id applicationId, String status){

        Application__c app = [

            SELECT Id,
                   Status__c
            FROM Application__c
            WHERE Id = :applicationId
            LIMIT 1

        ];

        app.Status__c = status;

        update app;

        return 'Application Status Updated Successfully';
    }
public static void validateApplications(List<Application__c> applications) {

    System.debug('Applications received: ' + applications.size());

    Set<Id> studentIds = new Set<Id>();

    for (Application__c app : applications) {
        studentIds.add(app.Student__c);
    }

    System.debug('Student IDs: ' + studentIds);

    Map<Id, Student__c> studentMap = new Map<Id, Student__c>([
        SELECT Id, Name, CGPA__c
        FROM Student__c
        WHERE Id IN :studentIds
    ]);

    System.debug('Students found: ' + studentMap.size());

    for (Application__c app : applications) {
        Student__c student = studentMap.get(app.Student__c);

        if (student != null) {
            System.debug('Student Name: ' + student.Name);
        }
    }
}
}