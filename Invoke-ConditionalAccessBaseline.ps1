<#
.SYNOPSIS
    Interactive Conditional Access Backup & Restore Script for Microsoft Entra ID

.DESCRIPTION
    Backs up and restores Conditional Access policies from Microsoft Entra ID,
    including their exclusion groups and Named Locations. On restore, groups and
    Named Locations are created in the target tenant if they do not already exist,
    and old-tenant UUIDs in policy bodies are remapped to the new-tenant UUIDs
    automatically. Policies are always restored in disabled state for safety.
    Troubleshooting events and detailed Microsoft Graph errors are logged to
    C:\Windows\Temp\Invoke-ConditionalAccessBaseline.log by default.

.EXAMPLE
    .\Invoke-ConditionalAccessBaseline.ps1
#>

$script:IsConnected = $false
$script:TenantId    = $null
$script:Account     = $null
$script:LogEnabled  = $true
$script:LogPath     = 'C:\Windows\Temp\Invoke-ConditionalAccessBaseline.log'
$script:KnownAppNames = @{
    '00000002-0000-0000-c000-000000000000' = 'Windows Azure Active Directory'
    'f1346770-5b25-470b-88bd-d5744ab7952c' = 'Intune Provisioning Client'
    '1b912ec3-a9dd-4c4d-a53e-76aa7adb28d7' = 'AADReporting'
    '270efc09-cd0d-444b-a71f-39af4910ec45' = 'Windows Cloud Login'
    '19db86c3-b2b9-44cc-b339-36da233a3be2' = 'My Signins'
    'ea890292-c8c8-4433-b5ea-b09d0668e1a6' = 'Azure Credential Configuration Endpoint Service'
    '0af06dc6-e4b5-4f28-818e-e78e62d137a5' = 'Windows 365'
    '65d91a3d-ab74-42e6-8a2f-0add61688c74' = 'Microsoft Approval Management'
    '4660504c-45b3-4674-a709-71951a6b0763' = 'Microsoft Invitation Acceptance Portal'
    '0000000c-0000-0000-c000-000000000000' = 'Microsoft App Access Panel'
    '8c59ead7-d703-4a27-9e55-c96a0054c8d2' = 'My Profile'
    '2793995e-0a7d-40d7-bd35-6968ba142197' = 'My Apps'
    'cc15fd57-2c6c-4117-a88c-83b1d56b4bbe' = 'Microsoft Teams Services'
    '0000000a-0000-0000-c000-000000000000' = 'Microsoft Intune'
    'd32c68ad-72d2-4acb-a0c7-46bb2cf93873' = 'Microsoft Activity Feed Service'
    'd4ebce55-015a-49b5-a083-c84d1797ae8c' = 'Microsoft Intune Enrollment'
    '00000003-0000-0ff1-ce00-000000000000' = 'Office 365 SharePoint Online'
    '797f4846-ba00-4fd7-ba43-dac1f8f63013' = 'Azure Resource Manager'
    '00000002-0000-0ff1-ce00-000000000000' = 'Office 365 Exchange Online'
    '45a330b1-b1ec-4cc1-9161-9f03992aa49f' = 'Windows Store for Business'
    '00000012-0000-0000-c000-000000000000' = 'Microsoft Rights Management Services'
    'a0e84e36-b067-4d5c-ab4a-3db38e598ae2' = 'MicrosoftDefenderATP XPlat'
    'e724aa31-0f56-4018-b8be-f8cb82ca1196' = 'Microsoft Defender for Mobile TVM'
    'a4f2693f-129c-4b96-982b-2c364b8314d7' = 'Edge Sync'
}

# ─────────────────────────────────────────────────────────────────────────────
# TROUBLESHOOTING LOG
# ─────────────────────────────────────────────────────────────────────────────

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    if (-not $script:LogEnabled) { return }

    try {
        $directory = Split-Path -Path $script:LogPath -Parent
        if (-not (Test-Path -LiteralPath $directory)) {
            $null = New-Item -Path $directory -ItemType Directory -Force -ErrorAction Stop
        }

        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
        $tenant    = if ($script:TenantId) { $script:TenantId } else { 'not-connected' }
        $entry     = "$timestamp [$Level] [Tenant: $tenant] $Message"
        Add-Content -LiteralPath $script:LogPath -Value $entry -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        # Logging must never interrupt backup or restore operations.
    }
}

function Initialize-Logging {
    if (-not $script:LogEnabled) { return $true }

    try {
        $directory = Split-Path -Path $script:LogPath -Parent
        if (-not (Test-Path -LiteralPath $directory)) {
            $null = New-Item -Path $directory -ItemType Directory -Force -ErrorAction Stop
        }
        if (-not (Test-Path -LiteralPath $script:LogPath)) {
            $null = New-Item -Path $script:LogPath -ItemType File -Force -ErrorAction Stop
        }

        Write-Log -Message ('-' * 78)
        Write-Log -Message "Script started. PowerShell $($PSVersionTable.PSVersion); user $([Environment]::UserName)."
        return $true
    }
    catch {
        $script:LogEnabled = $false
        Write-Host ""
        Write-Host "  [!] Troubleshooting log could not be created:" -ForegroundColor Yellow
        Write-Host "      $script:LogPath" -ForegroundColor DarkGray
        Write-Host "      $($_.Exception.Message)" -ForegroundColor DarkGray
        return $false
    }
}

function Write-LogError {
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [Parameter(Mandatory)]
        [string]$Context
    )

    $message = Get-GraphErrorMessage -ErrorRecord $ErrorRecord
    $exceptionType = if ($ErrorRecord.Exception) {
        $ErrorRecord.Exception.GetType().FullName
    }
    else {
        'UnknownException'
    }

    $lineNumber = $ErrorRecord.InvocationInfo.ScriptLineNumber
    $command    = $ErrorRecord.InvocationInfo.MyCommand.Name
    $location   = if ($lineNumber) {
        "line $lineNumber" + $(if ($command) { ", command '$command'" } else { "" })
    }
    else {
        'line unknown'
    }

    Write-Log -Level ERROR -Message "$Context | $location | $exceptionType | $message"
}

function Set-LoggingState {
    param([bool]$Enabled)

    if ($Enabled) {
        $script:LogEnabled = $true
        if (Initialize-Logging) {
            Write-Host ""
            Write-Host "  Troubleshooting logging ENABLED." -ForegroundColor Green
            Write-Host "  Log: $script:LogPath" -ForegroundColor DarkGray
        }
    }
    else {
        Write-Log -Message "Troubleshooting logging disabled by the user."
        $script:LogEnabled = $false
        Write-Host ""
        Write-Host "  Troubleshooting logging DISABLED." -ForegroundColor Yellow
    }

    Write-Host ""
    Start-Sleep -Seconds 2
}

# Declare the process as Per-Monitor DPI-aware so that all file/folder dialogs
# render at the correct scale on high-DPI monitors instead of appearing small.
Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class DpiAwareness {
    [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(int v);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    public static void Enable() {
        if (!SetProcessDpiAwarenessContext(-4)) { SetProcessDPIAware(); }
    }
}
"@ -ErrorAction SilentlyContinue
[DpiAwareness]::Enable() | Out-Null

# ─────────────────────────────────────────────────────────────────────────────
# MODULE CHECK & AUTO-INSTALL
# ─────────────────────────────────────────────────────────────────────────────

function Test-AndInstall-GraphModules {
    $requiredModules = @(
        "Microsoft.Graph.Authentication",
        "Microsoft.Graph.Identity.SignIns",
        "Microsoft.Graph.Groups"
    )

    $missingModules = @()
    foreach ($mod in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $mod)) {
            $missingModules += $mod
        }
    }

    if ($missingModules.Count -eq 0) { return $true }

    Write-Host ""
    Write-Host "  [!] The following required PowerShell modules are not installed:" -ForegroundColor Yellow
    foreach ($mod in $missingModules) {
        Write-Host "        - $mod" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  Would you like to install them now? " -NoNewline -ForegroundColor White
    Write-Host "[Y/N]: " -NoNewline -ForegroundColor Cyan
    $answer = Read-Host

    if ($answer -notmatch '^[Yy]$') {
        Write-Host ""
        Write-Host "  Installation declined. To install manually, run:" -ForegroundColor Gray
        Write-Host "    Install-Module Microsoft.Graph -Scope CurrentUser" -ForegroundColor Gray
        Write-Host ""
        return $false
    }

    Write-Host ""
    $allInstalled = $true
    foreach ($mod in $missingModules) {
        Write-Host "  Installing $mod ..." -NoNewline -ForegroundColor Cyan
        try {
            Install-Module -Name $mod -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop 6>$null 3>$null
            Write-Host " [OK]" -ForegroundColor Green
        }
        catch {
            Write-LogError -ErrorRecord $_ -Context "Install PowerShell module '$mod'"
            Write-Host " [FAILED]" -ForegroundColor Red
            Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
            $allInstalled = $false
        }
    }

    if (-not $allInstalled) {
        Write-Host ""
        Write-Host "  [!] One or more modules failed to install. Please install them manually." -ForegroundColor Red
        Write-Host ""
        return $false
    }

    Write-Host ""
    Write-Host "  Importing modules..." -NoNewline -ForegroundColor Cyan
    foreach ($mod in $missingModules) {
        Import-Module -Name $mod -ErrorAction SilentlyContinue 6>$null 3>$null
    }
    Write-Host " [OK]" -ForegroundColor Green
    Write-Host ""
    return $true
}

# ─────────────────────────────────────────────────────────────────────────────
# CONNECTION HELPERS
# ─────────────────────────────────────────────────────────────────────────────

function Connect-ToGraph {
    $requiredScopes = @(
        "Policy.Read.All",
        "Policy.ReadWrite.ConditionalAccess",
        "Application.ReadWrite.All",
        "Group.ReadWrite.All",
        "Directory.Read.All"
    )

    try {
        $params = @{
            Scopes      = $requiredScopes
            NoWelcome   = $true
            ErrorAction = "Stop"
        }
        if ($script:TenantId) { $params.TenantId = $script:TenantId }

        Connect-MgGraph @params -WarningAction SilentlyContinue

        $context            = Get-MgContext
        $script:TenantId    = $context.TenantId
        $script:Account     = $context.Account
        $script:IsConnected = $true
        Write-Log -Message "Connected to Microsoft Graph as '$($script:Account)'."
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Connect to Microsoft Graph"
        $errMsg = $_.Exception.Message
        if ($errMsg -notmatch "cancel|cancelled|user.*abort") {
            Clear-Host
            Write-Host ""
            Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
            Write-Host "  ║       Conditional Access Manager  —  Microsoft Entra ID            ║" -ForegroundColor Cyan
            Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  ✗ Failed to connect to Microsoft Graph." -ForegroundColor Red
            Write-Host "    $errMsg" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}

function Confirm-GraphConnection {
    $requiredScopes = @(
        "Policy.Read.All",
        "Policy.ReadWrite.ConditionalAccess",
        "Application.ReadWrite.All",
        "Group.ReadWrite.All",
        "Directory.Read.All"
    )

    try {
        $ctx = Get-MgContext
        if ($null -ne $ctx -and $null -ne $ctx.TenantId) {
            $script:IsConnected = $true
            $script:TenantId    = $ctx.TenantId
            $script:Account     = $ctx.Account

            $missingScopes = @($requiredScopes | Where-Object { $_ -notin @($ctx.Scopes) })
            if ($missingScopes.Count -eq 0) {
                return $true
            }

            Write-Log -Level WARN -Message "Existing Microsoft Graph context is missing required delegated scopes: $($missingScopes -join ', '). Reauthentication is required."
            Write-Host ""
            Write-Host "  [!] Microsoft Graph needs additional permission for this operation:" -ForegroundColor Yellow
            Write-Host "      $($missingScopes -join ', ')" -ForegroundColor DarkGray
            Write-Host "      Complete the sign-in and consent prompt to continue." -ForegroundColor Yellow
        }
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Check existing Microsoft Graph context"
    }

    if ($script:TenantId) {
        try {
            $params = @{
                Scopes      = $requiredScopes
                TenantId    = $script:TenantId
                NoWelcome   = $true
                ErrorAction = "Stop"
            }
            Connect-MgGraph @params -WarningAction SilentlyContinue

            $ctx = Get-MgContext
            if ($null -ne $ctx -and $null -ne $ctx.TenantId) {
                $script:IsConnected = $true
                return $true
            }
        }
        catch {
            Write-LogError -ErrorRecord $_ -Context "Reconnect to Microsoft Graph tenant '$($script:TenantId)'"
        }
    }

    $script:IsConnected = $false
    return $false
}

function Disconnect-FromGraph {
    try {
        $null = Disconnect-MgGraph -ErrorAction Stop 6>$null
        Write-Log -Message "Disconnected from Microsoft Graph."
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Disconnect from Microsoft Graph"
    }

    $script:IsConnected = $false
}

# ─────────────────────────────────────────────────────────────────────────────
# UI HELPERS
# ─────────────────────────────────────────────────────────────────────────────

function Get-SafeFileName {
    param([string]$Name)
    $invalid = [System.IO.Path]::GetInvalidFileNameChars() -join ''
    return ($Name -replace "[{0}]" -f [regex]::Escape($invalid), '_')
}

function Show-OpenFileDialog {
    param([string]$Title = "Select JSON File", [string]$InitialDirectory = [Environment]::GetFolderPath("MyDocuments"))
    Add-Type -AssemblyName System.Windows.Forms
    $dlg                  = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title            = $Title
    $dlg.Filter           = "JSON files (*.json)|*.json|All files (*.*)|*.*"
    $dlg.InitialDirectory = $InitialDirectory
    $dlg.Multiselect      = $false
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dlg.FileName }
    return $null
}

function Show-FolderBrowserDialog {
    param([string]$Description = "Select folder", [string]$SelectedPath = [Environment]::GetFolderPath("MyDocuments"))

    $source = @"
using System;
using System.Runtime.InteropServices;
public class FolderPicker {
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    private static extern int SHCreateItemFromParsingName([MarshalAs(UnmanagedType.LPWStr)] string pszPath, IntPtr pbc, [MarshalAs(UnmanagedType.LPStruct)] Guid riid, out IntPtr ppv);
    [ComImport, Guid("DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7")] private class FileOpenDialogClass {}
    [ComImport, Guid("42f85136-db7e-439c-85f1-e4075d135fc8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IFileOpenDialog {
        [PreserveSig] int Show(IntPtr hwndOwner);
        void SetFileTypes(uint c, IntPtr r); void SetFileTypeIndex(uint i); void GetFileTypeIndex(out uint p);
        void Advise(IntPtr p, out uint c); void Unadvise(uint c); void SetOptions(uint f); void GetOptions(out uint p);
        void SetDefaultFolder(IntPtr p); void SetFolder(IntPtr p); void GetFolder(out IntPtr p); void GetCurrentSelection(out IntPtr p);
        void SetFileName([MarshalAs(UnmanagedType.LPWStr)] string n); void GetFileName([MarshalAs(UnmanagedType.LPWStr)] out string n);
        void SetTitle([MarshalAs(UnmanagedType.LPWStr)] string t); void SetOkButtonLabel([MarshalAs(UnmanagedType.LPWStr)] string t);
        void SetFileNameLabel([MarshalAs(UnmanagedType.LPWStr)] string t); void GetResult(out IntPtr p); void AddPlace(IntPtr p, int f);
        void SetDefaultExtension([MarshalAs(UnmanagedType.LPWStr)] string e); void Close(int hr); void SetClientGuid(ref Guid g);
        void ClearClientData(); void SetFilter(IntPtr p); void GetResults(out IntPtr p); void GetSelectedItems(out IntPtr p);
    }
    [ComImport, Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IShellItem {
        void BindToHandler(IntPtr p, ref Guid b, ref Guid r, out IntPtr v); void GetParent(out IntPtr p);
        void GetDisplayName(uint s, [MarshalAs(UnmanagedType.LPWStr)] out string n); void GetAttributes(uint m, out uint a); void Compare(IntPtr p, uint h, out int o);
    }
    private const uint FOS_PICKFOLDERS = 0x20, FOS_FORCEFILESYSTEM = 0x40, SIGDN_FILESYSPATH = 0x80058000;
    private static readonly Guid IShellItemGuid = new Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE");
    public static string ShowDialog(string title, string initialPath) {
        IFileOpenDialog dialog = (IFileOpenDialog)new FileOpenDialogClass();
        try {
            dialog.SetOptions(FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM);
            dialog.SetTitle(title);
            if (!string.IsNullOrEmpty(initialPath) && System.IO.Directory.Exists(initialPath)) {
                IntPtr fp; if (SHCreateItemFromParsingName(initialPath, IntPtr.Zero, IShellItemGuid, out fp) == 0) { dialog.SetFolder(fp); Marshal.Release(fp); }
            }
            if (dialog.Show(IntPtr.Zero) == 0) {
                IntPtr rp; dialog.GetResult(out rp);
                IShellItem r = (IShellItem)Marshal.GetObjectForIUnknown(rp); string path;
                r.GetDisplayName(SIGDN_FILESYSPATH, out path); Marshal.Release(rp); return path;
            }
        } finally { Marshal.ReleaseComObject(dialog); }
        return null;
    }
}
"@
    try {
        if (-not ([System.Type]::GetType("FolderPicker", $false, $true))) { Add-Type -TypeDefinition $source -Language CSharp -ErrorAction Stop }
        return [FolderPicker]::ShowDialog($Description, $SelectedPath)
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Open native folder browser dialog"
        Add-Type -AssemblyName System.Windows.Forms
        $fb = New-Object System.Windows.Forms.FolderBrowserDialog
        $fb.Description = $Description; $fb.SelectedPath = $SelectedPath; $fb.ShowNewFolderButton = $true
        if ($fb.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $fb.SelectedPath }
        return $null
    }
}

function ConvertFrom-SelectionString {
    param([string]$SelectionText, [int]$MaxIndex)
    $indices = @()
    foreach ($part in ($SelectionText -split ',')) {
        $part = $part.Trim()
        if ($part -match '^(\d+)-(\d+)$') {
            $indices += [int]$Matches[1]..[int]$Matches[2]
        }
        elseif ($part -match '^\d+$') {
            $indices += [int]$part
        }
    }
    return $indices | Where-Object { $_ -ge 1 -and $_ -le $MaxIndex } | Select-Object -Unique | Sort-Object
}

# ─────────────────────────────────────────────────────────────────────────────
# PROPERTY CLEANUP HELPERS
# ─────────────────────────────────────────────────────────────────────────────

# Recursively removes response-only OData annotations and Graph action
# properties. The externalTenants discriminator is the only @odata.type needed
# by the policy payloads handled by this script.
function Remove-OdataAnnotations {
    param($obj)

    if ($null -eq $obj) { return $null }

    if ($obj -is [System.Collections.Hashtable] -or $obj -is [System.Collections.Specialized.OrderedDictionary]) {
        $clean = [ordered]@{}
        foreach ($k in @($obj.Keys)) {
            if ($k -match '^#microsoft\.graph\.') { continue }
            if ($k -match '@odata\.') {
                $isExternalTenantType = (
                    $k -eq '@odata.type' -and
                    [string]$obj[$k] -match '^#?microsoft\.graph\.conditionalAccess(All|Enumerated)ExternalTenants$'
                )
                if (-not $isExternalTenantType) { continue }
            }
            $clean[$k] = Remove-OdataAnnotations $obj[$k]
        }
        return $clean
    }
    elseif ($obj -is [PSCustomObject]) {
        $ht = [ordered]@{}
        foreach ($prop in $obj.PSObject.Properties) {
            if ($prop.Name -match '^#microsoft\.graph\.') { continue }
            if ($prop.Name -match '@odata\.') {
                $isExternalTenantType = (
                    $prop.Name -eq '@odata.type' -and
                    [string]$prop.Value -match '^#?microsoft\.graph\.conditionalAccess(All|Enumerated)ExternalTenants$'
                )
                if (-not $isExternalTenantType) { continue }
            }
            $ht[$prop.Name] = Remove-OdataAnnotations $prop.Value
        }
        return $ht
    }
    elseif ($obj -is [System.Collections.IEnumerable] -and $obj -isnot [string]) {
        $items = [System.Collections.Generic.List[object]]::new()
        foreach ($item in $obj) {
            $items.Add((Remove-OdataAnnotations $item))
        }
        return ,$items.ToArray()
    }

    return $obj
}

# Recursively removes null values, empty collections, and empty objects from a
# Graph request body. GET responses contain many such placeholders; replaying
# them can trigger policy-specific validation errors on POST.
function Remove-EmptyGraphProperties {
    param($obj)

    if ($null -eq $obj) { return $null }

    if ($obj -is [System.Collections.Hashtable] -or $obj -is [System.Collections.Specialized.OrderedDictionary]) {
        $clean = [ordered]@{}
        foreach ($k in @($obj.Keys)) {
            $value = Remove-EmptyGraphProperties $obj[$k]
            if ($null -eq $value) { continue }
            if (($value -is [System.Collections.Hashtable] -or
                 $value -is [System.Collections.Specialized.OrderedDictionary]) -and $value.Count -eq 0) { continue }
            if ($value -is [System.Collections.IEnumerable] -and $value -isnot [string] -and
                $value -isnot [System.Collections.IDictionary] -and @($value).Count -eq 0) { continue }
            $clean[$k] = $value
        }
        return $clean
    }
    elseif ($obj -is [PSCustomObject]) {
        $ht = [ordered]@{}
        foreach ($prop in $obj.PSObject.Properties) { $ht[$prop.Name] = $prop.Value }
        return Remove-EmptyGraphProperties $ht
    }
    elseif ($obj -is [System.Collections.IEnumerable] -and $obj -isnot [string]) {
        $items = [System.Collections.Generic.List[object]]::new()
        foreach ($item in $obj) {
            $value = Remove-EmptyGraphProperties $item
            if ($null -ne $value) { $items.Add($value) }
        }
        return ,$items.ToArray()
    }

    return $obj
}

function Get-GraphErrorMessage {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)

    $candidates = @(
        $ErrorRecord.ErrorDetails.Message,
        $ErrorRecord.Exception.ResponseBody,
        $ErrorRecord.Exception.Message
    )

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace([string]$candidate)) { continue }
        $text = [string]$candidate

        # HttpResponseException.Message can contain status line, headers, and a
        # JSON response body. Extract the final Graph error object first.
        if ($text -match '(?s)(\{"error"\s*:\s*\{.*\}\})\s*$') {
            $text = $Matches[1]
        }

        try {
            $json = $text | ConvertFrom-Json -ErrorAction Stop
            if ($json.error.message) {
                $code = if ($json.error.code) { "$($json.error.code): " } else { "" }
                $detail = if ($json.error.innerError.message) {
                    $json.error.innerError.message
                }
                else {
                    $json.error.message
                }
                return ($code + $detail) -replace '\s+', ' '
            }
        }
        catch { }
        return $text -replace '\s+', ' '
    }

    return "Unknown Microsoft Graph error."
}

# Converts a policy backup JSON (PSCustomObject) into a clean POST body.
# Strips all read-only/system properties, forces state=disabled, and reduces
# authenticationStrength to a minimal typed reference.
function Get-CleanPolicyBody {
    param($PolicyJson)

    # Convert to ordered hashtable for mutation
    $body = [ordered]@{}
    foreach ($prop in $PolicyJson.PSObject.Properties) {
        $body[$prop.Name] = $prop.Value
    }

    # Remove top-level read-only and system properties
    $removeKeys = @(
        'id', 'templateId', 'partialEnablementStrategy', 'deletedDateTime',
        'createdDateTime', 'createdDateTime@odata.type',
        'modifiedDateTime', 'modifiedDateTime@odata.type',
        'state@odata.type',
        '@odata.context', '@odata.type', '@odata.id', '@odata.editLink',
        '#microsoft.graph.restore'
    )
    foreach ($k in $removeKeys) { $body.Remove($k) }

    # Always create policies in disabled state — admin enables after verification
    $body['state'] = 'disabled'

    # Deep-strip response-only annotations. Only the polymorphic externalTenant
    # discriminator is retained.
    $body = Remove-OdataAnnotations $body

    # Remove obsolete response fields that aren't accepted by the current
    # conditionalAccessConditionSet create schema. The agents condition is
    # retained because agent identity policies use the current beta schema.
    if ($body['conditions']) {
        $body['conditions'].Remove('times')
    }

    # Reduce authenticationStrength to a minimal typed reference (all other
    # properties are tenant-specific metadata that Graph does not accept on POST)
    if ($body['grantControls'] -and $body['grantControls']['authenticationStrength']) {
        $as = $body['grantControls']['authenticationStrength']
        $asId = if ($as -is [PSCustomObject]) { $as.id } else { $as['id'] }
        if ($asId) {
            $policyType = if ($as -is [PSCustomObject]) { $as.policyType } else { $as['policyType'] }
            if ($policyType -and $policyType -ne 'builtIn') {
                Write-Host "    [!] Custom authenticationStrength '$($as.displayName ?? $asId)' may not exist in the target tenant." -ForegroundColor Yellow
            }
            $body['grantControls']['authenticationStrength'] = [ordered]@{ id = $asId }
        }
        else {
            $body['grantControls'].Remove('authenticationStrength')
        }
    }

    # Current Graph validation limits risk-remediation policies to users,
    # applications, and userRiskLevels conditions.
    $grantControls   = $body['grantControls']
    $builtInControls = if ($grantControls) { @($grantControls['builtInControls']) } else { @() }
    if ($builtInControls -contains 'riskRemediation' -and $body['conditions']) {
        $allowedConditionKeys = @('users', 'applications', 'userRiskLevels')
        foreach ($key in @($body['conditions'].Keys)) {
            if ($key -notin $allowedConditionKeys) { $body['conditions'].Remove($key) }
        }
    }

    # Application-enforced restrictions are supported only by Exchange Online
    # and SharePoint Online. Replace the broad Office365 alias with those two
    # target resource IDs when restoring this session control.
    $sessionControls = $body['sessionControls']
    $conditions      = $body['conditions']
    $appRestrictions = if ($sessionControls) { $sessionControls['applicationEnforcedRestrictions'] } else { $null }
    $applications    = if ($conditions) { $conditions['applications'] } else { $null }
    if ($appRestrictions -and $applications) {
        $includedApps = @($applications['includeApplications'])
        if ($includedApps.Count -eq 1 -and $includedApps[0] -eq 'Office365') {
            $applications['includeApplications'] = @(
                '00000002-0000-0ff1-ce00-000000000000',
                '00000003-0000-0ff1-ce00-000000000000'
            )
            Write-Host "    [!] Office365 target narrowed to Exchange Online and SharePoint Online for application-enforced restrictions." -ForegroundColor Yellow
        }
    }

    # Remove null/empty GET response placeholders. This is especially important
    # for user-action, guest/external-user, and authentication-strength policies.
    return Remove-EmptyGraphProperties $body
}

# Ensures properties defined as Graph collections remain JSON arrays even when
# they contain only one item. PowerShell normally unwraps single-item output
# from helper functions, which caused Graph schema error 1007 during restore.
function Repair-PolicyCollectionProperties {
    param([System.Collections.Specialized.OrderedDictionary]$PolicyBody)

    $collectionPaths = @(
        @('conditions', 'userRiskLevels'),
        @('conditions', 'signInRiskLevels'),
        @('conditions', 'servicePrincipalRiskLevels'),
        @('conditions', 'clientAppTypes'),
        @('conditions', 'applications', 'includeApplications'),
        @('conditions', 'applications', 'excludeApplications'),
        @('conditions', 'applications', 'includeUserActions'),
        @('conditions', 'applications', 'includeAuthenticationContextClassReferences'),
        @('conditions', 'users', 'includeUsers'),
        @('conditions', 'users', 'excludeUsers'),
        @('conditions', 'users', 'includeGroups'),
        @('conditions', 'users', 'excludeGroups'),
        @('conditions', 'users', 'includeRoles'),
        @('conditions', 'users', 'excludeRoles'),
        @('conditions', 'platforms', 'includePlatforms'),
        @('conditions', 'platforms', 'excludePlatforms'),
        @('conditions', 'locations', 'includeLocations'),
        @('conditions', 'locations', 'excludeLocations'),
        @('conditions', 'devices', 'includeDeviceStates'),
        @('conditions', 'devices', 'excludeDeviceStates'),
        @('conditions', 'devices', 'includeDevices'),
        @('conditions', 'devices', 'excludeDevices'),
        @('conditions', 'clientApplications', 'includeServicePrincipals'),
        @('conditions', 'clientApplications', 'excludeServicePrincipals'),
        @('conditions', 'clientApplications', 'includeAgentIdServicePrincipals'),
        @('conditions', 'clientApplications', 'excludeAgentIdServicePrincipals'),
        @('grantControls', 'builtInControls'),
        @('grantControls', 'customAuthenticationFactors'),
        @('grantControls', 'termsOfUse')
    )

    foreach ($path in $collectionPaths) {
        $parent = $PolicyBody
        for ($i = 0; $i -lt ($path.Count - 1); $i++) {
            if (-not $parent) { break }
            $parent = $parent[$path[$i]]
        }

        if (-not $parent) { continue }
        $property = $path[-1]
        $value = $parent[$property]
        if ($null -eq $value) { continue }

        if ($value -is [string] -or $value -isnot [System.Collections.IEnumerable]) {
            $parent[$property] = @($value)
        }
        else {
            # Force a concrete object[] so single-item collections serialize as [].
            $parent[$property] = @($value)
        }
    }

    return $PolicyBody
}

function Test-PolicyRequestSchema {
    param([System.Collections.Specialized.OrderedDictionary]$PolicyBody)

    $errors = [System.Collections.Generic.List[string]]::new()
    if (-not $PolicyBody['displayName']) { $errors.Add('displayName is missing') }
    if (-not $PolicyBody['state'])       { $errors.Add('state is missing') }
    if (-not $PolicyBody['conditions'])  { $errors.Add('conditions is missing') }

    $json = $PolicyBody | ConvertTo-Json -Depth 30 -Compress
    try {
        $null = $json | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        $errors.Add("payload isn't valid JSON: $($_.Exception.Message)")
    }

    return [PSCustomObject]@{
        IsValid = ($errors.Count -eq 0)
        Errors  = @($errors)
        Json    = $json
    }
}

# Converts a raw Graph group object (PSCustomObject) into a clean POST body.
function Get-CleanGroupBody {
    param($GroupJson)

    $displayName = if ($GroupJson -is [PSCustomObject]) { $GroupJson.displayName } else { $GroupJson['displayName'] }
    $description = if ($GroupJson -is [PSCustomObject]) { $GroupJson.description } else { $GroupJson['description'] }
    $visibility  = if ($GroupJson -is [PSCustomObject]) { $GroupJson.visibility  } else { $GroupJson['visibility']  }
    $rawNick     = if ($GroupJson -is [PSCustomObject]) { $GroupJson.mailNickname } else { $GroupJson['mailNickname'] }

    # Sanitize mailNickname to alphanumeric+hyphens; replace nonsensical defaults
    $nick = ($rawNick -replace '[^a-zA-Z0-9-]', '')
    if ([string]::IsNullOrEmpty($nick) -or $nick -in @('False', 'True', 'false', 'true')) {
        $nick = "grp-" + [System.Guid]::NewGuid().ToString("N").Substring(0, 8)
    }

    $body = [ordered]@{
        displayName     = $displayName
        mailNickname    = $nick
        mailEnabled     = $false
        securityEnabled = $true
        groupTypes      = @()
    }
    if ($description) { $body['description'] = $description }
    if ($visibility)  { $body['visibility']  = $visibility  }

    return $body
}

# Converts a Named Location backup JSON into a clean POST body.
# IMPORTANT: @odata.type is kept — Graph API requires it to determine the subtype.
function Get-CleanNamedLocationBody {
    param($LocationJson)

    $body = [ordered]@{}

    # Keep @odata.type at root level — Graph needs it for countryNamedLocation vs ipNamedLocation
    $odataType = if ($LocationJson -is [PSCustomObject]) { $LocationJson.'@odata.type' } else { $LocationJson['@odata.type'] }
    if ($odataType) { $body['@odata.type'] = $odataType }

    $safeProps = @('displayName', 'countriesAndRegions', 'includeUnknownCountriesAndRegions',
                   'isTrusted', 'ipRanges')

    # Properties that Graph requires as arrays. ConvertFrom-Json unboxes single-element
    # JSON arrays into plain strings, so @() wrapping is mandatory here.
    $arrayProps = @('countriesAndRegions', 'ipRanges')

    foreach ($prop in $safeProps) {
        $val = if ($LocationJson -is [PSCustomObject]) { $LocationJson.$prop } else { $LocationJson[$prop] }
        if ($null -ne $val) {
            $body[$prop] = if ($prop -in $arrayProps) { @($val) } else { $val }
        }
    }

    return $body
}

# ─────────────────────────────────────────────────────────────────────────────
# BACKUP
# ─────────────────────────────────────────────────────────────────────────────

function Invoke-BackupConditionalAccess {
    Write-Log -Message "Backup operation requested."

    if (-not (Confirm-GraphConnection)) {
        Write-Log -Level WARN -Message "Backup cancelled because Microsoft Graph is not connected."
        Write-Host ""
        Write-Host "  [!] Not connected to Microsoft Graph." -ForegroundColor Red
        Write-Host "      Select option [1] to connect first." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║           BACKUP MODE  —  Conditional Access Policies              ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # ── Step 1: Choose output base folder ────────────────────────────────────
    Write-Host "  Select the folder where the backup will be saved..." -ForegroundColor DarkGray
    $baseFolder = Show-FolderBrowserDialog -Description "Select Output Folder for Backup" -SelectedPath $PSScriptRoot
    if (-not $baseFolder) {
        Write-Host "  [!] No folder selected. Backup cancelled." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return
    }

    # ── Step 2: Fetch all CA policies ────────────────────────────────────────
    Write-Host ""
    Write-Host "  Fetching Conditional Access policies from tenant..." -ForegroundColor Cyan

    $allPolicies = [System.Collections.Generic.List[object]]::new()
    try {
        $uri = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$top=999"
        do {
            $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
            foreach ($item in $response.value) { $allPolicies.Add($item) }
            $uri = $response['@odata.nextLink']
        } while ($uri)
    }
    catch {
        $graphError = Get-GraphErrorMessage -ErrorRecord $_
        Write-LogError -ErrorRecord $_ -Context "Retrieve Conditional Access policies for backup"
        Write-Host "  ✗ Failed to retrieve policies: $graphError" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    if ($allPolicies.Count -eq 0) {
        Write-Host "  No Conditional Access policies found in this tenant." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    # Sort by displayName for consistent numbering
    $sortedPolicies = @($allPolicies | Sort-Object { $_['displayName'] })

    # ── Step 3: Policy selection ──────────────────────────────────────────────
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║           BACKUP MODE  —  Select Policies to Back Up               ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    $idx = 1
    foreach ($p in $sortedPolicies) {
        $state = $p['state']
        $stateColor = switch ($state) {
            'enabled'                        { 'Green' }
            'enabledForReportingButNotEnforced' { 'Yellow' }
            default                          { 'DarkGray' }
        }
        Write-Host "    " -NoNewline
        Write-Host ("[{0}]" -f $idx) -NoNewline -ForegroundColor Yellow
        Write-Host ("  {0,-65}" -f $p['displayName']) -NoNewline -ForegroundColor White
        Write-Host "  [$state]" -ForegroundColor $stateColor
        $idx++
    }
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[A]" -NoNewline -ForegroundColor Green
    Write-Host "  Select all policies" -ForegroundColor White
    Write-Host "  " -NoNewline; Write-Host "[O]" -NoNewline -ForegroundColor DarkCyan
    Write-Host "  Open in Out-GridView (searchable / sortable)" -ForegroundColor DarkGray
    Write-Host "  " -NoNewline; Write-Host "[0]" -NoNewline -ForegroundColor Red
    Write-Host "  Cancel" -ForegroundColor White
    Write-Host ""

    $backupSel = Read-Host "  Select policies to back up (comma-separated like 1,3,5 or range like 1-5 or A for all)"

    $selectedPolicies = @()
    if ($backupSel -eq '0' -or [string]::IsNullOrWhiteSpace($backupSel)) { return }
    elseif ($backupSel -match '^[Aa]$') {
        $selectedPolicies = $sortedPolicies
    }
    elseif ($backupSel -match '^[Oo]$') {
        $ogvList = $sortedPolicies | ForEach-Object {
            [PSCustomObject]@{
                DisplayName  = $_['displayName']
                State        = $_['state']
                CreatedDate  = if ($_['createdDateTime']) { ([datetime]$_['createdDateTime']).ToString('yyyy-MM-dd') } else { '' }
                Modified     = if ($_['modifiedDateTime']) { ([datetime]$_['modifiedDateTime']).ToString('yyyy-MM-dd') } else { '' }
                _Id          = $_['id']
            }
        }
        $ogvSelected = $ogvList | Out-GridView `
            -Title "Select Policies to Back Up  |  Ctrl+Click / Shift+Click for multi-select" `
            -PassThru
        if (-not $ogvSelected -or $ogvSelected.Count -eq 0) { return }
        $selIds = @($ogvSelected | ForEach-Object { $_._Id })
        $selectedPolicies = $sortedPolicies | Where-Object { $selIds -contains $_['id'] }
    }
    else {
        $chosen = ConvertFrom-SelectionString -SelectionText $backupSel -MaxIndex $sortedPolicies.Count
        if ($chosen.Count -eq 0) {
            Write-Host ""
            Write-Host "  [!] No valid policies selected." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            return
        }
        $selectedPolicies = @($chosen | ForEach-Object { $sortedPolicies[$_ - 1] })
    }

    if ($selectedPolicies.Count -eq 0) { return }

    # ── Step 4: Create timestamped output folder ──────────────────────────────
    $timestamp  = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $backupRoot = Join-Path $baseFolder "Backup-ConditionalAccess_$timestamp"
    $caDir      = Join-Path $backupRoot "ConditionalAccess"
    $grpDir     = Join-Path $backupRoot "Groups"
    $locDir     = Join-Path $backupRoot "NamedLocations"

    try {
        New-Item -ItemType Directory -Path $caDir  -Force -ErrorAction Stop | Out-Null
        New-Item -ItemType Directory -Path $grpDir -Force -ErrorAction Stop | Out-Null
        New-Item -ItemType Directory -Path $locDir -Force -ErrorAction Stop | Out-Null
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Create backup output folders under '$backupRoot'"
        Write-Host "  ✗ Cannot create output folders: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    # ── Step 5: Fetch all Named Locations ────────────────────────────────────
    Write-Host ""
    Write-Host "  Fetching Named Locations..." -ForegroundColor Cyan

    $allLocations = [System.Collections.Generic.List[object]]::new()
    try {
        $uri = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations?`$top=999"
        do {
            $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
            foreach ($item in $response.value) { $allLocations.Add($item) }
            $uri = $response['@odata.nextLink']
        } while ($uri)
    }
    catch {
        $graphError = Get-GraphErrorMessage -ErrorRecord $_
        Write-LogError -ErrorRecord $_ -Context "Retrieve Named Locations for backup"
        Write-Host "  [!] Could not fetch Named Locations: $graphError" -ForegroundColor Yellow
    }

    # Build location lookup by ID
    $locationById = @{}
    foreach ($loc in $allLocations) { $locationById[$loc['id']] = $loc }

    # ── Step 6: Collect UUID dependencies referenced by selected policies ────
    $referencedGroupIds    = [System.Collections.Generic.HashSet[string]]::new()
    $referencedLocationIds = [System.Collections.Generic.HashSet[string]]::new()
    $referencedAppIds      = [System.Collections.Generic.HashSet[string]]::new()
    $literalValues         = @('All', 'None', 'AllTrusted', 'GuestsOrExternalUsers', 'all', 'none')
    $uuidPattern           = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'

    foreach ($p in $selectedPolicies) {
        $conditions = $p['conditions']
        if ($conditions) {
            $users = $conditions['users']
            if ($users) {
                foreach ($gid in @($users['excludeGroups']) + @($users['includeGroups'])) {
                    if ($gid -and $gid -notmatch '^[{]?[0-9a-fA-F]{8}' -eq $false -and $gid -notin $literalValues) {
                        $null = $referencedGroupIds.Add($gid)
                    }
                }
            }
            $locs = $conditions['locations']
            if ($locs) {
                foreach ($lid in @($locs['excludeLocations']) + @($locs['includeLocations'])) {
                    if ($lid -and $lid -notin $literalValues) {
                        $null = $referencedLocationIds.Add($lid)
                    }
                }
            }
            $apps = $conditions['applications']
            if ($apps) {
                foreach ($appRef in @($apps['excludeApplications']) + @($apps['includeApplications'])) {
                    if ($appRef -and $appRef -match $uuidPattern) {
                        $null = $referencedAppIds.Add($appRef)
                    }
                }
            }
            $clientApps = $conditions['clientApplications']
            if ($clientApps) {
                foreach ($appRef in @(
                    $clientApps['excludeServicePrincipals']
                    $clientApps['includeServicePrincipals']
                    $clientApps['excludeAgentIdServicePrincipals']
                    $clientApps['includeAgentIdServicePrincipals']
                )) {
                    if ($appRef -and $appRef -match $uuidPattern) {
                        $null = $referencedAppIds.Add($appRef)
                    }
                }
            }
        }
    }

    # ── Step 7: Save Named Locations referenced by selected policies ──────────
    $savedLocCount = 0
    foreach ($lid in $referencedLocationIds) {
        $loc = $locationById[$lid]
        if (-not $loc) {
            Write-Log -Level WARN -Message "Named Location '$lid' was referenced by a policy but was not returned by Graph during backup."
            Write-Host "  [!] Named Location $lid not found in tenant — skipping" -ForegroundColor Yellow
            continue
        }
        $safeName = Get-SafeFileName -Name $loc['displayName']
        $filePath = Join-Path $locDir "$safeName.json"
        try {
            $loc | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath -Encoding UTF8 -ErrorAction Stop
            $savedLocCount++
        }
        catch {
            Write-LogError -ErrorRecord $_ -Context "Save Named Location '$($loc['displayName'])' to '$filePath'"
            Write-Host "  [!] Could not save location '$($loc['displayName'])': $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    # ── Step 8: Fetch and save groups referenced by selected policies ─────────
    Write-Host "  Fetching referenced groups ($($referencedGroupIds.Count) unique IDs)..." -ForegroundColor Cyan

    $savedGroups   = [System.Collections.Generic.List[object]]::new()
    $failedGroups  = @()
    $gCounter      = 0
    $gTotal        = $referencedGroupIds.Count

    foreach ($gid in $referencedGroupIds) {
        $gCounter++
        Write-Progress -Activity "Fetching Groups" -Status "$gCounter of $gTotal" -PercentComplete (($gCounter / [Math]::Max($gTotal, 1)) * 100)
        try {
            $grp = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/groups/$gid" -ErrorAction Stop
            $safeName = Get-SafeFileName -Name $grp['displayName']
            $filePath = Join-Path $grpDir "$safeName.json"
            $grp | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath -Encoding UTF8 -ErrorAction Stop
            $savedGroups.Add($grp)
        }
        catch {
            $failedGroups += $gid
            $graphError = Get-GraphErrorMessage -ErrorRecord $_
            Write-LogError -ErrorRecord $_ -Context "Retrieve or save referenced group '$gid'"
            Write-Host "  [!] Could not fetch/save group $gid`: $graphError" -ForegroundColor Yellow
        }
    }
    Write-Progress -Activity "Fetching Groups" -Completed

    # ── Step 9: Resolve service principals referenced by selected policies ──
    Write-Host "  Resolving referenced service principals ($($referencedAppIds.Count) unique IDs)..." -ForegroundColor Cyan

    $resolvedServicePrincipals = [System.Collections.Generic.List[object]]::new()
    foreach ($appRef in $referencedAppIds) {
        try {
            $escapedAppRef = $appRef -replace "'", "''"
            $response = Invoke-MgGraphRequest -Method GET `
                            -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$escapedAppRef'&`$select=id,appId,displayName" `
                            -ErrorAction Stop
            $sp = @($response.value) | Select-Object -First 1

            if (-not $sp) {
                try {
                    $sp = Invoke-MgGraphRequest -Method GET `
                              -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$appRef?`$select=id,appId,displayName" `
                              -ErrorAction Stop
                }
                catch {
                    $sp = $null
                }
            }

            if (-not $sp) {
                Write-Log -Level WARN -Message "Application reference '$appRef' could not be resolved to a service principal during backup."
                Write-Host "  [!] Service principal reference $appRef could not be resolved." -ForegroundColor Yellow
                continue
            }

            $spDisplayName = if ($sp -is [PSCustomObject]) { $sp.displayName } else { $sp['displayName'] }
            $spId          = if ($sp -is [PSCustomObject]) { $sp.id }          else { $sp['id'] }
            $spAppId       = if ($sp -is [PSCustomObject]) { $sp.appId }       else { $sp['appId'] }

            $resolvedServicePrincipals.Add([ordered]@{
                DisplayName      = $spDisplayName
                Id               = $spId
                AppId            = $spAppId
                PolicyReferenceId = $appRef
                ReferenceKind    = $(if ($appRef -eq $spId) { 'ServicePrincipalId' } else { 'AppId' })
                Type             = 'ServicePrincipal'
            })
        }
        catch {
            $graphError = Get-GraphErrorMessage -ErrorRecord $_
            Write-LogError -ErrorRecord $_ -Context "Resolve service principal reference '$appRef' for backup"
            Write-Host "  [!] Could not resolve service principal $appRef`: $graphError" -ForegroundColor Yellow
        }
    }

    # ── Step 10: Save each selected CA policy JSON ────────────────────────────
    $savedPolicies  = @()
    $failedPolicies = @()
    $pCounter       = 0
    $pTotal         = $selectedPolicies.Count

    foreach ($p in $selectedPolicies) {
        $pCounter++
        Write-Progress -Activity "Saving Policies" `
                       -Status "$pCounter of $pTotal  —  $($p['displayName'])" `
                       -PercentComplete (($pCounter / $pTotal) * 100)
        $safeName = Get-SafeFileName -Name $p['displayName']
        $filePath = Join-Path $caDir "$safeName.json"
        try {
            $p | ConvertTo-Json -Depth 20 | Set-Content -Path $filePath -Encoding UTF8 -ErrorAction Stop
            $savedPolicies += $p['displayName']
        }
        catch {
            $failedPolicies += $p['displayName']
            Write-LogError -ErrorRecord $_ -Context "Save policy backup '$($p['displayName'])' to '$filePath'"
        }
    }
    Write-Progress -Activity "Saving Policies" -Completed

    # ── Step 11: Write MigrationTable.json ───────────────────────────────────
    try {
        $ctx = Get-MgContext
        $migObjects = @()
        foreach ($grp in $savedGroups) {
            $migObjects += [ordered]@{ DisplayName = $grp['displayName']; Id = $grp['id']; Type = "Group" }
        }
        foreach ($lid in $referencedLocationIds) {
            $loc = $locationById[$lid]
            if ($loc) {
                $migObjects += [ordered]@{ DisplayName = $loc['displayName']; Id = $loc['id']; Type = "NamedLocation" }
            }
        }
        foreach ($sp in $resolvedServicePrincipals) {
            $migObjects += $sp
        }
        $migTable = [ordered]@{
            SchemaVersion    = 2
            ExportedAt       = (Get-Date -Format 'o')
            SourceTenantId   = $ctx.TenantId
            SourceOrganization = ($ctx.TenantId)
            Objects          = $migObjects
        }
        $migTable | ConvertTo-Json -Depth 5 |
            Set-Content -Path (Join-Path $backupRoot 'MigrationTable.json') -Encoding UTF8
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Write migration table to '$backupRoot'"
        Write-Host "  [!] Could not write MigrationTable.json: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # ── Step 12: Summary ─────────────────────────────────────────────────────
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║           BACKUP MODE  —  Conditional Access Policies              ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  BACKUP SUMMARY" -ForegroundColor Cyan
    Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "    Policies saved    : $($savedPolicies.Count)" -ForegroundColor Green
    Write-Host "    Policies failed   : $($failedPolicies.Count)" -ForegroundColor $(if ($failedPolicies.Count -gt 0) { 'Red' } else { 'Green' })
    Write-Host "    Groups saved      : $($savedGroups.Count)" -ForegroundColor Green
    Write-Host "    Groups failed     : $($failedGroups.Count)" -ForegroundColor $(if ($failedGroups.Count -gt 0) { 'Red' } else { 'Green' })
    Write-Host "    Locations saved   : $savedLocCount" -ForegroundColor Green
    Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "    Output folder : $backupRoot" -ForegroundColor White
    if (($failedPolicies.Count -gt 0 -or $failedGroups.Count -gt 0) -and $script:LogEnabled) {
        Write-Host "    Troubleshooting log: $script:LogPath" -ForegroundColor DarkGray
    }
    Write-Host "  ══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Log -Message "Backup completed. Policies saved: $($savedPolicies.Count); policies failed: $($failedPolicies.Count); groups saved: $($savedGroups.Count); groups failed: $($failedGroups.Count); locations saved: $savedLocCount; output: '$backupRoot'."
    Write-Host ""
    Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ─────────────────────────────────────────────────────────────────────────────
# RESTORE SUB-FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────

# Restores Named Locations from the NamedLocations\ subfolder of a backup root.
# If $RequiredOldIds is provided (string array of old UUIDs), only locations
# whose backup 'id' matches are processed. Returns a hashtable mapping old ID
# to new ID for use in policy ID remapping.
function Restore-NamedLocations {
    param(
        [string]$BackupFolder,
        [string[]]$RequiredOldIds,
        [bool]$Preview
    )

    $idMap = @{}

    $locDir = Join-Path $BackupFolder "NamedLocations"
    if (-not (Test-Path $locDir)) { return $idMap }

    $locFiles = @(Get-ChildItem -Path $locDir -Filter "*.json" -File | Sort-Object Name)
    if ($locFiles.Count -eq 0) { return $idMap }

    Write-Host ""
    Write-Host "  ── Named Locations ─────────────────────────────────────────────────────" -ForegroundColor Cyan

    foreach ($file in $locFiles) {
        try {
            $locJson = Get-Content -Path $file.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Write-LogError -ErrorRecord $_ -Context "Read Named Location backup '$($file.FullName)'"
            Write-Host "    [READ ERROR]  $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
            continue
        }

        $oldId      = if ($locJson -is [PSCustomObject]) { $locJson.id } else { $locJson['id'] }
        $dispName   = if ($locJson -is [PSCustomObject]) { $locJson.displayName } else { $locJson['displayName'] }

        # Filter to only required IDs when doing a targeted restore
        if ($RequiredOldIds -and $RequiredOldIds.Count -gt 0 -and $oldId -notin $RequiredOldIds) { continue }

        Write-Host "    $dispName" -NoNewline -ForegroundColor White

        # Check existence by displayName
        $existing = $null
        try {
            $escaped  = $dispName -replace "'", "''"
            $chkUri   = "https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations?`$filter=displayName eq '$escaped'"
            $chkResp  = Invoke-MgGraphRequest -Method GET -Uri $chkUri -ErrorAction Stop
            $existing = @($chkResp.value) | Select-Object -First 1
        }
        catch {
            Write-LogError -ErrorRecord $_ -Context "Check whether Named Location '$dispName' already exists"
        }

        if ($existing) {
            $newId = if ($existing -is [PSCustomObject]) { $existing.id } else { $existing['id'] }
            if ($oldId) { $idMap[$oldId] = $newId }
            Write-Host "  [SKIPPED — already exists]" -ForegroundColor Yellow
            continue
        }

        # Compliant network named locations are provisioned by Global Secure Access and
        # cannot be created via POST. When one is not already present in the tenant, surface
        # the prerequisite clearly instead of letting Graph return a confusing creation error.
        $odataType = if ($locJson -is [PSCustomObject]) { $locJson.'@odata.type' } else { $locJson['@odata.type'] }
        if ($odataType -like '*compliantNetworkNamedLocation') {
            Write-Log -Level WARN -Message "Named Location '$dispName' is a compliant network location and cannot be created directly; it is provisioned automatically when Global Secure Access / the compliant network check is enabled in the tenant."
            Write-Host "  [SKIPPED — enable Global Secure Access to provision this location]" -ForegroundColor Yellow
            continue
        }

        if ($Preview) {
            Write-Host "  [WOULD CREATE]" -ForegroundColor Cyan
            continue
        }

        try {
            $body    = Get-CleanNamedLocationBody -LocationJson $locJson
            # Use the typed Beta cmdlet so the @odata.type discriminator is handled correctly
            # by the SDK's own serializer. Invoke-MgGraphRequest fails with 1041 for named
            # locations regardless of body encoding (hashtable / string / bytes).
            $created = New-MgBetaIdentityConditionalAccessNamedLocation -BodyParameter $body -ErrorAction Stop
            $newId   = $created.Id
            if ($oldId) { $idMap[$oldId] = $newId }
            Write-Log -Message "Created Named Location '$dispName' — new ID: $newId"
            Write-Host "  [CREATED]" -ForegroundColor Green
        }
        catch {
            $graphError = Get-GraphErrorMessage -ErrorRecord $_
            Write-LogError -ErrorRecord $_ -Context "Create Named Location '$dispName'"
            Write-Host "  [FAILED: $graphError]" -ForegroundColor Red
        }
    }

    return $idMap
}

# Restores exclusion groups from the Groups\ subfolder of a backup root.
# If $RequiredOldIds is provided, only groups whose backup 'id' matches are
# processed. Returns a hashtable mapping old group ID to new group ID.
function Restore-ExclusionGroups {
    param(
        [string]$BackupFolder,
        [string[]]$RequiredOldIds,
        [bool]$Preview
    )

    $idMap = @{}

    $grpDir = Join-Path $BackupFolder "Groups"
    if (-not (Test-Path $grpDir)) { return $idMap }

    $grpFiles = @(Get-ChildItem -Path $grpDir -Filter "*.json" -File | Sort-Object Name)
    if ($grpFiles.Count -eq 0) { return $idMap }

    Write-Host ""
    Write-Host "  ── Exclusion Groups ────────────────────────────────────────────────────" -ForegroundColor Cyan

    foreach ($file in $grpFiles) {
        try {
            $grpJson = Get-Content -Path $file.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Write-LogError -ErrorRecord $_ -Context "Read group backup '$($file.FullName)'"
            Write-Host "    [READ ERROR]  $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
            continue
        }

        $oldId    = if ($grpJson -is [PSCustomObject]) { $grpJson.id } else { $grpJson['id'] }
        $dispName = if ($grpJson -is [PSCustomObject]) { $grpJson.displayName } else { $grpJson['displayName'] }

        # Filter to only required IDs when doing a targeted restore
        if ($RequiredOldIds -and $RequiredOldIds.Count -gt 0 -and $oldId -notin $RequiredOldIds) { continue }

        Write-Host "    $dispName" -NoNewline -ForegroundColor White

        # Check existence by displayName — requires ConsistencyLevel: eventual
        $existing = $null
        try {
            $escaped  = $dispName -replace "'", "''"
            $chkUri   = "https://graph.microsoft.com/beta/groups?`$filter=displayName eq '$escaped'&`$count=true"
            $chkResp  = Invoke-MgGraphRequest -Method GET -Uri $chkUri `
                            -Headers @{ "ConsistencyLevel" = "eventual" } -ErrorAction Stop
            $existing = @($chkResp.value) | Select-Object -First 1
        }
        catch {
            Write-LogError -ErrorRecord $_ -Context "Check whether group '$dispName' already exists"
        }

        if ($existing) {
            $newId = if ($existing -is [PSCustomObject]) { $existing.id } else { $existing['id'] }
            if ($oldId) { $idMap[$oldId] = $newId }
            Write-Host "  [SKIPPED — already exists]" -ForegroundColor Yellow
            continue
        }

        if ($Preview) {
            Write-Host "  [WOULD CREATE]" -ForegroundColor Cyan
            continue
        }

        try {
            $body    = Get-CleanGroupBody -GroupJson $grpJson
            $created = Invoke-MgGraphRequest -Method POST `
                           -Uri "https://graph.microsoft.com/beta/groups" `
                           -Body $body -ErrorAction Stop
            $newId = if ($created -is [PSCustomObject]) { $created.id } else { $created['id'] }
            if ($oldId) { $idMap[$oldId] = $newId }
            Write-Log -Message "Created exclusion group '$dispName'."
            Write-Host "  [CREATED]" -ForegroundColor Green
        }
        catch {
            $graphError = Get-GraphErrorMessage -ErrorRecord $_
            Write-LogError -ErrorRecord $_ -Context "Create exclusion group '$dispName'"
            Write-Host "  [FAILED: $graphError]" -ForegroundColor Red
        }
    }

    return $idMap
}

# Replaces old-tenant UUIDs in a policy body's groups and locations arrays
# with the corresponding new-tenant UUIDs from the provided maps.
function Invoke-ApplyIdRemapping {
    param(
        [System.Collections.Specialized.OrderedDictionary]$PolicyBody,
        [hashtable]$GroupIdMap,
        [hashtable]$LocationIdMap,
        [hashtable]$ServicePrincipalIdMap = @{}
    )

    $remapList = {
        param($list, $map, $context)
        if (-not $list) { return $list }
        $out = @()
        foreach ($item in $list) {
            if (-not $item) { $out += $item; continue }
            if ($map.ContainsKey($item)) {
                $out += $map[$item]
            }
            else {
                # A source-tenant UUID cannot be valid in the target tenant.
                # Omit unresolved dependencies; policies are created disabled so
                # the administrator can review the reduced exclusion scope.
                if ($item -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
                    Write-Log -Level WARN -Message "UUID '$item' in '$context' was not present in the remapping table and was omitted from the disabled policy."
                    Write-Host "    [!] UUID $item ($context) not in remapping table — omitted from disabled policy" -ForegroundColor Yellow
                    continue
                }
                $out += $item
            }
        }
        Write-Output -NoEnumerate ([object[]]$out)
    }

    $remapApplicationList = {
        param($list)
        if (-not $list) { return $list }
        $out = @(
            foreach ($item in $list) {
                if ($item -and $ServicePrincipalIdMap.ContainsKey($item)) {
                    $ServicePrincipalIdMap[$item]
                }
                else {
                    $item
                }
            }
        )
        Write-Output -NoEnumerate ([object[]]$out)
    }

    $conditions = $PolicyBody['conditions']
    if ($conditions) {
        $users = $conditions['users']
        if ($users) {
            if ($users['excludeGroups']) { $users['excludeGroups'] = & $remapList $users['excludeGroups'] $GroupIdMap 'excludeGroups' }
            if ($users['includeGroups']) { $users['includeGroups'] = & $remapList $users['includeGroups'] $GroupIdMap 'includeGroups' }
        }
        $locs = $conditions['locations']
        if ($locs) {
            if ($locs['excludeLocations']) { $locs['excludeLocations'] = & $remapList $locs['excludeLocations'] $LocationIdMap 'excludeLocations' }
            if ($locs['includeLocations']) { $locs['includeLocations'] = & $remapList $locs['includeLocations'] $LocationIdMap 'includeLocations' }
        }
        $apps = $conditions['applications']
        if ($apps) {
            if ($apps['excludeApplications']) { $apps['excludeApplications'] = & $remapApplicationList $apps['excludeApplications'] }
            if ($apps['includeApplications']) { $apps['includeApplications'] = & $remapApplicationList $apps['includeApplications'] }
        }
        $clientApps = $conditions['clientApplications']
        if ($clientApps) {
            if ($clientApps['excludeServicePrincipals']) { $clientApps['excludeServicePrincipals'] = & $remapApplicationList $clientApps['excludeServicePrincipals'] }
            if ($clientApps['includeServicePrincipals']) { $clientApps['includeServicePrincipals'] = & $remapApplicationList $clientApps['includeServicePrincipals'] }
            if ($clientApps['excludeAgentIdServicePrincipals']) { $clientApps['excludeAgentIdServicePrincipals'] = & $remapApplicationList $clientApps['excludeAgentIdServicePrincipals'] }
            if ($clientApps['includeAgentIdServicePrincipals']) { $clientApps['includeAgentIdServicePrincipals'] = & $remapApplicationList $clientApps['includeAgentIdServicePrincipals'] }
        }
    }

    return $PolicyBody
}

function Get-ServicePrincipalDependenciesFromMigrationTable {
    param(
        [string]$BackupFolder,
        [string[]]$RequiredReferenceIds
    )

    $requiredIds = @($RequiredReferenceIds | Where-Object { $_ } | Sort-Object -Unique)
    if ($requiredIds.Count -eq 0) { return @() }

    $migrationPath = Join-Path $BackupFolder 'MigrationTable.json'
    if (-not (Test-Path -LiteralPath $migrationPath)) {
        Write-Log -Level WARN -Message "Migration table '$migrationPath' was not found. Application references will use legacy AppId fallback."
        Write-Host ""
        Write-Host "  [!] MigrationTable.json not found; using legacy AppId fallback." -ForegroundColor Yellow
        return @(
            foreach ($referenceId in $requiredIds) {
                [PSCustomObject]@{
                    DisplayName      = $referenceId
                    Id               = $null
                    AppId            = $referenceId
                    PolicyReferenceId = $referenceId
                    ReferenceKind    = 'AppId'
                    Type             = 'ServicePrincipal'
                }
            }
        )
    }

    try {
        $migrationTable = Get-Content -LiteralPath $migrationPath -Raw -ErrorAction Stop |
                              ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Read service-principal dependencies from '$migrationPath'"
        throw "MigrationTable.json could not be read: $($_.Exception.Message)"
    }

    $objects = @($migrationTable.Objects)
    $servicePrincipals = @(
        $objects | Where-Object {
            $_.Type -in @('ServicePrincipal', 'Application')
        }
    )
    $isLegacyTable = $servicePrincipals.Count -eq 0

    $dependencies = [System.Collections.Generic.List[object]]::new()
    $missingReferences = [System.Collections.Generic.List[string]]::new()
    foreach ($referenceId in $requiredIds) {
        $entry = @(
            $servicePrincipals | Where-Object {
                $_.PolicyReferenceId -eq $referenceId -or
                $_.AppId -eq $referenceId -or
                $_.Id -eq $referenceId
            }
        ) | Select-Object -First 1

        if ($entry -and $entry.AppId) {
            $dependencies.Add([PSCustomObject]@{
                DisplayName       = $entry.DisplayName
                Id                = $entry.Id
                AppId             = $entry.AppId
                PolicyReferenceId = $(if ($entry.PolicyReferenceId) { $entry.PolicyReferenceId } else { $referenceId })
                ReferenceKind     = $(if ($entry.ReferenceKind) { $entry.ReferenceKind } elseif ($referenceId -eq $entry.Id) { 'ServicePrincipalId' } else { 'AppId' })
                Type              = 'ServicePrincipal'
            })
            continue
        }

        if ($isLegacyTable) {
            Write-Log -Level WARN -Message "Legacy migration table '$migrationPath' contains no service-principal entries. Treating policy reference '$referenceId' as an AppId."
            $dependencies.Add([PSCustomObject]@{
                DisplayName       = $referenceId
                Id                = $null
                AppId             = $referenceId
                PolicyReferenceId = $referenceId
                ReferenceKind     = 'AppId'
                Type              = 'ServicePrincipal'
            })
        }
        else {
            Write-Log -Level ERROR -Message "Service-principal reference '$referenceId' is not present in '$migrationPath'."
            Write-Host "  [!] Service-principal reference $referenceId is missing from MigrationTable.json." -ForegroundColor Red
            $missingReferences.Add($referenceId)
        }
    }

    if ($missingReferences.Count -gt 0) {
        throw "MigrationTable.json is missing required service-principal references: $($missingReferences -join ', ')"
    }

    return @($dependencies)
}

function Restore-ServicePrincipals {
    param(
        [object[]]$Dependencies,
        [bool]$Preview
    )

    $dependencyGroups = @(
        $Dependencies |
            Where-Object { $_ -and $_.AppId } |
            Group-Object AppId
    )
    $result = [PSCustomObject]@{
        Existing    = 0
        Created     = 0
        Preview     = 0
        Failed      = 0
        FailedIds   = @()
        ReferenceMap = @{}
    }

    if ($dependencyGroups.Count -eq 0) { return $result }

    Write-Host ""
    Write-Host "  ── Service Principals ─────────────────────────────────────────────────" -ForegroundColor Cyan

    foreach ($dependencyGroup in $dependencyGroups) {
        $dependency = $dependencyGroup.Group | Select-Object -First 1
        $aliases = @($dependencyGroup.Group)
        $appId = [string]$dependency.AppId
        $knownName = if ($dependency.DisplayName -and $dependency.DisplayName -ne $appId) {
            [string]$dependency.DisplayName
        }
        elseif ($script:KnownAppNames.ContainsKey($appId)) {
            $script:KnownAppNames[$appId]
        }
        else {
            $appId
        }

        Write-Host "    $knownName ($appId)" -NoNewline -ForegroundColor White

        try {
            $response = Invoke-MgGraphRequest -Method GET `
                            -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$appId'&`$select=id,appId,displayName" `
                            -ErrorAction Stop
            $existing = @($response.value) | Select-Object -First 1
        }
        catch {
            $graphError = Get-GraphErrorMessage -ErrorRecord $_
            Write-LogError -ErrorRecord $_ -Context "Check service principal for App ID '$appId'"
            Write-Host "  [CHECK FAILED: $graphError]" -ForegroundColor Red
            $result.Failed++
            $result.FailedIds += $appId
            continue
        }

        if ($existing) {
            $displayName = if ($existing -is [PSCustomObject]) { $existing.displayName } else { $existing['displayName'] }
            $targetId = if ($existing -is [PSCustomObject]) { $existing.id } else { $existing['id'] }
            foreach ($alias in $aliases) {
                $sourceReference = if ($alias.PolicyReferenceId) { [string]$alias.PolicyReferenceId } else { $appId }
                $referenceKind = if ($alias.ReferenceKind) { [string]$alias.ReferenceKind } else { 'AppId' }
                $result.ReferenceMap[$sourceReference] = if ($referenceKind -eq 'ServicePrincipalId') { $targetId } else { $appId }
            }
            Write-Log -Message "Service principal '$displayName' ($appId) already exists."
            Write-Host "  [SKIPPED — already exists as $displayName]" -ForegroundColor Yellow
            $result.Existing++
            continue
        }

        if ($Preview) {
            Write-Host "  [WOULD CREATE]" -ForegroundColor Cyan
            $result.Preview++
            continue
        }

        try {
            $requestJson = @{ appId = $appId } | ConvertTo-Json -Compress
            $created = Invoke-MgGraphRequest -Method POST `
                           -Uri "https://graph.microsoft.com/v1.0/servicePrincipals" `
                           -ContentType "application/json" `
                           -Body $requestJson -ErrorAction Stop
            $displayName = if ($created -is [PSCustomObject]) { $created.displayName } else { $created['displayName'] }
            $targetId = if ($created -is [PSCustomObject]) { $created.id } else { $created['id'] }
            if ([string]::IsNullOrWhiteSpace($displayName)) { $displayName = $knownName }
            foreach ($alias in $aliases) {
                $sourceReference = if ($alias.PolicyReferenceId) { [string]$alias.PolicyReferenceId } else { $appId }
                $referenceKind = if ($alias.ReferenceKind) { [string]$alias.ReferenceKind } else { 'AppId' }
                $result.ReferenceMap[$sourceReference] = if ($referenceKind -eq 'ServicePrincipalId') { $targetId } else { $appId }
            }

            Write-Log -Message "Created service principal '$displayName' for App ID '$appId'."
            Write-Host "  [CREATED as $displayName]" -ForegroundColor Green
            $result.Created++
        }
        catch {
            $graphError = Get-GraphErrorMessage -ErrorRecord $_
            Write-LogError -ErrorRecord $_ -Context "Create service principal for App ID '$appId'"
            Write-Host "  [FAILED: $graphError]" -ForegroundColor Red
            $result.Failed++
            $result.FailedIds += $appId
        }
    }

    return $result
}

# Restores a single CA policy JSON. Cleans the body, applies ID remapping,
# then POSTs to Graph. Returns 'created', 'skipped', 'unsupported', 'failed',
# or 'preview'.
function Restore-SinglePolicy {
    param(
        $PolicyJson,
        [hashtable]$GroupIdMap,
        [hashtable]$LocationIdMap,
        [hashtable]$ServicePrincipalIdMap = @{},
        [object[]]$ServicePrincipalDependencies = @(),
        [bool]$Preview
    )

    $displayName = if ($PolicyJson -is [PSCustomObject]) { $PolicyJson.displayName } else { $PolicyJson['displayName'] }

    Write-Host "    $displayName" -NoNewline -ForegroundColor White

    # Check if policy with same displayName already exists
    $existing = $null
    try {
        $escaped = $displayName -replace "'", "''"
        $chkResp = Invoke-MgGraphRequest -Method GET `
                       -Uri "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$filter=displayName eq '$escaped'" `
                       -ErrorAction Stop
        $existing = @($chkResp.value) | Select-Object -First 1
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Check whether Conditional Access policy '$displayName' already exists"
    }

    if ($existing) {
        Write-Log -Message "Skipped Conditional Access policy '$displayName' because it already exists."
        Write-Host "  [SKIPPED — already exists]" -ForegroundColor Yellow
        return 'skipped'
    }

    if ($Preview) {
        Write-Host "  [WOULD CREATE — DISABLED]" -ForegroundColor Cyan
        return 'preview'
    }

    try {
        $body = Get-CleanPolicyBody -PolicyJson $PolicyJson
        $body = Invoke-ApplyIdRemapping -PolicyBody $body -GroupIdMap $GroupIdMap `
                    -LocationIdMap $LocationIdMap -ServicePrincipalIdMap $ServicePrincipalIdMap

        # Detect unresolved named-location placeholders (e.g. %CompliantNetworkLocationId%
        # requires Global Secure Access). Fail early with a clear message rather than
        # letting Graph return a confusing 1040.
        $locBlock = $body['conditions']
        $locBlock = if ($locBlock) { $locBlock['locations'] } else { $null }
        $unresolvedLoc = @(
            @(if ($locBlock) { @($locBlock['includeLocations']) } else { @() }) +
            @(if ($locBlock) { @($locBlock['excludeLocations']) } else { @() }) |
            Where-Object { $_ -match '^%.+%$' }
        ) | Select-Object -Unique
        if ($unresolvedLoc.Count -gt 0) {
            $missing = $unresolvedLoc -join ', '
            Write-Log -Level WARN -Message "Conditional Access policy '$displayName' was not created because required named location(s) could not be resolved: $missing. Enable the corresponding tenant prerequisite (e.g., Global Secure Access) and re-run the restore."
            Write-Host "  [SKIPPED — prerequisite named location not available: $missing]" -ForegroundColor Yellow
            return 'unsupported'
        }

        $body = Repair-PolicyCollectionProperties -PolicyBody $body
        $schemaCheck = Test-PolicyRequestSchema -PolicyBody $body
        if (-not $schemaCheck.IsValid) {
            throw "Policy request failed local schema validation: $($schemaCheck.Errors -join '; ')"
        }

        $created = Invoke-MgGraphRequest -Method POST `
                       -Uri "https://graph.microsoft.com/beta/identity/conditionalAccess/policies" `
                       -Headers @{ Prefer = "include-unknown-enum-members" } `
                       -ContentType "application/json" `
                       -Body $schemaCheck.Json -ErrorAction Stop
        Write-Log -Message "Created Conditional Access policy '$displayName' in disabled state."
        Write-Host "  [CREATED — DISABLED]" -ForegroundColor Green
        return 'created'
    }
    catch {
        $policyErrorRecord = $_
        $graphError = Get-GraphErrorMessage -ErrorRecord $_

        # Retry once after provisioning any application service principals that
        # Graph reports as missing. The original policy assignments are kept.
        if ($graphError -match '1034:.*ServicePrincipalNotFound') {
            $missingAppIds = @(
                [regex]::Matches(
                    $graphError,
                    '(?i)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(?="\s*:\s*"ServicePrincipalNotFound")'
                ) | ForEach-Object { $_.Value } | Select-Object -Unique
            )

            if ($missingAppIds.Count -gt 0) {
                Write-Host ""
                Write-Host "    [!] Missing application service principal detected. Provisioning dependency..." -ForegroundColor Yellow
                $missingDependencies = @(
                    foreach ($missingAppId in $missingAppIds) {
                        $dependency = @(
                            $ServicePrincipalDependencies | Where-Object {
                                $_.AppId -eq $missingAppId -or
                                $_.Id -eq $missingAppId -or
                                $_.PolicyReferenceId -eq $missingAppId
                            }
                        ) | Select-Object -First 1

                        if ($dependency) {
                            $dependency
                        }
                        else {
                            [PSCustomObject]@{
                                DisplayName       = $missingAppId
                                Id                = $null
                                AppId             = $missingAppId
                                PolicyReferenceId = $missingAppId
                                ReferenceKind     = 'AppId'
                                Type              = 'ServicePrincipal'
                            }
                        }
                    }
                )
                $spResult = Restore-ServicePrincipals -Dependencies $missingDependencies -Preview $false

                if ($spResult.Failed -eq 0) {
                    try {
                        $created = Invoke-MgGraphRequest -Method POST `
                                       -Uri "https://graph.microsoft.com/beta/identity/conditionalAccess/policies" `
                                       -Headers @{ Prefer = "include-unknown-enum-members" } `
                                       -ContentType "application/json" `
                                       -Body $schemaCheck.Json -ErrorAction Stop
                        Write-Log -Message "Created Conditional Access policy '$displayName' in disabled state after provisioning missing service principals."
                        Write-Host "    $displayName  [CREATED — DISABLED]" -ForegroundColor Green
                        return 'created'
                    }
                    catch {
                        $policyErrorRecord = $_
                        $graphError = Get-GraphErrorMessage -ErrorRecord $_
                    }
                }
            }
        }

        if ($graphError -match '1039:.*premium P2') {
            Write-Log -Level WARN -Message "Conditional Access policy '$displayName' was not created because the target tenant does not have the required Entra ID P2 capability. Graph: $graphError"
            Write-Host "  [SKIPPED — REQUIRES ENTRA ID P2]" -ForegroundColor Yellow
            return 'unsupported'
        }

        if ($graphError -match '1149:.*workload identity premium') {
            Write-Log -Level WARN -Message "Conditional Access policy '$displayName' was not created because the target tenant does not have the required Workload Identity Premium capability. Graph: $graphError"
            Write-Host "  [SKIPPED — REQUIRES WORKLOAD IDENTITY PREMIUM]" -ForegroundColor Yellow
            return 'unsupported'
        }

        Write-LogError -ErrorRecord $policyErrorRecord -Context "Create Conditional Access policy '$displayName'"
        Write-Host "  [FAILED: $graphError]" -ForegroundColor Red
        return 'failed'
    }
}

# Extracts unique group, location, and application IDs from a policy.
# Group IDs include both real UUIDs and placeholder strings (e.g. %CA216ExclGroupId%)
# so that placeholder-based groups in the Groups\ folder are created during restore.
function Get-PolicyDependencyIds {
    param($PolicyJson)

    $groupIds    = [System.Collections.Generic.HashSet[string]]::new()
    $locationIds = [System.Collections.Generic.HashSet[string]]::new()
    $appIds      = [System.Collections.Generic.HashSet[string]]::new()
    $uuidPattern = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'

    $conditions = if ($PolicyJson -is [PSCustomObject]) { $PolicyJson.conditions } else { $PolicyJson['conditions'] }
    if (-not $conditions) { return @{ groups = @(); locations = @(); applications = @() } }

    $users = if ($conditions -is [PSCustomObject]) { $conditions.users } else { $conditions['users'] }
    if ($users) {
        $excGroups = if ($users -is [PSCustomObject]) { $users.excludeGroups } else { $users['excludeGroups'] }
        $incGroups = if ($users -is [PSCustomObject]) { $users.includeGroups } else { $users['includeGroups'] }
        foreach ($gid in @($excGroups) + @($incGroups)) {
            if ($gid) { $null = $groupIds.Add($gid) }
        }
    }

    $locs = if ($conditions -is [PSCustomObject]) { $conditions.locations } else { $conditions['locations'] }
    if ($locs) {
        $excLocs = if ($locs -is [PSCustomObject]) { $locs.excludeLocations } else { $locs['excludeLocations'] }
        $incLocs = if ($locs -is [PSCustomObject]) { $locs.includeLocations } else { $locs['includeLocations'] }
        # Location IDs include both real UUIDs and placeholder strings (e.g. %SvcCountryLocationId%)
        # so that placeholder-based locations in the NamedLocations\ folder are created during restore.
        # The reserved keywords All / AllTrusted are not real locations and must not be collected.
        foreach ($lid in @($excLocs) + @($incLocs)) {
            if ($lid -and $lid -notin @('All', 'AllTrusted')) { $null = $locationIds.Add($lid) }
        }
    }

    $apps = if ($conditions -is [PSCustomObject]) { $conditions.applications } else { $conditions['applications'] }
    if ($apps) {
        $excApps = if ($apps -is [PSCustomObject]) { $apps.excludeApplications } else { $apps['excludeApplications'] }
        $incApps = if ($apps -is [PSCustomObject]) { $apps.includeApplications } else { $apps['includeApplications'] }
        foreach ($appId in @($excApps) + @($incApps)) {
            if ($appId -and $appId -match $uuidPattern) { $null = $appIds.Add($appId) }
        }
    }

    $clientApps = if ($conditions -is [PSCustomObject]) { $conditions.clientApplications } else { $conditions['clientApplications'] }
    if ($clientApps) {
        $excServicePrincipals = if ($clientApps -is [PSCustomObject]) { $clientApps.excludeServicePrincipals } else { $clientApps['excludeServicePrincipals'] }
        $incServicePrincipals = if ($clientApps -is [PSCustomObject]) { $clientApps.includeServicePrincipals } else { $clientApps['includeServicePrincipals'] }
        $excAgentPrincipals = if ($clientApps -is [PSCustomObject]) { $clientApps.excludeAgentIdServicePrincipals } else { $clientApps['excludeAgentIdServicePrincipals'] }
        $incAgentPrincipals = if ($clientApps -is [PSCustomObject]) { $clientApps.includeAgentIdServicePrincipals } else { $clientApps['includeAgentIdServicePrincipals'] }
        foreach ($appId in @($excServicePrincipals) + @($incServicePrincipals) + @($excAgentPrincipals) + @($incAgentPrincipals)) {
            if ($appId -and $appId -match $uuidPattern) { $null = $appIds.Add($appId) }
        }
    }

    return @{
        groups       = @($groupIds)
        locations    = @($locationIds)
        applications = @($appIds)
    }
}

function Test-PolicyRequiresEntraP2 {
    param($PolicyJson)

    $conditions = if ($PolicyJson -is [PSCustomObject]) { $PolicyJson.conditions } else { $PolicyJson['conditions'] }
    if (-not $conditions) { return $false }

    foreach ($propertyName in @('signInRiskLevels', 'userRiskLevels', 'servicePrincipalRiskLevels', 'insiderRiskLevels')) {
        $value = if ($conditions -is [PSCustomObject]) {
            $conditions.$propertyName
        }
        else {
            $conditions[$propertyName]
        }
        if (@($value | Where-Object { $_ }).Count -gt 0) { return $true }
    }

    # agentIdRiskLevels is a string condition (e.g. "high", "medium,high") used by AGT risk policies
    $agentRisk = if ($conditions -is [PSCustomObject]) { $conditions.agentIdRiskLevels } else { $conditions['agentIdRiskLevels'] }
    if ($agentRisk -and $agentRisk -ne 'none') { return $true }

    return $false
}

function Show-EntraP2RestoreWarning {
    param([object[]]$Policies)

    $p2PolicyNames = @(
        foreach ($policy in $Policies) {
            if (Test-PolicyRequiresEntraP2 -PolicyJson $policy) {
                if ($policy -is [PSCustomObject]) { $policy.displayName } else { $policy['displayName'] }
            }
        }
    )

    if ($p2PolicyNames.Count -eq 0) { return }

    Write-Host ""
    Write-Host "  [!] Entra ID P2 required for $($p2PolicyNames.Count) selected policy/policies:" -ForegroundColor Yellow
    foreach ($policyName in $p2PolicyNames) {
        Write-Host "      - $policyName" -ForegroundColor DarkGray
    }
    Write-Host "      Without Entra ID P2, these policies will be skipped and reported as LICENSE REQUIRED." -ForegroundColor Yellow
    Write-Log -Level WARN -Message "Selected restore contains $($p2PolicyNames.Count) Conditional Access policy/policies that require Entra ID P2: $($p2PolicyNames -join '; ')."
}

# ─────────────────────────────────────────────────────────────────────────────
# RESTORE ORCHESTRATOR
# ─────────────────────────────────────────────────────────────────────────────

function Invoke-RestoreConditionalAccess {
    Write-Log -Message "Restore operation requested."

    if (-not (Confirm-GraphConnection)) {
        Write-Log -Level WARN -Message "Restore cancelled because Microsoft Graph is not connected."
        Write-Host ""
        Write-Host "  [!] Not connected to Microsoft Graph." -ForegroundColor Red
        Write-Host "      Select option [1] to connect first." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    do {
        Clear-Host
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "  ║          RESTORE MODE  —  Conditional Access Policies              ║" -ForegroundColor Cyan
        Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1]  Restore from Backup Folder" -ForegroundColor Yellow
        Write-Host "       └─ Browse to a backup folder and select which policies to restore" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  [2]  Restore Single Policy from File" -ForegroundColor Yellow
        Write-Host "       └─ Browse to a single .json policy file (resolves dependencies automatically)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  [0]  Back to Main Menu" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""

        $sub = Read-Host "  Enter your choice"

        switch ($sub.Trim()) {

            '1' {
                # ── Restore from backup folder ────────────────────────────────
                $folderPath = Show-FolderBrowserDialog `
                                  -Description "Select Backup Folder to Restore From" `
                                  -SelectedPath $PSScriptRoot
                if (-not $folderPath) { break }

                $caDir  = Join-Path $folderPath "ConditionalAccess"
                $grpDir = Join-Path $folderPath "Groups"
                $locDir = Join-Path $folderPath "NamedLocations"

                if (-not (Test-Path $caDir)) {
                    Write-Log -Level ERROR -Message "Selected restore folder '$folderPath' does not contain a ConditionalAccess subfolder."
                    Write-Host ""
                    Write-Host "  ✗ The selected folder does not contain a 'ConditionalAccess\' subfolder." -ForegroundColor Red
                    Write-Host "    Please select a valid backup folder." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    break
                }

                if (-not (Test-Path $grpDir))  {
                    Write-Log -Level WARN -Message "Restore folder '$folderPath' does not contain a Groups subfolder."
                    Write-Host "  [!] 'Groups\' subfolder not found — group creation will be skipped." -ForegroundColor Yellow
                }
                if (-not (Test-Path $locDir))  {
                    Write-Log -Level WARN -Message "Restore folder '$folderPath' does not contain a NamedLocations subfolder."
                    Write-Host "  [!] 'NamedLocations\' subfolder not found — location creation will be skipped." -ForegroundColor Yellow
                }

                # Load policy files
                $policyFiles = @(Get-ChildItem -Path $caDir -Filter "*.json" -File | Sort-Object Name)
                if ($policyFiles.Count -eq 0) {
                    Write-Host ""
                    Write-Host "  No .json files found in ConditionalAccess\ subfolder." -ForegroundColor Yellow
                    Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    break
                }

                # Show numbered policy list
                Clear-Host
                Write-Host ""
                Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
                Write-Host "  ║          RESTORE MODE  —  Select Policies to Restore               ║" -ForegroundColor Cyan
                Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Folder : $folderPath" -ForegroundColor DarkGray
                Write-Host ""

                $policyData = [System.Collections.Generic.List[object]]::new()
                $idx = 1
                foreach ($f in $policyFiles) {
                    try {
                        $pj = Get-Content -Path $f.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
                        $policyData.Add([PSCustomObject]@{ File = $f; Json = $pj; Index = $idx })
                        $state = if ($pj -is [PSCustomObject]) { $pj.state } else { $pj['state'] }
                        $name  = if ($pj -is [PSCustomObject]) { $pj.displayName } else { $pj['displayName'] }
                        $stateColor = switch ($state) {
                            'enabled' { 'Green' }
                            'enabledForReportingButNotEnforced' { 'Yellow' }
                            default   { 'DarkGray' }
                        }
                        Write-Host "    " -NoNewline
                        Write-Host ("[{0}]" -f $idx) -NoNewline -ForegroundColor Yellow
                        Write-Host ("  {0,-65}" -f $name) -NoNewline -ForegroundColor White
                        Write-Host "  [$state]" -ForegroundColor $stateColor
                        $idx++
                    }
                    catch {
                        Write-LogError -ErrorRecord $_ -Context "Read Conditional Access policy backup '$($f.FullName)'"
                        Write-Host "    [?]  $($f.Name)  [read error]" -ForegroundColor Red
                        $idx++
                    }
                }
                Write-Host ""
                Write-Host "  " -NoNewline; Write-Host "[A]" -NoNewline -ForegroundColor Green
                Write-Host "  Select all policies" -ForegroundColor White
                Write-Host "  " -NoNewline; Write-Host "[O]" -NoNewline -ForegroundColor DarkCyan
                Write-Host "  Open in Out-GridView (searchable / sortable)" -ForegroundColor DarkGray
                Write-Host "  " -NoNewline; Write-Host "[0]" -NoNewline -ForegroundColor Red
                Write-Host "  Cancel" -ForegroundColor White
                Write-Host ""

                $restoreSel = Read-Host "  Select policies to restore (comma-separated like 1,3,5 or range like 1-5 or A for all)"
                if ($restoreSel -eq '0' -or [string]::IsNullOrWhiteSpace($restoreSel)) { break }

                $selectedItems = @()
                if ($restoreSel -match '^[Aa]$') {
                    $selectedItems = @($policyData)
                }
                elseif ($restoreSel -match '^[Oo]$') {
                    $ogvList = $policyData | ForEach-Object {
                        $n = if ($_.Json -is [PSCustomObject]) { $_.Json.displayName } else { $_.Json['displayName'] }
                        $s = if ($_.Json -is [PSCustomObject]) { $_.Json.state }       else { $_.Json['state']       }
                        [PSCustomObject]@{ DisplayName = $n; State = $s; _Index = $_.Index }
                    }
                    $ogvSel = $ogvList | Out-GridView -Title "Select Policies to Restore  |  Ctrl+Click for multi-select" -PassThru
                    if (-not $ogvSel -or $ogvSel.Count -eq 0) { break }
                    $selIdxs = @($ogvSel | ForEach-Object { $_._Index })
                    $selectedItems = @($policyData | Where-Object { $_.Index -in $selIdxs })
                }
                else {
                    $chosen = ConvertFrom-SelectionString -SelectionText $restoreSel -MaxIndex $policyData.Count
                    if ($chosen.Count -eq 0) {
                        Write-Host "  [!] No valid policies selected." -ForegroundColor Yellow
                        Start-Sleep -Seconds 2
                        break
                    }
                    $selectedItems = @($chosen | ForEach-Object { $policyData[$_ - 1] })
                }

                if ($selectedItems.Count -eq 0) { break }

                Show-EntraP2RestoreWarning -Policies @($selectedItems | ForEach-Object { $_.Json })

                Write-Host ""
                $previewAns = Read-Host "  Preview only or Apply? (P=preview / A=apply / 0=cancel)"
                if ($previewAns -eq '0' -or [string]::IsNullOrWhiteSpace($previewAns)) { break }
                $previewMode = $previewAns -match '^[Pp]'
                Write-Log -Message "Folder restore started from '$folderPath'. Selected policies: $($selectedItems.Count); preview: $previewMode."

                Clear-Host
                Write-Host ""
                Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
                if ($previewMode) {
                    Write-Host "  ║          RESTORE MODE  —  PREVIEW (no changes will be made)        ║" -ForegroundColor Yellow
                }
                else {
                    Write-Host "  ║          RESTORE MODE  —  Applying Restore...                      ║" -ForegroundColor Cyan
                }
                Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

                # Collect group UUIDs referenced by selected policies only
                $neededGroupIds    = [System.Collections.Generic.HashSet[string]]::new()
                $neededLocationIds = [System.Collections.Generic.HashSet[string]]::new()
                $neededAppIds      = [System.Collections.Generic.HashSet[string]]::new()
                foreach ($item in $selectedItems) {
                    $deps = Get-PolicyDependencyIds -PolicyJson $item.Json
                    foreach ($gid in $deps.groups)    { $null = $neededGroupIds.Add($gid) }
                    foreach ($lid in $deps.locations) { $null = $neededLocationIds.Add($lid) }
                    foreach ($appId in $deps.applications) { $null = $neededAppIds.Add($appId) }
                }

                # Resolve application dependencies through MigrationTable.json,
                # then create missing target-tenant service principals by AppId.
                try {
                    $spDependencies = Get-ServicePrincipalDependenciesFromMigrationTable `
                                          -BackupFolder $folderPath `
                                          -RequiredReferenceIds @($neededAppIds)
                }
                catch {
                    Write-LogError -ErrorRecord $_ -Context "Resolve service-principal dependencies for folder restore '$folderPath'"
                    Write-Host ""
                    Write-Host "  [!] Restore stopped: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host "      Re-export the backup to regenerate MigrationTable.json." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    break
                }
                $spRestoreResult = Restore-ServicePrincipals `
                                       -Dependencies $spDependencies `
                                       -Preview $previewMode

                # Restore Named Locations first
                $locationIdMap = Restore-NamedLocations -BackupFolder $folderPath `
                                     -RequiredOldIds @($neededLocationIds) -Preview $previewMode

                # Restore only the groups needed by selected policies
                $groupIdMap = Restore-ExclusionGroups -BackupFolder $folderPath `
                                  -RequiredOldIds @($neededGroupIds) -Preview $previewMode

                # Restore selected policies
                Write-Host ""
                Write-Host "  ── Conditional Access Policies ─────────────────────────────────────────" -ForegroundColor Cyan
                $stats = @{ created = 0; skipped = 0; unsupported = 0; failed = 0; preview = 0 }
                $pIdx  = 0
                foreach ($item in $selectedItems) {
                    $pIdx++
                    Write-Progress -Activity "Restoring Policies" `
                                   -Status "$pIdx of $($selectedItems.Count)" `
                                   -PercentComplete (($pIdx / $selectedItems.Count) * 100)
                    $result = Restore-SinglePolicy -PolicyJson $item.Json `
                                  -GroupIdMap $groupIdMap -LocationIdMap $locationIdMap `
                                  -ServicePrincipalIdMap $spRestoreResult.ReferenceMap `
                                  -ServicePrincipalDependencies $spDependencies `
                                  -Preview $previewMode
                    $stats[$result]++
                }
                Write-Progress -Activity "Restoring Policies" -Completed

                # Summary
                Write-Host ""
                Write-Host "  ══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
                if ($previewMode) {
                    Write-Host "  PREVIEW COMPLETE  —  No changes were made" -ForegroundColor Yellow
                    Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                    Write-Host "    Would create : $($stats['preview'])" -ForegroundColor Cyan
                    Write-Host "    Would skip   : $($stats['skipped'])  (already exist)" -ForegroundColor Yellow
                }
                else {
                    Write-Host "  RESTORE COMPLETE" -ForegroundColor Cyan
                    Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                    Write-Host "    Created      : $($stats['created'])  (all in DISABLED state)" -ForegroundColor Green
                    Write-Host "    Skipped      : $($stats['skipped'])  (already exist)" -ForegroundColor Yellow
                    Write-Host "    License req. : $($stats['unsupported'])  (requires Entra ID P2, Workload Identity Premium, or tenant prerequisite)" -ForegroundColor $(if ($stats['unsupported'] -gt 0) { 'Yellow' } else { 'Green' })
                    Write-Host "    Failed       : $($stats['failed'])" -ForegroundColor $(if ($stats['failed'] -gt 0) { 'Red' } else { 'Green' })
                    if ($stats['failed'] -gt 0 -and $script:LogEnabled) {
                        Write-Host "    Troubleshooting log: $script:LogPath" -ForegroundColor DarkGray
                    }
                    if ($stats['created'] -gt 0) {
                        Write-Host ""
                        Write-Host "  [!] All restored policies are in DISABLED state." -ForegroundColor Yellow
                        Write-Host "      Review each policy in the Entra portal before enabling." -ForegroundColor DarkGray
                    }
                }
                Write-Host "  ══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
                Write-Log -Message "Folder restore completed. Preview: $previewMode; created: $($stats['created']); skipped: $($stats['skipped']); license required: $($stats['unsupported']); failed: $($stats['failed']); preview count: $($stats['preview'])."
                Write-Host ""
                Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }

            '2' {
                # ── Single policy file ────────────────────────────────────────
                $filePath = Show-OpenFileDialog -Title "Select CA Policy JSON File" -InitialDirectory $PSScriptRoot
                if (-not $filePath) { break }

                $policyJson = $null
                try {
                    $policyJson = Get-Content -Path $filePath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                }
                catch {
                    Write-LogError -ErrorRecord $_ -Context "Read single Conditional Access policy file '$filePath'"
                    Write-Host ""
                    Write-Host "  ✗ Could not read file: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    break
                }

                $policyName = if ($policyJson -is [PSCustomObject]) { $policyJson.displayName } else { $policyJson['displayName'] }

                # Determine backup root from file path (file is typically in <root>\ConditionalAccess\)
                $parentDir = Split-Path $filePath -Parent
                $backupRoot = Split-Path $parentDir -Parent
                $hasGroups    = Test-Path (Join-Path $backupRoot "Groups")
                $hasLocations = Test-Path (Join-Path $backupRoot "NamedLocations")

                if (-not $hasGroups)    {
                    Write-Log -Level WARN -Message "Single-policy restore root '$backupRoot' does not contain a Groups folder."
                    Write-Host "  [!] 'Groups\' folder not found at parent level — group creation skipped." -ForegroundColor Yellow
                }
                if (-not $hasLocations) {
                    Write-Log -Level WARN -Message "Single-policy restore root '$backupRoot' does not contain a NamedLocations folder."
                    Write-Host "  [!] 'NamedLocations\' folder not found — location creation skipped." -ForegroundColor Yellow
                }

                Clear-Host
                Write-Host ""
                Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
                Write-Host "  ║          RESTORE MODE  —  Single Policy                            ║" -ForegroundColor Cyan
                Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Policy : " -NoNewline -ForegroundColor Gray; Write-Host $policyName -ForegroundColor White
                Write-Host ""

                # Collect dependencies for this policy only
                $deps = Get-PolicyDependencyIds -PolicyJson $policyJson
                Write-Host "  Referenced Groups    : $($deps.groups.Count)" -ForegroundColor Gray
                Write-Host "  Referenced Locations : $($deps.locations.Count)" -ForegroundColor Gray
                Write-Host "  Referenced App IDs   : $($deps.applications.Count)" -ForegroundColor Gray
                Show-EntraP2RestoreWarning -Policies @($policyJson)
                Write-Host ""

                $previewAns = Read-Host "  Preview only or Apply? (P=preview / A=apply / 0=cancel)"
                if ($previewAns -eq '0' -or [string]::IsNullOrWhiteSpace($previewAns)) { break }
                $previewMode = $previewAns -match '^[Pp]'
                Write-Log -Message "Single-policy restore started for '$policyName' from '$filePath'. Preview: $previewMode."

                Write-Host ""

                # Resolve application dependencies through MigrationTable.json,
                # then create missing target-tenant service principals by AppId.
                try {
                    $spDependencies = Get-ServicePrincipalDependenciesFromMigrationTable `
                                          -BackupFolder $backupRoot `
                                          -RequiredReferenceIds $deps.applications
                }
                catch {
                    Write-LogError -ErrorRecord $_ -Context "Resolve service-principal dependencies for single-policy restore '$filePath'"
                    Write-Host ""
                    Write-Host "  [!] Restore stopped: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host "      Re-export the backup to regenerate MigrationTable.json." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    break
                }
                $spRestoreResult = Restore-ServicePrincipals `
                                       -Dependencies $spDependencies `
                                       -Preview $previewMode

                # Restore only needed Named Locations
                $locationIdMap = Restore-NamedLocations -BackupFolder $backupRoot `
                                     -RequiredOldIds $deps.locations -Preview $previewMode

                # Restore only needed Groups
                $groupIdMap = Restore-ExclusionGroups -BackupFolder $backupRoot `
                                  -RequiredOldIds $deps.groups -Preview $previewMode

                # Restore the policy
                Write-Host ""
                Write-Host "  ── Conditional Access Policy ───────────────────────────────────────────" -ForegroundColor Cyan
                $result = Restore-SinglePolicy -PolicyJson $policyJson `
                              -GroupIdMap $groupIdMap -LocationIdMap $locationIdMap `
                              -ServicePrincipalIdMap $spRestoreResult.ReferenceMap `
                              -ServicePrincipalDependencies $spDependencies `
                              -Preview $previewMode

                Write-Host ""
                Write-Host "  ══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
                if ($previewMode) {
                    Write-Host "  PREVIEW COMPLETE  —  No changes were made" -ForegroundColor Yellow
                }
                else {
                    switch ($result) {
                        'created' {
                            Write-Host "  RESTORE COMPLETE" -ForegroundColor Cyan
                            Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                            Write-Host "  [!] Policy created in DISABLED state. Enable it in the Entra portal." -ForegroundColor Yellow
                        }
                        'skipped' { Write-Host "  Policy already exists — no changes made." -ForegroundColor Yellow }
                        'unsupported' {
                            Write-Host "  Policy skipped because a premium license (Entra ID P2 or Workload Identity Premium) is required." -ForegroundColor Yellow
                        }
                        'failed'  {
                            Write-Host "  Restore failed. See error above." -ForegroundColor Red
                            if ($script:LogEnabled) {
                                Write-Host "  Troubleshooting log: $script:LogPath" -ForegroundColor DarkGray
                            }
                        }
                    }
                }
                Write-Host "  ══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
                Write-Log -Message "Single-policy restore completed for '$policyName'. Preview: $previewMode; result: $result."
                Write-Host ""
                Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }

            '0' { return }

            default {
                Write-Host ""
                Write-Host "  [!] Invalid selection. Please enter 1, 2, or 0." -ForegroundColor Red
                Write-Host ""
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
}

# ─────────────────────────────────────────────────────────────────────────────
# LIST / REVIEW POLICIES
# ─────────────────────────────────────────────────────────────────────────────

function Invoke-ListPolicies {
    Write-Log -Message "List policies operation requested."

    if (-not (Confirm-GraphConnection)) {
        Write-Log -Level WARN -Message "List policies cancelled because Microsoft Graph is not connected."
        Write-Host ""
        Write-Host "  [!] Not connected to Microsoft Graph." -ForegroundColor Red
        Write-Host "      Select option [1] to connect first." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║         LIST / REVIEW  —  Conditional Access Policies              ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Fetching Conditional Access policies from tenant..." -ForegroundColor DarkGray

    $allPolicies = [System.Collections.Generic.List[object]]::new()
    try {
        $uri = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies?`$top=999"
        do {
            $response = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
            foreach ($item in $response.value) { $allPolicies.Add($item) }
            $uri = $response['@odata.nextLink']
        } while ($uri)
    }
    catch {
        $graphError = Get-GraphErrorMessage -ErrorRecord $_
        Write-LogError -ErrorRecord $_ -Context "Retrieve Conditional Access policies for list view"
        Write-Host ""
        Write-Host "  ✗ Failed to retrieve policies: $graphError" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    if ($allPolicies.Count -eq 0) {
        Write-Host "  No Conditional Access policies found in this tenant." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    # Build display list
    $displayList = $allPolicies | ForEach-Object {
        $cond = $_['conditions']
        $incUsers = if ($cond -and $cond['users']) { ($cond['users']['includeUsers'] -join ', ') } else { '' }
        $incApps  = if ($cond -and $cond['applications']) { ($cond['applications']['includeApplications'] -join ', ') } else { '' }
        [PSCustomObject]@{
            DisplayName  = $_['displayName']
            State        = $_['state']
            CreatedDate  = if ($_['createdDateTime']) { ([datetime]$_['createdDateTime']).ToString('yyyy-MM-dd') } else { '' }
            Modified     = if ($_['modifiedDateTime']) { ([datetime]$_['modifiedDateTime']).ToString('yyyy-MM-dd') } else { '' }
            IncludeUsers = $incUsers
            IncludeApps  = $incApps
            Id           = $_['id']
        }
    } | Sort-Object State, DisplayName

    # Sub-menu loop
    do {
        Clear-Host
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "  ║         LIST / REVIEW  —  Conditional Access Policies              ║" -ForegroundColor Cyan
        Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        $enabledCount  = @($displayList | Where-Object { $_.State -eq 'enabled' }).Count
        $disabledCount = @($displayList | Where-Object { $_.State -eq 'disabled' }).Count
        $reportCount   = @($displayList | Where-Object { $_.State -eq 'enabledForReportingButNotEnforced' }).Count
        Write-Host "  Policies loaded  : " -NoNewline -ForegroundColor Gray
        Write-Host "$($allPolicies.Count)  (" -NoNewline -ForegroundColor White
        Write-Host "$enabledCount Enabled" -NoNewline -ForegroundColor Green
        Write-Host " / " -NoNewline -ForegroundColor DarkGray
        Write-Host "$reportCount Report-only" -NoNewline -ForegroundColor Yellow
        Write-Host " / " -NoNewline -ForegroundColor DarkGray
        Write-Host "$disabledCount Disabled" -NoNewline -ForegroundColor DarkGray
        Write-Host ")" -ForegroundColor White
        Write-Host ""
        Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  [1]  Browse Policies" -ForegroundColor Yellow
        Write-Host "       └─ Numbered list with detail view and Out-GridView option" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  [2]  Export Policies to CSV" -ForegroundColor Yellow
        Write-Host "       └─ Save all policies and key details to a CSV file" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  [0]  Back to Main Menu" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""

        $sub = Read-Host "  Enter your choice"

        switch ($sub.Trim().ToUpper()) {

            '1' {
                $enabledList  = @($displayList | Where-Object { $_.State -eq 'enabled' })
                $reportList   = @($displayList | Where-Object { $_.State -eq 'enabledForReportingButNotEnforced' })
                $disabledList = @($displayList | Where-Object { $_.State -eq 'disabled' })
                $browseList   = $enabledList + $reportList + $disabledList

                do {
                    Clear-Host
                    Write-Host ""
                    Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
                    Write-Host "  ║         LIST / REVIEW  —  Conditional Access Policies              ║" -ForegroundColor Cyan
                    Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
                    Write-Host ""

                    $bi = 1
                    if ($enabledList.Count -gt 0) {
                        Write-Host "  Enabled Policies:" -ForegroundColor Green
                        foreach ($p in $enabledList) {
                            Write-Host "    " -NoNewline
                            Write-Host ("[{0}]" -f $bi) -NoNewline -ForegroundColor Yellow
                            Write-Host "  $($p.DisplayName)" -ForegroundColor White
                            $bi++
                        }
                        Write-Host ""
                    }
                    if ($reportList.Count -gt 0) {
                        Write-Host "  Report-Only Policies:" -ForegroundColor Yellow
                        foreach ($p in $reportList) {
                            Write-Host "    " -NoNewline
                            Write-Host ("[{0}]" -f $bi) -NoNewline -ForegroundColor Yellow
                            Write-Host "  $($p.DisplayName)" -ForegroundColor White
                            $bi++
                        }
                        Write-Host ""
                    }
                    if ($disabledList.Count -gt 0) {
                        Write-Host "  Disabled Policies:" -ForegroundColor DarkGray
                        foreach ($p in $disabledList) {
                            Write-Host "    " -NoNewline
                            Write-Host ("[{0}]" -f $bi) -NoNewline -ForegroundColor Yellow
                            Write-Host "  $($p.DisplayName)" -ForegroundColor DarkGray
                            $bi++
                        }
                        Write-Host ""
                    }

                    Write-Host "  " -NoNewline; Write-Host "[O]" -NoNewline -ForegroundColor DarkCyan
                    Write-Host "  Open in Out-GridView (searchable / sortable)" -ForegroundColor DarkGray
                    Write-Host "  " -NoNewline; Write-Host "[0]" -NoNewline -ForegroundColor Red
                    Write-Host "  Back" -ForegroundColor White
                    Write-Host ""

                    $browseInput = Read-Host "  Enter a number for policy details, [O] for GridView, or [0] to go back"

                    if ($browseInput -eq '0' -or [string]::IsNullOrWhiteSpace($browseInput)) { break }

                    if ($browseInput -match '^[Oo]$') {
                        $browseList | Out-GridView -Title "Conditional Access Policies  |  $($browseList.Count) total  |  Read-only review"
                        continue
                    }

                    if ($browseInput -match '^\d+$') {
                        $bIdx = [int]$browseInput
                        if ($bIdx -ge 1 -and $bIdx -le $browseList.Count) {
                            $p = $browseList[$bIdx - 1]

                            # Fetch full policy for detail view
                            $fullPolicy = $null
                            try {
                                $fullPolicy = Invoke-MgGraphRequest -Method GET `
                                                 -Uri "https://graph.microsoft.com/beta/identity/conditionalAccess/policies/$($p.Id)" `
                                                 -ErrorAction Stop
                            }
                            catch {
                                Write-LogError -ErrorRecord $_ -Context "Retrieve details for Conditional Access policy '$($p.DisplayName)' ($($p.Id))"
                            }

                            Clear-Host
                            Write-Host ""
                            Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
                            Write-Host "  ║         POLICY DETAILS  —  Conditional Access                      ║" -ForegroundColor Cyan
                            Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
                            Write-Host ""
                            Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                            Write-Host "  Name         : " -NoNewline -ForegroundColor Gray; Write-Host $p.DisplayName -ForegroundColor White
                            Write-Host "  State        : " -NoNewline -ForegroundColor Gray
                            $sc = switch ($p.State) { 'enabled' { 'Green' } 'enabledForReportingButNotEnforced' { 'Yellow' } default { 'DarkGray' } }
                            Write-Host $p.State -ForegroundColor $sc
                            Write-Host "  Created      : " -NoNewline -ForegroundColor Gray; Write-Host $p.CreatedDate -ForegroundColor White
                            Write-Host "  Modified     : " -NoNewline -ForegroundColor Gray; Write-Host $p.Modified -ForegroundColor White
                            Write-Host "  ID           : " -NoNewline -ForegroundColor Gray; Write-Host $p.Id -ForegroundColor DarkGray

                            if ($fullPolicy) {
                                $cond = $fullPolicy['conditions']
                                if ($cond) {
                                    Write-Host ""
                                    Write-Host "  ── Conditions ──────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                                    $users = $cond['users']
                                    if ($users) {
                                        Write-Host "  Include Users  : " -NoNewline -ForegroundColor Gray; Write-Host ($users['includeUsers'] -join ', ') -ForegroundColor White
                                        Write-Host "  Exclude Users  : " -NoNewline -ForegroundColor Gray; Write-Host ($users['excludeUsers'] -join ', ') -ForegroundColor White
                                        Write-Host "  Include Groups : " -NoNewline -ForegroundColor Gray; Write-Host ($users['includeGroups'] -join ', ') -ForegroundColor White
                                        Write-Host "  Exclude Groups : " -NoNewline -ForegroundColor Gray; Write-Host ($users['excludeGroups'] -join ', ') -ForegroundColor White
                                        Write-Host "  Include Roles  : " -NoNewline -ForegroundColor Gray; Write-Host ($users['includeRoles'] -join ', ') -ForegroundColor DarkGray
                                    }
                                    $apps = $cond['applications']
                                    if ($apps) {
                                        Write-Host "  Include Apps   : " -NoNewline -ForegroundColor Gray; Write-Host ($apps['includeApplications'] -join ', ') -ForegroundColor White
                                    }
                                    $platforms = $cond['platforms']
                                    if ($platforms) {
                                        Write-Host "  Platforms      : " -NoNewline -ForegroundColor Gray; Write-Host ($platforms['includePlatforms'] -join ', ') -ForegroundColor White
                                    }
                                    $locs = $cond['locations']
                                    if ($locs) {
                                        Write-Host "  Incl Locations : " -NoNewline -ForegroundColor Gray; Write-Host ($locs['includeLocations'] -join ', ') -ForegroundColor White
                                        Write-Host "  Excl Locations : " -NoNewline -ForegroundColor Gray; Write-Host ($locs['excludeLocations'] -join ', ') -ForegroundColor White
                                    }
                                }
                                $grant = $fullPolicy['grantControls']
                                if ($grant) {
                                    Write-Host ""
                                    Write-Host "  ── Grant Controls ──────────────────────────────────────────────────────" -ForegroundColor DarkGray
                                    Write-Host "  Operator       : " -NoNewline -ForegroundColor Gray; Write-Host $grant['operator'] -ForegroundColor White
                                    Write-Host "  Built-In       : " -NoNewline -ForegroundColor Gray; Write-Host ($grant['builtInControls'] -join ', ') -ForegroundColor White
                                    if ($grant['authenticationStrength']) {
                                        $as = $grant['authenticationStrength']
                                        $asName = if ($as -is [PSCustomObject]) { $as.displayName } else { $as['displayName'] }
                                        Write-Host "  Auth Strength  : " -NoNewline -ForegroundColor Gray; Write-Host $asName -ForegroundColor White
                                    }
                                }
                            }

                            Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                            Write-Host ""
                            Write-Host "  Press any key to return to the list..." -ForegroundColor DarkGray
                            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                        }
                    }
                } while ($true)
            }

            '2' {
                Add-Type -AssemblyName System.Windows.Forms
                $saveDialog                  = New-Object System.Windows.Forms.SaveFileDialog
                $saveDialog.Title            = "Save Conditional Access Policies CSV"
                $saveDialog.Filter           = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
                $saveDialog.FileName         = "ConditionalAccessPolicies_$(Get-Date -Format 'yyyy-MM-dd')"
                $saveDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
                $saveDialog.OverwritePrompt  = $true

                if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    try {
                        $displayList | Export-Csv -Path $saveDialog.FileName -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
                        Write-Log -Message "Exported Conditional Access policy list to '$($saveDialog.FileName)'."
                        Write-Host ""
                        Write-Host "  ✓ CSV saved to: $($saveDialog.FileName)" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    }
                    catch {
                        Write-LogError -ErrorRecord $_ -Context "Export Conditional Access policy list to '$($saveDialog.FileName)'"
                        Write-Host ""
                        Write-Host "  ✗ Failed to save CSV: $($_.Exception.Message)" -ForegroundColor Red
                        Write-Host ""
                        Write-Host "  Press any key to continue..." -ForegroundColor DarkGray
                        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    }
                }
            }

            '0' { return }

            default {
                Write-Host ""
                Write-Host "  [!] Invalid selection. Please enter 1, 2, or 0." -ForegroundColor Red
                Write-Host ""
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN MENU
# ─────────────────────────────────────────────────────────────────────────────

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║       Conditional Access Manager  —  Microsoft Entra ID            ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    if ($script:IsConnected) {
        $context = Get-MgContext
        Write-Host "  Status  : " -NoNewline -ForegroundColor Gray
        Write-Host "CONNECTED" -ForegroundColor Green
        Write-Host "  Tenant  : " -NoNewline -ForegroundColor Gray
        Write-Host "$($context.TenantId)" -ForegroundColor Green
        Write-Host "  Account : " -NoNewline -ForegroundColor Gray
        Write-Host "$($context.Account)" -ForegroundColor Green
    }
    else {
        Write-Host "  Status  : " -NoNewline -ForegroundColor Gray
        Write-Host "NOT CONNECTED" -ForegroundColor Red
    }

    Write-Host "  Logging : " -NoNewline -ForegroundColor Gray
    if ($script:LogEnabled) {
        Write-Host "ENABLED" -NoNewline -ForegroundColor Green
        Write-Host "  ($script:LogPath)" -ForegroundColor DarkGray
    }
    else {
        Write-Host "DISABLED" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [1]  Connect / Switch Account" -ForegroundColor Yellow
    Write-Host "       └─ Interactive browser sign-in (Policy.ReadWrite.ConditionalAccess, ...)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [2]  Backup Conditional Access Policies" -ForegroundColor Yellow
    Write-Host "       └─ Select policies, export JSON files + groups + locations + MigrationTable" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [3]  Restore Conditional Access Policies" -ForegroundColor Yellow
    Write-Host "       └─ Restore from backup folder or single policy file (all created disabled)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [4]  List Current Policies" -ForegroundColor Yellow
    Write-Host "       └─ Browse all CA policies in a searchable read-only table" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [5]  Disconnect from Microsoft Graph" -ForegroundColor Yellow
    Write-Host "       └─ End the current Graph session" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [6]  Enable / Disable Troubleshooting Log" -ForegroundColor Yellow
    Write-Host "       └─ Log operations and detailed Graph errors to $script:LogPath" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [Q]  Quit" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

function Main {
    $null = Initialize-Logging

    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║       Conditional Access Manager  —  Microsoft Entra ID            ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    if (-not (Test-AndInstall-GraphModules)) {
        Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    # Resume an existing active session if the script is relaunched
    try {
        $ctx = Get-MgContext
        if ($null -ne $ctx -and $null -ne $ctx.TenantId) {
            $script:IsConnected = $true
            $script:TenantId    = $ctx.TenantId
            $script:Account     = $ctx.Account
        }
    }
    catch {
        Write-LogError -ErrorRecord $_ -Context "Resume existing Microsoft Graph session"
    }

    do {
        Show-Menu
        $selection = Read-Host "  Enter your choice"

        switch ($selection.Trim().ToUpper()) {
            '1' { Connect-ToGraph }
            '2' { Invoke-BackupConditionalAccess }
            '3' { Invoke-RestoreConditionalAccess }
            '4' { Invoke-ListPolicies }
            '5' { Disconnect-FromGraph }
            '6' { Set-LoggingState -Enabled (-not $script:LogEnabled) }
            'Q' {
                Write-Log -Message "Script exited by the user."
                Write-Host ""
                if ($script:IsConnected) {
                    Write-Host "  Note: You are still connected to Microsoft Graph." -ForegroundColor Yellow
                    Write-Host "        Run 'Disconnect-MgGraph' if you want to close the session." -ForegroundColor DarkGray
                }
                Write-Host ""
                Write-Host "  Goodbye." -ForegroundColor Cyan
                Write-Host ""
                return
            }
            default {
                Write-Host ""
                Write-Host "  [!] Invalid selection. Please enter 1, 2, 3, 4, 5, 6, or Q." -ForegroundColor Red
                Write-Host ""
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
}

Main
