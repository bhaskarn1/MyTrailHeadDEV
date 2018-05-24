trigger CCPM_task on Task (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
 
    CCPM_TriggerDispatcher.Run(new CCPM_taskTriggerHandler());
}