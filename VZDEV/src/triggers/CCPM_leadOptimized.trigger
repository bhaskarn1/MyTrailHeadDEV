trigger CCPM_leadOptimized on Lead (before insert, before update,after insert, after update) {
   system.debug('@@@I am in CCPM_leadOptimized');
   CCPM_TriggerDispatcher.Run(new CCPM_leadTriggerHandler());
}