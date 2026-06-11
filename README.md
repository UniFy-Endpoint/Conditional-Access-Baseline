# Microsoft Entra Conditional Access Zero Trust Baseline

This repository contains a structured Microsoft Entra Conditional Access baseline derived from Microsoft Zero Trust and Conditional Access guidance. It includes 39 Conditional Access policies, 39 security groups, one named location, a migration table, and a PowerShell backup/restore utility.

---

| | |
|---|---|
| **Author** | Yoennis Olmo, Sr. Modern Work Consultant |
| **Microsoft Zero Trust Assessment Reference** | [Microsoft Zero Trust Assessment](https://learn.microsoft.com/en-us/security/zero-trust/assessment/overview) (updated April 2026) |
| **Last Updated** | June 2026 |

---

> **Important:** This is a reference baseline, not a universal production configuration. Review tenant licensing, authentication methods, device management, application dependencies, emergency-access accounts, exclusions, and user impact before enabling any policy.

## Zero Trust Approach

Microsoft describes Conditional Access as its Zero Trust policy engine. This baseline follows the principles of explicitly verifying access, using least privilege, assuming breach, protecting privileged roles, requiring strong authentication, validating device health, limiting unmanaged-device access, and responding to identity risk.

The baseline is organized into five active policy families:

| Code | Family | Scope |
|---|---|---|
| GLB | Global | Foundational controls for all users |
| ADM | Administrators | Privileged directory roles |
| USR | Users | Standard users and managed/unmanaged device scenarios |
| GST | Guests | Guest and external identities |
| IDP | Identity Protection | Risk-driven policies that require Entra ID P2 |

Policy numbers are allocated by scope and licensing:

| Range | Usage |
|---|---|
| CA000 | Shared global emergency-access exclusion group |
| CA001-CA099 | Global baseline policies |
| CA100-CA199 | Administrator policies |
| CA200-CA299 | Standard user policies |
| CA300-CA399 | Reserved for future advanced protection policies |
| CA400-CA499 | Guest and external identity policies |
| CA500-CA599 | Policies that require Microsoft Entra ID P2 |

## Naming Convention

~~~text
CA###-[Scope]-[Apps]-[Platform]-[Client]-[Location/Scenario]-[Control]
~~~

This is a semantic pattern rather than a strict segment count. `Scope` identifies the target user type. Control tokens use compact PascalCase to keep names readable and reduce unnecessary separators.

| Token | Meaning |
|---|---|
| AllApps, O365, M365, AdminCenters, EXO-SPO | Application scope |
| AnyOS, Win, macOS, iOS, Android, Linux | Platform scope |
| AnyCli, ModernCli, Legacy, Browser, Desktop, Mobile | Client scope |
| AnyLoc, UntrustLoc, BYOD | Location or access scenario |
| ReqMFA, ReqPhishMFA, ReqPwdlessMFA | Authentication controls |
| ReqCompliant, ReqCompliantOrHybrid | Device controls |
| Block, SignInFreq, PersistSession, ContAccEval | Block or session controls |
| ReqAppProtect, AppCtrl, AppRestrict, ReqTokenProtect | Application and token controls |
| EXCL | Exclusion security group |

The shared emergency-access group is:

~~~text
CA000-GLB-BGA-EmergencyAccess-EXCL
~~~

It is intentionally independent from any single policy and is referenced by multiple policies. CA215 uses this shared group and has no dedicated exclusion group.

## Policy Catalog

| ID | Family | Policy | Purpose / intention | Enforcement / action | Requirements | Dedicated exclusion group |
|---|---|---|---|---|---|---|
| CA001 | GLB | <code>CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block</code> | Prevent access from locations outside the approved location exclusions. | Blocks matching sign-ins from untrusted locations. | Entra ID P1; named locations | <code>CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL</code> |
| CA002 | GLB | <code>CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block</code> | Prevent access from device platforms that are not explicitly supported by the organization. | Blocks platforms other than Android, iOS, Windows, macOS, and Linux. | Entra ID P1 | <code>CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block-EXCL</code> |
| CA003 | GLB | <code>CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block</code> | Remove legacy authentication protocols that cannot satisfy modern access controls. | Blocks Exchange ActiveSync and other legacy client authentication. | Entra ID P1 | <code>CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block-EXCL</code> |
| CA004 | GLB | <code>CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block</code> | Reduce phishing and token-transfer risk from high-risk authentication flows. | Blocks device code flow and authentication transfer. | Entra ID P1; authentication-flow support | <code>CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block-EXCL</code> |
| CA005 | GLB | <code>CA005-GLB-DeviceReg-AnyOS-AnyCli-AnyLoc-ReqMFA</code> | Protect Microsoft Entra device registration and join operations at every location. | Requires MFA for the register or join devices user action. | Entra ID P1; MFA registration; tenant device setting coordination | <code>CA005-GLB-DeviceReg-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL</code> |
| CA006 | GLB | <code>CA006-GLB-RegSecInfo-AnyOS-AnyCli-UntrustLoc-ReqMFA</code> | Protect security-information registration from unauthorized changes outside approved locations. | Requires MFA when registering security information from untrusted locations. | Entra ID P1; combined registration; named locations | <code>CA006-GLB-RegSecInfo-AnyOS-AnyCli-UntrustLoc-ReqMFA-EXCL</code> |
| CA100 | ADM | <code>CA100-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA</code> | Apply baseline multifactor protection to privileged administrator roles. | Requires MFA for targeted administrator roles across all applications. | Entra ID P1; MFA methods | <code>CA100-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL</code> |
| CA101 | ADM | <code>CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA</code> | Require phishing-resistant authentication for administrators at every location. | Requires the phishing-resistant MFA authentication strength for all targeted resources. | Entra ID P1; phishing-resistant methods | <code>CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA-EXCL</code> |
| CA102 | ADM | <code>CA102-ADM-AllApps-AnyOS-AnyCli-UntrustLoc-ReqPwdlessMFA</code> | Strengthen administrator access to management portals outside approved locations. | Requires the Passwordless MFA authentication strength for admin portals and Azure management. | Entra ID P1; passwordless methods; named locations | <code>CA102-ADM-AllApps-AnyOS-AnyCli-UntrustLoc-ReqPwdlessMFA-EXCL</code> |
| CA103 | ADM | <code>CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq</code> | Limit the lifetime of privileged sign-in sessions. | Requires administrators to reauthenticate every 8 hours. | Entra ID P1 | <code>CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq-EXCL</code> |
| CA104 | ADM | <code>CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-PersistSession</code> | Prevent privileged browser sessions from persisting after the browser closes. | Sets persistent browser session mode to never persistent. | Entra ID P1 | <code>CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-PersistSession-EXCL</code> |
| CA105 | ADM | <code>CA105-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval</code> | Apply strict location enforcement to supported administrator sessions. | Strictly enforces location policies with Continuous Access Evaluation. | Entra ID P1; CAE-capable resources and clients | <code>CA105-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL</code> |
| CA106 | ADM | <code>CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid</code> | Restrict privileged access to organization-managed devices. | Requires a compliant device or a Microsoft Entra hybrid joined device. | Entra ID P1; Intune compliance or hybrid join | <code>CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid-EXCL</code> |
| CA200 | USR | <code>CA200-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA</code> | Provide baseline multifactor protection for workforce users. | Requires MFA for all targeted users and applications. | Entra ID P1; MFA methods | <code>CA200-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL</code> |
| CA201 | USR | <code>CA201-USR-AllApps-AnyOS-ModernCli-UntrustLoc-ReqPwdlessMFA</code> | Strengthen workforce authentication outside approved locations. | Requires Passwordless MFA for browser, mobile, and desktop clients from untrusted locations. | Entra ID P1; passwordless methods; named locations | <code>CA201-USR-AllApps-AnyOS-ModernCli-UntrustLoc-ReqPwdlessMFA-EXCL</code> |
| CA202 | USR | <code>CA202-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block</code> | Prevent standard users from accessing administrative management resources. | Blocks access to Microsoft admin portals and Azure management. | Entra ID P1 | <code>CA202-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL</code> |
| CA203 | USR | <code>CA203-USR-AllApps-Win-macOS-AnyLoc-Browser-SignInFreq</code> | Limit browser session lifetime on Windows and macOS. | Requires browser reauthentication every 12 hours. | Entra ID P1 | <code>CA203-USR-AllApps-Win-macOS-AnyLoc-Browser-SignInFreq-EXCL</code> |
| CA204 | USR | <code>CA204-USR-AllApps-Win-macOS-AnyLoc-Browser-PersistSession</code> | Prevent workforce browser sessions from persisting on Windows and macOS. | Sets persistent browser session mode to never persistent. | Entra ID P1 | <code>CA204-USR-AllApps-Win-macOS-AnyLoc-Browser-PersistSession-EXCL</code> |
| CA205 | USR | <code>CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval</code> | Apply strict location enforcement to supported workforce sessions. | Strictly enforces location policies with Continuous Access Evaluation. | Entra ID P1; CAE-capable resources and clients | <code>CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL</code> |
| CA206 | USR | <code>CA206-USR-O365-Win-Desktop-AnyLoc-ReqCompliant</code> | Protect Microsoft 365 desktop access from unmanaged Windows devices. | Requires a compliant or Microsoft Entra hybrid joined Windows device. | Entra ID P1; Intune compliance or hybrid join | <code>CA206-USR-O365-Win-Desktop-AnyLoc-ReqCompliant-EXCL</code> |
| CA207 | USR | <code>CA207-USR-O365-macOS-Desktop-AnyLoc-ReqCompliant</code> | Protect Microsoft 365 desktop access from unmanaged macOS devices. | Requires the macOS device to be marked compliant. | Entra ID P1; Intune compliance | <code>CA207-USR-O365-macOS-Desktop-AnyLoc-ReqCompliant-EXCL</code> |
| CA208 | USR | <code>CA208-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant</code> | Restrict iOS access to organization-compliant devices. | Requires the iOS device to be marked compliant. | Entra ID P1; Intune compliance | <code>CA208-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant-EXCL</code> |
| CA209 | USR | <code>CA209-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant</code> | Restrict Android access to organization-compliant devices. | Requires the Android device to be marked compliant. | Entra ID P1; Intune compliance | <code>CA209-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant-EXCL</code> |
| CA210 | USR | <code>CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant</code> | Restrict Linux access to organization-compliant devices. | Requires the Linux device to be marked compliant. | Entra ID P1; supported Intune Linux compliance | <code>CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant-EXCL</code> |
| CA211 | USR | <code>CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl</code> | Reduce data loss from unmanaged Windows browser sessions accessing Microsoft 365. | Requires an app protection policy and uses Defender for Cloud Apps to block downloads. | Entra ID P1; Intune App Protection Policy; Defender for Cloud Apps | <code>CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl-EXCL</code> |
| CA212 | USR | <code>CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect</code> | Restrict Microsoft 365 mobile access from unmanaged Android devices to protected applications. | Requires an Intune app protection policy. | Entra ID P1; Intune App Protection Policy | <code>CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect-EXCL</code> |
| CA213 | USR | <code>CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect</code> | Restrict Microsoft 365 mobile access from unmanaged iOS devices to protected applications. | Requires an Intune app protection policy. | Entra ID P1; Intune App Protection Policy | <code>CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect-EXCL</code> |
| CA214 | USR | <code>CA214-USR-EXO-SPO-Win-Browser-BYOD-AppRestrict</code> | Provide limited Exchange Online and SharePoint Online browser access from unmanaged Windows devices. | Uses application-enforced restrictions to limit the browser experience. | Entra ID P1; Exchange Online and SharePoint configuration | <code>CA214-USR-EXO-SPO-Win-Browser-BYOD-AppRestrict-EXCL</code> |
| CA215 | USR | <code>CA215-USR-O365-macOS-Browser-BYOD-AppRestrict</code> | Provide a restricted Microsoft 365 browser experience from unmanaged macOS devices. | Uses application-enforced restrictions; restore normalization targets supported Exchange Online and SharePoint resources. | Entra ID P1; Exchange Online and SharePoint configuration | <code>CA000-GLB-BGA-EmergencyAccess-EXCL (shared)</code> |
| CA216 | USR | <code>CA216-USR-M365-Win-macOS-Desktop-AnyLoc-ReqTokenProtect</code> | Reduce token replay for supported Microsoft 365 desktop sessions. | Requires device-bound sign-in session tokens for supported applications and platforms. | Feature-specific licensing; supported apps and devices | <code>CA216-USR-M365-Win-macOS-Desktop-AnyLoc-ReqTokenProtect-EXCL</code> |
| CA400 | GST | <code>CA400-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA</code> | Apply baseline multifactor protection to guest and external identities. | Requires MFA for targeted guest and external users. | Entra ID P1; external identity MFA configuration | <code>CA400-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL</code> |
| CA401 | GST | <code>CA401-GST-ExceptAllowed-AnyOS-ModernCli-AnyLoc-Block</code> | Limit guest access to the explicitly allowed application set. | Blocks browser, mobile, and desktop access to all applications except the exclusions. | Entra ID P1; maintained application exclusions | <code>CA401-GST-ExceptAllowed-AnyOS-ModernCli-AnyLoc-Block-EXCL</code> |
| CA402 | GST | <code>CA402-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block</code> | Prevent guests and external identities from reaching administrative resources. | Blocks access to Microsoft admin portals and Azure management. | Entra ID P1 | <code>CA402-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL</code> |
| CA403 | GST | <code>CA403-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq</code> | Limit the lifetime of guest and external-user sessions. | Requires guest users to reauthenticate every 4 hours. | Entra ID P1 | <code>CA403-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq-EXCL</code> |
| CA404 | GST | <code>CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-PersistSession</code> | Prevent guest browser sessions from persisting after the browser closes. | Sets persistent browser session mode to never persistent. | Entra ID P1 | <code>CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-PersistSession-EXCL</code> |
| CA405 | GST | <code>CA405-GST-AllApps-AnyOS-ModernCli-AnyLoc-ContAccEval</code> | Apply strict location enforcement to supported guest sessions. | Configures strict CAE location enforcement; note that CAE support for guests is limited. | Entra ID P1; CAE limitations for guests | <code>CA405-GST-AllApps-AnyOS-ModernCli-AnyLoc-ContAccEval-EXCL</code> |
| CA501 | IDP | <code>CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMedHigh-ReqPhishMFA</code> | Challenge medium- and high-risk sign-ins with strong phishing-resistant authentication. | Requires phishing-resistant MFA when sign-in risk is medium or high. | Entra ID P2; phishing-resistant methods | <code>CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMedHigh-ReqPhishMFA-EXCL</code> |
| CA502 | IDP | <code>CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMedHigh-ReqRemediate</code> | Allow compromised users to securely remediate elevated user risk. | Requires risk remediation with the configured Passwordless MFA authentication strength. | Entra ID P2; Identity Protection; remediation prerequisites | <code>CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMedHigh-ReqRemediate-EXCL</code> |
| CA503 | IDP | <code>CA503-IDP-O365-AnyOS-AnyCli-InsiderRiskElevated-Block</code> | Protect Microsoft 365 resources when insider-risk signals are elevated. | Blocks access when the insider-risk condition is elevated. | Entra ID P2; Microsoft Purview insider-risk integration | <code>CA503-IDP-O365-AnyOS-AnyCli-InsiderRiskElevated-Block-EXCL</code> |

## Important Design Notes

The [Zero Trust Conditional Access assessment](ZERO-TRUST-ASSESSMENT.md) records current coverage, identified gaps, design risks, and recommended implementation priorities. The assessment is dated because Microsoft capabilities and recommendations change over time.

### Emergency access

Maintain at least two cloud-only emergency-access accounts. Monitor their use and exclude them carefully from policies that could cause tenant-wide lockout. Exclusion-group membership must be tightly controlled and reviewed.

### Policy deployment

All source policy JSON files are stored in the **Off** state, and the restore script also forces policies to **Off** before creation. Review each policy with Conditional Access report-only mode where supported, sign-in logs, the What If tool, pilot groups, and documented rollback procedures before enabling it. Policies scoped to User Actions, including CA005, require controlled functional testing because report-only evaluation does not support that scope.

For CA005, set the tenant device setting **Require Multifactor Authentication to register or join devices with Microsoft Entra** to **No** so Conditional Access controls the MFA requirement.

### Workload identities

> **Not included in this baseline:** Conditional Access policies for workload identities are tenant-specific and are not included in the policy JSON files. A Conditional Access Administrator can configure them directly in each tenant based on the tenant's service principals, approved network locations, risk tolerance, licensing, and operational dependencies. See [Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity) and [What are workload identities?](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview).

Workload-identity policies protect service-principal token requests rather than interactive user sign-ins. Microsoft supports blocking selected service principals based on network location or service-principal risk.

To configure a location-based policy:

1. Sign in to the Microsoft Entra admin center as at least a **Conditional Access Administrator**.
2. Go to **Entra ID > Conditional Access > Policies > New policy**.
3. Under **Users or workload identities**, select **Workload identities**.
4. Under **Include**, select the required service principals directly.
5. Under **Target resources**, include **All resources**.
6. Under **Conditions > Locations**, include **Any location** and exclude only the named locations containing approved public IP ranges.
7. Under **Grant**, select **Block access**.
8. Start in **Report-only** mode, create the policy, and review service-principal sign-in logs before enforcement.

For a risk-based policy, use the same workload-identity and resource assignments, configure **Conditions > Service principal risk**, select the risk levels that should trigger the policy, and use **Block access**. Review results under **Entra ID > Monitoring & health > Sign-in logs > Service principal sign-ins**.

Important limitations:

- Microsoft Entra Workload ID Premium licenses are required to create or modify these policies.
- Policies apply to selected single-tenant service principals owned by the organization.
- Managed identities, Microsoft applications, third-party SaaS applications, and multitenant applications are not covered.
- Assign service principals directly to the policy. Assignment through a group containing service principals is not enforced.
- Use the service principal **Object ID** from **Enterprise applications**, not the application-registration object ID.
- **Block access** is the available grant control because workload identities cannot perform MFA.
- Prefer managed identities or workload identity federation where supported to reduce stored credentials.

### App protection policy

- CA211, CA212, and CA213 use the Graph `compliantApplication` grant control, which represents **Require app protection policy**. Do not configure the retired **Require approved client app** (`approvedApplication`) control. Deploy and validate supported Intune App Protection Policies and applications before enabling these policies.

- CA002 treats Android, iOS, Windows, macOS, and Linux as supported platforms.

### Licensing and dependencies

- Microsoft Entra ID P1 is the baseline requirement for Conditional Access.
- CA501-CA503 require Microsoft Entra ID P2 and Identity Protection capabilities.
- Device-compliance policies require Microsoft Intune compliance configuration.
- App-protection controls require supported applications and deployed Intune App Protection Policies.
- CA211 also requires Microsoft Defender for Cloud Apps session control integration.
- CA503 requires the appropriate Microsoft Purview insider-risk integration.
- Token protection and application-enforced restrictions support only specific platforms, clients, and resources.
- Tenant-specific Conditional Access policies for service principals require Microsoft Entra Workload ID Premium.

## Repository Layout

~~~text
Conditional-Access-Baseline/
|-- ConditionalAccess/     # Conditional Access policy JSON files
|-- Groups/                # Exclusion security-group JSON files
|-- NamedLocations/        # Named-location JSON files
|-- MigrationTable.json    # Group and service-principal dependency metadata
|-- ZERO-TRUST-ASSESSMENT.md # Coverage and gap assessment
|-- Test-Baseline.ps1      # Local and CI baseline validation
+-- README.md
~~~

## Restore Workflow

1. Open PowerShell 7.
2. Run `Invoke-ConditionalAccessBaseline.ps1`.
3. Connect to Microsoft Graph and consent to the requested delegated permissions.
4. Select **Restore Conditional Access Policies**.
5. Select the Conditional-Access-Baseline folder.
6. Run **Preview** first.
7. Review service-principal creation, groups, named locations, licensing warnings, and policy payloads.
8. Apply the restore.
9. Update the **Allowed Countries** named location for your organization's approved countries and regions.
10. Review every restored policy in the Microsoft Entra admin center before enabling it.

### Customize the Allowed Countries named location

The included `Allowed Countries.json` named location contains Belgium (`BE`) and the Netherlands (`NL`) as baseline examples. After importing the baseline, update this named location to match the countries and regions from which your organization permits access.

Location-dependent policies use this named location to distinguish trusted and untrusted sign-ins. Do not enable those policies until the country list has been reviewed and customized for the target tenant. Keep `includeUnknownCountriesAndRegions` disabled unless your organization has explicitly assessed and accepted the additional risk.

The script uses these delegated Microsoft Graph permissions:

- Policy.Read.All
- Policy.ReadWrite.ConditionalAccess
- Application.ReadWrite.All
- Group.ReadWrite.All
- Directory.Read.All

Troubleshooting is written to:

~~~text
C:\Windows\Temp\Invoke-ConditionalAccessBaseline.log
~~~

## Validation Checklist

- Run `./Test-Baseline.ps1` locally; GitHub Actions also runs it for pushes and pull requests.
- All JSON files parse successfully.
- Policy filenames match their internal displayName.
- Group filenames match their internal displayName.
- Every source policy is disabled.
- Every non-guest policy excludes the shared emergency-access group.
- Policy and group IDs remain unchanged.
- Every referenced group ID exists in the baseline.
- Migration-table group names match the group files.
- Service-principal dependencies are represented in MigrationTable.json.
- All policy request payloads pass local schema validation.
- P2 policies are reported as license-required when the tenant lacks Entra ID P2.
- CA005 and CA101 remain scoped to all locations.

## Microsoft Documentation

- [Microsoft Entra Conditional Access overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Conditional Access policy templates](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policy-common)
- [Zero Trust identity and device access policies](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-identity-device-access-policies-overview)
- [Build Conditional Access policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies)
- [Authentication strengths](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- [Require device compliance](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-compliance)
- [Require app protection policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-approved-app-or-app-protection)
- [Conditional Access session controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session)
- [Continuous Access Evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation)
- [Token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection)
- [Identity Protection risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Authentication flows](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-authentication-flows)
- [Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity)
- [Workload identities overview](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview)
- [Network conditions in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network)
- [Conditional Access report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)

## Disclaimer

Test this baseline in a non-production tenant first. Conditional Access block policies can cause tenant lockout or application outages when assignments, exclusions, licensing, authentication methods, or dependencies are incorrect. The repository owner is responsible for validating applicability and impact in each target tenant.
