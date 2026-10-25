# Changelog

## v1.5.0 (October 2026) - Restructure into packs (54 -> 43 policies)

The baseline went from 54 to 43 policies to make it easier to implement and manage: related policies are merged, overlapping and redundant policies are removed, and everything that needs an extra licence or a customer decision is separated into packs.

**Structure**
- Policies are grouped into packs: **Essential** (10), **Hardening** (19) and **Add-on** (14, separate `ConditionalAccess/AddOn/` folder). Core = Essential + Hardening = 29 policies for Microsoft 365 Business Premium (Entra ID P1).
- Deployment state: every policy is deployed Off. The catalog gives a recommended first step per policy (Report-only for low-impact policies, Off until agreed for everything that needs a customer decision, user-action policies and continuous access evaluation).

**Administrator roles**
- One standard list of 40 roles (35 built-in roles that Microsoft marks as privileged, plus Exchange, SharePoint, Teams, Billing and Groups Administrator), identical in every policy that includes or excludes admin roles.
- New privileged roles added: Entra SOC Identity Responder, Partner Tier1 Support, Partner Tier2 Support, Tenant Governance Administrator, Groups Administrator.
- Sync roles: only `Directory Synchronization Accounts`, and only on policies that could stop directory synchronization.

**Policies merged or removed**
- CA004 now blocks device code flow and authentication transfer (CA007 merged).
- Guest MFA is its own policy, CA301. CA201 covers members only (guests and external users are excluded there), so each audience has its own exclusion group and rollout.
- Compliance and app protection stay separate per mobile platform: CA209 (iOS) and CA210 (Android) for compliance, CA213 (Android) and CA214 (iOS) for app protection, so a customer that uses only one platform can enable only that policy.
- CA216 covers Windows and macOS token protection (CA218 merged).
- Removed: CA102 (passwordless admins, covered by CA101/CA103), CA202, CA105, CA206, CA303, CA406 (separate CAE policies replaced by CA009), old CA301 (MFA for service accounts).
- Audience ranges changed: guests now use 3xx (CA301 guest MFA, CA302 app allow-list block, CA303 session limits, CA304 application-enforced restrictions; previously CA401, CA402, CA404, CA405) and the single service-account policy is CA401 (previously CA302/CA301). The restore script renames existing policies and groups in place.
- CA005 and CA006 merged into CA005 (`RegDevSecInfo`): one user-action policy for registering or joining devices and registering security information, using the Temporary Access Pass authentication strength.
- CA008 (Linux block) merged into CA002: unsupported platforms and Linux are blocked (the baseline covers Windows, macOS, iOS and Android; a customer that needs Linux uses the CA002 exclusion group together with the Add-on policy CA211).
- CA403 merged into CA204: one admin-portal block for non-administrator users and guests; service provider users are excluded.
- Linux compliance (CA211) is an optional Add-on policy: platform Linux, all resources, require compliant device, own `-EXCL` group, deployed Off. Deploy it when users are exempted from CA002.
- CA504 merged into CA501 (sign-in risk medium and high) and CA505 merged into CA502 (user risk medium and high).

**New**
- CA009: global continuous access evaluation (strict location) for users and administrators.
- CA219 (Add-on): Defender for Cloud Apps download block, replacing the session control in CA212-CA215.
- `CA000-GLB-ADM-ServiceProvider-Admins-EXCL`: shared group for privileged service provider administrators, excluded only from CA106 and CA216.

**Renamed for clarity**
- Shorter, clearer names: CA004 (`DevCodeAuthTransf`), CA103 and CA501 (`ReqPhishResMFA`), CA104, CA205 and CA303 (`SignInFrqPersistSess`), CA217 (`IntuEnrl-...-Always`). The restore script renames existing objects in place.

**Changed**
- CA203 now uses the Passwordless MFA strength (accepts phishing-resistant methods too); CA103 stays Phishing-resistant MFA. Raise CA203 to Phishing-resistant MFA when users are ready.
- CA104 sign-in frequency is 12 hours.
- CA212, CA213, CA214, CA215: Defender for Cloud Apps control moved to CA219.
- Removed feature-specific app references (Azure Virtual Desktop, Windows 365, AADReporting, Edge Sync, Microsoft Account Controls V2) so policies do not depend on service principals that may not exist.
- `MigrationTable.json` rebuilt from the group files; stale group names fixed.
- README and SETTINGSOUTPUT regenerated from the JSON files.

**Script**
- The rename map and the baseline-number matching apply only when the restore folder is this baseline (BaselineId in MigrationTable.json). Backups from other tenants are matched by exact display name only. The number-based match also requires the same audience code.
- Folder layout: policies are in ConditionalAccess/Core and ConditionalAccess/AddOn; groups, named locations and authentication strengths are shared at the root. The restore script asks which pack to restore.
