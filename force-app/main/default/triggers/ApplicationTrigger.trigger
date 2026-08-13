trigger ApplicationTrigger on Application__c (
    after insert,
    after update
) {

    ApplicationTriggerHandler.handleAfter(
        Trigger.new,
        Trigger.oldMap,
        Trigger.isInsert,
        Trigger.isUpdate
    );
}