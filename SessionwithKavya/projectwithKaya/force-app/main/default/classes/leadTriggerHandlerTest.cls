@istest
public class leadTriggerHandlerTest {
    @istest
	public static void updateUserTest(){
        user usISR = [SELECT id,name, userRole.Name FROM User Where name ='testUser'];
        user usSM = [SELECT id,name, userRole.Name FROM User Where name ='Integration User'];
        user usISS = [SELECT id,name, userRole.Name FROM User Where name ='Security User'];
        Branch_Lookup__c bl1 = new Branch_Lookup__c(name = 'bl1', zip__c = '123412', Territory__c = 'Ka', Selling_region__c = 'Bng');
        insert bl1;
        Branch_Lookup__c bl2 = new Branch_Lookup__c(name = 'bl2', zip__c = '1234123', Territory__c = 'kar', Selling_region__c = 'Bng');
        insert bl2;
        Branch_Lookup__c bl3 = new Branch_Lookup__c(name = 'bl3', zip__c = '123123', Territory__c = 'kar', Selling_region__c = 'bng');
        insert bl3;
        lead le1 = new Lead();
        le1.LastName = 'test1';
        le1.Company = 'comp1';
        le1.PostalCode = '123412';
        le1.Type__c = 'Outbound';
        insert le1;
        lead le11 = [SELECT id, OwnerId, owner.Name FROM Lead WHERE id=:le1.id];
        task ta1 = [SELECT id, WhoId,OwnerId FROM task WHERE WhoId=:le1.id];
        system.assertEquals(usISR.id, le11.Ownerid);
        system.assertEquals(usISR.id, ta1.OwnerId);
        le1.PostalCode = '1234123';
        update le1;
        lead le12 = [SELECT id, OwnerId, owner.Name FROM Lead WHERE id=:le1.id];
        task ta2 = [SELECT id, WhoId,OwnerId FROM task WHERE WhoId=:le1.id];
        system.assertEquals(usSM.id, le12.Ownerid);
        system.assertEquals(usSM.id, ta2.OwnerId);
        le1.PostalCode = '123123';
        le1.Type__c = 'Inbound';
        update le1;
        lead le13 = [SELECT id, OwnerId, owner.Name FROM Lead WHERE id=:le1.id];
        system.assertEquals(usISS.id, le13.Ownerid);
        id queueId = [SELECT Queue.id FROM Queuesobject WHERE queue.Name = 'Inbound Lead Queue' LIMIT 1].Queue.id;
        List<lead> leadList = new List<lead>();
        for(integer i=0; i<2 ; i++){
            lead le = new Lead();
            le.LastName = 'test'+i;
            le.Company = 'comp'+i;
            le.PostalCode = '123123';
            le.Type__c = 'Inbound';
            leadList.add(le);
        }
        insert leadList;
        lead le21 = [SELECT id, OwnerId FROM Lead WHERE id=:leadList[1].id];
        lead le22 = [SELECT id, OwnerId FROM Lead WHERE id=:leadList[0].id];
        system.assertEquals(queueId, le21.Ownerid);
        system.assertEquals(usISS.id, le22.OwnerId);
    }
}