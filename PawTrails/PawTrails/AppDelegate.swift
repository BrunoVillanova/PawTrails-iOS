//
//  AppDelegate.swift
//  Snout
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
    
    //func print(items: Any..., separator: String = " ", terminator: String = "\n") {} Uncomment for release version
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if AuthManager.Instance.isAuthenticated() {
            loadHomeScreen()
        }else{
            loadAuthenticationScreen()
        }
        
        // Set Status Bar Style
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Social Media Logins
        
        Fabric.with([Twitter.self])
        
        let facebook = SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self

        
        return true && facebook
    }
    
    func loadHomeScreen() {
        let root = storyboard.instantiateViewController(withIdentifier: "tabBarController")
        window?.rootViewController = root
    }
    
    func loadAuthenticationScreen() {
        let initial = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as? InitialViewController
        window?.rootViewController = initial
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if Twitter.sharedInstance().application(app, open: url, options: options) { return true }
        
        _ = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
//
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
    
    //MARK:- GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let root = window?.rootViewController as? InitialViewController {
            
            if (error == nil) {
                // Perform any operations on signed in user here.
                //            let userId = user.userID                  // For client-side use only!
                //            let idToken = user.authentication.idToken // Safe to send to the server
                //            let fullName = user.profile.name
                //            let givenName = user.profile.givenName
                //            let familyName = user.profile.familyName
                //            let email = user.profile.email
                debugPrint(user, user.profile.email)
                root.successGoogleLogin(email: user.profile.email)
            } else {
                root.alert(title: "", msg: error.localizedDescription)
            }

            
        }

    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        if AuthManager.Instance.signOut() {
            loadAuthenticationScreen()
        }else{
            debugPrint("Not Sign Out properly", user.debugDescription, error.localizedDescription)
        }
    }
    
}

