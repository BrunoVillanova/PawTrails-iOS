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
//        _ = AuthManager.Instance.signOut()
        
        // Set Status Bar Style
        UIApplication.shared.statusBarStyle = .lightContent
         
//        GIDSignIn.sharedInstance().disconnect()
        
        if AuthManager.Instance.isAuthenticated() {
            
            if let socialMedia = AuthManager.Instance.socialMedia() {
                
                if let sm = SocialMedia(rawValue: socialMedia) {
                    switch sm {
                    case .facebook:
                        out = SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//                        if AccessToken.current == nil {
//                            return signOut()
//                        }
                    case .twitter:
                        Fabric.with([Twitter.self])
                        break
                    case .google:
                        configureGoogleLogin()
//                        GIDSignIn.sharedInstance().signInSilently()
                    default:
                        break
                    }
                }
                
            }
            loadHomeScreen()
        }else{
            loadAuthenticationScreen()
        }
//        let initial = storyboard.instantiateViewController(withIdentifier: "AddEditSafeZoneViewController") as? AddEditSafeZoneViewController
//        window?.rootViewController = initial
//
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
    
    func signOut() -> Bool {
        loadAuthenticationScreen()
        return AuthManager.Instance.signOut()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if Twitter.sharedInstance().application(app, open: url, options: options) { return true }
        
        let google = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return SDKApplicationDelegate.shared.application(app, open: url, options: options) || google
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        SocketIOManager.Instance.closeConnection()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        SocketIOManager.Instance.establishConnection()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        SocketIOManager.Instance.closeConnection()
        try? CoreDataManager.Instance.save()
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

