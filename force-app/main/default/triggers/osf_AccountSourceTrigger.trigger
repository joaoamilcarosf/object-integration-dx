trigger osf_AccountSourceTrigger on osf_Account_Source__c(after insert, after update) {
    if(Trigger.isInsert) {
        
    } else if(Trigger.isUpdate) {
        osf_Account_Mapping__mdt settings = osf_AccountSourceService.getCustomSettings();
        Map<String, Object> fieldsMap = osf_AccountSourceService.getFieldsMap(settings);
        List<osf_Account_Target__c> targetAccounts = new List<osf_Account_Target__c>();
        
        for(osf_Account_Source__c account: Trigger.new) {
            osf_Account_Target__c targetAccount = (osf_Account_Target__c) osf_AssignmentService.assign(fieldsMap, settings.osf_Target_Object__c, account);
            targetAccounts.add(targetAccount);
        }
        
        Schema.SObjectField uniqueField = osf_AccountSourceService.getUniqueField(settings);
        Database.upsert(targetAccounts, uniqueField, true);
    }
}