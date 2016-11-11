public class OpeningTriggerHandler {
    public static Decimal updateOpeningBMM(List<Opening__C> openings)
    {
        ApexPages.StandardController con;
        Decimal acumBMM = 0;
        Decimal totalQty, totalOpenings, opeQuantityValue, opeInterviewValue, opePosLocValue = 0;
        Decimal opeQtyPercentage, opePartialBMM, opeBMM = 0;
        BMM objBMM = new BMM();
        List <Opportunity> opportunitiesToUpdate = new List<Opportunity> {};
        
        /* Loop Trigger */
        for(Opening__c ope: openings)
        {
            /* Load Opp */
            Opportunity objOpp = new Opportunity();
            objOpp = [SELECT Id, BMM__c, total_positions__c FROM Opportunity WHERE Id = :ope.Opportunity__c];
            
            /* Get Total Quantity of Opp Openings except the one in triggers loop */
            AggregateResult[] groupedResults = [SELECT SUM(Quantity__c)sumQty FROM Opening__c WHERE Opportunity__c = :objOpp.Id AND Id != :ope.Id];
            totalQty = (Decimal)groupedResults[0].get('sumQty');
            if(totalQty == null)
            {
                totalQty = 0;
            }
            
            /* Get Total Quantity of Opp Openings including the one in triggers loop */
            totalOpenings = totalQty + ope.Quantity__c;
            
            /* Get Trigger Opening's BMM Quantity Value */
            opeQuantityValue = objBMM.getQuantityBMMValue(totalOpenings);
            
            /* Get Trigger Opening's BMM Interview Value */
            opeInterviewValue = objBMM.getInterviewBMMValue(ope.Location__c, ope.Client_Interview_Requiered__c);
            
            /* Get Trigger Opening's BMM Position/Location Value */
            opePosLocValue = objBMM.getPosLocBMMValue(ope.Position__c, ope.Location__c);
            
            /* Get Trigger Opening's Qty Percentage */
            if (totalOpenings == 0)
            {
                opeQtyPercentage = totalOpenings;
            }
            else
            {
            	opeQtyPercentage = (ope.Quantity__c / totalOpenings);    
            }
            
            /* Get Trigger Opening's Partial BMM */
            opePartialBMM = ((opeInterviewValue * 0.3) + (opePosLocValue * 0.4) + (opeQuantityValue * 0.3));
            
            /* Get Trigger Opening's BMM */
            opeBMM = 1 - ((5.8 - opePartialBMM) / 14);
            
            /* Increase Opportunity Weighted Average BMM */
            acumBMM = acumBMM + (opeBMM * opeQtyPercentage);
            
            /* Update Opportunity Weighted Average BMM */
            objOpp.BMM__c = acumBMM;
            opportunitiesToUpdate.add(objOpp);
        }
        
        /* Update Oppotunities list */
        update(opportunitiesToUpdate);
        
        /* Return BMM Value */
        return opeBMM;
    }
    
    public static void updateAllOpeningsBMM(Id oppId, Id opeId, Decimal opeTriggerQty, Decimal opeBMM)
    {
        List<Opening__c> opesToUpdateBMM = new List<Opening__c>();
        Decimal acumBMM = 0;
        BMM objBMM = new BMM();
        List <Opportunity> opportunitiesToUpdate = new List<Opportunity> {};
        
        /* Get all Opp Openings except the one in triggers loop */
        List<Opening__c> oppOpenings = [SELECT Id, BMM__c, Client_Interview_Requiered__c, Location__c, Position__c, Quantity__c FROM Opening__c WHERE Opportunity__c = :oppId  AND Id != :opeId];
        
        Opportunity objOpp = new Opportunity();
        objOpp = [SELECT Id, BMM__c, total_positions__c FROM Opportunity WHERE Id = :oppId];
        
        AggregateResult[] groupedResults = [SELECT SUM(Quantity__c)sumQty FROM Opening__c WHERE Opportunity__c = :oppId AND Id != :opeId];
        Decimal totalOpenings = (Decimal)groupedResults[0].get('sumQty');
        if(totalOpenings == null)
        {
            totalOpenings = 0;
        }
        
        /* Add Opening's Quantity from Trigger to get Total Openings */
        totalOpenings = totalOpenings + opeTriggerQty;
        
        /* Add Opening's BMM Weighted Average from Trigger to Opportunity BMM Weighted Average */
        if (totalOpenings > 0)
        {
        	acumBMM = (opeTriggerQty / totalOpenings) * opeBMM;
        }
        
        /* Loop Openings except the one in triggers loop */
        if (oppOpenings.size()>0)
        {
            /* Loop all Opp Openings except the one in triggers loop */
            for (Opening__C oppOpe: oppOpenings)
            {
                /* Get Opening's BMM Interview Value */
                Decimal interviewValue = objBMM.getInterviewBMMValue(oppOpe.Location__c, oppOpe.Client_Interview_Requiered__c);
                
                /* Get Trigger Opening's BMM Quantity Value */
                Decimal opeQuantityValue = objBMM.getQuantityBMMValue(totalOpenings);
                
                /* Get Opening's BMM Position/Location Value */
                Decimal posLocValue = objBMM.getPosLocBMMValue(oppOpe.Position__c, oppOpe.Location__c);
                
                /* Get Opening's Qty Percentage */
                Decimal qtyPercentage = 0;
                if (totalOpenings == 0)
                {
                    qtyPercentage = totalOpenings;
                }
                else
                {
                    qtyPercentage = (oppOpe.Quantity__c / totalOpenings);    
                }
                
                /* Get Opening's Partial BMM */
                Decimal partialBMM = ((interviewValue * 0.3) + (posLocValue * 0.4) + (opeQuantityValue * 0.3));
                
                /* Get Opening's BMM */
                Decimal finalBMM = 1 - ((5.8 - partialBMM) / 14);
                
                /* Update Trigger Opening's BMM */
                oppOpe.BMM__c = finalBMM;
                
                /* Add Opening to update list */
                opesToUpdateBMM.add(oppOpe);
                
                /* Increase Opportunity Weighted Average BMM */
                acumBMM = acumBMM + (finalBMM * qtyPercentage);
            }
            
            /* Update Opportunity Weighted Average BMM */
            objOpp.BMM__c = acumBMM;
            opportunitiesToUpdate.add(objOpp);
            
            /* Update Opportunities list */
            update(opportunitiesToUpdate);
            
            
            /* Update Openings list */
            update(opesToUpdateBMM);
        }
    }
}