# iOpencode

iOpencode is a mobile application that brings the power of OpenCode to your iOS device. It provides a terminal interface where you can run OpenCode commands directly on your iPhone or iPad.

## Features

- Full terminal interface with Xterm.js
- Integration with OpenCode CLI
- Ability to run Node.js scripts
- Access to your local workspace
- Customizable terminal appearance

## Requirements

- iOS 17.0 or later
- Xcode 14.0 or later (for building)
- Node.js runtime (included via NodeMobile.framework)

## Installation

To install iOpencode on your device:

1. Clone this repository
2. Open `iOpencode.xcodeproj` in Xcode
3. Connect your iOS device
4. Select your device as the build target
5. Click the Run button in Xcode

## How It Works

iOpencode uses a WKWebView to display a terminal interface powered by Xterm.js. The terminal communicates with a Node.js process running in the background through Swift code that bridges the web view and the Node.js environment.

When you type commands in the terminal, they are sent to the Node.js process which executes them using the OpenCode CLI. The output is then sent back to the web view to be displayed in the terminal.

## Building the IPA

An automated GitHub Actions workflow is set up to build the IPA file:

1. The workflow triggers on pushes to the main branch or manual dispatch
2. It downloads the required NodeMobile.framework
3. It builds the app using xcodebuild
4. It exports the app as an IPA file
5. The IPA is uploaded as an artifact

## Customization

You can customize the terminal appearance by modifying the CSS in `www/terminal.html`.

## Troubleshooting

If you encounter a black screen when launching the app:

1. Ensure that the www folder files (terminal.html, index.js, package.json) are properly included in the app bundle
2. Check that NodeMobile.framework is correctly linked and embedded
3. Verify that the Info.plist has the necessary permissions for local networking
4. Look at the Xcode console for any error messages during launch

## License

This project is open source and available under the MIT License.