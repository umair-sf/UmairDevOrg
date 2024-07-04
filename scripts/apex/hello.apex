// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

List<Contact> conlist = [SELECT Id,LastName, Logo__c, Rank__c FROM Contact];
for(Contact con:conlist)
{
    if(con.LastName == 'Raza')
    {
        con.Rank__c = 1;
        con.Logo__c = 'https://ternedge.com/wp-content/uploads/2022/08/Standard-Black-300x75.png'; 
    }
    else if(con.LastName == 'Ahmad')
    {
        con.Rank__c = 1;
        con.Logo__c = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTiF7hK6OchPwrCJvEDtIuGe51ooIG_z0pWFA&s'; 
    }
    else if(con.LastName == 'Ali')
    {
        con.Rank__c = 2;
        con.Logo__c = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqSf7DfZwwKaxCeG4ThHQgwjLUPTsCGJBufQ&s'; 
    }
}
update conlist;