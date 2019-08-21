public abstract class osf_AssignmentAbstract {
    // TODO: refactor to receive a List<SObject> of sourceObjects
    public SObject assign(Map<String, Object> fieldsMap, String targetObjAPIName, SObject sourceObject) {
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

    private Object process(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject) {
        Schema.SObjectField sourceField = sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceFieldAPIName);
        Schema.DisplayType sourceFieldType = sourceField.getDescribe().getType();
        Object sourceValue = sourceObject.get(sourceFieldAPIName);

        Schema.SObjectField targetField = targetObject.getSObjectType().getDescribe().fields.getMap().get(targetFieldAPIName);
        Schema.DisplayType targetFieldType = targetField.getDescribe().getType();

        if(sourceFieldType == targetFieldType) {
            return processSameType(sourceFieldAPIName, targetFieldAPIName, sourceObject, targetObject);
        } else if(sourceFieldType == Schema.DisplayType.DOUBLE && targetFieldType == Schema.DisplayType.STRING) {
            return processDoubleToString(sourceFieldAPIName, targetFieldAPIName, sourceObject, targetObject);
        } else if(sourceFieldType == Schema.DisplayType.INTEGER && targetFieldType == Schema.DisplayType.STRING) {
            return processIntegerToString(sourceFieldAPIName, targetFieldAPIName, sourceObject, targetObject);
        } else {
            return null;
        }
    }

    public abstract Object processSameType(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject);

    public abstract Object processDoubleToString(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject);

    public abstract Object processIntegerToString(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject);
}
