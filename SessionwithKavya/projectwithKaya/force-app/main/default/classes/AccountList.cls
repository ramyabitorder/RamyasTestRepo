public class AccountList {
	@AuraEnabled(cacheable=true)
    public static List<Account> accList(){
        List<Account> accounts = new List<Account>();
        accounts = [SELECT id, Name, Need_Contact__c FROM Account];
        return accounts;
    }
}