public class opportunityBatchApex implements Database.Batchable <sObject>{
    public database.QueryLocator start(database.BatchableContext bc){
        return database.getQueryLocator([SELECT id, OwnerId, Zip__c FROM Opportunity WHERE StageName = 'Proposal/Price Quote']);
    }
    public void execute(database.BatchableContext bc, List<Opportunity> oppList){
        list<id> oppIds = new list<id>();
        set<string> zips = new set<string>();
        for(Opportunity opp : oppList){
            zips.add(opp.Zip__c);
            oppIds.add(opp.id);
        }
        map<string,string> ziptoterritory = new map<string,string>();
        map<string,string> ziptoSellingRegion = new map<string,string>();
        list<Branch_Lookup__c> bLList = [SELECT id, territory__c, selling_region__c, zip__c FROM Branch_Lookup__c WHERE zip__c IN : zips];
        for(Branch_Lookup__c bL : bLList){
            ziptoterritory.put(bL.zip__c,bL.territory__c);
            ziptoSellingRegion.put(bL.zip__c,bL.Selling_Region__c);
        }
        map<string,user> terrToISPUser = new map<string,user>();
        map<string,user> terrToSMUser = new map<string,user>();
        List<User> InsideSalesRepList = [SELECT id, Territory__c FROM User WHERE territory__c IN : ziptoterritory.values() AND UserRole.Name = 'Inside Sales Rep' AND Available_for_Leads__c = true];
        List<User> SalesManagerList = [SELECT id, Selling_region__c FROM User WHERE Selling_Region__c IN : ziptoSellingRegion.values() AND UserRole.Name = 'Sales Manager'];
        for(user us : InsideSalesRepList){
            terrToISPUser.put(us.Territory__c,us);
        }
        for(user us : SalesManagerList){
            terrToSMUser.put(us.Selling_Region__c,us);
        }
        List<task> taskList = new list<Task>();
        map<id,task> idToTask = new map<id,task>([SELECT id, WhatId, ownerId FROM Task WHERE WhatId In : oppIds]);
        for(opportunity opp : oppList){
            Boolean check = false;
            string terr = ziptoterritory.get(opp.Zip__c);
            string sell = ziptoSellingRegion.get(opp.Zip__c);
            if(terrToISPUser.containsKey(terr)){
                opp.ownerId = terrToISPUser.get(terr).id;
                check = true;
            }
            else{
                if(terrToSMUser.containskey(sell)){
                    opp.OwnerId = terrToSMUser.get(sell).id;
                    check = true;
                }
            }
            if(check==true){
            for(task ta : idToTask.values()){
                if(ta.WhatId == opp.id){
                    ta.OwnerId = opp.OwnerId;
                    TaskList.add(ta);
                }
            }
            }
        }
        if(!oppList.isEmpty()){
            update oppList;
        }
        if(!TaskList.isEmpty()){
            update TaskList;
        }
    }
    public void finish(database.BatchableContext bc){
        
    }
}