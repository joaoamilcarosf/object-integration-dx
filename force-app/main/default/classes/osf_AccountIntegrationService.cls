global class osf_AccountIntegrationService implements Database.Batchable<sObject>, Database.Stateful {
    // instance members to retain state across transactions
    global Integer recordsProcessed = 0;
    global osf_Account_Mapping__mdt accountMapping;
    global Datetime newLastValue;
    
    public osf_AccountIntegrationService() {

    }

    // collect the batches of records or objects to be passed to execute
    // return (Database.QueryLocator | Iterable<sObject>)
    global Database.QueryLocator start(Database.BatchableContext bc) {
        for(osf_Account_Mapping__mdt rec: [
            SELECT Id, osf_Active__c, osf_Last_Value__c, osf_Email__c, osf_Target_Object__c, osf_Fields_Map__c
            FROM osf_Account_Mapping__mdt
            WHERE osf_Active__c = true
            ORDER BY osf_Last_Value__c DESC
            LIMIT 1
        ]) {
            accountMapping = rec;
        }

        // TODO: handle when there is no metadata returned
        return Database.getQueryLocator([
            SELECT Name, LastModifiedDate, osf_Source_Number__c, osf_Codigo_Cobra__c
            FROM osf_Account_Source__c
            WHERE LastModifiedDate > :accountMapping.osf_Last_Value__c
        ]);
    }

    // process each batch of records
    global void execute(Database.BatchableContext bc, List<osf_Account_Source__c> scope) {
        if(scope.size() > 0) {
            // List<osf_Account_Target__c> targetAccounts = osf_AccountMappingService.start(scope, accountMapping);

            String fieldsMapJsonString = accountMapping.osf_Fields_Map__c;
            Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fieldsMapJsonString);
            List<osf_Account_Target__c> targetAccounts = new List<osf_Account_Target__c>();

            for(osf_Account_Source__c account: scope) {
                osf_Account_Target__c targetAccount = new osf_Account_Target__c();

                // TODO: consider a pre-process before assignment for required combinations of pairs of field types
                for(String key: fieldsMap.keySet()) {
                    String sourceFieldAPIName = key;
                    String targetFieldAPIName = (String) fieldsMap.get(key);

                    Object processedTargetValue = osf_AssignmentService.process(sourceFieldAPIName, targetFieldAPIName, account, targetAccount);
                    // Object processedTargetValue = account.get(sourceFieldAPIName);
                    
                    if (processedTargetValue != null) {
                        targetAccount.put(targetFieldAPIName, processedTargetValue);
                    }
                }
                
                targetAccounts.add(targetAccount);
                
                if(account.LastModifiedDate > newLastValue || newLastValue == null) {
                    newLastValue = account.LastModifiedDate;
                }

                recordsProcessed = recordsProcessed + 1;
            }

            // TODO: dynamically provide this field from Metadata.osf_Unique_Field__c value
            upsert targetAccounts osf_Codigo_Cobra__c;
        }
    }

    // execute any post-processing operations
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        osf_MessageService.sendEmailMessageByJob(job, accountMapping.osf_Email__c, recordsProcessed);
        
        if(job.Status == 'Completed' && job.NumberOfErrors == 0 && recordsProcessed > 0) {
            // TODO: update osf_Last_Value__c on Metadata

            // accountMapping.osf_Last_Value__c = newLastValue;
            // upsert accountMapping;

            // HandleMetadata handleMetadata = new HandleMetadata();
            // handleMetadata.updateAndDeployMetadata(newLastValue);
        }
    }
}
