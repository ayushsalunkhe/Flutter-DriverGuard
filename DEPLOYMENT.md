# Deployment Guide

## 🤖 Android (Windows/Mac/Linux)
Deploying to Android is straightforward and can be done entirely from Windows.

### Option 1: Direct Run (Development)
1.  Enable **Developer Mode** & **USB Debugging** on your Android phone.
2.  Connect via USB.
3.  Run:
    ```bash
    flutter run --release
    ```

### Option 2: Sideloading (APK Share)
You can generate an APK file and send it via WhatsApp, Drive, etc.
1.  Build the APK:
    ```bash
    flutter build apk --release
    ```
2.  Locate the file:
    `build\app\outputs\flutter-apk\app-release.apk`
3.  Transfer this file to your phone and tap to install.

---

## 🍎 iOS (Mac Required)
⚠️ **Note**: You **cannot** build or deploy iOS apps from Windows. Apple requires Xcode (macOS).

### Why can't I sideload an `.ipa` file?
Unlike Android, iOS does not allow you to simply install an app file sent via WhatsApp/download.
1.  **Code Signing**: Every iOS app must be signed by an Apple Developer Certificate.
2.  **Provisioning**: The app must be whitelisted for your specific device (UDID).
3.  **Compiler**: The iOS binary can only be compiled on macOS.

### If you have a Mac:
1.  Open `ios/Runner.xcworkspace` in Xcode.
2.  Sign in with your Apple ID.
3.  Select your connected iPhone as the target.
4.  Click **Run**.

### Workarounds (Advanced)
If you do not have a Mac, you must use a cloud builder (like Codemagic) to generate the `.ipa`, and then use complex tools like **AltStore** on Windows to sign and install it. This is generally not recommended for casual testing.
