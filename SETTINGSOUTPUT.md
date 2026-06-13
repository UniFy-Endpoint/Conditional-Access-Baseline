# Conditional Access Baseline - Policy Configuration Reference

Generated from the repository JSON inventory on **June 12, 2026**.

| Metric | Value |
| :--- | :--- |
| Policies | 50 |
| Security groups | 46 |
| Named locations | 3 |
| Administrator role standard | 34 roles |
| Disabled policies | 50 |

## Summary

| ID | Policy | Audience | Resources | Grant | Session | State |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CA001 | `CA001-GLB-AllApps-AnyOS-AnyCli-UntrustedLocation-Block` | Workforce users | All | block | None | Disabled |
| CA002 | `CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block` | Workforce users | All | block | None | Disabled |
| CA003 | `CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block` | Workforce users | All | block | None | Disabled |
| CA004 | `CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block` | Workforce users | All | block | None | Disabled |
| CA005 | `CA005-GLB-DeviceRegistration-AnyOS-AnyCli-AnyLoc-ReqMFA` | Workforce users | Any / none | mfa | None | Disabled |
| CA006 | `CA006-GLB-SecurityInfoReg-AnyOS-AnyCli-UntrustedLocation-ReqMFA` | Workforce users | Any / none | mfa | None | Disabled |
| CA101 | `CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResistantMFA` | Administrators (34 roles) | All | Authentication strength: Phishing-resistant MFA | None | Disabled |
| CA102 | `CA102-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq-PersistSession` | Administrators (34 roles) | All | Session controls only | Sign-in frequency: 8 hours; Persistent browser: never | Disabled |
| CA103 | `CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval` | Administrators (34 roles) | All | Session controls only | CAE: strictLocation | Disabled |
| CA104 | `CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid` | Administrators (34 roles) | All | compliantDevice OR domainJoinedDevice | None | Disabled |
| CA201 | `CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Workforce users | All | mfa | None | Disabled |
| CA202 | `CA202-USR-AllApps-AnyOS-ModernClient-UntrustedLocation-ReqPasswordlessMFA` | Workforce users | All | Authentication strength: Passwordless MFA | None | Disabled |
| CA203 | `CA203-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Workforce users | MicrosoftAdminPortals, Azure Resource Manager (797f4846-ba00-4fd7-ba43-dac1f8f63013) | block | None | Disabled |
| CA204 | `CA204-USR-AllApps-AnyOS-AnyLoc-Browser-SignInFreq-PersistSession` | Workforce users | All | Session controls only | Sign-in frequency: 12 hours; Persistent browser: never | Disabled |
| CA205 | `CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval` | Workforce users | All | Session controls only | CAE: strictLocation | Disabled |
| CA206 | `CA206-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant` | Workforce users | All | compliantDevice OR domainJoinedDevice | None | Disabled |
| CA207 | `CA207-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant` | Workforce users | All | compliantDevice | None | Disabled |
| CA208 | `CA208-USR-AllApps-iOS-AnyCli-AnyLoc-Managed-ReqCompliant` | Workforce users | All | compliantDevice | None | Disabled |
| CA209 | `CA209-USR-AllApps-Android-AnyCli-AnyLoc-Managed-ReqCompliant` | Workforce users | All | compliantDevice | None | Disabled |
| CA210 | `CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant` | Workforce users | All | compliantDevice | None | Disabled |
| CA211 | `CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl` | Workforce users | Office365 | compliantApplication | Defender for Cloud Apps: blockDownloads | Disabled |
| CA212 | `CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect` | Workforce users | Office365 | compliantApplication | None | Disabled |
| CA213 | `CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect` | Workforce users | Office365 | compliantApplication | None | Disabled |
| CA214 | `CA214-USR-O365-macOS-Browser-AnyLoc-AppEnforcedRestrictions` | Workforce users | Office365 | Session controls only | Application-enforced restrictions | Disabled |
| CA215 | `CA215-USR-M365-Win-Desktop-AnyLoc-ReqTokenProtect` | Workforce users | Office 365 Exchange Online (00000002-0000-0ff1-ce00-000000000000), Office 365 SharePoint Online (00000003-0000-0ff1-ce00-000000000000), Microsoft Teams Services (cc15fd57-2c6c-4117-a88c-83b1d56b4bbe) | Session controls only | Token protection | Disabled |
| CA216 | `CA216-USR-IntuneEnrollment-AnyOS-AnyCli-ReqMFA-SignInEveryTime` | Workforce users | Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c) | mfa | Sign-in frequency: every time | Disabled |
| CA217 | `CA217-USR-ExceptO365-iOS-AnyCli-AnyLoc-Unmanaged-Block` | Workforce users | All | block | None | Disabled |
| CA218 | `CA218-USR-ExceptO365-Android-AnyCli-AnyLoc-Unmanaged-Block` | Workforce users | All | block | None | Disabled |
| CA219 | `CA219-USR-M365-macOS-Desktop-AnyLoc-ReqTokenProtect-Preview` | Workforce users | Office 365 Exchange Online (00000002-0000-0ff1-ce00-000000000000), Office 365 SharePoint Online (00000003-0000-0ff1-ce00-000000000000), Microsoft Teams Services (cc15fd57-2c6c-4117-a88c-83b1d56b4bbe) | Session controls only | Token protection | Disabled |
| CA301 | `CA301-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Targeted group | All | mfa | None | Disabled |
| CA302 | `CA302-SVC-Interactive-AllApps-AnyOS-AnyCli-UntrustedLocation-Block` | Targeted group | All | block | None | Disabled |
| CA303 | `CA303-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval` | Targeted group | All | Session controls only | CAE: strictLocation | Disabled |
| CA401 | `CA401-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA` | Guests/external users | All | mfa | None | Disabled |
| CA402 | `CA402-GST-ExceptAllowed-AnyOS-ModernClient-AnyLoc-Block` | Guests/external users | All | block | None | Disabled |
| CA403 | `CA403-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block` | Guests/external users | Azure Resource Manager (797f4846-ba00-4fd7-ba43-dac1f8f63013), MicrosoftAdminPortals | block | None | Disabled |
| CA404 | `CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq-PersistSession` | Guests/external users | All | Session controls only | Sign-in frequency: 4 hours; Persistent browser: never | Disabled |
| CA405 | `CA405-GST-O365-AnyOS-Browser-AnyLoc-AppEnforcedRestrictions` | Guests/external users | Office365 | Session controls only | Application-enforced restrictions | Disabled |
| CA406 | `CA406-GST-AllApps-AnyOS-ModernClient-AnyLoc-ContinuousAccessEval` | Guests/external users | All | Session controls only | CAE: strictLocation | Disabled |
| CA501 | `CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMed-ReqPhishResistantMFA` | Workforce users | All | Authentication strength: Phishing-resistant MFA | Sign-in frequency: every time | Disabled |
| CA502 | `CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMed-ReqRiskRemediation` | Workforce users | All | riskRemediation AND Authentication strength: Passwordless MFA | Sign-in frequency: every time | Disabled |
| CA503 | `CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block` | Workforce users | All | block | None | Disabled |
| CA504 | `CA504-IDP-AllApps-AnyOS-AnyCli-SignInRiskHigh-Block` | Workforce users | All | block | None | Disabled |
| CA505 | `CA505-IDP-AllApps-AnyOS-AnyCli-UserRiskHigh-Block` | Workforce users | All | block | None | Disabled |
| CA601 | `CA601-AGT-AllAgentId-AllApps-AnyOS-AnyCli-BlockHighRiskAgent` | Agent identities | All | block | None | Disabled |
| CA602 | `CA602-AGT-UnapprovedAgentId-AllApps-AnyOS-AnyCli-Block` | Agent identities | All | block | None | Disabled |
| CA603 | `CA603-AGT-AllAgentUsers-AllApps-AnyOS-AnyCli-ReqCompliantDevice` | Scoped identities | All | compliantDevice | None | Disabled |
| CA604 | `CA604-AGT-AllAgentUsers-AllApps-AnyOS-AnyCli-BlockRiskyAgents` | Scoped identities | All | block | None | Disabled |
| CA605 | `CA605-AGT-AllAgentUsers-AllAgentIdResources-AnyOS-AnyCli-BlockNonCompliantNetwork` | Scoped identities | AllAgentIdResources | block | None | Disabled |
| CA701 | `CA701-WLI-AllApps-AnyLoc-WorkloadRiskHigh-Block` | Workload identities | All | block | None | Disabled |
| CA702 | `CA702-WLI-AllApps-AnyLoc-UntrustedNetwork-Block` | Workload identities | All | block | None | Disabled |

## Administrator Scope

CA101, CA102, CA103, and CA104 target the identical 34-role standard. All USR policies except CA215, CA216, and CA219 contain that full role exclusion set. CA201, CA202, CA203, CA206, and CA211 retain two additional directory-synchronization service-role exceptions. CA215, CA216, and CA219 retain only synchronization exceptions because their controls are unique and must continue to protect administrators.

## Policy Details

### CA001-GLB-AllApps-AnyOS-AnyCli-UntrustedLocation-Block

| Property | Configuration |
| :--- | :--- |
| ID | `8687d337-92c7-404e-912b-febb2a2fb410` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA001-GLB-AllApps-AnyOS-AnyCli-UntrustedLocation-Block-EXCL (abd4c0ac-aaaa-4683-827a-e326873dd454) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | All |
| Locations exclude | Allowed Countries (10725f98-e039-43b4-9084-ae8e9450d3fe), 04520deb-35c8-4d96-9a16-b3441e542e3b |
| Device filter | `exclude: device.mdmAppId -eq "0000000a-0000-0000-c000-000000000000" -and device.deviceOwnership -eq "Company" -and device.isCompliant -eq True` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA001-GLB-AllApps-AnyOS-AnyCli-UntrustedLocation-Block-EXCL |

### CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block

| Property | Configuration |
| :--- | :--- |
| ID | `85158d6b-e42c-480b-bce3-10f569eaf4ca` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block-EXCL (b81ebc29-66cf-4e69-8bf7-7604f797b08a), CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all except android, iOS, windows, macOS, linux (fires on other/unknown platforms only) |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA002-GLB-AllApps-AnyOS-AnyCli-UnsupportedOS-Block-EXCL |

### CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block

| Property | Configuration |
| :--- | :--- |
| ID | `2440a1db-13c3-4465-8634-02895b031486` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block-EXCL (a90133c8-9a64-47b4-bd50-3bc45556a0bf) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | exchangeActiveSync, other |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block-EXCL |

### CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block

| Property | Configuration |
| :--- | :--- |
| ID | `84db64ec-b24e-4d21-ba98-37ef4ff2fcfd` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block-EXCL (0813d74d-094c-4677-b4f4-9d8bec4c3b35) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA004-GLB-AllApps-AnyOS-AnyCli-DeviceCode-Block-EXCL |

### CA005-GLB-DeviceRegistration-AnyOS-AnyCli-AnyLoc-ReqMFA

| Property | Configuration |
| :--- | :--- |
| ID | `cca1efbd-cddb-4c3c-b393-7b1b9ff13787` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA005-GLB-DeviceRegistration-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL (e0a3310d-fd7b-42ec-9a6e-6fc064f02358) |
| Include roles | None |
| Exclude roles | 1 roles |
| Guest/external scope | Not configured |
| Include resources | Any / none |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | mfa |
| Session | None |
| Dedicated EXCL | CA005-GLB-DeviceRegistration-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL |

### CA006-GLB-SecurityInfoReg-AnyOS-AnyCli-UntrustedLocation-ReqMFA

| Property | Configuration |
| :--- | :--- |
| ID | `d0bd7a4c-7428-40fa-a44b-0db4dd387e58` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA006-GLB-SecurityInfoReg-AnyOS-AnyCli-UntrustedLocation-ReqMFA-EXCL (6a1fd238-bfef-470e-be4d-813bd29cf80e), CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Explicitly excluded |
| Include resources | Any / none |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | All |
| Locations exclude | Allowed Countries (10725f98-e039-43b4-9084-ae8e9450d3fe) |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | mfa |
| Session | None |
| Dedicated EXCL | CA006-GLB-SecurityInfoReg-AnyOS-AnyCli-UntrustedLocation-ReqMFA-EXCL |

### CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResistantMFA

| Property | Configuration |
| :--- | :--- |
| ID | `3e7161c6-61f6-48e4-a12c-0b1a80285bcd` |
| State | Disabled |
| Audience | Administrators (34 roles) |
| Include users | Any / none |
| Include groups | None |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResistantMFA-EXCL (7b32cf4c-58c1-4fe8-9547-983e4d57a098) |
| Include roles | 34 roles |
| Exclude roles | 1 roles |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Authentication strength: Phishing-resistant MFA |
| Session | None |
| Dedicated EXCL | CA101-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishResistantMFA-EXCL |

### CA102-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq-PersistSession

| Property | Configuration |
| :--- | :--- |
| ID | `4fc32cfa-e7f3-4bf5-b0c1-d9cf03727a0a` |
| State | Disabled |
| Audience | Administrators (34 roles) |
| Include users | Any / none |
| Include groups | None |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA102-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq-PersistSession-EXCL (9c00db91-443d-403d-aa57-a936717a05a8) |
| Include roles | 34 roles |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | Sign-in frequency: 8 hours; Persistent browser: never |
| Dedicated EXCL | CA102-ADM-AllApps-AnyOS-AnyCli-AnyLoc-SignInFreq-PersistSession-EXCL |

### CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval

| Property | Configuration |
| :--- | :--- |
| ID | `fd8ebdac-ccee-4867-b616-62321f6f7954` |
| State | Disabled |
| Audience | Administrators (34 roles) |
| Include users | Any / none |
| Include groups | None |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval-EXCL (a570fe91-63a6-40f4-ae55-aecef9ffa324) |
| Include roles | 34 roles |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | CAE: strictLocation |
| Dedicated EXCL | CA103-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval-EXCL |

### CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid

| Property | Configuration |
| :--- | :--- |
| ID | `49466c67-e8bb-4e0c-a50e-694579314365` |
| State | Disabled |
| Audience | Administrators (34 roles) |
| Include users | Any / none |
| Include groups | None |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid-EXCL (a247a2a0-0a3d-47cb-83c3-df185d806f8d) |
| Include roles | 34 roles |
| Exclude roles | 2 roles |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantDevice OR domainJoinedDevice |
| Session | None |
| Dedicated EXCL | CA104-ADM-AllApps-AnyOS-AnyCli-AnyLoc-ReqCompliantOrHybrid-EXCL |

### CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA

| Property | Configuration |
| :--- | :--- |
| ID | `781877d1-c270-42e2-8508-bc15941143d9` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL (3f9c97fb-8087-4992-b912-bfc471201a59) |
| Include roles | None |
| Exclude roles | 36 roles (34-role standard plus 2 directory-synchronization exceptions) |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | mfa |
| Session | None |
| Dedicated EXCL | CA201-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL |

### CA202-USR-AllApps-AnyOS-ModernClient-UntrustedLocation-ReqPasswordlessMFA

| Property | Configuration |
| :--- | :--- |
| ID | `61270a8f-8f28-4129-84e1-e7edc9a6cce1` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA202-USR-AllApps-AnyOS-ModernClient-UntrustedLocation-ReqPasswordlessMFA-EXCL (1444d9a4-a764-4127-a1f9-716342cb904b) |
| Include roles | None |
| Exclude roles | 36 roles (34-role standard plus 2 directory-synchronization exceptions) |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | browser, mobileAppsAndDesktopClients |
| Platforms | all |
| Locations include | All |
| Locations exclude | Allowed Countries (10725f98-e039-43b4-9084-ae8e9450d3fe) |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Authentication strength: Passwordless MFA |
| Session | None |
| Dedicated EXCL | CA202-USR-AllApps-AnyOS-ModernClient-UntrustedLocation-ReqPasswordlessMFA-EXCL |

### CA203-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block

| Property | Configuration |
| :--- | :--- |
| ID | `0e8ae394-ca86-4604-8380-bc851c5fce45` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA203-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL (5273dd03-b602-4a55-b42a-7d8819ea3a0c) |
| Include roles | None |
| Exclude roles | 36 roles (34-role standard plus 2 directory-synchronization exceptions) |
| Guest/external scope | Explicitly excluded |
| Include resources | MicrosoftAdminPortals, Azure Resource Manager (797f4846-ba00-4fd7-ba43-dac1f8f63013) |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA203-USR-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL |

### CA204-USR-AllApps-AnyOS-AnyLoc-Browser-SignInFreq-PersistSession

| Property | Configuration |
| :--- | :--- |
| ID | `9ce96145-e024-4bdd-a276-9e44b74d52db` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA204-USR-AllApps-AnyOS-AnyLoc-Browser-SignInFreq-PersistSession-EXCL (8d1356e9-235c-4fb3-85ff-b6f6fd33639f) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | browser |
| Platforms | windows, macOS, iOS, android, linux |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `exclude: device.deviceOwnership -eq "Company" -or device.isCompliant -eq True` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | Sign-in frequency: 12 hours; Persistent browser: never |
| Dedicated EXCL | CA204-USR-AllApps-AnyOS-AnyLoc-Browser-SignInFreq-PersistSession-EXCL |

### CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval

| Property | Configuration |
| :--- | :--- |
| ID | `4a88f697-7be4-4896-a37b-db1f6c3bc608` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval-EXCL (18fa41d2-7057-43bc-a7dc-b319f0ae6606) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | CAE: strictLocation |
| Dedicated EXCL | CA205-USR-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval-EXCL |

### CA206-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| ID | `7174872c-ef9f-45a5-9ed8-4203183ff5c3` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA206-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant-EXCL (c489e3e2-1bd0-4bce-b070-4f3ab23c8a9b) |
| Include roles | None |
| Exclude roles | 36 roles (34-role standard plus 2 directory-synchronization exceptions) |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Edge Sync (a4f2693f-129c-4b96-982b-2c364b8314d7), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c), Microsoft Intune (0000000a-0000-0000-c000-000000000000), Windows Cloud Login (270efc09-cd0d-444b-a71f-39af4910ec45), Microsoft Activity Feed Service (d32c68ad-72d2-4acb-a0c7-46bb2cf93873), Microsoft Rights Management Services (00000012-0000-0000-c000-000000000000) |
| Client app types | mobileAppsAndDesktopClients |
| Platforms | windows |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantDevice OR domainJoinedDevice |
| Session | None |
| Dedicated EXCL | CA206-USR-AllApps-Win-Desktop-AnyLoc-ReqCompliant-EXCL |

### CA207-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| ID | `697c223d-7239-4fd2-a05d-0391ee969792` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA207-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant-EXCL (c1b9fdaf-ebc0-456c-acd0-c6d2fac10f1e) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Edge Sync (a4f2693f-129c-4b96-982b-2c364b8314d7), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c), Microsoft Intune (0000000a-0000-0000-c000-000000000000), Windows Cloud Login (270efc09-cd0d-444b-a71f-39af4910ec45), Microsoft Activity Feed Service (d32c68ad-72d2-4acb-a0c7-46bb2cf93873), Microsoft Rights Management Services (00000012-0000-0000-c000-000000000000) |
| Client app types | mobileAppsAndDesktopClients |
| Platforms | macOS |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantDevice |
| Session | None |
| Dedicated EXCL | CA207-USR-AllApps-macOS-Desktop-AnyLoc-ReqCompliant-EXCL |

### CA208-USR-AllApps-iOS-AnyCli-AnyLoc-Managed-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| ID | `80773c8f-9409-4924-91bb-676e0bc0d86d` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA208-USR-AllApps-iOS-AnyCli-AnyLoc-Managed-ReqCompliant-EXCL (dd68178f-b5b1-45c3-be04-304ad8b5c91a) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Microsoft Intune (0000000a-0000-0000-c000-000000000000), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c) |
| Client app types | all |
| Platforms | iOS |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `include: device.mdmAppId -eq "0000000a-0000-0000-c000-000000000000"` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantDevice |
| Session | None |
| Dedicated EXCL | CA208-USR-AllApps-iOS-AnyCli-AnyLoc-Managed-ReqCompliant-EXCL |

### CA209-USR-AllApps-Android-AnyCli-AnyLoc-Managed-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| ID | `8e32fb97-8ef0-4198-9f8b-5e77cbe222c2` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA209-USR-AllApps-Android-AnyCli-AnyLoc-Managed-ReqCompliant-EXCL (1bed65eb-3c26-449e-bb1d-eb61e193de9e) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Microsoft Intune (0000000a-0000-0000-c000-000000000000), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c) |
| Client app types | all |
| Platforms | android |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `include: device.mdmAppId -eq "0000000a-0000-0000-c000-000000000000"` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantDevice |
| Session | None |
| Dedicated EXCL | CA209-USR-AllApps-Android-AnyCli-AnyLoc-Managed-ReqCompliant-EXCL |

### CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant

| Property | Configuration |
| :--- | :--- |
| ID | `b6ed4c3f-1d0c-41b8-bd51-e14a63198c68` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant-EXCL (24ce71a0-a35c-4d76-b473-98deae1de32b) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Microsoft Intune (0000000a-0000-0000-c000-000000000000) |
| Client app types | all |
| Platforms | linux |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantDevice |
| Session | None |
| Dedicated EXCL | CA210-USR-AllApps-Linux-AnyCli-AnyLoc-ReqCompliant-EXCL |

### CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl

| Property | Configuration |
| :--- | :--- |
| ID | `0293b8bd-ce33-4fc6-a2ee-c8a8089c3110` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl-EXCL (236772fa-5f88-4345-8de1-e6b2b6cc0c8b) |
| Include roles | None |
| Exclude roles | 36 roles (34-role standard plus 2 directory-synchronization exceptions) |
| Guest/external scope | Explicitly excluded |
| Include resources | Office365 |
| Exclude resources | Any / none |
| Client app types | browser |
| Platforms | windows |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -and device.isCompliant -ne True` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantApplication |
| Session | Defender for Cloud Apps: blockDownloads |
| Dedicated EXCL | CA211-USR-O365-Win-Browser-BYOD-ReqAppProtect-AppCtrl-EXCL |

### CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect

| Property | Configuration |
| :--- | :--- |
| ID | `bb19b550-319f-4edf-9122-0ddee34694c8` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect-EXCL (f69eda77-f120-4ffb-beba-fce593e90119) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | Office365 |
| Exclude resources | Microsoft Intune (0000000a-0000-0000-c000-000000000000), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c) |
| Client app types | mobileAppsAndDesktopClients |
| Platforms | android |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `exclude: device.mdmAppId -eq "0000000a-0000-0000-c000-000000000000"` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantApplication |
| Session | None |
| Dedicated EXCL | CA212-USR-O365-Android-Mobile-BYOD-ReqAppProtect-EXCL |

### CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect

| Property | Configuration |
| :--- | :--- |
| ID | `1ece068a-9766-4626-ac17-afc7262ad15d` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect-EXCL (b61afe3a-c7b2-4ce0-9dc7-cbc4176bb912) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | Office365 |
| Exclude resources | Microsoft Intune (0000000a-0000-0000-c000-000000000000), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c) |
| Client app types | mobileAppsAndDesktopClients |
| Platforms | iOS |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `exclude: device.mdmAppId -eq "0000000a-0000-0000-c000-000000000000"` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantApplication |
| Session | None |
| Dedicated EXCL | CA213-USR-O365-iOS-Mobile-BYOD-ReqAppProtect-EXCL |

### CA214-USR-O365-macOS-Browser-AnyLoc-AppEnforcedRestrictions

| Property | Configuration |
| :--- | :--- |
| ID | `bd42493a-8e90-4f7b-bdcf-5d80a4c0dd19` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA214-USR-O365-macOS-Browser-AnyLoc-AppEnforcedRestrictions-EXCL (6f0d26b1-8c5d-4c4a-9a77-5b3e2f8416d9) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | Office365 |
| Exclude resources | Any / none |
| Client app types | browser |
| Platforms | macOS |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -and device.isCompliant -ne True` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | Application-enforced restrictions |
| Dedicated EXCL | CA214-USR-O365-macOS-Browser-AnyLoc-AppEnforcedRestrictions-EXCL |

### CA215-USR-M365-Win-Desktop-AnyLoc-ReqTokenProtect

| Property | Configuration |
| :--- | :--- |
| ID | `98768fd6-bd6d-42d7-8d97-a98299a96b67` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA215-USR-M365-Win-Desktop-AnyLoc-ReqTokenProtect-EXCL (fb64ed78-b96f-4cc8-9eaf-6f1999c2c80b) |
| Include roles | None |
| Exclude roles | 1 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | Office 365 Exchange Online (00000002-0000-0ff1-ce00-000000000000), Office 365 SharePoint Online (00000003-0000-0ff1-ce00-000000000000), Microsoft Teams Services (cc15fd57-2c6c-4117-a88c-83b1d56b4bbe) |
| Exclude resources | Any / none |
| Client app types | mobileAppsAndDesktopClients |
| Platforms | windows |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | Token protection |
| Dedicated EXCL | CA215-USR-M365-Win-Desktop-AnyLoc-ReqTokenProtect-EXCL |

### CA216-USR-IntuneEnrollment-AnyOS-AnyCli-ReqMFA-SignInEveryTime

| Property | Configuration |
| :--- | :--- |
| ID | `%CA216PolicyId%` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA216-USR-IntuneEnrollment-AnyOS-AnyCli-ReqMFA-SignInEveryTime-EXCL (%CA216ExclGroupId%) |
| Include roles | None |
| Exclude roles | 2 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c) |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | mfa |
| Session | Sign-in frequency: every time |
| Dedicated EXCL | CA216-USR-IntuneEnrollment-AnyOS-AnyCli-ReqMFA-SignInEveryTime-EXCL |

### CA217-USR-ExceptO365-iOS-AnyCli-AnyLoc-Unmanaged-Block

| Property | Configuration |
| :--- | :--- |
| ID | `8af96a43-00fc-4e8e-8956-a17ef300dec2` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA217-USR-ExceptO365-iOS-AnyCli-AnyLoc-Unmanaged-Block-EXCL (e2b1a316-387a-46d0-b918-d7b5ca56e2dc) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Office365, Microsoft Intune (0000000a-0000-0000-c000-000000000000), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c), Device Registration Service (01cb2876-7ebd-4aa4-9cc9-d28bd4d359a9) |
| Client app types | all |
| Platforms | iOS |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -or device.isCompliant -ne True` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA217-USR-ExceptO365-iOS-AnyCli-AnyLoc-Unmanaged-Block-EXCL |

### CA218-USR-ExceptO365-Android-AnyCli-AnyLoc-Unmanaged-Block

| Property | Configuration |
| :--- | :--- |
| ID | `de6d9082-56c4-4c91-8dab-c1db7165b061` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA218-USR-ExceptO365-Android-AnyCli-AnyLoc-Unmanaged-Block-EXCL (d95b7bb3-0e51-4d1a-8371-8f9f118b2d83) |
| Include roles | None |
| Exclude roles | 34 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Office365, Microsoft Intune (0000000a-0000-0000-c000-000000000000), Microsoft Intune Enrollment (d4ebce55-015a-49b5-a083-c84d1797ae8c), Device Registration Service (01cb2876-7ebd-4aa4-9cc9-d28bd4d359a9) |
| Client app types | all |
| Platforms | android |
| Locations include | Any |
| Locations exclude | None |
| Device filter | `include: device.mdmAppId -ne "0000000a-0000-0000-c000-000000000000" -or device.isCompliant -ne True` |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA218-USR-ExceptO365-Android-AnyCli-AnyLoc-Unmanaged-Block-EXCL |

### CA219-USR-M365-macOS-Desktop-AnyLoc-ReqTokenProtect-Preview

| Property | Configuration |
| :--- | :--- |
| ID | `6c2b97ef-5c14-43f5-9d26-0d946b1c50ef` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA219-USR-M365-macOS-Desktop-AnyLoc-ReqTokenProtect-Preview-EXCL (f5f17fee-8aed-429d-ab88-86c7ba96fa40) |
| Include roles | None |
| Exclude roles | 1 roles |
| Guest/external scope | Explicitly excluded |
| Include resources | Office 365 Exchange Online (00000002-0000-0ff1-ce00-000000000000), Office 365 SharePoint Online (00000003-0000-0ff1-ce00-000000000000), Microsoft Teams Services (cc15fd57-2c6c-4117-a88c-83b1d56b4bbe) |
| Exclude resources | Any / none |
| Client app types | mobileAppsAndDesktopClients |
| Platforms | macOS |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | Token protection |
| Dedicated EXCL | CA219-USR-M365-macOS-Desktop-AnyLoc-ReqTokenProtect-Preview-EXCL |

### CA301-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA

| Property | Configuration |
| :--- | :--- |
| ID | `%CA301PolicyId%` |
| State | Disabled |
| Audience | Targeted group |
| Include users | Any / none |
| Include groups | CA-SVC-Interactive-ServiceAccounts (%ServiceAccountsGroupId%) |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA301-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL (%CA301ExclGroupId%) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | mfa |
| Session | None |
| Dedicated EXCL | CA301-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL |

### CA302-SVC-Interactive-AllApps-AnyOS-AnyCli-UntrustedLocation-Block

| Property | Configuration |
| :--- | :--- |
| ID | `%CA302PolicyId%` |
| State | Disabled |
| Audience | Targeted group |
| Include users | Any / none |
| Include groups | CA-SVC-Interactive-ServiceAccounts (%ServiceAccountsGroupId%) |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA302-SVC-Interactive-AllApps-AnyOS-AnyCli-UntrustedLocation-Block-EXCL (%CA302ExclGroupId%) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | All |
| Locations exclude | Allowed Countries - Service Accounts (%SvcCountryLocationId%) |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA302-SVC-Interactive-AllApps-AnyOS-AnyCli-UntrustedLocation-Block-EXCL |

### CA303-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval

| Property | Configuration |
| :--- | :--- |
| ID | `%CA303PolicyId%` |
| State | Disabled |
| Audience | Targeted group |
| Include users | Any / none |
| Include groups | CA-SVC-Interactive-ServiceAccounts (%ServiceAccountsGroupId%) |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA303-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval-EXCL (%CA303ExclGroupId%) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | CAE: strictLocation |
| Dedicated EXCL | CA303-SVC-Interactive-AllApps-AnyOS-AnyCli-AnyLoc-ContinuousAccessEval-EXCL |

### CA401-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA

| Property | Configuration |
| :--- | :--- |
| ID | `a9c2077e-49ae-4334-9bae-c728f7ebf16e` |
| State | Disabled |
| Audience | Guests/external users |
| Include users | Any / none |
| Include groups | Any / none |
| Exclude groups | CA401-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL (a84532fa-8795-4345-9c04-6cd954ac2191) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Included |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | mfa |
| Session | None |
| Dedicated EXCL | CA401-GST-AllApps-AnyOS-AnyCli-AnyLoc-ReqMFA-EXCL |

### CA402-GST-ExceptAllowed-AnyOS-ModernClient-AnyLoc-Block

| Property | Configuration |
| :--- | :--- |
| ID | `03c70fc2-fe67-4d3c-b896-86cb8014141b` |
| State | Disabled |
| Audience | Guests/external users |
| Include users | Any / none |
| Include groups | Any / none |
| Exclude groups | CA402-GST-ExceptAllowed-AnyOS-ModernClient-AnyLoc-Block-EXCL (d09b644e-696a-4e92-affa-29dd0afdf9d1) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Included |
| Include resources | All |
| Exclude resources | AADReporting (1b912ec3-a9dd-4c4d-a53e-76aa7adb28d7), Windows 365 (0af06dc6-e4b5-4f28-818e-e78e62d137a5), My Apps (2793995e-0a7d-40d7-bd35-6968ba142197), Windows Azure Active Directory (00000002-0000-0000-c000-000000000000), My Signins (19db86c3-b2b9-44cc-b339-36da233a3be2), Microsoft Approval Management (65d91a3d-ab74-42e6-8a2f-0add61688c74), Microsoft Invitation Acceptance Portal (4660504c-45b3-4674-a709-71951a6b0763), Windows Cloud Login (270efc09-cd0d-444b-a71f-39af4910ec45), Microsoft Teams Services (cc15fd57-2c6c-4117-a88c-83b1d56b4bbe), My Profile (8c59ead7-d703-4a27-9e55-c96a0054c8d2), Microsoft App Access Panel (0000000c-0000-0000-c000-000000000000), Azure Credential Configuration Endpoint Service (ea890292-c8c8-4433-b5ea-b09d0668e1a6), Microsoft Activity Feed Service (d32c68ad-72d2-4acb-a0c7-46bb2cf93873), Microsoft Rights Management Services (00000012-0000-0000-c000-000000000000), Office365 |
| Client app types | browser, mobileAppsAndDesktopClients |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA402-GST-ExceptAllowed-AnyOS-ModernClient-AnyLoc-Block-EXCL |

### CA403-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block

| Property | Configuration |
| :--- | :--- |
| ID | `13437e94-79fe-427b-8d30-ee1159f6f624` |
| State | Disabled |
| Audience | Guests/external users |
| Include users | Any / none |
| Include groups | Any / none |
| Exclude groups | CA403-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL (d8fa8de6-701f-4d57-855c-1bc64690ac95) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Included |
| Include resources | Azure Resource Manager (797f4846-ba00-4fd7-ba43-dac1f8f63013), MicrosoftAdminPortals |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA403-GST-AdminCenters-AnyOS-AnyCli-AnyLoc-Block-EXCL |

### CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq-PersistSession

| Property | Configuration |
| :--- | :--- |
| ID | `3c56e68a-ccf3-45ee-9317-996c6dc5f4cb` |
| State | Disabled |
| Audience | Guests/external users |
| Include users | Any / none |
| Include groups | Any / none |
| Exclude groups | CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq-PersistSession-EXCL (ed33faf7-bd1f-4481-9ba2-17508998226c) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Included |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | Sign-in frequency: 4 hours; Persistent browser: never |
| Dedicated EXCL | CA404-GST-AllApps-AnyOS-AnyCli-AnyLoc-Browser-SignInFreq-PersistSession-EXCL |

### CA405-GST-O365-AnyOS-Browser-AnyLoc-AppEnforcedRestrictions

| Property | Configuration |
| :--- | :--- |
| ID | `02d314d7-6ede-4d45-a11a-22fe0433f038` |
| State | Disabled |
| Audience | Guests/external users |
| Include users | Any / none |
| Include groups | Any / none |
| Exclude groups | CA405-GST-O365-AnyOS-Browser-AnyLoc-AppEnforcedRestrictions-EXCL (5e930f19-7ed3-404d-8381-9ebbdc74bcac) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Included |
| Include resources | Office365 |
| Exclude resources | Any / none |
| Client app types | browser |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | Application-enforced restrictions |
| Dedicated EXCL | CA405-GST-O365-AnyOS-Browser-AnyLoc-AppEnforcedRestrictions-EXCL |

### CA406-GST-AllApps-AnyOS-ModernClient-AnyLoc-ContinuousAccessEval

| Property | Configuration |
| :--- | :--- |
| ID | `60e297ec-1c16-4400-8521-cc1414894327` |
| State | Disabled |
| Audience | Guests/external users |
| Include users | Any / none |
| Include groups | Any / none |
| Exclude groups | CA406-GST-AllApps-AnyOS-ModernClient-AnyLoc-ContinuousAccessEval-EXCL (b00d9511-f97e-4aea-a1a5-faee05c8ab38) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Included |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | browser, mobileAppsAndDesktopClients |
| Platforms | all |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Session controls only |
| Session | CAE: strictLocation |
| Dedicated EXCL | CA406-GST-AllApps-AnyOS-ModernClient-AnyLoc-ContinuousAccessEval-EXCL |

### CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMed-ReqPhishResistantMFA

| Property | Configuration |
| :--- | :--- |
| ID | `ae0c2054-c1b5-4118-bb11-a43be325d1f6` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMed-ReqPhishResistantMFA-EXCL (16443a68-7c9a-4880-8018-9712da9cdfe9) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | medium |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | Authentication strength: Phishing-resistant MFA |
| Session | Sign-in frequency: every time |
| Dedicated EXCL | CA501-IDP-AllApps-AnyOS-AnyCli-SignInRiskMed-ReqPhishResistantMFA-EXCL |

### CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMed-ReqRiskRemediation

| Property | Configuration |
| :--- | :--- |
| ID | `ca9a0b62-e1e6-40c6-96b5-0623727cfbd7` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMed-ReqRiskRemediation-EXCL (c32d5ef2-7411-4c01-9f25-3650e7be61f4) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | medium |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | riskRemediation AND Authentication strength: Passwordless MFA |
| Session | Sign-in frequency: every time |
| Dedicated EXCL | CA502-IDP-AllApps-AnyOS-AnyCli-UserRiskMed-ReqRiskRemediation-EXCL |

### CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block

| Property | Configuration |
| :--- | :--- |
| ID | `7acb5d22-b294-465b-a9a0-6b620e1e6358` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block-EXCL (c5b52f76-4b2d-43e7-a27b-df4c1f455ef4), CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA503-IDP-AllApps-AnyOS-AnyCli-InsiderRiskElevated-Block-EXCL |

### CA504-IDP-AllApps-AnyOS-AnyCli-SignInRiskHigh-Block

| Property | Configuration |
| :--- | :--- |
| ID | `%CA504PolicyId%` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA504-IDP-AllApps-AnyOS-AnyCli-SignInRiskHigh-Block-EXCL (%CA504ExclGroupId%) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | high |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA504-IDP-AllApps-AnyOS-AnyCli-SignInRiskHigh-Block-EXCL |

### CA505-IDP-AllApps-AnyOS-AnyCli-UserRiskHigh-Block

| Property | Configuration |
| :--- | :--- |
| ID | `%CA505PolicyId%` |
| State | Disabled |
| Audience | Workforce users |
| Include users | All |
| Include groups | Any / none |
| Exclude groups | CA000-GLB-BGA-EmergencyAccess-EXCL (9f027ad8-042b-4c85-9727-9008f6851597), CA505-IDP-AllApps-AnyOS-AnyCli-UserRiskHigh-Block-EXCL (%CA505ExclGroupId%) |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Explicitly excluded |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | high |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | CA505-IDP-AllApps-AnyOS-AnyCli-UserRiskHigh-Block-EXCL |

### CA601-AGT-AllAgentId-AllApps-AnyOS-AnyCli-BlockHighRiskAgent

| Property | Configuration |
| :--- | :--- |
| ID | `%CA601PolicyId%` |
| State | Disabled |
| Audience | Agent identities |
| Include users | None |
| Include groups | Any / none |
| Exclude groups | Any / none |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | high |
| Grant | block |
| Session | None |
| Include service principals | Any / none |
| Exclude service principals | Any / none |
| Include agent identities | All |
| Exclude agent identities | Any / none |
| Agent approval filter | None |
| Dedicated EXCL | None |

### CA602-AGT-UnapprovedAgentId-AllApps-AnyOS-AnyCli-Block

| Property | Configuration |
| :--- | :--- |
| ID | `%CA602PolicyId%` |
| State | Disabled |
| Audience | Agent identities |
| Include users | None |
| Include groups | Any / none |
| Exclude groups | Any / none |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Include service principals | Any / none |
| Exclude service principals | Any / none |
| Include agent identities | All |
| Exclude agent identities | Any / none |
| Agent approval filter | `exclude: CustomSecurityAttribute.AgentIdentity_AgentApprovalStatus -eq "Approved"` |
| Dedicated EXCL | None |

### CA603-AGT-AllAgentUsers-AllApps-AnyOS-AnyCli-ReqCompliantDevice

| Property | Configuration |
| :--- | :--- |
| ID | `%CA603PolicyId%` |
| State | Disabled |
| Audience | Scoped identities |
| Include users | None |
| Include groups | Any / none |
| Exclude groups | Any / none |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | compliantDevice |
| Session | None |
| Dedicated EXCL | None |

### CA604-AGT-AllAgentUsers-AllApps-AnyOS-AnyCli-BlockRiskyAgents

| Property | Configuration |
| :--- | :--- |
| ID | `%CA604PolicyId%` |
| State | Disabled |
| Audience | Scoped identities |
| Include users | None |
| Include groups | Any / none |
| Exclude groups | Any / none |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | medium,high |
| Grant | block |
| Session | None |
| Dedicated EXCL | None |

### CA605-AGT-AllAgentUsers-AllAgentIdResources-AnyOS-AnyCli-BlockNonCompliantNetwork

| Property | Configuration |
| :--- | :--- |
| ID | `%CA605PolicyId%` |
| State | Disabled |
| Audience | Scoped identities |
| Include users | None |
| Include groups | Any / none |
| Exclude groups | Any / none |
| Include roles | None |
| Exclude roles | None |
| Guest/external scope | Not configured |
| Include resources | AllAgentIdResources |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | All |
| Locations exclude | All Compliant Network locations (%CompliantNetworkLocationId%) |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Dedicated EXCL | None |

### CA701-WLI-AllApps-AnyLoc-WorkloadRiskHigh-Block

| Property | Configuration |
| :--- | :--- |
| ID | `848a0ffb-bd95-4836-804c-44d42ddc3a59` |
| State | Disabled |
| Audience | Workload identities |
| User conditions | None (workload identity policy) |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | Any |
| Locations exclude | None |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | high |
| Agent risk | None |
| Grant | block |
| Session | None |
| Include service principals | ServicePrincipalsInMyTenant |
| Exclude service principals | Any / none |
| Include agent identities | Any / none |
| Exclude agent identities | Any / none |
| Agent approval filter | None |
| Dedicated EXCL | None |

### CA702-WLI-AllApps-AnyLoc-UntrustedNetwork-Block

| Property | Configuration |
| :--- | :--- |
| ID | `13922b7b-7836-4876-8edc-674ef5a1823d` |
| State | Disabled |
| Audience | Workload identities |
| User conditions | None (workload identity policy) |
| Include resources | All |
| Exclude resources | Any / none |
| Client app types | all |
| Platforms | Any |
| Locations include | All |
| Locations exclude | Allowed Countries - Service Accounts (%SvcCountryLocationId%) |
| Device filter | None |
| Sign-in risk | Any / none |
| User risk | Any / none |
| Service-principal risk | Any / none |
| Agent risk | None |
| Grant | block |
| Session | None |
| Include service principals | ServicePrincipalsInMyTenant |
| Exclude service principals | Any / none |
| Include agent identities | Any / none |
| Exclude agent identities | Any / none |
| Agent approval filter | None |
| Dedicated EXCL | None |

## Required Workload Configuration

- CA211 requires the Windows Intune App Protection policy and Defender for Cloud Apps session policy.
- CA212 and CA213 require platform-specific Intune App Protection policies.
- CA214 and CA405 require SharePoint/OneDrive limited-access and Exchange application-enforced restriction settings.
- CA103, CA205, CA303, and CA406 require validated named locations and CAE resource-seen IP testing.
- CA215 targets supported Windows M365 desktop resources. CA219 is the separate macOS preview policy and should be enabled in report-only mode until token-protection support for macOS is confirmed in the tenant.
- CA701 and CA702 require Microsoft Entra Workload ID Premium and approved service-principal inventory.
- CA602 requires `CustomSecurityAttribute.AgentIdentity_AgentApprovalStatus` with value `Approved` for allowed agents.
- CA605 requires Global Secure Access compliant-network signals.
