@isTest
public class BMM_Test {
    @isTest
    public static void getOpeningBMM()
    {
        TestData TD = new TestData();
        TD.loadInitialParams();
        TD.loadFullOpenings();

        TD.Opening1.Position__c = TD.ListPositions.get(2).Id;
        Decimal opeBMM = TD.Opening1.BMM__c;
        Decimal newBMM = 0;
        BMM objBMM = new BMM();

        Test.startTest();
        	newBMM = objBMM.getOpeningBMM(TD.opp1.Id, TD.Opening1.Id, TD.Opening1.Position__c, TD.Opening1.Location__c, TD.Opening1.Quantity__c, TD.Opening1.Client_Interview_Requiered__c);
        Test.stopTest();

        Opening__c TestOpe1 = [SELECT Id, BMM__c FROM Opening__c WHERE Id = :TD.Opening1.Id];

        System.assertNotEquals(TestOpe1.BMM__c, opeBMM);
    }

    public class TestData
    {
        public List<Position__c> ListPositions;
        public List<Seniority__c> ListSeniorities;
        public List<Seniorities_Per_Position__c> ListSenioritiesPos;
        public List<Location__c> ListLocations;
        public Opportunity Opp1;
        public Account Acc;
        public String TypeContract;
        public Opening__c Opening1;
        public BMM_Quantity_Entity__c BMMQty1;
        public BMM_Quantity_Entity__c BMMQty2;
        public Interview_BMM_Value__c IBMM1;
        public Interview_BMM_Value__c IBMM2;
        public Position_Location_BMM__c PLBMM1;
        public Position_Location_BMM__c PLBMM2;

        public TestData(String TypeContract)
        {
            this.TypeContract = TypeContract;
            LoadInitialParams();
        }

        public TestData()
        {
            this.TypeContract = null;
            LoadInitialParams();
        }

        public Void LoadInitialParams()
        {
            Acc = new Account();
            Acc.Name = 'Test Account';
            insert Acc;

            Opp1 = new Opportunity();
            Opp1.Name = 'Test Opportunity 1';
            Opp1.AccountId = Acc.Id;
            Opp1.Amount = 20;
            Opp1.StageName = 'Initial StageName';
            Opp1.CloseDate = System.today();
            Opp1.Openings__c = 5;
            Opp1.StageName = 'Pipeline';
            Opp1.Probability = 20;
            Opp1.Lead__c = 'Conference';
            Opp1.Type_of_deliverable__c = 'IAMAT';
            Opp1.Presales_contact__c = 'None';
            if(TypeContract != null)
            {
                Opp1.Contract_Type__c = TypeContract;
            }
            insert Opp1;

            ListPositions = new List<Position__c>();
            ListPositions.add(new Position__c(Name='Java Developer'));
            ListPositions.add(new Position__c(Name='Salesforce Developer'));
            ListPositions.add(new Position__c(Name='HTML Designer'));
            Insert ListPositions;

            ListSeniorities = new List<Seniority__c>();
            ListSeniorities.add(new Seniority__c(Name='Sr'));
            ListSeniorities.add(new Seniority__c(Name='Jr'));
            ListSeniorities.add(new Seniority__c(Name='Ssr'));
            Insert ListSeniorities;

            ListSenioritiesPos = new List<Seniorities_Per_Position__c>();

            for(Position__c pos : ListPositions)
            {
                for(Seniority__c srt: ListSeniorities)
                {
                    Seniorities_Per_Position__c spp = new Seniorities_Per_Position__c();
                    spp.Position__c = pos.id;
                    spp.Seniority__c = srt.id;
                    ListSenioritiesPos.add(spp);
                }
            }

            insert ListSenioritiesPos;

            ListLocations = new List<Location__c>();
            ListLocations.add(new Location__c(Name='CO', Complete_Name__c = 'Colombia'));
            ListLocations.add(new Location__c(Name='AR', Complete_Name__c = 'Argentina' ));

            Insert ListLocations;
        }

        public Void loadFullOpenings()
        {
            this.loadBMMTables();
            Opening1 = new Opening__c();
            Opening1.Duration__c = 2;
            Opening1.Location__c = ListLocations.get(0).Id;
            Opening1.Unit__c = 'Weeks';
            Opening1.Sale_Rate__c = 10;
            Opening1.Sale_Rate_Unit__c = 'Hour';
            Opening1.load__c = 0.2;
            Opening1.Quantity__c = 5;
            Opening1.Start_Date__c = System.today();
            Opening1.Opportunity__c = opp1.id;
            Opening1.Position__c = ListSenioritiesPos.get(0).Position__c;
            Opening1.Seniority__c = ListSenioritiesPos.get(0).Seniority__c;
            Opening1.Client_Interview_Requiered__c = true;

            Insert Opening1;
        }

        public void loadBMMTables()
        {
            BMMQty1 = new BMM_Quantity_Entity__c();
            BMMQty1.Quantity__c = 5;
            BMMQty1.Value__c = 2;
            insert BMMQty1;

            BMMQty2 = new BMM_Quantity_Entity__c();
            BMMQty2.Quantity__c = 6;
            BMMQty2.Value__c = 3;
            insert BMMQty2;

            IBMM1 = new Interview_BMM_Value__c();
            IBMM1.Interview_Required__c = true;
            IBMM1.Location__c = ListLocations.get(0).Id;
            IBMM1.Value__c = 10;
            insert IBMM1;

            IBMM2 = new Interview_BMM_Value__c();
            IBMM2.Interview_Required__c = false;
            IBMM2.Location__c = ListLocations.get(0).Id;
            IBMM2.Value__c = 5;
            insert IBMM2;

            PLBMM1 = new Position_Location_BMM__c();
            PLBMM1.Location__c = ListLocations.get(0).Id;
            PLBMM1.Position__c = ListPositions.get(0).Id;
            PLBMM1.Value__c = 5;
            insert PLBMM1;

            PLBMM2 = new Position_Location_BMM__c();
            PLBMM2.Location__c = ListLocations.get(1).Id;
            PLBMM2.Position__c = ListPositions.get(2).Id;
            PLBMM2.Value__c = 10;
            insert PLBMM2;
        }
    }
}