public with sharing class osf_Image {
    public String getBase64String() {
        osf_Image__c sr = [SELECT id, osf_base64__c
                           FROM osf_Image__c
                           WHERE Name = 'image2']; // external service call

        return sr.osf_base64__c;
    }

    /*
    public String getBase64String() {
        StaticResource sr = [SELECT body
                             FROM StaticResource
                             WHERE Name = 'base64image']; // external service call
        String stringFileContent = sr.body.toString();

        return stringFileContent;
    }
     */
}
