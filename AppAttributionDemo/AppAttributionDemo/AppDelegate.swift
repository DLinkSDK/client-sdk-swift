//
//  AppDelegate.swift
//  AppAttributionDemo
//

import UIKit
import AppAttribution
import AppTrackingTransparency
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // [Optional] you can set you project-applied custom deviceid
        // or use the device id we generate for you
        AttributionManager.setCustomDeviceId("your device id here")
        // create your configuration
        // appleStoreId is your app id in AppleStore
        var configuration = AttributionConfiguration(accountId: "your_account_id", devToken: "your_dev_token", appleStoreId: "idxxxxxxx")
        // if you want to support appsflyerlib
        // setup adapter here
        configuration.appsFlyerAdapter = self
        configuration.logEnabled = true
        AttributionManager.logDelegate = self
        AttributionManager.setup(configuration: configuration, delegate: self) // set your appid
        // start attribution manager
        AttributionManager.start()
                
        // you can call AttributionManager.readyToReport to
        // report your app attribution immediately
        // but we strongly recommend you to call readyToReport
        // after you finish your ATT auth
        
        // do something, such as request for att
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            // delay for some seconds, and request att
            self?.requestATTAuth()
        }
        return true
    }
    
    private func requestATTAuth() {
        if #available(iOS 14, *) {
            print("ask for att auth")
            ATTrackingManager.requestTrackingAuthorization { status in
                // auth determined
                // we can start to report app attribution
                print("auth finished, ready to report app attribution")
                Task { @MainActor in
                    AttributionManager.readyToReport()
                }
            }
        } else {
            // Fallback on earlier versions
            print("directly report app attribution")
            AttributionManager.readyToReport()
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        // If you use universal link to open your app
        // pass the info to AttributionManager
        AttributionManager.application(application: application, continue: userActivity, restorationHandler: restorationHandler)
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

// MARK: - AttributionManagerDelegate
extension AppDelegate: AttributionManagerDelegate {
    func appAttributionDidReceiveUniversalLinkInfo(_ info: [String : Any]) {
        // universal link info
        print("get info from universal link \(info)")
    }
    
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
}

// MARK: - AppAttribution Log Delegate
extension AppDelegate: AttributionManagerLogDelegate {
    func log(message: String) {
        print(message)
    }
}

// MARK: - AppsFlyerAdapter
extension AppDelegate: AppsFlyerAdapter {
    func startAppsFlyerLib() {
        // Start Your AppsFlyerLib Here
        print("start appsflyer")
        AppsFlyerLib.shared().appsFlyerDevKey = "your_apps_flyer_dev_key"
        AppsFlyerLib.shared().appleAppID = "your_apps_app_id"
        AppsFlyerLib.shared().start()
        AppsFlyerLib.shared().delegate = self
    }
    
    func getAppsFlyerUID() -> String {
        return AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    func logEvent(_ eventName: String, withValues values: [AnyHashable : Any]?) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: values)
    }
}

// MARK: - AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("appsflyer get conversion \(conversionInfo)")
        // callback to AttributionManager with appsflyer result
        AttributionManager.onAppflyerConversionDataSuccess(conversionInfo)
    }
    
    func onConversionDataFail(_ error: any Error) {
        print("appsflyer failed \(error)")
        AttributionManager.onAppflyerConversionDataFail(error)
    }
}
