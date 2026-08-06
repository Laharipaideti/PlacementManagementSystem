public with sharing class PlacementCategoryBatch
implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator(
    'SELECT Id, Name, Status__c FROM Application__c'
);
    }

    public void execute(Database.BatchableContext bc,
                        List<Application__c> scope){

        for(Application__c app : scope){

            if(app.Status__c == 'Selected'){
                System.debug(app.Name + ' is Placed');
            }
            else{
                System.debug(app.Name + ' is Not Placed');
            }

        }

    }

    public void finish(Database.BatchableContext bc){

        System.debug('Batch Completed Successfully');

    }
}