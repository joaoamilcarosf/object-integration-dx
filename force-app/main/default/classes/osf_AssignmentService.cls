public with sharing class osf_AssignmentService {
    public osf_AssignmentService() {

    }

    public static Object assignTest(Schema.SObjectField sourceField, Schema.SObjectField targetField, Object value) {
        Schema.DisplayType sourceFieldType = sourceField.getDescribe().getType();
        Schema.DisplayType targetFieldType = targetField.getDescribe().getType();
        
        if(sourceFieldType == targetFieldType) {
            return value;
        } else if(sourceFieldType == Schema.DisplayType.DOUBLE && targetFieldType == Schema.DisplayType.STRING) {
            return null;
        } else {
            return null;
        }

        return null;
    }
}
