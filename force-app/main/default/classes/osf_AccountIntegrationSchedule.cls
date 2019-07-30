global class osf_AccountIntegrationSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        osf_AccountSourceBatch batch = new osf_AccountSourceBatch();
        Database.executeBatch(batch);
    }
}
