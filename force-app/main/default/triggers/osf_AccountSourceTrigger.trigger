trigger osf_AccountSourceTrigger on osf_Account_Source__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    osf_TriggerFactory.createHandler(osf_Account_Source__c.SObjectType);
    
    // if(Trigger.isInsert) {
        
    // } else if(Trigger.isUpdate) {
    //     osf_Account_Mapping__mdt settings = osf_AccountSourceService.getCustomSettings();
    //     Map<String, Object> fieldsMap = osf_AccountSourceService.getFieldsMap(settings);
    //     List<osf_Account_Target__c> targetAccounts = new List<osf_Account_Target__c>();
        
    //     for(osf_Account_Source__c account: Trigger.new) {
    //         osf_Account_Target__c targetAccount = (osf_Account_Target__c) osf_AssignmentService.assign(fieldsMap, settings.osf_Target_Object__c, account);
    //         targetAccounts.add(targetAccount);
    //     }
        
    //     Schema.SObjectField uniqueField = osf_AccountSourceService.getUniqueField(settings);
    //     Database.upsert(targetAccounts, uniqueField, true);
    // }
}