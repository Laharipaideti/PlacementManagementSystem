public with sharing class ApplicationService {

    // ============================================================
    // GET ELIGIBLE JOBS
    // ============================================================

    public static List<Job__c> getEligibleJobs(Id studentId) {

        if (studentId == null) {
            throw new AuraHandledException(
                'Student Id is required.'
            );
        }

        Student__c student = [
            SELECT Id,
                   Name,
                   CGPA__c,
                   Branch__c,
                   Backlogs__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];

        if (student.CGPA__c == null) {
            return new List<Job__c>();
        }

        if (student.Branch__c == null) {
            return new List<Job__c>();
        }

        if (
            student.Backlogs__c != null &&
            student.Backlogs__c > 0
        ) {
            return new List<Job__c>();
        }


        List<Job__c> allJobs = [
            SELECT Id,
                   Name,
                   Minimum_cgpa__c,
                   Eligible_branches__c,
                   Last_date__c,
                   Application_deadline__c
            FROM Job__c
            WHERE Last_date__c >= :Date.today()
            ORDER BY Last_date__c ASC
        ];


        List<Job__c> eligibleJobs =
            new List<Job__c>();


        for (Job__c job : allJobs) {

            // -----------------------------
            // CGPA CHECK
            // -----------------------------

            if (
                job.Minimum_cgpa__c != null &&
                student.CGPA__c < job.Minimum_cgpa__c
            ) {
                continue;
            }


            // -----------------------------
            // BRANCH CHECK
            // -----------------------------

            Boolean branchEligible = false;

            if (
                job.Eligible_branches__c == null ||
                job.Eligible_branches__c.trim() == ''
            ) {

                branchEligible = true;

            } else {

                List<String> branches =
                    job.Eligible_branches__c.split(';');

                for (String branch : branches) {

                    if (
                        branch != null &&
                        branch.trim().equalsIgnoreCase(
                            student.Branch__c.trim()
                        )
                    ) {

                        branchEligible = true;
                        break;
                    }
                }
            }


            if (!branchEligible) {
                continue;
            }


            // -----------------------------
            // APPLICATION DEADLINE CHECK
            // -----------------------------

            if (
                job.Application_deadline__c != null &&
                job.Application_deadline__c < Date.today()
            ) {
                continue;
            }


            eligibleJobs.add(job);
        }


        return eligibleJobs;
    }


    // ============================================================
    // CREATE APPLICATION
    // ============================================================

    public static Id createApplication(
        Id studentId,
        Id jobId
    ) {

        if (studentId == null) {
            throw new AuraHandledException(
                'Student Id is required.'
            );
        }

        if (jobId == null) {
            throw new AuraHandledException(
                'Job Id is required.'
            );
        }


        // -----------------------------
        // GET STUDENT
        // -----------------------------

        Student__c student = [
            SELECT Id,
                   Name,
                   CGPA__c,
                   Branch__c,
                   Backlogs__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];


        // -----------------------------
        // GET JOB
        // -----------------------------

        Job__c job = [
            SELECT Id,
                   Name,
                   Minimum_cgpa__c,
                   Eligible_branches__c,
                   Last_date__c,
                   Application_deadline__c
            FROM Job__c
            WHERE Id = :jobId
            LIMIT 1
        ];


        // -----------------------------
        // DUPLICATE CHECK
        // -----------------------------

        List<Application__c> existingApplications = [
            SELECT Id,
                   Name,
                   student__c,
                   Job__c
            FROM Application__c
            WHERE student__c = :studentId
            AND Job__c = :jobId
            LIMIT 1
        ];


        if (!existingApplications.isEmpty()) {

            throw new AuraHandledException(
                'You have already applied for this job.'
            );
        }


        // -----------------------------
        // CGPA CHECK
        // -----------------------------

        if (
            student.CGPA__c == null ||
            job.Minimum_cgpa__c == null
        ) {

            throw new AuraHandledException(
                'CGPA information is missing.'
            );
        }


        if (
            student.CGPA__c <
            job.Minimum_cgpa__c
        ) {

            throw new AuraHandledException(
                'You are not eligible based on CGPA.'
            );
        }


        // -----------------------------
        // BRANCH CHECK
        // -----------------------------

        Boolean branchEligible = false;


        if (
            job.Eligible_branches__c == null ||
            job.Eligible_branches__c.trim() == ''
        ) {

            branchEligible = true;

        } else {

            List<String> branches =
                job.Eligible_branches__c.split(';');


            for (String branch : branches) {

                if (
                    branch != null &&
                    student.Branch__c != null &&
                    branch.trim().equalsIgnoreCase(
                        student.Branch__c.trim()
                    )
                ) {

                    branchEligible = true;
                    break;
                }
            }
        }


        if (!branchEligible) {

            throw new AuraHandledException(
                'You are not eligible for this job based on your branch.'
            );
        }


        // -----------------------------
        // BACKLOG CHECK
        // -----------------------------

        if (
            student.Backlogs__c != null &&
            student.Backlogs__c > 0
        ) {

            throw new AuraHandledException(
                'You cannot apply because you have active backlogs.'
            );
        }


        // -----------------------------
        // LAST DATE CHECK
        // -----------------------------

        if (
            job.Last_date__c != null &&
            job.Last_date__c < Date.today()
        ) {

            throw new AuraHandledException(
                'The job application last date has expired.'
            );
        }


        // -----------------------------
        // APPLICATION DEADLINE CHECK
        // -----------------------------

        if (
            job.Application_deadline__c != null &&
            job.Application_deadline__c < Date.today()
        ) {

            throw new AuraHandledException(
                'The application deadline has expired.'
            );
        }


        // -----------------------------
        // CREATE APPLICATION
        // -----------------------------

        Application__c application =
            new Application__c();

        application.student__c =
            studentId;

        application.Job__c =
            jobId;

        application.Status__c =
            'Applied';

        application.Application_Date__c =
            Date.today();


        insert application;


        return application.Id;
    }


    // ============================================================
    // SUBMIT APPLICATION
    // ============================================================

    public static Id submitApplication(
        Id studentId,
        Id jobId
    ) {

        return createApplication(
            studentId,
            jobId
        );
    }


    // ============================================================
    // UPDATE APPLICATION STATUS
    // ============================================================

    public static String updateApplicationStatus(
        Id applicationId,
        String status
    ) {

        if (applicationId == null) {

            throw new AuraHandledException(
                'Application Id is required.'
            );
        }


        if (
            status == null ||
            status.trim() == ''
        ) {

            throw new AuraHandledException(
                'Application status is required.'
            );
        }


        Application__c application = [
            SELECT Id,
                   Status__c
            FROM Application__c
            WHERE Id = :applicationId
            LIMIT 1
        ];


        application.Status__c =
            status;


        update application;


        return 'Application Status Updated Successfully';
    }


    // ============================================================
    // VALIDATE APPLICATIONS
    // ============================================================

    public static void validateApplications(
        List<Application__c> applications
    ) {

        if (
            applications == null ||
            applications.isEmpty()
        ) {
            return;
        }


        // ========================================================
        // COLLECT STUDENT IDS AND JOB IDS
        // ========================================================

        Set<Id> studentIds =
            new Set<Id>();

        Set<Id> jobIds =
            new Set<Id>();


        for (
            Application__c application :
            applications
        ) {

            if (
                application.student__c != null
            ) {

                studentIds.add(
                    application.student__c
                );
            }


            if (
                application.Job__c != null
            ) {

                jobIds.add(
                    application.Job__c
                );
            }
        }


        // ========================================================
        // QUERY STUDENTS ONCE
        // ========================================================

        Map<Id, Student__c> studentsById =
            new Map<Id, Student__c>();


        if (!studentIds.isEmpty()) {

            studentsById =
                new Map<Id, Student__c>([
                    SELECT Id,
                           Name,
                           CGPA__c,
                           Branch__c,
                           Backlogs__c
                    FROM Student__c
                    WHERE Id IN :studentIds
                ]);
        }


        // ========================================================
        // QUERY JOBS ONCE
        // ========================================================

        Map<Id, Job__c> jobsById =
            new Map<Id, Job__c>();


        if (!jobIds.isEmpty()) {

            jobsById =
                new Map<Id, Job__c>([
                    SELECT Id,
                           Name,
                           Minimum_cgpa__c,
                           Eligible_branches__c,
                           Last_date__c,
                           Application_deadline__c
                    FROM Job__c
                    WHERE Id IN :jobIds
                ]);
        }


        // ========================================================
        // DUPLICATE CHECK
        // ========================================================

        Set<Id> existingStudentIds =
            new Set<Id>();

        Set<Id> existingJobIds =
            new Set<Id>();


        if (
            !studentIds.isEmpty() &&
            !jobIds.isEmpty()
        ) {

            for (
                Application__c existingApplication :
                [
                    SELECT Id,
                           student__c,
                           Job__c
                    FROM Application__c
                    WHERE student__c IN :studentIds
                    AND Job__c IN :jobIds
                ]
            ) {

                if (
                    existingApplication.student__c != null
                ) {

                    existingStudentIds.add(
                        existingApplication.student__c
                    );
                }


                if (
                    existingApplication.Job__c != null
                ) {

                    existingJobIds.add(
                        existingApplication.Job__c
                    );
                }
            }
        }


        // ========================================================
        // VALIDATE APPLICATIONS
        // ========================================================

        Set<String> currentTransactionPairs =
            new Set<String>();


        for (
            Application__c application :
            applications
        ) {

            // -----------------------------------------------
            // STUDENT REQUIRED
            // -----------------------------------------------

            if (
                application.student__c == null
            ) {

                application.addError(
                    'Student is required.'
                );

                continue;
            }


            // -----------------------------------------------
            // JOB REQUIRED
            // -----------------------------------------------

            if (
                application.Job__c == null
            ) {

                application.addError(
                    'Job is required.'
                );

                continue;
            }


            Student__c student =
                studentsById.get(
                    application.student__c
                );


            Job__c job =
                jobsById.get(
                    application.Job__c
                );


            // -----------------------------------------------
            // STUDENT FOUND
            // -----------------------------------------------

            if (student == null) {

                application.addError(
                    'Student record not found.'
                );

                continue;
            }


            // -----------------------------------------------
            // JOB FOUND
            // -----------------------------------------------

            if (job == null) {

                application.addError(
                    'Job record not found.'
                );

                continue;
            }


            // -----------------------------------------------
            // DUPLICATE IN DATABASE
            // -----------------------------------------------

            String pairKey =
                String.valueOf(
                    application.student__c
                ) +
                '-' +
                String.valueOf(
                    application.Job__c
                );


            if (
                existingStudentIds.contains(
                    application.student__c
                ) &&
                existingJobIds.contains(
                    application.Job__c
                )
            ) {

                application.addError(
                    'Student has already applied for this job.'
                );

                continue;
            }


            // -----------------------------------------------
            // DUPLICATE IN SAME TRANSACTION
            // -----------------------------------------------

            if (
                currentTransactionPairs.contains(
                    pairKey
                )
            ) {

                application.addError(
                    'Duplicate application detected.'
                );

                continue;
            }


            currentTransactionPairs.add(
                pairKey
            );


            // -----------------------------------------------
            // CGPA
            // -----------------------------------------------

            if (
                student.CGPA__c == null
            ) {

                application.addError(
                    'Student CGPA is missing.'
                );

                continue;
            }


            if (
                job.Minimum_cgpa__c != null &&
                student.CGPA__c <
                job.Minimum_cgpa__c
            ) {

                application.addError(
                    'Student is not eligible based on CGPA.'
                );

                continue;
            }


            // -----------------------------------------------
            // BRANCH
            // -----------------------------------------------

            Boolean branchEligible =
                false;


            if (
                job.Eligible_branches__c == null ||
                job.Eligible_branches__c.trim() == ''
            ) {

                branchEligible = true;

            } else if (
                student.Branch__c != null
            ) {

                List<String> branches =
                    job.Eligible_branches__c.split(';');


                for (
                    String branch :
                    branches
                ) {

                    if (
                        branch != null &&
                        branch.trim().equalsIgnoreCase(
                            student.Branch__c.trim()
                        )
                    ) {

                        branchEligible = true;
                        break;
                    }
                }
            }


            if (!branchEligible) {

                application.addError(
                    'Student is not eligible for this branch.'
                );

                continue;
            }


            // -----------------------------------------------
            // BACKLOGS
            // -----------------------------------------------

            if (
                student.Backlogs__c != null &&
                student.Backlogs__c > 0
            ) {

                application.addError(
                    'Student has active backlogs.'
                );

                continue;
            }


            // -----------------------------------------------
            // LAST DATE
            // -----------------------------------------------

            if (
                job.Last_date__c != null &&
                job.Last_date__c < Date.today()
            ) {

                application.addError(
                    'Job application last date has expired.'
                );

                continue;
            }


            // -----------------------------------------------
            // APPLICATION DEADLINE
            // -----------------------------------------------

            if (
                job.Application_deadline__c != null &&
                job.Application_deadline__c < Date.today()
            ) {

                application.addError(
                    'Application deadline has expired.'
                );

                continue;
            }


            // -----------------------------------------------
            // DEFAULT STATUS
            // -----------------------------------------------

            if (
                application.Status__c == null ||
                application.Status__c.trim() == ''
            ) {

                application.Status__c =
                    'Applied';
            }


            // -----------------------------------------------
            // DEFAULT APPLICATION DATE
            // -----------------------------------------------

            if (
                application.Application_Date__c == null
            ) {

                application.Application_Date__c =
                    Date.today();
            }
        }
    }
}