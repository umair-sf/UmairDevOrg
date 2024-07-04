public with sharing class ContentVersionTriggerHandler
{
	public static void createContentDistribution(List<ContentVersion> conVersions)
    {
        List<ContentDistribution> conDistributions = new List<ContentDistribution>();
        for(ContentVersion conVersion: conVersions)
        {
            ContentDistribution conDis = new ContentDistribution();
            conDis.Name = conVersion.Title;
            conDis.ContentVersionId = conVersion.Id;
            conDis.PreferencesExpires = false;
            conDis.PreferencesAllowPDFDownload = false;
            conDis.PreferencesAllowOriginalDownload = false;
            conDis.PreferencesPasswordRequired = false;
            conDis.PreferencesAllowViewInBrowser = true;
            conDistributions.add(conDis);
        }
        if(conDistributions.size()>0) insert conDistributions;
    }
}