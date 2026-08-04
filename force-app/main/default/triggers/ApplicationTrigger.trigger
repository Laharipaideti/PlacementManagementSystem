trigger ApplicationTrigger on Application__c (
    before insert,
    after update
) {

    if (Trigger.isBefore && Trigger.isInsert) {

        for (Application__c app : Trigger.new) {

            Student__c student =
                ApplicationService.getStudent(app.Student__c);

            Job__c job =
                ApplicationService.getJob(app.Job__c);

            if (!ApplicationService.validateEligibility(student, job)) {
                app.addError('Student is not eligible for this job.');
            }

            if (ApplicationService.checkDuplicateApplication(
                    app.Student__c,
                    app.Job__c
                )) {

                app.addError('Duplicate application is not allowed.');
            }
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {

        for (Application__c app : Trigger.new) {

            if (app.Status__c == 'Selected') {

                StatisticsService.updateStatistics();
                  NotificationService.sendNotification(app);


            }
        }

    }

}