# Zero Trust Conditional Access Assessment

Assessment date: June 11, 2026

## Executive Summary

This baseline provides strong coverage of Microsoft's common Conditional Access controls for workforce users, administrators, guests, managed devices, unmanaged-device access, identity risk, session enforcement, legacy authentication, and authentication flows.

The baseline is substantial, but it is not a complete Microsoft Zero Trust Conditional Access implementation because several controls require tenant-specific identities, applications, networks, licensing, and governance decisions.

Conditional Access for workload identities remains the highest-priority uncovered area. Workload-identity policies require tenant-specific service-principal and network information, so they should be implemented as documented extensions or generated templates rather than universal static policies.

The repository validator checks policy state, emergency exclusions, filenames, group references, migration metadata, required CA005 and CA101 controls, JSON syntax, and PowerShell syntax.

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

## Open Gap

### Conditional Access for workload identities

**Status:** Not included in this baseline; tenant administrator action required

Conditional Access policies for workload identities are intentionally not included in the baseline policy JSON files. The current policies target users and guests, and user-scoped Conditional Access policies do not protect service-principal token requests.

A Conditional Access Administrator must configure workload-identity policies directly in each tenant based on the tenant's service principals, approved public IP ranges, service-principal risk tolerance, licensing, and operational dependencies.

Microsoft supports workload-identity policies that block selected service principals:

- Outside known public IP ranges.
- When Microsoft Entra detects service-principal risk.
- In scenarios integrated with authentication context.

**Tenant configuration**

- Inventory service principals, credentials, owners, permissions, sign-in locations, and business criticality.
- Prefer managed identities where supported.
- Sign in to the Microsoft Entra admin center as at least a Conditional Access Administrator.
- Go to **Entra ID > Conditional Access > Policies > New policy**.
- Under **Users or workload identities**, select **Workload identities** and directly select the required service principals.
- Under **Target resources**, include **All resources**.
- For a location-based policy, include **Any location**, exclude only named locations containing approved public IP ranges, and select **Block access**.
- For a risk-based policy, configure **Service principal risk**, select the risk levels that should trigger the policy, and select **Block access**.
- Start in report-only mode and review **Entra ID > Monitoring & health > Sign-in logs > Service principal sign-ins** before enforcement.

**Limitations and prerequisites**

- These policies aren't suitable as universal static JSON because service-principal object IDs and approved network locations are tenant-specific.
- Microsoft Entra Workload ID Premium licensing is required to create or modify them.
- Policies apply to selected single-tenant service principals owned by the organization.
- Managed identities, Microsoft applications, third-party SaaS applications, and multitenant applications aren't covered.
- Service principals must be assigned directly. Assignment through a group containing service principals isn't enforced.
- Use the service principal Object ID from **Enterprise applications**, not the application-registration object ID.
- Block access is the available grant control because workload identities can't perform MFA.
- Prefer managed identities or workload identity federation where supported to reduce stored credentials.

## Tenant Deployment Prerequisites

These actions remain the responsibility of each tenant administrator:

- Register targeted administrators for phishing-resistant methods such as passkeys, Windows Hello for Business, or certificate-based authentication before enabling CA101.
- Set `Require Multifactor Authentication to register or join devices with Microsoft Entra` to `No` so CA005 controls the device-registration MFA requirement.
- Test CA005 with controlled device-registration scenarios because report-only evaluation doesn't support User Actions policies.
- Maintain at least two cloud-only emergency-access accounts with independent phishing-resistant credentials.
- Alert on every emergency-access sign-in and test the accounts regularly.
- Review all policies in report-only mode where supported before enforcement.

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

1. Complete the tenant deployment prerequisites.
2. Inventory workload identities and build tenant-specific location and risk policies.
3. Evaluate authentication context, cross-tenant trust, compliant-network signals, and Terms of Use based on business requirements.
4. Validate changes with report-only mode where supported, sign-in logs, the What If tool, pilot assignments, emergency-access testing, and rollback procedures. Use controlled functional tests for User Actions policies.

## Microsoft Documentation

- [Require phishing-resistant MFA for administrators](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-admin-phish-resistant-mfa)
- [Require MFA for device registration](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-registration)
- [Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity)
- [Workload identities overview](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview)
- [Network conditions in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network)
- [Manage emergency-access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Conditional Access report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Authentication strengths](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- [Authentication strength for external users](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strength-external-users)
- [Conditional Access authentication context](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps#authentication-context)
- [Enable compliant network checks with Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network)
- [Conditional Access Terms of Use](https://learn.microsoft.com/en-us/entra/identity/conditional-access/terms-of-use)
- [Zero Trust identity and device access policies](https://learn.microsoft.com/en-us/security/zero-trust/zero-trust-identity-device-access-policies-overview)
