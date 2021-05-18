//
//  SignUpViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/18.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet var tfUserId: UITextField!
    @IBOutlet var tfUserName: UITextField!
    @IBOutlet var tfPassWd: UITextField!
    @IBOutlet var tfPassWdAgain: UITextField!
    @IBOutlet var lblUserId: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblPassWd: UILabel!
    @IBOutlet var btnSignUp: DisabledBtn!
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //텍스트필드 입력을 마쳤을때 수행
    @IBAction func tfUserIdAction(_ sender: UITextField) {
        //유효성 검사
        let senderText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        if senderText?.count ?? 0 < 3 {
            lblUserId.text = "아이디는 최소 3자 이상 입니다."
            lblUserId.textColor = UIColor.orange
        } else {
            //네트워크 체크
            networkCheck { [self] in
                req.apiSignUpUserIdCheck(userid: senderText ?? "") {
                    lblUserId.text = "사용 가능한 아이디입니다."
                    lblUserId.textColor = UIColor().mainColor
                    //버튼 활성화
                    btnSignUpIsOn()
                } fail: {
                    lblUserId.text = "이미 존재하는 아이디입니다."
                    lblUserId.textColor = UIColor.orange
                }
            }
        }
    }
    
    //텍스트필드 입력을 마쳤을때 수행
    @IBAction func tfUserNameAction(_ sender: UITextField) {
        //유효성 검사
        let senderText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        if senderText?.count ?? 0 < 2 {
            lblUserName.text = "유저네임은 최소 2자 이상 입니다."
            lblUserName.textColor = UIColor.orange
        } else {
            //네트워크 체크
            networkCheck { [self] in
                req.apiSignUpUserNameCheck(username: senderText ?? "") {
                    lblUserName.text = "사용 가능한 유저네임입니다."
                    lblUserName.textColor = UIColor().mainColor
                    //버튼 활성화
                    btnSignUpIsOn()
                } fail: {
                    lblUserName.text = "이미 존재하는 유저네임입니다."
                    lblUserName.textColor = UIColor.orange
                }
            }
        }
    }
    
    //텍스트필드 입력을 마쳤을때 수행
    @IBAction func tfPassWdAction(_ sender: UITextField) {
        //비밀번호 유효성 검사
        isPasswordValid()
    }
    
    //텍스트필드 입력을 마쳤을때 수행
    @IBAction func tfPassWdAgainAction(_ sender: UITextField) {
        //비밀번호 유효성 검사
        isPasswordValid()
    }
    
    //비밀번호 유효성 검사 - 비밀번호 글자 체크, 일치 체크
    func isPasswordValid() {
        //유효성 검사
        let cleanedPassword = tfPassWd.text?.trimmingCharacters(in: .whitespacesAndNewlines)//공백 제거
        if isPasswordValidCheck(cleanedPassword ?? "") == true {
            if tfPassWd.text != tfPassWdAgain.text {
                lblPassWd.text = "비밀번호가 일치하지 않습니다."
                lblPassWd.textColor = UIColor.orange
            } else {
                lblPassWd.text = "사용 가능한 비밀번호입니다."
                lblPassWd.textColor = UIColor().mainColor
                //버튼 활성화
                btnSignUpIsOn()
            }
        } else {
            self.lblPassWd.text = "비밀번호는 알파벳, 특수문자를 포함, 6자 이상 작성해야합니다."
            self.lblPassWd.textColor = UIColor.orange
        }
    }
    
    //비밀번호 유효성 검사 - 비밀번호 글자 체크
    func isPasswordValidCheck(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}")
        return passwordTest.evaluate(with: password)
    }
    
    //버튼 활성화
    func btnSignUpIsOn() {
        let btnColor = UIColor().mainColor
        if lblUserId.textColor == btnColor && lblUserName.textColor == btnColor && lblPassWd.textColor == btnColor {
            btnSignUp.isOn = .On
        }
    }
    
    //회원가입 버튼
    @IBAction func btnSignUpAction(_ sender: UIButton) {
        //네트워크 확인
        networkCheck {
            self.SignUp()
        }
    }
    
    //회원가입 메소드
    func SignUp() {
        let userid = tfUserId.text!.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        let username = tfUserName.text!.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        let passwd = tfPassWd.text!.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        req.apiSignUp(userid: userid, username: username, passwd: passwd) {
            self.showAlertBtn1(title: "회원가입 알림", message: "회원가입을 성공적으로 완료했습니다.", btnTitle: "확인") {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } fail: {
            self.showAlertBtn1(title: "회원가입 오류", message: "회원가입을 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
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
