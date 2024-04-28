//
//  SceneDelegate.swift
//  Ulmago
//
//  Created by dhui on 3/11/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let uiWindow = UIWindow(windowScene: windowScene)
        //
#warning("TODO: - ")
        //        // 사용자가 이전에 접속해서 UserGoal을 이미 작성했을 때(UserGoal이 이미 존재할 때)
        if let userGoal = UserGoalRepository.shared.fetchUserGoalEntities().first {
            if userGoal.goalPrice == 0 {
                let storyboard = UIStoryboard(name: WholeCostSettingVC.reuseIdentifier, bundle: .main)
                let vc = storyboard.instantiateViewController(identifier: WholeCostSettingVC.reuseIdentifier, creator: { coder in
                    return WholeCostSettingVC(coder: coder, goalText: userGoal.goalTitle)
                })/* as? PreviousDailyBudgetVC*/
                
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.tintColor = UIColor.primaryColor
                
                uiWindow.rootViewController = navigationController
                
                
            } else if userGoal.dailyExpenseLimit == 0 {
                let storyboard = UIStoryboard(name: DailyExpenseSettingVC.reuseIdentifier, bundle: .main)
                let vc = storyboard.instantiateViewController(identifier: DailyExpenseSettingVC.reuseIdentifier, creator: { coder in
                    return DailyExpenseSettingVC(coder: coder, goalText: userGoal.goalTitle, wholeCost: userGoal.goalPrice)
                })/* as? PreviousDailyBudgetVC*/
                
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.tintColor = UIColor.primaryColor
                
                uiWindow.rootViewController = navigationController
            } else {
                let storyboard = UIStoryboard(name: DailyMainVC.reuseIdentifier, bundle: .main)
                let vc = storyboard.instantiateViewController(identifier: DailyMainVC.reuseIdentifier, creator: { coder in
                    return DailyMainVC(coder: coder, goalText: "\(userGoal.goalTitle)", wholeCostText: "\(userGoal.goalPrice)", dailyExpense: "\(userGoal.dailyExpenseLimit)")
                })/* as? PreviousDailyBudgetVC*/
                
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.tintColor = UIColor.primaryColor
                
                uiWindow.rootViewController = navigationController
            }
            window = uiWindow
            
            uiWindow.makeKeyAndVisible()
            
            
        }
        
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
}

