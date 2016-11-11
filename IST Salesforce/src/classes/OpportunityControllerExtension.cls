public with sharing class OpportunityControllerExtension {
	public Opportunity opp;
    
    public OpportunityControllerExtension(ApexPages.StandardController stdController)
    {
        this.opp = (Opportunity)stdController.getRecord();
    }
    
    public PageReference Dismiss()
    {
        System.debug('Id del Opp' + opp.Id);
        opp.Display_Alert__c = false;
        update opp;
        System.debug('Display Alert' + opp.Display_Alert__c);
        return null;
        
        /*PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;*/
    }
}