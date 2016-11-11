public class OpportunityTriggerHandler {
    public static void updateOpeningStartDate(List<Opportunity> opportunities){
        List <Opening__c> openingsToUpdate = new List<Opening__c> {};
        for (Opportunity oppsFromTrigger : opportunities) {
            Date oppNewCloseDate = oppsFromTrigger.CloseDate;
            List <Opening__c> oppsOpenings = [SELECT Id, Start_Date__c, Start_Date_Unit__c, Start_Date_Value__c, Opportunity__c FROM Opening__c WHERE Opportunity__c = :oppsFromTrigger.Id];
            for (Opening__c openingToUpdate : oppsOpenings) {
                Date newStartDate = oppNewCloseDate;
                String startDateUnit = openingToUpdate.Start_Date_Unit__c;
                Decimal startDateValue = openingToUpdate.Start_Date_Value__c;
                Integer intValue = 0;
                intValue = Integer.valueOf(startDateValue);
                if (startDateUnit == 'Days') {
                    newStartDate = newStartDate.addDays(intValue);
                }
                else if(startDateUnit == 'Weeks') {
                    newStartDate = newStartDate.addDays(intValue*7);
                }
                else if(startDateUnit == 'Months') {
                    newStartDate = newStartDate.addMonths(intValue);
                }
                openingToUpdate.Start_Date__c = newStartDate;
                openingsToUpdate.add(openingToUpdate);
            }
        }
        update(openingsToUpdate);
    }
    
    public static void updateOpportunityOpening(List<Opportunity> opportunities){
        for (Opportunity oppsFromTrigger : opportunities) {
            oppsFromTrigger.Display_Alert__c = true;
            oppsFromTrigger.Openings__c = oppsFromTrigger.total_positions__c;
        }
    }
}