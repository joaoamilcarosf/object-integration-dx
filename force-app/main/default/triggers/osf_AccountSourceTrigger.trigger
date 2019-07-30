trigger osf_AccountSourceTrigger on osf_Account_Source__c(after insert, after update) {

    if(Trigger.isInsert) {
        
    } else if(Trigger.isUpdate) {
        osf_Account_Mapping__mdt settings = osf_AccountSourceService.getCustomSettings();
        Map<String, Object> fieldsMap = osf_AccountSourceService.getFieldsMap(settings);
        List<osf_Account_Source__c> sourceAccount = Trigger.new;
        // TODO: send the Trigger.new List ?
        osf_Account_Target__c targetAccount = osf_AccountSourceService.assign(fieldsMap, sourceAccount.get(0));
        
        upsert targetAccount osf_Codigo_Cobra__c;
    }

}