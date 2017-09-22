//
//  AppDelegate.swift
//  ManuNews
//
//  Created by Thành Lã on 2/21/17.
//  Copyright © 2017 Thành Lã. All rights reserved.
//

import UIKit
import CleanroomLogger
import FBSDKLoginKit
import PHExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FileManager.default.createAppDirectory("Log", skipBackupAttribute: true)
        let path = FileManager.default.getDocumentDirectory().appendingPathComponent("Log")
        Log.enable(configuration: CustomLogConfiguration(minimumSeverity: .verbose, dayToKeep: 60, filePath: path.path))
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let tabBar = setupTabBarController()
        
        if let window = window {
            window.rootViewController = tabBar
            window.makeKeyAndVisible()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate
            .sharedInstance()
            .application(
                application,
                open: url,
                sourceApplication: sourceApplication,
                annotation: annotation
        )
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    
    ///
    func setupTabBarController() -> UITabBarController {
        
        let tabbarVC = UITabBarController()
        
        let naviNewsVC = UINavigationController(rootViewController: NewsViewController())
        let naviComunityVC = UINavigationController(rootViewController: ComunityViewController())
        let naviResultVC = UINavigationController(rootViewController: ResultViewController())
        let naviScheduleVC = UINavigationController(rootViewController: ScheduleViewController())
        let naviProfileVC = UINavigationController(rootViewController: ProfileViewController())
        
        let viewControllers = [naviNewsVC, naviResultVC, naviScheduleVC, naviComunityVC, naviProfileVC]
        
        viewControllers.forEach { Utility.shared.configureAppearance(navigation: $0) }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        tabbarVC.viewControllers = viewControllers
        
        tabbarVC.tabBar.barStyle = .default
        tabbarVC.tabBar.backgroundColor = UIColor.Navi.main
        tabbarVC.tabBar.barTintColor = UIColor.white.alpha(0.8)
        tabbarVC.tabBar.isTranslucent = false
        
        let items: [(title: String, image: UIImage)] = [
            ("Tin tức", Icon.TabBar.article),
            ("Kết quả",  Icon.TabBar.noteBook),
            ("Lịch thi đấu", Icon.TabBar.history),
            ("Bình loạn",  Icon.TabBar.noteBook),
            ("Cá nhân", Icon.TabBar.personal)
        ]
        
        
        for (i, item)  in tabbarVC.tabBar.items!.enumerated() {
            item.selectedImage = items[i].image.tint(UIColor.main)
            item.image = items[i].image.tint(UIColor.lightGray)
            item.title = items[i].title
            
            item.setTitleTextAttributes([
                NSFontAttributeName: UIFont(name: FontType.latoSemibold.., size: FontSize.small--)!], for: .normal)
            
        }
        
        return tabbarVC
    }
    
}

