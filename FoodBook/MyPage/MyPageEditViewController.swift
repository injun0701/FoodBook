//
//  MyPageEditViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/20.
//

import UIKit

class MyPageEditViewController: UIViewController {
    
    @IBOutlet var imgViewUser: UIImageView!
    @IBOutlet var btnImgAdd: UIButton!
    @IBOutlet var lblUserId: UILabel!
    @IBOutlet var tfUserName: UITextField!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var btnAdd: DisabledBtn!
    
    //유저 이미지
    var userImg = UIImage()
    //유저 아이디
    var userId = ""
    //유저 네임
    var userName = ""
    //유저 이미지 url
    var userImgUrl = UserDefaults.standard.value(forKey: UDkey().userimgurl) as? String
    
    //이미지 변화 체크
    var imgChange = false
    
    //앨범 객체 생성
    let imagePickerController = UIImagePickerController()
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    @IBAction func btnImgAddAction(_ sender: UIButton) {
        //사진을 선택하기 위해 앨범 출력
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    //입력을 마쳤을때 호출
    @IBAction func tfUserName(_ sender: UITextField) {
        //유효성 검사
        let senderText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) //공백 제거
        if senderText?.count ?? 0 < 2 || senderText?.count ?? 0 > 12 {
            lblUserName.text = "유저네임은 2~12자로 작성해야 합니다."
            lblUserName.textColor = UIColor.orange
        } else {
            if senderText == userName {
                lblUserName.text = "유저네임가 기존 내용이랑 동일합니다."
                lblUserName.textColor = UIColor.orange
            } else {
                //네트워크 체크
                networkCheck { [self] in
                    req.apiSignUpUserNameCheck(username: senderText ?? "") {
                        lblUserName.text = "사용 가능한 유저네임입니다."
                        lblUserName.textColor = UIColor().mainColor
                        //버튼 활성화
                        btnAddIsOn()
                    } fail: {
                        lblUserName.text = "이미 존재하는 유저네임입니다."
                        lblUserName.textColor = UIColor.orange
                    }
                }
            }
        }
    }
    
    //저장 버튼
    @IBAction func btnAddAction(_ sender: UIButton) {
        //네트워크 확인
        networkCheck {
            self.userUpdate()
        }
    }
    
    func userUpdate() {
        let userId = userId
        let userImgUrl = userImgUrl!
        let username = tfUserName.text!
        
        //이미지
        let img = imgViewUser.image
        
        let imgChange = self.imgChange
        
        //서버에서 아이템 데이터 수정
        req.apiUserEdit(userid: userId, username: username, userimgurl: userImgUrl, img: img!, imgChange: imgChange, success: { userid, username, userimgurl in
            print("userid:\(userid), username:\(username), userimgurl\(userimgurl)")
            UserDefaults.standard.set(userid, forKey: UDkey().userid)
            UserDefaults.standard.set(username, forKey: UDkey().username)
            UserDefaults.standard.set(userimgurl, forKey: UDkey().userimgurl)
            
            self.navigationController?.popViewController(animated: true)
        }, fail: {
            self.showAlertBtn1(title: "업로드 오류", message: "업로드 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        })
    }
    
    //버튼 활성화
    func btnAddIsOn() {
        let ldlColorMainColor = UIColor().mainColor
        if lblUserName.textColor == ldlColorMainColor || imgChange == true{
            btnAdd.isOn = .On
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //네비 세팅
        navbarSetting(title: "내 정보 수정")
        viewSetting()
        imagePickerControllerSetting()
    }
    
    //뷰 세팅
    func viewSetting() {
        imgViewUser.image = userImg
        lblUserId.text = userId
        tfUserName.text = userName
        
        //유저이미지, btnImgAdd 라운드 처리
        DispatchQueue.main.async { [self] in
            imgViewUser.layer.cornerRadius = imgViewUser.frame.height/2
            imgViewUser.clipsToBounds = true
            
            btnImgAdd.layer.cornerRadius = btnImgAdd.frame.height/2
            btnImgAdd.clipsToBounds = true
        }
    }
    
    func imagePickerControllerSetting() {
        imagePickerController.delegate = self
    }
}

//MARK: 이미지피커컨트롤러
extension MyPageEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //이미지 선택했을때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //이미지뷰를 선택된 이미지로 교체
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgViewUser.image = image
        }
        //선택된 이미지의 이름과 확장자 받아오기
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            userImgUrl = url.lastPathComponent
            print(userImgUrl!)
        }
        imgChange = true
        btnAddIsOn()
        dismiss(animated: true, completion: nil)
    }
    
}
