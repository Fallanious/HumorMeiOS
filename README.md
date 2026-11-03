# HumorMe native iOS app

SwiftUI show discovery and comedian browsing, with no user accounts or third-party SDK dependencies. The live interface uses teal-and-blush cards, Archivo fonts, and compact orange price pills.

## Open and run

Open `HumorMe.xcodeproj` in Xcode, choose the **HumorMe** scheme, and run on an iPhone simulator. The app uses Apple frameworks only; no Firebase, CocoaPods, Node, or Metro setup is required.

- Minimum deployment target: iOS 16.0.
- Bundle ID: **com.comedy.2.0.0**.
- Signing team: copied from the original iOS target; verify device signing before distribution.
- API URL: `HumorMe/Config.plist` → `HumorMeAPIURL`.

## Features

- Two tabs: Search Shows and Find Comedians.
- Show title/venue/comedian search, multi-city and comedian filters, date ranges and shortcuts, maximum ticket price including zero, price sorting.
- Show details, lineup links, venue addresses, ticket-page links, and native sharing.
- Comedian search, portraits, and upcoming shows.
- Loading, error and empty states; pull to refresh; cancellation of superseded searches.
- Debug-only design gallery via Search Shows → show-count menu → UI Mockups, with clearly labeled illustrative content.

Account screens, authentication, account models, comedian follow/alert controls, user API calls, SDK package references, and the Google service configuration have been removed. The client makes public read-only requests for shows, comedians, and venues. No login or account configuration is necessary.

The former React Native app and server repositories are separate legacy projects. This native-app change does not delete remote account records or deploy changes to those services.

## Validation

```sh
xcodebuild -project HumorMe.xcodeproj -scheme HumorMe \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/humorme-native-no-auth CODE_SIGNING_ALLOWED=NO build

swift test --scratch-path /tmp/humorme-core-tests
```

Seven core tests cover numeric/string/missing prices, free-show filters, date ordering, URL route construction, special characters in names, external URL schemes, HTTP failures, and chronological ordering of show times. The API client uses async URLSession and validates HTTP status.

Before release, verify real-device signing, App Store metadata, privacy declarations, VoiceOver, large text, iPad layout, iOS 16 support, and the complete search/filter matrix. Distance sorting and in-app maps were incomplete in the old app and are not included here.
