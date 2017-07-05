//
//  AppDelegate.swift
//  PawTrails
//
//  Created by Marc Perello on 27/01/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//
let isDebug = true

public struct ezdebug {
    public static let email = "ios@test.com"
    public static let password = "iOStest12345"
    public static let is4test = "marc@attitudetech.ie"
}

import UIKit

import FacebookCore

import Fabric
import TwitterKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        var out = true
        
        configureUIPreferences()

        Fabric.with([Crashlytics.self])
        
        if DataManager.instance.isAuthenticated() {
            
            if let socialMedia = DataManager.instance.isSocialMedia() {
                
                if let sm = SocialMedia(rawValue: socialMedia) {
                    switch sm {
                    case .facebook:
                        out = SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
                    case .twitter:
                        Fabric.with([Twitter.self])
                        break
                    case .google:
                        configureGoogleLogin()
                    default:
                        break
                    }
                }
                
            }
            loadHomeScreen()
        }else{
            loadAuthenticationScreen()
        }
//        let initial = storyboard.instantiateViewController(withIdentifier: "EmailVerificationViewController") as? EmailVerificationViewController
//        initial?.email = ""
//        window?.rootViewController = initial
        
        return out
    }
    
    func configureGoogleLogin() {
        GIDSignIn.sharedInstance().clientID = "994470408291-80qh373cjbu149ft6hb93c5dcslt2oup.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func loadHomeScreen() {
        let root = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        root.selectedIndex = 0
        window?.rootViewController = root
    }
    
    func loadAuthenticationScreen() {
        let initial = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController
        window?.rootViewController = initial
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if Twitter.sharedInstance().application(app, open: url, options: options) { return true }
        
        let google = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return SDKApplicationDelegate.shared.application(app, open: url, options: options) || google
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {

        SocketIOManager.instance.disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if DataManager.instance.isAuthenticated() {
            SocketIOManager.instance.connect()
            DataManager.instance.loadPets { (error, pets) in
                if error == nil, let pets = pets {
                    SocketIOManager.instance.startGPSUpdates(for: pets.map({ $0.id}))
                    NotificationManager.instance.postPetListUpdates(with: pets)
                }
            }

        }
        NotificationManager.instance.getEventsUpdates { (event) in
            EventManager.instance.handle(event: event, for: self.visibleViewController)
        }
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
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UINavigationBar.appearance().backgroundColor = UIColor.primary
        UINavigationBar.appearance().barTintColor = UIColor.primary
        UINavigationBar.appearance().tintColor = UIColor.secondary
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title2),
            NSForegroundColorAttributeName: UIColor.secondary
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
            Reporter.send(file: "#file", function: "#function", error)
        }else{
            if let root = window?.rootViewController as? InitialViewController {
                root.successGoogleLogin(token: user.authentication.idToken)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            Reporter.send(file: "#file", function: "#function", error)
        }
    }
    
}

