trigger LeadTrigger on Lead (before insert,before update, after insert, after update){
    if(trigger.isBefore){
        if(trigger.isInsert){
            LeadTriggerHandler.updateUserOnInsert(trigger.new);
        }
        if(trigger.isUpdate){
            LeadTriggerHandler.updateUserOnUpdate(trigger.new,trigger.oldmap);
        }
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            LeadTriggerHandler.taskCreationOnInsert(trigger.new);
        }
        if(trigger.isUpdate){
            LeadTriggerHandler.taskCreationOnUpdate(trigger.new, trigger.oldmap);
        }
    }
}