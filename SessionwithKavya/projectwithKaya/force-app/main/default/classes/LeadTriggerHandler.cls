public class LeadTriggerHandler {
    public static void updateUserOnInsert(List<Lead> newList){
        set<string> outZips = new set<string>();
        set<string> inZips = new set<string>();
        List<Lead> outLead = new list<Lead>();
        List<Lead> inLead = new list<Lead>();
        if(!newList.isEmpty())
        for(Lead le : newList){
            if(le.Type__c == 'Outbound' && le.postalcode!=null){
                outZips.add(le.postalcode);
                outLead.add(le);
            }
            else if(le.Type__c == 'Inbound' && le.postalcode!=null){
                inZips.add(le.postalcode);
                inLead.add(le);
            }
        }
        updateuser(outZips,outLead,inZips,inLead);
    }
    public static void updateUserOnUpdate(List<Lead> newList, map<id,lead> oldmap){
        set<string> outZips = new set<string>();
        set<string> inZips = new set<string>();
        List<Lead> outLead = new list<Lead>();
        List<Lead> inLead = new list<Lead>();
        if(!newList.isEmpty())
            for(Lead le : newList){
                if(le.Type__c!=oldmap.get(le.id).Type__c || le.PostalCode!=oldmap.get(le.id).Postalcode){
                    if(le.Type__c == 'Outbound' && le.postalcode!=null){
                        outZips.add(le.postalcode);
                        outLead.add(le);
                    }
                    else if(le.Type__c == 'Inbound' && le.postalcode!=null){
                        inZips.add(le.postalcode);
                        inLead.add(le);
                    }
                }
                updateuser(outZips,outLead,inZips,inLead);
            }
    }
    public static void updateUser(set<string> outZips, list<lead> outLead, set<string> inZips, List<Lead> inLead){
        map<string,string> outziptoterritory = new map<string,string>();
        map<string,string> outziptoSellingRegion = new map<string,string>();
        list<Branch_Lookup__c> outbLList = [SELECT id, territory__c, selling_region__c, zip__c FROM Branch_Lookup__c WHERE zip__c IN : outZips];
        for(Branch_Lookup__c bL : outbLList){
            outziptoterritory.put(bL.zip__c,bL.territory__c);
            outziptoSellingRegion.put(bL.zip__c,bL.Selling_Region__c);
        }
        map<string,user> terrToISPUser = new map<string,user>();
        map<string,user> terrToSMUser = new map<string,user>();
        List<User> InsideSalesRepList = [SELECT id, Territory__c FROM User WHERE territory__c IN : outziptoterritory.values() AND UserRole.Name = 'Inside Sales Rep' AND Available_for_Leads__c = true];
        List<User> SalesManagerList = [SELECT id, Selling_region__c FROM User WHERE Selling_Region__c IN : outziptoSellingRegion.values() AND UserRole.Name = 'Sales Manager'];
        for(user us : InsideSalesRepList){
            terrToISPUser.put(us.Territory__c,us);
        }
        for(user us : SalesManagerList){
            terrToSMUser.put(us.Selling_Region__c,us);
        }
        for(Lead le : outLead){
            string terr = outziptoterritory.get(le.PostalCode);
            string sell = outziptoSellingRegion.get(le.PostalCode);
            if(terrToISPUser.containsKey(terr)){
                le.ownerId = terrToISPUser.get(terr).id;
            }
            else{
                if(terrToSMUser.containskey(sell)){
                    le.OwnerId = terrToSMUser.get(sell).id;
                }
            }
        }
        
        map<string,string> inziptoterritory = new map<string,string>();
        list<Branch_Lookup__c> inbLList = [SELECT id, territory__c, zip__c FROM Branch_Lookup__c WHERE zip__c IN : inZips];
        for(Branch_Lookup__c bL : inbLList){
            inziptoterritory.put(bL.zip__c,bL.territory__c);
        }
        map<string,user> terrToISSUser = new map<string,user>();
        List<User> InboundSalesSpecialistList = [SELECT id, Territory__c FROM User WHERE territory__c IN : Inziptoterritory.values() AND UserRole.Name = 'Inbound Sales Specialist' AND Available_for_Leads__c = true];
        for(user us : InboundSalesSpecialistList){
            terrToISSUser.put(us.Territory__c,us);
        }
        set<id> userlist = new set<id>();
        id queueId = [SELECT Queue.id FROM Queuesobject WHERE queue.Name = 'Inbound Lead Queue' LIMIT 1].Queue.id;
        for(Lead le : inLead){
            string terr = inziptoterritory.get(le.PostalCode);
            if(terr!=null && terrToISSUser.containskey(terr) && !userList.contains(terrToISSUser.get(terr).id)){
                le.ownerId = terrToISSUser.get(terr).id;
                userList.add(terrToISSUser.get(terr).id);
            }
            else if(terr!=null && terrToISSUser.containskey(terr) && userList.contains(terrToISSUser.get(terr).id))
                le.OwnerId = queueId;
        }
    }
    public static void taskCreationOnInsert(List<Lead> newList){
        List<task> taskList = new list<Task>();
        for(lead le : newList){
            task ta = new task();
            ta.ownerId = le.OwnerId;
            ta.Subject = 'Call';
            ta.ActivityDate = system.today() + 15;
            ta.WhoId = le.id;
            taskList.add(ta);
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    
    public static void taskCreationOnUpdate(List<Lead> newList, map<id,lead> oldmap){
        List<task> taskList = new list<Task>();
        List<lead> leadList = new list<Lead>();
        list<id> leadIds = new list<id>();
        for(lead le : newList){
            if(le.OwnerId!=oldmap.get(le.id).ownerId && le.OwnerId!=null){
                leadIds.add(le.id);
                leadList.add(le);
            }
        }
        map<id,task> idToTask = new map<id,task>([SELECT id, WhoId, ownerId FROM Task WHERE WhoId In : leadIds]);
        for(lead le : leadList){
            for(task ta : idToTask.values()){
                if(ta.WhoId == le.id){
                    ta.OwnerId = le.OwnerId;
                    TaskList.add(ta);
                }
            }           
        }
        if(!taskList.isEmpty()){
            update taskList;
        }
    }
}