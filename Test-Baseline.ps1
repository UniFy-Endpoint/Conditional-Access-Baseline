[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$errors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError {
    param([string]$Message)
    $errors.Add($Message)
}

function Read-JsonFile {
    param([System.IO.FileInfo]$File)

    try {
        return Get-Content -LiteralPath $File.FullName -Raw | ConvertFrom-Json
    }
    catch {
        Add-ValidationError "$($File.FullName): invalid JSON: $($_.Exception.Message)"
        return $null
    }
}

$policyDir = Join-Path $root 'ConditionalAccess'
$groupDir = Join-Path $root 'Groups'
$migrationPath = Join-Path $root 'MigrationTable.json'

$groupsById = @{}
$groupNames = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

foreach ($file in Get-ChildItem -LiteralPath $groupDir -Filter '*.json' -File) {
    $group = Read-JsonFile -File $file
    if ($null -eq $group) { continue }

    if ($file.BaseName -ne $group.displayName) {
        Add-ValidationError "$($file.Name): filename doesn't match displayName '$($group.displayName)'."
    }
    if ([string]::IsNullOrWhiteSpace($group.id)) {
        Add-ValidationError "$($file.Name): group id is missing."
    }
    else {
        $groupsById[[string]$group.id] = [string]$group.displayName
    }
    $null = $groupNames.Add([string]$group.displayName)
}

$emergencyGroup = $groupsById.GetEnumerator() |
    Where-Object { $_.Value -eq 'CA000-GLB-BGA-EmergencyAccess-EXCL' } |
    Select-Object -First 1

if ($null -eq $emergencyGroup) {
    Add-ValidationError 'The shared emergency-access exclusion group is missing.'
}

$policies = @{}
foreach ($file in Get-ChildItem -LiteralPath $policyDir -Filter '*.json' -File) {
    $policy = Read-JsonFile -File $file
    if ($null -eq $policy) { continue }

    $policies[[string]$policy.displayName] = $policy

    if ($file.BaseName -ne $policy.displayName) {
        Add-ValidationError "$($file.Name): filename doesn't match displayName '$($policy.displayName)'."
    }
    if ($policy.state -ne 'disabled') {
        Add-ValidationError "$($file.Name): source policy state must be 'disabled', found '$($policy.state)'."
    }

    foreach ($groupId in @($policy.conditions.users.includeGroups) + @($policy.conditions.users.excludeGroups)) {
        if (-not [string]::IsNullOrWhiteSpace($groupId) -and -not $groupsById.ContainsKey([string]$groupId)) {
            Add-ValidationError "$($file.Name): referenced group '$groupId' isn't present in Groups."
        }
    }

    $isGuestOnly = $null -ne $policy.conditions.users.includeGuestsOrExternalUsers
    if (-not $isGuestOnly -and $null -ne $emergencyGroup) {
        if ([string]$emergencyGroup.Key -notin @($policy.conditions.users.excludeGroups)) {
            Add-ValidationError "$($file.Name): shared emergency-access group isn't excluded."
        }
    }
}

$ca005Name = 'CA005-GLB-DeviceReg-AnyOS-AnyCli-AnyLoc-ReqMFA'
$ca005 = $policies[$ca005Name]
if ($null -eq $ca005) {
    Add-ValidationError "Required policy '$ca005Name' is missing."
}
else {
    if ('urn:user:registerdevice' -notin @($ca005.conditions.applications.includeUserActions)) {
        Add-ValidationError "$ca005Name doesn't target the device-registration user action."
    }
    if ($null -ne $ca005.conditions.locations) {
        Add-ValidationError "$ca005Name must apply at all locations and must not define a location condition."
    }
}

$ca101Name = 'CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA'
$ca101 = $policies[$ca101Name]
if ($null -eq $ca101) {
    Add-ValidationError "Required policy '$ca101Name' is missing."
}
else {
    if ($ca101.grantControls.authenticationStrength.displayName -ne 'Phishing-resistant MFA') {
        Add-ValidationError "$ca101Name must require the Phishing-resistant MFA authentication strength."
    }
    if ('All' -notin @($ca101.conditions.applications.includeApplications) -or
        @($ca101.conditions.applications.excludeApplications).Count -gt 0) {
        Add-ValidationError "$ca101Name must target all resources without application exclusions."
    }
    if ($null -ne $ca101.conditions.locations) {
        Add-ValidationError "$ca101Name must apply at all locations and must not define a location condition."
    }
}

$migrationFile = Get-Item -LiteralPath $migrationPath
$migration = Read-JsonFile -File $migrationFile
if ($null -ne $migration) {
    $migrationGroupNames = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::OrdinalIgnoreCase
    )
    foreach ($entry in @($migration.Objects | Where-Object Type -eq 'Group')) {
        $null = $migrationGroupNames.Add([string]$entry.DisplayName)
    }
    foreach ($groupName in $groupNames) {
        if (-not $migrationGroupNames.Contains($groupName)) {
            Add-ValidationError "MigrationTable.json is missing group '$groupName'."
        }
    }
}

foreach ($scriptFile in Get-ChildItem -LiteralPath $root -Filter '*.ps1' -File) {
    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        $scriptFile.FullName,
        [ref]$tokens,
        [ref]$parseErrors
    ) | Out-Null
    foreach ($parseError in @($parseErrors)) {
        Add-ValidationError "$($scriptFile.Name): $($parseError.Message)"
    }
}

if ($errors.Count -gt 0) {
    Write-Host "Baseline validation failed with $($errors.Count) error(s):" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Baseline validation passed: $($policies.Count) policies and $($groupsById.Count) groups." -ForegroundColor Green
