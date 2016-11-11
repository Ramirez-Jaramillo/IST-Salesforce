trigger OpportunityUpdateFields on Opportunity (before insert, before update, before delete, after insert, after update, after delete)
{
    
    if(trigger.isBefore){
        if(trigger.isInsert){

        }
        if(trigger.isUpdate){
			for(Opportunity opp : Trigger.new)
            {
                if (opp.Probability == 60 || opp.Probability == 80 || opp.Probability == 100)
                {
                    if (opp.Openings__c != opp.total_positions__c)
                    {
                    	OpportunityTriggerHandler.updateOpportunityOpening(trigger.new);    
                    }
                }
                else if (opp.Probability == 0)
                {
                    if (opp.Openings__c != opp.total_positions__c && opp.total_positions__c > 0)
                    {
                        OpportunityTriggerHandler.updateOpportunityOpening(trigger.new);
                    }
                }
            }
        }
    }
    
    if (trigger.isAfter) {
        if (trigger.isInsert) {
            
        }
        if (trigger.isUpdate) {
            for(Opportunity opp : Trigger.new)
            {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if (opp.CloseDate != oldOpp.CloseDate)
                {
                    OpportunityTriggerHandler.updateOpeningStartDate(trigger.new);
                }
            }
        }
    }
	
}