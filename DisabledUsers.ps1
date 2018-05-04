# Search disabled users and his out dates in Senior RH database

$connectionString = "Data Source=<host>;initial catalog=<database>;persist security info=True;multipleactiveresultsets=True;user id=<user>;password=<pass>;"
$sqlCommand = "select numcad,datafa from r034fun"

$connection = new-object system.data.SqlClient.SQLConnection($connectionString)
$command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
$connection.Open()

$adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataSet) | Out-Null

$connection.Close()
$rhDisabledUsers = $dataSet.Tables

# Search disabled users in Active Directory, that login starts with u

$disabledUsers = Get-ADUser -Filter {Enabled -eq $false -and SamAccountName -like 'u*'} -Properties *  | Select-Object 'SamAccountName', 'Name', 'mail', 'zarafaAccount', 'EmployeeId'

# Add out date to active directory users

ForEach($disabledUser in $disabledUsers)
{
    $rhDisabledUser = $rhDisabledUsers.Rows | Where-Object {($_.numcad -eq $disabledUser.EmployeeId)} | Select-Object -First 1

    if ($rhDisabledUser)
    {
        Add-Member -InputObject $disabledUser -NotePropertyName "datafa" -NotePropertyValue $rhDisabledUser.datafa
    }
}

$disabledUsers | Export-Csv -Path "data.csv"
