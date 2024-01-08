# Russell Swanson 011557243
try {
    #Searches for OU named Finance and deletes OU if it exists
    if ((Get-ADOrganizationalUnit -filter {Name -like 'finance'}).distinguishedName) {
        Remove-ADOrganizationalUnit -Identity (Get-ADOrganizationalUnit -filter {Name -like 'finance'}).distinguishedName
        Write-Host "Finance OU found and deleted."
    }
    #Creates a new Finance OU
    New-ADOrganizationalUnit -name 'Finance' -ProtectedFromAccidentalDeletion $False
    Write-Host "New Finance OU Created."
    #Creates Finance OU's distinguished name variable
    $OUdistName = (Get-ADOrganizationalUnit -filter {Name -like 'finance'}).distinguishedName
    #Pulls finance personel data from csv
    $userinfo = Import-Csv $PSScriptRoot\financePersonnel.csv

    #For each loop running through each user record in the personnel file
    foreach($user in $userinfo) {
        #Creating a parameters variable for Splatting
        $parameters = @{
            Name = "$($user.First_Name) $($user.Last_Name)"
            GivenName = $user.First_Name
            Surname = $user.Last_Name
            City = $user.City
            DisplayName = "$($user.First_Name) $($user.Last_Name)"
            PostalCode = $user.PostalCode
            OfficePhone = $user.OfficePhone
            MobilePhone = $user.MobilePhone
            Path = $OUdistName
        }
        #Creates user with parameters above
        New-ADUser @parameters 
        Write-Host "$($user.First_Name) Write-Host $($user.Last_Name) has been added"
    }
    #Writes users from Finance OU to text file for record keeping
    Get-ADUser -Filter * -SearchBase “ou=Finance,dc=consultingfirm,dc=com” -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > .\AdResults.txt
}
catch {
    Write-Host -ForegroundColor Red "Exception: Error Occured."
}
finally {
    
}
