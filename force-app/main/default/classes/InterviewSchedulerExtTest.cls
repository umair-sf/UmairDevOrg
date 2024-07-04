@isTest
private class InterviewSchedulerExtTest
{
    static testMethod void testMethod1()
    {
        InterviewSchedulerExt_UAC cont = new InterviewSchedulerExt_UAC();
        Interview__c interview = TestUtil.createInterview('Test', true);
        cont.getInterviews();
        cont.setInterviewId(interview.Id);
        cont.getInterviewId();
        cont.newRage();
        cont.gotoPage();
        cont.edit();
        cont.save();
        cont.cancel();
        cont.gotoPage = 2;
        cont.gotoPage();
    }
}