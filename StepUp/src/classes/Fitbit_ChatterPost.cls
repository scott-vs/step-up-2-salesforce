public class Fitbit_ChatterPost {
    static public void sendOutTheMadProps(){
        
        List<CollaborationGroup> chatterGroups = [SELECT Id FROM CollaborationGroup WHERE Name = 'Step Up Group'];
        List<Fitbit_Day__c> rank = [SELECT Steps__c,User__c FROM Fitbit_Day__c WHERE Date__c = YESTERDAY ORDER BY Steps__c DESC];
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        textSegmentInput.text = 'Mad props to ';
		messageBodyInput.messageSegments.add(textSegmentInput);
        
        mentionSegmentInput.id = rank[0].User__c;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        textSegmentInput2.text = ' for scoring the most yesterday with '+rank[0].Steps__c+' steps.';
		messageBodyInput.messageSegments.add(textSegmentInput2);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = chatterGroups[0].id;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput, null);
        
    }

}