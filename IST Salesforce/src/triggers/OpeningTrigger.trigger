trigger OpeningTrigger on Opening__c (before insert, before update, before delete, after insert, after update, after delete) {
	if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate)
        {
            /* Avoid recursive trigger calling*/
            if(CheckTriggerRun.triggerFirstRun)
            {
            	Id oppId, opeId;
                Decimal opeTriggerQty, opeTriggerBMM = 0;
                for (Opening__c ope : Trigger.new)
                {
                    CheckTriggerRun.triggerFirstRun = false;
                    
                    /* Get Opp Id and Opening Qty and Id */
                    oppId = ope.Opportunity__c;
                    opeId = ope.Id;
                    opeTriggerQty = ope.Quantity__c;
                    
                    /* Set Trigger Opening's BMM */
                    ope.BMM__c = OpeningTriggerHandler.updateOpeningBMM(trigger.new);
                    opeTriggerBMM = ope.BMM__c;
                }
                /* Update all others Openings BMM */
                OpeningTriggerHandler.updateAllOpeningsBMM(oppId, opeId, opeTriggerQty, opeTriggerBMM);
            }
        }
        
        if(trigger.isDelete){
			for(Opening__c ope : Trigger.old)
            {
                List <Opportunity> objOpp = [SELECT Id, Probability FROM Opportunity WHERE Id = :ope.Opportunity__c];
                for (Opportunity opportunitiesToCheck : objOpp) {
                    if(userinfo.getProfileId() != '00e80000000tCfrAAE')
                    {
                    	if(opportunitiesToCheck.Probability == 100 || opportunitiesToCheck.Probability == 0 ) {
                            ope.addError('You cannot delete an Opening on a Closed Opportunity');
                        }    
                    }
            	}
                
                if(CheckTriggerRun.triggerFirstRun)
                {
                	system.debug('Delete Trigger');
                    CheckTriggerRun.triggerFirstRun = false;
                    
                    /* Update all others Openings BMM */
                	OpeningTriggerHandler.updateAllOpeningsBMM(ope.Opportunity__c, ope.Id, 0, ope.BMM__c);    
                }
            }
        }
    }
    if (trigger.isAfter) {
        
    }
}