//
//  SettingPageViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/21.
//

import UIKit

class SettingPageViewController: UIViewController {
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
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
        showAlertBtn2(title: "탈퇴 안내", message: "정말로 탈퇴하시겠습니까?", btn1Title: "취소", btn2Title: "탈퇴") {
        } btn2Action: {
            self.showAlertBtn2(title: "탈퇴 안내", message: "탈퇴하시면 기존의 정보가 모두 삭제됩니다. 그래도 탈퇴하시겠습니까?", btn1Title: "취소", btn2Title: "탈퇴") {
            } btn2Action: {
                self.req.apiUserDelete {
                    self.showAlertBtn1(title: "탈퇴 안내", message: "탈퇴를 성공했습니다.", btnTitle: "확인") {
                        //로그아웃
                        self.logout()
                    }
                } fail: {
                    self.showAlertBtn1(title: "탈퇴 안내", message: "탈퇴를 실패했습니다.", btnTitle: "확인") {}
                }

            }

        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbarSetting(title: "설정 페이지")
    }
    
}
