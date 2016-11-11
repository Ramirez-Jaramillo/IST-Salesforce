trigger OpeningTrigger on Opening__c (before insert, before update, before delete, after insert, after update, after delete) {
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate)
        {
            // Avoid recursive trigger calling
            if(CheckTriggerRun.triggerFirstRun)
            {
                Id oppId, opeId;
                Decimal opeTriggerQty, opeTriggerBMM = 0;
                for (Opening__c ope : Trigger.new)
                {
                    if (trigger.isUpdate)
                    {
                        Opening__c oldOpe = Trigger.oldMap.get(ope.Id);
                        
                        // Only enter if BMM needs to be recalculated
                        if (oldOpe.Position__c != ope.Position__c || oldOpe.Location__c != ope.Location__c || oldOpe.Quantity__c != ope.Quantity__c || oldOpe.Client_Interview_Requiered__c != ope.Client_Interview_Requiered__c)
                        {
                            CheckTriggerRun.triggerFirstRun = false;
                        
                            // Get Opp Id and Opening Qty and Id 
                            oppId = ope.Opportunity__c;
                            opeId = ope.Id;
                            opeTriggerQty = ope.Quantity__c;
                            
                            // Set Trigger Opening's BMM 
                            ope.BMM__c = OpeningTriggerHandler.updateOpeningBMM(trigger.new);
                            system.debug('Hoy Ope BMM: ' + ope.BMM__c);
                            opeTriggerBMM = ope.BMM__c;
                            
                            // Update all others Openings BMM 
                            OpeningTriggerHandler.updateAllOpeningsBMM(oppId, opeId, opeTriggerQty, opeTriggerBMM);
                        }
                    }
                    else if (trigger.isInsert)
                    {
                        CheckTriggerRun.triggerFirstRun = false;
                        
                        if (ope.BMM__c == null)
                        {
                            // Set Trigger Opening's BMM 
                            ope.BMM__c = OpeningTriggerHandler.updateOpeningBMM(trigger.new);    
                        }
                        
                        // Update all others Openings BMM 
                        OpeningTriggerHandler.updateAllOpeningsBMM(ope.Opportunity__c, ope.Id, ope.Quantity__c, ope.BMM__c);
                    }
                }
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
                    system.debug('Delete Trigger Ope' + ope);
                    // Update all others Openings BMM 
                    OpeningTriggerHandler.updateAllOpeningsBMM(ope.Opportunity__c, ope.Id, 0, ope.BMM__c);    
                    
                    CheckTriggerRun.triggerFirstRun = false;
                }
            }
        }
    }
    if (trigger.isAfter) {
        
    }
}