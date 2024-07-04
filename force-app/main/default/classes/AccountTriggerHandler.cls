public with sharing class AccountTriggerHandler
{
    public static void contactClonerToParent(List<Account> accounts, Map<Id,Account> oldMap)
    {
    	Set<Id> acIds = new Set<Id>();

    	Map<Id,List<Contact>> acIdtoContacts = new Map<Id,List<Contact>>();
		Map<Id,List<Id>> acIdtoChildAcIds = new Map<Id,List<Id>>();

		List<Contact> conToUpdate = new List<Contact>();

    	for(Account ac : accounts)
    	{
    		if(String.isNotBlank(ac.ParentId) && ac.ParentId != oldMap.get(ac.Id).ParentId)
    		{
    			acIds.add(ac.Id);

    			List<Id> acTempList = acIdtoChildAcIds.get(ac.ParentId);
    			if(acTempList==null)
    			{
    				acTempList = new List<Id>();
    				acIdtoChildAcIds.put(ac.ParentId, acTempList);
    			}
    			acTempList.add(ac.Id);
    		}
    	}
    	if(acIds.size()==0) return;

    	for(Contact con : [SELECT FirstName, LastName, Email, Phone, AccountId FROM Contact WHERE AccountId IN :acIds])
    	{
    		List<Contact> tempList = acIdtoContacts.get(con.AccountId);
			if(tempList == null)
	        {
	            tempList = new List<Contact>();
	            acIdtoContacts.put(con.AccountId, tempList);
	        }
	        tempList.add(con);
    	}

    	for(Id parentAcId : acIdtoChildAcIds.keySet())
    	{
    		List<Id> childAcList = acIdtoChildAcIds.get(parentAcId);
    		for(Id childAcId : childAcList)
    		{
    			if(acIdtoContacts.containsKey(childAcId))
    			{
    				List<Contact> contacts = acIdtoContacts.get(childAcId);
	    			for(Contact con : contacts)
	    			{
	    				con.AccountId = parentAcId;
	    				conToUpdate.add(con);
	    			}
    			}
    		}
    	}
    	if(conToUpdate.size()>0) update conToUpdate;
    }
}