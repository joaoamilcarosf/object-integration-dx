public with sharing class osf_MessageService {
    public osf_MessageService() {

    }

    public static void sendEmailMessageByJob(AsyncApexJob job, osf_Account_Mapping__mdt mappingObject, Integer recordsProcessed) {
        // reserve email capacity for the Apex transaction to ensure not exceeding the daily email limits
        Messaging.reserveSingleEmailCapacity(2);
        // create a new single email message object, to send out a single email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] { mappingObject.osf_Email__c }; 
        // String[] ccAddresses = new String[] {};
        // assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        // mail.setCcAddresses(ccAddresses);
        // specify the address used when the recipients reply to the email. 
        mail.setReplyTo(mappingObject.osf_Email__c);
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
