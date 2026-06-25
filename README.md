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

- ADM policies (CA101–CA106) target 35 built-in privileged roles directly via role targeting in Conditional Access. The three-tier MFA stack (CA101 plain MFA → CA102 passwordless MFA → CA103 phishing-resistant MFA) provides a graduated enforcement path for administrator authentication uplift.
- `CA-SVC-IntSvcAcc-ServiceAccounts` contains interactive service-account user objects targeted by SVC policies. Workload identities and service principals are governed separately by WLI policies.
- A block grant control always wins. Where multiple policies apply, all grant and session controls must be satisfied — a weaker overlapping policy is not a fallback.
- CA218, CA601–CA604, and CA801–CA803 should be enabled in report-only mode until preview, Global Secure Access, and licensing dependencies are validated in the tenant.
- CA203 enforces phishing-resistant MFA on all workforce users. Prerequisite: all users must have FIDO2, Windows Hello for Business, or certificate-based authentication registered before enabling this policy.
- CA004 blocks device code flow, while CA007 separately blocks authentication transfer so each flow can be piloted and excepted independently.
- CA006 protects the `Register security information` user action from any location with the custom authentication strength `Temp Access Pass - Strength`. This strength should include TAP for bootstrap plus approved existing strong methods for users who already have MFA. Keep TAP out of normal all-app sign-in strengths so TAP is only usable for bootstrap/recovery flows. See `Security-Info-Registration-Readiness-Guide.md` for the operational checklist to run before enabling CA202 or CA203 for a user.
- CA212, CA213, and CA214 target **All cloud apps** rather than Office 365. This follows Microsoft's own Zero Trust guidance: scope broadly and exclude what does not fit, rather than allowlisting specific services. Scoping to Office 365 only protects Exchange, SharePoint, and Teams — leaving apps such as Dynamics 365, Power BI, Power Apps, Power Automate, Planner, Loop, Viva Engage, Whiteboard, Microsoft Designer, Azure Information Protection, and Work Folders unprotected from browser-based access on BYOD devices, because users can reach those services without a MAM-compliant client. With All cloud apps scope, any access attempt on a BYOD device must come from a client app that satisfies the Intune App Protection Policy requirement. **Before enabling CA212, CA213, or CA214**, review `excludeApplications` in each policy and add any non-MAM-capable third-party cloud apps your organisation uses on BYOD devices — those apps cannot satisfy the grant and will be blocked without an exclusion. CA215 intentionally remains scoped to Office 365 because Application Enforced Restrictions is a SharePoint/Exchange server-side feature and only applies to those services. CA212 also requires Windows App Protection for Microsoft Edge and a tested Defender for Cloud Apps session policy.
- CA505 follows Microsoft's high-user-risk remediation model: risk remediation, Passwordless MFA authentication strength, and reauthentication every time.
- CA801 uses the Global Secure Access compliant-network named location to block agent-resource access when traffic is not coming from a compliant network.
- CA802 targets **All internet resources with Global Secure Access** (`5dc48733-b5df-475c-a49b-fa307ef00853`) and follows Microsoft's example control model: require one of MFA, compliant device, or Microsoft Entra hybrid joined device.
- CA803 is a Private Access template. Microsoft does not support a single Conditional Access target for the whole Private Access tunnel; each Quick Access or Private Access enterprise application must be targeted directly. Replace `%GsaPrivateAccessAppId%` with the target Private Access enterprise application object ID, or duplicate CA803 per private app/app group.
- CA501 and CA504 allow medium- and high-risk sign-ins to self-remediate with phishing-resistant MFA and every-time reauthentication.
- CA001 uses the strict geography profile. Compliant corporate devices do not bypass the disallowed-country block.

---

## Tenant Prerequisites

- Maintain at least two cloud-only emergency-access accounts and test them every 90 days.
- Assign owners, justification, approval, expiration, access review, and monitoring to every EXCL group membership.
- Create a custom authentication strength named `Temp Access Pass - Strength` before restoring/enabling CA006. Include `temporaryAccessPassOneTime`; include `temporaryAccessPassMultiUse` only if your Temporary Access Pass authentication methods policy allows multi-use TAPs. Also include approved existing methods such as `password,microsoftAuthenticatorPush`, `deviceBasedPush`, `fido2`, `windowsHelloForBusiness`, and `x509CertificateMultiFactor` so registered users can maintain security info without needing a fresh TAP.
- Enable Temporary Access Pass in the Authentication Methods policy for the users who need registration bootstrap. Prefer one-time, short-lived TAPs unless Windows/device setup requires multi-use TAPs.
- Configure and test phishing-resistant methods (FIDO2, Windows Hello for Business, certificate-based authentication) before piloting CA103, CA203, or CA301.
- Validate Intune compliance and App Protection policies before device and MAM enforcement.
- Configure SharePoint/OneDrive limited access and Exchange application-enforced restrictions before CA215 or CA405.
- Validate Defender for Cloud Apps session controls before CA212.
- Validate CAE authentication IP and resource-seen IP before strict location enforcement.
- Populate `CA-SVC-IntSvcAcc-ServiceAccounts` only with user objects that can complete MFA. Prefer managed identities or workload identity federation for automation.
- Microsoft Entra Workload ID Premium is required for CA701 and CA702.
- Create the `AgentIdentity` custom security attribute set and `AgentApprovalStatus` attribute before evaluating CA601.
- Enable Global Secure Access Conditional Access signaling before evaluating CA801. Confirm that the `All Compliant Network locations` named location exists.
- Enable and license Microsoft Entra Internet Access before evaluating CA802. Ensure Intune and compliance-remediation endpoints are bypassed where needed so a noncompliant device is not locked out of becoming compliant.
- Configure Quick Access or per-app Microsoft Entra Private Access enterprise applications before evaluating CA803. Replace `%GsaPrivateAccessAppId%` with the actual Private Access enterprise application object ID.
- Reconcile Security Defaults, legacy per-user MFA, cross-tenant trust, and Microsoft-managed Conditional Access policies before enforcement.
- Enable FIDO2, Windows Hello for Business, and certificate-based authentication in the tenant Authentication Methods Policy before piloting CA102, CA103, CA203, CA301, CA501, or CA502; those policies will fail at runtime if the required methods are not enabled.
- CA001 enforces the allowed-country boundary regardless of device ownership, Intune enrollment, or compliance state. Create a separately reviewed travel exception only when the accepted risk and compensating controls are documented.
- The **Allowed Countries** named locations in this baseline are pre-configured for **Belgium (BE) and The Netherlands (NL)**. Update `NamedLocations/Allowed Countries.json` and `NamedLocations/Allowed Countries - Service Accounts.json` to match your organization's permitted countries before running the restore. These locations are referenced by CA001, CA202 (all users) and CA302, CA702 (service accounts and workload identities).

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
