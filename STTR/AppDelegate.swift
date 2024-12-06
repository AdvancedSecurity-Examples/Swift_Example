//
//  AppDelegate.swift
//  STTR
//
//  Created by Brady  on 3/25/21.
//

import UIKit
import Firebase
import GoogleSignIn
import CryptoSwift
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate/*, GIDSignInDelegate*/ {
    
    //function used to decrypt encrypted strings
    func decryptAES(string: String) throws -> String{
        let aes = try AES(key: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177], blockMode: CBC(iv: [206, 131, 29, 10, 221, 211, 60, 236, 57, 131, 76, 101, 238, 39, 200, 177]))
        let decrypt = try string.decryptBase64ToString(cipher: aes)
        return decrypt
    }
    
    //function used to sign in using google firebase
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            return
        }
        
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken ?? "", accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error != nil {
                
            }
        }
    }
    
    //function that initializes the Firebase Auth Configuration
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        URLSessionConfiguration.default.requestCachePolicy = .reloadIgnoringCacheData
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        #if ZIP_T
            let vuln = Vuln()
            vuln.trustCerts()
        #endif
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
//        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
//        GIDSignIn.sharedInstance.delegate = self
        return true
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        let handled: Bool = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        return handled
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication,
                     shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool{
        #if KEYBOARD_T
        return true
        #else
        return false
        #endif
    }
    
    
}
