$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'

#USERS
Get-ADUser -Filter * -Properties * | Sort-Object Name | ForEach-Object {
	$obj = [PSCustomObject]@{
		
		'Name' = $_.Name
		'UserPrincipalName' = $_.UserPrincipalName
		'Enabled' = $_.Enabled
		'Last Logon' = $_.PasswordNeverExpires
	}
	
	$UsersTable.Add($obj)
}

if (($UsersTable).Count -eq 0)
{
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No users were found in Active Directory'
	}
	$UsersTable.Add($obj)
}

#COMPUTERS
Get-ADComputer -Filter * -Properties * | Sort-Object Name | ForEach-Object {
	$obj = [PSCustomObject]@{
		
		'Name' = $_.Name
		'Enabled' = $_.Enabled
		'Last Logon' = $_.ProtectedFromAccidentalDeletion
	}
	
	$ComputersTable.Add($obj)
}

if (($ComputersTable).Count -eq 0)
{
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No users were found in Active Directory'
	}
	$ComputersTable.Add($obj)
}


$FinalReport = New-Object 'System.Collections.Generic.List[System.Object]'
#Change CSS Template to FakeCompany template in C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.2, changed background color to #4E89C6
#LeftLogo is now complogo.png
$FinalReport.Add($(Get-HTMLOpenPage -CSSName "FakeCompany" -TitleText "Active Directory Report" -LeftLogoString "C:\complogo.png"))
	$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Users"))
		$FinalReport.Add($(Get-HTMLContentTable $UsersTable))
	$FinalReport.Add($(Get-HTMLContentClose))
	$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Computers"))
		$FinalReport.Add($(Get-HTMLContentTable $ComputersTable))
	$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLClosePage))

Save-HTMLReport -ReportContent $FinalReport -ShowReport -ReportName "3-AD Users and Computers Report v1" -ReportPath "C:\Scripts\Results\ReportHTML\"
