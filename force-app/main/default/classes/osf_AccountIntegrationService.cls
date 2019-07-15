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

    // process each batch of records
    global void execute(Database.BatchableContext bc, List<osf_Account_Source__c> scope) {
        if(scope.size() > 0) {
            List<osf_Account_Source__c> newAccounts = new List<osf_Account_Source__c>();

            for(osf_Account_Source__c account: scope) {
                account.osf_Source_Number__c = 10;
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

        sendEmailMessage(job);
        
        if(job.Status == 'Completed' && job.NumberOfErrors == 0 && recordsProcessed > 0) {
            // accountMapping.osf_Last_Value__c = newLastValue;
            // upsert accountMapping;

            // HandleMetadata handleMetadata = new HandleMetadata();
            // handleMetadata.updateAndDeployMetadata(newLastValue);
        }
    }

    private void sendEmailMessage(AsyncApexJob job) {
        // reserve email capacity for the Apex transaction to ensure not exceeding the daily email limits
        Messaging.reserveSingleEmailCapacity(2);
        // create a new single email message object, to send out a single email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] { accountMapping.osf_Email__c }; 
        // String[] ccAddresses = new String[] {};
        // assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        // mail.setCcAddresses(ccAddresses);
        // specify the address used when the recipients reply to the email. 
        mail.setReplyTo(accountMapping.osf_Email__c);
        // specify the name used as the display name.
        mail.setSenderDisplayName('OSF Cobra - Support');
        // specify the subject line for your email address.
        mail.setSubject('batch process.');
        // set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // optionally append the salesforce.com email signature to the email.
        // the email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        // specify the text content of the email.
        mail.setPlainTextBody(
            'Records processed: ' + recordsProcessed + ';'
            + 'Job: ' + job + '.'
        );
        mail.setHtmlBody(
            '<b>Records processed:</b> ' + recordsProcessed + ';'
            + '<br>'
            + '<b>Job:</b> ' + job + '.'
        );
        // send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
