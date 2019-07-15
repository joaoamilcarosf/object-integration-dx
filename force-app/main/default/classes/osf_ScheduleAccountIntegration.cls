global class osf_ScheduleAccountIntegration implements Schedulable {
    public osf_ScheduleAccountIntegration() {

    }

    global void execute(SchedulableContext SC) {
        osf_AccountIntegrationService batch = new osf_AccountIntegrationService();
        Database.executeBatch(batch);
    }
}
