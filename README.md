# Microsoft Entra Conditional Access — Zero Trust Baseline

A structured Microsoft Entra Conditional Access Baseline derived from Microsoft Zero Trust and Conditional Access guidance. Includes **39 policies**, **39 exclusion security groups**, **Named Location**, a migration dependency table, and a PowerShell Backup &Restore utility.

---

| Field | Details |
| :--- | :--- |
| **Author** | Yoennis Olmo, Sr. Modern Work Consultant |
| **Reference** | [Microsoft Zero Trust Assessment](https://learn.microsoft.com/en-us/security/zero-trust/assessment/overview) (updated April 2026) |
| **Last Updated** | June 2026 |

---

> **Important:** This is a reference baseline, not a universal one-size-fits-all configuration. Review tenant licensing, authentication methods, device management, application dependencies, emergency-access accounts, exclusions, and user impact before enabling any policy. Assess each recommendation against your organization's operational requirements, risk tolerance, and deployment model. Always test with a pilot group before broad rollout.

---

## Table of Contents

- [Zero Trust Approach](#zero-trust-approach)
- [Naming Convention](#naming-convention)
- [Policy Catalog](#policy-catalog)
- [Important Design Notes](#important-design-notes)
- [Repository Layout](#repository-layout)
- [Restore Workflow](#restore-workflow)
- [Validation Checklist](#validation-checklist)
- [Microsoft Documentation](#microsoft-documentation)
- [Disclaimer](#disclaimer)

---

## Zero Trust Approach

Microsoft defines Conditional Access as its Zero Trust policy engine. This baseline aligns with the Zero Trust principles of explicitly verifying access, enforcing least privilege, assuming breach, protecting privileged roles, requiring strong authentication, validating device health, limiting unmanaged-device access, and responding to identity risk signals.

Policies are organized into five active families:

| Code | Family | Scope |
| :---: | :--- | :--- |
| GLB | Global | Foundational controls applied to all users |
| ADM | Administrators | Privileged directory roles |
| USR | Users | Standard users — managed and unmanaged device scenarios |
| GST | Guests | Guest and external identities |
| IDP | Identity Protection | Risk-driven policies requiring Entra ID P2 |

Policy numbers are allocated by scope and licensing tier:

| Range | Purpose |
| :--- | :--- |
| CA000 | Shared emergency-access exclusion group — referenced across multiple policies |
| CA001 – CA099 | Global baseline policies |
| CA100 – CA199 | Administrator policies |
| CA200 – CA299 | Standard user policies |
| CA300 – CA399 | Reserved for future advanced protection policies |
| CA400 – CA499 | Guest and external identity policies |
| CA500 – CA599 | Policies requiring Microsoft Entra ID P2 |

---

## Naming Convention

~~~text
CA###-[Scope]-[Apps]-[Platform]-[Client]-[Location/Scenario]-[Control]
~~~

This is a semantic pattern rather than a fixed segment count. `Scope` identifies the target user type. Control tokens use compact PascalCase to keep names concise and readable.

| Token | Meaning |
| :--- | :--- |
| `AllApps` `O365` `M365` `AdminCenters` `EXO-SPO` | Application scope |
| `AnyOS` `Win` `macOS` `iOS` `Android` `Linux` | Platform scope |
| `AnyCli` `ModernCli` `Legacy` `Browser` `Desktop` `Mobile` | Client scope |
| `AnyLoc` `UntrustLoc` `BYOD` | Location or access scenario |
| `ReqMFA` `ReqPhishMFA` `ReqPwdlessMFA` | Authentication strength controls |
| `ReqCompliant` `ReqCompliantOrHybrid` | Device compliance controls |
| `Block` `SignInFreq` `PersistSession` `ContAccEval` | Block and session controls |
| `ReqAppProtect` `AppCtrl` `AppRestrict` `ReqTokenProtect` | Application and token controls |
| `EXCL` | Exclusion security group |

The shared emergency-access exclusion group is:

~~~text
CA000-GLB-BGA-EmergencyAccess-EXCL
~~~

This group is intentionally shared across multiple policies rather than scoped to a single one. CA215 references this shared group and has no dedicated exclusion group.

---

## Policy Catalog

| ID | Family | Policy Name | Purpose | Enforcement | Requirements | Exclusion Group |
| :--- | :---: | :--- | :--- | :--- | :--- | :--- |
| CA001 | GLB | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block` | Prevent access from locations outside the approved named location. | Blocks matching sign-ins from untrusted locations. | Entra ID P1; named locations configured | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL` |
| CA002 | GLB | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block` | Block access from device platforms that are not explicitly supported. | Blocks all platforms except Android, iOS, Windows, macOS, and Linux. | Entra ID P1 | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block-EXCL` |
| CA003 | GLB | `CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block` | Remove legacy authentication protocols that cannot satisfy modern access controls. | Blocks Exchange ActiveSync and other legacy client authentication. | Entra ID P1 | `CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block-EXCL` |
| CA004 | GLB | `CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block` | Reduce phishing and token-transfer risk from high-risk authentication flows. | Blocks device code flow and authentication transfer. | Entra ID P1; authentication-flow support | `CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block-EXCL` |
| CA005 | GLB | `CA005-GLB-DeviceReg-AnyOS-AnyCli-AnyLoc-ReqMFA` | Protect Microsoft Entra device registration and join operations at every location. | Requires MFA for the register or join devices user action. | Entra ID P1; MFA registration; tenant device setting coordination | `CA005-GLB-DeviceReg-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA006 | GLB | `CA006-GLB-RegSecInfo-AnyOS-AnyCli-UntrustLoc-ReqMFA` | Protect security-information registration from unauthorized changes outside approved locations. | Requires MFA when registering security information from untrusted locations. | Entra ID P1; combined registration; named locations | `CA006-GLB-RegSecInfo-AnyOS-AnyCli-UntrustLoc-ReqMFA-EXCL` |
| CA100 | ADM | `CA100-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Apply baseline multifactor protection to privileged administrator roles. | Requires MFA for targeted administrator roles across all applications. | Entra ID P1; MFA methods registered | `CA100-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA101 | ADM | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA` | Require phishing-resistant authentication for administrators at every location. | Requires the phishing-resistant MFA authentication strength for all targeted resources. | Entra ID P1; phishing-resistant methods registered | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA-EXCL` |
| CA102 | ADM | `CA102-ADM-AllApps-AnyOS-AnyCli-UntrustLoc-ReqPwdlessMFA` | Strengthen administrator access to management portals outside approved locations. | Requires the Passwordless MFA authentication strength for admin portals and Azure management. | Entra ID P1; passwordless methods; named locations | `CA102-ADM-AllApps-AnyOS-AnyCli-UntrustLoc-ReqPwdlessMFA-EXCL` |
| CA103 | ADM | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq` | Limit the lifetime of privileged sign-in sessions. | Requires administrators to reauthenticate every 8 hours. | Entra ID P1 | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq-EXCL` |
| CA104 | ADM | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-PersistSession` | Prevent privileged browser sessions from persisting after the browser closes. | Sets persistent browser session mode to never persistent. | Entra ID P1 | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-PersistSession-EXCL` |
| CA105 | ADM | `CA105-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval` | Apply strict location enforcement to supported administrator sessions. | Strictly enforces location policies with Continuous Access Evaluation. | Entra ID P1; CAE-capable resources and clients | `CA105-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL` |
| CA106 | ADM | `CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid` | Restrict privileged access to organization-managed devices only. | Requires a compliant device or a Microsoft Entra hybrid joined device. | Entra ID P1; Intune compliance or hybrid join | `CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid-EXCL` |
| CA200 | USR | `CA200-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Provide baseline multifactor protection for all workforce users. | Requires MFA for all targeted users and applications. | Entra ID P1; MFA methods registered | `CA200-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA201 | USR | `CA201-USR-AllApps-AnyOS-ModernCli-UntrustLoc-ReqPwdlessMFA` | Strengthen workforce authentication outside approved locations. | Requires Passwordless MFA for browser, mobile, and desktop clients from untrusted locations. | Entra ID P1; passwordless methods; named locations | `CA201-USR-AllApps-AnyOS-ModernCli-UntrustLoc-ReqPwdlessMFA-EXCL` |
| CA202 | USR | `CA202-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Prevent standard users from accessing administrative management resources. | Blocks access to Microsoft admin portals and Azure management. | Entra ID P1 | `CA202-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL` |
| CA203 | USR | `CA203-USR-AllApps-Win-macOS-AnyLoc-Browser-SignInFreq` | Limit browser session lifetime on Windows and macOS. | Requires browser reauthentication every 12 hours. | Entra ID P1 | `CA203-USR-AllApps-Win-macOS-AnyLoc-Browser-SignInFreq-EXCL` |
| CA204 | USR | `CA204-USR-AllApps-Win-macOS-AnyLoc-Browser-PersistSession` | Prevent workforce browser sessions from persisting on Windows and macOS. | Sets persistent browser session mode to never persistent. | Entra ID P1 | `CA204-USR-AllApps-Win-macOS-AnyLoc-Browser-PersistSession-EXCL` |
| CA205 | USR | `CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval` | Apply strict location enforcement to supported workforce sessions. | Strictly enforces location policies with Continuous Access Evaluation. | Entra ID P1; CAE-capable resources and clients | `CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL` |
| CA206 | USR | `CA206-USR-O365-Win-Desktop-AnyLoc-ReqCompliant` | Protect Microsoft 365 desktop access from unmanaged Windows devices. | Requires a compliant or Microsoft Entra hybrid joined Windows device. | Entra ID P1; Intune compliance or hybrid join | `CA206-USR-O365-Win-Desktop-AnyLoc-ReqCompliant-EXCL` |
| CA207 | USR | `CA207-USR-O365-macOS-Desktop-AnyLoc-ReqCompliant` | Protect Microsoft 365 desktop access from unmanaged macOS devices. | Requires the macOS device to be marked compliant. | Entra ID P1; Intune compliance | `CA207-USR-O365-macOS-Desktop-AnyLoc-ReqCompliant-EXCL` |
| CA208 | USR | `CA208-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant` | Restrict iOS access to organization-compliant devices. | Requires the iOS device to be marked compliant. | Entra ID P1; Intune compliance | `CA208-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA209 | USR | `CA209-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant` | Restrict Android access to organization-compliant devices. | Requires the Android device to be marked compliant. | Entra ID P1; Intune compliance | `CA209-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA210 | USR | `CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant` | Restrict Linux access to organization-compliant devices. | Requires the Linux device to be marked compliant. | Entra ID P1; supported Intune Linux compliance | `CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA211 | USR | `CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl` | Reduce data-loss risk from unmanaged Windows browser sessions accessing Microsoft 365. | Requires an app protection policy and uses Defender for Cloud Apps to block downloads. | Entra ID P1; Intune App Protection Policy; Defender for Cloud Apps | `CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl-EXCL` |
| CA212 | USR | `CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect` | Restrict Microsoft 365 mobile access on unmanaged Android devices to protected applications. | Requires an Intune app protection policy. | Entra ID P1; Intune App Protection Policy | `CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect-EXCL` |
| CA213 | USR | `CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect` | Restrict Microsoft 365 mobile access on unmanaged iOS devices to protected applications. | Requires an Intune app protection policy. | Entra ID P1; Intune App Protection Policy | `CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect-EXCL` |
| CA214 | USR | `CA214-USR-EXO-SPO-Win-Browser-BYOD-AppRestrict` | Provide limited Exchange Online and SharePoint Online browser access from unmanaged Windows devices. | Uses application-enforced restrictions to limit the browser experience. | Entra ID P1; Exchange Online and SharePoint configuration | `CA214-USR-EXO-SPO-Win-Browser-BYOD-AppRestrict-EXCL` |
| CA215 | USR | `CA215-USR-O365-macOS-Browser-BYOD-AppRestrict` | Provide a restricted Microsoft 365 browser experience from unmanaged macOS devices. | Uses application-enforced restrictions; targets supported Exchange Online and SharePoint resources. | Entra ID P1; Exchange Online and SharePoint configuration | `CA000-GLB-BGA-EmergencyAccess-EXCL` *(shared)* |
| CA216 | USR | `CA216-USR-M365-Win-macOS-Desktop-AnyLoc-ReqTokenProtect` | Reduce token replay risk for supported Microsoft 365 desktop sessions. | Requires device-bound sign-in session tokens for supported applications and platforms. | Feature-specific licensing; supported apps and devices | `CA216-USR-M365-Win-macOS-Desktop-AnyLoc-ReqTokenProtect-EXCL` |
| CA400 | GST | `CA400-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Apply baseline multifactor protection to guest and external identities. | Requires MFA for all targeted guest and external users. | Entra ID P1; external identity MFA configuration | `CA400-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA401 | GST | `CA401-GST-ExceptAllowed-AnyOS-ModernCli-AnyLoc-Block` | Limit guest access to the explicitly permitted application set. | Blocks browser, mobile, and desktop access to all applications except listed exclusions. | Entra ID P1; maintained application exclusions | `CA401-GST-ExceptAllowed-AnyOS-ModernCli-AnyLoc-Block-EXCL` |
| CA402 | GST | `CA402-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Prevent guests and external identities from reaching administrative resources. | Blocks access to Microsoft admin portals and Azure management. | Entra ID P1 | `CA402-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL` |
| CA403 | GST | `CA403-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq` | Limit the lifetime of guest and external-user sessions. | Requires guest users to reauthenticate every 4 hours. | Entra ID P1 | `CA403-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq-EXCL` |
| CA404 | GST | `CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-PersistSession` | Prevent guest browser sessions from persisting after the browser closes. | Sets persistent browser session mode to never persistent. | Entra ID P1 | `CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-PersistSession-EXCL` |
| CA405 | GST | `CA405-GST-AllApps-AnyOS-ModernCli-AnyLoc-ContAccEval` | Apply strict location enforcement to supported guest sessions. | Configures strict CAE location enforcement; note that CAE support for guests is limited. | Entra ID P1; CAE limitations for guests | `CA405-GST-AllApps-AnyOS-ModernCli-AnyLoc-ContAccEval-EXCL` |
| CA501 | IDP | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMedHigh-ReqPhishMFA` | Challenge medium- and high-risk sign-ins with strong phishing-resistant authentication. | Requires phishing-resistant MFA when sign-in risk is medium or high. | Entra ID P2; phishing-resistant methods registered | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMedHigh-ReqPhishMFA-EXCL` |
| CA502 | IDP | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMedHigh-ReqRemediate` | Allow compromised users to securely remediate elevated user risk. | Requires risk remediation using the configured Passwordless MFA authentication strength. | Entra ID P2; Identity Protection; remediation prerequisites | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMedHigh-ReqRemediate-EXCL` |
| CA503 | IDP | `CA503-IDP-O365-AnyOS-AnyCli-InsiderRiskElevated-Block` | Protect Microsoft 365 resources when insider-risk signals are elevated. | Blocks access when the insider-risk condition is elevated. | Entra ID P2; Microsoft Purview insider-risk integration | `CA503-IDP-O365-AnyOS-AnyCli-InsiderRiskElevated-Block-EXCL` |

---

## Important Design Notes

The [Zero Trust Conditional Access Assessment](ZERO-TRUST-ASSESSMENT.md) records current coverage, identified gaps, design risks, and recommended implementation priorities. The assessment is dated because Microsoft capabilities and recommendations evolve over time.

### Emergency Access

Maintain at least two cloud-only emergency-access accounts. Monitor their use and exclude them carefully from policies that could cause tenant-wide lockout. Exclusion-group membership must be tightly controlled and reviewed on a recurring basis.

### Policy Deployment

All source policy JSON files are stored in the **Off** state, and the restore script forces policies to **Off** before creation. Before enabling any policy:

- Validate with Conditional Access **report-only mode** where supported.
- Review **sign-in logs** and use the **What If** tool.
- Test with a **pilot group** and document rollback procedures.

> Policies scoped to **User Actions** (including CA005) require controlled functional testing because report-only evaluation does not support that scope.

For CA005: set the tenant device setting **Require Multifactor Authentication to register or join devices with Microsoft Entra** to **No** so that Conditional Access fully controls the MFA requirement.

### Workload Identities

> **Not included in this baseline:** Conditional Access policies for workload identities are tenant-specific and are not included in the policy JSON files. A Conditional Access Administrator can configure them directly in each tenant based on the tenant's service principals, approved network locations, risk tolerance, licensing, and operational dependencies. See [Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity) and [What are workload identities?](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview).

Workload-identity policies protect service-principal token requests rather than interactive user sign-ins. Microsoft supports blocking selected service principals based on network location or service-principal risk.

**Key limitations:**

| Limitation | Detail |
| :--- | :--- |
| Licensing | Microsoft Entra Workload ID Premium required to create or modify these policies |
| Scope | Applies only to selected single-tenant service principals owned by the organization |
| Exclusions | Managed identities, Microsoft apps, third-party SaaS apps, and multitenant apps are not covered |
| Assignment | Service principals must be assigned directly — group-based assignment is not enforced |
| Object ID | Use the service principal **Object ID** from **Enterprise applications**, not the app-registration ID |
| Grant control | **Block access** is the only available grant control — workload identities cannot perform MFA |
| Best practice | Prefer managed identities or workload identity federation where supported to reduce stored credentials |

### App Protection Policy

CA211, CA212, and CA213 use the Graph `compliantApplication` grant control, which maps to **Require app protection policy**. Do not configure the retired **Require approved client app** (`approvedApplication`) control. Deploy and validate supported Intune App Protection Policies and applications before enabling these policies.

CA002 treats Android, iOS, Windows, macOS, and Linux as the organization's supported platforms.

### Licensing and Dependencies

| Dependency | Applies To |
| :--- | :--- |
| Microsoft Entra ID P1 | All policies — baseline requirement for Conditional Access |
| Microsoft Entra ID P2 + Identity Protection | CA501, CA502, CA503 |
| Microsoft Intune — device compliance | All device-compliance policies |
| Microsoft Intune — App Protection Policies | CA211, CA212, CA213 |
| Microsoft Defender for Cloud Apps — session control | CA211 |
| Microsoft Purview — insider-risk integration | CA503 |
| Token protection and app-enforced restrictions | Limited to specific platforms, clients, and resources |
| Microsoft Entra Workload ID Premium | Tenant-specific service-principal policies |

---

## Repository Layout

~~~text
Conditional-Access-Baseline/
├── ConditionalAccess/        # Conditional Access policy JSON files
├── Groups/                   # Exclusion security-group JSON files
├── NamedLocations/           # Named-location JSON files
├── MigrationTable.json       # Group and service-principal dependency metadata
├── ZERO-TRUST-ASSESSMENT.md  # Coverage and gap assessment
└── README.md
~~~

---

## Restore Workflow

1. Open **PowerShell 7**.
2. Run `Invoke-ConditionalAccessBaseline.ps1`.
3. Connect to Microsoft Graph and consent to the requested delegated permissions.
4. Select **Restore Conditional Access Policies**.
5. Select the `Conditional-Access-Baseline` folder.
6. Run **Preview** first and review all output carefully.
7. Verify service-principal creation, groups, named locations, licensing warnings, and policy payloads.
8. Apply the restore.
9. Update the **Allowed Countries** named location for your organization's approved countries and regions.
10. Review every restored policy in the Microsoft Entra admin center before enabling it.

### Customizing the Allowed Countries Named Location

The included `Allowed Countries.json` named location contains Belgium (`BE`) and the Netherlands (`NL`) as baseline examples. After importing the baseline, update this named location to match the countries and regions from which your organization permits access.

Location-dependent policies use this named location to distinguish trusted from untrusted sign-ins. Do not enable those policies until the country list has been reviewed and customized for the target tenant. Keep `includeUnknownCountriesAndRegions` disabled unless your organization has explicitly assessed and accepted the additional risk.

**Required Microsoft Graph delegated permissions:**

| Permission | Purpose |
| :--- | :--- |
| `Policy.Read.All` | Read existing policies |
| `Policy.ReadWrite.ConditionalAccess` | Create and update Conditional Access policies |
| `Application.ReadWrite.All` | Manage service principal dependencies |
| `Group.ReadWrite.All` | Create and update exclusion security groups |
| `Directory.Read.All` | Read directory objects |

**Troubleshooting log location:**

~~~text
C:\Windows\Temp\Invoke-ConditionalAccessBaseline.log
~~~

---

## Validation Checklist

- [ ] All JSON files parse successfully
- [ ] Policy filenames match their internal `displayName`
- [ ] Group filenames match their internal `displayName`
- [ ] Every source policy is in the **disabled** state
- [ ] Every non-guest policy excludes the shared emergency-access group
- [ ] Policy and group IDs remain unchanged
- [ ] Every referenced group ID exists in the baseline
- [ ] Migration-table group names match the group files
- [ ] Service-principal dependencies are represented in `MigrationTable.json`
- [ ] All policy request payloads pass local schema validation
- [ ] P2 policies are reported as license-required when the tenant lacks Entra ID P2
- [ ] CA005 and CA101 remain scoped to all locations

---

## Microsoft Documentation

| Topic | Link |
| :--- | :--- |
| Conditional Access overview | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) |
| Plan a Conditional Access deployment | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access) |
| Conditional Access policy templates | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policy-common) |
| Zero Trust identity and device access policies | [learn.microsoft.com](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-identity-device-access-policies-overview) |
| Build Conditional Access policies | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies) |
| Authentication strengths | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths) |
| Require device compliance | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-compliance) |
| Require app protection policy | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-approved-app-or-app-protection) |
| Conditional Access session controls | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session) |
| Continuous Access Evaluation | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation) |
| Token protection | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection) |
| Identity Protection risk policies | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies) |
| Authentication flows | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-authentication-flows) |
| Conditional Access for workload identities | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity) |
| Workload identities overview | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview) |
| Network conditions in Conditional Access | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network) |
| Conditional Access report-only mode | [learn.microsoft.com](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only) |

---

## Disclaimer

Test this baseline in a non-production tenant before deploying to any production environment. Conditional Access block policies can cause tenant lockout or application outages when assignments, exclusions, licensing, authentication methods, or dependencies are misconfigured. The repository owner is responsible for validating applicability and impact in each target tenant.
