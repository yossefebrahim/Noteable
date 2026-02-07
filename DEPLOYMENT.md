# Noteable Deployment Setup

## App metadata
- App Name: `Noteable`
- Bundle/Application ID: `com.noteable.app`
- Version source: `pubspec.yaml` (`1.0.0+1`)

## iOS signing (development)
- Xcode project is configured with **Automatic signing**.
- Team ID is set in `ios/Runner.xcodeproj/project.pbxproj`.
- Bundle ID: `com.noteable.app`.

## Android signing
- Debug signing uses local debug keystore by default.
- Release signing reads `android/key.properties` when available, otherwise falls back to debug signing.

`android/key.properties` format:

```properties
storePassword=***
keyPassword=***
keyAlias=***
storeFile=upload-keystore.jks
```

## GitHub Secrets required for CI/CD

### Android (Internal Test Track)
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

### iOS (TestFlight)
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY` (base64 `.p8` content)
- `APPLE_ID`
- `APPLE_DEVELOPER_TEAM_ID`
- `APP_STORE_CONNECT_TEAM_ID`

## Workflows
- `.github/workflows/ci.yml`: analyze, tests, debug Android/iOS builds
- `.github/workflows/deploy-beta.yml`: deploy Android Internal + iOS TestFlight on tags/manual dispatch
