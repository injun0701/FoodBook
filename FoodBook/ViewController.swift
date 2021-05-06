//
//  ViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/06.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBAction func toItemListAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "ItemList", bundle: nil)
        let navi = sb.instantiateViewController(withIdentifier: "ItemListViewController") as! ItemListViewController
        navigationController?.pushViewController(navi, animated: true)
    }
    
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
        
    override func viewWillAppear(_ animated: Bool) {
        navbarSetting(title: "FoodBook")
    }
}

