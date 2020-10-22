@isTest
public class litmosTeamsNumSubteamsFlowTEST {
    @isTest
    static void testNumSubteams() {
        List<Litmos_Team__c> teams = new List<Litmos_Team__c>();
        for(Integer i = 0; i < 5; i++) {
            teams.add(new Litmos_Team__c(
                Name='Test team ' + i,
                Litmos_Id__c = 'TESTTEAM' + i
            ));
        }

        insert teams;
        for(Integer i = 1; i < 5; i++) {
            teams[i].Litmos_Parent_Team__c = teams[0].Id;
        }
        //confirm no parent teams on team[0]
        Litmos_Team__c parent = [SELECT Id,Trigger_Number_of_Subteams__c FROM Litmos_Team__c WHERE Id=:teams[0].Id];
        System.assertEquals(0, parent.Trigger_Number_of_Subteams__c);
        Test.startTest();
        update teams;
        Test.stopTest();

        parent = [SELECT Id, Trigger_Number_of_Subteams__c FROM Litmos_Team__c WHERE Id=: teams[0].Id];
        System.assertEquals(4, parent.Trigger_Number_of_Subteams__c);
    }
}
