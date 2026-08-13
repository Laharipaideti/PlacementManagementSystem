public with sharing class ApplicationTriggerHandler {

    public static void handleAfter(
        List<Application__c> newApplications,
        Map<Id, Application__c> oldApplicationMap,
        Boolean isInsert,
        Boolean isUpdate
    ) {

        Set<Id> applicationIds =
            new Set<Id>();


        for (
            Application__c applicationRecord :
            newApplications
        ) {

            /*
             * INSERT
             *
             * If an application is created directly
             * with Selected status, synchronize it.
             */
            if (isInsert) {

                if (
                    applicationRecord.Status__c ==
                    'Selected'
                ) {

                    applicationIds.add(
                        applicationRecord.Id
                    );
                }

                continue;
            }


            /*
             * UPDATE
             *
             * Only enqueue when status changes
             * TO Selected.
             */
            if (isUpdate) {

                Application__c oldApplication =
                    oldApplicationMap.get(
                        applicationRecord.Id
                    );


                Boolean changedToSelected =
                    applicationRecord.Status__c ==
                    'Selected'
                    &&
                    (
                        oldApplication == null
                        ||
                        oldApplication.Status__c !=
                        'Selected'
                    );


                if (changedToSelected) {

                    applicationIds.add(
                        applicationRecord.Id
                    );
                }
            }
        }


        /*
         * Enqueue one Queueable per Application.
         *
         * This keeps the Queueable responsible for
         * the actual external API callout.
         */
        for (
            Id applicationId :
            applicationIds
        ) {

            System.enqueueJob(
                new CandidateSyncQueueable(
                    applicationId
                )
            );
        }
    }
}