public with sharing class NotificationService {

    public static void sendNotifications(List<Application__c> applications){

        for(Application__c app : applications){

            System.debug('Notification sent for Application : ' + app.Id);

        }

    }

}