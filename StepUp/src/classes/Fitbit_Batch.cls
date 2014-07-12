global with sharing class Fitbit_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private Integer dayCount = 3;
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
       List<id> userIds = new List<Id>();
       OAuth oa = new OAuth();
       for (User u : oa.getUsersOfService())
           userIds.add(u.id);
       return Database.getQueryLocator([SELECT id FROM User WHERE id =: userIds]);
    }
    
    global void execute(Database.BatchableContext BC,List<User> lstUsers) 
    {
        for (User u : lstUsers)
            Fitbit_Callout.fitbitCallout(u.id, dayCount);
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}