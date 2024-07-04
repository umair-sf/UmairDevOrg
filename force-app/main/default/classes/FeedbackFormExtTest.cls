@isTest
private class FeedbackFormExtTest
{
    static testMethod void testMethod1()
    {
        FeedbackFormExt cont = new FeedbackFormExt();
        Feedback__c feed = new Feedback__c(Feedback_Date__c = Date.today(), Feedback_Giver__c=Userinfo.getUserId(), Feedback_Type__c='Positive', Feedback_Rating__c='Good');
        insert feed;
        cont.feedbackId = feed.Id;
        cont.newRage();
        cont.gotoPage();
        cont.gotoPage=3;
        cont.gotoPage();
        cont.edit();
        cont.getFeedbacks();

    }
}