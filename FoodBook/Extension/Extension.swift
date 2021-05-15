//
//  Extension.swift
//  Injunstagram
//
//  Created by HongInJun on 2021/04/30.
//

import UIKit

extension UIViewController {
    
    //네비게이션바 세팅
    func navbarSetting(title: String) {
        self.title = title
        //백버튼 텍스트 제거
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    //네트워크 체크
    func networkCheck(after: @escaping () -> ()) {
        //네트워크 사용 여부 확인
        let reachability = Reachability()
        let result = reachability.isConnectedToNetwork()
        
        if result == true {
            after()
        } else {
            showAlertBtn1(title: "네트워크 오류", message: "네트워크를 키고 다시 실행해주세요.", btnTitle: "확인") {}
        }
    }
    //네트워크 체크
    func networkCheckSuccessAndFaile(success: @escaping () -> (), faile: @escaping () -> ()) {
        //네트워크 사용 여부 확인
        let reachability = Reachability()
        let result = reachability.isConnectedToNetwork()
        
        if result == true {
            success()
        } else {
            faile()
        }
        
    }
    
    //버튼 한개 알럿
    func showAlertBtn1(title: String, message: String, btnTitle: String, action: @escaping () -> Void)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btn1 = UIAlertAction(title: btnTitle, style: .default) { (_) in
            print("버튼1 클릭함")
            action()
        }
        alert.addAction(btn1)
        
        present(alert, animated: true) {
            print("Alert이 잘 작동됨")
        }
    }
    
    //버튼 두개 알럿
    func showAlertBtn2(title: String, message: String, btn1Title: String, btn2Title: String, btn1Action: @escaping () -> Void, btn2Action: @escaping () -> Void)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btn1 = UIAlertAction(title: btn1Title, style: .default) { (_) in
            print("버튼1 클릭함")
            btn1Action()
        }
        alert.addAction(btn1)
        
        let btn2 = UIAlertAction(title: btn2Title, style: .default) { (_) in
            print("버튼2 클릭함")
            btn2Action()
        }
        alert.addAction(btn2)
        
        present(alert, animated: true) {
            print("Alert이 잘 작동됨")
        }
    }
    
}

extension String {
    func substring(from: Int, to: Int) -> String {
        guard from < count, to >= 0, to - from >= 0 else {
            return ""
        }
        
        // Index 값 획득
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to + 1) // '+1'이 있는 이유: endIndex는 문자열의 마지막 그 다음을 가리키기 때문
        
        // 파싱
        return String(self[startIndex ..< endIndex])
    }
}

//루트 뷰 컨트롤러
func rootVC() {
    if UserDefaults.standard.value(forKey: UDkey().userid) != nil  {
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ItemListViewController") as! ItemListViewController
        let nav = UINavigationController(rootViewController: vc)
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            sceneDelegate.window!.rootViewController = nav
        // iOS12 or earlier
        } else {
            // UIApplication.shared.keyWindow?.rootViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController =  nav
        }
    } else {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let nav = UINavigationController(rootViewController: vc)
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes
                .first!.delegate as! SceneDelegate
            sceneDelegate.window!.rootViewController = nav
        // iOS12 or earlier
        } else {
            // UIApplication.shared.keyWindow?.rootViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController =  nav
        }
    }
}
