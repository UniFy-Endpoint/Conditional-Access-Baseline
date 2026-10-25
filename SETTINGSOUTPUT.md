# Conditional Access Baseline - Policy Configuration Reference

Baseline **v1.5.0**. Generated from the repository JSON on **October 25, 2026**.

| Metric | Value |
| :--- | :--- |
| Core policies (Microsoft 365 Business Premium / Entra ID P1) | 29 |
| Add-on policies (13 extra licences + optional CA211 Linux) | 14 |
| Security groups | 39 |
| Administrator role standard | 40 roles (35 Microsoft privileged + Exchange, SharePoint, Teams, Billing, Groups Administrator) |

## Core pack: 29 policies (Microsoft 365 Business Premium)

### Essential (10): low user impact, deploy first

| ID | Policy | What it does | Recommended first step |
| :--- | :--- | :--- | :--- |
| CA001 | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block` | Block sign-ins from countries outside Allowed Countries | Report-only |
| CA002 | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block` | Block unsupported or unknown device platforms, Linux included | Report-only |
| CA003 | `CA003-GLB-AllApps-AnyOS-LegacyAuth-AnyLoc-Block` | Block legacy authentication protocols | Report-only |
| CA004 | `CA004-GLB-AllApps-AnyOS-AnyCli-DevCodeAuthTransf-Block` | Block device code flow and authentication transfer | Report-only |
| CA005 | `CA005-GLB-RegDevSecInfo-AnyOS-AnyCli-AnyLoc-ReqTAPorMFA` | Require strong authentication (Temporary Access Pass strength) to register or join devices and to register security information | Off until agreed |
| CA101 | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Require MFA for administrators | Report-only |
| CA201 | `CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Require MFA for all members (guests are covered by CA301) | Report-only |
| CA204 | `CA204-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Block admin portals for non-administrator users and guests (service provider users excluded) | Report-only |
| CA301 | `CA301-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Require MFA for guests and external users | Report-only |
| CA401 | `CA401-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-UntrustLoc-Block` | Restrict interactive service accounts to allowed countries | Off until agreed |

### Hardening (19): agree with the customer before enabling

| ID | Policy | What it does | Recommended first step |
| :--- | :--- | :--- | :--- |
| CA009 | `CA009-GLB-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval` | Continuous access evaluation (strict location) for users and administrators | Off until agreed |
| CA103 | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResMFA` | Require phishing-resistant MFA for administrators | Off until agreed |
| CA104 | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess` | Administrator sign-in frequency 12 hours, no persistent browser | Off until agreed |
| CA106 | `CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqComplOrHybrid` | Require compliant or hybrid-joined device for administrators | Off until agreed |
| CA203 | `CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPwdlessMFA` | Require passwordless MFA for users (raise to phishing-resistant when ready) | Off until agreed |
| CA205 | `CA205-USR-AllApps-AnyOS-Browser-AnyLoc-SignInFrqPersistSess` | Sign-in frequency 12 hours, no persistent browser on unmanaged browsers | Off until agreed |
| CA207 | `CA207-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant` | Require compliant or hybrid-joined Windows device | Off until agreed |
| CA208 | `CA208-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant` | Require compliant macOS device | Off until agreed |
| CA209 | `CA209-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant` | Require compliant iOS device | Off until agreed |
| CA210 | `CA210-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant` | Require compliant Android device | Off until agreed |
| CA212 | `CA212-USR-AllApps-Win-Browser-BYOD-ReqAppProtect` | Require app protection for browsers on unmanaged Windows devices | Off until agreed |
| CA213 | `CA213-USR-AllApps-Android-AnyCli-BYOD-ReqAppProtect` | Require app protection for Android on personal devices | Off until agreed |
| CA214 | `CA214-USR-AllApps-iOS-AnyCli-BYOD-ReqAppProtect` | Require app protection for iOS on personal devices | Off until agreed |
| CA215 | `CA215-USR-AllApps-macOS-Browser-BYOD-AppEnfRestr` | Application-enforced restrictions for browsers on unmanaged macOS | Off until agreed |
| CA216 | `CA216-USR-M365-WinMac-Desktop-AnyLoc-ReqTokenProt` | Token protection for Windows and macOS desktop apps | Off until agreed |
| CA217 | `CA217-USR-IntuEnrl-AnyOS-AnyCli-AnyLoc-ReqMFA-Always` | Require MFA every time for Intune enrollment | Off until agreed |
| CA302 | `CA302-GST-AllowedApps-AnyOS-ModernCli-AnyLoc-Block` | Block guests from all apps except the allowed list | Report-only |
| CA303 | `CA303-GST-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess` | Guest sign-in frequency 4 hours, no persistent browser | Off until agreed |
| CA304 | `CA304-GST-O365-AnyOS-Browser-AnyLoc-AppEnfRestr` | Application-enforced restrictions for guests in the browser | Off until agreed |

## Add-on pack: 14 policies (extra licence required, except CA211)

| ID | Policy | What it does | Licence |
| :--- | :--- | :--- | :--- |
| CA211 | `CA211-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant` | Require compliant Linux device (Microsoft Edge) for users exempted from CA002 | Intune (no extra licence) |
| CA219 | `CA219-USR-O365-AnyOS-Browser-BYOD-AppCtrl-BlockDownloads` | Block downloads on unmanaged browsers (Defender for Cloud Apps) | Defender for Cloud Apps |
| CA501 | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRisk-ReqPhishResMFA` | Phishing-resistant MFA on medium and high sign-in risk | Entra ID P2 |
| CA502 | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRisk-ReqRiskRemed` | Risk remediation and passwordless MFA on medium and high user risk | Entra ID P2 |
| CA503 | `CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block` | Block elevated insider risk | Entra ID P2 + Purview Insider Risk |
| CA601 | `CA601-AGT-AllAgtId-AllApps-AnyOS-AnyCli-Block` | Block agent identities that are not approved | Agent 365 / M365 E7 |
| CA602 | `CA602-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-ReqCompliant` | Require compliant device for agent users | Agent 365 / M365 E7 |
| CA603 | `CA603-AGT-AllAgtId-AllApps-AnyOS-AnyCli-RiskyAgt-Block` | Block risky agent identities | Entra ID P2 |
| CA604 | `CA604-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-RiskyAgt-Block` | Block risky agent users | Entra ID P2 |
| CA701 | `CA701-WLI-AllApps-AnyLoc-WorkloadRiskHigh-Block` | Block high-risk workload identities | Workload ID Premium |
| CA702 | `CA702-WLI-AllApps-AnyLoc-UntrustedNetwork-Block` | Block workload identities from untrusted networks | Workload ID Premium |
| CA801 | `CA801-GSA-AllAgtUsr-AllAgtRsrc-AnyOS-AnyCli-NonComplNet-Block` | Block agent users outside the compliant network | Agent 365 / M365 E7 |
| CA802 | `CA802-GSA-AllUsr-InternetAcc-AnyOS-AnyCli-ReqMFAOrCompliant` | Require MFA or managed device for internet access (Global Secure Access) | Entra Suite (Internet Access) |
| CA803 | `CA803-GSA-AllUsr-PrivateAcc-AnyOS-AnyCli-ReqMFAOrCompliant` | Require MFA or managed device for private access (Global Secure Access) | Entra Suite (Private Access) |

> **Deployment state:** every policy is deployed **Off**, by the PowerShell script and by other tooling alike. The *Recommended first step* column is guidance: after the customer conversation, set each policy to Report-only, On or keep it Off. Add-on policies need the listed licence first.

## Policy details

### CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA001-GLB-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Locations | incl: Any location; excl: Allowed Countries |
| Grant | block |
| Session | None |

### CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block-EXCL, CA000-GLB-BGA-EmergencyAccess-Admins-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms | all (excl: android,iOS,windows,macOS) |
| Client apps | all |
| Grant | block |
| Session | None |

### CA003-GLB-AllApps-AnyOS-LegacyAuth-AnyLoc-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA003-GLB-AllApps-AnyOS-LegacyAuth-AnyLoc-Block-EXCL |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms |  |
| Client apps | exchangeActiveSync,other |
| Grant | block |
| Session | None |

### CA004-GLB-AllApps-AnyOS-AnyCli-DevCodeAuthTransf-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA004-GLB-AllApps-AnyOS-AnyCli-DevCodeAuthTransf-Block-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | block |
| Session | None |

### CA005-GLB-RegDevSecInfo-AnyOS-AnyCli-AnyLoc-ReqTAPorMFA

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA005-GLB-RegDevSecInfo-AnyOS-AnyCli-AnyLoc-ReqTAPorMFA-EXCL |
| Excluded directory roles | None |
| Resources | User action: urn:user:registerdevice, User action: urn:user:registersecurityinfo |
| Platforms |  |
| Client apps | all |
| Grant | Auth strength: Temp Access Pass - Strength |
| Session | None |

### CA009-GLB-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA009-GLB-AllApps-AnyOS-AnyCli-AnyLoc-ContAccEval-EXCL |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | None |
| Session | CAE: strictLocation |

### CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | 40 admin roles |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | mfa |
| Session | None |

### CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResMFA

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | 40 admin roles |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResMFA-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | Auth strength: Phishing-resistant MFA |
| Session | None |

### CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | 40 admin roles |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | None |
| Session | Sign-in frequency: 12 hours; Persistent browser: never |

### CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqComplOrHybrid

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | 40 admin roles |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA106-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqComplOrHybrid-EXCL, CA000-GLB-ADM-ServiceProvider-Admins-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | compliantDevice OR domainJoinedDevice |
| Session | None |

### CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL |
| Excluded directory roles | 40 admin roles (standard list) + Directory Synchronization Accounts |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | mfa |
| Session | None |

### CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPwdlessMFA

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPwdlessMFA-EXCL |
| Excluded directory roles | 40 admin roles (standard list) + Directory Synchronization Accounts |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | Auth strength: Passwordless MFA |
| Session | None |

### CA204-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA204-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL |
| Excluded directory roles | 40 admin roles (standard list) |
| Resources | Microsoft Admin Portals, Azure Resource Manager |
| Platforms | all |
| Client apps | all |
| Grant | block |
| Session | None |

### CA205-USR-AllApps-AnyOS-Browser-AnyLoc-SignInFrqPersistSess

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA205-USR-AllApps-AnyOS-Browser-AnyLoc-SignInFrqPersistSess-EXCL |
| Excluded directory roles | 40 admin roles (standard list) |
| Resources | All resources |
| Platforms | windows,macOS,iOS,android,linux |
| Client apps | browser |
| Device filter | exclude: device.deviceOwnership -eq "Company" -or device.isCompliant -eq True |
| Grant | None |
| Session | Sign-in frequency: 12 hours; Persistent browser: never |

### CA207-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA207-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant-EXCL |
| Excluded directory roles | 40 admin roles (standard list) + Directory Synchronization Accounts |
| Resources | All resources |
| Excluded resources | Microsoft Intune Enrollment, Microsoft Intune, Microsoft App Access Panel, Windows Store for Business, Windows Cloud Login, Microsoft Activity Feed Service, Microsoft Rights Management Services |
| Platforms | windows |
| Client apps | mobileAppsAndDesktopClients |
| Grant | compliantDevice OR domainJoinedDevice |
| Session | None |

### CA208-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA208-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant-EXCL |
| Excluded directory roles | 40 admin roles (standard list) + Directory Synchronization Accounts |
| Resources | All resources |
| Excluded resources | Microsoft Intune Enrollment, Microsoft Intune, Windows Cloud Login, Microsoft Activity Feed Service, Microsoft Rights Management Services |
| Platforms | macOS |
| Client apps | mobileAppsAndDesktopClients |
| Grant | compliantDevice |
| Session | None |

### CA209-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA209-USR-AllApps-iOS-AnyCli-AnyLoc-ReqCompliant-EXCL |
| Excluded directory roles | 40 admin roles (standard list) + Directory Synchronization Accounts |
| Resources | All resources |
| Excluded resources | Microsoft Intune, Microsoft Intune Enrollment |
| Platforms | iOS |
| Client apps | all |
| Device filter | include: device.mdmAppId -eq "0000000a-0000-0000-c000-000000000000" |
| Grant | compliantDevice |
| Session | None |

### CA210-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA210-USR-AllApps-Android-AnyCli-AnyLoc-ReqCompliant-EXCL |
| Excluded directory roles | 40 admin roles (standard list) + Directory Synchronization Accounts |
| Resources | All resources |
| Excluded resources | Microsoft Intune, Microsoft Intune Enrollment |
| Platforms | android |
| Client apps | all |
| Device filter | include: device.mdmAppId -eq "0000000a-0000-0000-c000-000000000000" |
| Grant | compliantDevice |
| Session | None |

### CA212-USR-AllApps-Win-Browser-BYOD-ReqAppProtect

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA212-USR-AllApps-Win-Browser-BYOD-ReqAppProtect-EXCL |
| Excluded directory roles | 40 admin roles (standard list) |
| Resources | Office 365 (app group) |
| Platforms | windows |
| Client apps | browser |
| Device filter | include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -and device.isCompliant -ne True |
| Grant | compliantApplication |
| Session | None |

### CA213-USR-AllApps-Android-AnyCli-BYOD-ReqAppProtect

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA213-USR-AllApps-Android-AnyCli-BYOD-ReqAppProtect-EXCL |
| Excluded directory roles | 40 admin roles (standard list) |
| Resources | All resources |
| Excluded resources | Azure Credential Configuration Endpoint Service, Microsoft App Access Panel, Microsoft Intune, Windows Azure Active Directory, Microsoft Intune Enrollment, Microsoft Authenticator Credential Registration |
| Platforms | android |
| Client apps | browser,mobileAppsAndDesktopClients |
| Device filter | include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -or device.deviceOwnership -eq "Personal" |
| Grant | compliantApplication |
| Session | None |

### CA214-USR-AllApps-iOS-AnyCli-BYOD-ReqAppProtect

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA214-USR-AllApps-iOS-AnyCli-BYOD-ReqAppProtect-EXCL |
| Excluded directory roles | 40 admin roles (standard list) |
| Resources | All resources |
| Excluded resources | Azure Credential Configuration Endpoint Service, Microsoft App Access Panel, Microsoft Intune, Windows Azure Active Directory, Microsoft Intune Enrollment, Microsoft Authenticator Credential Registration |
| Platforms | iOS |
| Client apps | browser,mobileAppsAndDesktopClients |
| Device filter | include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -or device.deviceOwnership -eq "Personal" |
| Grant | compliantApplication |
| Session | None |

### CA215-USR-AllApps-macOS-Browser-BYOD-AppEnfRestr

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA215-USR-AllApps-macOS-Browser-BYOD-AppEnfRestr-EXCL |
| Excluded directory roles | 40 admin roles (standard list) |
| Resources | All resources |
| Platforms | macOS |
| Client apps | browser |
| Device filter | include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -and device.isCompliant -ne True |
| Grant | None |
| Session | App-enforced restrictions |

### CA216-USR-M365-WinMac-Desktop-AnyLoc-ReqTokenProt

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA216-USR-M365-WinMac-Desktop-AnyLoc-ReqTokenProt-EXCL, CA000-GLB-ADM-ServiceProvider-Admins-EXCL |
| Excluded directory roles | None |
| Resources | Office 365 Exchange Online, Office 365 SharePoint Online, Microsoft Teams Services |
| Platforms | windows,macOS |
| Client apps | mobileAppsAndDesktopClients |
| Grant | None |
| Session | Token protection |

### CA217-USR-IntuEnrl-AnyOS-AnyCli-AnyLoc-ReqMFA-Always

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA217-USR-IntuEnrl-AnyOS-AnyCli-AnyLoc-ReqMFA-Always-EXCL |
| Excluded directory roles | None |
| Resources | Microsoft Intune Enrollment |
| Platforms |  |
| Client apps | all |
| Grant | mfa |
| Session | Sign-in frequency: every time |

### CA211-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on (optional) |
| Deployed state | Off |
| Licence | Intune (no extra licence) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA211-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant-EXCL |
| Excluded directory roles | 40 admin roles (standard list) + Directory Synchronization Accounts |
| Resources | All resources |
| Excluded resources | Microsoft Intune, Microsoft Intune Enrollment |
| Platforms | linux |
| Client apps | all |
| Device filter | None |
| Grant | compliantDevice |
| Session | None |

### CA219-USR-O365-AnyOS-Browser-BYOD-AppCtrl-BlockDownloads

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Defender for Cloud Apps |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA219-USR-O365-AnyOS-Browser-BYOD-AppCtrl-BlockDownloads-EXCL |
| Excluded directory roles | 40 admin roles (standard list) |
| Resources | Office 365 (app group) |
| Platforms | all |
| Client apps | browser |
| Device filter | include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -and device.isCompliant -ne True |
| Grant | None |
| Session | Defender for Cloud Apps: blockDownloads |

### CA301-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | Guests/external |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA301-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | mfa |
| Session | None |

### CA302-GST-AllowedApps-AnyOS-ModernCli-AnyLoc-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | Guests/external |
| Exclude groups | CA302-GST-AllowedApps-AnyOS-ModernCli-AnyLoc-Block-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Excluded resources | My Apps, Windows Azure Active Directory, My Signins, Microsoft Approval Management, Microsoft Invitation Acceptance Portal, Windows Cloud Login, Microsoft Teams Services, My Profile, Microsoft App Access Panel, Azure Credential Configuration Endpoint Service, Microsoft Activity Feed Service, Microsoft Rights Management Services, Office 365 (app group) |
| Platforms | all |
| Client apps | browser,mobileAppsAndDesktopClients |
| Grant | block |
| Session | None |

### CA303-GST-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | Guests/external |
| Exclude groups | CA303-GST-AllApps-AnyOS-AnyCli-AnyLoc-SignInFrqPersistSess-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms | all |
| Client apps | all |
| Grant | None |
| Session | Sign-in frequency: 4 hours; Persistent browser: never |

### CA304-GST-O365-AnyOS-Browser-AnyLoc-AppEnfRestr

| Property | Configuration |
| :--- | :--- |
| Pack | Hardening |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | Guests/external |
| Exclude groups | CA304-GST-O365-AnyOS-Browser-AnyLoc-AppEnfRestr-EXCL |
| Excluded directory roles | None |
| Resources | Office 365 (app group) |
| Platforms | all |
| Client apps | browser |
| Grant | None |
| Session | App-enforced restrictions |

### CA401-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-UntrustLoc-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Essential |
| Deployed state | Off |
| Licence | Entra ID P1 (Business Premium) |
| Include | CA401-SVC-IntSvcAcc-ServiceAccounts-INCL |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA401-SVC-IntSvcAcc-AllApps-AnyOS-AnyCli-UntrustLoc-Block-EXCL |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Locations | incl: Any location; excl: Allowed Countries - Service Accounts |
| Grant | block |
| Session | None |

### CA501-IDP-AllApps-AnyOS-AnyCli-SignInRisk-ReqPhishResMFA

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Entra ID P2 |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA501-IDP-AllApps-AnyOS-AnyCli-SignInRisk-ReqPhishResMFA-EXCL |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Risk | signin:medium,high |
| Grant | Auth strength: Phishing-resistant MFA |
| Session | Sign-in frequency: every time |

### CA502-IDP-AllApps-AnyOS-AnyCli-UserRisk-ReqRiskRemed

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Entra ID P2 |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA502-IDP-AllApps-AnyOS-AnyCli-UserRisk-ReqRiskRemed-EXCL |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Risk | user:medium,high |
| Grant | Auth strength: Passwordless MFA AND riskRemediation |
| Session | Sign-in frequency: every time |

### CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Entra ID P2 + Purview Insider Risk |
| Include | All |
| Exclude groups | CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block-EXCL, CA000-GLB-BGA-EmergencyAccess-Admins-EXCL |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | block |
| Session | None |

### CA601-AGT-AllAgtId-AllApps-AnyOS-AnyCli-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Agent 365 / M365 E7 |
| Include | None; Workload/agent identities |
| Exclude groups |  |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | block |
| Session | None |

### CA602-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Agent 365 / M365 E7 |
| Include | None; Workload/agent identities |
| Exclude groups |  |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | compliantDevice |
| Session | None |

### CA603-AGT-AllAgtId-AllApps-AnyOS-AnyCli-RiskyAgt-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Entra ID P2 |
| Include | None; Workload/agent identities |
| Exclude groups |  |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | block |
| Session | None |

### CA604-AGT-AllAgtUsr-AllApps-AnyOS-AnyCli-RiskyAgt-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Entra ID P2 |
| Include | None; Workload/agent identities |
| Exclude groups |  |
| Excluded directory roles | None |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | block |
| Session | None |

### CA701-WLI-AllApps-AnyLoc-WorkloadRiskHigh-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Workload ID Premium |
| Include | 1 admin roles; Workload/agent identities |
| Exclude groups |  |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Grant | block |
| Session | None |

### CA702-WLI-AllApps-AnyLoc-UntrustedNetwork-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Workload ID Premium |
| Include | 1 admin roles; Workload/agent identities |
| Exclude groups |  |
| Excluded directory roles | Directory Synchronization Accounts |
| Resources | All resources |
| Platforms |  |
| Client apps | all |
| Locations | incl: Any location; excl: Allowed Countries - Service Accounts |
| Grant | block |
| Session | None |

### CA801-GSA-AllAgtUsr-AllAgtRsrc-AnyOS-AnyCli-NonComplNet-Block

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Agent 365 / M365 E7 |
| Include | None; Workload/agent identities |
| Exclude groups |  |
| Excluded directory roles | None |
| Resources | All agent resources |
| Platforms |  |
| Client apps | all |
| Locations | incl: Any location; excl: All Compliant Network locations |
| Grant | block |
| Session | None |

### CA802-GSA-AllUsr-InternetAcc-AnyOS-AnyCli-ReqMFAOrCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Entra Suite (Internet Access) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA802-GSA-AllUsr-InternetAcc-AnyOS-AnyCli-ReqMFAOrCompliant-EXCL |
| Excluded directory roles | None |
| Resources | All internet resources with Global Secure Access |
| Platforms |  |
| Client apps | all |
| Grant | mfa OR compliantDevice OR domainJoinedDevice |
| Session | None |

### CA803-GSA-AllUsr-PrivateAcc-AnyOS-AnyCli-ReqMFAOrCompliant

| Property | Configuration |
| :--- | :--- |
| Pack | Add-on |
| Deployed state | Off |
| Licence | Entra Suite (Private Access) |
| Include | All |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-Admins-EXCL, CA803-GSA-AllUsr-PrivateAcc-AnyOS-AnyCli-ReqMFAOrCompliant-EXCL |
| Excluded directory roles | None |
| Resources | %GsaPrivateAccessAppId% |
| Platforms |  |
| Client apps | all |
| Grant | mfa OR compliantDevice OR domainJoinedDevice |
| Session | None |


