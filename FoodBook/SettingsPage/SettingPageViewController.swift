//
//  SettingPageViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/21.
//

import UIKit

class SettingPageViewController: UIViewController {

    //로그인 로그 페이지로 이동
    @IBAction func btnToLoginLogAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "SettingPage", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "LoginLogViewController") as! LoginLogViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //비밀번호 변경 페이지로 이동
    @IBAction func btnToUserPasswdUpdateAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "SettingPage", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "UserPasswordUpdateViewController") as! UserPasswordUpdateViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //탈퇴하기 버튼
    @IBAction func btnSecessionAction(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbarSetting(title: "설정 페이지")
    }
    
}
