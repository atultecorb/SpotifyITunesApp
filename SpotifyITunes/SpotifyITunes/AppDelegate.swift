//
//  AppDelegate.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 23/03/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appDelegate = UIApplication.shared.delegate
    
    var window: UIWindow?
    lazy var rootViewController = ViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = (UIApplication.shared.delegate?.window)!
       // self.setRootViewController()
        if AppSettings.shared.acToken != ""{
            AppSettings.shared.proceedToDashboard()
        } else {
            AppSettings.shared.proceedToSpotifySignIn()
        }
        self.window?.overrideUserInterfaceStyle = .dark
        return true
    }
    
    
//    let appdelegate = UIApplication.shared.delegate as! AppDelegate
//    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//    var homeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
//    let nav = UINavigationController(rootViewController: homeViewController)
//    appdelegate.window!.rootViewController = nav
//
    func setRootViewController(){
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        rootViewController = mainStoryBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let nav = UINavigationController(rootViewController: rootViewController)
        self.appDelegate?.window??.rootViewController = nav
       // self.window?.rootViewController = rootViewController
    }
    
   
 /*   // MARK: UISceneSession Lifecycle

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
    */
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let accessToken = rootViewController.appRemote.connectionParameters.accessToken {
            rootViewController.appRemote.connectionParameters.accessToken = accessToken
            rootViewController.appRemote.connect()
        } else if let accessToken = rootViewController.accessToken {
            rootViewController.appRemote.connectionParameters.accessToken = accessToken
            rootViewController.appRemote.connect()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication){
        if rootViewController.appRemote.isConnected {
            rootViewController.appRemote.disconnect()
        }
    }
  
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool{
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
      //  guard let url = URLContexts.first?.url else { return }
        let parameters = rootViewController.appRemote.authorizationParameters(from: url.absoluteURL)
        if let code = parameters?["code"] {
            rootViewController.responseCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            rootViewController.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
        return true
    }


}

extension AppDelegate{
    class func getAppDelegate() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func getWindowNavigation()-> UINavigationController?{
        guard let window = self.window else {
            return nil
        }
        guard let nav = window.rootViewController as? UINavigationController else {
            return nil
        }
        return nav
    }
}
