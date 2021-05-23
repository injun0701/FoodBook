//
//  ItemListInputViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/07.
//

import UIKit
import Alamofire
import Photos

class ItemListPostViewController: UIViewController {
    
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
    var itemImg = UIImage()
    //셀의 이미지 url
    var itemImgUrl = "gray.jpg"
    //셀의 가격
    var itemPrice = ""
    //셀의 텍스트
    var itemDescription = ""
    //셀의 유저 이미지 이름
    var userImgUrl = ""
    //셀의 유저 이름
    var userName = ""
    
    //앨범 객체 생성
    let imagePickerController = UIImagePickerController()
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //저장, 수정 모드 설정
    var mode = "저장"
    
    //이미지 변화 체크
    var imgChange = false
    
    @IBAction func btnImgAddAction(_ sender: UIButton) {
        //사진을 선택하기 위해 앨범 출력
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    //삽입, 수정 버튼
    @IBAction func btnAddAction(_ sender: UIButton) {
        if mode == "저장" {
            //유효성 검사
            validateField() {
                //아이템 삽입
                self.itemAdd()
            }
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
        LoadingHUD.show()
        let itemname = tfTitle.text!
        let price = tfPrice.text!
        let description = tvDescription.text!
        let itemimgurl = itemImgUrl
        let username = userName
        let img = imgView.image!//이미지
        
        //서버에서 아이템 데이터 삽입
        req.apiItemInsert(itemname: itemname, price: price, description: description, itemimgurl: itemimgurl, username: username, img: img) {
            self.showAlertBtn1(title: "업로드 알림", message: "업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                LoadingHUD.hide()
                self.navigationController?.popToRootViewController(animated: true)
            }
        } fail: {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "업로드 오류", message: "업로드 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    //유효성 검사
    func validateField(success: @escaping () -> ()) {
        let itemname = tfTitle.text!
        let price = tfPrice.text!
        let description = tvDescription.text!
        let itemImg = itemImg
        
        if itemname == "" || price == "" || description == "" {
            showAlertBtn1(title: "업로드 오류", message: "빈칸 없이 모두 작성해주세요.", btnTitle: "확인") {}
        } else {
            if itemname == self.itemName && price == self.itemPrice && description == self.itemDescription && itemImg == imgView.image {
                showAlertBtn1(title: "업로드 오류", message: "게시물 정보가 이전과 동일합니다.", btnTitle: "확인") {}
            } else {
                success()
            }
        }
    }
    
    //아이템 수정
    func itemEdit() {
        LoadingHUD.show()
        let itemid = itemId
        let itemname = tfTitle.text!
        let price = tfPrice.text!
        let description = tvDescription.text!
        let itemimgurl = itemImgUrl
        let username = userName
        
        //이미지
        let img = imgView.image
        
        let imgChange = self.imgChange
        
        //서버에서 아이템 데이터 수정
        req.apiItemEdit(itemid: itemid, itemname: itemname, price: price, description: description, itemimgurl: itemimgurl, username: username, img: img!, imgChange: imgChange) {
            self.showAlertBtn1(title: "업로드 알림", message: "업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                LoadingHUD.hide()
                self.navigationController?.popToRootViewController(animated: true)
            }
        } fail: {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "업로드 오류", message: "업로드 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }

    }
    
    //삭제 버튼
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        showAlertBtn2(title: "아이템 삭제", message: "아이템을 삭제하시겠습니까?", btn1Title: "취소", btn2Title: "삭제") {} btn2Action: { [self] in
            LoadingHUD.show()
            //서버에서 아이템 데이터 삭제
            req.apiItemDelete(itemid: itemId) { result in
                
                var msg = ""
                if result == 1 {
                    msg = "아이템 삭제 성공"
                } else {
                    msg = "아이템 삭제 실패"
                }
                LoadingHUD.hide()
                showAlertBtn1(title: "아이템 삭제", message: "\(msg)했습니다.", btnTitle: "확인") {
                    navigationController?.popToRootViewController(animated: true)
                }
            } fail: {
                LoadingHUD.hide()
                showAlertBtn1(title: "아이템 삭제", message: "삭제를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
        imagePickerControllerSetting()
    }
    
    func setting() {
        //텍스트뷰 디자인
        textViewDesign(textView: tvDescription)
        
        if mode == "저장" {
            navbarSetting(title: "게시물 저장")
            
            btnDelete.isHidden = true
            btnAdd.setTitle(mode, for: .normal)
        } else {
            navbarSetting(title: "게시물 수정")
            
            btnAdd.setTitle(mode, for: .normal)
            
            tfTitle.text = itemName
            imgView.image = itemImg
            tfPrice.text = itemPrice
            tvDescription.text = itemDescription
        }
    }
    
    func imagePickerControllerSetting() {
        imagePickerController.delegate = self
    }
}

//MARK: 이미지피커컨트롤러
extension ItemListPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //이미지 선택했을때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //이미지뷰를 선택된 이미지로 교체
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgView.image = image
        }
        //선택된 이미지의 이름과 확장자 받아오기
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            itemImgUrl = url.lastPathComponent
            print(itemImgUrl)
        }
        imgChange = true
        dismiss(animated: true, completion: nil)
    }
    
}
