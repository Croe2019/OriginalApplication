//
//  SceneDelegate.swift
//  OriginalApplication
//
//  Created by 濱田広毅 on 2020/07/10.
//  Copyright © 2020 濱田広毅. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        let storyboard: UIStoryboard = self.grabStoryboard()
        
        if let window = window{
            
            window.rootViewController = storyboard.instantiateInitialViewController() as UIViewController?
        }
        self.window?.makeKeyAndVisible()
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    // 画面の高さ画面を変える
    func grabStoryboard() -> UIStoryboard{
        
        var storyBoard = UIStoryboard()
        let height = UIScreen.main.bounds.size.height
        
        if(height == 667){
            
            // iPhone8
            storyBoard = UIStoryboard(name: "Main", bundle: nil)
        }
        else if(height == 736){
            
            // iPhone8Plus
            storyBoard = UIStoryboard(name: "iPhone8Plus", bundle: nil)
        }
        else if(height == 896){
            
            // iPhone11
            storyBoard = UIStoryboard(name: "iPhone11", bundle: nil)
        }
        else if(height == 896){
            
            // iPhone11ProMax
            storyBoard = UIStoryboard(name: "iPhone11ProMax", bundle: nil)
        }
        else if(height == 844){
            
            // iPhone12,12Pro
            storyBoard = UIStoryboard(name: "iPhone12", bundle: nil)
        }
        else if(height == 926){
            
            // iPhone12ProMax
            storyBoard = UIStoryboard(name: "iPhone12ProMax", bundle: nil)
        }
        else if(height == 812){
            
            // iPhone12mini
            storyBoard = UIStoryboard(name: "iPhone12mini", bundle: nil)
        }
        
        return storyBoard
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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

