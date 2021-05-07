//
//  LoginViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/07.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet var tfId: UITextField!
    @IBOutlet var tfPw: UITextField!
    
    @IBAction func btnLoginAction(_ sender: UIButton) {
        //유효성 검사
        validateField()
        
        //로그인 정보를 저장할 파일 경로를 생성
        let fileMgr = FileManager.default
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let loginPath = docPathURL.appendingPathComponent("login.txt").path
        
        //로그인 처리
        let id = tfId.text!
        let pw = tfPw.text!
        networkCheck {
            //post 방식으로 전송할 파라미터
            let parameters = ["userid":id, "userpw":pw]
            
            let url = "http://192.168.0.4/user/login"
            
            //요청 생성
            let request = AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil)
            //요청을 전송하고 결과 사용하기
            request.responseJSON { response in
                //전체 데이터를 딕셔너리로 변환
                if let jsonObject = response.value as? [String:Any] {
                    //result 키의 데이터 가져오기
                    let result = jsonObject["result"] as! Int32
                    //로그인 성공
                    if result == 1 {
                        //user키의 값을 가져오기
                        let user = jsonObject["user"] as! NSDictionary
                        //username 가져오기
                        let username = user["username"] as! String
                        
                        //아이디와 별명을 저장
                        let data = "\(id):\(username)"
                        let databuffer = data.data(using: .utf8)
                        fileMgr.createFile(atPath: loginPath, contents: databuffer, attributes: nil)
                        
                        NSLog("로그인 성공")
                        self.toListView()
                    } else { //로그인 실패
                        self.showAlertBtn1(title: "로그인 오류", message: "아이디나 비밀번호를 확인해 주세요.", btnTitle: "확인") {}
                    }
                    
                }
            }
        }
    }
    
    //유효성 검사
    func validateField() {
        let id = tfId.text!
        let pw = tfPw.text!
        let alertTitle = "로그인 오류"
        if id.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showAlertBtn1(title: alertTitle, message: "아이디을 입력해 주세요.", btnTitle: "확인") {}
        }
        if id.count < 3 {
            showAlertBtn1(title: alertTitle, message: "아이디는 3글자 이상입니다.", btnTitle: "확인") {}
        }
        if pw.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showAlertBtn1(title: alertTitle, message: "비밀번호를 입력해 주세요.", btnTitle: "확인") {}
        }
        if pw.count < 5 {
            showAlertBtn1(title: alertTitle, message: "비밀번호는 5글자 이상입니다.", btnTitle: "확인") {}
        }
    }
    
    func toListView() {
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListViewController") as! ItemListViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    @IBAction func btnSignUpAction(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
