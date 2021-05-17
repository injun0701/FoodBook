//
//  SceneDelegate.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/06.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        //UserDefaults userid 정보를 가져와서, 존재한다면 메인으로, 없다면 회원가입 화면으로 루트뷰컨트롤러로 설정
        rootVC()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

        //앲 삭제(UserDefault는 액삭제시 자동 날라감), 회원 탈퇴, 로그아웃, 핸드폰 변경, 로그인 등등
//        UserDefaults.standard.removeObject(forKey: UDkey().userid)
//        UserDefaults.standard.removeObject(forKey: UDkey().username)
//        UserDefaults.standard.removeObject(forKey: UDkey().userimgurl)
        NSLog("로그아웃 상태")
    }
}

