public with sharing class osf_AccountSourceService {
    // TODO: check if a custom metadata type can be abstracted and revise all methods here
    public static osf_Account_Mapping__mdt getCustomSettings() {
        osf_Account_Mapping__mdt settings;
        
        for(osf_Account_Mapping__mdt rec: [
            SELECT Id, DeveloperName, MasterLabel, NamespacePrefix, osf_Active__c, osf_Last_Value__c, osf_Email__c, osf_Target_Object__c, osf_Fields_Map__c, osf_Unique_Field__c
            FROM osf_Account_Mapping__mdt
            WHERE osf_Active__c = true
            ORDER BY osf_Last_Value__c DESC
            LIMIT 1
        ]) {
            settings = rec;
        }

        return settings;
    }

    public static Map<String, Object> getFieldsMap(osf_Account_Mapping__mdt settings) {
        String fieldsMapJsonString = settings.osf_Fields_Map__c;
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fieldsMapJsonString);

        return fieldsMap;
    }

    public static Schema.SObjectField getUniqueField(osf_Account_Mapping__mdt settings) {
        SObject targetSObj = Schema.getGlobalDescribe().get(settings.osf_Target_Object__c).newSObject();
        Schema.SObjectField uniqueField = targetSObj.getSObjectType().getDescribe().fields.getMap().get(settings.osf_Unique_Field__c);
        
        return uniqueField;
    }
}
