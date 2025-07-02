Language: [中文简体](README.md) | English

# **Swift-Call-OC-Example**

Swift Calling Objective-C Module Example Project

## **📖 Project Overview**

This project is an example project for Swift calling Objective-C modules, developed in Swift, aimed at helping developers quickly understand and master Swift and Objective-C mixed programming techniques.

The project adopts a **minimalist design** with good **readability** and **maintainability**.

## **✨ Features**

### **🎯 Minimalist Demo Design**
- **Direct Launch to OC Interface** - The app launches directly into the Objective-C homepage without intermediate pages.
- **Minimalist Code Implementation** - Only core bridging logic is retained, removing redundant code to improve example readability.
- **Dynamic Class Creation** - Uses `NSClassFromString` to implement Swift dynamic calling of OC classes.

### **🔧 Technical Features**
- **Bridging Header Configuration** - Standard Swift-OC bridging header file with support for bilingual comments.
- **CocoaPods Integration** - Local dependency management based on CocoaPods, supporting modular development.
- **Error Handling Mechanism** - Comprehensive error handling that displays friendly prompts when OC classes cannot be found.
- **iOS 11.0+ Compatibility** - Full support for iOS 11.0 and above, using traditional AppDelegate pattern.
- **Streamlined Permission Configuration** - Only includes necessary network and file access permissions.

## **🏗️ Project Architecture**

The current project adopts a minimalist organization approach with the following main components:

| Component                         | Description              | Main Functions                     |
| --------------------------------- | ------------------------ | ---------------------------------- |
| **AppDelegate.swift**             | Swift app entry point    | Direct launch to OC interface, error handling |
| **SwiftExample-Bridging-Header.h** | Swift-OC bridging header | Import OC modules, type bridging   |
| **Podfile**                       | Dependency management    | Manage API-Example local dependencies |
| **Info.plist**                    | App configuration file   | Permission configuration, app info |

>  📌 This project focuses on demonstrating core Swift-to-OC calling techniques and can serve as a foundation template for mixed programming projects.

## **🔗 Dependency Relationship**

This project depends on Objective-C modules in the API-Example project, integrated through CocoaPods local path dependencies.

### 📁 Required Directory Structure

```
AliPlayer-iOS/
├── API-Example/          # Objective-C example project
│   ├── App/
│   ├── Common/
│   └── BasicPlayback/
└── Swift-Call-OC-Example/  # This Swift project
    ├── SwiftExample/
    ├── Podfile
    └── README.md
```

> **⚠️ Note**: Please ensure the API-Example project is located in the same directory as this project, otherwise CocoaPods cannot find local dependencies.

## **🔐 License Configuration Instructions**

This project does not include an official license. Please complete the following configuration to enable full functionality.

### ✅ Pre-deployment Setup

1. **Obtain and Integrate License**

   Please refer to the [Bind a license](https://www.alibabacloud.com/help/en/apsara-video-sdk/user-guide/access-to-license) to obtain an authorized SDK license and follow the instructions to integrate it.

2. **Update License Information**

   Open the file `SwiftExample/Info.plist` and locate the following lines. Replace them with your own license details:

```xml
	<key>AlivcLicenseKey</key>
	<string>YOUR_LICENSE_KEY</string>
	<key>AlivcLicenseFile</key>
	<string>YOUR_LICENSE_FILE_PATH</string>
```

* **License Key**: Enter the license key string obtained from the console.
* **License File**: Provide the license file name (e.g., `license.crt`) and place this `.crt` file into the `SwiftExample/` directory.

> 💡 Tip: Make sure the `.crt` file is correctly added to your Xcode project and included in the build process.

3. **Rebuild and Run the Project**

   After completing the configuration, rebuild and run the project. The SDK will automatically load the license and activate all features.

> **⚠️ Note**: If the license is not configured correctly, player functionality may be limited or unavailable.

## **🚀 Quick Start**

### **🧰 Environment Requirements**

| Tool        | Version Required |
| ----------- | ---------------- |
| Xcode       | 13.0+            |
| iOS         | 11.0+            |
| Swift       | 5.0+             |
| CocoaPods   | 1.10+            |

### **📦 Build and Run**

1. **Verify Directory Structure**

   ```bash
   # Ensure correct directory structure
   ls -la
   # You should see both API-Example and Swift-Call-OC-Example directories
   ```

2. **Install Dependencies**

   ```bash
   cd Swift-Call-OC-Example
   pod install
   ```

3. **Open Project**

   ```bash
   open SwiftExample.xcworkspace
   ```

   > **⚠️ Note**: Please use the `.xcworkspace` file to open the project, not the `.xcodeproj` file.

4. **Connect Device and Run**
   
   - Connect an **iOS physical device** via USB and ensure the device trusts the developer certificate
   - Select the target device in Xcode
   - Click the run button (⌘+R) or select `Product` → `Run`
   - Wait for the app to compile and install on the device

### **🧪 Verification Results**

After the app launches, it will directly enter the Objective-C AppHomeViewController interface, proving that Swift successfully called the OC module.

## **🔧 How to Implement Bridging**

### **Step 1: Create Bridging Header File**

Create a bridging header file `SwiftExample-Bridging-Header.h` in the Swift project:

```objc
#ifndef SwiftExample_Bridging_Header_h
#define SwiftExample_Bridging_Header_h

// Import OC header files needed in Swift
#import <App/App.h>
#import <Common/Common.h>
#import <BasicPlayback/BasicPlayback.h>

#endif /* SwiftExample_Bridging_Header_h */
```

### **Step 2: Configure Xcode Project**

Configure the bridging header file path in Xcode project settings:

1. Select project Target
2. Go to `Build Settings`
3. Search for `Objective-C Bridging Header`
4. Set path to: `SwiftExample/SwiftExample-Bridging-Header.h`

### **Step 3: Call OC Classes in Swift**

Use OC classes directly in Swift code:

```swift
// Method 1: Direct use (if already imported in bridging header)
let homeVC = AppHomeViewController()

// Method 2: Dynamic creation (recommended for optional dependencies)
if let vcClass = NSClassFromString("AppHomeViewController") as? UIViewController.Type {
    let homeVC = vcClass.init()
    homeVC.title = "App Home"
    // Use OC controller
}
```

### **Step 4: Configure CocoaPods Dependencies**

Add local dependencies in `Podfile`:

```ruby
platform :ios, '11.0'

target 'SwiftExample' do
  use_frameworks!
  
  # Local dependencies for API-Example modules
  pod 'App', :path => '../API-Example'
  pod 'Common', :path => '../API-Example'
  pod 'BasicPlayback', :path => '../API-Example'
end
```

### **Key Technical Points**

1. **Bridging Header File**: Swift compiler understands OC class interfaces through the bridging header file
2. **Dynamic Class Creation**: `NSClassFromString` allows runtime dynamic acquisition of OC classes
3. **Type Conversion**: Convert OC classes to Swift-usable types
4. **Error Handling**: Check if classes exist and provide friendly error messages

> **💡 Tip**: Bridging is bidirectional - OC code can also call Swift classes, but Swift classes need to be marked with `@objc`.