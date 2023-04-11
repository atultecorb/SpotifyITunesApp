//
//  AppSetting.swift
//  SpotifyITunes
//
//  Created by Tecorb Technologies on 27/03/23.
//

import Foundation
import UIKit


class AppSettings{
    
    static let shared = AppSettings()
    fileprivate init() {}
    
    let kUserDefaults = UserDefaults.standard
    
    var acToken : String {
        get {
            var result = ""
            if let r = kUserDefaults.value(forKey:accessTokenKey) as? String{
                result = r
            }
            if result == ""{
                result = ""
            }
            return result
        }
        set(newGuestToken){
            kUserDefaults.set(newGuestToken, forKey: accessTokenKey)
        }
    }
    
    var refreshToken : String {
        get {
            var result = ""
            if let r = kUserDefaults.value(forKey:accessRefreshTokenKey) as? String{
                result = r
            }
            if result == ""{
                result = ""
            }
            return result
        }
        set(newGuestToken){
            kUserDefaults.set(newGuestToken, forKey: accessRefreshTokenKey)
        }
    }
    
    func proceedToDashboard(completionBlock :(() -> Void)? = nil){
        let navigationController = AppStoryboard.Main.viewController(DashboardNavigationController.self)
        AppDelegate.getAppDelegate().window?.rootViewController = navigationController
        guard let handler = completionBlock else{return}
        handler()
    }

    func proceedToSpotifySignIn(completionBlock :(() -> Void)? = nil){
        AppSettings.shared.acToken = ""
           let navigationController = AppStoryboard.Main.viewController(StartNavigationViewController.self)
           AppDelegate.getAppDelegate().window?.rootViewController = navigationController
           guard let handler = completionBlock else{return}
           handler()
       }
    
}

enum AppStoryboard : String {

    case Main

    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    func viewController<T : UIViewController>(_ viewControllerClass : T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }

    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {

    class var storyboardID : String {
        return "\(self)"
    }
    static func instantiate(fromAppStoryboard appStoryboard : AppStoryboard) -> Self {
        return appStoryboard.viewController(self)
    }
}
