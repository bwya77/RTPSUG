$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GroupsTable = New-Object 'System.Collections.Generic.List[System.Object]'
$LockedOutUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$PasswordNeverExpiresUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$PasswordExpiredUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'

[int]$usersenabled = 0
[int]$usersdisabled = 0

#Users
Get-ADUser -Filter * -Properties * | Sort-Object Name | ForEach-Object {
	If ($_.LockedOut -eq $True)
	{
		$obj = [PSCustomObject]@{
			
			'Name' = $_.Name
			'Locked' = $_.LockedOut
			'UserPrincipalName' = $_.UserPrincipalName
			'Enabled' = $_.Enabled
			'Password Never Expires' = $_.PasswordNeverExpires
		}
		
		$LockedOutUsersTable.Add($obj)
	}
	If ($_.PasswordNeverExpires -eq $True)
	{
		$obj = [PSCustomObject]@{
			
			'Name' = $_.Name
			'Password Never Expires' = $_.PasswordNeverExpires
			'UserPrincipalName' = $_.UserPrincipalName
			'Enabled' = $_.Enabled
		}
		
		$PasswordNeverExpiresUsersTable.Add($obj)
	}
	If ($_.PasswordExpired -eq $True)
	{
		$obj = [PSCustomObject]@{
			
			'Name' = $_.Name
			'Password Expired' = $_.PasswordExpired
			'UserPrincipalName' = $_.UserPrincipalName
			'Enabled' = $_.Enabled
		}
		
		$PasswordExpiredUsersTable.Add($obj)
	}
	$obj = [PSCustomObject]@{
		
		'Name' = $_.Name
		'UserPrincipalName' = $_.UserPrincipalName
		'Enabled' = $_.Enabled
		'SamAccountName' = $_.SamAccountName
		'Email Address' = $_.EmailAddress
		'Department' = $_.Department
		'ObjectClass' = $_.ObjectClass
		'Protected' = $_.ProtectedFromAccidentalDeletion
		'Created' = $_.WhenCreated
		'PW Expired' = $_.PasswordExpired
		'Locked Out' = $_.LockedOut
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

#Groups
Get-ADGroup -Filter * -Properties * | Sort-Object Name | ForEach-Object {
	$obj = [PSCustomObject]@{
		
		'Name' = $_.Name
		'Type' = $_.groupCategory
		'Scope' = $_.GroupScope
	}
	
	$GroupsTable.Add($obj)
}

Dashboard -Name 'Active Directory' -FilePath C:\Scripts\Results\Dashimo\7-UsersAndComputersAndGroupsAndSecurityV2.html {
	Tab -Name 'Users' {
		Section -Name 'Users' -Invisible {
			Section -Name 'Users' {
				Table -HideFooter -DataTable $UsersTable
			}
			Section -Name 'Computers' {
				Table -HideFooter -DataTable $ComputersTable
			}
		}
		Section -Name 'User Stats' <#-Invisible#>  {
			Section -Name 'Locked Out Users' {
				Panel {
					Table -HideFooter -DataTable $LockedOutUsersTable
				}
			}
			Section -Name 'Password Never Expires'{
				Panel {
					Table -HideFooter -DataTable $PasswordNeverExpiresUsersTable
				}
			}
			Section -Name 'Password Expired'{
				Panel {
					Table -HideFooter -DataTable $PasswordExpiredUsersTable
				}
			}
		}
	}
	Tab -Name 'Groups' {
		Section -Name 'Groups' <#-Invisible#> -Collapsable {
			Table -HideFooter -DataTable $GroupsTable
		}
	}
}