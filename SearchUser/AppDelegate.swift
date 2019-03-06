//
//  AppDelegate.swift
//  SearchUser
//
//  Created by junwoo on 28/02/2019.
//  Copyright © 2019 samchon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow()
    window?.makeKeyAndVisible()
    let networkManger = NetworkManager()
    let pagingManager = PagingManager()
    let viewModel = ViewModel(networkManager: networkManger,
                              pagingManager: pagingManager)
    let viewController = ViewController(viewModel: viewModel)
    window?.rootViewController = UINavigationController(rootViewController: viewController)
    
    return true
  }

}

