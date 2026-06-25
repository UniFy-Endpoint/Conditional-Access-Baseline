# Security Info Registration Readiness Guide

This guide defines the operational checks to complete before enabling `CA202` or `CA203` for a user. Use it when onboarding new users, moving users into stronger authentication enforcement, or troubleshooting blocked MFA/security-info registration.

## Scope

Relevant baseline policies:

- `CA006-GLB-SecInfoReg-AnyOS-AnyCli-AnyLoc-ReqAuthStrMFA`
- `CA202-USR-AllApps-AnyOS-ModernCli-UntrustLoc-ReqPwdlessMFA`
- `CA203-USR-AllApps-AnyOS-AnyCli-AnyLoc-ReqPhishMFA`

`CA006` is the bootstrap policy for the `Register security information` user action. `CA202` and `CA203` are normal sign-in enforcement policies and should not be applied to a user until the user can satisfy their required authentication strength.

## Registration Complete Criteria

Mark a user as registration complete only when all applicable checks below are true.

| Check | Required Evidence |
| :--- | :--- |
| User can sign in with baseline MFA | Successful interactive sign-in requiring MFA, or equivalent helpdesk validation |
| User has a passwordless method for `CA202` | Microsoft Authenticator passwordless, FIDO2, Windows Hello for Business, or another method included in the Passwordless MFA strength |
| User has a phishing-resistant method for `CA203` | FIDO2, Windows Hello for Business, or certificate-based authentication, matching the tenant authentication strength configuration |
| User can access Security info | User can open `https://mysignins.microsoft.com/security-info` and view registered methods |
| User no longer needs bootstrap TAP | Temporary Access Pass is expired, revoked, or no longer required for sign-in or registration |
| No blocking CA result is present | Recent sign-in logs show success or expected report-only behavior for the user |

Do not enable or include the user in `CA202` or `CA203` until the required method for that policy is present and tested. If both policies will apply, validate the strongest required method first.

## Operational Steps

1. Create or confirm the user account and licensing.
2. Issue a short-lived Temporary Access Pass if the user has no usable MFA method.
3. Have the user register security information through `https://mysignins.microsoft.com/security-info`.
4. Confirm the user registered the method required by the target policy:
   - For `CA202`, confirm a method allowed by the Passwordless MFA strength.
   - For `CA203`, confirm a phishing-resistant method.
5. Test a fresh sign-in in a private browser session or clean device session.
6. Review sign-in logs for the registration and test sign-in.
7. Remove or let the Temporary Access Pass expire.
8. Add the user to the scope that enables `CA202` and/or `CA203`, or remove the user from the applicable temporary exclusion group.
9. Run a final What If simulation for the user.

## What If Validation

Use the Conditional Access What If tool before enabling `CA202` or `CA203` for the user.

Recommended simulations:

| Simulation | Settings |
| :--- | :--- |
| Security-info registration | User = target user; Cloud app/action = `Register security information`; client app = browser; location = expected onboarding location |
| Normal untrusted sign-in | User = target user; Cloud app = All cloud apps or expected app; client app = modern client/browser; location = untrusted or external |
| Normal trusted sign-in | User = target user; Cloud app = expected app; client app = expected client; location = trusted/corporate, if applicable |

Expected result:

- `CA006` applies to `Register security information`.
- `CA202` and `CA203` do not create an impossible registration path for an unregistered user.
- After registration is complete, the user can satisfy `CA202` and/or `CA203`.
- No unexpected block policy applies.

## Sign-In Log Review

Use Microsoft Entra sign-in logs for both successful and failed attempts.

Recommended filters:

| Filter | Value |
| :--- | :--- |
| User principal name | Target user |
| Application / resource | `My Signins`, `My Profile`, or the app shown during the registration attempt |
| User action | `Register security information`, when available |
| Status | Failure and Interrupted |
| Conditional Access status | Failure, Not applied, Report-only failure |
| Error code | `53003`, `53010`, or other CA/MFA-related errors shown in the failed attempt |
| Time range | Start 30 minutes before the reported failure and include the full onboarding window |

Open each relevant event and review:

- **Conditional Access tab**: policies applied, policies not applied, report-only result, grant controls, and session controls.
- **Authentication details**: method attempted, MFA requirement, and whether authentication strength was satisfied.
- **Device info**: join type, compliance state, platform, browser/client.
- **Location**: named location match, country, IP, and whether the location is trusted.
- **Failure reason and error code**: especially CA block, MFA registration interruption, or auth-strength failure.

If no event appears for the exact registration attempt, check normal interactive sign-ins first, then non-interactive sign-ins around the same timestamp. Also confirm the user reached Microsoft Entra authentication and was not blocked earlier by network, proxy, browser, or device controls.

## Conditional Access Insights

Use the Conditional Access insights and reporting workbook before broad enablement and during pilot rollout.

Recommended workbook review:

| Review | Purpose |
| :--- | :--- |
| Policy filter = `CA006` | Confirm registration policy impact and failures |
| Policy filter = `CA202` | Identify users who would fail Passwordless MFA enforcement |
| Policy filter = `CA203` | Identify users who would fail phishing-resistant MFA enforcement |
| User filter = pilot user/group | Validate onboarding behavior before expansion |
| Result filter = Failure / Report-only failure | Find users that would be blocked |
| Application/resource breakdown | Confirm whether failures are registration, all-app sign-in, or specific app access |
| Device platform/client/location breakdown | Detect patterns such as unmanaged devices, unsupported clients, or unexpected locations |

Keep `CA202` and `CA203` in report-only or scoped pilot mode until the workbook shows the target population can satisfy the required methods.

## Common Failure Patterns

| Symptom | Likely Cause | Action |
| :--- | :--- | :--- |
| User cannot reach MFA registration | User is already in scope for `CA202` or `CA203` without the required method | Complete registration using `CA006` bootstrap flow before enforcing `CA202`/`CA203` |
| Error `53003` | A Conditional Access policy blocked token issuance | Open the sign-in event and identify the blocking policy on the Conditional Access tab |
| Error `53010` or registration interruption | Registration action is blocked or cannot satisfy required controls | Run What If with `Register security information`; verify CA006 and authentication strength configuration |
| No useful sign-in log appears | Attempt may not have reached Entra sign-in logging, or the wrong log category/time range is selected | Expand time range, check interactive and non-interactive logs, and verify browser/network path |
| User can register but later cannot sign in | Registered method does not satisfy `CA202` or `CA203` | Compare the user's method with the allowed combinations in the target authentication strength |

## Completion Record

Record this information before enabling `CA202` or `CA203` for the user:

| Field | Value |
| :--- | :--- |
| User | |
| Registration date/time | |
| Registered passwordless method | |
| Registered phishing-resistant method | |
| TAP expired/revoked | |
| What If result reviewed | |
| Sign-in log event IDs reviewed | |
| CA Insights workbook reviewed | |
| Approved for `CA202` | |
| Approved for `CA203` | |

## References

- Microsoft Learn: Conditional Access What If tool - https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool
- Microsoft Learn: Conditional Access insights and reporting workbook - https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-insights-reporting
- Microsoft Learn: Troubleshoot sign-in problems with Conditional Access - https://learn.microsoft.com/en-us/entra/identity/conditional-access/troubleshoot-conditional-access
- Microsoft Learn: Targeting resources and user actions in Conditional Access - https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps
