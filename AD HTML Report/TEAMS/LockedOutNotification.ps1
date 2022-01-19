﻿<#	
	.NOTES
	===========================================================================
	 Created on:   	12/13/2018 3:57 PM
	 Created by:   	Bradley Wyatt
	 Filename:     	PSPush_LockedOutUsers.ps1
	===========================================================================
	.DESCRIPTION
		Sends a Teams notification via webhook of a recently locked out user. Set up a scheduled task to trigger on event ID 4740. 
#>

#Teams webhook url
$uri = "https://outlook.office.com/webhook/eee030b9-93ef-4fae-add9-17bf369d1101@6438b2c9-54e9-4fce-9851-f00c24b5dc1f/IncomingWebhook/41a30c93412a43a2b3d51763e4dff1f7/5bcffade-2afd-48a2-8096-390a9090555c"

#Image on the left hand side, here I have a regular user picture
$ItemImage = 'https://img.icons8.com/color/1600/circled-user-male-skin-type-1-2.png'

$ArrayTable = New-Object 'System.Collections.Generic.List[System.Object]'

$Event = Get-EventLog -LogName Security -InstanceId 4740 | Select-object -First 1
[string]$Item = $Event.Message
$Item.SubString($Item.IndexOf("Caller Computer Name"))
$sMachineName = $Item.SubString($Item.IndexOf("Caller Computer Name"))
$sMachineName = $sMachineName.TrimStart("Caller Computer Name :")
$sMachineName = $sMachineName.TrimEnd("}")
$sMachineName = $sMachineName.Trim()
$sMachineName = $sMachineName.TrimStart("\\")

$RecentLockedOutUser = Search-ADAccount -server localhost -LockedOut | Get-ADUser -Properties badpwdcount, lockoutTime, lockedout, emailaddress | Select-Object badpwdcount, lockedout, Name, EmailAddress, SamAccountName, @{ Name = "LockoutTime"; Expression = { ([datetime]::FromFileTime($_.lockoutTime).ToLocalTime()) } } | Sort-Object LockoutTime -Descending | Select-Object -first 1

$RecentLockedOutUser | ForEach-Object {
	
	$Section = @{
		activityTitle = "$($_.Name)"
		activitySubtitle = "$($_.EmailAddress)"
		activityText  = "$($_.Name)'s account was locked out at $(($_.LockoutTime).ToString("hh:mm:ss tt")) and may require additional assistance"
		activityImage = $ItemImage
		facts		  = @(
			@{
				name  = 'Lockout Source:'
				value = $sMachineName
			},
			@{
				name  = 'Lock-Out Timestamp:'
				value = $_.LockoutTime.ToString()
			},
			@{
				name  = 'Locked Out:'
				value = $_.lockedout
			},
			@{
				name  = 'Bad Password Count:'
				value = $_.badpwdcount
			},
			@{
				name  = 'SamAccountName:'
				value = $_.SamAccountName
			}
		)
	}
	$ArrayTable.add($section)
}

$body = ConvertTo-Json -Depth 8 @{
	title = "Locked Out User - Notification"
	text  = "$($RecentLockedOutUser.Name)'s account got locked out at $(($RecentLockedOutUser.LockoutTime).ToString("hh:mm:ss tt"))"
	sections = $ArrayTable
	
}
Write-Host "Sending lockedout account POST" -ForegroundColor Green
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'