//
//  AppDelegate.swift
//  Picker
//
//  Created by Nao Sasaki on 2019/05/26.
//  Copyright © 2019 Nao Sasaki. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: QRView())
        self.window?.makeKeyAndVisible()
        
        
        
        let hourFmt = DateFormatter()
        hourFmt.dateFormat = "HH:mm"
        let timeArray = hourFmt.string(from: Date()).components(separatedBy: ":")
        let hour = Int(timeArray[0])! * 60
        let min = Int(timeArray[1])!
        if (hour + min + 10000) > UserDefaults.standard.integer(forKey: "classFinish"){
            UserDefaults.standard.set(false, forKey: "Attendance")
            UserDefaults.standard.removeObject(forKey: "AttendingClassPass")
            UserDefaults.standard.removeObject(forKey: "classFinish")
            UserDefaults.standard.removeObject(forKey: "instructor")
        } else { return true }
        print(UserDefaults.standard.bool(forKey: "Attendance"))
        return true
    }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool { return GIDSignIn.sharedInstance().handle(url) }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil { return }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: { (authResult, error) in if error != nil { return }})
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {}
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

