public with sharing class osf_AssignmentService extends osf_AssignmentAbstract {
    public override Object processSameType(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject) {
        Schema.SObjectField sourceField = sourceObject.getSObjectType().getDescribe().fields.getMap().get(sourceFieldAPIName);
        Schema.DisplayType sourceFieldType = sourceField.getDescribe().getType();
        Object sourceValue = sourceObject.get(sourceFieldAPIName);
        return sourceValue;
    }

    public override Object processDoubleToString(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject) {
        return null;
    }

    public override Object processIntegerToString(String sourceFieldAPIName, String targetFieldAPIName, SObject sourceObject, SObject targetObject) {
        return null;
    }
}