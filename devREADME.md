# Developing on IVAS Messenger UI iOS

Provides a UI to interface with IVAS Messenger.

## Build

To build and run the demo project included, [Xcode](https://developer.apple.com/xcode/resources/) must be installed.

Open the bundled demo project with Xcode to run, located here: [MessengerUIDemo/MessengerUIDemo.xcodeproj](MessengerUIDemo/MessengerUIDemo.xcodeproj)

## Test

Unit tests can be run via Xcode by opening the package at the root level.

Tests can also be run via command line using `xcodebuild`:

```bash
xcodebuild -scheme ivas-messenger-ui-ios test -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```