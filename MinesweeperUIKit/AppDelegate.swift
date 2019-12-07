//
//  AppDelegate.swift
//  MinesweeperUIKit
//
//  Created by Srdan Rasic on 07/12/2019.
//  Copyright © 2019 Atelier Clockwork. All rights reserved.
//

import UIKit
import MockingbirdUIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let state = GameState(configuration: .init(width: 9, height: 9, mineCount: 10))

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create the SwiftUI view that provides the window contents.
        let contentView = MainView(state: state)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = HostingController(contentView)
        self.window = window
        window.makeKeyAndVisible()

        return true
    }
}
