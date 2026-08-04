public with sharing class NotificationService {

    public static void sendNotification(Application__c app){

        System.debug('Notification sent for Application : ' + app.Id);

    }

}