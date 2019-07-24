public with sharing class osf_AssignmentService {

    public osf_AssignmentService() {

    }

    public static Object assign(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject) {
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