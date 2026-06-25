# Microsoft Entra Conditional Access Baseline

A Zero Trust-aligned Microsoft Entra Conditional Access baseline built on Microsoft's own guidance, containing **54 policies**, **49 security groups**, **3 named locations**, **1 custom authentication strength**, a migration dependency table, and PowerShell backup/restore tooling.

The restore workflow creates policies disabled, and preview policies remain report-only until tenant prerequisites and impact evidence are approved.

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
- [Repository Structure](#repository-structure)
- [Naming](#naming)
- [Policy Catalog](#policy-catalog)
- [Design Notes](#design-notes)
- [Tenant Prerequisites](#tenant-prerequisites)
- [Deployment Order](#deployment-order)
- [Microsoft Guidance](#microsoft-guidance)

---

## Zero Trust Approach

Microsoft defines Conditional Access as its Zero Trust policy engine. This baseline aligns with Zero Trust principles: explicitly verify access, enforce least privilege, assume breach, protect privileged roles, require strong authentication, validate device health, limit unmanaged-device access, and respond to identity risk signals.

Policies are organized into nine audience families:

| Code | Family | Scope |
| :---: | :--- | :--- |
| GLB | Global | Foundational controls applied to all identities |
| ADM | Administrators | Privileged directory roles |
| USR | Users | Standard workforce — managed and unmanaged device scenarios |
| SVC | Service Accounts | Interactive service-account user objects |
| WLI | Workload Identities | Service principals and managed identities |
| GST | Guests | Guest and external identities |
| IDP | Identity Protection | Risk-driven policies requiring Microsoft Entra ID P2 |
| AGT | Agents | AI agent and autonomous workload identities |
| GSA | Global Secure Access | Entra Internet Access, Entra Private Access, and compliant-network controls |

Policy numbers are allocated by family:

| Range | Family |
| :--- | :--- |
| CA000 | Shared emergency-access exclusion group — referenced across all policies |
| CA001 – CA099 | GLB — Global baseline policies |
| CA100 – CA199 | ADM — Administrator policies |
| CA200 – CA299 | USR — Standard user policies |
| CA300 – CA399 | SVC — Interactive service-account policies |
| CA400 – CA499 | GST — Guest and external identity policies |
| CA500 – CA599 | IDP — Identity Protection policies (requires Entra ID P2) |
| CA600 – CA699 | AGT — Agent and autonomous workload policies |
| CA700 – CA799 | WLI — Workload identity policies (requires Workload ID Premium) |
| CA800 – CA899 | GSA — Global Secure Access policies |

---

## Repository Structure

```
Conditional-Access-Baseline/
├── README.md                                      ← This file
├── SETTINGSOUTPUT.md                              ← Complete policy settings reference
├── Security-Info-Registration-Readiness-Guide.md  ← Operational checklist for CA202/CA203 readiness
├── MigrationTable.json                            ← Dependency identity mapping
├── Invoke-ConditionalAccessBaseline.ps1           ← Backup and restore utility
│
├── ConditionalAccess/                             ← 54 policy JSON files
│   ├── CA001–CA007   GLB — Global baseline policies
│   ├── CA101–CA106   ADM — Administrator policies
│   ├── CA201–CA218   USR — Standard user policies
│   ├── CA301–CA303   SVC — Interactive service account policies
│   ├── CA401–CA406   GST — Guest and external identity policies
│   ├── CA501–CA505   IDP — Identity Protection policies (requires Entra ID P2)
│   ├── CA601–CA604   AGT — Agent and autonomous workload policies
│   ├── CA701–CA702   WLI — Workload identity policies (requires Workload ID Premium)
│   └── CA801–CA803   GSA — Global Secure Access policies
│
├── Groups/                                        ← 49 security group JSON files
│   ├── CA000-GLB-BGA-EmergencyAccess-EXCL.json   ← Shared emergency access exclusion
│   ├── CA-SVC-IntSvcAcc-ServiceAccounts.json      ← Shared SVC service accounts
│   └── CA001–CA803 EXCL groups                   ← 47 dedicated EXCL groups, one per policy
│
├── NamedLocations/                                ← 3 named location JSON files
│   ├── Allowed Countries.json
│   ├── Allowed Countries - Service Accounts.json
│   └── Compliant Network Locations.json
│
└── AuthenticationStrengths/                       ← 1 custom authentication strength
    └── Temp Access Pass - Strength.json
```

---

## Naming

`CA###-Audience-Resource-Platform-Client-Location-Control`

Audience families: `GLB`, `ADM`, `USR`, `SVC`, `WLI`, `GST`, `IDP`, `AGT`, and `GSA`. Workforce (`USR`) and guest (`GST`) policies are always separate. A dedicated exclusion group is named exactly `<policy-displayName>-EXCL`.

---

## Policy Catalog

| ID | Family | Policy | State | Effective control | Dedicated EXCL |
| :--- | :--- | :--- | :--- | :--- | :--- |
| CA001 | GLB | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block` | Disabled | block | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL` |
| CA002 | GLB | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block` | Disabled | block | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block-EXCL` |
| CA003 | GLB | `CA003-GLB-AllApps-AnyOS-LegacyCli-AnyLoc-Block` | Disabled | block | `CA003-GLB-AllApps-AnyOS-LegacyCli-AnyLoc-Block-EXCL` |
| CA004 | GLB | `CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block` | Disabled | block | `CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block-EXCL` |
| CA005 | GLB | `CA005-GLB-DeviceReg-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | mfa | `CA005-GLB-DeviceReg-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA006 | GLB | `CA006-GLB-SecInfoReg-AnyOS-AnyCli-AnyLoc-ReqTempAccPass` | Disabled | Authentication strength: Temp Access Pass - Strength | `CA006-GLB-SecInfoReg-AnyOS-AnyCli-AnyLoc-ReqTempAccPass-EXCL` |
| CA007 | GLB | `CA007-GLB-AllApps-AnyOS-AnyCli-AuthTransfer-Block` | Disabled | block | `CA007-GLB-AllApps-AnyOS-AnyCli-AuthTransfer-Block-EXCL` |
| CA101 | ADM | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | mfa | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA102 | ADM | `CA102-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPwdlessMFA` | Disabled | Authentication strength: Passwordless MFA | `CA102-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPwdlessMFA-EXCL` |
| CA103 | ADM | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA` | Disabled | Authentication strength: Phishing-resistant MFA | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA-EXCL` |
| CA104 | ADM | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrq-PrstSess` | Disabled | Sign-in frequency: 8 hours; Persistent browser: never | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrq-PrstSess-EXCL` |
| CA105 | ADM | `CA105-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval` | Disabled | CAE: strictLocation | `CA105-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL` |
| CA106 | ADM | `CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqComplOrHybrid` | Disabled | compliantDevice OR domainJoinedDevice | `CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqComplOrHybrid-EXCL` |
| CA201 | USR | `CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | mfa | `CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA202 | USR | `CA202-USR-AllApps-AnyOS-ModernCli-UntrustLoc-ReqPwdlessMFA` | Disabled | Authentication strength: Passwordless MFA | `CA202-USR-AllApps-AnyOS-ModernCli-UntrustLoc-ReqPwdlessMFA-EXCL` |
| CA203 | USR | `CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA` | Disabled | Authentication strength: Phishing-resistant MFA | `CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA-EXCL` |
| CA204 | USR | `CA204-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Disabled | block | `CA204-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL` |
| CA205 | USR | `CA205-USR-AllApps-AnyOS-Browser-AnyLoc-SignInFrq-PrstSess` | Disabled | Sign-in frequency: 12 hours; Persistent browser: never | `CA205-USR-AllApps-AnyOS-Browser-AnyLoc-SignInFrq-PrstSess-EXCL` |
| CA206 | USR | `CA206-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval` | Disabled | CAE: strictLocation | `CA206-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL` |
| CA207 | USR | `CA207-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant` | Disabled | compliantDevice OR domainJoinedDevice | `CA207-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant-EXCL` |
| CA208 | USR | `CA208-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant` | Disabled | compliantDevice | `CA208-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant-EXCL` |
| CA209 | USR | `CA209-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant` | Disabled | compliantDevice | `CA209-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA210 | USR | `CA210-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant` | Disabled | compliantDevice | `CA210-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA211 | USR | `CA211-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant` | Disabled | compliantDevice | `CA211-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA212 | USR | `CA212-USR-AllApps-Win-Browser-BYOD-ReqAppProtect-AppCtrl` | Disabled | compliantApplication; Defender for Cloud Apps: blockDownloads | `CA212-USR-AllApps-Win-Browser-BYOD-ReqAppProtect-AppCtrl-EXCL` |
| CA213 | USR | `CA213-USR-AllApps-Android-AnyCli-BYOD-ReqAppProtect-AppCtrl` | Disabled | compliantApplication; Defender for Cloud Apps: blockDownloads | `CA213-USR-AllApps-Android-AnyCli-BYOD-ReqAppProtect-AppCtrl-EXCL` |
| CA214 | USR | `CA214-USR-AllApps-iOS-AnyCli-BYOD-ReqAppProtect-AppCtrl` | Disabled | compliantApplication; Defender for Cloud Apps: blockDownloads | `CA214-USR-AllApps-iOS-AnyCli-BYOD-ReqAppProtect-AppCtrl-EXCL` |
| CA215 | USR | `CA215-USR-AllApps-macOS-Browser-BYOD-AppEnfRestr-AppCtrl` | Disabled | Application-enforced restrictions; Defender for Cloud Apps: blockDownloads | `CA215-USR-AllApps-macOS-Browser-BYOD-AppEnfRestr-AppCtrl-EXCL` |
| CA216 | USR | `CA216-USR-M365-Win-Desktop-AnyLoc-ReqTokenProt` | Disabled | Token protection | `CA216-USR-M365-Win-Desktop-AnyLoc-ReqTokenProt-EXCL` |
| CA217 | USR | `CA217-USR-IntuEnrollmt-AnyOS-AnyCli-AnyLoc-ReqMFA-ReqSignInAlwys` | Disabled | mfa; Sign-in frequency: every time | `CA217-USR-IntuEnrollmt-AnyOS-AnyCli-AnyLoc-ReqMFA-ReqSignInAlwys-EXCL` |
| CA218 | USR | `CA218-USR-M365-macOS-Desktop-AnyLoc-ReqTokenProt` | Disabled | Token protection | `CA218-USR-M365-macOS-Desktop-AnyLoc-ReqTokenProt-EXCL` |
| CA301 | SVC | `CA301-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | Authentication strength: Phishing-resistant MFA | `CA301-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA302 | SVC | `CA302-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-UntrustLoc-Block` | Disabled | block | `CA302-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL` |
| CA303 | SVC | `CA303-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval` | Disabled | CAE: strictLocation | `CA303-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL` |
| CA401 | GST | `CA401-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | mfa | `CA401-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA402 | GST | `CA402-GST-ExceptAllowed-AnyOS-ModernCli-AnyLoc-Block` | Disabled | block | `CA402-GST-ExceptAllowed-AnyOS-ModernCli-AnyLoc-Block-EXCL` |
| CA403 | GST | `CA403-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Disabled | block | `CA403-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL` |
| CA404 | GST | `CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrq-PrstSess` | Disabled | Sign-in frequency: 4 hours; Persistent browser: never | `CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrq-PrstSess-EXCL` |
| CA405 | GST | `CA405-GST-O365-AnyOS-Browser-AnyLoc-AppEnfRestr` | Disabled | Application-enforced restrictions | `CA405-GST-O365-AnyOS-Browser-AnyLoc-AppEnfRestr-EXCL` |
| CA406 | GST | `CA406-GST-AllApps-AnyOS-ModernCli-AnyLoc-ContAccEval` | Disabled | CAE: strictLocation | `CA406-GST-AllApps-AnyOS-ModernCli-AnyLoc-ContAccEval-EXCL` |
| CA501 | IDP | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMed-ReqPhishMFA` | Disabled | Authentication strength: Phishing-resistant MFA; Sign-in frequency: every time | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMed-ReqPhishMFA-EXCL` |
| CA502 | IDP | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMed-ReqRiskRemed` | Disabled | Authentication strength: Passwordless MFA; Sign-in frequency: every time | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMed-ReqRiskRemed-EXCL` |
| CA503 | IDP | `CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block` | Disabled | block | `CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block-EXCL` |
| CA504 | IDP | `CA504-IDP-AllApps-AnyOS-AnyCli-SignInRiskHigh-ReqPhishMFA` | Disabled | Authentication strength: Phishing-resistant MFA; Sign-in frequency: every time | `CA504-IDP-AllApps-AnyOS-AnyCli-SignInRiskHigh-ReqPhishMFA-EXCL` |
| CA505 | IDP | `CA505-IDP-AllApps-AnyOS-AnyCli-UserRiskHigh-ReqRiskRemed` | Disabled | riskRemediation AND Passwordless MFA; Sign-in frequency: every time | `CA505-IDP-AllApps-AnyOS-AnyCli-UserRiskHigh-ReqRiskRemed-EXCL` |
| CA601 | AGT | `CA601-AGT-AllAgtIdt-AllApps-AnyOS-AnyCli-Block` | Disabled | block | None |
| CA602 | AGT | `CA602-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-ReqCompliant` | Disabled | compliantDevice | None |
| CA603 | AGT | `CA603-AGT-AllAgtId-AllApps-AnyOS-AnyCli-RiskyAgt-Block` | Disabled | block | None |
| CA604 | AGT | `CA604-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-RiskyAgt-Block` | Disabled | block | None |
| CA701 | WLI | `CA701-WLI-AllApps-AnyLoc-WorkloadRiskHigh-Block` | Disabled | block | None |
| CA702 | WLI | `CA702-WLI-AllApps-AnyLoc-UntrustedNetwork-Block` | Disabled | block | None |
| CA801 | GSA | `CA801-GSA-AllAgtUsr-AllAgtRsrc-AnyOS-AnyCli-NonComplNet-Block` | Disabled | block | None |
| CA802 | GSA | `CA802-GSA-AllUsr-InternetAcc-AnyOS-AnyCli-ReqMFAOrCompliant` | Disabled | mfa OR compliantDevice OR domainJoinedDevice | `CA802-GSA-AllUsr-InternetAcc-AnyOS-AnyCli-ReqMFAOrCompliant-EXCL` |
| CA803 | GSA | `CA803-GSA-AllUsr-PrivateAcc-AnyOS-AnyCli-ReqMFAOrCompliant` | Disabled | mfa OR compliantDevice OR domainJoinedDevice | `CA803-GSA-AllUsr-PrivateAcc-AnyOS-AnyCli-ReqMFAOrCompliant-EXCL` |

---

## Design Notes

| Policy | Note |
| :--- | :--- |
| All | A block grant always wins. All grant and session controls must be satisfied — a weaker overlapping policy is not a fallback. |
| CA001 | Strict geography block. Compliant corporate devices do not bypass the disallowed-country boundary. |
| CA004 / CA007 | Device code flow and authentication transfer are blocked as separate policies so each can be piloted and excepted independently. |
| CA006 | Protects `Register security information` from any location using `Temp Access Pass - Strength`. TAP enables bootstrap for new users; existing strong methods let registered users manage security info without a new TAP. Keep TAP out of all-app sign-in strengths. See `Security-Info-Registration-Readiness-Guide.md` before enabling CA202 or CA203. |
| CA101–CA106 | Three-tier MFA stack (CA101 → CA102 → CA103) targets 35 built-in privileged roles and provides a graduated enforcement path for administrator authentication uplift. |
| CA203 | All workforce users must have FIDO2, Windows Hello for Business, or CBA registered before enabling. |
| CA212–CA214 | Scoped to **All cloud apps** (not Office 365) to cover Dynamics 365, Power BI, Power Apps, Planner, and other Microsoft services not reachable via MAM on BYOD. Review `excludeApplications` and add non-MAM-capable apps before enabling. CA215 remains scoped to Office 365 — Application Enforced Restrictions is a SharePoint/Exchange server-side feature only. |
| CA501 / CA504 | Medium and high sign-in risk: self-remediation with phishing-resistant MFA and every-time reauthentication. |
| CA505 | High user risk: risk remediation, Passwordless MFA strength, and reauthentication every time. |
| CA218 / CA601–CA604 / CA801–CA803 | Enable in report-only mode until preview, Global Secure Access, and licensing dependencies are validated in the tenant. |
| CA801 | Compliant-network block for agent resources using the GSA `All Compliant Network locations` named location. |
| CA802 | Targets All internet resources with Global Secure Access (`5dc48733-b5df-475c-a49b-fa307ef00853`). Requires MFA, compliant device, or hybrid-joined device. |
| CA803 | Private Access template. Replace `%GsaPrivateAccessAppId%` with the target enterprise application object ID, or duplicate per app/app group. |
| SVC policies | `CA-SVC-IntSvcAcc-ServiceAccounts` contains interactive service-account user objects. Workload identities are governed separately by WLI policies. |

---

## Tenant Prerequisites

**General**
- Maintain at least two cloud-only emergency-access accounts and test them every 90 days.
- Assign owners, approval, expiration, and access reviews to every EXCL group membership.
- Reconcile Security Defaults, legacy per-user MFA, cross-tenant trust, and Microsoft-managed CA policies before enforcement.
- Update `NamedLocations/Allowed Countries.json` and `Allowed Countries - Service Accounts.json` to match your permitted countries before restore. Pre-configured for **Belgium (BE)** and **The Netherlands (NL)**; referenced by CA001, CA202, CA302, and CA702.

**Authentication Methods**
- Enable FIDO2, Windows Hello for Business, and CBA in the Authentication Methods policy before piloting CA102, CA103, CA203, CA301, CA501, or CA502.
- Enable Temporary Access Pass before CA006. Prefer one-time, short-lived TAPs unless device setup requires multi-use.
- Create the `Temp Access Pass - Strength` authentication strength including `temporaryAccessPassOneTime`, `temporaryAccessPassMultiUse` (if allowed), `password,microsoftAuthenticatorPush`, `deviceBasedPush`, `fido2`, `windowsHelloForBusiness`, and `x509CertificateMultiFactor`.

**Device and App Management**
- Validate Intune compliance and App Protection policies before enabling device and MAM enforcement.
- Configure SharePoint/OneDrive limited access and Exchange application-enforced restrictions before CA215 or CA405.
- Validate Defender for Cloud Apps session controls before CA212.
- Validate CAE authentication IP and resource-seen IP before enabling strict location enforcement.

**Licensing**
- Entra ID P2 required for IDP policies (CA501–CA505) and AGT risk policies (CA603–CA604).
- Workload ID Premium required for CA701 and CA702.
- Microsoft Entra Suite (Internet Access + Private Access) required for CA801–CA803.

**Global Secure Access**
- Enable GSA Conditional Access signaling before CA801. Confirm the `All Compliant Network locations` named location exists.
- Enable and license Microsoft Entra Internet Access before CA802. Ensure compliance-remediation endpoints are reachable for noncompliant devices.
- Configure Quick Access or per-app Private Access enterprise applications before CA803. Replace `%GsaPrivateAccessAppId%` with the actual enterprise application object ID.

**Agent and Workload Identities**
- Create the `AgentIdentity` custom security attribute set and `AgentApprovalStatus` attribute before evaluating CA601.
- Populate `CA-SVC-IntSvcAcc-ServiceAccounts` only with user objects that can complete MFA. Prefer managed identities or workload identity federation for automation.

---

## Deployment Order

1. Audit Microsoft-managed Conditional Access policies in the tenant and decide whether to disable, retain, or supersede each one before restoring this baseline to avoid duplicate or conflicting controls.
2. Restore policies disabled and reconcile migration dependencies.
3. Pilot GLB and ADM controls, then broad workforce MFA.
4. Pilot device compliance, MAM, browser restrictions, and session controls by platform.
5. Enable guest controls only after cross-tenant MFA trust and external collaboration tests.
6. Pilot SVC and WLI policies after identity inventory approval.
7. Enable CA218, CA601–CA604, and CA801–CA803 in report-only mode until preview, Global Secure Access, and licensing dependencies are validated.
8. Review at least one normal business cycle of Conditional Access insights before enforcement.

---

## Microsoft Guidance

- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Require phishing-resistant MFA for administrators](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-admin-phish-resistant-mfa)
- [Require MFA for all users](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-mfa-strength)
- [Block authentication flows](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-authentication-flows)
- [Configure risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Use application-enforced restrictions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-app-enforced-restrictions)
- [Filter for devices](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-condition-filters-for-devices)
- [Token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection)
- [Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity)
- [Recommended policies for autonomous agents](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-autonomous-agents)
- [Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
