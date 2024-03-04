@istest
public class opportunityBatchTest {
	@istest
    public static void oppUserTest(){
        user usISR = [SELECT id,name, userRole.Name FROM User Where name ='testUser'];
        user usSM = [SELECT id,name, userRole.Name FROM User Where name ='Integration User'];
        Branch_Lookup__c bl1 = new Branch_Lookup__c(name = 'bl1', zip__c = '123412', Territory__c = 'Ka', Selling_region__c = 'Bng');
        insert bl1;
        Branch_Lookup__c bl2 = new Branch_Lookup__c(name = 'bl2', zip__c = '1234123', Territory__c = 'kar', Selling_region__c = 'Bng');
        insert bl2;
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'test1';
        opp1.StageName = 'Proposal/Price Quote';
        opp1.zip__c = '123412';
        opp1.CloseDate = system.today()+15;
        insert opp1;
        task ta1 = new task();
        ta1.Subject = 'Call';
        ta1.ActivityDate = system.today()+5;
        ta1.WhatId = opp1.id;
        insert ta1;
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test2';
        opp2.StageName = 'Proposal/Price Quote';
        opp2.zip__c = '1234123';
        opp2.CloseDate = system.today()+15;
        insert opp2;
        task ta2 = new task();
        ta2.Subject = 'Call';
        ta2.ActivityDate = system.today()+5;
        ta2.WhatId = opp2.id;
        insert ta2;
        test.startTest();
        database.executeBatch(new opportunityBatchApex());
        test.stopTest();
        opportunity opp11 = [SELECT id, OwnerId FROM Opportunity WHERE id = :opp1.id];
        system.assertEquals(usISR.id, opp11.OwnerId);
        task ta11 = [SELECT id, OwnerId FROM Task WHERE WhatId = : opp1.id];
        system.assertEquals(usISR.id, ta11.OwnerId);
        opportunity opp21 = [SELECT id, OwnerId FROM Opportunity WHERE id = :opp2.id];
        system.assertEquals(usSM.id, opp21.OwnerId);
        task ta21 = [SELECT id, OwnerId FROM Task WHERE WhatId = : opp2.id];
        system.assertEquals(usSM.id, ta21.OwnerId);
    }
}