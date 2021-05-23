//
//  LoginViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/07.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet var tfUserId: UITextField!
    @IBOutlet var tfPasswd: UITextField!
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //로그인 버튼
    @IBAction func btnLoginAction(_ sender: UIButton) {
        //유효성 검사
        validateField() {
            //로그인 처리
            self.login()
        }
    }
    
    //유효성 검사
    func validateField(success: @escaping () -> ()) {
        let id = tfUserId.text!.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        let pw = tfPasswd.text!.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        let alertTitle = "로그인 오류"
        if id == "" {
            showAlertBtn1(title: alertTitle, message: "아이디을 입력해 주세요.", btnTitle: "확인") {}
        } else {
            if id.count < 3 || id.count > 12 {
                showAlertBtn1(title: alertTitle, message: "아이디는 3~12자로 작성해야 합니다.", btnTitle: "확인") {}
            } else {
                if pw == "" {
                    showAlertBtn1(title: alertTitle, message: "비밀번호를 입력해 주세요.", btnTitle: "확인") {}
                } else {
                    if pw.count < 6 || pw.count > 12 {
                        self.showAlertBtn1(title: alertTitle, message: "비밀번호는 6~12자로 작성해야 합니다.", btnTitle: "확인") {}
                    } else {
                        success()
                    }
                }
            }
        }
    }
    
    //로그인 처리
    func login() {
        let userid = tfUserId.text!
        let passwd = tfPasswd.text!
        //AES.swift에 있는 기능 이용, 사용자가 입력한 텍스트를 암호화한다.
        let encryptPassword = AES256CBC.encryptString(passwd, password: AESkey().defaultKey)!
        networkCheck {
            LoadingHUD.show()
            self.req.apiUserLogin(userid: userid, passwd: encryptPassword) { userid, username, userimgurl in
                print("userid:\(userid), username:\(username), userimgurl\(userimgurl)")
                UserDefaults.standard.set(userid, forKey: UDkey().userid)
                UserDefaults.standard.set(username, forKey: UDkey().username)
                UserDefaults.standard.set(userimgurl, forKey: UDkey().userimgurl)
                LoadingHUD.hide()
                // 최상의 rootview 갱신
                rootVC()
            } fail: {
                LoadingHUD.hide()
                self.showAlertBtn1(title: "로그인 오류", message: "로그인 정보가 맞지 않습니다.", btnTitle: "확인") {}
            }
        }
    }
    
    //리스트 뷰로 이동 메소드
    func toListView() {
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListViewController") as! ItemListViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //회원가입 버튼
    @IBAction func btnToSignUpViewAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "SignUp", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navbarSetting(title: "")
        
    }
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        navibarSetting()
    }
    
    func navibarSetting() {
        self.navigationController?.navigationBar.barTintColor = UIColor.white //네비 바 배경색
        
        setNeedsStatusBarAppearanceUpdate() //상태바 업데이트
        navigationController?.navigationBar.barStyle = .default //상태바 글자 검정색으로 설정하기위해 네비바 barStyle를 default
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //상태바 글자 검정
    }
}
