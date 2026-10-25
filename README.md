# Microsoft Entra Conditional Access Baseline

A Zero Trust-aligned Microsoft Entra Conditional Access baseline built on Microsoft's own guidance, containing **43 policies** (Core pack **29**, Add-on pack **14**), **39 security groups**, **3 named locations**, **1 custom authentication strength**, a migration dependency table, and PowerShell backup/restore tooling.

The baseline went from 54 to 43 policies to make it easier to implement and manage. Every policy is deployed disabled; each one is switched to report-only or on only after tenant prerequisites and impact evidence are approved.

---

| Field | Details |
| :--- | :--- |
| **Author** | Yoennis Olmo, Sr. Modern Work Consultant |
| **Reference** | [Microsoft Zero Trust Assessment](https://learn.microsoft.com/en-us/security/zero-trust/assessment/overview) |
| **Version** | 1.5.0 |
| **Last Updated** | October 2026 |

---

> **Important:** This is a reference baseline, not a universal one-size-fits-all configuration. Review tenant licensing, authentication methods, device management, application dependencies, emergency-access accounts, exclusions, and user impact before enabling any policy. Assess each recommendation against your organization's operational requirements, risk tolerance, and deployment model. Always test with a pilot group before broad rollout.

---

## Table of Contents

- [Zero Trust Approach](#zero-trust-approach)
- [Packs](#packs)
- [Repository Structure](#repository-structure)
- [Naming](#naming)
- [Policy Catalog](#policy-catalog)
- [Design Notes](#design-notes)
- [Tenant Prerequisites](#tenant-prerequisites)
- [Deployment Order](#deployment-order)
- [Restore with the Script](#restore-with-the-script)
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
| GST | Guests | Guest and external identities |
| SVC | Service Accounts | Interactive service-account user objects |
| IDP | Identity Protection | Risk-driven policies requiring Microsoft Entra ID P2 |
| AGT | Agents | AI agent and autonomous workload identities |
| WLI | Workload Identities | Service principals and managed identities |
| GSA | Global Secure Access | Entra Internet Access, Entra Private Access, and compliant-network controls |

Policy numbers are allocated by family. Numbers are stable identifiers, so gaps are intentional:

| Range | Family |
| :--- | :--- |
| CA000 | Shared exclusion groups — emergency access and service provider administrators |
| CA001 – CA099 | GLB — Global baseline policies |
| CA100 – CA199 | ADM — Administrator policies |
| CA200 – CA299 | USR — Standard user policies |
| CA300 – CA399 | GST — Guest and external identity policies |
| CA400 – CA499 | SVC — Interactive service-account policies |
| CA500 – CA599 | IDP — Identity Protection policies (requires Entra ID P2) |
| CA600 – CA699 | AGT — Agent and autonomous workload policies |
| CA700 – CA799 | WLI — Workload identity policies (requires Workload ID Premium) |
| CA800 – CA899 | GSA — Global Secure Access policies |

---

## Packs

The policies are split into packs so the baseline stays easy to understand and manage:

| Pack | Policies | Licence | Rule |
| :--- | :---: | :--- | :--- |
| **Essential** | 10 | Entra ID P1 | Low user impact. Deploy first; start in report-only where the policy supports it. |
| **Hardening** | 19 | Entra ID P1 (+ Intune where noted) | Agree with the customer first: strong authentication methods, device compliance, app protection, token protection, session controls. Keep Off until agreed. |
| **Add-on** | 14 | Entra ID P2, Defender for Cloud Apps, Workload ID Premium, Entra Suite or Agent 365 | Deploy only when the tenant holds the licence. The exception is CA211 (Linux compliance), which needs no extra licence and is only for tenants that allow Linux devices. |

Essential and Hardening together are the **Core pack** (29 policies, Microsoft 365 Business Premium). The Add-on pack lives in its own folder, `ConditionalAccess/AddOn/`.

---

## Repository Structure

```
Conditional-Access-Baseline/
├── README.md                                      ← This file
├── SETTINGSOUTPUT.md                              ← Complete policy settings reference
├── CHANGELOG.md                                   ← What changed and why
├── MigrationTable.json                            ← Dependency identity mapping
├── Invoke-ConditionalAccessBaseline.ps1           ← Backup and restore utility
│
├── Docs/                                          ← readiness guide
    └── Security-Info-Registration-Readiness-Guide.md  ← Operational checklist for CA005/CA203 readiness
│
├── ConditionalAccess/
│   ├── Core/                                      ← 29 policy JSON files (Microsoft 365 Business Premium)
│   │   ├── CA001–CA009   GLB — Global baseline policies
│   │   ├── CA101–CA106   ADM — Administrator policies
│   │   ├── CA201–CA217   USR — Standard user policies
│   │   ├── CA301–CA304   GST — Guest and external identity policies
│   │   └── CA401         SVC — Interactive service account policy
│   └── AddOn/                                     ← 14 policy JSON files
│       ├── CA211, CA219  USR — Linux compliance (no extra licence), Defender for Cloud Apps download block
│       ├── CA501–CA503   IDP — Identity Protection policies (requires Entra ID P2)
│       ├── CA601–CA604   AGT — Agent and autonomous workload policies
│       ├── CA701–CA702   WLI — Workload identity policies (requires Workload ID Premium)
│       └── CA801–CA803   GSA — Global Secure Access policies
│
├── Groups/                                        ← 39 security group JSON files
│   ├── CA000-GLB-BGA-EmergencyAccess-Admins-EXCL.json          ← Shared emergency access exclusion
│   ├── CA000-GLB-ADM-ServiceProvider-Admins-EXCL.json          ← Shared service provider administrators exclusion
│   ├── CA401-SVC-IntSvcAcc-ServiceAccounts-INCL.json           ← Shared SVC service accounts
│   └── CA001–CA803 EXCL groups                                 ← 36 dedicated EXCL groups, one per policy
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

Audience families: `GLB`, `ADM`, `USR`, `GST`, `SVC`, `IDP`, `AGT`, `WLI`, and `GSA`. Workforce (`USR`) and guest (`GST`) policies are always separate. A dedicated exclusion group is named exactly `<policy-displayName>-EXCL`.

---

## Policy Catalog

Every policy is deployed **Off** (shown as Disabled). The *First step* column is guidance: **Report-only** evaluates and logs without enforcing and never prompts users (policies for user actions and continuous access evaluation cannot be report-only); **Off until agreed** means the policy needs a customer decision before it is switched on; for Add-on policies the column shows the licence you need first.

| ID | Pack | Policy | State | First step | Effective control | Dedicated EXCL |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CA001 | Essential | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block` | Disabled | Report-only | block | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL` |
| CA002 | Essential | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block` | Disabled | Report-only | block | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block-EXCL` |
| CA003 | Essential | `CA003-GLB-AllApps-AnyOS-LegacyAuth-AnyLoc-Block` | Disabled | Report-only | block | `CA003-GLB-AllApps-AnyOS-LegacyAuth-AnyLoc-Block-EXCL` |
| CA004 | Essential | `CA004-GLB-AllApps-AnyOS-AnyCli-DevCodeAuthTransf-Block` | Disabled | Report-only | block | `CA004-GLB-AllApps-AnyOS-AnyCli-DevCodeAuthTransf-Block-EXCL` |
| CA005 | Essential | `CA005-GLB-RegDevSecInfo-AnyOS-AnyCli-AnyLoc-ReqTAPorMFA` | Disabled | Off until agreed | Authentication strength: Temp Access Pass - Strength | `CA005-GLB-RegDevSecInfo-AnyOS-AnyCli-AnyLoc-ReqTAPorMFA-EXCL` |
| CA009 | Hardening | `CA009-GLB-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval` | Disabled | Off until agreed | CAE: strictLocation | `CA009-GLB-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL` |
| CA101 | Essential | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | Report-only | mfa | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA103 | Hardening | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResMFA` | Disabled | Off until agreed | Authentication strength: Phishing-resistant MFA | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResMFA-EXCL` |
| CA104 | Hardening | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess` | Disabled | Off until agreed | Sign-in frequency: 12 hours; Persistent browser: never | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess-EXCL` |
| CA106 | Hardening | `CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqComplOrHybrid` | Disabled | Off until agreed | compliantDevice OR domainJoinedDevice | `CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqComplOrHybrid-EXCL` |
| CA201 | Essential | `CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | Report-only | mfa | `CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA203 | Hardening | `CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPwdlessMFA` | Disabled | Off until agreed | Authentication strength: Passwordless MFA | `CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPwdlessMFA-EXCL` |
| CA204 | Essential | `CA204-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Disabled | Report-only | block | `CA204-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL` |
| CA205 | Hardening | `CA205-USR-AllApps-AnyOS-Browser-AnyLoc-SignInFrqPersistSess` | Disabled | Off until agreed | Sign-in frequency: 12 hours; Persistent browser: never | `CA205-USR-AllApps-AnyOS-Browser-AnyLoc-SignInFrqPersistSess-EXCL` |
| CA207 | Hardening | `CA207-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant` | Disabled | Off until agreed | compliantDevice OR domainJoinedDevice | `CA207-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant-EXCL` |
| CA208 | Hardening | `CA208-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant` | Disabled | Off until agreed | compliantDevice | `CA208-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant-EXCL` |
| CA209 | Hardening | `CA209-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant` | Disabled | Off until agreed | compliantDevice | `CA209-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA210 | Hardening | `CA210-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant` | Disabled | Off until agreed | compliantDevice | `CA210-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA211 | Add-on | `CA211-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant` | Disabled | Intune (no extra licence) | compliantDevice | `CA211-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant-EXCL` |
| CA212 | Hardening | `CA212-USR-AllApps-Win-Browser-BYOD-ReqAppProtect` | Disabled | Off until agreed | compliantApplication | `CA212-USR-AllApps-Win-Browser-BYOD-ReqAppProtect-EXCL` |
| CA213 | Hardening | `CA213-USR-AllApps-Android-AnyCli-BYOD-ReqAppProtect` | Disabled | Off until agreed | compliantApplication | `CA213-USR-AllApps-Android-AnyCli-BYOD-ReqAppProtect-EXCL` |
| CA214 | Hardening | `CA214-USR-AllApps-iOS-AnyCli-BYOD-ReqAppProtect` | Disabled | Off until agreed | compliantApplication | `CA214-USR-AllApps-iOS-AnyCli-BYOD-ReqAppProtect-EXCL` |
| CA215 | Hardening | `CA215-USR-AllApps-macOS-Browser-BYOD-AppEnfRestr` | Disabled | Off until agreed | Application-enforced restrictions | `CA215-USR-AllApps-macOS-Browser-BYOD-AppEnfRestr-EXCL` |
| CA216 | Hardening | `CA216-USR-M365-WinMac-Desktop-AnyLoc-ReqTokenProt` | Disabled | Off until agreed | Token protection | `CA216-USR-M365-WinMac-Desktop-AnyLoc-ReqTokenProt-EXCL` |
| CA217 | Hardening | `CA217-USR-IntuEnrl-AnyOS-AnyCli-AnyLoc-ReqMFA-Always` | Disabled | Off until agreed | mfa; Sign-in frequency: every time | `CA217-USR-IntuEnrl-AnyOS-AnyCli-AnyLoc-ReqMFA-Always-EXCL` |
| CA219 | Add-on | `CA219-USR-O365-AnyOS-Browser-BYOD-AppCtrl-BlockDownloads` | Disabled | Defender for Cloud Apps | Defender for Cloud Apps: blockDownloads | `CA219-USR-O365-AnyOS-Browser-BYOD-AppCtrl-BlockDownloads-EXCL` |
| CA301 | Essential | `CA301-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Disabled | Report-only | mfa | `CA301-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL` |
| CA302 | Hardening | `CA302-GST-AllowedApps-AnyOS-ModernCli-AnyLoc-Block` | Disabled | Report-only | block | `CA302-GST-AllowedApps-AnyOS-ModernCli-AnyLoc-Block-EXCL` |
| CA303 | Hardening | `CA303-GST-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess` | Disabled | Off until agreed | Sign-in frequency: 4 hours; Persistent browser: never | `CA303-GST-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess-EXCL` |
| CA304 | Hardening | `CA304-GST-O365-AnyOS-Browser-AnyLoc-AppEnfRestr` | Disabled | Off until agreed | Application-enforced restrictions | `CA304-GST-O365-AnyOS-Browser-AnyLoc-AppEnfRestr-EXCL` |
| CA401 | Essential | `CA401-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-UntrustLoc-Block` | Disabled | Off until agreed | block | `CA401-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL` |
| CA501 | Add-on | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRisk-ReqPhishResMFA` | Disabled | Entra ID P2 | Authentication strength: Phishing-resistant MFA; Sign-in frequency: every time | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRisk-ReqPhishResMFA-EXCL` |
| CA502 | Add-on | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRisk-ReqRiskRemed` | Disabled | Entra ID P2 | riskRemediation AND Passwordless MFA; Sign-in frequency: every time | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRisk-ReqRiskRemed-EXCL` |
| CA503 | Add-on | `CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block` | Disabled | Entra ID P2 + Purview Insider Risk | block | `CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block-EXCL` |
| CA601 | Add-on | `CA601-AGT-AllAgtId-AllApps-AnyOS-AnyCli-Block` | Disabled | Agent 365 / M365 E7 | block | None |
| CA602 | Add-on | `CA602-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-ReqCompliant` | Disabled | Agent 365 / M365 E7 | compliantDevice | None |
| CA603 | Add-on | `CA603-AGT-AllAgtId-AllApps-AnyOS-AnyCli-RiskyAgt-Block` | Disabled | Entra ID P2 | block | None |
| CA604 | Add-on | `CA604-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-RiskyAgt-Block` | Disabled | Entra ID P2 | block | None |
| CA701 | Add-on | `CA701-WLI-AllApps-AnyLoc-WorkloadRiskHigh-Block` | Disabled | Workload ID Premium | block | None |
| CA702 | Add-on | `CA702-WLI-AllApps-AnyLoc-UntrustedNetwork-Block` | Disabled | Workload ID Premium | block | None |
| CA801 | Add-on | `CA801-GSA-AllAgtUsr-AllAgtRsrc-AnyOS-AnyCli-NonComplNet-Block` | Disabled | Agent 365 / M365 E7 | block | None |
| CA802 | Add-on | `CA802-GSA-AllUsr-InternetAcc-AnyOS-AnyCli-ReqMFAOrCompliant` | Disabled | Entra Suite (Internet Access) | mfa OR compliantDevice OR domainJoinedDevice | `CA802-GSA-AllUsr-InternetAcc-AnyOS-AnyCli-ReqMFAOrCompliant-EXCL` |
| CA803 | Add-on | `CA803-GSA-AllUsr-PrivateAcc-AnyOS-AnyCli-ReqMFAOrCompliant` | Disabled | Entra Suite (Private Access) | mfa OR compliantDevice OR domainJoinedDevice | `CA803-GSA-AllUsr-PrivateAcc-AnyOS-AnyCli-ReqMFAOrCompliant-EXCL` |

---

## Design Notes

| Policy | Note |
| :--- | :--- |
| All | A block grant always wins. All grant and session controls must be satisfied — a weaker overlapping policy is not a fallback. |
| Administrator roles | One standard list of **40 roles**: the 35 built-in roles Microsoft marks as privileged, plus Exchange, SharePoint, Teams, Billing and Groups Administrator. The identical list is **included** in CA101–CA106 and **excluded** in the user policies CA201–CA215 (administrators are covered by the ADM policies). CA216, CA217, the GLB, guest and Add-on risk policies keep administrators in scope. |
| Directory synchronization | Only the role `Directory Synchronization Accounts` is excluded, and only where a user policy could stop Entra Connect (CA001, CA003, CA201, CA203, CA207–CA211 and the Add-on risk policies). Add `On Premises Directory Sync Account` manually when Entra Cloud Sync is used. |
| Service provider administrators | `CA000-GLB-ADM-ServiceProvider-Admins-EXCL` holds privileged service provider administrator accounts (for example two dedicated Global Administrators). It is excluded only from CA106 (managed device) and CA216 (token protection). Those accounts still need strong authentication (CA101/CA103). |
| CA002 | Blocks unsupported and unknown device platforms, Linux included: the baseline covers Windows, macOS, iOS and Android. Review the report-only sign-in results for 1–2 weeks (device platform Linux or Unknown) before enabling. |
| CA002 / CA211 | Users who need Linux go in `CA002-...-EXCL` and are covered by the Add-on policy CA211 (require compliant device). Without CA211 an exempted Linux user is protected by MFA only. Linux compliance works in Microsoft Edge only and needs an Intune Linux compliance policy (Ubuntu 24.04/26.04 LTS or RHEL 9/10). Administrators on Linux can only satisfy CA106 through compliance. |
| CA004 | One policy blocks both device code flow and authentication transfer. |
| CA005 | One user-action policy for registering or joining devices and registering security information, using `Temp Access Pass - Strength`. TAP enables bootstrap for new users; guests are excluded. It cannot run in report-only. See `Docs/Security-Info-Registration-Readiness-Guide.md` before enabling CA203. |
| CA101 / CA103 | CA101 is standard MFA for every administrator (the minimum). CA103 requires **Phishing-resistant MFA** and is enabled only after the customer agrees and the administrators hold FIDO2, Windows Hello for Business or certificate credentials. |
| CA203 | Users default to **Passwordless MFA**, which already accepts every phishing-resistant method plus Microsoft Authenticator phone sign-in. Change the authentication strength to Phishing-resistant MFA when users hold FIDO2, Windows Hello for Business or certificate credentials. |
| CA009 | One global policy for continuous access evaluation (strict location) for users and administrators; guests are excluded because CAE does not support them. Strict location needs **IP-based** named locations and cannot run in report-only. Validate the egress IPs (including IPv6) before enabling. |
| CA201 / CA301 / CA204 | CA201 requires MFA for members; guests and external users are covered by CA301, so each audience has its own exclusion group and rollout. CA204 blocks admin portals for non-administrator users and guests and excludes service provider users so partner access keeps working. |
| CA207–CA210 | Device compliance, one policy per platform (Windows, macOS, iOS, Android), so a customer that uses only some platforms can enable only those. |
| CA212–CA215 | BYOD app protection (Intune MAM) per platform and application-enforced restrictions for macOS browsers. The Defender for Cloud Apps download control is the Add-on policy CA219. |
| CA213–CA214 (passkey note) | **Baseline Note:** Microsoft documents a known limitation with Microsoft Authenticator passkey registration on iOS and Android: users can be blocked when a Conditional Access policy targets All resources and requires App protection policy. Current baseline keeps All resources with explicit exclusions for the required registration services. This provides broader BYOD protection, but it is an exception-based design that may need adjustment if Microsoft changes the registration flow. Review the exclusions before enabling. Reference: [Microsoft Authenticator passkey Conditional Access limitation](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-support-authenticator-passkey) |
| CA216 | Token protection for Windows and macOS desktop clients (Exchange, SharePoint, Teams). Browsers are not covered. |
| CA217 | MFA every time for Intune enrollment. Autopilot Device Preparation (v2) can stall under this policy because the automated flow cannot complete MFA; add the Autopilot users to `CA217-...-EXCL`. |
| CA302–CA304 | Guest app allow-list block, guest session limits, and application-enforced restrictions for guests in the browser. |
| CA401 | Interactive service accounts (user objects used by scripts) are restricted to allowed countries. Microsoft recommends managed identities or workload identities instead. Keep `CA401-SVC-IntSvcAcc-ServiceAccounts-INCL` empty unless an account is unavoidable, with an owner and a review date. Service accounts cannot complete MFA, so add them to the CA201 exclusion group. |
| CA501 / CA502 | Medium and high risk are handled in one policy each: sign-in risk with phishing-resistant MFA, user risk with risk remediation and Passwordless MFA, both with reauthentication every time. |
| CA601–CA604 / CA801–CA803 | Preview and licence-dependent policies: validate the Agent 365, Global Secure Access and licensing dependencies in the tenant before enabling. |
| CA701 / CA702 | Exclude your own management applications (for example deployment tools that use service principals) before enabling. |
| CA802 / CA803 | CA802 targets all internet resources with Global Secure Access. CA803 is the Private Access template: replace `%GsaPrivateAccessAppId%` with the target enterprise application object ID, or duplicate per app. |
| Report-only | Compliant-device policies in report-only can show a device-certificate prompt on macOS, iOS and Android. Exclude those platforms when testing in report-only, or keep the policy Off until agreed. |

---

## Tenant Prerequisites

**General**
- Maintain at least two cloud-only emergency-access accounts with neutral names (for example a planet or a constellation; avoid words like "breakglass", "emergency" or "admin"), protect them with a passkey (FIDO2 key), and test them every 30 days.
- Assign owners, approval, expiration, and access reviews to every EXCL group membership.
- Reconcile Security Defaults, per-user MFA, cross-tenant trust, and Microsoft-managed Conditional Access policies before enforcement.
- Update `NamedLocations/Allowed Countries.json` and `Allowed Countries - Service Accounts.json` to match your permitted countries before restore. Pre-configured for **Belgium (BE)** and **The Netherlands (NL)**; referenced by CA001 and CA401.
- Review the number of Global Administrators; Microsoft recommends fewer than five.

**Authentication Methods**
- Enable FIDO2, Windows Hello for Business, and certificate-based authentication before moving CA103 or CA203 to phishing-resistant MFA, and Microsoft Authenticator passwordless before CA203 starts at Passwordless MFA.
- Enable Temporary Access Pass before CA005. Prefer one-time, short-lived TAPs unless device setup requires multi-use.

**Device and App Management**
- Validate Intune compliance policies (including the antivirus product used: Defender or a third-party product reported through a compliance partner) before CA106 and CA207–CA210.
- For CA211, create an Intune Linux compliance policy and enrol the Linux devices with the Microsoft Intune app; access is limited to Microsoft Edge.
- Validate App Protection policies before CA212–CA214; configure SharePoint/OneDrive limited access and Exchange application-enforced restrictions before CA215 or CA304.
- Ensure the Intune and Intune Enrollment service principals exist (included with Intune).
- Validate CAE authentication IP and resource-seen IP before enabling CA009.

**Licensing**
- Core pack: Microsoft Entra ID P1 (included in Microsoft 365 Business Premium).
- Add-on pack: Entra ID P2 for CA501–CA503, CA603 and CA604; Defender for Cloud Apps for CA219; Workload ID Premium for CA701 and CA702; Agent 365 or Microsoft 365 E7 for CA601, CA602 and CA801; Microsoft Entra Suite (Internet Access + Private Access) for CA802 and CA803. CA211 needs no extra licence.

**Global Secure Access**
- Enable GSA Conditional Access signaling before CA801. Confirm the `All Compliant Network locations` named location exists.
- Enable and license Microsoft Entra Internet Access before CA802. Configure Private Access enterprise applications before CA803 and replace `%GsaPrivateAccessAppId%` with the actual enterprise application object ID.

**Agent and Workload Identities**
- Create the `AgentIdentity` custom security attribute set and `AgentApprovalStatus` attribute before evaluating CA601.
- Populate `CA401-SVC-IntSvcAcc-ServiceAccounts-INCL` only with user objects that cannot be replaced by managed identities or workload identity federation.

---

## Deployment Order

1. Audit Microsoft-managed Conditional Access policies and decide whether to disable, keep or supersede each one before restoring this baseline, to avoid duplicate or conflicting controls.
2. Create the emergency-access accounts and the service provider administrator group members; confirm both groups before any policy is switched on.
3. Deploy the **Essential** pack (all Off), then set the policies marked Report-only in the catalog to report-only and review sign-in logs for at least one business cycle.
4. Switch Essential policies from Report-only to On one by one, starting with CA101 and CA201 after MFA registration is confirmed.
5. Agree and enable the **Hardening** pack per policy with the customer: administrators first (CA103, CA106, CA104), then users and devices.
6. Enable guest controls only after cross-tenant MFA trust and external collaboration tests.
7. Deploy the **Add-on** pack only for licensed capabilities, and CA211 only when Linux devices are allowed.

---

## Restore with the Script

`Invoke-ConditionalAccessBaseline.ps1` backs up and restores the baseline interactively (Microsoft Graph PowerShell).

- Select the baseline folder in the restore option. The script asks which pack to restore: **Core**, **Add-on** or **Both** (selecting `ConditionalAccess\Core` or `ConditionalAccess\AddOn` directly restores that pack). Shared groups, named locations, the authentication strength and the migration table are taken from the baseline folder automatically.
- A backup made by the script itself (policies directly in `ConditionalAccess\`) restores exactly as before.
- The script creates the service principals, named locations, exclusion groups and authentication strength a policy needs, then the policies, remapping the identifiers.
- The script always creates policies **Off** for safety. Switch the policies marked Report-only in the catalog to report-only after you have reviewed them.
- Backups of any other tenant, or custom policy sets, restore exactly as before: objects are matched by exact display name, and a policy that already exists is skipped. The rename map for earlier baseline versions is used only for this baseline (detected through `BaselineId` in `MigrationTable.json`), so unrelated policies are never mixed up.
- Policies and groups that were renamed in an earlier version are renamed in place instead of being created twice. Policies that were retired are only reported, never created.
- Policies that need a licence the tenant does not hold (Entra ID P2, Workload ID Premium, Entra Suite, Agent 365) are skipped.

---

## Microsoft Guidance

- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Conditional Access conditions: device platforms](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions)
- [Require phishing-resistant MFA for administrators](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-admin-phish-resistant-mfa)
- [Require MFA for all users](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-mfa-strength)
- [Block authentication flows](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-authentication-flows)
- [Report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Configure risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Use application-enforced restrictions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-app-enforced-restrictions)
- [Filter for devices](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-condition-filters-for-devices)
- [Token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection)
- [Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity)
- [Recommended policies for autonomous agents](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-autonomous-agents)
- [Manage emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Linux device management with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/deployment-guide-platform-linux)
