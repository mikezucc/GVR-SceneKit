//
//  AppDelegate.swift
//  VRBoilerplate
//
//  Created by Andrian Budantsov on 5/19/16.
//  Copyright © 2016 Andrian Budantsov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {

    var window: UIWindow?

    var arWindow: UIWindow?

    static var arVC: ARViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        let navController = UINavigationController(rootViewController:  )
//        navController.delegate = self;
//        navController.isNavigationBarHidden = true;

        let window = UIWindow(frame: UIScreen.main.bounds);
        window.rootViewController = ViewController();
        window.makeKeyAndVisible();
        self.window = window;

        arWindow = UIWindow(frame: UIScreen.main.bounds)
        AppDelegate.arVC = UIStoryboard(name: "AR", bundle: .main).instantiateInitialViewController() as? ARViewController
        arWindow?.rootViewController = AppDelegate.arVC
        arWindow?.makeKeyAndVisible()
//        self.window = arWindow

        return true
    }
    
    // Make the navigation controller defer the check of supported orientation to its topmost view
    // controller. This allows |GVRCardboardViewController| to lock the orientation in VR mode.
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        
        return navigationController.topViewController!.supportedInterfaceOrientations
        
    }


}

