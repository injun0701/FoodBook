//
//  ViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/06.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    //로그인 버튼
    @IBAction func toLoginViewAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Login", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: (실제 기기 테스트를 위한)임시 로컬 허용 얼럿 - 실제 url로 바뀌면 꼭 삭제하자!!!
        testAF()
    }
    
    //MARK: (실제 기기 테스트를 위한)임시 로컬 허용 얼럿 - 실제 url로 바뀌면 꼭 삭제하자!!!
    func testAF() {
        //데이터를 다운로드 받을 URL
        let url = "http://192.168.0.4/item/getall"
        networkCheck {
            //데이터 다운로드 - get 방식이고 파라미터 없고 결과는 json
            let request = AF.request(url, method: .get, encoding: JSONEncoding.default, headers: nil)
            request.responseJSON { response in
               
            }
        }
    }
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        naviDesignSetting()
    }
    
    //네비게이션 세팅
    func naviDesignSetting() {
        title = "FoodBook"
        //백버튼 텍스트 제거
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] //타이틀 글자색
        self.navigationController?.navigationBar.barTintColor = UIColor().mainColor //네비 바 배경색
        self.navigationController?.navigationBar.isTranslucent = false //네비 바 배경 기본 반투명 false
        
        //네비 라인 삭제
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.barStyle = .black //상태바 글자 흰색으로 설정하기위해 네비바 barStyle를 black
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent //상태바 글자 검정
    }

}

