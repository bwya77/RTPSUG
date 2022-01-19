<#	
	.NOTES
	===========================================================================
	 Created on:   	12/13/2018 3:57 PM
	 Created by:   	Bradley Wyatt
	 Filename:     	PSPush_NewlyCreatedUser.ps1
	===========================================================================
	.DESCRIPTION
		Sends a Teams notification via webhook of a recently created out user. Set up a scheduled task to trigger on event ID 4720. 
#>

#Teams webhook url
$uri = "https://outlook.office.com/webhook/eee030b9-93ef-4fae-add9-17bf369d1101@6438b2c9-54e9-4fce-9851-f00c24b5dc1f/IncomingWebhook/5cbe9b89d8ac438daac355d864f403fa/5bcffade-2afd-48a2-8096-390a9090555c"

#Image on the left hand side, here I have a regular user picture
$ItemImage = 'https://img.icons8.com/color/1600/circled-user-male-skin-type-1-2.png'

$ArrayTable = New-Object 'System.Collections.Generic.List[System.Object]'

$Event = Get-EventLog -LogName Security -InstanceId 4720 | Select-object -First 1
$AccountThatCreated = $Event | Select-Object -Expand Message | Select-String '(?<=subject:\s+security id:\s+\S+\s+account name:\s+)\S+' | Select-Object -Expand Matches | Select-Object -Expand Value
$SamAccountName = $Event | Select-Object -Expand Message | Select-String '(?<=new account:\s+security id:\s+\S+\s+account name:\s+)\S+' | Select-Object -Expand Matches | Select-Object -Expand Value

$NewUser = Get-ADUser -Filter "sAMAccountName -eq '$SamAccountName'" -Properties *

$NewUser | ForEach-Object {
	
	$Section = @{
		activityTitle = "$($_.Name)"
		activitySubtitle = "$($_.EmailAddress)"
		activityText  = "A new user account was created by: $AccountThatCreated"
		activityImage = $ItemImage
		facts		  = @(
			@{
				name  = 'Created:'
				value = $_.whenCreated
			},
			@{
				name  = 'User Principal Name:'
				value = $_.UserPrincipalName
			},
			@{
				name  = 'SamAccountName:'
				value = $_.SamAccountName
			},
			@{
				name  = 'Protected:'
				value = $_.ProtectedFromAccidentalDeletion
			}
		)
	}
	$ArrayTable.add($section)
}

$body = ConvertTo-Json -Depth 8 @{
	title = "Newly Created User - Notification"
	text  = "A new user account was created by: $AccountThatCreated"
	sections = $ArrayTable
	
}
Write-Host "Sending lockedout account POST" -ForegroundColor Green
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'