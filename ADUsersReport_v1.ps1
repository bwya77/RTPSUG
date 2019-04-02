$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'


Get-ADUser -Filter * -Properties * | ForEach-Object {
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


$FinalReport = New-Object 'System.Collections.Generic.List[System.Object]'
$FinalReport.Add($(Get-HTMLOpenPage -TitleText "AD Users Report"))
$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Users"))
$FinalReport.Add($(Get-HTMLContentTable $UsersTable))
$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLClosePage))
Save-HTMLReport -ReportContent $FinalReport -ShowReport -ReportName "AD Users Report" -ReportPath C:\Automation\Users.HTML
