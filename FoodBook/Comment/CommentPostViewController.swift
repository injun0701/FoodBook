//
//  CommentAddViewController.swift
//  Injunstagram
//
//  Created by HongInJun on 2021/05/05.
//

import UIKit

class CommentPostViewController: UIViewController {
    
    @IBOutlet var tvComment: UITextView!
    
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var btnAdd: UIButton!
   
    //서버 통신을 위한 객체
    let req = URLRequest()
    
    //게시물 id
    var itemId = ""
    //게시물 user
    var itemUserName = ""
    //댓글 id
    var commentId = 0
    //댓글 글
    var commentText = ""
    
    //댓글 모드
    var mode = "저장"
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        //네트워크 사용 여부 확인
        networkCheck() { [self] in
            //삭제
            delete()
        }
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        //네트워크 사용 여부 확인
        networkCheck() { [self] in
            if mode == "저장" {
                //유효성 검사
                validateField() {
                    //아이템 삽입
                    self.insert()
                }
            } else {
                //유효성 검사
                validateField() {
                    //아이템 수정
                    self.edit()
                }
            }
        }
    }
    
    func delete() {
        showAlertBtn2(title: "아이템 삭제", message: "아이템을 삭제하시겠습니까?", btn1Title: "취소", btn2Title: "삭제") {} btn2Action: { [self] in
            LoadingHUD.show()
            let commentid = "\(commentId)"
            //서버와 커뮤니케이션
            req.apiCommentDelete(commentid: commentid, itemid: itemId) { result in
                var msg = ""
                if result == 1 {
                    msg = "댓글 삭제 성공"
                } else {
                    msg = "댓글 삭제 실패"
                }
                LoadingHUD.hide()
                showAlertBtn1(title: "업로드 알림", message: "\(msg)했습니다.", btnTitle: "확인") {
                    navigationController?.popViewController(animated: true)
                }
            } fail: {
                LoadingHUD.hide()
                showAlertBtn1(title: "업로드 오류", message: "댓글 삭제를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
            }
        }
    }
    
    func insert() {
        LoadingHUD.show()
        let username = UserDefaults.standard.value(forKey: UDkey().username) as? String
        
        let comment = tvComment.text!
        //서버와 커뮤니케이션
        self.req.apiCommentInsert(itemid: itemId, username: username ?? "", comment: comment, tousername: itemUserName) {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "업로드 알림", message: "댓글 업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.navigationController?.popViewController(animated: true)
            }
        } fail: {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "업로드 오류", message: "댓글 업로드를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    func edit() {
        LoadingHUD.show()
        let comment = tvComment.text!
        let commentid = "\(commentId)"
        //서버와 커뮤니케이션
        self.req.apiCommentEdit(commentid: commentid, comment: comment) {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "업로드 알림", message: "댓글 업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.navigationController?.popViewController(animated: true)
            }

        } fail: {
            LoadingHUD.hide()
            self.showAlertBtn1(title: "업로드 오류", message: "댓글 업로드를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
    }
    
    func setting() {
        title = "댓글 작성"
        self.navigationController?.navigationBar.topItem?.title = ""
        
        //텍스트 뷰 디자인
        textViewDesign(textView: tvComment)
        
        btnAdd.setTitle(mode, for: .normal)
        
        if mode == "저장" {
            btnDelete.isHidden = true
        } else {
            tvComment.text = commentText
        }
    }
    
    //유효성 검사
    func validateField(success: @escaping () -> ()) {
        let comment = tvComment.text!
        
        if comment == "" {
            showAlertBtn1(title: "업로드 오류", message: "빈칸 없이 모두 작성해주세요.", btnTitle: "확인") {}
        } else{
            if comment == self.commentText {
                showAlertBtn1(title: "업로드 오류", message: "댓글 정보가 이전과 동일합니다.", btnTitle: "확인") {}
            } else {
                success()
            }
        }
    }
}
