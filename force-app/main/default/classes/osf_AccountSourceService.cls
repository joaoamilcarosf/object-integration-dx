public with sharing class osf_AccountSourceService {
    // TODO: check if the custom metadata type on return can be abstracted.
    public static osf_Account_Mapping__mdt getCustomSettings() {
        osf_Account_Mapping__mdt settings;
        
        for(osf_Account_Mapping__mdt rec: [
            SELECT Id, osf_Active__c, osf_Last_Value__c, osf_Email__c, osf_Target_Object__c, osf_Fields_Map__c, osf_Unique_Field__c
            FROM osf_Account_Mapping__mdt
            WHERE osf_Active__c = true
            ORDER BY osf_Last_Value__c DESC
            LIMIT 1
        ]) {
            settings = rec;
        }

        return settings;
    }

    // TODO: check if the custom metadata type on argument can be abstracted.
    public static Map<String, Object> getFieldsMap(osf_Account_Mapping__mdt settings) {
        String fieldsMapJsonString = settings.osf_Fields_Map__c;
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fieldsMapJsonString);

        return fieldsMap;
    }

    public static Schema.SObjectField getUniqueField(osf_Account_Mapping__mdt settings) {
        SObject targetObj = Schema.getGlobalDescribe().get(settings.osf_Target_Object__c).newSObject();
        Schema.SObjectField uniqueField = targetObj.getSObjectType().getDescribe().fields.getMap().get(settings.osf_Unique_Field__c);
        
        return uniqueField;
    }
}
