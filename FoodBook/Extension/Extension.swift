//
//  Extension.swift
//  Injunstagram
//
//  Created by HongInJun on 2021/04/30.
//

import UIKit
import SideMenu

extension UIViewController {
    
    //네비게이션바 세팅
    func navbarSetting(title: String) {
        self.navigationItem.title = title
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
    func networkCheckSuccessAndFaile(success: @escaping () -> (), fail: @escaping () -> ()) {
        //네트워크 사용 여부 확인
        let reachability = Reachability()
        let result = reachability.isConnectedToNetwork()
        
        if result == true {
            success()
        } else {
            fail()
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
    
    //버튼 세개 알럿
    func showAlertBtn3(title: String, message: String, btn1Title: String, btn2Title: String, btn3Title: String, btn1Action: @escaping () -> Void, btn2Action: @escaping () -> Void, btn3Action: @escaping () -> Void)  {
        
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
        
        let btn3 = UIAlertAction(title: btn3Title, style: .default) { (_) in
            print("버튼2 클릭함")
            btn3Action()
        }
        alert.addAction(btn3)
        
        present(alert, animated: true) {
            print("Alert이 잘 작동됨")
        }
    }
    
    func btnEtcActionSheet(btn1Action: @escaping () -> Void, btn2Action: @escaping () -> Void, btn3Action: @escaping () -> Void) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let btn1 = UIAlertAction(title: "해당 콘텐츠 보지 않기", style: .default) { (_) in
            print("버튼1 클릭함")
            btn1Action()
        }
        actionSheet.addAction(btn1)
        
        let btn2 = UIAlertAction(title: "신고하기", style: .default) { (_) in
            print("버튼2 클릭함")
            btn2Action()
        }
        actionSheet.addAction(btn2)
        let btn3 = UIAlertAction(title: "유저 차단하기", style: .default) { (_) in
            print("버튼3 클릭함")
            btn3Action()
        }
        actionSheet.addAction(btn3)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (_) in
            print("버튼2 클릭함")
        }
        
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true) {
            print("actionSheet이 잘 작동됨")
        }
    }
    func btnCommentEtcActionSheet(btn1Action: @escaping () -> Void, btn2Action: @escaping () -> Void) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let btn1 = UIAlertAction(title: "신고하기", style: .default) { (_) in
            print("버튼2 클릭함")
            btn1Action()
        }
        actionSheet.addAction(btn1)
        let btn2 = UIAlertAction(title: "유저 차단하기", style: .default) { (_) in
            print("버튼3 클릭함")
            btn2Action()
        }
        actionSheet.addAction(btn2)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (_) in
            print("버튼2 클릭함")
        }
        
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true) {
            print("actionSheet이 잘 작동됨")
        }
    }
    //문자열 자르기
    func cutString(str: String, endIndex: Int, fromTheFront: Bool) -> String {
        if fromTheFront == true {
            let result = String(str.prefix(endIndex))
            return result
        } else {
            let result = String(str.suffix(endIndex))
            return result
        }
    }
    
    //텍스트뷰 디자인
    func textViewDesign(textView: UITextView) {
        textView.layer.borderWidth = 0.3
        textView.layer.borderColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 4
    }
    
    //로그아웃
    func logout() {
        //SQLite 파일 urlpath
        let directoryPath = SQLiteDocumentDirectoryPath()
        
        //앲 삭제(UserDefault는 액삭제시 자동 날라감), 회원 탈퇴, 로그아웃, 핸드폰 변경 등등
        UserDefaults.standard.removeObject(forKey: UDkey().userid)
        UserDefaults.standard.removeObject(forKey: UDkey().username)
        UserDefaults.standard.removeObject(forKey: UDkey().userimgurl)
        //파일 핸들링하기 위한 객체 생성
        let fileMgr = FileManager.default
        //데이터베이스 팡리 경로를 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPathURL.appendingPathComponent(directoryPath.item).path
        //기존 데이터를 지우고 새로 다운로드
        try? fileMgr.removeItem(atPath: dbPath) //데이터베이스 파일 삭제
        
        NSLog("로그아웃 상태")
        rootVC()
    }
    
    //사이드 메뉴 세팅
    func setUpSideMenu() {
        // 1. Side Menu ViewController 만들기
        let sideMenu = SideMenuViewController(nibName: "SideMenuViewController", bundle: nil)
        // 2. UISideMenuNavigationController 생성시키기.
        let sideNavigation = SideMenuNaviController(rootViewController: sideMenu)
        // 3. 셋팅하기.
        SideMenuManager.default.rightMenuNavigationController = sideNavigation
        
        // 4. 스와이프 열고 닫기 켜기
//        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
    }
    
    func presentSideMenu() {
        // 강제 열림 액션.
        present(SideMenuManager.default.rightMenuNavigationController!, animated: true, completion: nil)
    }
    
    
    //사이드 메뉴 세팅
    func setUpNoti() {
        // 1. Side Menu ViewController 만들기
        let noti = NotiViewController(nibName: "NotiViewController", bundle: nil)
        // 2. UISideMenuNavigationController 생성시키기.
        let notiNavi = NotiNaviController(rootViewController: noti)
        // 3. 셋팅하기.
        SideMenuManager.default.leftMenuNavigationController = notiNavi
        
        // 4. 스와이프 열고 닫기 켜기
//        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
    }
    
    func presentNoti() {
        // 강제 열림 액션.
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
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

//MARK: 유아이_컬러 extension
extension UIColor {
    var mainColor : UIColor {
        return UIColor(named: "mainColor")!
    }
    var color666666 : UIColor {
        return UIColor(named: "color666666")!
    }
    var colorEEEEEE : UIColor {
        return UIColor(named: "colorEEEEEE")!
    }
}
