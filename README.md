# client-sdk-swift

## Step 1: Get the AccountId and DevToken

Register an account at [https://console.dlink.cloud/](https://console.dlink.cloud). After creating an app on the platform, get the corresponding AccountId of the app.

## Step 2: Get the SDK

### (1) Add Pod source in you Pod file

```Ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/DLinkSDK/deeplink-dev-specs.git'
```

### (2) add dependency
```Ruby
pod 'AppAttribution'
```

## Step 3: Initialize the SDK 

### (1) configure and setup AttributionManager and start it
```swift
import AppAttribution

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {    

    // you can set you project-applied custom deviceid
    AttributionManager.setCustomDeviceId("your device id here")
    // create your configuration
        var configuration = AttributionConfiguration(accountId: "your_account_id", devToken: "your_dev_token")
    AttributionManager.setup(configuration: configuration, delegate: self) // setup your appid
    // start attribution manager
    AttributionManager.start()

    return true
}
```

### (2) **[!! IMPORTANT !!] Allow to make app attribution report**
```swift
// if you're ready to report app attribution, call readyToReport to start the process
// strongly recommended to begin report after you get your att auth

AttributionManager.readyToReport()
```
### (3) [Optional] UniversalLink
pass the universal link info to AttributionManager in UIApplicationDelegate
```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
    // If you use universal link to open your app
    // pass the info to AttributionManager
    AttributionManager.application(application: application, continue: userActivity, restorationHandler: restorationHandler)
    return true
}

```

### (4) Implement the delegate
```swift
extension AppDelegate: AttributionManagerDelegate {
    func appAttributionDidFinish(matched: Bool, info: [String : Any]) {
        // app attribution finished
        if matched {
            print("attribution matched, get info \(info)")
            // you can fetch your campaign info from here
            if let campaignInfo = info[AttributionParamKey.campaignInfoKey] as? [String: Any] {
                // check your campaign info params here
                print("campaign info \(campaignInfo)")
            }
        } else {
          print("attribution not matched")
        }
    }

    func appAttributionDidFail(error: any Error) {
        print("attribution failed \(error)")
    }
    
    func appAttributionDidReceiveUniversalLinkInfo(_ info: [String : Any]) {
        // universal link info
        print("get info from universal link \(info)")
    }

}
```

### (5) Directly obtain attribution results

You may also obtain the attribution result by attributionInfo API.
Remeber it's only available after you have finished your attribution process, or else you can only get an nil result
```swift
let info = AttributionManager.attributionInfo
print("attribution info \(info)")
```
## Step 4: AppsFlyerLib Support
If your app supports AppsFlyerLib, follow the next steps
### (1) Setup adapter in configuration
```swift
        var configuration = AttributionConfiguration(appId: "your_app_id")
        configuration.appsFlyerAdapter = self      // set AppsFlyerAdapter
        AttributionManager.setup(configuration: configuration, delegate: self) // set 
``` 

### (2) Implements AppsFlyerAdapter Protocol
```swift
extension AppDelegate: AppsFlyerAdapter {
    func startAppsFlyerLib() {
        // Start Your AppsFlyerLib Here
        
        AppsFlyerLib.shared().appsFlyerDevKey = "your_apps_flyer_dev_key"
        AppsFlyerLib.shared().appleAppID = "your_apps_app_id"
        AppsFlyerLib.shared().start()
    }
        
    func getAppsFlyerUID() -> String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    func logEvent(_ eventName: String, withValues values: [AnyHashable : Any]?) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: values)
    }
}
```

### (3) Pass AppsFlyerLib conversation data to AttributionManager
**This step is very important!**
```swift
extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        // callback to AttributionManager with appsflyer result
        AttributionManager.onAppflyerConversionDataSuccess(conversionInfo)
         
    }
    
    func onConversionDataFail(_ error: any Error) {
        AttributionManager.onAppflyerConversionDataFail(error)
    }
}

```
