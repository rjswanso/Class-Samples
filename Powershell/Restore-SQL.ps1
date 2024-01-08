# Russell Swanson 011557243
try {
    #Import SQLServer Module
    if (Get-Module -Name sqlps) { Remove-Module sqlps}
    Import-Module -Name SQLServer
    #Set a string representing instance name SRV19-PRIMARY
    $sqlinstancename = ".\SQLEXPRESS"
    
    #Set a string equal to ClientDB name
    $dbName = "ClientDB"
    
    #Create connection to sql server
    $connectionstr = "Data Source=$($sqlinstancename);Initial Catalog-master;Integrated Security=True;"
    $sqlconn = New-Object System.Data.SqlClient.SqlConnection
    $sqlconn.ConnectionString = $connectionstr
    $sqlconn.Open()
    
    #Create check db squery statement
    $checkdbquery = "SELECT name FROM sys.databases WHERE name = '$(dbName)"

    #create command obj to run query
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand $checkdbquery, $sqlconn
    $sqlReader = $sqlCommand.ExecuteReader()
    
    if($sqlReader.Read()) {
        $sqlReader.Close()
        Write-Host -ForegroundColor Yellow "$(dbName) Database Found and deleting..."
        #Query to drop db
        $dropdbQuery = "Alter Database [$(dbName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE DROP DATABASE [$(dbName)]"
        $sqlCommand.CommandText = $dropdbQuery
        $sqlcommand.ExecuteNonQuery() | Out-Null
    }

    #Create db
    $createdbQuery = "CREATE DATABASE [$(dbName)]"
    $sqlCommand.CommandText = $createdbQuery
    $sqlCommand.ExecuteNonQuery() | Out-Null
    Write-Host -ForegroundColorYellow "DB Created as [$($sqlinstancename)].[$($dbName)]"

    #Create table query with client data
    $tbName = "Client_A_Contacts"

    $createTblQuery = "
        USE [$(dbName)]
        CREATE TABLE [$(tbName)] (
            first_name varchar(40),
            last_name varchar(40),
            city varchar(40),
            county varchar(40),
            zip varchar(40),
            officePhone varchar(40),
            mobilePhone varchar(40),
        )"
    
    #Create table in DB using query
    $sqlcommand.CommandText = $createTblQuery
    $sqlcommand.ExecuteNonQuery() | Out-Null
    Write-Host -ForegroundColor Yellow "Table Created as [$($sqlinstancename)].[$(dbName)].dbo.[$(tbName)]"

    # Import data from csv and insert into SQL
    $NewClients = Import-Csv $PSScriptRoot\NewClientsData.csv
    $insertQuery = "INSERT INTO [$($tbName)] (first_name,last_name,city,county,zip,officePhone,mobilePhone) "

    #For each client in the csv, update the db table with values
    foreach($client in $NewClients)
    {
    $vals = "VALUES ('$(NewClients.first_name)','$(NewClients.last_name)','$(NewClients.city)','$(NewClients.county)','$(NewClients.zip)','$(NewClients.officePhone)','$(NewClients.mobilePhone)')"
    $sqlCommand.CommandText = $insertQuery + $vals
    $sqlcommand.ExecuteNonQuery() | Out-Null
    }
    #Write out table results into text file
    Invoke-Sqlcmd -Database ClientDB –ServerInstance .\SQLEXPRESS -Query ‘SELECT * FROM dbo.Client_A_Contacts’ > .\SqlResults.txt
}
catch {
    Write-Host -ForegroundColor Red "Exception: Error Occured."
}
finally {
    $sqlconn.Close()
}






