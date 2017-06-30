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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        var out = true
        
        // Set Status Bar Style
        UIApplication.shared.statusBarStyle = .lightContent
        
        configureUIPreferences()
        
//        _ = DataManager.Instance.signOut()
        
        if DataManager.Instance.isAuthenticated() {
            
            if let socialMedia = DataManager.Instance.socialMedia() {
                
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
        root.selectedIndex = 1
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

        SocketIOManager.Instance.disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if DataManager.Instance.isAuthenticated() {
            SocketIOManager.Instance.connect()
            UpdateManager.Instance.loadPetList { (pets) in
                if let pets = pets {
                    SocketIOManager.Instance.startGPSUpdates(for: pets.map({ $0.id}))
                }
            }
        }
        NotificationManager.Instance.getEventsUpdates { (event) in
            if let event = event {
                EventManager.Instance.handle(event: event, for: self.visibleViewController)
            }
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

        SocketIOManager.Instance.disconnect()
        CoreDataManager.instance.save { (error) in
            if let error = error {
                debugPrint("AppDelegate - WillTerminate - SaveAction ",error)
            }
        }
    }
    
    private func configureUIPreferences() {
        
        let primaryColor = UIColor.primaryColor()
        let secondaryColor = UIColor.secondaryColor()
        
        UINavigationBar.appearance().barTintColor = primaryColor
        UINavigationBar.appearance().tintColor = secondaryColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title2),
            NSForegroundColorAttributeName: secondaryColor
        ]
        
        UITabBar.appearance().tintColor = primaryColor
        
        UITableViewCell.appearance().tintColor = primaryColor
        
        UISwitch.appearance().onTintColor = primaryColor
        
        UISegmentedControl.appearance().tintColor = primaryColor
        
        UIActivityIndicatorView.appearance().color = primaryColor
        
//        UILabel.appearance().backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    //    MARK:- GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let root = window?.rootViewController as? InitialViewController {
            
            if (error == nil) {
                print(user.authentication.idToken)
                print("\n")
                print(user.authentication.idTokenExpirationDate)
                print("\n")
                root.successGoogleLogin(token: user.authentication.idToken)
            } else {
                root.alert(title: "", msg: error.localizedDescription)
            }
            
        }else{
            //Mec
            print("Shit")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            debugPrint(error)
        }
    }
    
}

