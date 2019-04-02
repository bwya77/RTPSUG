$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$EnabledDisabledUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$EnabledDisabledComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'
[int]$EnabledUsers = 0
[int]$DisabledUsers = 0
[int]$EnabledComputers = 0
[int]$DisabledComputers = 0
 

#USERS
Get-ADUser -Filter * -Properties * | ForEach-Object {
	If ($_.Enabled -eq $True)
	{
		$EnabledUsers++
	}
	Else
	{
		$DisabledUsers++
	}
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

#Data for users enabled vs disabled pie graph
$obj = [PSCustomObject]@{
	
	'Name'  = 'Enabled'
	'Count' = $EnabledUsers
}

$EnabledDisabledUsersTable.Add($obj)

$obj = [PSCustomObject]@{
	
	'Name'  = 'Disabled'
	'Count' = $DisabledUsers
}

$EnabledDisabledUsersTable.Add($obj)


#COMPUTERS
Get-ADComputer -Filter * -Properties * | ForEach-Object {
	If ($_.Enabled -eq $True)
	{
		$EnabledComputers++
	}
	Else
	{
		$DisabledComputers++
	}
	
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

#Data for computers enabled vs disabled pie graph
$obj = [PSCustomObject]@{
	
	'Name'  = 'Enabled'
	'Count' = $EnabledComputers
}

$EnabledDisabledComputersTable.Add($obj)

$obj = [PSCustomObject]@{
	
	'Name'  = 'Disabled'
	'Count' = $DisabledComputers
}

$EnabledDisabledComputersTable.Add($obj)


#Report Items

$FinalReport = New-Object 'System.Collections.Generic.List[System.Object]'

#Enabled Users vs Disabled Users Pie Object
$EnabledDisabledUsersPieObject = Get-HTMLPieChartObject
$EnabledDisabledUsersPieObject.Title = "Enabled vs Disabled Users"
$EnabledDisabledUsersPieObject.Size.Height = 250
$EnabledDisabledUsersPieObject.Size.width = 250
$EnabledDisabledUsersPieObject.ChartStyle.ChartType = 'doughnut'
$EnabledDisabledUsersPieObject.ChartStyle.ColorSchemeName = 'Random'


#Enabled Users vs Disabled Computers Pie Object
$EnabledDisabledComputersPieObject = Get-HTMLPieChartObject
$EnabledDisabledComputersPieObject.Title = "Enabled vs Disabled Computers"
$EnabledDisabledComputersPieObject.Size.Height = 250
$EnabledDisabledComputersPieObject.Size.width = 250
$EnabledDisabledComputersPieObject.ChartStyle.ChartType = 'doughnut'
$EnabledDisabledComputersPieObject.ChartStyle.ColorSchemeName = 'Random'


#Change CSS Template to FakeCompany template in C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.2, changed background color to #4E89C6
#LeftLogo is now complogo.png
$FinalReport.Add($(Get-HTMLOpenPage -CSSName "FakeCompany" -TitleText "Active Directory Report" -LeftLogoString "C:\complogo.png"))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Users"))
$FinalReport.Add($(Get-HTMLContentDataTable -HideFooter $UsersTable))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Computers"))
$FinalReport.Add($(Get-HTMLContentDataTable -HideFooter $ComputersTable))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Charts"))
	$FinalReport.Add($(Get-HTMLColumn1of2))
		$FinalReport.Add($(Get-HTMLPieChart -ChartObject $EnabledDisabledUsersPieObject -DataSet $EnabledDisabledUsersTable))
	$FinalReport.Add($(Get-HTMLColumnClose))
	$FinalReport.Add($(Get-HTMLColumn2of2))
		$FinalReport.Add($(Get-HTMLPieChart -ChartObject $EnabledDisabledComputersPieObject -DataSet $EnabledDisabledComputersTable))
	$FinalReport.Add($(Get-HTMLColumnClose))
$FinalReport.Add($(Get-HTMLContentClose))

$FinalReport.Add($(Get-HTMLClosePage))

Save-HTMLReport -ReportContent $FinalReport -ShowReport -ReportName "AD Report" -ReportPath "C:\Automation\"
