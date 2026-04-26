param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Body,

    [string]$Type = "broadcast",

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Get-EnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $line = Get-Content ".env" | Where-Object { $_ -match "^$Name=" } | Select-Object -First 1
    if (-not $line) {
        throw "Missing $Name in .env"
    }

    return ($line -replace "^$Name=", "").Trim('"')
}

$supabaseUrl = Get-EnvValue -Name "SUPABASE_URL"
$serviceRoleKey = Get-EnvValue -Name "SUPABASE_SERVICE_ROLE_KEY"

$headers = @{
    "apikey" = $serviceRoleKey
    "Authorization" = "Bearer $serviceRoleKey"
    "Content-Type" = "application/json"
}

$usersEndpoint = "$($supabaseUrl.TrimEnd('/'))/rest/v1/users?select=id"
$users = Invoke-RestMethod -Method Get -Uri $usersEndpoint -Headers $headers

if (-not $users -or $users.Count -eq 0) {
    throw "No users found in Supabase users table."
}

$notifications = @()
foreach ($user in $users) {
    $notifications += @{
        title = $Title
        body = $Body
        type = $Type
        receiverId = $user.id
        isRead = $false
        createdAt = [DateTime]::UtcNow.ToString("o")
    }
}

if ($DryRun) {
    Write-Host "Dry run only."
    Write-Host "Users found: $($users.Count)"
    Write-Host "Notifications prepared: $($notifications.Count)"
    return
}

$notificationsEndpoint = "$($supabaseUrl.TrimEnd('/'))/rest/v1/notifications"
$jsonBody = $notifications | ConvertTo-Json -Depth 4

Invoke-RestMethod `
    -Method Post `
    -Uri $notificationsEndpoint `
    -Headers ($headers + @{ "Prefer" = "return=minimal" }) `
    -Body $jsonBody

Write-Host "Inserted $($notifications.Count) notifications."
