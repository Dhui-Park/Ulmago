//
//  AppDelegate.swift
//  Ulmago
//
//  Created by dhui on 3/11/24.
//

import UIKit
import Realm
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        print(Realm.Configuration.defaultConfiguration.filRL ?? "")
        
//        if let id = try? ObjectId(string: "660b9fbc179e877f2bab8a6c") {
//            BudgetRepository.shared.editBudget(at: id, updatedTitle: "짬뽕", updatedPrice: 30000)
//        }
        
//        BudgetRepository.shared.deleteAllBudgets()
        UserGoalRepository.shared.deleteAllUserGoals()
        
        
        if let realm = try? Realm() {
            print("Realm Path : \(realm.configuration.fileURL?.absoluteURL)")
        }
        
    
        return true
    }

    // MARK: UISceneSession Lifecycle

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


}

