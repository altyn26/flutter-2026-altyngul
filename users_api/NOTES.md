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