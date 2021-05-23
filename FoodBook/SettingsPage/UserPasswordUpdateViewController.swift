//
//  UserPasswordUpdateViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/21.
//

import UIKit

class UserPasswordUpdateViewController: UIViewController {
    @IBOutlet var tfCurrentPasswd: UITextField!
    @IBOutlet var lblCurrentPasswd: UILabel!
    
    @IBOutlet var tfNewPasswd: UITextField!
    @IBOutlet var tfNewPasswdAgain: UITextField!
    @IBOutlet var lblNewPasswd: UILabel!
    
    @IBOutlet var btnPasswdUpdate: DisabledBtn!
    
    //서버 객체
    var req = URLRequest()
    
    //텍스트필드 입력을 마쳤을때 수행
    @IBAction func tfCurrentPasswdAction(_ sender: UITextField) {
        //유효성 검사
        isCurrentPasswordValid()
    }
    
    //현재 비밀번호 유효성 검사 - 비밀번호 글자 체크
    func isCurrentPasswordValid() {
        //유효성 검사
        let cleanedPassword = tfCurrentPasswd.text?.trimmingCharacters(in: .whitespacesAndNewlines)//공백 제거
        if isPasswordValidCheck(cleanedPassword ?? "") == true {
            //네트워크 확인
            networkCheck {
                //현재 비밀번호가 맞는지 서버에 조회
                self.currentPasswordCheck()
            }
        } else {
            self.lblCurrentPasswd.text = "알파벳, 특수문자를 포함, 6~12자 작성해야 합니다."
            self.lblCurrentPasswd.textColor = UIColor.orange
        }
    }
    
    //현재 비밀번호가 맞는지 서버에 조회
    func currentPasswordCheck() {
        let passwd = tfCurrentPasswd.text?.trimmingCharacters(in: .whitespacesAndNewlines)//공백 제거
        //서버에 조회
        req.apiUserPasswordCheck(passwd: passwd!) {
            self.lblCurrentPasswd.text = "현재 비밀번호를 성공적으로 확인 완료했습니다."
            self.lblCurrentPasswd.textColor = UIColor().mainColor
            //버튼 활성화
            self.btnSignUpIsOn()
        } fail: {
            self.lblCurrentPasswd.text = "현재 비밀번호를 확인해주세요."
            self.lblCurrentPasswd.textColor = UIColor.orange
        }
    }
    
    //텍스트필드 입력을 마쳤을때 수행
    @IBAction func tfNewPasswdAction(_ sender: UITextField) {
        //네트워크 체크
        networkCheck { [self] in
            //비밀번호 유효성 검사
            isNewPasswordValid()
        }
    }
    
    //텍스트필드 입력을 마쳤을때 수행
    @IBAction func tfNewPasswdAgainAction(_ sender: UITextField) {
        //네트워크 체크
        networkCheck { [self] in
            //비밀번호 유효성 검사
            isNewPasswordValid()
        }
    }
    
    //비밀번호 유효성 검사 - 비밀번호 글자 체크, 일치 체크
    func isNewPasswordValid() {
        //유효성 검사
        let cleanedPassword = tfNewPasswd.text?.trimmingCharacters(in: .whitespacesAndNewlines)//공백 제거
        if isPasswordValidCheck(cleanedPassword ?? "") == true {
            if tfNewPasswd.text != tfNewPasswdAgain.text {
                lblNewPasswd.text = "새 비밀번호가 일치하지 않습니다."
                lblNewPasswd.textColor = UIColor.orange
            } else {
                lblNewPasswd.text = "사용 가능한 비밀번호입니다."
                lblNewPasswd.textColor = UIColor().mainColor
                //버튼 활성화
                btnSignUpIsOn()
            }
        } else {
            self.lblNewPasswd.text = "알파벳, 특수문자를 포함, 6~12자로 작성해야 합니다."
            self.lblNewPasswd.textColor = UIColor.orange
        }
    }
    
    //비밀번호 유효성 검사 - 비밀번호 글자 체크
    func isPasswordValidCheck(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,12}")
        return passwordTest.evaluate(with: password)
    }
    
    //버튼 활성화
    func btnSignUpIsOn() {
        let btnColor = UIColor().mainColor
        if lblCurrentPasswd.textColor == btnColor && lblNewPasswd.textColor == btnColor {
            btnPasswdUpdate.isOn = .On
        }
    }
    
    //저장 버튼
    @IBAction func btnPasswdUpdateAction(_ sender: DisabledBtn) {
        //네트워크 확인
        networkCheck {
            self.passwdUpdate()
        }
    }
    
    func passwdUpdate() {
        LoadingHUD.show()
        guard let cleanedPassword = tfNewPasswd.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
//        //AES.swift에 있는 기능 이용, 사용자가 입력한 텍스트를 암호화한다.
        let encryptPassword = AES256CBC.encryptString(cleanedPassword, password: AESkey().defaultKey)!
        //비밀번호 수정
        req.apiUserPasswordUpdate(passwd: encryptPassword) {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "비밀번호 변경", message: "비밀번호 변경이 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.navigationController?.popViewController(animated: true)
            }
        } fail: {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "비밀번호 변경", message: "비밀번호 변경을 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbarSetting(title: "비밀번호 변경")
    }
}
