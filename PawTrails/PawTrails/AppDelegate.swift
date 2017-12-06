//
//  AppDelegate.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import FacebookCore
import Fabric
import Crashlytics
import SocketIO
import SwiftyJSON
import IQKeyboardManagerSwift

#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

public struct ezdebug {
    public static let email = "ios@test.com"
    public static let password = "iOStest12345"
    public static let is4test = "mohamed@attitudetech.ie"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure UI
        configureUIPreferences()
        
        // Configure services
        Fabric.with([Crashlytics.self])
        
        // KeyboardManager
        IQKeyboardManager.sharedManager().enable = true

        
        var out = true
        
        if DataManager.instance.isAuthenticated() {
            if let socialMedia = DataManager.instance.isSocialMedia() {
                if let sm = SocialMedia(rawValue: socialMedia) {
                    switch sm {
                    case .facebook:
                        out = SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
                    case .google:
                        configureGoogleLogin()
                    default:
                        break
                    }
                }
            }
            loadHomeScreen()
        } else {
            loadAuthenticationScreen()
        }
        
        return out
    }
    
    func configureGoogleLogin() {
        GIDSignIn.sharedInstance().clientID = "994470408291-80qh373cjbu149ft6hb93c5dcslt2oup.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func loadHomeScreen() {
//        if runningTripArray.isEmpty == false {
            let root = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            root.selectedIndex = 0
            window?.rootViewController = root
}
    
    func loadAuthenticationScreen() {
            let initial = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController
            window?.rootViewController = initial
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let google = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return SDKApplicationDelegate.shared.application(app, open: url, options: options) || google
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.instance.disconnect()
    }
//
    func applicationDidBecomeActive(_ application: UIApplication) {
        
//        if DataManager.instance.isAuthenticated() {
//            getRunningandPausedTrips()
//            SocketIOManager.instance.connect()
//            DataManager.instance.loadPets { (error, pets) in
//                if error == nil, let pets = pets {
////                    SocketIOManager.instance.startGPSUpdates(for: pets.map({ $0.id}))
//                    NotificationManager.instance.postPetListUpdates(with: pets)
//                }
//            }
//
//        }
//
//        NotificationManager.instance.getEventsUpdates { (event) in
//            EventManager.instance.handle(event: event, for: self.visibleViewController)
//        }
    }
    
    var visibleViewController: UIViewController? {
        
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            if  let navigationController = tabBarController.selectedViewController as? UINavigationController {
                return navigationController.viewControllers.last!
            }else{
                return tabBarController.selectedViewController
            }
        }
        return nil
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketIOManager.instance.disconnect()
        CoreDataManager.instance.save { (_) in }
    }
    
    private func configureUIPreferences() {
        UIApplication.shared.statusBarStyle = .default
        UINavigationBar.appearance().backgroundColor = UIColor.secondary
        UINavigationBar.appearance().barTintColor = UIColor.secondary
        UINavigationBar.appearance().tintColor = UIColor.primary
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title2),
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        UITabBar.appearance().tintColor = UIColor.primary
        UITableViewCell.appearance().tintColor = UIColor.primary
        UISwitch.appearance().onTintColor = UIColor.primary
        UISegmentedControl.appearance().tintColor = UIColor.primary
        UIActivityIndicatorView.appearance().color = UIColor.primary
//        UILabel.appearance().backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    //    MARK:- GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            Reporter.send(file: "\(#file)", function: "\(#function)", error)
        }else{
            if let root = window?.rootViewController as? InitialViewController {
                root.successGoogleLogin(token: user.authentication.idToken)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            Reporter.send(file: "\(#file)", function: "\(#function)", error)
        }
    }
    
}

