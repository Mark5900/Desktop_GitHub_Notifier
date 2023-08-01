$pollInterval = 60
$lastPollDate = [DateTime]::MinValue
$githubToken = Get-Content "$env:userprofile\github_token.txt" | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString -AsPlainText
$githubIcon = 'C:\Users\itcemara\github-icon.png'

$ti = New-TaskbarItem -Title 'Github Notifier' -IconResourcePath $githubIcon -OnClicked {
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

Show-TaskbarItem $ti