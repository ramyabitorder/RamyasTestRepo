public class opportunitybatchSchedule implements schedulable{
	public void execute(SchedulableContext sc){
        opportunityBatchApex oBA = new opportunityBatchApex();
        Database.executeBatch(oBA);
    }
}