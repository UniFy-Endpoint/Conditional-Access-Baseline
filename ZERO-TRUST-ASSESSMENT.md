# Zero Trust Conditional Access Assessment

Assessment date: June 11, 2026

## Executive Summary

This baseline provides strong coverage of Microsoft's common Conditional Access controls for workforce users, administrators, guests, managed devices, unmanaged-device access, identity risk, session enforcement, legacy authentication, and authentication flows.

The baseline is substantial, but it is not yet a complete Microsoft Zero Trust Conditional Access implementation. The highest-priority findings are:

1. Phishing-resistant MFA for administrators is limited to untrusted locations instead of applying to all locations.
2. MFA for device registration or join is limited to untrusted locations instead of applying to the user action at all locations.
3. Conditional Access for workload identities is not represented.
4. Two applicable policies do not exclude the shared emergency-access group.
5. The source JSON records policies as enabled even though the restore script safely creates them as disabled.

The first four findings should be addressed before describing the repository as a complete Conditional Access baseline. Workload-identity policies require tenant-specific service-principal and network information, so they should be implemented as documented extensions or generated templates rather than universal static policies.

## Assessment Scope

The assessment reviewed:

- All Conditional Access policy JSON files.
- Exclusion-group assignments.
- Grant and session controls.
- User actions, locations, device filters, authentication flows, and risk conditions.
- The restore script's policy-state handling.
- Current Microsoft Zero Trust, Conditional Access, Identity Protection, workload identity, emergency-access, and authentication-strength guidance.

This is a design assessment. It does not validate tenant licensing, authentication-method readiness, group membership, named-location accuracy, Intune compliance, cross-tenant settings, sign-in logs, or application behavior.

## Current Coverage

| Control area | Status | Baseline coverage |
|---|---|---|
| Block legacy authentication | Covered | CA003 |
| Block unsupported device platforms | Covered | CA002 |
| Block device-code and authentication-transfer flows | Covered | CA004 |
| MFA for all workforce users | Covered | CA200 |
| MFA for administrator roles | Covered | CA100 |
| Phishing-resistant MFA for risky sign-ins | Covered | CA501 |
| User-risk remediation | Covered | CA502 |
| Device compliance by platform | Covered | CA106 and CA206-CA210 |
| Mobile app protection | Covered | CA212 and CA213 |
| Unmanaged browser restrictions | Covered | CA211, CA214, and CA215 |
| Guest MFA and session restrictions | Covered | CA400-CA405 |
| Security-information registration | Covered | CA006 |
| Sign-in frequency and browser persistence | Covered | CA103-CA104, CA203-CA204, and CA403-CA404 |
| Continuous Access Evaluation enforcement | Covered | CA105, CA205, and CA405 |
| Token protection | Covered with platform limitations | CA216 |
| Sign-in and user risk | Covered; Entra ID P2 required | CA501 and CA502 |
| Insider-risk signal | Covered; integration required | CA503 |

## Priority Findings

### 1. Require phishing-resistant MFA for administrators at all locations

**Priority:** High

CA101 requires phishing-resistant MFA only outside approved locations. CA100 applies MFA at all locations, but ordinary MFA does not provide the same phishing resistance.

Microsoft recommends phishing-resistant MFA for privileged administrator roles across all resources and does not make the recommendation dependent on network location.

**Recommendation**

- Change CA101 from `UntrustLoc` to `AnyLoc`.
- Target all resources.
- Keep only the administrator roles required by the organization, including at least Microsoft's recommended high-impact roles.
- Exclude the emergency-access group.
- Validate administrator registration for passkeys, Windows Hello for Business, or certificate-based authentication before enforcement.
- Deploy in report-only mode before enabling.

### 2. Require MFA for device registration or join at all locations

**Priority:** High

CA005 protects the `Register or join devices` user action only outside approved locations. Device registration establishes a persistent device identity and should not rely on location as the deciding factor.

**Recommendation**

- Change CA005 from `UntrustLoc` to `AnyLoc`.
- Use the built-in Multifactor authentication strength when external authentication-method compatibility permits it.
- Exclude emergency-access accounts.
- Set the tenant device setting `Require Multifactor Authentication to register or join devices with Microsoft Entra` to `No` when this user-action policy is used. Microsoft documents that the tenant-wide setting otherwise prevents correct Conditional Access enforcement.
- Test with a controlled pilot assignment and explicit device registration scenarios. Microsoft report-only evaluation does not support policies in the User Actions scope.

### 3. Add Conditional Access for workload identities

**Priority:** High for tenants with application service principals

The current policies target users and guests. User-scoped Conditional Access policies do not protect service-principal token requests.

Microsoft supports workload-identity policies that block selected service principals:

- Outside known public IP ranges.
- When Microsoft Entra detects service-principal risk.
- In scenarios integrated with authentication context.

**Recommendation**

- Inventory service principals, credentials, owners, permissions, sign-in locations, and business criticality.
- Prefer managed identities where supported.
- Add a location-based block policy for selected single-tenant service principals with predictable network origins.
- Add a service-principal risk block policy where licensing and Identity Protection support it.
- Start in report-only mode and review service-principal sign-in logs.

These policies are not suitable as universal static JSON because service-principal object IDs and approved network locations are tenant-specific. Microsoft Entra Workload ID Premium licensing is required to create or modify them, and managed identities are not covered by these policies.

### 4. Correct emergency-access exclusions

**Priority:** High

The shared emergency-access group is excluded from 31 of 39 policies. Six guest-only policies do not need the exclusion because emergency accounts should not be guests. The following two applicable policies do need correction:

- CA003-GLB-AllApps-AnyOS-Legacy-LegacyAuth-Block
- CA101-ADM-AllApps-AnyOS-AnyCli-UntrustLoc-ReqPhishMFA

Microsoft recommends excluding emergency-access accounts from Conditional Access policies that block or restrict sign-in. The accounts should instead use independent phishing-resistant credentials, be monitored, and be tested regularly.

**Recommendation**

- Add `CA000-GLB-BGA-EmergencyAccess-EXCL` to CA003 and CA101.
- Maintain at least two cloud-only emergency-access accounts.
- Use passkeys or certificate-based authentication that does not depend on the normal administrator authentication path.
- Alert on every sign-in and regularly validate account access.

### 5. Make source policy state safer

**Priority:** Medium

Every policy JSON currently records `"state": "enabled"`. The restore script correctly overrides this and creates policies in the disabled state, but the source files can still be misunderstood or reused outside the restore workflow.

Microsoft recommends evaluating new Conditional Access policies before enforcement, normally with report-only mode. User Actions policies are an exception because report-only evaluation does not support that scope.

**Recommendation**

- Change the stored policy state to `disabled`, or document the source files explicitly as exported reference state.
- Keep the restore script's forced-disabled behavior.
- Add automated validation that rejects a restore path capable of directly creating enabled policies.

## Tenant-Specific Extensions

These controls can strengthen Zero Trust but should not be added as universal static policies without tenant requirements and dependency validation.

### Authentication context for sensitive resources

Use authentication context to require stronger controls for sensitive applications, privileged actions, protected SharePoint sites, or application-defined high-impact operations. Application integration and context IDs are tenant-specific.

### External-user authentication strength and cross-tenant trust

CA400 provides guest MFA coverage. Organizations with mature cross-tenant collaboration should also define which MFA and device claims are trusted from partner tenants and consider authentication strengths appropriate for external users.

### Compliant network signals

Organizations using Microsoft Entra Internet Access or Microsoft Entra Private Access can evaluate compliant-network signals in Conditional Access. This requires Global Secure Access deployment and should not replace identity, authentication, and device controls.

### Terms of Use

Terms of Use can be required for guests, regulated resources, or acceptable-use scenarios. This is a governance requirement rather than a universal Zero Trust access control.

### Privileged Identity Management

Use Privileged Identity Management for eligible role assignment, approval, justification, time limits, and authentication requirements during activation. Conditional Access protects sign-in and resource access but does not replace privileged-role lifecycle controls.

## Design Risks to Review

### Country allow-list policy

CA001 can be appropriate for organizations with a fixed geographic operating model, but Microsoft does not treat a network location as trusted by itself. Customize the country list, account for travel and emergency scenarios, and retain strong authentication and device controls at approved locations.

### Broad exclusions

Every dedicated exclusion group creates a potential bypass. Keep membership empty by default, require approval and expiry for additions, and monitor changes and sign-ins by excluded accounts.

### Device-property evaluation

Device filters can behave differently when device attributes are unavailable during authentication. Test unmanaged, unregistered, mobile, browser, and desktop-client scenarios before enabling policies that depend on `deviceOwnership`, `isCompliant`, or `mdmAppId`.

### Licensing and unsupported scenarios

Authentication strengths, Identity Protection, Defender for Cloud Apps, Insider Risk, token protection, Global Secure Access, and Workload ID have different licensing and platform limitations. A policy being accepted by Microsoft Graph does not prove that its intended control is enforceable for every application or client.

## Recommended Implementation Order

1. Add the emergency-access exclusion to CA003 and CA101.
2. Expand CA101 to phishing-resistant MFA for administrators at all locations.
3. Expand CA005 device registration or join protection to all locations and verify the tenant device setting.
4. Change stored policy state to report-only or explicitly mark it as export-only state.
5. Inventory workload identities and build tenant-specific location and risk policies.
6. Evaluate authentication context, cross-tenant trust, compliant-network signals, and Terms of Use based on business requirements.
7. Validate changes with report-only mode where supported, sign-in logs, the What If tool, pilot assignments, emergency-access testing, and rollback procedures. Use controlled functional tests for User Actions policies.

## Microsoft Documentation

- [Require phishing-resistant MFA for administrators](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-admin-phish-resistant-mfa)
- [Require MFA for device registration](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-registration)
- [Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity)
- [Manage emergency-access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Conditional Access report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Authentication strengths](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- [Authentication strength for external users](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strength-external-users)
- [Conditional Access authentication context](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps#authentication-context)
- [Enable compliant network checks with Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network)
- [Conditional Access Terms of Use](https://learn.microsoft.com/en-us/entra/identity/conditional-access/terms-of-use)
- [Zero Trust identity and device access policies](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-identity-device-access-policies-overview)
