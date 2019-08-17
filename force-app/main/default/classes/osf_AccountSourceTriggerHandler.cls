public with sharing class osf_AccountSourceTriggerHandler implements osf_ITrigger {
    public void bulkBefore() {}

    public void bulkAfter() {}

    public void beforeInsert(SObject so) {}

    public void beforeUpdate(SObject oldSo, SObject so) {}

    public void beforeDelete(SObject so) {}

    public void afterInsert(SObject so) {}

    public void afterUpdate(SObject oldSo, SObject so) {
        osf_Account_Source__c newClassRegistration = castToAS(so);
        osf_Account_Mapping__mdt settings = osf_AccountSourceService.getCustomSettings();
        Map<String, Object> fieldsMap = osf_AccountSourceService.getFieldsMap(settings);
        osf_Account_Target__c targetAccount = (osf_Account_Target__c) osf_AssignmentService.assign(fieldsMap, settings.osf_Target_Object__c, newClassRegistration);
        
        Schema.SObjectField uniqueField = osf_AccountSourceService.getUniqueField(settings);
        Database.upsert(targetAccount, uniqueField, true);
    }

    public void afterDelete(SObject so) {}
    
    public void afterUndelete(SObject so) {}

    public void postProcessing() {}
    
    private osf_Account_Source__c castToAS(SObject so) {
        return (osf_Account_Source__c) so;
    }
}
