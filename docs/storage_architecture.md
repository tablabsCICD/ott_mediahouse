# Media House Portal storage architecture

Migration version: **1**. Hive adapter type ID: **41** (`PortalCacheEntry`).

SharedPreferences contains only non-sensitive preferences and migration markers.
During the first migration release, the legacy authentication keys remain as a
fallback so an Android upgrade does not force a logout. Secure values are read
first, migrated independently, read back for verification, and migration is
safe to rerun. Logout removes both new and legacy authentication locations.

Hive is a disposable cache. Every protected record uses
`userId:mediaHouseId:dataType:queryHash`, UTC timestamps, schema validation,
TTL, and a 50-entry per-box bound. Bank/KYC fields, authorization state,
passwords, OTPs, uploaded bytes, local upload paths, and signed document URLs
must not be included in payloads.

| Box | Default TTL |
|---|---:|
| `mh_dashboard_cache_v1` | 3 minutes |
| `mh_transaction_cache_v1` | 2 minutes |
| `mh_settlement_cache_v1` | 2 minutes |
| `mh_notification_cache_v1` | 1 minute |
| `mh_profile_cache_v1` | 10 minutes |
| `mh_support_cache_v1` | 3 minutes |
| `mh_lookup_cache_v1` | 24 hours |

Android backup is disabled because encrypted secure-storage values cannot be
reliably restored without their original encryption key. The application ID
and signing configuration are unchanged.

On Web, `flutter_secure_storage` encrypts values in browser storage, but this is
not equivalent to an HttpOnly cookie because JavaScript running in the origin
can access the application. The existing token contract is retained for this
release. The backend should add an HttpOnly, Secure, appropriately SameSite
cookie session before browser tokens can be removed. Multi-tab logout also
requires a server-side session revocation endpoint or a cross-tab logout event.

The backend remains authoritative for identity, ownership, permissions,
settlements, transactions, documents, KYC, and financial values. Cached
identity may only be a display hint and must be revalidated before protected
requests.
