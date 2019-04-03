$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'


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

$FinalReport = New-Object 'System.Collections.Generic.List[System.Object]'
#Change CSS Template to FakeCompany template in C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.2, changed background color to #4E89C6
#LeftLogo is now complogo.png
$FinalReport.Add($(Get-HTMLOpenPage -CSSName "FakeCompany" -TitleText "AD Users Report" -LeftLogoString "C:\complogo.png"))
	$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Users"))
		$FinalReport.Add($(Get-HTMLContentTable $UsersTable))
	$FinalReport.Add($(Get-HTMLContentClose))
$FinalReport.Add($(Get-HTMLClosePage))
Save-HTMLReport -ReportContent $FinalReport -ShowReport -ReportName "2-ADUsersReportv2" -ReportPath "C:\Scripts\Results\ReportHTML\"
