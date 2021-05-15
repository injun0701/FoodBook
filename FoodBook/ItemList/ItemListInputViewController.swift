//
//  ItemListInputViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/07.
//

import UIKit
import Alamofire
import Photos

class ItemListInputViewController: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var tfTitle: UITextField!
    @IBOutlet var tfPrice: UITextField!
    @IBOutlet var tvDescription: UITextView!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var btnAdd: UIButton!
    
    //셀의 게시물 아이디
    var itemId = ""
    //셀의 게시물 제목
    var itemName = ""
    //셀의 이미지
    var listImg = UIImage()
    //셀의 이미지 url
    var listImgUrl = "gray.jpg"
    //셀의 가격
    var itemPrice = ""
    //셀의 텍스트
    var itemDescription = ""
    //셀의 유저 이미지 이름
    var userimgurl = ""
    //셀의 유저 이름
    var username = ""
    
    //앨범 객체 생성
    let imagePickerController = UIImagePickerController()
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //저장, 수정 모드 설정
    var mode = "저장"
    
    @IBAction func btnImgAction(_ sender: UIButton) {
        //사진을 선택하기 위해 앨범 출력
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    //삽입, 수정 버튼
    @IBAction func btnAddAction(_ sender: UIButton) {
        if mode == "저장" {
            //아이템 삽입
            itemAdd()
        } else {
            //유효성 검사
            validateField() {
                //아이템 수정
                self.itemEdit()
            }
        }
    }
    
    //아이템 삽입
    func itemAdd() {
        let itemname = tfTitle.text!
        let price = tfPrice.text!
        let description = tvDescription.text!
        let listimgUrl = listImgUrl
        let userimgurl = userimgurl
        let username = username
        let img = imgView.image!//이미지
        
        //서버에서 아이템 데이터 삽입
        req.apiItemInsert(itemname: itemname, price: price, description: description, userimgurl: userimgurl, listimgUrl: listimgUrl, username: username, img: img) {
            self.navigationController?.popViewController(animated: true)
        } fail: {
            self.showAlertBtn1(title: "업로드 오류", message: "업로드 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //유효성 검사
    func validateField(success: @escaping () -> ()) {
        let itemname = tfTitle.text!
        let price = tfPrice.text!
        let description = tvDescription.text!
        let listImg = listImg
        
        if itemname == self.itemName && price == self.itemPrice && description == self.itemDescription && listImg == imgView.image {
            showAlertBtn1(title: "업로드 오류", message: "게시물 정보가 이전과 동일합니다.", btnTitle: "확인") {}
        } else {
            success()
        }
    }
    
    //아이템 수정
    func itemEdit() {
        let itemid = itemId
        let itemname = tfTitle.text!
        let price = tfPrice.text!
        let description = tvDescription.text!
        let listimgUrl = listImgUrl
        let username = username
        
        //이미지
        let img = imgView.image
        
        //서버에서 아이템 데이터 수정
        req.apiItemEdit(itemid: itemid, itemname: itemname, price: price, description: description, listimgUrl: listimgUrl, username: username, img: img!) {
            self.navigationController?.popViewController(animated: true)
        } fail: {
            self.showAlertBtn1(title: "업로드 오류", message: "업로드 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }

    }
    
    //삭제 버튼
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        showAlertBtn2(title: "아이템 삭제", message: "아이템을 삭제하시겠습니까?", btn1Title: "취소", btn2Title: "삭제") {} btn2Action: { [self] in
            //서버에서 아이템 데이터 삭제
            req.apiItemDelete(itemid: itemId) { result in
                
                var msg = ""
                if result == 1 {
                    msg = "아이템 삭제 성공"
                } else {
                    msg = "아이템 삭제 실패"
                }
                showAlertBtn1(title: "아이템 삭제", message: "\(msg)했습니다.", btnTitle: "확인") {
                    navigationController?.popViewController(animated: true)
                }
            } fail: {
                self.showAlertBtn1(title: "아이템 삭제", message: "삭제를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
        imageSetting()
    }
    
    func setting() {
        tvDescription.layer.borderWidth = 0.3
        tvDescription.layer.borderColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        tvDescription.layer.masksToBounds = true
        tvDescription.layer.cornerRadius = 4
        
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
    
    func imageSetting() {
        imagePickerController.delegate = self
    }
}

//MARK: 이미지피커컨트롤러
extension ItemListInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //이미지 선택했을때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //이미지뷰를 선택된 이미지로 교체
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgView.image = image
        }
        //선택된 이미지의 이름과 확장자 받아오기
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            listImgUrl = url.lastPathComponent
            print(listImgUrl)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
