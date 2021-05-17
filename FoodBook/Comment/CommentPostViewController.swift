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
            let commentid = "\(commentId)"
            //서버와 커뮤니케이션
            req.apiCommentDelete(commentid: commentid, itemid: itemId) { result in
                var msg = ""
                if result == 1 {
                    msg = "댓글 삭제 성공"
                } else {
                    msg = "댓글 삭제 실패"
                }
                showAlertBtn1(title: "업로드 알림", message: "\(msg)했습니다.", btnTitle: "확인") {
                    navigationController?.popViewController(animated: true)
                }
            } fail: {
                showAlertBtn1(title: "업로드 오류", message: "댓글 삭제를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
            }
        }
    }
    
    func insert() {
        let username = UserDefaults.standard.value(forKey: UDkey().username) as? String
        let userimgurl = UserDefaults.standard.value(forKey: UDkey().userimgurl) as? String
        
        let comment = tvComment.text!
        //서버와 커뮤니케이션
        self.req.apiCommentInsert(itemid: itemId, username: username ?? "", userimgurl: userimgurl ?? "", comment: comment) {
            self.showAlertBtn1(title: "업로드 알림", message: "댓글 업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.navigationController?.popViewController(animated: true)
            }
        } fail: {
            self.showAlertBtn1(title: "업로드 오류", message: "댓글 업로드를 실패했습니다. 다시 시도해주세요.", btnTitle: "확인") {}
        }
    }
    
    func edit() {
        let comment = tvComment.text!
        let commentid = "\(commentId)"
        //서버와 커뮤니케이션
        self.req.apiCommentEdit(commentid: commentid, comment: comment) {
            self.showAlertBtn1(title: "업로드 알림", message: "댓글 업로드가 성공적으로 완료되었습니다.", btnTitle: "확인") {
                self.navigationController?.popViewController(animated: true)
            }

        } fail: {
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
        tvComment.layer.borderWidth = 0.3
        tvComment.layer.borderColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        tvComment.layer.masksToBounds = true
        tvComment.layer.cornerRadius = 4
        
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
