//
//  ItemListInputViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/07.
//

import UIKit
import Alamofire

class ItemListInputViewController: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var tfTitle: UITextField!
    @IBOutlet var tfPrice: UITextField!
    @IBOutlet var tvDescription: UITextView!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var btnAdd: UIButton!
    
    //셀의 게시물 아이디
    var itemId = 0
    //셀의 게시물 제목
    var itemName = ""
    //셀의 이미지
    var listImg = UIImage()
    //셀의 가격
    var itemPrice = ""
    //셀의 텍스트
    var itemDescription = ""
    
    //저장, 수정 모드 설정
    var mode = "저장"
    
    @IBAction func btnImgAction(_ sender: UIButton) {
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        itemAdd()
    }
    
    func itemAdd() {
        let itemname = tfTitle.text!
        let price = tfPrice.text!
        let description = tvDescription.text!
        let username = "kim"
        
        let url = "http://192.168.0.4/item/insert"
        
        //이미지
        let img = imgView.image
        //이미지를 데이터로 변환
        //jpg 이면
        let imgData = img?.jpegData(compressionQuality: 0.5)
        //png 이면
        //let imgData = img?.pngData()
        
        //업로드
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(Data(itemname.utf8), withName: "itemname")
            multipartFormData.append(Data(price.utf8), withName: "price")
            multipartFormData.append(Data(username.utf8), withName: "username")
            multipartFormData.append(Data(description.utf8), withName: "description")
            //나중에 fileName 진짜 이름으로 바꿔주자!
            multipartFormData.append(imgData!, withName: "imgurl", fileName: "gray.jpg", mimeType: "image/jpg")
            
        }, to: url, method: .post).responseJSON { response in
            if let jsonObject = response.value as? [String:Any] {
                let result = jsonObject["result"] as! Int32
                if result == 1 {
                    print("삽입 성공")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("삽입 실패")
                    self.showAlertBtn1(title: "업로드 오류", message: "업로드 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
                }
            }
            
        }
        
        
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        showAlertBtn2(title: "아이템 삭제", message: "아이템을 삭제하시겠습니까?", btn1Title: "취소", btn2Title: "삭제") {} btn2Action: { [self] in
            //서버에서 삭제
            //파일이 없는 post 방식에서의 파라미터 만들기
            let parameters = ["itemid":"\(itemId)"]
            
            //서버의 요청 생성
            let request = AF.request("http://192.168.0.4/item/delete", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: [:])
            
            request.responseJSON { response in
                if let jseonObject = response.value as? [String:Any] {
                    let result = jseonObject["result"] as! Int32
                    
                    var msg = ""
                    if result == 1 {
                        msg = "아이템 삭제 성공"
                    } else {
                        msg = "아이템 삭제 실패"
                    }
                    showAlertBtn1(title: "아이템 삭제", message: "\(msg)했습니다.", btnTitle: "확인") {
                        navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
    }
    
    func setting() {
        if mode == "저장" {
            btnDelete.isHidden = true
            btnAdd.setTitle(mode, for: .normal)
        } else {
            btnAdd.setTitle(mode, for: .normal)
            
            tfTitle.text = itemName
            imgView.image = listImg
            tfPrice.text = itemPrice
            tvDescription.text = itemDescription
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}
