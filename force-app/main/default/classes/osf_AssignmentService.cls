public with sharing class osf_AssignmentService {
    // TODO: refactor to receive a List<SObject> of sourceObjects
    public static SObject assign(Map<String, Object> fieldsMap, String targetObjAPIName, SObject sourceObject) {
        SObject targetObject = Schema.getGlobalDescribe().get(targetObjAPIName).newSObject();
        
        for(String key: fieldsMap.keySet()) {
            String sourceFieldAPIName = key;
            String targetFieldAPIName = (String) fieldsMap.get(key);

            Object processedTargetValue = process(sourceFieldAPIName, targetFieldAPIName, sourceObject, targetObject);
            
            if (processedTargetValue != null) {
                targetObject.put(targetFieldAPIName, processedTargetValue);
            }
        }

        return targetObject;
    }

    public static Object process(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject) {
        Schema.SObjectField sourceField = sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceFieldAPIName);
        Schema.DisplayType sourceFieldType = sourceField.getDescribe().getType();
        Object sourceValue = sourceObject.get(sourceFieldAPIName);

        Schema.SObjectField targetField = targetObject.getSObjectType().getDescribe().fields.getMap().get(targetFieldAPIName);
        Schema.DisplayType targetFieldType = targetField.getDescribe().getType();

        if(sourceFieldType == targetFieldType) {
            return sourceValue;
        } else if(sourceFieldType == Schema.DisplayType.DOUBLE && targetFieldType == Schema.DisplayType.STRING) {
            return null;
        } else {
            return null;
        }
    }
}