# iOpencode

iOS app that runs the [opencode](https://opencode.ai) AI CLI tool via embedded Node.js.

## Prerequisites

- Xcode 15+
- [NodeMobile.framework](https://github.com/cjntjy/nodejs-mobile-ios/releases/tag/v0.3.3) (Node.js 18 for iOS)

## Build

```bash
# Download NodeMobile.framework
./download_node_mobile.sh

# Build unsigned IPA for sideloading
xcodebuild archive \
  -project iOpencode.xcodeproj \
  -scheme iOpencode \
  -destination "generic/platform=iOS" \
  -archivePath build/iOpencode.xcarchive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

The IPA will need to be re-signed by [AltStore](https://altstore.io) or [Sideloadly](https://sideloadly.io) before sideloading.

## How it works

- `NodeMobile.framework` embeds Node.js 18 as a native library
- `iOpencode/NodeBridge.swift` starts Node.js via `node_start()` with stdin/stdout piped to a WKWebView
- `www/terminal.html` renders an xterm.js terminal in the WebView
- `www/index.js` installs `opencodelatest` on first launch (requires network)

## License

MIT
