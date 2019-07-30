global class osf_AccountSourceBatch implements Database.Batchable<sObject>, Database.Stateful {
    // instance members to retain state across transactions
    global Integer recordsProcessed = 0;
    global osf_Account_Mapping__mdt accountMapping;
    global Datetime newLastValue;

    // collect the batches of records or objects to be passed to execute
    // return (Database.QueryLocator | Iterable<sObject>)
    global Database.QueryLocator start(Database.BatchableContext bc) {
        accountMapping = osf_AccountSourceService.getCustomSettings();

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
            Map<String, Object> fieldsMap = osf_AccountSourceService.getFieldsMap(accountMapping);
            List<osf_Account_Target__c> targetAccounts = new List<osf_Account_Target__c>();

            for(osf_Account_Source__c account: scope) {
                osf_Account_Target__c targetAccount = osf_AccountSourceService.assign(fieldsMap, account);
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
