$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'

#Users
Get-ADUser -Filter * -Properties * | Sort-Object Name | ForEach-Object {
	$obj = [PSCustomObject]@{
		
		'Name' = $_.Name
		'UserPrincipalName' = $_.UserPrincipalName
		'Enabled' = $_.Enabled
		'SamAccountName' = $_.SamAccountName
	}
	$UsersTable.Add($obj)
}

#Computers
Get-ADComputer -Filter * -Properties * | Sort-Object Name | ForEach-Object {
	$obj = [PSCustomObject]@{
		
		'Name' = $_.Name
		'Enabled' = $_.Enabled
		'Last Logon' = $_.ProtectedFromAccidentalDeletion
	}
	$ComputersTable.Add($obj)
}


Dashboard -Name 'Active Directory' -FilePath C:\Scripts\Results\Dashimo\3-UsersAndComputersV2.html {
	Section -Name 'Users' -Invisible {
		Section -Name 'Users' {
			Table -HideFooter -DataTable $UsersTable
		}
		Section -Name 'Computers' {
			Table -HideFooter -DataTable $ComputersTable
		}
	}
}