$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'

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


Dashboard -Name 'Active Directory' -FilePath C:\Scripts\Results\Dashimo\1-UsersV1.html {
	Section -Name 'Users' -Invisible {
		Section -Name 'Users' {
			Table -HideFooter -DataTable $UsersTable
		}
	}
}