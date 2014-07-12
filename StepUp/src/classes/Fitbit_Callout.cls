public class Fitbit_Callout{
    
    public static void fitbitCallout(ID userId, Integer days){
        List<OAuthService__c> l = [SELECT name FROM OAuthService__c];
        if (l.size() == 0) {
            return;
        }
        String keyName = l[0].name;
        List<Fitbit_Day__c> fDays = new List<Fitbit_Day__c>();
        DateTime myDate = System.now();
        for (integer x = 0; x < days; x++){
            String d = myDate.format('YYYY-MM-dd');
            system.debug('my d ' + d);
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint('http://api.fitbit.com/1/user/-/activities/date/'+d+'.json');
            System.debug('endpoint ' + req.getEndpoint());
            OAuth oa = new OAuth();
            if(!oa.setService(keyName,userId)) {
                System.debug(oa.message);
            } else {
                oa.sign(req);
                System.debug('Sending request...');
                HttpResponse res = h.send(req);
                String body = res.getBody();
                System.debug('Received response ('+res.getStatusCode()+' '+res.getStatus()+')');
                
                System.debug(body);
                
                Fitbit_Day__c fd = new Fitbit_Day__c();
                Id myID =  userId;
                fd.User__c = myID;
                fd.Date__c = date.newinstance(myDate.year(), myDate.month(), myDate.day());
                fd.External_ID__c = myID + d;
                
                JSONParser parser = JSON.createParser(body);
                while (parser.nextToken() != null) {
                    system.debug(parser.getCurrentToken());
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                                (parser.getText() == 'summary')) { 
                        while (parser.nextToken() != null) {
                             if (parser.getCurrentToken() == JSONToken.FIELD_NAME) { 
                                    if (parser.getText() == 'steps'){
                                        parser.nextToken();
                                        fd.Steps__c = parser.getIntegerValue();
                                    } else if (parser.getText() == 'floors'){
                                        parser.nextToken();
                                        fd.Floors__c = parser.getIntegerValue();
                                    } else if (parser.getText() == 'lightlyActiveMinutes'){
                                        parser.nextToken();
                                        fd.Lightly_Active_Minutes__c = parser.getIntegerValue();
                                    } else if (parser.getText() == 'fairlyActiveMinutes'){
                                        parser.nextToken();
                                        fd.Fairly_Active_Minutes__c = parser.getIntegerValue();
                                    } else if (parser.getText() == 'sedentaryMinutes'){
                                        parser.nextToken();
                                        fd.Sedentary_Minutes__c = parser.getIntegerValue();
                                    } else if (parser.getText() == 'veryActiveMinutes'){
                                        parser.nextToken();
                                        fd.Very_Active_Minutes__c = parser.getIntegerValue();
                                    }
                             }
                        }
                    }
                }
                fDays.add(fd);
            }
            
            myDate = myDate.addDays(-1);
        }
        
        upsert fDays External_ID__c;   
    }

}