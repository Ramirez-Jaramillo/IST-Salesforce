global class BMM {
    public BMM()
    {
        
    }
    
    global Decimal getOpeningBMM(Id oppId, Id opeId, Id positionId, Id locationId, decimal quantity, boolean interview)
    {
        Decimal totalQty, totalOpenings, opeQuantityValue, opeInterviewValue, opePosLocValue = 0;
        Decimal opeQtyPercentage, opePartialBMM, opeBMM = 0;
        
        // Check if no Qty has been set for Opening 
        if (quantity == null)
        {
            quantity = 0;
        }
        
        if (oppId != null)
        {
            // Get Total Quantity of Opp Openings except this one 
            AggregateResult[] groupedResults = [SELECT SUM(Quantity__c)sumQty FROM Opening__c WHERE Opportunity__c = :oppId AND Id != :opeId];
            totalQty = (Decimal)groupedResults[0].get('sumQty');
            if(totalQty == null)
            {
                totalQty = 0;
            }
            
            // Get Total Quantity of Opp Openings including this one 
            totalOpenings = totalQty + quantity;
            
            // Get BMM Quantity Value 
            opeQuantityValue = getQuantityBMMValue(totalOpenings);
            
            // Get BMM Interview Value 
            opeInterviewValue = getInterviewBMMValue(locationId, interview);
            
            // Get BMM Position/Location Value 
            opePosLocValue = getPosLocBMMValue(positionId, locationId);
            
            // Get Opening's Qty Percentage 
            if (totalOpenings == 0)
            {
                opeQtyPercentage = totalOpenings;
            }
            else
            {
                opeQtyPercentage = (quantity / totalOpenings);    
            }
            
            // Get Opening's Partial BMM 
            opePartialBMM = ((opeInterviewValue * 0.3) + (opePosLocValue * 0.4) + (opeQuantityValue * 0.3));
            
            // Get Opening's BMM 
            opeBMM = 1 - ((5.8 - opePartialBMM) / 14);
        }
        return opeBMM;
    }
    
    global Decimal getQuantityBMMValue(Decimal totalQty)
    {
        Decimal opeQuantityValue = 0;
        
        // Check if Total Qty is greater than the MAX value in BMM's value table 
        // If so, get MAX value result 
        AggregateResult[] queryVal = [SELECT MAX(Quantity__c)maxVal FROM BMM_Quantity_Entity__c];
        Decimal maxQty = (Decimal)queryVal[0].get('maxVal');
        if (totalQty > maxQty)
        {
            totalQty = maxQty;    
        }
        
        // Get BMM Quantity Value 
        BMM_Quantity_Entity__c objBMMQtyVal = [SELECT Value__c FROM BMM_Quantity_Entity__c WHERE Quantity__c = :totalQty];
        if (objBMMQtyVal != null)
        {
            opeQuantityValue = objBMMQtyVal.Value__c;
        }
        return opeQuantityValue;
    }
    
    global Decimal getInterviewBMMValue(Id locationId, boolean interview)
    {
        Decimal opeInterviewValue = 0;
        
        
        // Get BMM Interview Value 
        Interview_BMM_Value__c objOpeIntBMMVal = null;
        // Check if Interview has a value 
        List<Interview_BMM_Value__c> listOpeIntBMMVal = [SELECT Value__c FROM Interview_BMM_Value__c WHERE Interview_Required__c = :interview AND Location__c = :locationId];
        if(!listOpeIntBMMVal.isEmpty())
        {
           objOpeIntBMMVal = listOpeIntBMMVal[0];
           if (objOpeIntBMMVal != null)
           {
               opeInterviewValue = objOpeIntBMMVal.Value__c;
           }
        }
        else
        {
            opeInterviewValue = 0;
        }
        return opeInterviewValue;
    }
    
    global Decimal getPosLocBMMValue(Id positionId, Id locationId)
    {
        Decimal opePosLocValue = 0;
        
        // Get BMM Position/Location Value 
        Position_Location_BMM__c objOpePosLocVal = null;
        // Check if Pos/Loc combination has a value 
        List<Position_Location_BMM__c> listOpePosLocVal = [SELECT Value__c FROM Position_Location_BMM__c WHERE Position__c = :positionId AND Location__c = :locationId];
        if(!listOpePosLocVal.isEmpty())
        {
            objOpePosLocVal = listOpePosLocVal[0];
            if (objOpePosLocVal != null)
            {
                opePosLocValue = objOpePosLocVal.Value__c;
            }
        }
        else
        {
            // If there's no value for Position/Location use default value (5) 
            opePosLocValue = 5;
        }
        return opePosLocValue;
    }
    
    public static Decimal roundNumber(Decimal roundNumber , Integer decimalPlace)
    {
        if(roundNumber != null)
        {
            Decimal decPlace = Math.POW(10 , decimalPlace) ;
            return Math.round(roundNumber * decPlace) / decPlace ;
        }
        else
        {
            return 0 ;
        }
    }
}