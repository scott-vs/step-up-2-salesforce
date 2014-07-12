public with sharing class AuthController {

    public Boolean authorizedUser { get; set; }

    public String service { get; set; }
    
    public String authUrl { get; set; }
    
    public boolean authSuccess { get; set; }

    public String message { get; set; }
    
    public List<Fitbit_Day__c> getMyFDays(){
        List<Fitbit_Day__c> myFDays = new List<Fitbit_Day__c>();
        myFDays = [SELECT Date__c,Fairly_Active_Minutes__c,Floors__c,
                      			Lightly_Active_Minutes__c,Sedentary_Minutes__c,
                      			Very_Active_Minutes__c, Steps__c
                      FROM Fitbit_Day__c 
                      WHERE User__c =: UserInfo.getUserID() 
                      ORDER BY Date__c DESC NULLS FIRST];
        return myFDays;
        
    }
    public List<String> getStrings() {
        return new String[]{'ONE','TWO','THREE'};
    }
    
    // controller
    public AuthController(){
        authorizedUser = false;
        List<OAuth_Token__c> myTokens = [SELECT Id FROM OAuth_Token__c WHERE isAccess__c = true AND Owner__c =: UserInfo.getUserID()]; 
        
        //system.debug('myTokens ' + myTokens);
        if (myTokens.size()>0){
            authorizedUser = true;
            /*myFDays = [SELECT Date__c,Fairly_Active_Minutes__c,Floors__c,
                      			Lightly_Active_Minutes__c,Sedentary_Minutes__c,
                      			Very_Active_Minutes__c 
                      FROM Fitbit_Day__c 
                      WHERE User__c =: UserInfo.getUserID() 
                      ORDER BY Date__c DESC NULLS FIRST];
            system.debug('myDays ' + myFDays); */
        }
    
    }

    public List<SelectOption> services {
        get {
            if(services==null) {
                List<OAuthService__c> l = [SELECT name FROM OAuthService__c];
                services = new List<SelectOption>();
                for(OAuthService__c obj : l) {
                    services.add(new SelectOption(obj.name,obj.name));
                    System.debug('service: '+obj.name);
                }
            }
            return services;
        }
        set;
    }
    
    public PageReference authorize() {
        OAuth oa = new OAuth();
        authUrl = oa.newAuthorization('Fitbit');
        System.debug(authUrl);
        if(authUrl==null) {
                this.message = oa.message;
                return null;
        } else {
                
                return new PageReference(authUrl);
        }
    }
    
    public PageReference completeAuthorization() {
        String token = ApexPages.currentPage().getParameters().get('oauth_token');
        if(token!=null)
        {
            String verifier = ApexPages.currentPage().getParameters().get('oauth_verifier');
            OAuth oa = new OAuth();
            authSuccess = oa.completeAuthorization(token,verifier);
            this.message = oa.message;
        }
        else {
            message = 'Invalid request. Missing parameter oauth_token';
        }
        return null;
    }
    
}