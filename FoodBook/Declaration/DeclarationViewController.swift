//
//  DeclarationViewController.swift
//  FoodBook
//
//  Created by HongInJun on 2021/05/26.
//

import UIKit

class DeclarationViewController: UIViewController {

    @IBOutlet var tvContents: UITextView!
    
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    var itemId = ""
    var commentId = ""
    
    @IBAction func btnDeclarationAction(_ sender: UIButton) {
        let commentid = commentId
        let tvContents = tvContents.text!
        if tvContents == "" {
            self.showAlertBtn1(title: "신고", message: "신고 내용을 입력해주세요.", btnTitle: "확인") {}
        } else {
            req.apiDeclaration(itemid: itemId, commentid: commentid, declaration: tvContents) {
                self.showAlertBtn1(title: "신고", message: "신고가 완료되었습니다. 24시간 안으로 조치하겠습니다.", btnTitle: "확인") {
                    rootVC()
                }
            } fail: {
                self.showAlertBtn1(title: "신고", message: "신고를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "신고"
        self.navigationController?.navigationBar.topItem?.title = ""
        
        //텍스트 뷰 디자인
        textViewDesign(textView: tvContents)
    }
    
}
