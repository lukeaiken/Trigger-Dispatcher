public with sharing class TriggerDMLSupport {

    public static Boolean updatingPendingObjects = false;
    private static Map<Schema.SObjectType, Map<Id, SObject>> objectsToUpdate = new Map<Schema.SObjectType, Map<Id, SObject>>();

    // Return a map of updatable SObject records
    public static Map<Id, SObject> getUpdatableObjects(Schema.SObjectType objType, Set<Id> objIds) {
        Map<Id, SObject> objMap = objectsToUpdate.get(objType);
        if(objMap==null) {
            objMap = new Map<Id, SObject>();
            objectsToUpdate.put(objType, objMap);
        }
        Map<Id, SObject> results = new Map<Id, SObject>();
        for(Id objId: objIds) results.put(objId, (objMap.containsKey(objId))? objMap.get(objId): objType.newSObject(objId));
        return results;
    }

    // We assume all objects are of the same type
    // You can add some error checking here just in case
    public static void queueForUpdates(List<SObject> toUpdate) {
        if(toUpdate==null || toUpdate.size()==0) return;
        Schema.SObjectType objType = toUpdate[0].id.getSobjectType();
        Map<Id, SObject> mapForSObjectType = objectsToUpdate.get(objType);
        mapForSObjectType.putAll(toUpdate);
    }

    private static Boolean updatesPending() {
        for(Schema.SObjectType objType: objectsToUpdate.keyset()) {
            if(objectsToUpdate.get(objType).size()>0) return true;
        }
        return false;
    }

    public static void updatePendingObjects() {
        if (!updatingPendingObjects) {
            while (updatesPending()) {
                for (Schema.SObjectType objType: objectsToUpdate.keyset()) {
                    Map<Id, SObject> objectToUpdateMap = objectsToUpdate.get(objType);
                    if(objectToUpdateMap.size()==0) continue;
                    List<SObject> updatingList = objectToUpdateMap.values();
                    objectsToUpdate.put(objType, new Map<Id, SObject>());
                    updatingPendingObjects = true;
                    update updatingList;
                    updatingPendingObjects = false;
                }
            }
        }
    }

}