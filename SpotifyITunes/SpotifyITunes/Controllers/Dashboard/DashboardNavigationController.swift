//
//  DashboardNavigationController.swift
//  FreeApp
//
//  Created by Tecorb Techonologies on 09/01/20.
//  Copyright © 2020 Tecorb. All rights reserved.
//

import UIKit

class DashboardNavigationController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isOpaque = false
        navigationBar.isTranslucent = true
        navigationBar.barTintColor = .white
      //  self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fonts.Poppins.bold.font(.large)]
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .none
    }
    
}
