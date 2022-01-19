$UsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GroupsTable = New-Object 'System.Collections.Generic.List[System.Object]'
$EnabledDisabledUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$EnabledDisabledComputersTable = New-Object 'System.Collections.Generic.List[System.Object]'
$GroupTypeTable = New-Object 'System.Collections.Generic.List[System.Object]'
[int]$EnabledUsers = 0
[int]$DisabledUsers = 0
[int]$EnabledComputers = 0
[int]$DisabledComputers = 0
[int]$SecurityGroups = 0
[int]$DistributionGroups = 0


#USERS
Get-ADUser -Filter * -Properties * | Sort-Object Name | ForEach-Object {
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
Get-ADComputer -Filter * -Properties * | Sort-Object Name | ForEach-Object {
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


#GROUPS
Get-ADGroup -Filter * -Properties * | Sort-Object Name | ForEach-Object {
	If ($_.groupCategory -eq "Distribution")
	{
		$DistributionGroups++
	}
	Else
	{
		$SecurityGroups++
	}
	$obj = [PSCustomObject]@{
		
		'Name' = $_.Name
		'Type' = $_.groupCategory
		'Scope' = $_.GroupScope
	}
	
	$GroupsTable.Add($obj)
}
if (($GroupsTable).Count -eq 0)
{
	$Obj = [PSCustomObject]@{
		
		Information = 'Information: No users were found in Active Directory'
	}
	$GroupsTable.Add($obj)
}

#Data for computers enabled vs disabled pie graph
$obj = [PSCustomObject]@{
	
	'Name'  = 'Security Groups'
	'Count' = $SecurityGroups
}

$GroupTypeTable.Add($obj)

$obj = [PSCustomObject]@{
	
	'Name'  = 'Distribution Groups'
	'Count' = $DistributionGroups
}

$GroupTypeTable.Add($obj)



#Report Items

$FinalReport = New-Object 'System.Collections.Generic.List[System.Object]'

$tabarray = @('Dashboard', 'Groups')

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


#Group Type Pie Object
$GroupTypePieObject = Get-HTMLPieChartObject
$GroupTypePieObject.Title = "Group Types"
$GroupTypePieObject.Size.Height = 250
$GroupTypePieObject.Size.width = 250
$GroupTypePieObject.ChartStyle.ChartType = 'doughnut'
$GroupTypePieObject.ChartStyle.ColorSchemeName = 'Random'



#Change CSS Template to FakeCompany template in C:\Program Files\WindowsPowerShell\Modules\ReportHTML\1.4.1.2, changed background color to #4E89C6
#LeftLogo is now complogo.png
$FinalReport.Add($(Get-HTMLOpenPage -CSSName "FakeCompany" -TitleText "Active Directory Report" -LeftLogoString "C:\complogo.png"))

$FinalReport.Add($(Get-HTMLTabHeader -TabNames $tabarray))
	$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[0] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))

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

	$FinalReport.Add($(Get-HTMLTabContentClose))


	$FinalReport.Add($(Get-HTMLTabContentopen -TabName $tabarray[1] -TabHeading ("Report: " + (Get-Date -Format MM-dd-yyyy))))

	$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Groups"))
		$FinalReport.Add($(Get-HTMLContentDataTable -HideFooter $GroupsTable))
	$FinalReport.Add($(Get-HTMLContentClose))
	$FinalReport.Add($(Get-HTMLContentOpen -HeaderText "Charts"))
		$FinalReport.Add($(Get-HTMLPieChart -ChartObject $GroupTypePieObject -DataSet $GroupTypeTable))
	$FinalReport.Add($(Get-HTMLContentClose))

	$FinalReport.Add($(Get-HTMLTabContentClose))

$FinalReport.Add($(Get-HTMLClosePage))

Save-HTMLReport -ReportContent $FinalReport -ShowReport -ReportName "6-ADUsersandComputersReportv3DataTablePieChart" -ReportPath "C:\Scripts\Results\ReportHTML\"
