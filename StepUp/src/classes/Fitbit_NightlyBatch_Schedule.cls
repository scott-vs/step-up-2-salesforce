global class Fitbit_NightlyBatch_Schedule implements Schedulable    {
	
	global void execute(SchedulableContext sc){
		database.executeBatch(new Fitbit_Batch());
    }	
}