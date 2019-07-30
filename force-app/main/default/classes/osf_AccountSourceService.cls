public with sharing class osf_AccountSourceService {
    
    public osf_AccountSourceService() {

    }

    // TODO: check if the custom metadata type on return can be refactor.
    public static osf_Account_Mapping__mdt getCustomSettings() {
        osf_Account_Mapping__mdt settings;
        
        for(osf_Account_Mapping__mdt rec: [
            SELECT Id, osf_Active__c, osf_Last_Value__c, osf_Email__c, osf_Target_Object__c, osf_Fields_Map__c
            FROM osf_Account_Mapping__mdt
            WHERE osf_Active__c = true
            ORDER BY osf_Last_Value__c DESC
            LIMIT 1
        ]) {
            settings = rec;
        }

        return settings;
    }

    // TODO: check if the custom metadata type on argument can be refactor.
    public static Map<String, Object> getFieldsMap(osf_Account_Mapping__mdt settings) {
        String fieldsMapJsonString = settings.osf_Fields_Map__c;
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fieldsMapJsonString);

        return fieldsMap;
    }

    // TODO: check if the custom metadata type on argument can be refactor. If so, move this method to osf_AssignmentService class 
    public static osf_Account_Target__c assign(Map<String, Object> fieldsMap, SObject sourceObject) {
        osf_Account_Target__c targetObject = new osf_Account_Target__c();

        // TODO: consider a pre-process before assignment for required combinations of pairs of field types
        for(String key: fieldsMap.keySet()) {
            String sourceFieldAPIName = key;
            String targetFieldAPIName = (String) fieldsMap.get(key);

            Object processedTargetValue = osf_AssignmentService.process(sourceFieldAPIName, targetFieldAPIName, sourceObject, targetObject);
            
            if (processedTargetValue != null) {
                targetObject.put(targetFieldAPIName, processedTargetValue);
            }
        }

        return targetObject;
    }
}
