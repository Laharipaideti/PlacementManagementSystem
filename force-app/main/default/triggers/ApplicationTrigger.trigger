trigger ApplicationTrigger on Application__c (
    before insert,
    after update
) {

    if (Trigger.isBefore && Trigger.isInsert) {
        ApplicationTriggerHandler.beforeInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        ApplicationTriggerHandler.afterUpdate(Trigger.new);
    }
}