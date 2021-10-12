//
//  AppDelegate.swift
//  UUVideo
//
//  Created by Galaxy on 2020/8/14.
//  Copyright © 2020 qykj. All rights reserved.
//

import UIKit
import SJVideoPlayer
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        #if DEBUG
//        var injectionBundlePath = "/Applications/InjectionIII.app/Contents/Resources"
//        #if targetEnvironment(macCatalyst)
//        injectionBundlePath = "\(injectionBundlePath)/macOSInjection.bundle"
//        #elseif os(iOS)
//        injectionBundlePath = "\(injectionBundlePath)/iOSInjection.bundle"
//        #endif
//        Bundle(path: injectionBundlePath)?.load()
//        #endif
        
        #if DEBUG
            Bundle.init(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
            #endif
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
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        if Tool.isPhone(){
            return .all
//        }else{
//            return .landscape
//        }
    }
}

