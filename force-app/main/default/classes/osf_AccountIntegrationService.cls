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
            SELECT Id, osf_Active__c, osf_Last_Value__c, osf_Email__c
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

    // TODO: process each batch of records
    global void execute(Database.BatchableContext bc, List<osf_Account_Source__c> scope) {
        if(scope.size() > 0) {
            List<osf_Account_Source__c> newAccounts = new List<osf_Account_Source__c>();

            for(osf_Account_Source__c account: scope) {
                account.osf_Source_Number__c = 13;
                recordsProcessed = recordsProcessed + 1;
                newAccounts.add(account);
                
                if(account.LastModifiedDate > newLastValue || newLastValue == null) {
                    newLastValue = account.LastModifiedDate;
                }
            }

            upsert newAccounts;
        }
    }

    // execute any post-processing operations
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        osf_MessageService.sendEmailMessageByJob(job, accountMapping, recordsProcessed);
        
        if(job.Status == 'Completed' && job.NumberOfErrors == 0 && recordsProcessed > 0) {
            // TODO: update osf_Last_Value__c on metadata

            // accountMapping.osf_Last_Value__c = newLastValue;
            // upsert accountMapping;

            // HandleMetadata handleMetadata = new HandleMetadata();
            // handleMetadata.updateAndDeployMetadata(newLastValue);
        }
    }
}
