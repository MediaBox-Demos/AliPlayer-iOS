Language: [中文简体](README.md) | English

# **amdemos-ios-player**

Aliyun Video Cloud Player SDK Sample Code

## **🔐 License Configuration Instructions**

This project does not include an official license. Please complete the following configuration to enable full functionality.

### **✅ Pre-deployment Setup**

1. **Obtain and Integrate License**

   Please refer to the [Bind a license](https://www.alibabacloud.com/help/en/apsara-video-sdk/user-guide/access-to-license) to obtain an authorized SDK license and follow the instructions to integrate it.

2. **Update License Information**

   Open the file `Example/AlivcPlayerDemo/Info.plist` and locate the following lines. Replace them with your own license details:

```xml
	<key>AlivcLicenseKey</key>
	<string>YOUR_LICENSE_KEY</string>
	<key>AlivcLicenseFile</key>
	<string>YOUR_LICENSE_FILE_PATH</string>
```

* **License Key**: Enter the license key string obtained from the console.
* **License File**: Provide the license file name (e.g., `license.crt`) and place this `.crt` file into the `Example/AlivcPlayerDemo/` directory.

> 💡 Tip: Make sure the `.crt` file is correctly added to your Xcode project and included in the build process.

3. **Rebuild and Run the Project**

   After completing the configuration, rebuild and run the project. The SDK will automatically load the license and activate all features.

> **⚠️ Note**: If the license is not configured correctly, player functionality may be limited or unavailable.

------

## **Short Drama Demo Source Code Announcement**

This version is the old Short Drama Scenario Demo source code released before October 2024. Alibaba Cloud officially released the latest version of the "Micro-Drama Scenario Multi-Instance Demo" in February 2025, which includes the complete source code. Compared with the old version, the new Demo features higher integration ease of use, smoother playback experience, and achieves the optimal balance in playback performance and user experience.

The old version of the Short Drama Scenario Demo source code in the current directory is no longer updated or maintained. If you need to obtain the latest "Micro-Drama Scenario Multi-Instance Demo," please purchase the Professional Player License first and submit a ticket to contact us for the Demo source code. For details, see:

[Integrate the Latest "Micro-Drama Scenario Multi-Instance Demo"](https://help.aliyun.com/zh/vod/use-cases/micro-drama-integration-ios-player-sdk?spm=a2c4g.11186623.help-menu-29932.d_3_0_0_1_1.6afd523cYfdJM7)

[Obtain the Player SDK Professional License](https://help.aliyun.com/zh/vod/developer-reference/obtain-the-player-sdk-license?spm=a2c4g.11186623.help-menu-search-29932.d_15)

------

## **Code Structure**

```
├── Root Directory                            // Demo root directory
│   ├── AUIPlayerMain                        // Demo shell component code
│   ├── AUIVideoFlow                         // Video feed playback, full-screen playback component code
│   ├── AUIPlayer.podspec                    // Local podspec file
│   ├── Example                              // Sample code project
│   ├── README.md                            // Readme   
```

## **Environment Requirements**

- Xcode 12.0 or later (latest stable version recommended)
- CocoaPods 1.9.3 or later
- iOS device running iOS 10.0 or above

## **Prerequisites**

To obtain the SDK license and key, playback authorization is required.
 Refer to [Get License](https://help.aliyun.com/zh/vod/developer-reference/license-authorization-and-management).

## **Running the Example Demo**

1. After downloading the source code, unzip and enter the `AlivcPlayerDemo` directory.
2. Modify the player SDK version in the Podfile to the latest version. For the version number, refer to [iOS Player SDK](https://help.aliyun.com/zh/vod/developer-reference/release-notes-for-apsaravideo-player-sdk-for-ios).
3. In the `Example` directory, run `pod install --repo-update` to automatically install the dependent SDK.
4. Open the project file `AlivcPlayerDemo.xcworkspace` and modify the bundle ID.
5. Apply for a trial license in the console to get the license file and license key (or use an existing one).
6. Place the license file in the `AlivcPlayerDemo/` directory and rename it to `license.crt`.
7. Copy the “LicenseKey” (if you don’t have it, copy it from the console), open `AlivcPlayerDemo/Info.plist`, and fill it in the `AlivcLicenseKey` field.
8. Build and run on a physical iOS device.
