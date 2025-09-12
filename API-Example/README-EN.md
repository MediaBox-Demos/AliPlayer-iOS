Language: [中文简体](README.md) | English

# **API-Example (iOS)**

ApsaraVideo Player SDK iOS Sample Project

## **📖 Project Overview**

This project is an iOS sample application for the ApsaraVideo Player SDK, developed in Objective-C, aimed at helping developers quickly understand and integrate the core features provided by the SDK.

The project adopts a **plugin-based architecture**, offers excellent **extensibility** and **maintainability**.

## **✨ Feature Highlights**

### **🎯 Single-Function Demonstration Design**

- **Focused on single functions** - Each module demonstrates only one core feature, making it easy to understand and verify quickly.
- **Minimal code implementation** - Only essential logic is retained, eliminating redundant code to improve example readability.
- **Unified access entry** - Supports schema-based routing for decoupled inter-module navigation.

### **🔧 Technical Features**

- **Plugin-based architecture** - Each functional plugin is independently packaged for easier management and reuse.
- **CocoaPods integration** - Plugin management is based on CocoaPods, supporting independent development and testing.
- **Runtime discovery** - Automatically discovers plugins without manual registration, enabling dynamic expansion.
- **Internationalization support** - Supports automatic switching between Chinese and English for multi-language environments.
- **Flexible SDK switching** - Seamlessly switch between different versions of the ApsaraVideo Player SDK.

## **🏗️ Project Architecture**

This project uses a plugin-based structure, with a clear structure and easy scalability:

| Module               | Description                          | Main Functions                                               | Entry File |
| -------------------- | ------------------------------------ | ------------------------------------------------------------ | ---------- |
| **Example**          | Project entrance                     | Initialize and start the main framework of the app           | ViewController |
| **App**              | Main application module              | Application entry point, plugin management, route navigation | AppHomeViewController |
| **Common**           | Common base module                   | Constant definitions, utility classes, SDK headers           | Common.h |
| **BasicPlayback**    | Single-Function demonstration module | Video playback demo, playback controls                       | BasicPlaybackViewController |
| **BasicLiveStream**  | Single-Function demonstration module | Video livestream demo, playback controls                     | BasicLiveStreamViewController |
| **Download**         | Single-Function demonstration module | Video download and offline playback                          | DownloaderViewController |
| **ExternalSubtitle** | Single-Function demonstration module | External subtitle demo and switching                         | ExternalSubtitleViewController |
| **FloatWindow**      | Single-Function demonstration module | Floating window playback                                     | FloatWindowViewController |
| **MultiResolution**  | Single-Function demonstration module | Multi-bitrate/resolution switching                           | MultiResolutionViewController |
| **PictureInPicture** | Single-Function demonstration module | Picture-in-picture playback                                  | PictureInPictureViewController |
| **Preload**          | Single-Function demonstration module | Video preloading (Direct URL/VOD)                            | PreloadViewController |
| **RtsLiveStream**    | Single-Function demonstration module | RTS ultra-low latency live streaming                         | RtsLiveStreamViewController |
| **Thumbnail**        | Single-Function demonstration module | Video thumbnail preview                                      | ThumbnailViewController |

> 📌 The functional modules will be continuously expanded according to business and demonstration needs. The table only lists some representative modules. For more functions, please follow the project's subsequent updates.

## **🔐 License Configuration Instructions**

This project does not include an official license. Please complete the following configuration to enable full functionality.

### ✅ Pre-deployment Setup

1. **Obtain and Integrate License**

   Please refer to the [Bind a license](https://www.alibabacloud.com/help/en/apsara-video-sdk/user-guide/access-to-license) to obtain an authorized SDK license and follow the instructions to integrate it.

2. **Update License Information**

   Open the file `Example/Example/Info.plist` and locate the following lines. Replace them with your own license details:

```xml
	<key>AlivcLicenseKey</key>
	<string>YOUR_LICENSE_KEY</string>
	<key>AlivcLicenseFile</key>
	<string>YOUR_LICENSE_FILE_PATH</string>
```

* **License Key**: Enter the license key string obtained from the console.
* **License File**: Provide the license file name (e.g., `license.crt`) and place this `.crt` file into the `Example/Example/` directory.

> 💡 Tip: Make sure the `.crt` file is correctly added to your Xcode project and included in the build process.

3. **Rebuild and Run the Project**

   After completing the configuration, rebuild and run the project. The SDK will automatically load the license and activate all features.

> **⚠️ Note**: If the license is not configured correctly, player functionality may be limited or unavailable.

## **🚀 Quick Start**

### **🧰 System Requirements**

| Tool      | Version Required |
| --------- | ---------------- |
| Xcode     | 12.0+            |
| iOS       | 9.0+             |
| CocoaPods | 1.10+            |

### **📦 Build and Run**

1. **Downloader the Project**

   ```bash
   git clone [your-repo-url]
   cd API-Example
   ```

2. **Install Dependencies**

   ```bash
   cd Example
   pod install
   ```

3. **Open the Project**

   ```bash
   open Example.xcworkspace
   ```

   > **⚠️ Note**: Always open the project using the `.xcworkspace` file, not the `.xcodeproj`.

4. **Connect Device and Run**

   - Connect an **iOS physical device** via USB and ensure that the developer certificate is trusted on the device.
   - In Xcode, select your target device.
   - Click the Run button (⌘+R), or select `Product` → `Run`.
   - Wait for the app to compile and install on the device.

### **🧪 Verify Results**

After launching the app, you will enter the main menu page. Tap any function item to navigate to the corresponding playback demonstration page.

