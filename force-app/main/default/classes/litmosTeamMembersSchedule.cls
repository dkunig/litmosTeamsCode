global class litmosTeamMembersSchedule implements Schedulable{
	//utilize the callout method already created to pull teams within specific time frame
    public void execute(SchedulableContext SC) {
        //schedule this test to be at least 4 hours after team schedule
        litmosTeamMemberUpdates.litmosTeamMemberUpdates();
    }
}