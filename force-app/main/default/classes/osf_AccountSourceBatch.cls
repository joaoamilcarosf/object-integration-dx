global class osf_AccountSourceBatch implements Database.Batchable<sObject>, Database.Stateful {
    // instance members to retain state across transactions
    global Integer recordsProcessed = 0;
    global osf_Account_Mapping__mdt settings;
    global Datetime newLastValue;

    // collect the batches of records or objects to be passed to execute
    // return (Database.QueryLocator | Iterable<sObject>)
    global Database.QueryLocator start(Database.BatchableContext bc) {
        settings = osf_AccountSourceService.getCustomSettings();

        // TODO: handle when there is no metadata returned
        return Database.getQueryLocator([
            SELECT Name, LastModifiedDate, osf_Source_Number__c, osf_Codigo_Cobra__c
            FROM osf_Account_Source__c
            WHERE LastModifiedDate > :settings.osf_Last_Value__c
        ]);
    }

    // process each batch of records
    global void execute(Database.BatchableContext bc, List<osf_Account_Source__c> scope) {
        if(scope.size() > 0) {
            Map<String, Object> fieldsMap = osf_AccountSourceService.getFieldsMap(settings);
            List<osf_Account_Target__c> targetAccounts = new List<osf_Account_Target__c>();

            for(osf_Account_Source__c account: scope) {
                osf_Account_Target__c targetAccount = (osf_Account_Target__c) osf_AssignmentService.assign(fieldsMap, settings.osf_Target_Object__c, account);
                targetAccounts.add(targetAccount);
                
                if(account.LastModifiedDate > newLastValue || newLastValue == null) {
                    newLastValue = account.LastModifiedDate;
                }

                recordsProcessed = recordsProcessed + 1;
            }

            Schema.SObjectField uniqueField = osf_AccountSourceService.getUniqueField(settings);
            Database.upsert(targetAccounts, uniqueField, true);
        }
    }

    // execute any post-processing operations
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        // First error: DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): DeployRequest, original object: EmailMessage
        // osf_MessageService.sendEmailMessageByJob(job, settings.osf_Email__c, recordsProcessed);
        
        // update osf_Last_Value__c on Metadata
        if(job.Status == 'Completed' && job.NumberOfErrors == 0 && recordsProcessed > 0) {
            // Set up custom metadata to be created in the subscriber org.
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            String namespacePrefix = (settings.NamespacePrefix == null) ? '' : settings.NamespacePrefix;
            customMetadata.fullName = namespacePrefix + 'osf_Account_Mapping__mdt.' + settings.DeveloperName;
            customMetadata.label = settings.MasterLabel;

            // Add all the field values 
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'osf_Last_Value__c';
            customField.value = newLastValue;
            customMetadata.values.add(customField);

            System.debug( ' >>>> Created custom metadata object >>> ' + customMetadata );
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);

            // Setup deploy callback
            osf_CustomMetadataDeployCallback callback = new osf_CustomMetadataDeployCallback();

            // Enqueue custom metadata deployment. jobId is the deployment ID
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
}
