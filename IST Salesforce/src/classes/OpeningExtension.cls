public class OpeningExtension {
    
    private ApexPages.StandardController con;
    public final Opening__c Opening;
    public List<SelectOption> ListPositions { get;set; }
    public List<SelectOption> ListSeniorities;
    public List<SelectOption> ListLocations;
    public String AccountName { get;set; }
    public String opportunityContractTye { get;set;}
    public Boolean isNotFPContractType {get;set;}
    public Date opportunityCloseDate {get;set;}
    public Boolean isOppClosed {get;set;}
    public Id OpportunityId {get;set;}
    BMM objBMM = new BMM();
    
    public OpeningExtension(ApexPages.StandardController stdController)
    {
        con = stdController;
        Opening = (Opening__c)stdController.getRecord();
        isNotFPContractType = true;
        isOppClosed = false;
        
        OpportunityId = ApexPages.currentPage().getParameters().get('OpportunityId');
        
        if(OpportunityId != null)
        {
            Opening.Opportunity__c = OpportunityId;
            
        }
        else
        {
            OpportunityId = Opening.Opportunity__c;
        }
        
        if(OpportunityId != null)
        {
            Opportunity objectOpportunity = [SELECT Contract_Type__c, CloseDate, Probability FROM Opportunity WHERE Id = :OpportunityId];
            opportunityContractTye = objectOpportunity.Contract_Type__c;
            
            opportunityCloseDate = objectOpportunity.CloseDate;
            
            if (objectOpportunity.Probability == 100 || objectOpportunity.Probability == 0)
            {
                isOppClosed = true;
            }
            
            if (opportunityContractTye == 'FP')
            {
                isNotFPContractType = false;
                Opening.Sale_Rate__c = 0;
                Opening.Sale_Rate_Unit__c = 'Hour';
            }
            else
            {
                isNotFPContractType = true;
            }
        }
        
        ListPositions = new List<SelectOption>();
        boolean first = true;
        
        for(Position__c position : [SELECT id,Name FROM Position__c ORDER BY Name ASC])
        {
            if (first && this.Opening.Position__c == null)
            {
                first = false;
                this.Opening.Position__c = position.Id;        
            }
            ListPositions.add(new SelectOption(position.Id,position.Name));
        }
        reloadAccountName();
        reloadStartDate();
        ListLocations = getListLocations();
        
        this.Opening.BMM__c = objBMM.getOpeningBMM(OpportunityId, this.Opening.Id, this.Opening.Position__c, this.Opening.Location__c, this.Opening.Quantity__c, this.Opening.Client_Interview_Requiered__c);
                
    }    
    
    public List<SelectOption> getListSeniorities ()
    {
        ListSeniorities = new List<SelectOption>();
        
        for(Seniorities_Per_Position__c seniority : 
            [SELECT id,seniority__r.id,seniority__r.Name
             FROM Seniorities_Per_Position__c 
             WHERE Position__c = :this.Opening.Position__c
             ORDER BY seniority__r.Name ASC]
        ){
            ListSeniorities.add(new SelectOption(seniority.seniority__r.id,seniority.seniority__r.Name));
        	if(seniority.seniority__r.Name == 'Ssr' && Opening.Id == null)
            {
                Opening.Seniority__c = seniority.seniority__r.id;
            }
        }
        return ListSeniorities;
    }
    
    public List<SelectOption> getListLocations ()
    {
        ListLocations = new List<SelectOption>();
        
        for(Location__c location : [SELECT id,Complete_Name__c FROM Location__c ORDER BY Complete_Name__c ASC])
        {
            ListLocations.add(new SelectOption(location.Id,location.Complete_Name__c));
            if(location.Complete_Name__c == 'Anywhere' && Opening.Id == null)
            {
             	Opening.Location__c = location.Id; 
            }
        }
        
        return ListLocations;
    }
    
    public PageReference reloadAccountName()
    {
        if ( Opening.Opportunity__c != null)
        {   
            Opportunity op = [SELECT Account.Name FROM Opportunity WHERE Id = :Opening.Opportunity__c];
            AccountName = op.Account.Name;
        }        
        return null;
    }
    
    public PageReference reloadListSeniorities()
    {
        this.ListSeniorities = this.getListSeniorities();
        
        for(SelectOption selopt : this.ListSeniorities)
        {
            //if Ssr Exists, select by Default
            if (selopt.getLabel() == 'Ssr')
            {
                Opening.Seniority__c = selopt.getValue();
            }
        }
        
        recalculateOpeningBMM();
        
        return null;
    }
    
    public PageReference reloadStartDate()
    {
        if(Opening.Opportunity__c != null)
        {
            String startDateUnit = Opening.Start_Date_Unit__c;
            Decimal startDateValue = Opening.Start_Date_Value__c;
            Opportunity objectOpportunity = [SELECT Contract_Type__c, CloseDate FROM Opportunity WHERE Id = :Opening.Opportunity__c];
            opportunityCloseDate = objectOpportunity.CloseDate;
            Date newDate = opportunityCloseDate;
            Integer intValue = 0;
            
            if(String.isBlank(startDateUnit)) {
                startDateUnit = 'Weeks';
            }
            
            if (startDateValue == null) {
                startDateValue = 3;
            }
            
            intValue = Integer.valueOf(startDateValue);
            
            if (startDateUnit == 'Days') {
                newDate = newDate.addDays(intValue);
                
            }
            else if(startDateUnit == 'Weeks') {
                newDate = newDate.addDays(intValue*7);
            }
            else if(startDateUnit == 'Months') {
                newDate = newDate.addMonths(intValue);
            }
            
            Opening.Start_Date__c = newDate;
        }
        
        return null;
    }
    
    public PageReference saveNew() 
    {   
        try
        {
            reloadStartDate();
            upsert Opening;
            Schema.DescribeSObjectResult describeResult = con.getRecord().getSObjectType().getDescribe(); 
            PageReference pr = new PageReference('/' + describeResult.getKeyPrefix() + '/e'); 
            pr.getParameters().put('OpportunityId',Opening.Opportunity__c);
            pr.setRedirect(true); 
            return pr;
        }
        catch (Exception ex)
        {
           ApexPages.addMessages(ex);
           return null;
        }
    }
    
    public PageReference SaveReturnOpening()
    {        
        try
        {
            reloadStartDate();
            upsert Opening;
            PageReference pr = new PageReference('/' + Opening.Opportunity__c); 
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception ex)
        {
           ApexPages.addMessages(ex);
           return null;
        }
    }
    
    public PageReference recalculateOpeningBMM()
    {
        this.Opening.BMM__c = objBMM.getOpeningBMM(OpportunityId, this.Opening.Id, this.Opening.Position__c, this.Opening.Location__c, this.Opening.Quantity__c, this.Opening.Client_Interview_Requiered__c);
        return null;
    }
}