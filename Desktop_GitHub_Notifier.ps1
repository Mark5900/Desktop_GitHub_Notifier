$GithubOrg = $null # Set the link to your organization
$GithubProject = $null # Set the link to your project

$pollInterval = 60
$lastPollDate = [DateTime]::MinValue
$githubToken = Get-Content 'C:\PowerShell\GitHub_Notifier\github_token.txt'

$ti = New-TaskbarItem -Title 'Github Notifier' -OnClicked {
    & explorer 'https://github.com/notifications'
}

Set-TaskbarItemTimerFunction $ti -IntervalInMillisecond 1000 {
    $elapsedSeconds = ((Get-Date) - $script:lastPollDate).TotalSeconds
    $progress = [Math]::Min($elapsedSeconds / $pollInterval, 1.0)
    $ti | Set-TaskbarItemProgressIndicator -Progress $progress -State Normal
    if ($elapsedSeconds -lt $pollInterval) {
        return
    }

    #Region Get notifications
    $headers = @{
        'Accept'               = 'application/vnd.github+json'
        'Authorization'        = "Bearer $githubToken"
        'X-GitHub-Api-Version' = '2022-11-28'
    }
    $response = Invoke-WebRequest -Uri 'https://api.github.com/notifications' -Method GET -Headers $headers
    if ($response.StatusCode -ne 200) {
        # Status is not OK
        return
    }

    $unreadNotifications = @($response.Content | ConvertFrom-Json)
    $description = ''
    foreach ($notification in $unreadNotifications) {
        $description += $notification.subject.title + "`n"
    }
    $script:ti | Set-TaskbarItemDescription -Description $description

    $unreadCount = $unreadNotifications.Count
    if ($unreadCount) {
        $script:ti | Set-TaskbarItemOverlayBadge -Text $unreadCount -BackgroundColor DodgerBlue
    } else {
        $script:ti | Clear-TaskbarItemOverlay
    }
    #endregion

    $newPollInterval = [Int]($response.Headers.'X-Poll-Interval'[0])
    if ($newPollInterval) {
        $script:pollInterval = $newPollInterval
    }
    $script:lastPollDate = Get-Date
}

if ($GithubOrg) {
    $thumbButton1 = New-TaskbarItemThumbButton -Description 'Open GitHub Organization' -IconResourcePath 'C:\PowerShell\GitHub_Notifier\org.png' -OnClicked {
        & explorer $GithubOrg
    }
    Add-TaskbarItemThumbButton $ti $thumbButton1
}

if ($GithubProject) {
    $thumbButton2 = New-TaskbarItemThumbButton -Description 'Open GitHub Project' -IconResourcePath 'C:\PowerShell\GitHub_Notifier\kanban.png' -OnClicked {
        & explorer $GithubProject
    }
    Add-TaskbarItemThumbButton $ti $thumbButton2
}

Show-TaskbarItem $ti