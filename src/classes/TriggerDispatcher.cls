public with sharing class TriggerDispatcher {

    public static ITriggerEntry activeFunction = null;

    public static AppConfig__c triggerDispatcherConfig {
        get {
            AppConfig__c setting = AppConfig__c.getInstance('TriggerDispatcher');
            if (setting == null) {
                setting = new AppConfig__c(Name = 'TriggerDispatcher', IsEnabled__c = true);
                insert setting;
            }
            return setting;
        }
        private set;
    }

    public interface ITriggerEntry {
        void mainEntry( List<SObject> newObjList, Map<ID, SObject> newObjMap, List<SObject> oldObjList, Map<ID,SObject> oldObjMap);
        void inProgressEntry( List<SObject> newObjList, Map<ID, SObject> newObjMap, List<SObject> oldObjList, Map<ID,SObject> oldObjMap);
    }

    public static void handleTriggers(TriggerOperation triggerType, List<SObject> newObjList,
            Map<ID, SObject> newObjMap, List<SObject> oldObjList,
            Map<ID,SObject> oldObjMap)
    {

        if (!triggerDispatcherConfig.IsEnabled__c) {
            SystemLogger.log(LoggingLevel.INFO, 'Triggers are disabled.');
        } else {
            SObject firstObject =
                    (triggerType == TriggerOperation.AFTER_DELETE || triggerType == TriggerOperation.BEFORE_DELETE) ?
                    oldObjList[0]: newObjList[0];

            if (activeFunction!=null) {
                // Active function always gets all triggers
                activeFunction.inProgressEntry(newObjList, newObjMap, oldObjList, oldObjMap);
                return;
            }

            switch on firstObject {
                when Contact obj {
                    switch on triggerType {
                        when AFTER_INSERT {
//                            invokeMainEntry(new ContactAfterInsertHandler(), newObjList, newObjMap, oldObjList, oldObjMap);
                        }
                    }
                }
            }

            TriggerDMLSupport.updatePendingObjects();
        }
    }

    public static void invokeMainEntry(
            ITriggerEntry handler, List<SObject> newObjList, Map<Id, SObject> newObjMap,
            List<SObject> oldObjList, Map<Id,SObject> oldObjMap)
    {
        ITriggerEntry oldActiveFunction = activeFunction;
        handler.mainEntry(newObjList, newObjMap, oldObjList, oldObjMap);
        activeFunction = oldActiveFunction;
    }

}
