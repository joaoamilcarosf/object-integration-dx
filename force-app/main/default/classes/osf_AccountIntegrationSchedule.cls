global class osf_AccountIntegrationSchedule implements Schedulable {
    public osf_AccountIntegrationSchedule() {

    }

    global void execute(SchedulableContext SC) {
        osf_AccountIntegrationService batch = new osf_AccountIntegrationService();
        Database.executeBatch(batch);
    }
}
