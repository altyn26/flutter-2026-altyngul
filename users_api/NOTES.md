#Practice 11 - NOTES

## GET /users
- Status: 200 OK, Content-Type: application/json; charset=utf-8
- 10 users (a JSON array)
- Nested objects: address, company. Nested twice: address.geo
- No null fields in the real data; website is treated as optional (String?)

### User
| field    | JSON type | Dart type                           | nullable? |
|----------|-----------|-------------------------------------|-----------|
| id       | number    | int                                 | no        |
| name     | string    | String                              | no        |
| username | string    | String                              | no        |
| email    | string    | String                              | no        |
| address  | object    | Address                             | no        |
| phone    | string    | String                              | no        |
| website  | string    | String?                             | yes (treated as optional) |
| company  | object    | ({String name, String catchPhrase}) | no        |

### Address
| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### Geo
| field | JSON type | Dart type             | nullable? |
|-------|-----------|-----------------------|-----------|
| lat   | string    | double (double.parse) | no        |
| lng   | string    | double (double.parse) | no        |

### Company
| field       | JSON type | Dart type      | nullable? |
|-------------|-----------|----------------|-----------|
| name        | string    | String         | no        |
| catchPhrase | string    | String         | no        |
| bs          | string    | — (not stored) | no        |

## Statuses
- GET /users/999 → 404 Not Found, body: `{}`
- POST /users (Content-Type: application/json) → 201 Created; the server returns what I sent plus `"id": 11`
- With a typo in Content-Type the server still answers 201, but ignores the body and returns only `{"id": 11}`
- GET /users?id=3 → 200 OK, a list of one user `[ {...} ]`, not an object

## No-network timings
- Airplane mode → Offline view after: ~0.4 s
- Wi-Fi without internet → Offline view after:21 s (the OS connect timeout) — without .timeout() the spinner would spin for 21 s

## grep "package:http"
- api_client.dart, user_repository.dart — the network layer
- main.dart — the composition root: the only place that creates http.Client() (as the brief requires); no screen or model imports http


## Caret and pubspec.lock
- pubspec.yaml says http: ^1.6.0; pub resolved it to exactly 1.6.0 (see pubspec.lock).
- ^1.6.0 accepts >=1.6.0 <2.0.0: 1.6.1, 1.7.0, 1.9.9 would all be fine.
- It refuses 1.5.x and older (below the minimum I tested against) and 2.0.0+ (a new major version may break the API).
- pubspec.lock is committed for an app so that every machine and every CI build gets exactly the same versions as mine; libraries do not commit it because their users resolve their own versions.

- Experiment: I changed http: ^1.6.0 to http: 1.6.0 (no caret) and ran flutter pub get and flutter pub outdated. Nothing changed in the table, because 1.6.0 is already the latest http. The difference would appear when 1.6.1 is released: ^1.6.0 would accept it, but the pinned 1.6.0 would block it. I restored the caret.

## pub outdated
- cupertino_icons is locked at 1.0.9, and 2.0.0 is available (Resolvable and Latest columns). I did not upgrade it because my constraint ^1.0.8 does not allow a new major version, and a major version can have breaking changes. Upgrading would mean editing pubspec.yaml by hand (or running flutter pub upgrade --major-versions) and checking the changelog first. The app barely uses it, so there is no reason to risk it now.
- Other packages in the list (meta, hooks, objective_c, ...) are transitive: I did not choose them, and they can be upgraded safely with flutter pub upgrade, because their constraints already allow it.

## Package verdicts
1. shared_preferences 2.5.6: verified publisher flutter.dev (Flutter Favorite),released 49 days ago, all six platforms (Android, iOS, Linux, macOS, web, Windows), 160 pub points, BSD-3-Clause, depends only on Flutter and its own per-platform implementation packages.

2. flutter_secure_storage 11.2.0: verified publisher steenbakker.dev, released 2 months ago, all six platforms (Android, iOS, macOS, Windows, Linux, web), 160 pub points, BSD-3-Clause, depends only on Flutter, meta and its own per-platform implementation packages.

3. path_provider 2.1.6: verified publisher flutter.dev, released 5 months ago, five platforms (Android, iOS, Linux, macOS, Windows; no web), 160 pub points, BSD-3-Clause, depends only on Flutter and its own per-platform implementation packages.

4. image_picker 1.2.4: verified publisher flutter.dev, released 49 days ago, all six platforms (Android, iOS, Linux, macOS, web, Windows; camera on desktop needs a custom delegate), 160 pub points, Apache-2.0 and BSD-3-Clause, depends on Flutter and its own per-platform implementation packages. README notes that photos taken with the camera are saved only in a temporary cache, so I 
must copy them to a permanent location myself.

5. permission_handler 13.0.2: verified publisher baseflow.com (a third-party company, not flutter.dev), released 2 months ago, four platforms (Android, iOS, web, Windows; no Linux/macOS), 160 pub points, MIT, depends on Flutter, meta and its own per-platform implementation packages. README warns that on iOS a missing Info.plist entry kills the app as soon as the permission is checked, and that on Android status never returns permanentlyDenied, only request() does.

6. url_launcher 6.3.3: verified publisher flutter.dev, released 52 days ago, all six platforms (Android, iOS, Linux, macOS, web, Windows), 160 pub points, BSD-3-Clause, depends on Flutter and its own per-platform implementation packages. README says canLaunchUrl can return false even when launchUrl would work, so I call launchUrl directly and check the returned bool.


## Level 2: why read settings in main()
- I read darkMode and cityFilter in main() before runApp, so the first frame already has the right theme.
- Experiment: I moved the read into the SettingsModel constructor with a default of false. The app showed one light frame and then switched to dark. That flash is the reason the read happens before runApp. I restored the original order.

## Where the token lives
- prefs.setString('token', ...) would store it in a plain, unencrypted file inside the app's data folder (an XML file on Android, a plist on iOS). Anyone with a backup, a rooted/jailbroken phone or a debug cable can read it. flutter_secure_storage uses the Keychain (iOS) and encrypted storage with a key in the Android Keystore, so the file alone is useless.
- Surprise 1 (iOS): Keychain items can survive deleting the app, so after a reinstall the old token may still be there.
- Surprise 2 (Android): Android auto backup can restore the encrypted data onto a device without the key, which throws "Failed to unwrap key"; the fix is android:allowBackup="false".
- Verified in DevTools → Network: the users request carries "Authorization: Bearer tok_...", and it disappears after Sign out.

## Level 4: Documents vs Temporary
- The cache file lives in getApplicationDocumentsDirectory(), because Documents is meant to keep data until the user deletes the app; Temporary may be cleared by the OS at any time.
- Offline logic: on NoConnectionException the repository returns the saved list with fromCache = true; if there is no saved file it rethrows, so the user sees the honest Offline screen and not an empty list.
- Verified on the Android emulator: loaded the list online, turned on airplane mode, killed the app, reopened it: the ten users appear immediately with the "Saved data · no connection" banner. Retry in airplane mode keeps the banner; with the network back, Retry removes it.
- On the slow emulator the first request hit the 10 s timeout, which is mapped to NoConnectionException and showed the Offline screen, as designed.

## Level 5: permissions
- Android (emulator, API 35): the system dialog appeared <N> time(s); after that request() returned permanentlyDenied immediately and my own dialog "Camera access is turned off" with "Open settings" appeared. "Open settings" opens the app's permission page; after allowing the camera there, Take photo opens the camera.
- iOS (not tested, no Mac): the system dialog appears only once. After one "Don't Allow" permission_handler reports permanentlyDenied and the only way back is openAppSettings(). The fourth Photos state is called limited (the user shared only selected photos).
- launchUrl(Uri.parse('kbtu.edu.kz')) without a scheme returned false and nothing opened; with https:// the browser opens. I check the bool and show "No app can open this".
- The camera photo is copied to Documents/avatar.jpg because image_picker keeps camera photos only in a temporary cache; the path is stored in shared_preferences, so the photo survives a restart.