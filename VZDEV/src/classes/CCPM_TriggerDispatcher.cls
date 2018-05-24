/**
*@name          CCPM_TriggerDispatcher 
*@author        Bharath Ammanamanchi (Deloitte)
*@date          10/05/2017
*@description   The dispatcher is responsible for making sure all of the applicable methods on your trigger handler are called, 
				depending on the current trigger context
*@Class         CCPM_TriggerDispatcher
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Bharath Ammanamanchi (Deloitte)    10/05/2017   Initial Implementation.
*/
public class CCPM_TriggerDispatcher  {
    
    /**
	@author       Bharath Ammanamanchi (Deloitte)
	@description  Call this method from trigger, passing in an instance of a trigger handler which implements CCPM_ITriggerHandler.
        			This method will fire the appropriate methods on the handler depending on the trigger context.
	@param        N/A
	@return       Void(None)
	*/ 
    public static void Run(CCPM_ITriggerHandler handler)
    {
        // Check to see if the trigger has been disabled. If it has, return
        if (handler.IsDisabled())
            return;
             
        // Detect the current trigger context and fire the relevant methods on the trigger handler:
 
        // Before trigger logic
        if (Trigger.IsBefore )
        {
            if (Trigger.IsInsert)
                handler.BeforeInsert(trigger.new);
 
            if (Trigger.IsUpdate)
                handler.BeforeUpdate(trigger.newMap, trigger.oldMap);
 
            if (Trigger.IsDelete)
                handler.BeforeDelete(trigger.oldMap);
        }
         
        // After trigger logic
        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert)
                handler.AfterInsert(Trigger.newMap);
 
            if (Trigger.IsUpdate)
                handler.AfterUpdate(trigger.newMap, trigger.oldMap);
 
            if (Trigger.IsDelete)
                handler.AfterDelete(trigger.oldMap);
 
            if (Trigger.isUndelete)
                handler.AfterUndelete(trigger.oldMap);
        }
    }
}